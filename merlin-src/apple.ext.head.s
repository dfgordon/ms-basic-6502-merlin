* applesoft.head: Applesoft header with equates
*
* DFG - In the UB package this was a global header, here
* it is only used by the extension modules.
*
*                 Taken from the Applesoft Disassembly Listing made by
*                 James P. Davis and slightly edited to avoid clashes
*                 with labels in the original Microsoft source code,
*                 and issues with the DASM assembler. 

LOC0      EQU $00    ; Preset to JMP OpCode [$4C]
LOC1      EQU $01    ; Address bytes for the JMP here
LOC4      EQU $04    ; Address bytes for another JMP
DATAFLG   EQU $13    ; Applesoft DATA statement flag
HSHAPE    EQU $1A    ; Applesoft Hi-Res Screen Byte Pointer
HCOLOR1   EQU $1C    ; Applesoft Hi-Res Color Mask
HCOUNT    EQU $1D    ; Applesoft Hi-Res Line Step
WNDLFT    EQU $20    ; Left Column of Scroll Window
WNDWDTH   EQU $21    ; Width of Scroll Window
WNDTOP    EQU $22    ; Top of Scroll Window
WNDBTM    EQU $23    ; Bottom of Scroll Window
CH        EQU $24    ; Cursor horizontal displacement
CV        EQU $25    ; Cursor vertical   displacement
GBASL     EQU $26    ; Graphics Base Address, Low
GBASH     EQU $27    ; Graphics Base Address, High
BASL      EQU $28    ; Text Base Address, Low
BASH      EQU $29    ; Text Base Address, High
BAS2L     EQU $2A    ; Scrolling Destination Line Pointer, Low
BAS2H     EQU $2B    ; Scrolling Destination Line Pointer, High
CHKSUM    EQU $2E    ; Cassette checksum
FORMAT    EQU $2E    ; Disassembler Instruction Display
H2        EQU $2C    ; Right End of Horizontal Line (HLINE)
LMNEM     EQU $2C    ; Instruction Display Mnemonic Left Byte
RMNEM     EQU $2D    ; Instruction Display Mnemonic Right Byte
V2        EQU $2D    ; Bottom End of Vertical Line (VLINE)
MASK      EQU $2E    ; Lo-Res Graphics Color Mask (Apple IIc)
LASTIN    EQU $2F    ; Cassette Input Voltage Change Detector
LENGTH    EQU $2F    ; Disassembler Instruction Display Length
HMASK     EQU $30    ; Graphics On-the-Fly Color Bit Mask Safe
MODE      EQU $31    ; Monitor Mode Flag
INVFLG    EQU $32    ; Text Mask (Normal=$FF, Flash=$7F, Inv=$3F)
PROMPT    EQU $33    ; Command Prompt Character
YSAV      EQU $34    ; Y-Reg Safe For Monitor Command Processing
YSAV1     EQU $35    ; Y-Reg Safe; Save across JSR VIDOUT/VIDWAIT
CSWL      EQU $36    ; Character Output Hook, Low
KSWL      EQU $38    ; Character  Input Hook, Low
PCL       EQU $3A    ; Program Counter Safe, Low
PCH       EQU $3B    ; Program Counter Safe, High
A1L       EQU $3C    ; Monitor General Purpose 16 bit Register A1, Low
A1H       EQU $3D    ; Monitor General Purpose 16 bit Register A1, High
A2L       EQU $3E    ; Monitor General Purpose 16 bit Register A2, Low
A2H       EQU $3F    ; Monitor General Purpose 16 bit Register A2, High
A3L       EQU $40    ; Monitor General Purpose 16 bit Register A3, Low
A3H       EQU $41    ; Monitor General Purpose 16 bit Register A3, High
A4L       EQU $42    ; Monitor General Purpose 16 bit Register A4, Low
A4H       EQU $43    ; Monitor General Purpose 16 bit Register A4, High
A5L       EQU $44    ; Monitor General Purpose  8 bit Register A5
ACC       EQU $45    ; A-Reg Safe
XREG      EQU $46    ; X-Reg Safe (Index Register X)
YREG      EQU $47    ; Y-Reg Safe (Index Register Y)
STATUS    EQU $48    ; P-Reg Safe (Status Register)
SPNT      EQU $49    ; S-Reg Safe (Stack Pointer)
SAVE6502  EQU $4A    ; 6502 Registers Safe (Save Locations)+5
RNDL      EQU $4E    ; Keyin Random Counter Value, Low
RNDH      EQU $4F    ; Keyin Random Counter Value, High
DSTPTR    EQU $60    ; Move Strings Destination Pointer
OLDTEXT   EQU $79    ; Applesoft Old Text Pointer
ARYPTR    EQU $94    ; Copy Pointer: Highest Destination Address + 1
HGRDX     EQU $D0    ; Hi-Res Drawing Horizontal X-Position
HGRDY     EQU $D2    ; Hi-Res Drawing  Vertical  Y-Position
HGRQUAD   EQU $D3    ; Hi-Res Graphics Drawing Quadrant
HGRE      EQU $D4    ; Used in Hi-Res Graphics Drawing
AUTORUN   EQU $D6    ; AutoRun/Lock: No User Access If >=$80
ERRFLG    EQU $D8    ; ONERR GOTO is Active If = #$80
ERRLIN    EQU $DA    ; Applesoft Line# Where ERROR Occurred
ERRPOS    EQU $DC    ; Applesoft Error Handler TXTPTR Safe
ERRNUM    EQU $DE    ; Current Applesoft Error Number Safe
ERRSTK    EQU $DF    ; Applesoft Stack Ptr before Error Safe
HGRX      EQU $E0    ; Hi-Res Graphics X-Coordinate (H-POSN)
HGRY      EQU $E2    ; Hi-Res Graphics Y-Coordinate (V-POSN)
HGRCOLOR  EQU $E4    ; Hi-Res Graphics Color Flag/Safe
HGRHORIZ  EQU $E5    ; Hi-Res Byte Horiz. Index from GBASL,H
HGRPAGE   EQU $E6    ; Hi-Res Base Page (HPg1=$20, HPg2=$40)
HGRSCALE  EQU $E7    ; Hi-Res Graphics Drawing Scale Factor
HGRSHPTR  EQU $E8    ; Hi-Res Graphics Shape Pointer
HGRCLSN   EQU $EA    ; Hi-Res Graphics Collision Counter
FIRST     EQU $F0    ; Lo-Res Plot Coordinates
SPDBYT    EQU $F1    ; Text Output Speed Limiter
TRCFLG    EQU $F2    ; Trace OFF/ON Flag (<128/>127)~(bit-7)
FLASHBIT  EQU $F3    ; Flash Text? (Flash=$40, Else=$00)
TXTPSV    EQU $F4    ; Applesoft Char/Token Pointer Safe
CURLSV    EQU $F6    ; Applesoft Current Line Safe
REMSTK    EQU $F8    ; Stack Ptr Before Each Statement Safe
HGRROT    EQU $F9    ; Hi-Res Graphics Rotation Value
FOUTBUFF  EQU $FF    ; Start String at STACK-1 ($FF)

