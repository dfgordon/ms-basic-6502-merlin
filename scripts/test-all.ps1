#Requires -Version 7.4

if (-not (Test-Path -Path ".\merlin-src" -PathType Container)) {
    Write-Error "Please run from project directory"
    exit 1
}

$targets = @(
    @{ Name = "KIM";   File = "kim";   Addr = 0x2000 }
    @{ Name = "OSI";   File = "osi";   Addr = 0xa000 }
    @{ Name = "PET";   File = "pet1";  Addr = 0xc000 }
    @{ Name = "Apple"; File = "apple"; Addr = 0xd000 }
)

$tot_errs = 0

foreach ($t in $targets) {
    Write-Host "`n-----------------------------`n"
    Write-Host "Testing $($t.Name)...`n"
    $tot_errs += (& "$PSScriptRoot/test-one.ps1" $t.File $t.Addr)
}

Write-Host "`n-----------------------------`n"

if ($tot_errs -eq 0) {
    Write-Host "`u{2714} all tests succeeded" -ForegroundColor Green
    exit 0
} else {
    Write-Host "`u{2718} failed with $tot_errs total errors" -ForegroundColor Red
    exit 1
}
