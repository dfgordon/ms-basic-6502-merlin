         XC    OFF
         REL
         DSK   APPLE.EXT.L

* DFG - This is a Merlin linker module containing Apple II
* specific portions of Applesoft BASIC. It is linked with
* the main source file `MSB6502.S` which contains the
* baseline Microsoft code. This source is derived from
* "Uncle Bernie's Rendering" (UB) of Microsoft BASIC, which in
* turn is derived from other sources, see comments below.

* DFG - the following headers use fixed addresses, if the source
* code is altered, these can become invalid. The `microsoft.zp`
* header is necessary due to Merlin 32 issues, see comments therein.
         PUT   apple.ext.head ; from UB, which in turn, is from Davis
         PUT   apple.prim.head ; derived from MSB6502 symbol table

* DFG - This is defined separately in MSB6502, if it changes there
* it must be changed here too.
BUF      EQU   512

* DFG - The following are the symbols we would like to import, but
* instead are brought in through the `microsoft.zp` header file.
*  EXT   LINNUM,PRGEND,STREND,MEMSIZ,FRETOP,VARTAB
*  EXT   TXTPTR,CURLIN,LOWTR,FAC,DSCTMP,SUBFLG
 
* DFG - Tokens imported from MSB6502, except due to Merlin 32 issues
* we cannot import them. As a workaround we use hard coded equates.
*         EXT   ATTK,GOTOTK,TOTK
ATTK     EQU   197
GOTOTK   EQU   171
TOTK     EQU   193

* DFG - Imports from MSB6502
         EXT   STROUT,READY,FRMNUM,GETADR,GETBYT,SYNCHR
         EXT   CLEARC,REMN,ADDON,GOTO,NEWSTT
         EXT   FCERR,OMERR,SNERR,LINGET,FNDLIN,FINI
         EXT   PTRGET,VARTIO,GETAR2,CRDO

* DFG - Imports from F8 ROM
         EXT   INPORT,OUTPORT
         EXT   MON_PLOT,HLINE,VLINE
         EXT   COLSET,TABV,GRSET,TXTSET
         EXT   MON_WRITE,MON_READ,RD2BIT,MON_READ2

* DFG - Exports to MSB6502
         ENT   DEL,GR,TEXT,PR_NUMBER,IN_NUMBER
         ENT   CALL,BAS_PLOT,HLIN,VLIN,HGR2,HGR,HCOLOR
         ENT   HPLOT,DRAW,XDRAW,HTAB,ROT,SCALE,SHLOAD
         ENT   TRACE,NOTRACE,NORMAL,INVERSE,FLASH,COLOR
         ENT   VTAB,HIMEM,LOMEM,ONERR,RESUME,RECALL,STORE,SPEED
         ENT   ERRHND,PLOTFNS

* ========================== ***APPLESOFT*** =============================
*
* We need to add lot of the AppleSoft code to complete the ROMs
*
* All the following code is not part of the original Microsoft source code
* and was copied (almost) verbatim from the annotated  disassembly listing
* prepared by James P. Davis, his version which was used had the identifier
* "last updated 2020/04/21" which should help to avoid mixing things up.
*
* 'Uncle Bernie' made some cosmetic changes to James' code, to make it work
* with DASM, to fit Uncle Bernie's formatting way, and - most importantly -
* all labels referring  into the  original  Microsoft 6502 BASIC  code were
* changed to Microsoft's label names, which are the real deal.
*
* This code tail begins with line #9323 of James P. Davis' APPLE2.ROM.txt
* file and is a continuation of the previous code seen in the Microsoft
* 6502 BASIC source file 'm6502.asm' beginning at its line #6883:
*
*                                    Original Microsoft source file line#
* F1B8: A5 67    QROOM: LDWD  TXTTAB* PREPARE TO USE "REASON".  (6883)
* F1BA: A4 68
* F1BC: 20 E3 D3        JSR   REASON*                           (6884)
* F1BF: 20 4B D6        JSR   SCRTCH* SET UP EVERYTHING ELSE.   (6899)
*
* now starting with line #9323 of James P. Davis' APPLE2.ROM.txt: 

; ------------------------------------------------------------------------------
; Properly Reset GOWARM and GOSTROUT ("Wasting Prime Real Estate at 0-5!"):
; ------------------------------------------------------------------------------
; GOWARM   (LOC0, LOC1 & LOC2) is setup by COLD_START, but is not used anywhere
; GOSTROUT (LOC3, LOC4 & LOC5) is setup by COLD_START, but is not used anywhere
; ------------------------------------------------------------------------------
; Setup GOSTROUT to Print the String at [(A,Y)={Low,High}] when called:
                LDA   #<STROUT       ;Get String Out Routine Address, Low
                LDY   #>STROUT       ;Get String Out Routine Address, High
                STA   LOC4           ;Set GOSTROUT+1; =LOC3+1
                STY   LOC4+1         ;Set GOSTROUT+2; =LOC3+2; =LOC4+1; =LOC5
; Set GOWARM to BASIC Soft/Warm/Ctrl-C [& Mon Cmd: 0G] Entry Point
                LDA   #<READY        ;Get BASIC Warm Start Address, Low
                LDY   #>READY        ;Get BASIC Warm Start Address, High
                STA   LOC1           ;Set GOWARM+1; =LOC0+1
                STY   LOC1+1         ;Set GOWARM+2; =LOC0+2; =LOC1+1; =LOC2
                JMP   (LOC1)         ;DO WARM START
; 
; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
; ==============================================================================
; Applesoft - Part D, $F1D5-$F7FF: Graphics Display Routines, etc.
; ==============================================================================
; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
; 
; ==============================================================================
; "CALL" Statement: Immediate & Deferred; Parameter: CALL Aexpr;
; ==============================================================================
; Causes execution of a machine language subroutine at the memeory location
; whose decimal address is specified (Aexpr)
; ------------------------------------------------------------------------------
; Effectively: Performs a JSR to the specified address; Called routines can
; return with RTS; & Applesoft will continue with the next statement
; ------------------------------------------------------------------------------
; Note: Applesoft's CALL does not set up registers like Integer BASIC's does;
; On a CALL: Y = CALL Adrs, Low; A = CALL Adrs, High; & X = FAC Adrs ($9D)
; ==============================================================================
; 
CALL            JSR   FRMNUM         ;Evaluate & Assure Expression is Numeric
                JSR   GETADR         ;Convert FAC to a 16-bit Value in LINNUM
                JMP   (LINNUM)       ;Jump to 6502 Memory Address in Line Number

; ==============================================================================
; "IN#" Statement: Immediate & Deferred; Parameter: IN# Aexpr
; ==============================================================================
; Sets Vector to get Input from Slot Number (1~7) specified (Aexpr)
; ------------------------------------------------------------------------------
; Note: There's No Check for a Valid Slot Number; As long as the Value is < 256
; it is Accepted; But the Monitor Masks the Value to 4 Bits (0-15)
; ==============================================================================
; 
IN_NUMBER       JSR   GETBYT         ;Convert Expression to a Byte in X-Reg
                TXA                  ;Get Value of Expression (0~255)
;                                    ;Install in Character Input Hook
;                                    ;^[Vector at KSW ($38,$39)={Low,High}]:
                JMP   INPORT         ;Go Set Slot for Input (Monitor S/R)

; ==============================================================================
; "PR#" Statement: Immediate & Deferred; Parameter: PR# Aexpr;
; ==============================================================================
; Sets Vector to direct Output to Slot Number (1~7) specified (Aexpr)
; ------------------------------------------------------------------------------
; Note: There's No Check for a Valid Slot Number; As long as the Value is < 256
; it is Accepted; But the Monitor Masks the Value to 4 Bits (0-15)
; ==============================================================================
; 
PR_NUMBER       JSR   GETBYT         ;Convert Expression to a Byte in X-Reg
                TXA                  ;Get Value of Expression (0~255)
;                                    ;Install in Character Output Hook
;                                    ;^[Vector at CSW ($36,$37)={Low,High}]:
                JMP   OUTPORT        ;Go Set Slot for Output (Monitor S/R)

; 
; ==============================================================================
; Low Resolution (Lo-Res) Graphics Subroutines
; ==============================================================================
; Lo-Res Screen SIZE is 48 or 80 by 48:
;  48 Hard-Coded below, in Apple II Plus machines;
;  48 for <  Apple IIc, in machines without 80-Column Capability;
;  80 for >= Apple IIc, but coding it created a Dangerous BUG in those machines!
;  [Enhanced Apple IIe is THE BEST Apple II machine! -- JPD]
; ==============================================================================
; 
; 
; ==============================================================================
; Cartesian Coordinator: Subroutine to Get Cartesian ("#,#") Coordinates
; ==============================================================================
; Gets Two Values < 48, with Comma Separator
; ------------------------------------------------------------------------------
; Called for PLOT X,Y; HLIN A,B at Y; & VLIN A,B at X
; ==============================================================================
; 
; -----------------------------------;Get 1st Coordinate:
PLOTFNS         JSR   GETBYT         ;Convert Expression to a Byte in X-Reg
                CPX   #SCRSIZE       ;Assure (X)<(Max Size of Lo-Res Screen)
                BCS   BAS_GOERR      ;BGE: IQ ERROR if it is Not < SIZE
                STX   FIRST          ;Save 1st Lo-Res Plot Coordinate
                LDA   #44            ;Must have a Comma next
                JSR   SYNCHR         ;If = Chr Got, Get Next; Else, Syntax Error
; -----------------------------------;Get 2nd Coordinate:
                JSR   GETBYT         ;Convert Expression to a Byte in X-Reg
                CPX   #SCRSIZE       ;Assure (X)<(Max Size of Lo-Res Screen)
                BCS   BAS_GOERR      ;BGE: IQ ERROR if it is Not < SIZE
                STX   H2             ;Set Right End of Horizontal Line (HLINE)
                STX   V2             ;Set Bottom End of Vertical Line (VLINE)
                RTS                  ;Return [(FIRST),(X=H2=V2)] to Caller

BAS_GOERR       JMP   FCERR          ;Go Print "?Illegal Quantity" Error Message

; ==============================================================================
; Line Coordinator: Subroutine to Get Lo-Res Line ("#,# at #") Coordinates
; ==============================================================================
; Gets "A,B at C" Values < 48, with Comma & "at" Separators, for HLIN and VLIN;
; Puts Smaller of (A,B) in FIRST, and Larger of (A,B) in H2 & V2;
; Returns X-Reg = (C) Value
; ------------------------------------------------------------------------------
; Called for HLIN A,B at Y; & VLIN A,B at X
; ==============================================================================
; 
LINCOOR         JSR   PLOTFNS        ;Get Cartesian ("A,B") Coordinates
                CPX   FIRST          ;Is B < A?  [Plot Coordinates (PC)]
                BCS   LINAT          ;BGE: Branch if B >= A
;                                    ;Else, B < A; Swap (A,B) -> (B,A):
                LDA   FIRST          ;Get B, 2nd Lo-Res PC, & Smaller of (A,B)
                STA   H2             ;Set Right End of Horizontal Line (HLINE)
                STA   V2             ;Set Bottom End of Vertical Line (VLINE)
                STX   FIRST          ;Save X as 1st Lo-Res Plot Coordinate
;                                    ;Was (A,B) -> Now (B,A)
LINAT           LDA   #ATTK          ;Get "AT" Token
                JSR   SYNCHR         ;If = Chr Got, Get Next; Else, Syntax Error
                JSR   GETBYT         ;Convert Next Expression to a Byte in X-Reg
                CPX   #SCRSIZE       ;Assure (X)<(Max Size of Lo-Res Screen)
                BCS   BAS_GOERR      ;BGE: IQ ERROR if it is Not < SIZE
                RTS                  ;Return to Caller

; ==============================================================================
; "PLOT" Statement: Immediate & Deferred; Parameters: PLOT Aexpr1, Aexpr2
; ==============================================================================
; Plots a Point of current COLOR at [(X,Y)={Aexpr1,Aexpr2}] on the Lo-Res Screen
; ==============================================================================
; 
BAS_PLOT        JSR   PLOTFNS        ;Get Cartesian ("X,Y") Coordinates
                TXA                  ;Get 2nd (Y) Coordinate
                LDY   FIRST          ;Get 1st (X) Coordinate
                CPY   #40            ;Is  1st (X) Coordinate < 40?
                BCS   BAS_GOERR      ;BGE: IQ ERROR if 1st (X) Coordinate >= 40
                JMP   MON_PLOT       ;Go Let Monitor Plot Point on Lo-Res Screen

; ==============================================================================
; "HLIN" Statement: Immediate & Deferred; Parms: HLIN Aexpr1, Aexpr2 AT Aexpr3
; ==============================================================================
; Draws a Horizontal Line of current COLOR on the Lo-Res Screen
; from [(X,Y)=(Aexpr1,Aexpr3)] to [(X,Y)=(Aexpr2,Aexpr3)]
; ==============================================================================
HLIN            JSR   LINCOOR        ;Get Lo-Res Line ("A,B at Y") Coordinates
                TXA                  ;Get 3rd (Y) Horizontal Line Coordinate
                LDY   H2             ;Get Right End (B) of Horizontal Line
                CPY   #40            ;Is  Right End (B) of Horizontal Line < 40?
                BCS   BAS_GOERR      ;BGE: IQ ERROR if Right End of Line >= 40
                LDY   FIRST          ;Get Left End (A) of Horizontal Line
                JMP   HLINE          ;Go Let Monitor Draw Line on Lo-Res Screen

; ==============================================================================
; "VLIN" Statement: Immediate & Deferred; Parms: VLIN Aexpr1, Aexpr2 AT Aexpr3
; ==============================================================================
; Draws a Vertical Line of current COLOR on the Lo-Res Screen
; from [(X,Y)=(Aexpr1,Aexpr3)] to [(X,Y)=(Aexpr2,Aexpr3)]
; ==============================================================================
; 
VLIN            JSR   LINCOOR        ;Get Lo-Res Line ("A,B at X") Coordinates
                TXA                  ;Get 3rd (X) Vertical Column Coordinate
                TAY                  ;Get Bottom End (B) of Vertical Line
                CPY   #40            ;Is  Bottom End (B) of Vertical Line < 40?
                BCS   BAS_GOERR      ;BGE: IQ ERROR if Bottom End of Line >= 40
                LDA   FIRST          ;Get Top End (A) of Vertical Line
                JMP   VLINE          ;Go Let Monitor Draw Line on Lo-Res Screen