STACK     EQU $100   ; 6502 Microprocessor Stack
LINEIMAG  EQU $1FB   ; Program's New Line Image (should be zero)

GOBRKV    EQU $3EF   ; Set by DOS to JMP for User BRK Vector
BRKV      EQU $3F0   ; Address L, H of User BRK Vector
SOFTEV    EQU $3F2   ; Soft Entry (Warm Start) Vector
PWREDUP   EQU $3F4   ; Power-Up Reset CHKSUM [(SOFTEV+1)EOR #$A5]
AMPERV    EQU $3F5   ; Ampersand '&' Command vector (JMP)
USRADDR   EQU $3F8   ; Monitor User Command (Ctrl-Y) Vector
NMI       EQU $3FB   ; Non-Maskable Interrupt (NMI) Vector
IRQADDR   EQU $3FE   ; Address of IRQ Handler
MSLOT     EQU $7F8   ; Slot Number ($CS) of Peripheral Card

LINE1     EQU $400   ; Text Screen Start Address
PRGMEM    EQU $800   ; Program memory start = 2nd page of text screen
HGR1SCRN  EQU $2000  ; ~$3FFF: Hi-Res Screen Pg.1 (Base-Address)
HGR2SCRN  EQU $4000  ; ~$5FFF: Hi-Res Screen Pg.2 (Base-Address)

NCMPOS    EQU 0
SCRSIZE   EQU $30
CTRLCH    EQU $83
BELL_H    EQU $87
BSH       EQU $88
LFH       EQU $8A    ; High ASCII Ctrl-J: Line Feed
RTNH      EQU $8D    ; High ASCII Ctrl-M: Carriage Return
CTRLSH    EQU $93
PICK      EQU $95    ; Right-Arrow Key Code: Ctrl-U (NAK)
CTRLXH    EQU $98
ESCH      EQU $9B
CIOPG     EQU $FD
BADRESP   EQU $FE    ; error code for 'Bad Response'
DELETE    EQU $FF
HGRHIGH   EQU 192    ; Hi-Res Graphics Screen Height: 192 Pixels
HGRWIDE   EQU 280    ; Hi-Res Graphics Screens Width: 280 Pixels

IOADR    EQU $C000   ; Hardware I/O Addresses & Soft Switches
KBD      EQU $C000
KBDSTRB  EQU $C010
TAPEOUT  EQU $C020
SPKR     EQU $C030
TXTOFF   EQU $C050
TXTON    EQU $C051
MIXOFF   EQU $C052
MIXON    EQU $C053
TXTPAGE1 EQU $C054
TXTPAGE2 EQU $C055
LORES    EQU $C056
HIRES    EQU $C057
AN0OFF   EQU $C058
AN1OFF   EQU $C05A
AN2ON    EQU $C05D
AN3ON    EQU $C05F
TAPEIN   EQU $C060
PADDL0   EQU $C064
PTRIG    EQU $C070
CLRROM   EQU $CFFF

; end of applesoft.head
