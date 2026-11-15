* Dummy section to generate zero-page symbols for non-Apple cases.
* Does not include Apple conditionals.
* If the toolchains advance and we want to recombine all the ZP,
* use one of the apple files as the basis, not this one.

         DUM   $0000

         DO    REALIO#valPET
START    JMP   INIT       ; INITIALIZE - SETUP CERTAIN LOCATIONS
                          ; AND DELETE FUNCTIONS IF NOT NEEDED,
                          ; AND CHANGE THIS TO "JMP READY"
                          ; IN CASE USER RESTARTS AT LOC ZERO.
RDYJSR   JMP   INIT       ; CHANGED TO "JMP STROUT" BY "INIT"
                          ; TO HANDLE ERRORS.
ADRAYI   DA    AYINT      ; STORE HERE THE ADDR OF THE
                          ; ROUTINE TO TURN THE FAC INTO A
                          ; TWO BYTE SIGNED INTEGER IN [Y,A]
ADRGAY   DA    GIVAYF     ; STORE HERE THE ADDR OF THE
                          ; ROUTINE TO CONVERT [Y,A] TO A FLOATING
                          ; POINT NUMBER IN THE FAC.
         FIN

         DO    ROMSW
USRPOK   JMP   FCERR      ; SET UP ORIG BY INIT.
         FIN

                          ;
                          ; THIS IS THE "VOLATILE" STORAGE AREA AND NONE OF IT
                          ; CAN BE KEPT IN ROM. ANY CONSTANTS IN THIS AREA CANNOT
                          ; BE KEPT IN A ROM, BUT MUST BE LOADED IN BY THE
                          ; PROGRAM INSTRUCTIONS IN ROM.
                          ;
                          ; --- GENERAL RAM ---:

         DO    swPET
CHANNL   DS    1
         FIN
         DO    swOSI+swPET
NULCNT   DS    1
TRMPOS   DS    1
LINWID   DS    1
NCMWID   DS    1
LINNUM   DFB   0,44
BUF      DS    BUFLEN
         FIN

CHARAC   DS    1          ; A DELIMITING CHARACTER.
INTEGR   EQU   CHARAC     ; A ONE-BYTE INTEGER FROM "QINT".
ENDCHR   DS    1          ; THE OTHER DELIMITING CHARACTER.
COUNT    DS    1          ; A GENERAL COUNTER.

                          ; --- FLAGS ---:

DIMFLG   DS    1          ; IN GETTING A POINTER TO A VARIABLE
                          ; IT IS IMPORTANT TO REMEMBER WHETHER IT
                          ; IS BEING DONE FOR "DIM" OR NOT.
                          ; DIMFLG AND VALTYP MUST BE
                          ; CONSECUTIVE LOCATIONS.
KIMY     EQU   DIMFLG     ; PLACE TO PRESERVE Y DURING OUT.
VALTYP   DS    1          ; THE TYPE INDICATOR.
                          ; 0=NUMERIC 1=STRING.
         DO    INTPRC
INTFLG   DS    1          ; TELLS IF INTEGER.
         FIN
DORES    DS    1          ; WHETHER CAN OR CAN'T CRUNCH RES'D WORDS.
                          ; TURNED ON WHEN "DATA"
                          ; BEING SCANNED BY CRUNCH SO UNQUOTED
                          ; STRINGS WON'T BE CRUNCHED.
GARBFL   EQU   DORES      ; WHETHER TO DO GARBAGE COLLECTION.
SUBFLG   DS    1          ; FLAG WHETHER SUB'D VARIABLE ALLOWED.
                          ; "FOR" AND USER-DEFINED FUNCTION
                          ; POINTER FETCHING TURN
                          ; THIS ON BEFORE CALLING "PTRGET"
                          ; SO ARRAYS WON'T BE DETECTED.
                          ; "STKINI" AND "PTRGET" CLEAR IT.
                          ; ALSO DISALLOWS INTEGERS THERE.
INPFLG   DS    1          ; FLAGS WHETHER WE ARE DOING "INPUT"
                          ; OR "READ".
TANSGN   DS    1          ; USED IN DETERMINING SIGN OF TANGENT.
         DO    REALIO
CNTWFL   DS    1          ; SUPPRESS OUTPUT FLAG.
         FIN
                          ; NON-ZERO MEANS SUPPRESS.
                          ; RESET BY "INPUT", READY AND ERRORS.
                          ; COMPLEMENTED BY INPUT OF ^O.

* --- RAM DEALING WITH TERMINAL HANDLING ---

         DO    EXTIO*{swPET=0}
