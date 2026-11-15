* Equates related to "primitive Apple BASIC" (without extensions)
*
* These are zero-page locations extracted from the symbol
* table that falls out of the dummy zero-page section in
* the source file `MSB6502.S`. Ideally we would export these
* directly using `ENT`, but it was found that Merlin 32 will
* use absolute addressing (as opposed to zero-page) in that case,
* and we will get object code that doesn't match expectations.
*
* As a result of the above issue, we create this header by
* pulling from the symbol table of `MSB6502.S`.

SUBFLG   EQU   $0014
LINNUM   EQU   $0050
VARTAB   EQU   $0069
STREND   EQU   $006D
FRETOP   EQU   $006F
MEMSIZ   EQU   $0073
CURLIN   EQU   $0075
LOWTR    EQU   $009B
FAC      EQU   $009D
DSCTMP   EQU   $009D
PRGEND   EQU   $00AF
CHRGOT   EQU   $00B7
TXTPTR   EQU   $00B8
