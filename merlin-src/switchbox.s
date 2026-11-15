* DFG - This "switchbox" was formerly embedded directly in `MSB6502.S` by UB.
* We moved it to its own `PUT` file to make editing the values via a script
* less intrusive to the main code. This comes about because Merlin does not
* provide a way to pass values in from the command line.

* DFG - Conditionals involving REALIO originally used literal comparisons,
* I changed them all to refer to the following constant symbols instead.
* Lower case identifies symbols we have added or altered in some way.

* Let's start to define for which target the code must be generated:

valSim   EQU   0          ; PDP-10 simulating 6502
valKIM   EQU   1          ; MOS TECH,KIM
valOSI   EQU   2
valPET   EQU   3          ; Commodore PET
valApple EQU   4          ; Apple II
valSTM   EQU   5

REALIO   EQU   4

* ... but wait, this is not all. If you only use the REALIO setting, with all
* switches in Uncle Bernie's switchbox set to zero, you get what the original
* source code would generate, and none of the binaries for any of the targets
* would match with the authentic binaries that can be found on the web. This
* is due to the differences mentioned above. So you also have to set the KIM,
* OSI, PET or APPLE2 switch in the switchbox.
*
* DFG - removed comments pertaining to DASM command line switches which have
* been removed since they do not work with Merlin 32.
*
* =================  Switchbox added by Uncle Bernie  ====================
*
*    KIM if set, generates KIM's KB9 BASIC loaded into KIM's RAM.
*    OSI if set, generates the BASIC ROM images for the Superboard II
* OSIFIX if set  with OSI, add's Uncle Bernie's Y1980 garbage collection
*                bug fix, that affects ROM#3. Also see comments at GARBAG.
*    PET if set, generates the BASIC ROM images for the first PET 2001.
* APPLE2 if set, generates Applesoft ROM images for the Apple II+
*
* If none of these switches are set, assembly reverts to the original
* source code as published by Microsoft. It has none of the modifications
* or extensions found in the ROMs of the machine selected by REALIO, so
* be aware that the binaries will not match the contents of the real ROMs
* =======================================================================

* DFG - I added the `sw` prefix to these in keeping with the idea that
* symbols with lower case are not part of the original MS package.
swKIM      EQU   0
swOSI      EQU   0
swOSIFIX   EQU   0
swPET      EQU   0
swAPPLE2   EQU   1