CHANNL   DS    1          ; HOLDS CHANNEL NUMBER.
         FIN
         DO    NULCMD*{swOSI=0}
NULCNT   DFB   0          ; NUMBER OF NULLS TO PRINT.
         FIN
         DO    {swOSI=0}*{{REALIO=valPET}=0} ; Merlin 32 is not letting us use REALIO#valPET
TRMPOS   DS    1          ; POSITION OF TERMINAL CARRIAGE.
         FIN
         DO    swOSI+swPET=0
LINWID   DFB   LINLEN    ; LENGTH OF LINE (WIDTH).
NCMWID   DFB   NCMPOS     ; POSITION BEYOND WHICH THERE ARE
                          ; NO MORE FIELDS.
         FIN

         DO    swOSI+swPET=0
LINNUM   ENT
         DFB   0          ; LOCATION TO STORE LINE NUMBER BEFORE BUF
                          ; SO THAT "BLTUC" CAN STORE IT ALL AWAY AT
                          ; ONCE.
         DFB   44         ; A COMMA (PRELOAD OR FROM ROM)
                          ; USED BY INPUT STATEMENT SINCE THE
                          ; DATA POINTER ALWAYS STARTS ON A
                          ; COMMA OR TERMINATOR.
         FIN

* NOTE: this late allocation of a zero page input buffer may not work to
* ===== get a matching zero page layout. OSI BASIC-in-ROM is one example.
* DFG - changed this logic to allow REALIO=3 && !PET to work

         DO    {BUFPAG.swOSI.swPET}=0
BUF      DS    BUFLEN     ; TYPE IN STORED HERE.
         FIN
                          ; DIRECT STATEMENTS EXECUTE OUT OF
                          ; HERE. REMEMBER "INPUT" SMASHES BUF.
                          ; MUST BE ON PAGE ZERO
                          ; OR ASSIGNMENT OF STRING
                          ; VALUES IN DIRECT STATEMENTS WON'T COPY
                          ; INTO STRING SPACE -- WHICH IT MUST.
                          ; N.B. TWO NONZERO BYTES MUST
                          ; PRECEDE "BUFLNM".

                          ; --- STORAGE FOR TEMPORARY THINGS ---:

TEMPPT   DS    1          ; POINTER AT FIRST FREE TEMP DESCRIPTOR.
                          ; INITIALIZED TO POINT TO TEMPST.
LASTPT   DS    2          ; POINTER TO LAST-USED STRING TEMPORARY.
TEMPST   DS    STRSIZ*NUMTMP ; STORAGE FOR NUMTMP TEMP DESCRIPTORS.
INDEX1   DS    2          ; INDEXES.
INDEX    EQU   INDEX1
INDEX2   DS    2
RESHO    DS    1          ; RESULT OF MULTIPLIER AND DIVIDER.
         DO    ADDPRC
RESMOH   DS    1          ; ONE MORE BYTE.
         FIN
RESMO    DS    1
RESLO    DS    1
ADDEND   EQU   RESMO      ; TEMPORARY USED BY "UMULT".
         DFB   0          ; OVERFLOW FOR RES.

                          ; --- POINTERS INTO DYNAMIC DATA STRUCTURES ---:

TXTTAB   DS    2          ; POINTER TO BEGINNING OF TEXT.
                          ; DOESN'T CHANGE AFTER BEING
                          ; SETUP BY "INIT".
VARTAB   DS    2          ; POINTER TO START OF SIMPLE
                          ; VARIABLE SPACE.
                          ; UPDATED WHENEVER THE SIZE OF THE
                          ; PROGRAM CHANGES, SET TO [TXTTAB]
                          ; BY "SCRATCH" ("NEW").
ARYTAB   DS    2          ; POINTER TO BEGINNING OF ARRAY
                          ; TABLE.
                          ; INCREMENTED BY 6 WHENEVER
                          ; A NEW SIMPLE VARIABLE IS FOUND, AND
                          ; SET TO [VARTAB] BY "CLEARC".
STREND   DS    2          ; END OF STORAGE IN USE.
                          ; INCREASED WHENEVER A NEW ARRAY
                          ; OR SIMPLE VARIABLE IS ENCOUNTERED.
                          ; SET TO [VARTAB] BY "CLEARC".
FRETOP   DS    2          ; TOP OF STRING FREE SPACE.
FRESPC   DS    2          ; POINTER TO NEW STRING.
MEMSIZ   DS    2          ; HIGHEST LOCATION IN MEMORY.

                          ; --- LINE NUMBERS AND TEXTUAL POINTERS ---:

