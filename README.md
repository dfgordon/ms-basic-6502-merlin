# Microsoft BASIC Sources

## Origins

In 2025 Microsoft released the source code for Microsoft BASIC for the 6502 processor.
It was quickly ported to modern cross-assemblers, first by "Uncle Bernie" (UB), and then by this author (DFG). Specifically,

* Microsoft wrote their BASIC in MACRO-10 assembly language on a DEC PDP-10 mainframe
* UB ported to the DASM cross-assembler, and importantly, added patches and extensions from the various vendors
* DFG ported the UB package to the Merlin 32 cross-assembler

Years earlier the source code was leaked and analyzed by Michael Steil, see [here](https://www.pagetable.com/135).

## Motivation

This package enables the following:

* Browse Microsoft BASIC source code in a form compatible with various language servers
* Assemble code that matches various ROM images found on the web
* Assemble primitive MS-BASIC targeted for a specific vendor, but without the vendor's own patches or extensions
* Assemble with a wide range of fine grained settings (results may vary, we cannot test them all)

See the scripts directory for more on how to assemble object files.

## Dependencies

* Merlin 32 cross assembler
  - For predictable results use the executable from [Brutal Deluxe](http://www.brutaldeluxe.fr/products/crossdevtools/merlin/) since this is what was used for testing
  - You can try your luck building one of the various forks such as [apple2accumulator](https://github.com/apple2accumulator/merlin32)
* PowerShell 7
  - Don't use `Windows PowerShell`, install PowerShell 7
  - Scripts have been tested and verified on Linux, Mac, and Windows

## Project Structure

The items essential to the Merlin 32 port are:

* `merlin-src`- contains all the source files needed to assemble Microsoft BASIC in a variety of configurations
* `scripts` - contains build and test scripts
* `test` - contains reference data for the test scripts

Other items include:

* `dasm-src` - contains the source code from which `merlin-src` was derived
* `ub-package` - contains items from the UB package geared toward assembling with DASM
* `macro10-src` - a copy of the 2025 Microsoft release