; ==============================================================================
; "COLOR=" Statement: Immediate & Deferred; Parameter: COLOR = Aexpr1
; ==============================================================================
; Set the Color for Lo-Res Plotting of Points (Dots) & Lines
; ==============================================================================
; 
COLOR           JSR   GETBYT         ;Convert Expression to a Byte in X-Reg
                TXA                  ;Get Color for Lo-Res (Dot/Line) Plotting
                JMP  COLSET         ;Go Let Monitor Set Color for Lo-Res Plots

; 
; ==============================================================================
; Non-Graphics Subroutines
; ==============================================================================
; 
; ==============================================================================
; "VTAB" Statement: Immediate & Deferred; Parameter: VTAB Aexpr1
; ==============================================================================
; Moves the Cursor to the Line (1~24) that is Aexpr1 Lines down the screen
; ==============================================================================
; 
VTAB            JSR   GETBYT         ;Convert Expression to a Byte in X-Reg
                DEX                  ;Reduce Line Number [from (1~24) to (0~23)]
                TXA                  ;Get Line Number to Check Range
                CMP   #24            ;Is Line Number < 24?
                BCS   BAS_GOERR      ;BGE: IQ ERROR if Line Number >= 24
                JMP   TABV           ;Go Let Monitor Set Vertical Cursor Position

; ==============================================================================
; "SPEED=" Statement: Immediate & Deferred; Parameter: SPEED = Aexpr1
; ==============================================================================
; Sets the Speed at which Characters are to be sent to the Screen or to other
; Input/Output Devices
; ==============================================================================
; 
SPEED           JSR   GETBYT         ;Convert Expression to a Byte in X-Reg
                TXA                  ;Get Input/Output Speed Specified (0~255)
                EOR   #%11111111     ;Invert Bits (Negate)            -(0~255)
                TAX                  ;Get Negated I/O Speed           (-255~0)
                INX                  ;Advance I/O Speed   [1+(-255~0)=(-254~1)]
                STX   SPDBYT         ;=$100-Speed+1, So SPEED=255 is Fastest[?]
                RTS                  ;Return to Caller

; ==============================================================================
; "TRACE" Statement: Immediate & Deferred; No Parameters; Enables DeBug Mode
; ==============================================================================
; 
TRACE           SEC                  ;To Set Sign Bit in TRCFLG (Trace OFF/ON)
                DFB $90            ;Never Taken; Fake BCC to skip next OpCode

; ==============================================================================
; "NOTRACE" Statement: Immediate & Deferred; No Parameters; Disables DeBug Mode
; ==============================================================================
; 
NOTRACE         CLC                  ;To Clear Sign Bit in TRCFLG
;                                    ;Trace OFF/ON Flag (<128/>127)~(bit-7)
                ROR   TRCFLG         ;Shift CARRY into TRCFLG
                RTS                  ;Return to Caller

; ==============================================================================
; "NORMAL" Statement: Immediate & Deferred; No Parameters
; ==============================================================================
; Sets Normal Video Input/Output Mode: White Letters on Black Background
; ==============================================================================
; 
NORMAL          LDA   #$FF           ;For INVFLG Text Mask
;                                    ;(Normal=$FF, Flash=$7F, Inverse=$3F)
                BNE   NRMINV         ;Always Taken

; ==============================================================================
; "INVERSE" Statement: Immediate & Deferred; No Parameters
; ==============================================================================
; Sets Inverse Video Input/Output Mode: Black Letters on White Background
; ==============================================================================
; 
INVERSE         LDA   #$3F           ;For INVFLG Text Mask
NRMINV          LDX   #$00           ;For FLASHBIT Text Mask
NRMINVFLSH      STA   INVFLG         ;Text Mask (Normal=$FF, Flash=$7F, Inverse=$3F)
                STX   FLASHBIT       ;Text Mask (Flash=$40, Lowercase=$20, Else=$00)
                RTS                  ;Return to Caller

; ==============================================================================
; "FLASH" Statement: Immediate & Deferred; No Parameters
; ==============================================================================
; Sets Flashing Video Input/Output Mode: Alternating Normal (White Letters on
; Black Background) with Inverse (Black Letters on White Background) Modes
; [about two times per second] 
; ==============================================================================
; 
FLASH           LDA   #$7F           ;For INVFLG Text Mask
;                                    ;(Normal=$FF, Flash=$7F, Inverse=$3F)
                LDX   #$40           ;For FLASHBIT Text Mask
;                                    ;(Flash=$40, Lowercase=$20, Else=$00)
                BNE   NRMINVFLSH     ;Always Taken

; ==============================================================================
; "HIMEM:" Statement: Immediate & Deferred; Parameter: HIMEM: Aexpr1
; ==============================================================================
; Sets Highest Memory Address Available to a BASIC Program, including Variables,
; to Protect Memory above IT for Data, Graphics, or Machine Language Routines;
; Automatically Set during Cold Start to Maximum RAM Memory Address in System;
; Reset by RESET CTRL-B RETURN, which also Erases Any Stored Program; Not Reset
; by CLEAR, RUN, NEW, DEL, Changing or Adding a Program Line, or RESET alone;
; Resets String Variable Pointers to Zero Difference, which is effectively the
; same as Clearing String Variables!
; ==============================================================================
; 
HIMEM           JSR   FRMNUM         ;Get Value Specified as 16-Bit Integer
                JSR   GETADR         ;Convert FAC to a 16-bit Value in LINNUM
; -----------------------------------;Is HIMEM above Variables & Arrays?
                LDA   LINNUM         ;Get HIMEM Value Specified, Low
                CMP   STREND         ;Subtract Start of Free Space, Low
                LDA   LINNUM+1       ;Get HIMEM Value Specified, High
                SBC   STREND+1       ;Subtract Start of Free Space, High
                BCS   HISET          ;BGE: Branch if HIMEM is above them
JMM             JMP   OMERR          ;ERROR if NOT, Do "?Out Of Memory" Error

; -----------------------------------;Store New HIMEM Value:
HISET           LDA   LINNUM         ;Get HIMEM Value Specified, Low
                STA   MEMSIZ         ;Set Top End of String Space (HIMEM), Low
                STA   FRETOP         ;Set Bottom End of String Space, Low
;                                    ;^(AKA: Top of Free Space, Low)
                LDA   LINNUM+1       ;Get HIMEM Value Specified, High
                STA   MEMSIZ+1       ;Set Top End of String Space (HIMEM), High
                STA   FRETOP+1       ;Set Bottom End of String Space, High
;                                    ;^(AKA: Top of Free Space, High)
;                                    ;That Resets String-Storage (FRETOP=HIMEM)
                RTS                  ;Return to Caller

; ==============================================================================
; <<< HIMEM: Does Not Clear String Variables, which could be Disastrous! >>>
; ------------------------------------------------------------------------------
; But, it does Reset String Variable Pointers to Zero Difference, which is
; effectively the same as Clearing String Variables!
; ==============================================================================
; 
; 
; ==============================================================================
; "LOMEM:" Statement: Immediate & Deferred; Parameter: LOMEM: Aexpr1
; ==============================================================================
; Sets Lowest Memory Address Available to a BASIC Program; Automatically Set to
; End of Program, Start of Simple BASIC Variables, before Program Execution;
; Reset by NEW, DEL, & by Adding or Changing a Program Line; Reset by RESET
; CTRL-B, which also Deletes any Stored Program; Not Reset by RUN, RESET CTRL-C
; RETURN, or RESET 0G RETURN; Can Protect Variables from High-Resolution
; Graphics
; ==============================================================================
; 
LOMEM           JSR   FRMNUM         ;Get Value Specified as 16-Bit Integer
                JSR   GETADR         ;Convert FAC to a 16-bit Value in LINNUM
; -----------------------------------;Is LOMEM below HIMEM?
                LDA   LINNUM         ;Get LOMEM Value Specified, Low
                CMP   MEMSIZ         ;Subtract Top of String Space (HIMEM), Low
                LDA   LINNUM+1       ;Get LOMEM Value Specified, High
                SBC   MEMSIZ+1       ;Subtract Top of String Space (HIMEM), High
                BCS   JMM            ;BGE: Do "?Out Of Memory" ERROR if NOT
; -----------------------------------;Is LOMEM above End of Program (EOP)?
                LDA   LINNUM         ;Get LOMEM Value Specified, Low
                CMP   VARTAB         ;Subtract Start of Variables (EOP+1), Low
                LDA   LINNUM+1       ;Get LOMEM Value Specified, High
                SBC   VARTAB+1       ;Subtract Start of Variables (EOP+1), High
                BCC   JMM            ;BLT: Do "?Out Of Memory" ERROR if NOT
; -----------------------------------;Store New LOMEM Value:
                LDA   LINNUM         ;Get LOMEM Value Specified, Low
                STA   VARTAB         ;Set Start of Variables (EOP+1), Low
                LDA   LINNUM+1       ;Get LOMEM Value Specified, High
                STA   VARTAB+1       ;Set Start of Variables (EOP+1), High
                JMP   CLEARC         ;Go Clear Variables & Arrays

; ==============================================================================
; "ONERR GOTO" Statements: Deferred Only; Parameter: ONERR GOTO LineNumber
; ==============================================================================
; Prevents having an Error Message Printed & Execution Halted when an Error
; Occurs during Program Execution; ONERR GOTO must be Executed before the
; occurance of an Error to avoid Program Interruption; Sets a Flag that causes
; an Unconditional Jump to LineNumber (if an Error Occurs during Program
; Execution); POKE 216, 0 (*$D8:0) Resets the Error-Detection Flag so that
; Normal Error Messages will be Printed.
; ==============================================================================
; 
ONERR           LDA   #GOTOTK        ;Get GOTO Token
                JSR   SYNCHR         ;If = Chr Got, Get Next; Else, Syntax Error