CURLIN   DS    2          ; CURRENT LINE #.
                          ; SET TO 0,255 FOR DIRECT STATEMENTS.
OLDLIN   DS    2          ; OLD LINE NUMBER (SETUP BY ^C,"STOP"
                          ; OR "END" IN A PROGRAM).
POKER    EQU   LINNUM     ; SET UP LOCATION USED BY POKE.
                          ; TEMPORARY FOR INPUT AND READ CODE
OLDTXT   DS    2          ; OLD TEXT POINTER.
                          ; POINTS AT STATEMENT TO BE EXEC'D NEXT.
DATLIN   DS    2          ; DATA LINE # -- REMEMBER FOR ERRORS.
DATPTR   DS    2          ; POINTER TO DATA. INITIALIZED TO POINT
                          ; AT THE ZERO IN FRONT OF [TXTTAB]
                          ; BY "RESTORE" WHICH IS CALLED BY "CLEARC".
                          ; UPDATED BY EXECUTION OF A "READ".
INPPTR   DS    2          ; THIS REMEMBERS WHERE INPUT IS COMING FROM.

                          ; --- STUFF USED IN EVALUATIONS ---:

VARNAM   DS    2          ; VARIABLE'S NAME IS STORED HERE.
VARPNT   DS    2          ; POINTER TO VARIABLE IN MEMORY.
FDECPT   EQU   VARPNT     ; POINTER INTO POWER OF TENS OF "FOUT".
FORPNT   DS    2          ; A VARIABLE'S POINTER FOR "FOR" LOOPS
                          ; AND "LET" STATEMENTS.
LSTPNT   EQU   FORPNT     ; PNTR TO LIST STRING.
ANDMSK   EQU   FORPNT     ; THE MASK USED BY WAIT FOR ANDING.
EORMSK   EQU   FORPNT+1   ; THE MASK FOR EORING IN WAIT.
OPPTR    DS    2          ; POINTER TO CURRENT OP'S ENTRY IN "OPTAB".
* DFG - VARTXT equivalence has been delayed until later
OPMASK   DS    1          ; MASK CREATED BY CURRENT OPERATOR.
DOMASK   EQU   TANSGN     ; MASK IN USE BY RELATION OPERATIONS.
DEFPNT   DS    2          ; POINTER USED IN FUNCTION DEFINITION.
GRBPNT   EQU   DEFPNT     ; ANOTHER USED IN GARBAGE COLLECTION.
DSCPNT   DS    2          ; POINTER TO A STRING DESCRIPTOR.
         DO    ADDPRC     ; FOR TEMPF3.
         DS    1
         FIN
DSCLEN                    ; temporary for string descriptor length
FOUR6    DFB   STRSIZ     ; VARIABLE CONSTANT USED BY GARB COLLECT.

                          ; --- ET CETERA ---:

JMPER    DS   3
SIZE     EQU   JMPER+1
OLDOV    EQU   JMPER+2    ; THE OLD OVERFLOW.
TEMPF3   EQU   DEFPNT     ; A THIRD FAC TEMPORARY (4 BYTES).
TEMPF1
         DO    ADDPRC     ; FOR TEMPF1S EXTRA BYTE.
         DFB   0
         FIN
HIGHDS   DS    2          ; DESINATION OF HIGHEST ELEMENT IN BLT.
HIGHTR   DS    2          ; SOURCE OF HIGHEST ELEMENT TO MOVE.
TEMPF2
         DO    ADDPRC     ; FOR TEMPF2S EXTRA BYTE.
         DFB   0
         FIN
LOWDS    DS    2          ; LOCATION OF LAST BYTE TRANSFERRED INTO.
LOWTR    DS    2          ; LAST THING TO MOVE IN BLT.
ARYPNT   EQU   HIGHDS     ; A POINTER USED IN ARRAY BUILDING.
GRBTOP   EQU   LOWTR      ; A POINTER USED IN GARBAGE COLLECTION.
DECCNT   EQU   LOWDS      ; NUMBER OF PLACES BEFORE DECIMAL POINT.
TENEXP   EQU   LOWDS+1    ; HAS A DPT BEEN INPUT?
DPTFLG   EQU   LOWTR      ; BASE TEN EXPONENT.
                          ;     .IF !PET
EXPSGN   EQU   LOWTR+1    ; SIGN OF BASE TEN EXPONENT.
                          ;     .ENDIF

                          ; --- THE FLOATING ACCUMULATOR ---:

