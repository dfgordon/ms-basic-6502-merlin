# Elements from the UB package

This is a place to put things from the "Uncle Bernie" (UB) package that don't really apply to this one.
Everything in this directory is directly from the UB package, except this README.
For more see UB's `CONTENTS` file. Package layout differs as follows:

1. Linux build products are not included here
2. DASM version of the source code is moved to `dasm-src`
3. Original `README` renamed `README-ub`

## DASM Syntax and PowerShell

This project uses a lot of PowerShell.  The DASM syntax is not compatible with PowerShell.  The workaround is to use quotes.

In particular PS does not accept arguments of the form `-l<something>.<other>`, i.e., it will parse that rather than take it literally.  So the solution to this sort of thing, as usual, is quote it.

If you want a PowerShell equivalent of UB's DASM upgrade test try this:

```ps1
./ub_dasm test.asm -v3 '-ltest.lst' > test.out
Compare-Object (Get-Content test.out) (Get-Content test.ref1)
Compare-Object (Get-Content test.lst) (Get-Content test.ref2)
```
