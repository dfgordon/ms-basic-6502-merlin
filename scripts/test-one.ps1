#Requires -Version 7.4

# Much of this script is AI generated

param (
    [Parameter(Mandatory)]
    [string]$target_name,
    [Parameter(Mandatory)]
    [ValidateSet('web','dasm')]
    [string]$ref_type,
    [Parameter(Mandatory)]
    [Uint16]$starting_address,
    [int]$MaxErrorsToShow = 10
)

function Remove-Extras {
    param(
        [array]$Text
    )
    $lines = $Text -split "\r?\n"
    $ans = ""
    foreach ($line in $lines) {
        if ($line.Length -ge 52) {
            $ans = $ans + $line.Substring(5,47) + "`r`n"
        }
    }
    return $ans.TrimEnd("`r", "`n")
}

function Write-HexDiff {
    param(
        [string]$ActualLine,
        [string]$ExpectedLine,
        [int]$LineAddress
    )
    $actualBytes = $ActualLine.Trim() -split '\s+'
    $expectedBytes = $ExpectedLine.Trim() -split '\s+'
    $maxLen = [Math]::Max($actualBytes.Count, $expectedBytes.Count)

    # Collect exact addresses of mismatched bytes on this line
    $badAddresses = @()
    for ($b = 0; $b -lt $maxLen; $b++) {
        $act = if ($b -lt $actualBytes.Count) { $actualBytes[$b] } else { "" }
        $exp = if ($b -lt $expectedBytes.Count) { $expectedBytes[$b] } else { "" }
        if ($act -ne $exp) {
            $badAddresses += ('$' + ($LineAddress + $b).ToString("X4"))
        }
    }

    Write-Host ("  Mismatched byte address(es): " + ($badAddresses -join ", ")) -ForegroundColor Cyan

    # Print Actual line with mismatched bytes in Red
    Write-Host "  Actual:   " -NoNewline
    for ($b = 0; $b -lt $maxLen; $b++) {
        $act = if ($b -lt $actualBytes.Count) { $actualBytes[$b] } else { "  " }
        $exp = if ($b -lt $expectedBytes.Count) { $expectedBytes[$b] } else { "  " }

        if ($act -ne $exp) {
            Write-Host "$act " -ForegroundColor Red -NoNewline
        } else {
            Write-Host "$act " -NoNewline
        }
    }
    Write-Host ""

    # Print Expected line with mismatched bytes in Green
    Write-Host "  Expected: " -NoNewline
    for ($b = 0; $b -lt $maxLen; $b++) {
        $act = if ($b -lt $actualBytes.Count) { $actualBytes[$b] } else { "  " }
        $exp = if ($b -lt $expectedBytes.Count) { $expectedBytes[$b] } else { "  " }

        if ($act -ne $exp) {
            Write-Host "$exp " -ForegroundColor Green -NoNewline
        } else {
            Write-Host "$exp " -NoNewline
        }
    }
    Write-Host ""
}

if (-not (Test-Path -Path ".\merlin-src" -PathType Container)) {
    Write-Error "Please run from project directory"
    exit 1
}

$outFile = "build/$target_name.out"
$refFile = "test/$target_name.$ref_type.ref"
$missingFiles = $false

if (-not (Test-Path -Path $outFile -PathType Leaf)) {
    Write-Host "`u{2718} Missing build output file: $outFile" -ForegroundColor Red
    $missingFiles = $true
}

if (-not (Test-Path -Path $refFile -PathType Leaf)) {
    Write-Host "`u{2718} Missing reference file: $refFile" -ForegroundColor Red
    $missingFiles = $true
}

if ($missingFiles) {
    return 1
}

$hex_and_ascii = & "$PSScriptRoot/Format-Hex7bit.ps1" $outFile -Start $starting_address
$ref_and_ascii = Get-Content $refFile

$hex = Remove-Extras -Text $hex_and_ascii
$ref = Remove-Extras -Text $ref_and_ascii

# the following deliberately introduces an error just to make sure we aren't fooling ourselves
# (normally should be commented out)
# $ref = $ref -replace "A9 09","A9 00"

$hex_ary = $hex -split "\r?\n"
$ref_ary = $ref -split "\r?\n"
$maxLines = [Math]::Max($hex_ary.Count, $ref_ary.Count)
$err_count = 0

for ($i = 0; $i -lt $maxLines; $i++) {
    $actLine = if ($i -lt $hex_ary.Count) { $hex_ary[$i] } else { "" }
    $expLine = if ($i -lt $ref_ary.Count) { $ref_ary[$i] } else { "" }

    if ($actLine -ne $expLine) {
        $err_count += 1
        $lineAddr = $starting_address + ($i * 16)

        if ($err_count -le $MaxErrorsToShow) {
            Write-Host ("Error on line $i (line start `$" + $lineAddr.ToString("X4") + ")") -ForegroundColor Yellow
            Write-HexDiff -ActualLine $actLine -ExpectedLine $expLine -LineAddress $lineAddr
        }
    }
}

if ($err_count -gt $MaxErrorsToShow) {
    $hidden = $err_count - $MaxErrorsToShow
    Write-Host "`n... and $hidden more line error(s) hidden (limit: $MaxErrorsToShow)" -ForegroundColor DarkYellow
}

if ($err_count -eq 0) {
    Write-Host ("`r`n`u{2714} succeeded") -ForegroundColor Green
} else {
    Write-Host ("`r`n`u{2718} failed with " + $err_count + " line errors") -ForegroundColor Red
}

return $err_count