FAC
FACEXP   DFB   0
FACHO    DFB   0          ; MOST SIGNIFICANT BYTE OF MANTISSA.
         DO    ADDPRC
FACMOH   DFB   0          ; ONE MORE.
         FIN
FACMO    DFB   0          ; MIDDLE ORDER OF MANTISSA.
FACLO    DFB   0          ; LEAST SIG BYTE OF MANTISSA.
FACSGN   DFB   0          ; SIGN OF FAC (0 OR -1) WHEN UNPACKED.
SGNFLG   DFB   0          ; SIGN OF FAC IS PRESERVED BERE BY "FIN".
DEGREE   EQU   SGNFLG     ; A COUNT USED BY POLYNOMIALS.
DSCTMP   EQU   FAC        ; THIS IS WHERE TEMP DESCS ARE BUILT.
INDICE   EQU   FACMO      ; INDICE IS SET UP HERE BY "QINT".
BITS     DFB   0          ; SOMETHING FOR "SHIFTR" TO USE.

                          ; --- THE FLOATING ARGUMENT (UNPACKED) ---:

ARGEXP   DFB   0
ARGHO    DFB   0
         DO    ADDPRC
ARGMOH   DFB   0
         FIN
ARGMO    DFB   0
ARGLO    DFB   0
ARGSGN   DFB   0

ARISGN   DFB   0          ; A SIGN REFLECTING THE RESULT.
FACOV    DFB   0          ; OVERFLOW BYTE OF THE FAC.
STRNG1   EQU   ARISGN     ; POINTER TO A STRING OR DESCRIPTOR.

FBUFPT   DS    2          ; POINTER INTO FBUFFR USED BY FOUT.
BUFPTR   EQU   FBUFPT     ; POINTER TO BUF USED BY "CRUNCH".
STRNG2   EQU   FBUFPT     ; POINTER TO STRING OR DESC.
POLYPT   EQU   FBUFPT     ; POINTER INTO POLYNOMIAL COEFFICIENTS.
CURTOL   EQU   FBUFPT     ; ABSOLUTE LINEAR INDEX IS FORMED HERE.

* PAGE
* SUBTTL     RAM CODE.

* THIS CODE GETS CHANGED THROUGHOUT EXECUTION.
* IT IS MADE TO BE FAST THIS WAY.
* ALSO, [X] AND [Y] ARE NOT DISTURBED
*
* "CHRGET" USING [TXTPTR] AS THE CURRENT TEXT PNTR
* FETCHES A NEW CHARACTER INTO ACCA AFTER INCREMENTING [TXTPTR]
* AND SETS CONDITION CODES ACCORDING TO WHAT'S IN ACCA.
*       NOT C=  NUMERIC   ("0" THRU "9")
*       Z=      ":" OR END-OF-LINE (A NULL)
*
* [ACCA] = NEW CHAR.
* [TXTPTR]=[TXTPTR]+1
*
* THE FOLLOWING EXISTS IN ROM IF ROM EXISTS AND IS LOADED
* DOWN HERE BY INIT. OTHERWISE IT IS JUST LOADED INTO THIS
* RAM LIKE ALL THE REST OF RAM IS LOADED.
* DFG - Merlin 32 will select absolute addressing in this dummy
* section, so we have to replace two INC instructions with data,
* the replacement is harmless in a dummy section.
CHRGET   DS    2          ; INC   CHRGET+7   ; INCREMENT THE WHOLE TXTPTR.
         BNE   CHRGOT
         DS    2          ; INC   CHRGET+8
CHRGOT   LDA   60000      ; A LOAD WITH AN EXT ADDR.
TXTPTR   EQU   CHRGOT+1
         CMP   #$20       ; SKIP SPACES.
         BEQ   CHRGET
QNUM     CMP   #':'       ; IS IT A ":"?
         BCS   CHRRTS     ; IT IS .GE. ":"
         SEC
         SBC   #'0'       ; ALL CHARS .GT. "9" HAVE RET'D SO
         SEC
         SBC   #256-'0'   ; SEE IF NUMERIC.
                          ; TURN CARRY ON IF NUMERIC.
                          ; ALSO, SET Z IF NULL.
CHRRTS   RTS              ; RETURN TO CALLER.

RNDX     DFB   128        ; LOADED OR FROM ROM.
         DFB   79         ; THE INITIAL RANDOM NUMBER.
         DFB   199
         DFB   82
         DO    ADDPRC     ; ONE MORE BYTE.
         DFB   89
         FIN

         DEND
