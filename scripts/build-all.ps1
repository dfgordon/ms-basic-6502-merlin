#Requires -Version 7.4

# AI enhanced build script

if (-not (Test-Path -Path ".\merlin-src" -PathType Container)) {
    Write-Error "Please run from project directory"
    exit 1
}

# Ensure build directory exists
if (-not (Test-Path -Path ".\build" -PathType Container)) {
    $null = New-Item -Path ".\build" -ItemType Directory
}

$cases = @(
    @{Name="kim";           RealIO="valKIM";   Sw=@("swKIM");             Src="MSB6502.S"},
    @{Name="kim.primitive"; RealIO="valKIM";   Sw=@();                    Src="MSB6502.S"},
    @{Name="osi";           RealIO="valOSI";   Sw=@("swOSI");             Src="MSB6502.S"},
    @{Name="osi.primitive"; RealIO="valOSI";   Sw=@();                    Src="MSB6502.S"},
    @{Name="osi.ubfix";     RealIO="valOSI";   Sw=@("swOSI","swOSIFIX");  Src="MSB6502.S"},
    @{Name="pet1";          RealIO="valPET";   Sw=@("swPET");             Src="MSB6502.S"},
    @{Name="pet1.primitive";RealIO="valPET";   Sw=@();                    Src="MSB6502.S"},
    @{Name="apple";         RealIO="valApple"; Sw=@("swAPPLE2");          Src="link_apple.S"},
    @{Name="apple.primitive";RealIO="valApple";Sw=@();                    Src="MSB6502.S"}
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
    Merlin32-v1.2 "merlin-src" ("merlin-src/" + $case.Src)

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
