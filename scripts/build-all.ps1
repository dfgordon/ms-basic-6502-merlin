#Requires -Version 7.4

# AI enhanced build script

# Demand that the working directory is the project root
if (-not (Test-Path -Path ".\merlin-src" -PathType Container)) {
    Write-Error "Please run from project directory"
    exit 1
}

# Find Merlin in the path with allowance for versioned names.
# Policy is simply to take the first match.
$exePattern = "(?i)^Merlin32(-v[0-9]\.[0-9]?)?(\.exe)?$"
$matchedApp = Get-Command -CommandType Application -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -match $exePattern } |
    Select-Object -First 1
if (-not $matchedApp) {
    Write-Error "Could not find Merlin 32 in the system PATH."
    exit 1
}
$merlinExe = $matchedApp.Source
Write-Host "Using executable: $merlinExe" -ForegroundColor Green

# Ensure build directory exists
if (-not (Test-Path -Path ".\build" -PathType Container)) {
    $null = New-Item -Path ".\build" -ItemType Directory
}

# N.b. the last case is the one that will determine the final state of the switchbox
$cases = @(
    @{Name="kim.primitive"; RealIO="valKIM";   Sw=@();                    Src="MSB6502.S"},
    @{Name="kim";           RealIO="valKIM";   Sw=@("swKIM");             Src="MSB6502.S"},
    @{Name="osi.primitive"; RealIO="valOSI";   Sw=@();                    Src="MSB6502.S"},
    @{Name="osi";           RealIO="valOSI";   Sw=@("swOSI");             Src="MSB6502.S"},
    @{Name="osi.ubfix";     RealIO="valOSI";   Sw=@("swOSI","swOSIFIX");  Src="MSB6502.S"},
    @{Name="pet1.primitive";RealIO="valPET";   Sw=@();                    Src="MSB6502.S"},
    @{Name="pet1";          RealIO="valPET";   Sw=@("swPET");             Src="MSB6502.S"},
    @{Name="apple.primitive";RealIO="valApple";Sw=@();                    Src="MSB6502.S"},
    @{Name="apple";         RealIO="valApple"; Sw=@("swAPPLE2");          Src="link_apple.S"}
)
$validSwitches = @('swKIM', 'swOSI', 'swOSIFIX', 'swPET', 'swAPPLE2')

$successCount = 0
$failCount = 0

foreach ($case in $cases) {
    $basename = $case.Name
    Write-Host "`n--- Assembling $basename ---" -ForegroundColor Cyan

    # Remove any leftover artifacts from a previous run so we don't accidentally move stale files
    Remove-Item -Force -ErrorAction SilentlyContinue "merlin-src/MSBASOBJ", "merlin-src/MSBASOBJ_*", "merlin-src/_FileInformation.txt"

    $params = @{
        FilePath = "merlin-src/switchbox.s"
        REALIO = $case.RealIO
    }
    foreach ($sw in $validSwitches) {
        $params[$sw] = $case.Sw.Contains($sw)
    }

    & "$PSScriptRoot/Set-AssemblySwitches.ps1" @params
    & $merlinExe "merlin-src" ("merlin-src/" + $case.Src)

    # Check both the exit code and whether MSBASOBJ was actually generated
    if ($LASTEXITCODE -eq 0 -and (Test-Path -Path "merlin-src/MSBASOBJ" -PathType Leaf)) {
        Move-Item -Force "merlin-src/MSBASOBJ" ("build/" + $basename + ".out")
        Move-Item -Force -ErrorAction SilentlyContinue "merlin-src/MSBASOBJ_*" "build/"
        Remove-Item -Force -ErrorAction SilentlyContinue "merlin-src/_FileInformation.txt"

        Write-Host "`u{2714} $basename assembled successfully" -ForegroundColor Green
        $successCount++
    } else {
        Write-Host "`u{2718} $basename assembly failed" -ForegroundColor Red
        $failCount++
    }
}

Write-Host "`n============================="
Write-Host "`u{2714} Successful cross-assemblies: $successCount" -ForegroundColor Green
if ($failCount -gt 0) {
    Write-Host "`u{2718} Failed cross-assemblies:     $failCount" -ForegroundColor Red
    exit 1
} else {
    Write-Host "Failed cross-assemblies:     0"
    exit 0
}
