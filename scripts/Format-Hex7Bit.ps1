# This is an AI-generated hex dump program that does something
# close to the C program "Uncle Bernie" used to create reference files.
# There are unimportant differences in the policy for displaying the ASCII.

<#
.SYNOPSIS
    Displays a hex dump of a file with the high bit cleared in the right-hand ASCII column.
.EXAMPLE
    .\Format-Hex7Bit.ps1 -Path "C:\path\to\file.bin"
.EXAMPLE
    .\Format-Hex7Bit.ps1 "file.bin" -Offset 0 -Count 256
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [Alias("FullName")]
    [string]$Path,

    [Parameter()]
    [long]$Offset = 0,

    [Parameter()]
    [long]$Count,

    [Parameter()]
    [long]$Start = 0
)

process {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        Write-Error "File not found: $Path"
        return
    }

    # Build parameters to pass directly to Format-Hex
    $hexParams = @{
        LiteralPath = $Path
        Offset      = $Offset
    }

    if ($PSBoundParameters.ContainsKey('Count')) {
        $hexParams['Count'] = $Count
    }

    Format-Hex @hexParams | ForEach-Object {
        # Clear the high bit (0x7F mask) for the right-hand text preview only
        $ascii = -join ($_.Bytes | ForEach-Object {
            $b = $_ -band 0x7F
            if ($b -ge 32 -and $b -le 126) { [char]$b } else { '.' }
        })

        # Output the original Offset and HexBytes alongside the 7-bit ASCII string
        "{0:X4} {1,-47} {2}" -f ($Start + $_.Offset), $_.HexBytes, $ascii
    }
}