; -----------------------------------;Save TXTPTR for ERRHND:
                LDA   TXTPTR         ;Get Next Char/Token Pointer, Low
                STA   TXTPSV         ;Set Char/Token Pointer Safe, Low
                LDA   TXTPTR+1       ;Get Next Char/Token Pointer, High
                STA   TXTPSV+1       ;Set Char/Token Pointer Safe, High
                SEC                  ;Set Sign Bit of ERRFLG
                ROR   ERRFLG         ;Activate ONERR GOTO (ERRFLG=#$80)
; -----------------------------------;Save Current Line Number:
                LDA   CURLIN         ;Get Current Line Number, Low
                STA   CURLSV         ;Set Current Line Safe, Low
                LDA   CURLIN+1       ;Get Current Line Number, High
                STA   CURLSV+1       ;Set Current Line Safe, High
; -----------------------------------;Ignore Rest of Line:     <<< Why? >>>
;                                    ;[Anything after ONERR GOTO LineNumber
;                                    ; is treated like a REM & Ignored !!!]
                JSR   REMN           ;Set (Y)=(Offset to Next ":" or EOL)
;              ----------------------;Advance TXTPTR by adding (Y):
                JMP   ADDON          ;Continue Program at Next Line

; ==============================================================================
; Error Handler (Part 2): Routine to Handle errors if ONERR GOTO is Active
; ==============================================================================
; 
ERRHND          STX   ERRNUM         ;Set Current Error Number Safe
; -----------------------------------;Get & Save Stack Pointer Saved at NEWSTT:
                LDX   REMSTK         ;Get Stack Ptr Saved Before Each Statement
                STX   ERRSTK         ;Set Stack Pointer Before Error Safe
; <<< Could also have done TXS here; See ONERR Correction in Applesoft Manual >>
; -----------------------------------;Save Line Number of Offending Statement:
                LDA   CURLIN         ;Get Current Line Number, Low
                STA   ERRLIN         ;Set Line Number Where ERROR Occurred, Low
                LDA   CURLIN+1       ;Get Current Line Number, High
                STA   ERRLIN+1       ;Set Line Number Where ERROR Occurred, High
; -----------------------------------;Get Position in Line to RESUME:
                LDA   OLDTEXT        ;Get Old Text Pointer, Low
                STA   ERRPOS         ;Set Error Handler TXTPTR Safe, Low
                LDA   OLDTEXT+1      ;Get Old Text Pointer, High
                STA   ERRPOS+1       ;Set Error Handler TXTPTR Safe, High
; -----------------------------------;Setup for "ON ERR GO TO <Line #>" Msg:
                LDA   TXTPSV         ;Get Char/Token Pointer Safe, Low
                STA   TXTPTR         ;Set Next Char/Token Pointer, Low
                LDA   TXTPSV+1       ;Get Char/Token Pointer Safe, High
                STA   TXTPTR+1       ;Set Next Char/Token Pointer, High
; -----------------------------------;Save Line Number of "ON ERR" Statement:
                LDA   CURLSV         ;Get Current Line Safe, Low
                STA   CURLIN         ;Set Current Line Number, Low
                LDA   CURLSV+1       ;Get Current Line Safe, High
                STA   CURLIN+1       ;Set Current Line Number, High
; -----------------------------------;Start Conversion:
                JSR   CHRGOT         ;Get Char/Token Got w/o advancing TXTPTR
                JSR   GOTO           ;Goto Specified ONERR GOTO Line Number
                JMP   NEWSTT         ;Execute a New Statement

; ==============================================================================
; "RESUME" Statement: Deferred; No Parameters
; ==============================================================================
; RESUMEs Program Execution at Beginning of Statement where ERROR occurred when
; used after Error Handling; Dangerous if used in Immediate Mode
; ==============================================================================
; 
; -----------------------------------;Restore Line Number:
RESUME          LDA   ERRLIN         ;Get Line Number Where ERROR Occurred, Low
                STA   CURLIN         ;Set Current Line Number, Low
                LDA   ERRLIN+1       ;Get Line Number Where ERROR Occurred, High
                STA   CURLIN+1       ;Set Current Line Number, High
; -----------------------------------;Restore Next Char/Token Pointer:
                LDA   ERRPOS         ;Get Error Handler TXTPTR Safe, Low
                STA   TXTPTR         ;Set Next Char/Token Pointer, Low
                LDA   ERRPOS+1       ;Get Error Handler TXTPTR Safe, High
                STA   TXTPTR+1       ;Set Next Char/Token Pointer, High
; -----------------------------------;Restore Stack Pointer:
                LDX   ERRSTK         ;Get Stack Pointer Before Error Safe
                TXS                  ;Set Stack Pointer
; -----------------------------------;Re-try Offending Line:
                JMP   NEWSTT         ;Execute Offending Statement, Again

; ==============================================================================
; "DEL" Statement: Immediate & Deferred; Parameters: DEL LineNuml , LineNum2
; ==============================================================================
; Deletes a Range of Lines from LineNuml to LineNum2, inclusively; Respectively,
; if LineNuml/LineNum2 is NOT an Existing Program Line Number, the Next Larger/-
; /Smaller Line Number in the Program is used in lieu of LineNuml/LineNum2
; ==============================================================================
; 
JSYN            JMP   SNERR          ; Relay Point to Throw a "?Syntax" Error

; ==============================================================================
; "DEL" Statement - Main Entry Point:
; ==============================================================================
; 
DEL             BCS   JSYN           ;BGE: ERROR If Line Number NOT Specified
; -----------------------------------;Synchronize LOMEM Pointers:
                LDX   PRGEND         ;Get End of Program Pointer, Low
                STX   VARTAB         ;Set Start of Variables Pointer, Low
                LDX   PRGEND+1       ;Get End of Program Pointer, High
                STX   VARTAB+1       ;Set Start of Variables Pointer, High
; -----------------------------------;Is Range START Line Number in Program?
                JSR   LINGET         ;Get Range START Line Number (LINNUM)
;                                    ;^[Rtns 0 if Line Number is NOT Specified]
                JSR   FNDLIN         ;Find, Convert, & Point LOWTR at Line/Next
                LDA   LOWTR          ;Get Address of Line or Next Line, Low
                STA   DSTPTR         ;Set Move Destination Pointer, Low
                LDA   LOWTR+1        ;Get Address of Line or Next Line, High
                STA   DSTPTR+1       ;Set Move Destination Pointer, High
; ---------------------------------->;Upper Program will move down to (DSTPTR)
                LDA   #44            ;Require a Comma Separator Character next: 
                JSR   SYNCHR         ;If = Chr Got, Get Next; Else, Syntax Error
; -----------------------------------;Is Range END Line Number in Program?
                JSR   LINGET         ;Get Range END Line Number (LINNUM)
;                                    ;^[Rtns 0 if Line Number is NOT Specified]
; -----------------------------------;Point 1 Line Past Range END Line Number:
                INC   LINNUM         ;Advance Range END Line Number, Low
                BNE   DELSKIP1       ;Branch if No Page Carryover
                INC   LINNUM+1       ;Advance Range END Line Number, High
; -----------------------------------;Is Range Valid (START < END):
DELSKIP1        JSR   FNDLIN         ;Find, Convert, & Point LOWTR at Line/Next
                LDA   LOWTR          ;Get Address of Line or Next Line, Low
                CMP   DSTPTR         ;Subtract Move Destination Pointer, Low
                LDA   LOWTR+1        ;Get Address of Line or Next Line, High
                SBC   DSTPTR+1       ;Subtract Move Destination Pointer, High
                BCS   DELMVDWN       ;BGE: Branch if Range Valid (START < END)
                RTS                  ;Else, Nothing to Delete; Return to Caller

; ------------------------------------------------------------------------------
; Delete Specified Section:
; Move Upper Program Section Down [(LOWTR~VARTAB) to (DSTPTR)] 
; ------------------------------------------------------------------------------
; 
DELMVDWN        LDY   #0             ;Clear Indirect Addressing Index
; -----------------------------------;Move a Byte (Delete Loop):
DELMVLOOP       LDA   (LOWTR),Y      ;Get a Byte from (Source Address),Y
                STA   (DSTPTR),Y     ;Copy Byte to (Destination Address),Y
; -----------------------------------;Advance to Next Source Address:
                INC   LOWTR          ;Advance Source Address, Low
                BNE   DELMVSKP1      ;Branch if No Page Boundary Reached
                INC   LOWTR+1        ;Advance Source Address, High
; -----------------------------------;Advance to Next Destination Address:
DELMVSKP1       INC   DSTPTR         ;Advance Destination Address, Low
                BNE   DELMVSKP2      ;Branch if No Page Boundary Reached
                INC   DSTPTR+1       ;Advance Destination Address, High
; -----------------------------------;Move Next Byte? Or Finish Up?
DELMVSKP2       LDA   VARTAB         ;Get Start of Variables Ptr (EOP+1), Low
                CMP   LOWTR          ;Subtract Source Address, Low
                LDA   VARTAB+1       ;Get Start of Variables Ptr (EOP+1), High
                SBC   LOWTR+1        ;Subtract Source Address, High
                BCS   DELMVLOOP      ;BGE: LOOP if Not Done Moving Bytes
;                                    ;^[Done when LOWTR move-up reaches VARTAB]
;                                    ;^[Variables will be Cleared, Not Moved!]
; -----------------------------------;Else, Finish Up; Reverse Last Advance:
;                                    ;Point End of Program (EOP) to Last Byte 
;                                    ;Moved [(Destination Address)-1]:
                LDX   DSTPTR+1       ;Get Destination Address, High
                LDY   DSTPTR         ;Get Destination Address, Low
                BNE   DELMVSKP3      ;Branch if No Page Boundary Reached
                DEX                  ;Reduce Destination Address, High
DELMVSKP3       DEY                  ;Reduce Destination Address, Low
; <<< Seems like there is a one byte overlap here now that would wipe out the
; last byte of an Applesoft BASIC program!  Should this last reduction really
; have been done? -- JPD >>>
; -----------------------------------;Reset Start of Variables Pointer (LOMEM):
                STX   VARTAB+1       ;Set Start of Variables Ptr (EOP+1), High
                STY   VARTAB         ;Set Start of Variables Ptr (EOP+1), Low
                JMP   FINI       ;Go Clear Vars, Fix Fwd Links, Restart Warm

; ==============================================================================
; "GR" Statement: Immediate & Deferred; No Parameters
; ==============================================================================
; Sets Low-Resolution GRaphics Mode (40 by 40) for Screen, leaving Four Lines
; for Text at Bottom; Screen is Cleared to Black, & Cursor is Moved to Text
; Window; Can be Converted to Full-Screen (40 by 48) Graphics, after executing
; GR, with command POKE -16302,0 or equivalent command POKE 49234,0; If GR
; follows a Full-Screen POKE command, Mixed Graphics-Plus-Text Mode is Reset;
; After a GR command, COLOR has been set to Zero
; ==============================================================================
; 
GR              LDA   LORES          ;Reset HiRes Mode to LoRes/Text Mode
                LDA   MIXON          ;Set Mixed Graphics & Text Mode
                JMP   GRSET          ;Go Set Screen to Graphics Mode

; ==============================================================================
; "TEXT" Statement: Immediate & Deferred; No Parameters
; ==============================================================================
; Sets Screen to Full-Screen Text Mode (40 characters per line, 24 lines) from
; Low-Resolution Graphics Mode or either of two High-Resolution Graphics Modes;
; Prompt & Cursor are moved to last line of Screen; Same as VTAB 24 in Text Mode
; ==============================================================================
; 
;              JMP    TEXT02         ;(=$FB36) Would've done both these things:
TEXT            LDA   TXTPAGE1       ;Display Text Page1; R/W Main V-RAM
                JMP   TXTSET         ;Go Set Screen to Text Mode

; <<<                                ;Better code would be:
; TEXT         LDA     MIXON        ;Set Mixed Graphics & Text Mode
;              JMP     TEXT01        ;(=$FB33) Reset HiRes to LoRes/Text Mode
;                                    ;                              -- BS-C >>>
; ==============================================================================
; 
; 
; ==============================================================================
; Tape Array STORE & RECALL Routines: 
; ==============================================================================
;    (There are No Corresponding Routines for Diskette Storage in Applesoft)
; ==============================================================================
; STORE & RECALL Arrays via Cassette Tape (using Apple II Audio Input/Output)
; System; [Did anybody ever use these?]; Array Names are Not Stored with their
; Values, So an Array may be Recalled using a Different Name than that used when
; Stored; Dimensions of arrays recalled should be identical to Dimensions of
; Original Arrays Stored; Failure to observe this will result in Scrambled
; Numbers, Extra Zeros, or ?Out of Memory Erors, in Recalled Arrays
; ==============================================================================
; 
; ==============================================================================
; "STORE" Statement: Immediate & Deferred; Parameter: STORE Avar
; ==============================================================================
; 
; -----------------------------------;Prepare to Read/Write a 3-Byte Header 
;                                    ;from/to a Cassette Tape (Audio I/O):
STORE           JSR   GETARYPTR      ;If Found, Point LOWTR at Array Specified
; -----------------------------------;Compute [(Array Size)=(Fwd Offset)-1]:
                LDY   #3             ;Point to Forward Offset Pointer, High
;                                    ;^[Data within Array Variable Pointer]
                LDA   (LOWTR),Y      ;Get Forward Offset, High
                TAX                  ;Save Forward Offset, High
                DEY                  ;Point to Forward Offset Pointer, Low
;                                    ;^[Data within Array Variable Pointer]
                LDA   (LOWTR),Y      ;Get Forward Offset, Low
                SBC   #1             ;Reduce Forward Offset, Low
;                                    ;^[C=0: Subtract with Borrow (A-Data-!C)]
;                                    ;^[C=1: Subtract w/o  Borrow (A-Data-!C)]
                BCS   STORESKP1      ;BGE: Branch if Borrowed [(A)>=(Data)]
                DEX                  ;Else, LT: Reduce Forward Offset, High
STORESKP1       STA   LINNUM         ;Save Array Size, Low
                STX   LINNUM+1       ;Save Array Size, High
; -----------------------------------;STORE Array on Tape:
                JSR   MON_WRITE      ;Write 3-Byte Header (Length & Lock Byte)
                JSR   TAPEPTR        ;Point at 1st Value in Array
                JMP   MON_WRITE      ;Go Write Array Data to Tape

; ==============================================================================
; "RECALL" Statement: Immediate & Deferred; Parameter: RECALL Avar
; ==============================================================================
; 
; -----------------------------------;Prepare to Read/Write a 3-Byte Header 
;                                    ;from/to a Cassette Tape (Audio I/O):
RECALL          JSR   GETARYPTR      ;If Found, Point LOWTR at Array Specified
; -----------------------------------;RECALL 3-Byte Header from Tape:
                JSR   MON_READ       ;Read 3-Byte Header (Length & Lock Byte)
; -----------------------------------;Compute [(Fwd Offset)-(Tape Array Size)]:
                LDY   #2             ;Point to Forward Offset Pointer, Low
;                                    ;^[Data within Array Variable Pointer]
                LDA   (LOWTR),Y      ;Get Forward Offset, Low
                CMP   LINNUM         ;Subtract Tape Array Size, Low (A-Data):NZC
;                                    ;^[Carry gets Set when [(A)>=(Data)]]
                INY                  ;Point to Forward Offset Pointer, High
                LDA   (LOWTR),Y      ;Get Forward Offset, High
                SBC   LINNUM+1       ;Subtract Tape Array Size, High
;                                    ;^[C=0: Subtract with Borrow (A-Data-!C)]
;                                    ;^[C=1: Subtract w/o  Borrow (A-Data-!C)]
;                                    ;Now've Adrs where Tape Array would Start
;                                    ;^[OK if >, but sh'd be = Spec'd Start+1]
                BCS   RECALLDATA     ;BGE: Branch if Borrowed [(A)>=(Data)]
                JMP   OMERR          ;Else, LT: Throw an "?Out Of Memory" Error

; -----------------------------------;RECALL Array Data from Tape:
RECALLDATA      JSR   TAPEPTR        ;Point at 1st Value in Array
                JMP   MON_READ       ;Go Read Array Data from Tape

; ==============================================================================
; High-Resolution Graphics Mode (Hi-Res) Initialization Routines:
; ==============================================================================
; 
; ==============================================================================
; "HGR2" Statement: Immediate & Deferred; No Parameters; Init & Clear HIRES Pg.2
; ==============================================================================
; Sets Full-Screen High-Resolution Graphics Mode (280 by 192), Displaying Screen
; Page 2 of Memory (16K-24K), Cleared to Black
; ==============================================================================
; 
HGR2            BIT   TXTPAGE2       ;Display Text Page 2
;                                    ;Default to:
                BIT   MIXOFF         ;Set Full Screen Graphics & Text Mode
                LDA   #>HGR2SCRN     ;Get Hi-Res Screen Pg.2 Base-Address, High
                BNE  HPGSET         ;Go Set Hi-Res Graphics Mode; Always Taken

; ==============================================================================
; "HGR" Statement: Immediate & Deferred; No Parameters; Init & Clear HIRES Pg.1
; ==============================================================================
; Sets Mixed-Screen High-Resolution Graphics Mode (280 by 160), Displaying
; Screen Page 1 of Memory (8K-16K), Cleared to Black, Leaving 4 Lines of Text
; Visible at Bottom of Screen, & 20 Lines of Text Invisible at Top of Screen,
; Overlayed with Graphics but Still Functional Underneath, with Cursor
; Unrestricted but Only Visible at Bottom of Screen
; ==============================================================================
; 
HGR             LDA   #>HGR1SCRN     ;Get Hi-Res Screen Pg.1 Base-Address, High
                BIT   TXTPAGE1       ;Display Text Page1; R/W Main V-RAM
;                                    ;Default to:
                BIT   MIXON         ;Set Mixed Graphics & Text Mode
; 
; ==============================================================================
; Common High-Resolution Graphics Mode (Hi-Res) Initialization Routine:
; ==============================================================================
; 
HPGSET          STA   HGRPAGE        ;Set Hi-Res Base Page (HPg1=$20, HPg2=$40)
                LDA   HIRES          ;Reset Lo-Res/Text Mode to Hi-Res Mode
                LDA   TXTOFF         ;Set Graphics Display Mode
; -----------------------------------;Setup to Initialize Hi-Res Screen Memory:
HCLR            LDA   #0             ;Clear Accumulator
                STA   HCOLOR1        ;Clear Hi-Res Color Mask (Black Background)
                LDA   HGRPAGE        ;Get Hi-Res Base Page (HPg1=$20, HPg2=$40)
                STA   HSHAPE+1       ;Clear Hi-Res Screen Byte Pointer, High
                LDY   #0             ;Clear Indirect Addressing Index
                STY   HSHAPE         ;Clear Hi-Res Screen Byte Pointer, Low
; -----------------------------------;Initialize Loop; Color Hi-Res Background:
BGLOOP          LDA   HCOLOR1        ;Get Hi-Res Color Mask
                STA   (HSHAPE),Y     ;Clear Hi-Res Screen to Mask Color
                JSR   COLORSHIFT     ;Correct for Color Shift
;                                    ;(Slows Clear by Factor of 2)
                INY                  ;Advance Indirect Addressing Index
                BNE   BGLOOP         ;LOOP if Not at Page Boundary
                INC   HSHAPE+1       ;Advance Hi-Res Screen Byte Pointer, High
                LDA   HSHAPE+1       ;Get Hi-Res Screen Byte Pointer, High
                AND   #%00011111     ;Done? <-[Done at Hi-Res Page End +1, High:
;                                    ;Pg1:$40=(%01000000); Pg2:$60=(%01100000)
                BNE   BGLOOP         ;LOOP if Not Done
                RTS                  ;Else, Return to Caller

; ==============================================================================
; High-Resolution Graphics Mode (Hi-Res) Position And Plot Subroutines:
; ==============================================================================
; 
; ==============================================================================
; Set Hi-Res Cursor Position Subroutine:              [Called by HPLOT0 & SCALE]
; ==============================================================================
; Enter with: [(X,Y)={Low,High}] = Horizontal (Cartesian) X-Coordinate (0-279)
;                  (Accumulator) =   Vertical (Cartesian) Y-Coordinate (0-191)
; ------------------------------------------------------------------------------
; Note: X-Coordinate = X-Position = Column; Y-Coordinate = Y-Position = Row
; ==============================================================================
; 
; -----------------------------------;Save Spec'd Cartesian (X,Y) Coordinates:
HPOSN           STA   HGRY           ;Save  Vertical  Y-Position
                STX   HGRX           ;Save Horizontal X-Position, Low
                STY   HGRX+1         ;Save Horizontal X-Position, High
; -----------------------------------;Compute Base Address for Y-Position 
;                                    ;^[to access Screen Memory via (GBASL),Y]:
                PHA                  ;*** BITS IN: A|Y=ABCDEFGH; Push Y-Position
                AND   #%11000000     ;Retain A|Y=AB000000, Negative & Overflow Bits
                STA   GBASL          ;Set Graphics Base Address, Low
                LSR              ;Shift Right: A|Y=0AB00000
                LSR              ;Shift Right: A|Y=00AB0000
                ORA   GBASL          ;*** BITS OUT: GBASL=ABAB0000
                STA   GBASL          ;Set Graphics Base Address, Low
; -----------------------------------;-----------------------------------------
;                                    ;Bit  A|Y     GBASH     GBASL    A|Y = Row
                PLA                  ;| --------  --------  -------- Pull Y-Pos
                STA   GBASH          ;Y=ABCDEFGH (ABCDEFGH) ABAB0000 <Set GBASH
                ASL              ;A-BCDEFGH0< ABCDEFGH  ABAB0000 Shift Left
                ASL              ;B-CDEFGH00< ABCDEFGH  ABAB0000 Shift Left
                ASL              ;C-DEFGH000< ABCDEFGH  ABAB0000 Shift Left
                ROL   GBASH          ;A-DEFGH000  BCDEFGHC< ABAB0000 Sets GBASH
                ASL              ;D-EFGH0000< BCDEFGHC  ABAB0000 Shift Left
                ROL   GBASH          ;B-EFGH0000  CDEFGHCD< ABAB0000 Sets GBASH
                ASL              ;E-FGH00000< CDEFGHCD  ABAB0000 Shift Left
                ROR   GBASL          ;0-FGH00000  CDEFGHCD >EABAB000 Sets GBASL
                LDA   GBASH          ;0-CDEFGHCD (CDEFGHCD) EABAB000 <Get GBASH
                AND   #%00011111     ;0-000FGHCD& CDEFGHCD  EABAB000 Rtn 5 LSBs
                ORA   HGRPAGE        ;0-PPPFGHCD+ CDEFGHCD  EABAB000 +($20,$40)
                STA   GBASH          ;0-PPPFGHCD (PPPFGHCD) EABAB000 <Set GBASH
;                                    ;-----------------------------------------
;                                    ;Hi-Res Page1: PPP=001 for $2000-$3FFF
;                                    ;Hi-Res Page2: PPP=010 for $4000-$5FFF
; -----------------------------------;-----------------------------------------
;                                    ;Divide X-Position by 7 for Index frm Base
;                                    ;Address (Quotient) & BIT within Screen 
;                                    ;Memry Byte (Mask Specified by Remainder):
                TXA                  ;Retrieve Horizontal X-Position, Low
                CPY   #0             ;Is Horizontal X-Position, High a Zero?
                BEQ   HPOSN2         ;Branch if So: Horizontal X-Position < 256
;                                    ;Else, Horizontal X-Position >= 256:
;                                    ;256/7 = 36, Remainder = 4; & Carry = 1, 
;                                    ;So ADC #4 is Too Large; However, ADC #4 
;                                    ;Clears Carry which makes SBC #7 only -6, 
;                                    ;balancing it out ...
                LDY   #35            ;Following INY will make Y=36
                ADC   #4             ;Addvance Horizontal X-Position, Low
HPOSN1          INY                  ;Addvance Horizontal X-Position, High
;              ----------------------;Horizontal X-Position < 256:
HPOSN2          SBC   #7             ;Reduce Horizontal X-Position, Low
;                                    ;^[C=0: Subtract with Borrow (A-Data-!C)]
;                                    ;^[C=1: Subtract w.o  Borrow (A-Data-!C)]
                BCS   HPOSN1         ;BGE: LOOP if Borrowed [(A)>=(Data)]
                STY   HGRHORIZ       ;Store Horizontal Byte Index (Counted)
                TAX                  ;Use Remainder -7 to look up Color Bit Mask:
                LDA   MSKTBL-249,X   ;[Should be MSKTBL-$100+7,X] Get Bit Mask
                STA   HMASK          ;Save H/GR On-the-Fly Color Bit Mask
                TYA                  ;Retrieve Horizontal Byte Index (Quotient)
                LSR              ;Shift Right (lsb->C): Even or Odd Column?
                LDA   HGRCOLOR       ;Get Specified Hi-Res Graphics Color
                STA   HCOLOR1        ;Set Hi-Res Color Mask (Color Specified)
                BCS   COLORSHIFT     ;Branch if Odd Column: Fix Odd Color
                RTS                  ;Return to Caller if Even Column: No Fix

; ==============================================================================
; High-Resolution Graphics Mode (Hi-Res) Plot Subroutine:      [Called by HPLOT]
; ==============================================================================
; Enter with: [(X,Y)={Low,High}] = Horizontal (Cartesian) X-Coordinate (0-279)
;                  (Accumulator) =   Vertical (Cartesian) Y-Coordinate (0-191)
; ------------------------------------------------------------------------------
; Note: X-Coordinate = X-Position = Column; Y-Coordinate = Y-Position = Row
; ==============================================================================
; 
; -----------------------------------;Plot a Dot (w/ current Color Specified):
HPLOT0          JSR   HPOSN          ;Set Hi-Res Cursor Position
;                                    ;^[Computes Bit Position in GBASL/GBASH &
;                                    ;HGRHORIZ, + HMASK, from Y-Coordinate in
;                                    ;A-Reg & X-Coordinate in X-Reg & Y-Reg]
                LDA   HCOLOR1        ;Get Hi-Res Color Mask (Color Specified)
;                                    ;For any 1-bits in HCOLOR1, 
;                                    ;Substitute Corresponding Bit of HMASK: 
                EOR   (GBASL),Y      ;XOR with Dot at Cursor Position
                AND   HMASK          ;AND with H/GR On-the-Fly Color Bit Mask
                EOR   (GBASL),Y      ;XOR with Dot at Cursor Position
                STA   (GBASL),Y      ;Plot a Dot: Set Color at Cursor Position
                RTS                  ;Return to Caller

; ==============================================================================
; High-Resolution Graphics Mode (Hi-Res) Left, Right, Up, Down Subroutines:
; ==============================================================================
; 
; ==============================================================================
; Move Left or Right One Pixel (1 Dot):
; ==============================================================================
; If Status is Positive, Move Right; If is Negative, Move Left; If already at
; Left or Right Edge, Wrap Around
; ==============================================================================
; Remember Bits in Hi-Res Byte are Backwards Order:    Byte N   Byte N+1
;                                                    S7654321   SEDCBA98
; ==============================================================================
; 
MVLFTRGT        BPL   MVRIGHT        ;Go Move Right If Status is Positive
; -----------------------------------;Else, Move Left: Status is Negative:
MVLEFT          LDA   HMASK          ;Get H/GR On-the-Fly Color Bit Mask
;              ----------------------;Shifting Mask Right, Moves Dot Left:
                LSR              ;Shift Right (lsb->C): Bit = 0 or 1?
                BCS   MVLEFT1        ;Branch if Bit Set: Dot Moved to Next Byte
                EOR   #%11000000     ;Move Sign bit back to where it was (msb)
MVLFTRGT1       STA   HMASK          ;Set New H/GR On-the-Fly Color Bit Mask
                RTS                  ;Return to Caller

; -----------------------------------;Dot Moved to Next Byte:
MVLEFT1         DEY                  ;Reduce Horizontal Byte Index
                BPL   MVLEFT2        ;Branch if still Not Past Edge
                LDY   #39            ;Else, Off Left Edge, So Wrap Around Scrn:
MVLEFT2         LDA   #%11000000     ;New HMASK, Rightmost Bit on Screen, ...
;                                    ;     ... is Overflow Bit in Byte
MVLEFT3         STA   HMASK          ;Set New H/GR On-the-Fly Color Bit Mask
                STY   HGRHORIZ       ;Set New Horizontal Byte Index
; -----------------------------------;Correct for Color Shift:
                LDA   HCOLOR1        ;Get Hi-Res Color Mask: Black Bits = 1
COLORSHIFT      ASL              ;Shift/Rotate/Fix Even/Odd Color
                CMP   #%11000000     ;(Black1|White1|Black2|White2)=(0|3|4|7)?
                BPL   BAS_RTS26      ;Return to Caller if Black or White
;                                    ;Else, Shifted Hi-Res Color is Negative:
                LDA   HCOLOR1        ;Get Hi-Res Color Mask: Black Bits = 1
                EOR   #%01111111     ;Keep Sign Bit & Invert 7 Color Bits
                STA   HCOLOR1        ;Set Hi-Res Color Mask
BAS_RTS26       RTS                  ;Return to Caller

; -----------------------------------;Move Right: Status is Positive:
MVRIGHT         LDA   HMASK          ;Get H/GR On-the-Fly Color Bit Mask
;              ----------------------;Shifting Mask Left, Moves Dot Right:
                ASL              ;Shift Left (N->S): Bit = 0 or 1?
                EOR   #%10000000     ;Invert Sign Bit & Keep 7 Color Bits
                BMI   MVLFTRGT1      ;Branch if Finished [(N->S): Bit was = 0]
; -----------------------------------;Else, Not Done yet [(N->S): Bit was = 1],
;                                    ;Dot Moved to Next Byte:
                LDA   #%10000001     ;Get New H/GR On-the-Fly Color Bit Mask
                INY                  ;Advance Horizontal Byte Index
                CPY   #40            ;Is Horizontal Byte Index Off Right Edge?
                BCC   MVLEFT3        ;BLT: Branch if Not Past Edge; Else:
                LDY   #0             ;Wrap Around Scrn: Zero Horiz. Byte Index
                BCS   MVLEFT3        ;Now, Go Finish Up; Always Taken

; ==============================================================================
; More High-Resolution Graphics Mode (Hi-Res) Left, Right, Up, Down Subroutines:
; ==============================================================================
; 
; ==============================================================================
; "XDRAW" One Bit: [Same as DRAW, but this Compliments Color (It happens here!)]
; ==============================================================================
; 
; -----------------------------------;Entry Point for No 90 Degree Rotation:
LRUDX1          CLC                  ;Clear Carry Flag (C=0)
; -----------------------------------;Entry Point to Rotate 90 Degrees:
;                                    ;^[Carry Flag should already be Set (C=1)]
LRUDX2          LDA   HGRDX+1        ;Get Hi-Res Drawing Column, High
                AND   #%00000100     ;Is (Bit 2 = 0)?
                BEQ   LRUD4          ;YES, (Bit2 = 0), Don't Plot
;                                    ;NO, (Bit2 = 1), See what's already there:
;              ----------------------;[Start of Color Complemnting Section]:
                LDA   #%01111111     ;Clear Sign Bit & Keep 7 Color Bits:
                AND   HMASK          ;AND with H/GR On-the-Fly Color Bit Mask
                AND   (GBASL),Y      ;Get Dot at Cursor Position
;                                    ;Is Screen Bit Set (=1)?
                BNE   LRUD3          ;YES, Go Clear Screen Bit
                INC   HGRCLSN        ;NO, Count Collision
                LDA   #%01111111     ;& Turn Bit On
;              ----------------------;[End of Color Complemnting Section]
                AND   HMASK          ;And with H/GR On-the-Fly Color Bit Mask
                BPL   LRUD3          ;Go Plot Bit; Always Taken
; 
; ==============================================================================
; "DRAW" One Bit: [Same as XDRAW, but it Compliments Color (happens just above)]
; ==============================================================================
; 
; -----------------------------------;Entry Point for No 90 Degree Rotation:
LRUD1           CLC                  ;Clear Carry Flag (C=0)
; -----------------------------------;Entry Point to Rotate 90 Degrees:
;                                    ;^[Carry Flag should already be Set (C=1)]
LRUD2           LDA   HGRDX+1        ;Get Hi-Res Drawing Column, High
                AND   #%00000100     ;Is (Bit 2 = 0)?
                BEQ   LRUD4          ;YES, (Bit 2 = 0), Don't Plot
;                                    ;NO, (Bit2 = 1), See what's already there:
;              ----------------------;[Start of NonColorComplemnting Section]:
                LDA   (GBASL),Y      ;Get Dot at Cursor Position
;                                    ;Set Screen Bit to corresponding HCOLOR:
                EOR   HCOLOR1        ;XOR with Hi-Res Color Mask: Black Bits = 1
;              ----------------------;[End of Non Color Complemnting Section]
;                                    ;Look at just this Bit Position:
                AND   HMASK          ;AND with H/GR On-the-Fly Color Bit Mask
                BNE   LRUD3          ;Plot Bit if it was Zero
                INC   HGRCLSN        ;Else, Bit is already 1: Count Collision
; -----------------------------------;Plot Bit - Toggle Bit on Screen with (A):
LRUD3           EOR   (GBASL),Y      ;XOR with Dot at Cursor Position
                STA   (GBASL),Y      ;Set Dot at Cursor Position
; -----------------------------------;Don't Plot - Determine where next Point 
;                                    ;             will be, and Move there:
;              ----------------------;Calculate Direction to Move:
;                                    ;Add Quadrant to Specified Vector & Move 
;                                    ;Left/Right/Up/Down based on Sign & Carry:
LRUD4           LDA   HGRDX+1        ;Get Hi-Res Drawing Column, High
                ADC   HGRQUAD        ;Add Hi-Res Drawing Quadrant
CON3            AND   #%00000011     ;Wrap Around Circle
;                                    ;| 0 = %00 : Up    | 1 = %01 : Down |
;                                    ;| 2 = %10 : Right | 3 = %11 : Left |
                CMP   #2             ;C=0 if 0 or 1, C=1 if 2 or 3
                ROR              ;Put C into Sign, Odd/Even into C
                BCS   MVLFTRGT       ;BGE: Branch if C >= 2: Move Left or Right
;                                    ;Else, C < 2, Move Up or Down:
MVUPDWN0        BMI   MVDWN          ;Branch if Sign = 1: Move Down
;                                    ;Else, Sign = 0, Move Up:
; 
; ==============================================================================
; Move Up One Pixel (1 Dot): If already at Top, go to Bottom
; ==============================================================================
; -----------------------------------;Note: X-Coordinate = X-Position = Column
;                                    ;      Y-Coordinate = Y-Position = Row
; -----------------------------------;Remember:   Row      GBASH     GBASL
;                                    ;          ABCDEFGH  PPPFGHCD  EABAB000
; -----------------------------------;Compute Base Adrs for HR Line Above; Put
; MVUP        [Drop-In]              ;Result in (GBAS) w/ 192-Line Wrap Around:
; -----------------------------------;-----------------------------------------
                CLC                  ;Prepare for Add with Carry
                LDA   GBASH          ;Get Graphics Base Address, High
                BIT   CON_1C         ;&-Mask for "FGH" bits [($1C)=(%00011100)]
                BNE   MVUP5          ;Branch if FGH Bits <> 0; Go Do FGH=FGH-1
;                                    ;^[GBASH=PPP000CD, GBASL=EABAB000]
                ASL   GBASL          ;Else, Put GBASL Sign (E) Bit into Carry
; -----------------------------------;Move Left/Right/Up/Down based on Sign:
                BCS   MVUP3          ;Branch if Sign (E) Bit was Set (=1)
;                                    ;^[Do EFGH=EFGH-1 [Really: FGHCD-1]]
;              ----------------------;Finished?
;                                    ;Test Bit2 of GBASH for Carry [(H)<-(CD)]:
                BIT   CON3+1         ;(Constant=3)[SourceGen Mission Impossible]
                BEQ   MVUP1          ;Finished if No Carryover [(H=0)<-(CD)]
;                                    ;^[Y-Position Form is AB000000]?
;              ----------------------;Else, Not Finished, GBASH [(H=1)<-(CD)]:
                ADC   #%00011111     ;^[Do CDEFGH=CDEFGH-1 for Row = ABCDEFGH]
                SEC                  ;Force Following Branch:
                BCS   MVUP4          ;Always Taken

; -----------------------------------;No Carry, Finish:
;                                    ;Y-Position Form is AB000000
MVUP1           ADC   #$23           ;Add enough to make GBASH=PPP11111 later
                PHA                  ;Push Modified GBASH: Save it for Later
;              ----------------------;Is Wrap-Around Needed?
                LDA   GBASL          ;GBASL is now ABAB0000 (AB=00,01,10)
                ADC   #%10110000     ;Add to GBASL [High Nibble] 
;                                    ;GBASL = ABAB + 1011:
;                                    ;        0000 + 1011 = 1011  &  Clrs Carry
;                                    ;   or   0101 + 1011 = 0000  &  Sets Carry
;                                    ;   or   1010 + 1011 = 0101  &  Sets Carry
                BCS   MVUP2          ;Branch if C=1: No Wrap-Around Needed
;              ----------------------;Else, ... C=0, So Wrap-Around Needed:
                ADC   #%11110000     ;Add to Fix GBASL [High Nibble]->[1010]
MVUP2           STA   GBASL          ;Set Graphics Base Address, Low
;                                    ;^[Form is still ABAB0000]
;              ----------------------;Do CDEFGH=CDEFGH-1 for Row = ABCDEFGH:
                PLA                  ;Pull Modified GBASH: Saved for later Mod
                BCS   MVUP4          ;Always Taken
; 
; -----------------------------------;Do EFGH=EFGH-1 [Really: FGHCD-1]: 
MVUP3           ADC   #%00011111     ;Add to GBASH=PPPFGHCD
; -----------------------------------;Do CDEFGH=CDEFGH-1 for Row = ABCDEFGH:
MVUP4           ROR   GBASL          ;Shift (E) back in to get GBASL=EABAB000
; -----------------------------------;Finish GBASH Modifications, Do FGH=FGH-1:
;                                    ;^[GBASH=PPP000CD, GBASL=EABAB000]
MVUP5           ADC   #%11111100     ;Add to GBASH=PPPFGHCD [Really^: PPPFGH-1]
; -----------------------------------;Finished:
MVUPDWN1        STA   GBASH          ;Set Graphics Base Address, High
                RTS                  ;Return to Caller

; ==============================================================================
; Move Down One Pixel (1 Dot): If already at Bottom, go to Top
; ==============================================================================
; -----------------------------------;Note: X-Coordinate = X-Position = Column
;                                    ;      Y-Coordinate = Y-Position = Row
; -----------------------------------;Remember:   Row      GBASH     GBASL
;                                    ;          ABCDEFGH  PPPFGHCD  EABAB000
; -----------------------------------;Compute Base Adrs for HR Line Below; Put
; MVDOWN   [No Drop-In]              ;Result in (GBAS) w/ 192-Line Wrap Around:
; -----------------------------------;-----------------------------------------
                CLC                  ;Prepare for Add with Carry <(Never Used)>
; -----------------------------------;-----------------------------------------
MVDWN           LDA   GBASH          ;Get Graphics Base Address, High
CON4            ADC   #%00000100     ;Add to GBASH=PPPFGHCD; Do FGH=FGH+1
                BIT   CON_1C         ;&-Mask for "FGH" bits [($1C)=(%00011100)]
                BNE   MVUPDWN1       ;Branch if FGH Bits <> 0: Finished
                ASL   GBASL          ;Else, Put GBASL Sign (E) Bit into Carry
; -----------------------------------;Move Left/Right/Up/Down based on Sign:
                BCC   MVDWN2         ;Branch if Sign (E) Bit was Clear (=0)
;              ----------------------;Finished?
                ADC   #%11100000     ;Add to GBASH=PPPFGHCD; Do PPP=PPP-1
                CLC                  ;Prepare for Add with Carry
;                                    ;Test Bit2 of GBASH for Carry [(H)<-(CD)]:
                BIT   CON4+1         ;(Constant=4)[SourceGen Mission Impossible]
                BEQ   MVDWN3         ;Finished if No Carryover [(H=0)<-(CD)]
;                                    ;Else, Not Finished, GBASH [(H=1)<-(CD)]:
;              ----------------------;Is Wrap-Around Needed?
                LDA   GBASL          ;Get Graphics Base Address, Low
                ADC   #%01010000     ;Advance GBASL (AB)'s [High Nibble]: 
;                                    ;GBASL = ABAB + 0101:
;                                    ;        0000 + 0101 = 0101  &  No Carry
;                                    ;   or   0101 + 0101 = 1010  &  No Carry
;                                    ;   or   1010 + 0101 = 1111  &  No Carry
;                                    ;    &   1010 --> Wrap Around Up to Line 0
                EOR   #%11110000     ;Invert GBASL (AB)'s [High Nibble]
                BEQ   MVDWN1         ;Branch if GBASL is Zero: Wrap Needed
;                                    ;^[Wrap Around to Line Zero of Group]
;                                    ;Else, Wrap-Around Not Needed:
                EOR   #%11110000     ;Invert GBASL (AB)'s [High Nibble], Again
;                                    ;^[Get it Back to what was, to Not Wrap]
; -----------------------------------;Finish Move:
MVDWN1          STA   GBASL          ;Set New Graphics Base Address, Low
                LDA   HGRPAGE        ;Get Hi-Res Base Page (HPg1=$20, HPg2=$40)
                BCC   MVDWN3         ;Always Taken
; 
; -----------------------------------;Finish GBASH Modifications:
MVDWN2          ADC   #%11100000     ;Add to GBASH=PPPFGHCD; Do PPP=PPP-1
; -----------------------------------;Fix GBASL, Reverse Shift Left:
MVDWN3          ROR   GBASL          ;Shift (E) back in to get GBASL=EABAB000
                BCC   MVUPDWN1       ;Finished, Go Set GBASH; Always Taken
; 
; ==============================================================================
; High-Resolution Graphics Mode (Hi-Res) Line Drawing Subroutines:
; ==============================================================================
; 
; ==============================================================================
; HLINRL: Clear Current Point [(X0L, X0H), Y0] so HGLIN will act Relatively
;         to draw line from it to [{(X0L + DXL), (X0H + DXH)}, (Y0 + DY)]
; ==============================================================================
; HLINRL                           ;Enter with: (A,X) = DX from Current Point
; ^(Never Called by Applesoft)     ;             (Y)  = DY from Current Point
; ------------------------------------------------------------------------------
; Note: X-Coordinate = X-Position = Column; Y-Coordinate = Y-Position = Row
; ==============================================================================
; 
; ------------------------------------------------------------------------------
; HLINRL      [Drop-In Only]       ;Never Referenced [Can Never Happen]
; (Only Exception: User-Callable Entry Point; BASIC: CALL -2,768 or CALL 62,768;
;                  But Need to Set A,X & Y Registers 1st; How? POKES & Pg.3 S/R)
; ------------------------------------------------------------------------------
HLINRL          PHA                  ;Push Accumulator
                LDA   #0             ;Clear Accumulator
                STA   HGRX           ;Clear Horizontal X-Position, Low
                STA   HGRX+1         ;Clear Horizontal X-Position, High
                STA   HGRY           ;Clear  Vertical  Y-Position, Low
                PLA                  ;Pull Accumulator
; ------------------------------------------------------------------------------
; 
; ==============================================================================
; Hi-Res Line Drawing Subroutine: Draw Line from Last Plotted Point to [(A,X),Y]
; ==============================================================================
; HGLIN   [Can Drop-In Too]        ;Enter with: (A,X) = X of Target Point {L,H}
;                                    ;             (Y)  = Y of Target Point
; ------------------------------------------------------------------------------
; Note: X-Coordinate = X-Position = Column; Y-Coordinate = Y-Position = Row
; ==============================================================================
; Delta: the 4th letter of the Greek alphabet (D or d); is used here, with X & Y
; (DX & DY), to mean the amount by which one number or quantity differs from an-
; other, the amount of change; e.g., Delta X = [DX=X1-X0] & Delta Y = [DY=Y1-Y0]
; ==============================================================================
; 
; -----------------------------------;Compute Delta X = (X - X0):
HGLIN           PHA                  ;Push Target Point X-Coordinate, Low
                SEC                  ;Prepare to Subtract w/o Borrow [A-Data-!C]
                SBC   HGRX           ;Subtract Horizontal X-Position, Low
                PHA                  ;Push Delta X, Low
                TXA                  ;Get Target Point X-Coordinate, High
                SBC   HGRX+1         ;Subtract Horizontal X-Position, High
;                                    ;Now Carry's Direction of Change in X-Pos
                STA   HGRQUAD        ;Set Hi-Res Drawing Quadrant (w/ DXH)
;                                    ;^[Saves DX Dir (Pos=Right, Neg=Left)]
                BCS   HGLIN1         ;BGE: Branch if Borrowed
                PLA                  ;Else, Pull Delta X, Low; &
; -----------------------------------;Compute Magnitude of Delta X 
;                                    ;[(DXL,DXH)=(ABS(X-X0))={& Twos Comp}]:
                EOR   #%11111111     ;Invert Bits (Negate)
                ADC   #1             ;Add to Get New Delta X, Low [DXL=(1-DXL)]
                PHA                  ;Push New Delta X, Low
                LDA   #0             ;Prep to Subtract to Get [DXH=(1-DXH-!C)]
                SBC   HGRQUAD        ;Subtract Hi-Res Drawing Quadrant (w/ DXH)
HGLIN1          STA   HGRDX+1        ;Set Hi-Res Drawing Column, High [ABS(DXH)]
                STA   HGRE+1         ;Set Magnitude of Delta X, High  [ABS(DXH)]
                PLA                  ;Pull New Delta X, Low
                STA   HGRDX          ;Set Hi-Res Drawing Column, Low  [ABS(DXL)]
                STA   HGRE           ;Set Magnitude of Delta X, Low   [ABS(DXL)]
; -----------------------------------;Set Pointer to End of Line; Target X Pt:
                PLA                  ;Pull Target Point X-Coordinate, Low
                STA   HGRX           ;Set Horizontal X-Position, Low
                STX   HGRX+1         ;Set Horizontal X-Position, High
; -----------------------------------;Set Pointer to End of Line; Target Y Pt:
;              ----------------------;Compute Delta Y = (Y - Y0):
                TYA                  ;Get Target Point Y-Coordinate [Low < 256]
                CLC                  ;Prepare to Subtract w/ Borrow [A-Data-!C]
                SBC   HGRY           ;Subtract Vertical Y-Position  [DY=Y-Y0-1]
;                                    ;Now Carry's Direction of Change in Y-Pos
                BCC   HGLIN2         ;BLT: Branch if No Borrow
;              ----------------------;Else, Compute Magnitude of Delta Y
;                                    ;[(DY)=(ABS(Y-Y0))={& Twos Compliment}]:
                EOR   #%11111111     ;Invert Bits (Negate)
                ADC   #%11111110     ;Add to Get New Delta Y [DY=(254+{C=1}-DY)]
HGLIN2          STA   HGRDY          ;Set Hi-Res Drawing Row, Low [DY=(-1-DY)]
;                                    ;^[-(Magnitude of Delta Y, Lo) [-ABS(DY)]]
                STY   HGRY           ;Set Vertical Y-Position = Target Y Point
; -----------------------------------;Add Y-Dir to Hi-Res Drawing Quadrant:
                ROR   HGRQUAD        ;Shift Carry Right into HGRQUAD Bit 7
;                                    ;^[Saves DY Direction (Pos=Up, Neg=Down)]
;                                    ;^[Shifts DX Direction into HGRQUAD Bit 6]
; -----------------------------------;Initialize HCOUNT to [-DX-DY-1]:
;                                    ;^[HCount = Number of Dots needed]
                SEC                  ;Prepare to Subtract w/o Borrow [A-Data-!C]
                SBC   HGRDX          ;Subtract Drawing Column, Low [ABS(DXL)]
                TAX                  ;Save Result [-ABS(DY)-ABS(DXL)]
                LDA   #%11111111     ;Get -1
                SBC   HGRDX+1        ;Subtract Drawing Column, High [ABS(DXH)]
                STA   HCOUNT         ;Set Hi-Res Line Step [-1-ABS(DXH)]
; -----------------------------------;Draw Line:
                LDY   HGRHORIZ       ;Get Hi-Res Byte Horiz. Index from GBASH,L
                BCS   MOVEX2         ;BGE: Branch if Borrowed; Always Taken
; 
; -----------------------------------;Move Left or Right One Pixel;
;                                    ;A-Reg Bit 6 has Direction
;                                    ;MOVE X Loop 1 [Overlaps MOVE X Loop 2]:
MOVEX1L1        ASL              ;Shift Column Direction into Sign Bit
                JSR   MVLFTRGT       ;Move Left or Right One Pixel (1 Dot)
;              ----------------------;Draw Line Now:
                SEC                  ;Prepare to Add with Carry Set (Adds 1)
MOVEX2          LDA   HGRE           ;(C=1): Get Magnitude of Delta X, Low
                ADC   HGRDY          ;Add Hi-Res Drawing Row, Low [DY=(-1-DY)]
                STA   HGRE           ;Set Magnitude of Delta X, Low
                LDA   HGRE+1         ;Get Magnitude of Delta X, High
;                                    ;Carry Clear if HGRE {L,H} goes Negative
                SBC   #0             ;Subtract Zero with Borrow [A-Data-!C]
;                                    ;MOVE X Loop 2 [Overlaps MOVE X Loop 1]:
MOVEX3L2        STA   HGRE+1         ;Set Magnitude of Delta X, High
;              ----------------------;Plot A Dot:
                LDA   (GBASL),Y      ;Get Dot at Cursor Position
                EOR   HCOLOR1        ;XOR with Hi-Res Color Mask
                AND   HMASK          ;AND with H/GR On-the-Fly Color Bit Mask
                EOR   (GBASL),Y      ;XOR with Dot at Cursor Position
                STA   (GBASL),Y      ;Set Dot at Cursor Position
                INX                  ;Count Dot Plotted
;              ----------------------;Finished All Dots?
                BNE   MOVEX4         ;Branch if All Dots Not Done
;                                    ;Else, Test Rest of Count:
                INC   HCOUNT         ;Advance Hi-Res Line Step [-Dots Needed]
;                                    ;HCount = [-DX-DY-1] = No. of Dots needed
                BEQ   BAS_RTS27      ;EXIT if All Dots Done: Return to Caller
;              ----------------------;Else, Test Direction:
MOVEX4          LDA   HGRQUAD        ;Get Hi-Res Drawing Quadrant
;                                    ;^Bit 7 = DY Dir (Pos=Up, Neg=Down);
;                                    ;^Bit 6 = DX Dir (Pos=Right, Neg=Left)
                BCS   MOVEX1L1       ;[LOOP] BGE: Do Next Column (X Dir) Move
                JSR   MVUPDWN0       ;Else, Do Next Row (Y Direction) Move
;              ----------------------;Advance Hi-Res Horiz Cursor Position:
                CLC                  ;Prepare for Add with Carry
                LDA   HGRE           ;Get Magnitude of Delta X, Low
                ADC   HGRDX          ;Add Hi-Res Drawing Column, Low
                STA   HGRE           ;Set Magnitude of Delta X, Low
                LDA   HGRE+1         ;Get Magnitude of Delta X, High
                ADC   HGRDX+1        ;Add Hi-Res Drawing Column, High
;              ----------------------;(A)=(Magnitude of Delta X, Hi); Next Dot:
                BVC   MOVEX3L2       ;[LOOP] Branch if NO Overflow; Always Taken
; 
; ==============================================================================
; Graphics On-the-Fly Color Bit Mask Table                    (Binary Constants)
; ==============================================================================
; Remember Bits in Hi-Res Byte are Backwards Order:    Byte N   Byte N+1
;                                                    S7654321   SEDCBA98
; ==============================================================================
; 
MSKTBL        DFB   %10000001      ;Mask Hi-Res Byte Sign Bit & Column Bit 1
              DFB   %10000010      ;Mask Hi-Res Byte Sign Bit & Column Bit 2
              DFB   %10000100      ;Mask Hi-Res Byte Sign Bit & Column Bit 3
              DFB   %10001000      ;Mask Hi-Res Byte Sign Bit & Column Bit 4
              DFB   %10010000      ;Mask Hi-Res Byte Sign Bit & Column Bit 5
              DFB   %10100000      ;Mask Hi-Res Byte Sign Bit & Column Bit 6
              DFB   %11000000      ;Mask Hi-Res Byte Sign Bit & Column Bit 7
; 
; ==============================================================================
CON_1C        DFB   %00011100      ;Mask for "FGH" Bits [($1C)=(%00011100)]
;                                    ; Y-Coord   GBASH     GBASL
;                                    ;ABCDEFGH (PPPFGHCD) EABAB000
; ------------------------------------------------------------------------------
; Note: X-Coordinate = X-Position = Column; Y-Coordinate = Y-Position = Row
; ==============================================================================
; 
; 
; ==============================================================================
; Cosine Table                         (Used by DRAW and XDRAW as Defined Words)
; ==============================================================================
; COS(90*X/16 Degrees)*$100-1; with one-byte precision, X=0 ~ (+/-)16 (17 Bytes)
; ------------------------------------------------------------------------------
; Indexed via DRAW & XDRAW [for Cosines (DX's) & Sines (DY's)] like so:
;   LDY COSTBL,X   where X is a Positive Low Nibble Value, X=0 ~ +16 (for COS's)
; & LDY COSTBL+1,X where X is a Negative Low Nibble Value, X=0 ~ -16 (for SIN's)
; ==============================================================================
; 
;                                              Values 
;                     --------------------------------------------------------
;                      Hex          ;      Decimal      &     {Low,High}
;                     --------------;-------------------|---------------------
COSTBL          DA $FEFF         ;=(65,279)=(   -257)|(255,254)=(  -1,  -2)
                DA $F4FA         ;=(62,714)=( -2,822)|(250,244)=(  -6, -12)
                DA $E1EC         ;=(57,836)=( -7,700)|(236,225)=( -20, -31)
                DA $C5D4         ;=(50,644)=(-14,892)|(212,197)=( -44, -59)
                DA $A1B4         ;=(41,396)=(-24,140)|(180,161)=( -76, -95)
                DA $788D         ;=(30,861)=(-34,675)|(141,120)=(-115,-136)
                DA $4961         ;=(18,785)=(-46,751)|( 97, 73)=(-159,-183)
                DA $1831         ;=( 6,193)=(-59,343)|( 49, 24)=(-207,-232)
                DFB $FF           ;=(   255)=(-65,281)|(255,n/a)=(  -1, n/a)

; ==============================================================================
; High-Resolution Graphics Mode (Hi-Res) Coordinate Restore Subroutine:
; ==============================================================================
; HFIND (Never Called by Applesoft): Computes Current Position of Hi-Res Cursor;
;       Y-Coordinate from GBASH,GBASL & X-Coordinate from HGRHORIZ & HMASK
; ------------------------------------------------------------------------------
; Note: X-Coordinate = X-Position = Column; Y-Coordinate = Y-Position = Row
; ==============================================================================
; 
; ------------------------------------------------------------------------------
; HFIND       [Drop-In Only]       ;Never Referenced [Can Never Happen]
; (Only Exception: User-Callable Entry Point; BASIC: CALL -2,613 or CALL 62,923
; ------------------------------------------------------------------------------
; 
; -----------------------------------;Convert Base Address to Y-Coordinate;
;                                    ;For: GBASL=EABAB000, GBASH=PPPFGHCD;
;                                    ;Generate: Y-Coordinate=ABCDEFGH:
HFIND           LDA   GBASL          ;EABAB000; Get Graphics Base Address, Low
                ASL              ;EABAB000; Shift Sign (E) Bit into Carry
                LDA   GBASH          ;PPPFGHCD; Get Graphics Base Address, High
                AND   #%00000011     ;000000CD; AND Graphics Base Address, High
                ROL              ;00000CDE; Rotate Left: Carry, Sign (E) Bit
                ORA   GBASL          ;EABABCDE; OR Graphics Base Address, Low
                ASL              ;ABABCDE0; Shift Left
                ASL              ;BABCDE00; Shift Left
                ASL              ;ABCDE000; Shift Left
                STA   HGRY           ;ABCDE000; Save in Vertical Y-Position, Low
                LDA   GBASH          ;PPPFGHCD; Get Graphics Base Address, High
;                                    ;^(PPP=Screen Page)
                LSR              ;0PPPFGHC; Shift Right
                LSR              ;00PPPFGH; Shift Right
                AND   #%00000111     ;00000FGH; AND with Seven
                ORA   HGRY           ;ABCDEFGH; OR with Vertical Y-Position, Low
                STA   HGRY           ;ABCDEFGH; Set Vertical Y-Position, Low
; -----------------------------------;Convert HGRHORIZ & HMASK to X-Coordinate
;                                    ;[X = 7 * HGRHORIZ + (HMASK Bit Position)]
;                                    ;[Range 0-$133]:
                LDA   HGRHORIZ       ;Get Hi-Res Byte Horizontal Index    (I*1)
                ASL              ;Double (A): Horizontal Index        (I*2)
                ADC   HGRHORIZ       ;Add Hi-Res Byte Horizontal Index    (I*3)
                ASL              ;Double (A): Horizontal Index        (I*6)
;              ----------------------;Since (I*7) might not fit in 1 byte,
;                                    ; wait till later for last add:
                TAX                  ;Save (I*6) Horizontal Index
                DEX                  ;[Loop Prep] Reduce (I*6) Hrz.Index (I*6)-1
;                                    ;Find HMASK Bit Position:
                LDA   HMASK          ;Get H/GR On-the-Fly Color Bit Mask
                AND   #%01111111     ;Discard Sign Bit; Keep 7 Lower Bits (LSBs)
;                                    ;^[Sign Bit = 0 will Stop Loop if reached]
HFNDLOOP        INX                  ;Advance (Loop) Shift Counter   (I*6) 1st.
;                                    ;^[Saved (I*6) Horizontl Index] (I*6)+1..N
                LSR              ;Shift LSB Right into Carry
                BNE   HFNDLOOP       ;LOOP if LSB was Set; Else, Exit Loop:
                STA   HGRX+1         ;Set Horizontal X-Position, High (=0)
;                                    ;Compute HGRHORIZ*7+LOG2(HMASK):
                TXA                  ;Get Shift Count
;                                    ;^[Saved (I*6) Horizontl Index]   (I*6)+N
;              ----------------------;Add HGRHORIZ One More Time:
                CLC                  ;Prepare for Add with Carry
                ADC   HGRHORIZ       ;Add Hi-Res Byte Horizontal Index  (I*7)+N
                BCC   HFNDFIN        ;Branch if No Carryover
                INC   HGRX+1         ;Advance Horizontal X-Position, High
HFNDFIN         STA   HGRX           ;Set Horizontal X-Position, Low    (I*7)+N
BAS_RTS27       RTS                  ;Return to Caller

; ==============================================================================
; High-Resolution Graphics Mode (Hi-Res) Shape Drawing Subroutines:
; ==============================================================================
; 
; ==============================================================================
; DRAW0: Sets Hi-Res Screen Byte Pointer
; ==============================================================================
; DRAW0                            ;Enter: (X,Y) = Shape Starting Address {L,H}
; ^(Never Called by Applesoft)     ;        (A)  = Rotation ($00-$3F)
; ==============================================================================
; 
; ------------------------------------------------------------------------------
; DRAW0       [No Drop-In]         ;Never Referenced [Can Never Happen]
; (Only Exception: User-Callable Entry Point; BASIC: CALL -2,559 or CALL 62,977;
;                  But Need to Set A,X & Y Registers 1st; How? POKES & Pg.3 S/R)
; ------------------------------------------------------------------------------
; 
DRAW0           STX   HSHAPE         ;Set Hi-Res Screen Byte Pointer, Low
                STY   HSHAPE+1       ;Set Hi-Res Screen Byte Pointer, High
; 
; ------------------------------------------------------------------------------
; 
; ==============================================================================
; Draw A Shape: Continues "DRAW" Statement
; ==============================================================================
; DRAW1   [Can Drop-In Too]        ;Enter: (X,Y) = Shape Starting Address {L,H}
;                                    ;        (A)  = Rotation ($00-$3F)
; ------------------------------------------------------------------------------
; Note: X-Coordinate = X-Position = Column; Y-Coordinate = Y-Position = Row
; ==============================================================================
; 
;                                    ;[Same as XDRAW, but it Compliments Color]
DRAW1           TAX                  ;Save Rotation Angle [($00-$3F)=(0-63)]
;              ----------------------;Divide Rotation by 16 to Get Quadrant:
                LSR              ;Shift Right: (A)=(A/2);  NOW
                LSR              ;Shift Right: (A)=(A/2); (A/4)
                LSR              ;Shift Right: (A)=(A/2); (A/8)
                LSR              ;Shift Right: (A)=(A/2); (A/16)
                STA   HGRQUAD        ;Set HGR Drawing Quadrant
;                                    ;^(Dir: Up=0, Right=1, Down=2, Left=3)
;              ----------------------;Use Rotation Angle to Index Trig Table
;                                    ;^[to Get COS & SIN, (X,Y) Distances]:
                TXA                  ;Retrieve Rotation Angle [($00-$3F)=(0-63)]
                AND   #%00001111     ;AND w/ Rotation to Get Index (Low Nibble)
                TAX                  ;Set Positive Index into Trig Table for DX
                LDY   COSTBL,X       ;Get COS(90*X/16 Degrees)*$100-1, Low
                STY   HGRDX          ;Save COS in HGRDX, Drawing Column, Low
                EOR   #%00001111     ;Invert (Negate) Low Nibble Bits of Index
                TAX                  ;Set Negative Index into Trig Table for DY
                LDY   COSTBL+1,X     ;Get COS(90*X/16 Degrees)*$100-1, High
                INY                  ;Advance Value Got; Now have SIN, too
                STY   HGRDY          ;Save SIN in HGRDY, Drawing Row
;              ----------------------;Prepare to DRAW One Bit:
                LDY   HGRHORIZ       ;Get HGR Hrz.Index frm GBAS to Current Byte
                LDX   #0             ;Clear Index into Trig Table 
                STX   HGRCLSN        ;Clear HGR Collision Counter
                LDA   (HSHAPE,X)     ;Get 1st Byte of SHAPE Definition
DRWLP2          STA   HGRDX+1        ;Store SHAPE Byte in Drawing Column, High
                LDX   #$80           ;Get Initial Value for Fractional Vectors:
                STX   HGRE           ;Set .5 in COS X-Component
                STX   HGRE+1         ;Set .5 in SIN Y-Component
                LDX   HGRSCALE       ;Get Drawing Scale Factor
;              ----------------------;Advance COS X-Component:
DRWLP3          LDA   HGRE           ;Get COS X-Component
                SEC                  ;Prepare for Add w/ Carry Set (Adds 1)
                ADC   HGRDX          ;Add COS X-Component to Drawing Column
                STA   HGRE           ;Set COS X-Component
;                                    ;^[Save Fraction Part, No Integer Part]
                BCC   DRW4           ;BLT: Branch if No Carryover; Else, ...*
                JSR   LRUD1          ;* DRAW One Bit (w/o 90 Degree Rotation)
;                                    ;^[Same as XDRAW <- Compliments Color]
;              ----------------------;Advance SIN Y-Component:
                CLC                  ;Prepare for Add w/ Carry Clear (Adds 0)
DRW4            LDA   HGRE+1         ;Get SIN Y-Component
                ADC   HGRDY          ;Add SIN Y-Component to Drawing Row
                STA   HGRE+1         ;Set SIN Y-Component
;                                    ;^[Save Fraction Part, No Integer Part]
                BCC   DRW5           ;BLT: Branch if No Carryover; Else, ...*
                JSR   LRUD2          ;* DRAW One Bit (w/ 90 Degree Rotation)
;                                    ;^[Same as XDRAW <- Compliments Color]
;              ----------------------;Next Iteration:
DRW5            DEX                  ;Reduce Drawing Scale Factor
                BNE   DRWLP3         ;LOOP if Still on Same SHAPE Item
                LDA   HGRDX+1        ;Get Next SHAPE Item
;                                    ;Go to Next 3-Bit Vector:
                LSR              ;Shift Right: 1st Bit Out
                LSR              ;Shift Right: 2nd Bit Out
                LSR              ;Shift Right: 3rd Bit Out
                BNE   DRWLP2         ;LOOP if More in this SHAPE Byte
                INC   HSHAPE         ;Advance to Next SHAPE Byte, Low
                BNE   DRW6           ;Branch Until Page Boundary Reached
                INC   HSHAPE+1       ;Advance to Next SHAPE Byte, High
DRW6            LDA   (HSHAPE,X)     ;Get Next Byte of SHAPE Definition
                BNE   DRWLP2         ;LOOP if SHAPE Definition <> 0
                RTS                  ;Else, Finished, Return to Caller

; ==============================================================================
; High-Resolution Graphics Mode (Hi-Res) Shape XDRAW Subroutine:
; ==============================================================================
; 
; ==============================================================================
; XDRAW0: Sets Hi-Res Screen Byte Pointer
; ==============================================================================
; XDRAW0                           ;Enter: (X,Y) = Shape Starting Address {L,H}
; ^(Never Called by Applesoft)     ;        (A)  = Rotation ($00-$3F)
; ==============================================================================
; 
; ------------------------------------------------------------------------------
; XDRAW0      [No Drop-In]         ;Never Referenced [Can Never Happen]
; (Only Exception: User-Callable Entry Point; BASIC: CALL -2,467 or CALL 63,069;
;                  But Need to Set A,X & Y Registers 1st; How? POKES & Pg.3 S/R)
; ------------------------------------------------------------------------------
; 
XDRAW0          STX   HSHAPE         ;Set Hi-Res Screen Byte Pointer, Low
                STY   HSHAPE+1       ;Set Hi-Res Screen Byte Pointer, High
; 
; ------------------------------------------------------------------------------
; 
; ==============================================================================
; XDraw A Shape: Continues "XDRAW" Statement
; ==============================================================================
; XDRAW1  [Can Drop-In Too]        ;Enter: (X,Y) = Shape Starting Address {L,H}
;                                    ;        (A)  = Rotation ($00-$3F)
; ------------------------------------------------------------------------------
; Note: X-Coordinate = X-Position = Column; Y-Coordinate = Y-Position = Row
; ==============================================================================
; 
;                                    ;[Same as DRAW, but Compliments Color]
XDRAW1          TAX                  ;Save Rotation Angle [($00-$3F)=(0-63)]
;              ----------------------;Divide Rotation by 16 to Get Quadrant:
                LSR              ;Shift Right: (A)=(A/2);  NOW
                LSR              ;Shift Right: (A)=(A/2); (A/4)
                LSR              ;Shift Right: (A)=(A/2); (A/8)
                LSR              ;Shift Right: (A)=(A/2); (A/16)
                STA   HGRQUAD        ;Set HGR Drawing Quadrant
;                                    ;^(Dir: Up=0, Right=1, Down=2, Left=3)
;              ----------------------;Use Rotation Angle to Index Trig Table
;                                    ;^[to Get COS & SIN, (X,Y) Distances]:
                TXA                  ;Retrieve Rotation Angle [($00-$3F)=(0-63)]
                AND   #%00001111     ;AND w/ Rotation to Get Index (Low Nibble)
                TAX                  ;Set Positive Index into Trig Table for DX
                LDY   COSTBL,X       ;Get COS(90*X/16 Degrees)*$100-1, Low
                STY   HGRDX          ;Save COS in HGRDX, Drawing Column, Low
                EOR   #%00001111     ;Invert (Negate) Low Nibble Bits of Index
                TAX                  ;Set Negative Index into Trig Table for DY
                LDY   COSTBL+1,X     ;Get COS(90*X/16 Degrees)*$100-1, High
                INY                  ;Advance Value Got; Now have SIN, too
                STY   HGRDY          ;Save SIN in HGRDY, Drawing Row
;              ----------------------;Prepare to DRAW One Bit:
                LDY   HGRHORIZ       ;Get HGR Hrz.Index frm GBAS to Current Byte
                LDX   #0             ;Clear Index into Trig Table
                STX   HGRCLSN        ;Clear HGR Collision Counter
                LDA   (HSHAPE,X)     ;Get 1st Byte of SHAPE Definition
XDRWLP2         STA   HGRDX+1        ;Store SHAPE Byte in Drawing Column, High
                LDX   #$80           ;Get Initial Value for Fractional Vectors:
                STX   HGRE           ;Set .5 in COS X-Component
                STX   HGRE+1         ;Set .5 in SIN Y-Component
                LDX   HGRSCALE       ;Get Drawing Scale Factor
;              ----------------------;Advance COS X-Component:
XDRWLP3         LDA   HGRE           ;Get COS X-Component
                SEC                  ;Prepare for Add w/ Carry Set (Adds 1)
                ADC   HGRDX          ;Add COS X-Component to Drawing Column
                STA   HGRE           ;Set COS X-Component
;                                    ;^[Save Fraction Part, No Integer Part]
                BCC   XDRW4          ;BLT: Branch if No Carryover; Else, ...*
                JSR   LRUDX1         ;* XDRAW One Bit (w/o 90 Degree Rotation)
;                                    ;^[Same as DRAW, but Compliments Color]
;              ----------------------;Advance SIN Y-Component:
                CLC                  ;Prepare for Add w/ Carry Clear (Adds 0)
XDRW4           LDA   HGRE+1         ;Get SIN Y-Component
                ADC   HGRDY          ;Add SIN Y-Component to Drawing Row
                STA   HGRE+1         ;Set SIN Y-Component
;                                    ;^[Save Fraction Part, No Integer Part]
                BCC   XDRW5          ;BLT: Branch if No Carryover; Else, ...*
                JSR   LRUDX2         ;* XDRAW One Bit (w/ 90 Degree Rotation)
;                                    ;^[Same as DRAW, but Compliments Color]
;              ----------------------;Next Iteration:
XDRW5           DEX                  ;Reduce Drawing Scale Factor
                BNE   XDRWLP3        ;LOOP if Still on Same SHAPE Item
                LDA   HGRDX+1        ;Get Next SHAPE Item
;                                    ;Go to Next 3-Bit Vector:
                LSR              ;Shift Right: 1st Bit Out
                LSR              ;Shift Right: 2nd Bit Out
                LSR              ;Shift Right: 3rd Bit Out
                BNE   XDRWLP2        ;LOOP if More in this SHAPE Byte
                INC   HSHAPE         ;Advance to Next SHAPE Byte, Low
                BNE   XDRW6          ;Branch Until Page Boundary Reached
                INC   HSHAPE+1       ;Advance to Next SHAPE Byte, High
XDRW6           LDA   (HSHAPE,X)     ;Get Next Byte of SHAPE Definition
                BNE   XDRWLP2        ;LOOP if SHAPE Definition <> 0
                RTS                  ;Else, Finished, Return to Caller

; ==============================================================================
; Parsing Routines used by BASIC for Hi-Res Access:
; ==============================================================================
; 
; ==============================================================================
; HFNS Subroutine: Get Hi-Res Plotting Coordinates (0-279,0-191) from TXTPTR
;                  Leave Registers set for HPOSN: (X,Y) = X-Coordinate (Column)
;                                                  (A)  = Y-Coordinate (Row)
; ==============================================================================
; 
;              ----------------------;Evaluate Expression; Must be Numeric:
HFNS            JSR   FRMNUM         ;Get Value Specified as 16-Bit Integer
                JSR   GETADR         ;Convert FAC to a 16-bit Value in LINNUM
;              ----------------------;Get Column-Coord in (X,Y)={Low,High}:
                LDY   LINNUM+1       ;Get Horizontal-Column X-Coordinate, High
                LDX   LINNUM         ;Get Horizontal-Column X-Coordinate, Low
                CPY   #>HGRWIDE      ;< 280 Pixels: HGR Screens Width, High?
                BCC   HFNS1          ;BLT: Branch if in Range, < 280 Pixels
                BNE   GGERR          ;Branch if Too Big (>=280); Throw IQ ERROR
                CPX   #<HGRWIDE      ;< 280 Pixels: HGR Screens Width, Low?
                BCS   GGERR          ;Branch if Too Big (>=280); Throw IQ ERROR
;                                    ;Else, in Range, < 280 Pixels ...
;              ----------------------;Stack Column-Coordinate:
HFNS1           TXA                  ;Get Horizontal-Column X-Coordinate, Low
                PHA                  ;Push Horizontal-Column X-Coordinate, Low
                TYA                  ;Get Horizontal-Column X-Coordinate, High
                PHA                  ;Push Horizontal-Column X-Coordinate, High
;              ----------------------;Get Row-Coordinate in Accumulator (A):
                LDA   #44           ;Require a Comma (at TXTPTR)
                JSR   SYNCHR         ;If = Chr Got, Get Next; Else, Syntax Error
                JSR   GETBYT         ;Convert Expression to a Byte in X-Reg
                CPX   #HGRHIGH       ;< 192 Pixels: HGR Screens Height?
                BCS   GGERR          ;Branch if Too Big (>=192); Throw IQ ERROR
                STX   FAC            ;Save Vertical-Row Y-Coordinate in FAC
;              ----------------------;Retrieve Column & Row Coordinates:
                PLA                  ;Pull Horizontal-Column X-Coordinate, High
                TAY                  ;Set Horizontal-Column X-Coordinate, High
                PLA                  ;Pull Horizontal-Column X-Coordinate, Low
                TAX                  ;Set Horizontal-Column X-Coordinate, Low
                LDA   FAC            ;Set Vertical-Row Y-Coordinate from FAC
;              ----------------------;Finished (with Registers set for HPOSN):
                RTS                  ;Return to Caller

GGERR           JMP   BAS_GOERR      ;Go Print "?Illegal Quantity" Error Message

; ==============================================================================
; "HCOLOR=" Statement: Immediate & Deferred; Parameter: HCOLOR = Aexpr; (0~7)
; ==============================================================================
; Sets High-Resolution Graphics Color; Color Names & Associated Values:
; +------------+-------------+---------------------------+---------------------+
; |  0 Blackl  |  4 Black2  _/  1 Green (depends on TV)  |  5 (depends on TV)  |
; |  3 Whitel  |  7 White2   \  2 Blue  (depends on TV)  |  6 (depends on TV)  |
; +------------+-------------+---------------------------+---------------------+
; A High-Resolution Dot plotted with HCOLOR=3 (White) will be Blue if the 
; X-Coordinate of the Dot is Even, Green if the X-Coordinate is Odd, and White
; only if both (X,Y) & (X+1,Y) are plotted; This is due to the way home TVs work
; [the Technology of the Time (late 1970s)--JPD]
; ==============================================================================
; 
HCOLOR          JSR   GETBYT         ;Convert Expression to a Byte in X-Reg
                CPX   #$08           ;Value must be 0~7
                BCS   GGERR          ;Branch if Too Big (>=8); Throw IQ ERROR
                LDA   COLORTBL,X     ;Get Color Pattern from Table
                STA   HGRCOLOR       ;Save Hi-Res Graphics Color
BAS_RTS28       RTS                  ;Return to Caller

; ==============================================================================
; High Resolution Graphics Colors Table
; ==============================================================================
; 
COLORTBL       DFB  %00000000      ;Black1
               DFB  %00101010      ;Green
               DFB  %01010101      ;Violet
               DFB  %01111111      ;White1
               DFB  %10000000      ;Black2
               DFB  %10101010      ;Orange
               DFB  %11010101      ;Cyan (Light-Blue)
               DFB  %11111111      ;White2

; ==============================================================================
; "HPLOT" Statement: Immediate & Deferred
; ==============================================================================
; Parameters: HPLOT Aexprl, Aexpr2 [{TO Aexpr3, Aexpr4}]
; -----------------------------------------------------------------------------
; HPLOT Plots a High-Resolution Dot, or a Line from the Last Dot Plotted, & may
; be Extended (Subject to Screen Limits & Character Instruction Limits)
; ==============================================================================
; 
HPLOT           CMP   #TOTK          ;Continue Plotting "TO" Requested?
                BEQ   HPLOT2         ;YES, Start from Current Location
                JSR   HFNS           ;NO, Get Starting Point of Line
                JSR   HPLOT0         ;Plot Point & Prep to Draw a Line from it
HPLOTLOOP       JSR   CHRGOT         ;Get Character at End of Expression
                CMP   #TOTK          ;Is a Line Specified?
                BNE   BAS_RTS28      ;NO, Exit: a Line is Not Specified
;                                    ;YES, Advance TXTPTR
;                                    ;(Why Not CHRGET? A: CMP Sets Carry)
HPLOT2          JSR   SYNCHR         ;If = Chr Got, Get Next; Else, Syntax Error
                JSR   HFNS           ;Get Point Coordinates at End of Line
;                                    ;Prepare to Continue Plotting "TO" Line:
                STY   DSCTMP         ;Swap (Y) into (T)
                TAY                  ;Swap (A) into (Y)
                TXA                  ;Swap (X) into (A)
                LDX   DSCTMP         ;Swap (T) into (X)
                JSR   HGLIN          ;Plot Line
                JMP   HPLOTLOOP      ;LOOP Until No More "TO" Phrases

; ==============================================================================
; "ROT=" Statement: Immediate & Deferred; Parameter: ROT = Aexpr
; ==============================================================================
; Sets Angular Rotation for SHAPE to be Drawn by DRAW or XDRAW
; ==============================================================================
; 
ROT             JSR   GETBYT         ;Convert Expression to a Byte in X-Reg
                STX   HGRROT         ;Set Hi-Res Graphics Rotation Value
                RTS                  ;Return to Caller

; ==============================================================================
; "SCALE=" Statement: Immediate & Deferred; Parameter: SCALE = Aexpr
; ==============================================================================
; Sets SCALE Size for SHAPE to be Drawn by DRAW or XDRAW
; ==============================================================================
; 
SCALE           JSR   GETBYT         ;Convert Expression to a Byte in X-Reg
                STX   HGRSCALE       ;Set Hi-Res Graphics Drawing Scale Factor
                RTS                  ;Return to Caller

; ==============================================================================
; DRWPTR Subroutine: Prepares for DRAW & XDRAW:
; ==============================================================================
; 
; -----------------------------------;Find & Check SHAPE Number Specified:
DRWPTR          JSR   GETBYT         ;Convert Expression to a Byte in X-Reg
;                                    ;Setup Pointer to SHAPE Table Start:
                LDA   HGRSHPTR       ;Get HGR SHAPE Pointer, Low
                STA   HSHAPE         ;Set SHAPE Table Start Pointer, Low
                LDA   HGRSHPTR+1     ;Get HGR SHAPE Pointer, High
                STA   HSHAPE+1       ;Set SHAPE Table Start Pointer, High
                TXA                  ;Get SHAPE Number Specified
;              ----------------------;Compare to Total No. of SHAPEs in Table:
                LDX   #0             ;Clear (Indexed Indirect) Addressing Index
                CMP   (HSHAPE,X)     ;Subtract Total Number of SHAPE Definitions
                BEQ   DRWPTR1        ;Branch if Both Numbers of SHAPEs are Equal
                BCS   GGERR          ;Else, Branch if Spec Too Big; Throw IQ ERR
; -----------------------------------;Else, Find Address of SHAPE in Table:
DRWPTR1         ASL              ;Double SHAPE Number Specified for Index
                BCC   DRWPTR2        ;Branch if SHAPE Number Specified < 128
                INC   HSHAPE+1       ;Advance SHAPE Table Start Pointer, High
;              ----------------------;Get Offset frm SHAPE Table Offsets Index:
                CLC                  ;Prepare for Add with Carry
DRWPTR2         TAY                  ;Get Index into SHAPE Table Offsets Index
                LDA   (HSHAPE),Y     ;Get SHAPE Offset, Low
                ADC   HSHAPE         ;Add SHAPE Table Start Pointer, Low
                TAX                  ;Save Low Address of SHAPE in Table
                INY                  ;INC Index into SHAPE Table Offsets Index
                LDA   (HSHAPE),Y     ;Get SHAPE Offset, High
                ADC   HGRSHPTR+1     ;Add HGR SHAPE Pointer, High
;              ----------------------;Save Address of SHAPE in Table:
                STA   HSHAPE+1       ;Set SHAPE Start Pointer, High
                STX   HSHAPE         ;Set SHAPE Start Pointer, Low
; -----------------------------------;Any More "AT" Position Coordinates?
                JSR   CHRGOT         ;Get Last Char/Token Got
                CMP   #ATTK          ;Is it an "AT" Phrase?
                BNE   DRWPTR3        ;Branch if Not: DRAW at Current Position
;              ----------------------;Else, Scan "AT" Position Coordinates:
                JSR   SYNCHR         ;If = Chr Got, Get Next; Else, Syntax Error
                JSR   HFNS           ;Get Column & Row to Start Drawing SHAPE
                JSR   HPOSN          ;Set Hi-Res Cursor at Position Coordinates
; -----------------------------------;DRAW at Current Position:
DRWPTR3         LDA   HGRROT         ;Get Rotation Value
                RTS                  ;Return to Caller

; ==============================================================================
; "DRAW" Statement: Immediate & Deferred;
;                   Parameters: DRAW Aexprl [AT Aexpr2, Aexpr3]
; ==============================================================================
; DRAWs a SHAPE (Aexprl)=(0~255) in High-Resolution Graphics at (X,Y)=(Aexpr2,
; Aexpr3)=(0~278,0~191) from a SHAPE Table previously loaded into Memeory using
; SHLOAD (from Tape) or BLOAD (from Disk), or typed in using Apple's F8 Monitor
; Program.
; ==============================================================================
; 
;                                    ;[Same as XDRAW, but it Compliments Color]
DRAW            JSR   DRWPTR         ;Prepare for DRAW|XDRAW
                JMP   DRAW1          ;Go DRAW 1 Shape

; ==============================================================================
; "XDRAW" Statement: Immediate & Deferred;
;                    Parameters: XDRAW Aexprl [AT Aexpr2, Aexpr3]
; ==============================================================================
; Provides a way to Erase SHAPEs previously Drawn: XDRAWing a SHAPE at the same
; Location, Rotation, & Scale previously Drawn will Erase it without Erasing its
; Background; Same as DRAW, except Color used to XDRAW SHAPE is Complement of
; Color already existing at each Point plotted; Pairs of Complementary Colors
; are: Black & White; Cyan (or Light-Blue) & Green; and Violet & Orange
; ==============================================================================
; 
;                                    ;[Same as DRAW, but Compliments Color]
XDRAW           JSR   DRWPTR         ;Prepare for DRAW|XDRAW
                JMP   XDRAW1         ;Go XDRAW 1 Shape

; ==============================================================================
; "SHLOAD" Command Statement: Immediate & Deferred; No Parameters or Options
; ==============================================================================
; Reads/Loads a SHAPE Table from Cassette Tape to a Position just below HIMEM,
; which is then moved to just below the SHAPE Table LOADed
; ==============================================================================
; 
; -----------------------------------;Prepare to Load Shape Table from Tape:
;              ----------------------;Prepare to Read 2 Bytes into LINNUM:
SHLOAD          LDA   #0             ;Clear Accumulator
                STA   A1H            ;Clear Monitor General Purpose A1-Reg, High
                STA   A2H            ;Clear Monitor General Purpose A2-Reg, High
                LDY   #LINNUM        ;Get ZP Address of LINNUM
                STY   A1L            ;Set Monitor General Purpose A1-Reg, Low
                INY                  ;Get ZP Address of LINNUM+1
                STY   A2L            ;Set Monitor General Purpose A2-Reg, Low
;              ----------------------;Read Length into LINNUM:
                JSR   MON_READ       ;Go Read 2 Bytes of Data from Tape
;              ----------------------;Prepare to Read LINNUM Bytes, Starting at
; 
;                                    ;(HIMEM)-(LINNUM) & Ending at (HIMEM)-1:
                CLC                  ;Prepare to Subtract w/ Borrow [A-Data-!C]
                LDA   MEMSIZ         ;Get Top End of String Space (HIMEM), Low
                TAX                  ;Set (X)=[String Space End (HIMEM), Low]
                DEX                  ;(X)=[(HIMEM)-1] Forming End Pointer, Low
                STX   A2L            ;Set Monitor General Purpose A2-Reg, Low
                SBC   LINNUM         ;[(HIMEM)-(LINNUM)] Forming Start Ptr, Low
                PHA                  ;Push Start Pointer, Low
                LDA   MEMSIZ+1       ;Get Top End of String Space (HIMEM), High
                TAY                  ;Set (Y)=[String Space End (HIMEM), High]
                INX                  ;Set (X)=[String Space End (HIMEM), Low]
                BNE   SHLOAD1        ;Branch if Not at Page Boundary
                DEY                  ;(Y)=[(HIMEM)-1] Forming End Pointer, High
SHLOAD1         STY   A2H            ;Set Monitor General Purpose A2-Reg, High
                SBC   LINNUM+1       ;[(HIMEM)-(LINNUM)] Forming Start Ptr, High
                CMP   STREND+1       ;Subtract End of Vars & Ptrs Storage, High
;                                    ;^[AKA: Bottom/Start of Free Space]
                BCC   SHLOAD2        ;Branch if SHLOAD would clobber Vars & Ptrs
                BNE   SHLOAD3        ;Branch if SHLOAD has sufficient Free Space
SHLOAD2         JMP   OMERR          ;Throw an "?Out Of Memory" Error

; -----------------------------------;Load Shape Table from Tape:
;              ----------------------;(A)=[(HIMEM)-(LINNUM)] Start Ptr, High:
SHLOAD3         STA   MEMSIZ+1       ;Set Top End of String Space (HIMEM), High
                STA   FRETOP+1       ;Set FreSpcEnd/StringStorageStart Ptr, High
                STA   A1H            ;Set Monitor General Purpose A1-Reg, High
                STA   HGRSHPTR+1     ;Set Hi-Res Graphics Shape Pointer, High
                PLA                  ;Pull [(HIMEM)-(LINNUM)] Start Pointer, Low
                STA   HGRSHPTR       ;Set Hi-Res Graphics Shape Pointer, Low
                STA   MEMSIZ         ;Set Top End of String Space (HIMEM), Low
                STA   FRETOP         ;Set FreSpcEnd/StringStorageStart Ptr, Low
                STA   A1L            ;Set Monitor General Purpose A1-Reg, Low
                JSR   RD2BIT         ;Read Two Bits, Tape Transitions; Find Edge
                LDA   #3             ;Create Short Delay for Intermediate Header
                JMP   MON_READ2      ;Go Read Shape Table into (A1-Reg)

; 
; ==============================================================================
; Non-Graphics Subroutines:
; ==============================================================================
; 
; ==============================================================================
; Tape Array STORE & RECALL Routines: 
; ==============================================================================
; 
; ==============================================================================
; Called by STORE & RECALL: 
; Point Tape Array Data Pointers at First Value in Specified Array
; ==============================================================================
; NOTE: (ARYPTR) = (HIGHDS)
; ------------------------------------------------------------------------------
;       (ARYPTR) = Applesoft Array Pointer
;       (HIGHDS) = Highest Destination Adrs +1
; ==============================================================================
; 
; -----------------------------------;Compute Offset to Next Variable:
TAPEPTR         CLC                  ;Prepare for Add with Carry
                LDA   LOWTR          ;Get Specified Array Variable Pointer, Low
                ADC   LINNUM         ;Add Array Size, Low
                STA   A2L            ;Set Monitor General Purpose A2-Reg, Low
                LDA   LOWTR+1        ;Get Specified Array Variable Pointer, High
                ADC   LINNUM+1       ;Add Array Size, High
                STA   A2H            ;Set Monitor General Purpose A2-Reg, High
;                                    ;A2 Now has Offset to Next Variable
; -----------------------------------;Get Address of 1st Value in Array:
                LDY   #4             ;Point to Number of Array Dimensions
;                                    ;^[Data within Array Variable Pointer]
                LDA   (LOWTR),Y      ;Get Number of Array Dimensions
                JSR   GETAR2         ;Compute Address of 1st Value in Array
;                                    ;ARYPTR Now has Adrs of 1st Value in Array
                LDA   ARYPTR         ;Get Array Pointer, Low
                STA   A1L            ;Set Monitor General Purpose A1-Reg, Low
                LDA   ARYPTR+1       ;Get Array Pointer, High
                STA   A1H            ;Set Monitor General Purpose A1-Reg, High
;                                    ;A1 Now has Address of 1st Value in Array
                RTS                  ;Return to Caller

; ==============================================================================
; Called by STORE & RECALL: Points LOWTR at Array Specified if Found
; ==============================================================================
; 
;                                    ;Get an Array Pointer:
GETARYPTR       LDA   #$40           ;Prepare to Flag "Called from GETARYPTR"
                STA   SUBFLG         ;Set Subscript Flag ($00=Allowed, $80=NOT)
                JSR   PTRGET         ;Locate Variable: Returns Address
;                                    ; in VARPTR & [(A,Y)={Low,High}]
                LDA   #$00           ;Prepare to Allow Subscripts
                STA   SUBFLG         ;Set Subscript Flag ($00=Allowed, $80=NOT)
;                                    ;Prepare to Read/Write a 3-Byte Header 
;                                    ;from/to a Cassette Tape (Audio I/O):
                JMP   VARTIO         ;Point A1/A2 at LINNUM/TEMPPT ZP-Pointers

; ==============================================================================
; "HTAB" Statement: Immediate & Deferred; Parameter: HTAB Aexprl
; ==============================================================================
; Moves the Cursor to the Column Position Specified (Aexprl), on the Current
; Screen Line, Relative to the Left Margin of the Text Window, but Independent
; of the Line Width
; ==============================================================================
; 
;                                    ;Get Column Position Specified:
HTAB            JSR   GETBYT         ;Convert Expression to a Byte in X-Reg
                DEX                  ;Reduce Column Position Specified (-1)
                TXA                  ;Get Text Screen Position (0~255)
; <<< If WNDLFT <> (0), HTAB can Print Outside of Screen, within Program! >>>
HTABLOOP        CMP   #BASL          ;Is it More or Less than Text Screen Width?
                BCC   HTABEXIT       ;BLT: Branch if it is < 1 Screen Width
                SBC   #BASL          ;Else, Subtract 1 Screen Width & Add a Line
                PHA                  ;Push Reduced HTAB Value
                JSR   CRDO           ;Print a Carriage <Return> Character
                PLA                  ;Pull Reduced HTAB Value
                JMP   HTABLOOP       ;LOOP Until it is < 1 Screen Width

HTABEXIT        STA   CH             ;Set Cursor Horizontal Displacement
                RTS                  ;Return to Caller

; ==============================================================================
; Someone's initials?  K?  R?  W?  Richard Weiland?
; ==============================================================================
; IIRC, I read, or heard somewhere, long ago, that this was a plea inserted by
; one of the authors because he had cancer, meaning: "Kill Ric Weiland!" 
; 
; RIP: Richard W. "Ric" Weiland (April 21, 1953 - June 24, 2006)
; 
; But, it is not in any of these . . .
; 
; References: 
; 
; Applesoft BASIC <https://en.wikipedia.org/wiki/Applesoft_BASIC>
; Ric Weiland <https://en.wikipedia.org/wiki/Ric_Weiland>    <--[Most likely!]
; Steve Wozniak <https://en.wikipedia.org/wiki/Steve_Wozniak>
; Randy Wigginton <https://en.wikipedia.org/wiki/Randy_Wigginton>
; ==============================================================================
KRW             DFB "K"      ; Someone's initials?  K?R?W?
                DFB "R"
                DFB "W"
; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
; ==============================================================================
; Applesoft - End of all Parts
; ==============================================================================
; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
