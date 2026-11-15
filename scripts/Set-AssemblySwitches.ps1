# This is an AI generated script to modify the switchbox.s header file.
# We need this for automation because Merlin 32 does not have command line switches.

param(
    [Parameter(Mandatory = $true)]
    [string]$FilePath,

    # REALIO can be a number (0-5) or one of: valSim, valKIM, valOSI, valPET, valApple, valSTM
    [string]$REALIO,

    [int]$swKIM,
    [int]$swOSI,
    [int]$swOSIFIX,
    [int]$swPET,
    [int]$swAPPLE2,

    # Optional: write to a different file instead of overwriting the original
    [string]$OutputPath
)

if (-not (Test-Path -LiteralPath $FilePath)) {
    Write-Error "File not found: $FilePath"
    exit 1
}

# Map friendly REALIO names to their numeric values if needed
$realioMap = @{
    'valSim'   = '0'
    'valKIM'   = '1'
    'valOSI'   = '2'
    'valPET'   = '3'
    'valApple' = '4'
    'valSTM'   = '5'
}

function Get-RealIoValue([string]$value) {
    if ([string]::IsNullOrWhiteSpace($value)) { return $null }
    if ($realioMap.ContainsKey($value)) {
        return $realioMap[$value]
    }
    # Allow raw numbers or the existing symbolic form (e.g. valApple)
    return $value
}

$content = Get-Content -LiteralPath $FilePath -Raw

# Helper to replace an EQU line while preserving leading whitespace and any trailing comment
function Update-EquLine {
    param(
        [string]$Text,
        [string]$Symbol,
        [string]$NewValue
    )

    if ($null -eq $NewValue) { return $Text }

    # Matches: optional whitespace, symbol, whitespace, EQU, whitespace, value, rest of line
    $pattern = "(?m)^([ \t]*$Symbol[ \t]+EQU[ \t]+)(\S+)(.*)$"
    $replacement = "`${1}$NewValue`$3"

    if ($Text -match $pattern) {
        return [regex]::Replace($Text, $pattern, $replacement)
    }
    else {
        Write-Warning "Symbol '$Symbol' not found in file. Skipping."
        return $Text
    }
}

# Apply updates only for parameters that were actually supplied
$realioValue = Get-RealIoValue $REALIO
if ($PSBoundParameters.ContainsKey('REALIO')) {
    $content = Update-EquLine -Text $content -Symbol 'REALIO' -NewValue $realioValue
}
if ($PSBoundParameters.ContainsKey('swKIM')) {
    $content = Update-EquLine -Text $content -Symbol 'swKIM' -NewValue $swKIM
}
if ($PSBoundParameters.ContainsKey('swOSI')) {
    $content = Update-EquLine -Text $content -Symbol 'swOSI' -NewValue $swOSI
}
if ($PSBoundParameters.ContainsKey('swOSIFIX')) {
    $content = Update-EquLine -Text $content -Symbol 'swOSIFIX' -NewValue $swOSIFIX
}
if ($PSBoundParameters.ContainsKey('swPET')) {
    $content = Update-EquLine -Text $content -Symbol 'swPET' -NewValue $swPET
}
if ($PSBoundParameters.ContainsKey('swAPPLE2')) {
    $content = Update-EquLine -Text $content -Symbol 'swAPPLE2' -NewValue $swAPPLE2
}

# Determine output path
$targetPath = if ($OutputPath) { $OutputPath } else { $FilePath }

# Write the result (preserve original encoding as much as possible)
Set-Content -LiteralPath $targetPath -Value $content -NoNewline -Encoding UTF8

Write-Host "Updated header written to: $targetPath"