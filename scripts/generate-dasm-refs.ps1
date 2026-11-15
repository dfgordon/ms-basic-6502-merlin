# This (re)generates the DASM reference files for comparison with Merlin.
# It assumes the DASM object files are in `dasm-build`.
# Normally this is not needed since it has already been done,
# and the reference files are kept in `test`.

$cases = @(
    [Tuple]::Create("kim",0x2000),
    [Tuple]::Create("osi",0xA000),
    [Tuple]::Create("pet1",0xC000),
    [Tuple]::Create("apple",0xD000)
)

if (-not (Test-Path -Path ".\merlin-src" -PathType Container)) {
    Write-Error "Please run from project directory"
    exit 1
}

foreach ($case in $cases) {
    & "$PSScriptRoot/Format-Hex7bit.ps1" ("dasm-build/"+$case.item1+".out") -Offset $case.item2 > ("test/"+$case.item1+".dasm.ref")
    & "$PSScriptRoot/Format-Hex7bit.ps1" ("dasm-build/"+$case.item1+".primitive.out") -Offset $case.item2 > ("test/"+$case.item1+".primitive.dasm.ref")
}

& "$PSScriptRoot/Format-Hex7bit.ps1" "dasm-build/osi.ubfix.out" -Offset 0xA000 > "test/osi.ubfix.dasm.ref"
