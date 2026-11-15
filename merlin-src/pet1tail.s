; =============================================================================
; pet1.tail: This is Uncle Bernie's disassembly of the last 70 bytes of PET2001
;            BASIC 1, which come after the end of the 'official' source code as
;            published by Microsoft.  It is not known who owns the Copyright to
;            these patches. Possibly they are copyrighted by Commodore.  But we
;            could argue  that at least  PATCH1  belongs to the original source
;            which was "freed" by Microsoft (see the LICENSE on their github).
;            This is because  Microsoft's original source code has the  CLC  at
;            the place where it belongs.  Obviously it was forgotten in earlier
;            versions of Microsoft 6502 BASIC, and had to be added as PATCH1.
;            This gives us a clue how these  patches most likely came about and
;            why they are located after the end of the "official" source code.
; =============================================================================

PATCH1 CLC
        JMP STPEND

PATCH2 BIT FACLO
        BPL PATC21
        CMP #$54
        BNE PATC21
        JMP PATCO2
PATC21 RTS 

PATCH3 BIT FACLO
        BMI PATC31
        JMP GOMOVF
PATC31 CMP #$54
        BEQ PATC32
        JMP QSETATV
PATC32 JMP PATCO3

PATCH4 STA CHARAC
        INX 
        JMP PATC41

PATCH5 BPL PATC51
        LDA DATLIN
        LDY DATLIN+1
        RTS 
PATC51 LDY #$FF
        RTS 

PATCH6 BNE PATC62
PATC61 INC TRMPOS
        BNE PATC62
        LDA $E2
        STA TRMPOS
        BNE PATC61
PATC62 RTS 

PATC41 STX TXTPTR   ; looks like a patch of a patch (ouch !)
        PLA 
        PLA 
        TYA 
        JMP RESETC

PATCH7 EQU $E7F3    ; yet another patch but at an inconvenient location ...
      DO 0          ; ... so it's disabled from being assembled by this DO.
        * ORG PATCH7
        * ASL
        * ADC #$05
        * LDY #$00
        * RTS
      FIN

; =============================================================================
; ========================= end of file 'pet1.tail' ===========================
; =============================================================================
