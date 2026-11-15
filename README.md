# Microsoft BASIC Sources

## Origins

This is a Merlin port of Microsoft BASIC for various early computers with 6502 processors.

It was first ported by "Uncle Bernie" (UB) to the DASM cross-assembler, and extended to account
for vendor extensions and patches.  This project is a port of that port, specifically:

* Microsoft wrote their BASIC in MACRO-10 assembly language on a DEC PDP-10 mainframe
* "Uncle Bernie" (UB) added patches and extensions from the various vendor, and ported to the DASM cross-assembler
* I (DFG) ported the UB package to the Merlin 32 cross-assembler

## Building

This package will allow you to:

* Assemble code that matches various ROM images found on the web
* Assemble primitive MS-BASIC targeted for a specific vendor, but without the vendor's own patches or extensions
* Assemble with a wide range of fine grained settings (results may vary, we cannot test them all)

See the scripts directory for more.

## Dependencies

* Merlin 32 cross assembler
  - For predictable results use the executable from [Brutal Deluxe](http://www.brutaldeluxe.fr/products/crossdevtools/merlin/) since this is what was used for testing
  - You can try your luck building one of the various forks such as [apple2accumulator](https://github.com/apple2accumulator/merlin32)
* PowerShell 7
  - Don't use the `Windows PowerShell` that comes with Windows, install PowerShell 7
  - Yes it should work on Mac and Linux, just install it