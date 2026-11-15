* This is the Apple F8 ROM code, also known as the Monitor ROM.
* This is derived from the UB package, which in turn is derived
* from the disassembly of James P. Davis.

         XC    OFF
         REL
         DSK   F8ROM.L
 
         PUT   apple.ext.head ; from UB, which in turn, is from Davis

* DFG - This is defined separately in MSB6502, if it changes there
* it must be changed here too. We would prefer to import, but there
* is a Merlin 32 issue with importing equivalences.
BUF      EQU   512

* DFG - Imports from MSB6502
         EXT   BASIC,BASIC2

* DFG - Exports to MSB6502
         ENT   HOME,GETLN,COUT,MON_WAIT,SCRN,PREAD

* DFG - Exports to Apple Extensions
         ENT   INPORT,OUTPORT
         ENT   MON_PLOT,HLINE,VLINE
         ENT   COLSET,TABV,GRSET,TXTSET
         ENT   MON_WRITE,MON_READ,RD2BIT,MON_READ2

; <---[$F8 Page Boundary]
; 
; ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ
; ==============================================================================
; ROM Space ($F800-$FFFF): ROM Socket $F8 on a real Apple II Plus. 
; ==============================================================================
; ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ
; 
; ==============================================================================
; ORIGIN  EQU $F800;Old Monitor ROM or New Autostart Monitor ROM Start Address.
;                  ;Or, Language Card Additional ROM/RAM: 
;                  ;When Language Card {ROM/RAM} is Deselected, {RAM/ROM} on
;                  ;Card is Active, {respectively}.
; ==============================================================================
; 
; 
; ==============================================================================
; New Monitor ROM (Modified AutoStart Image):
; ==============================================================================
; Apple II Monitor II by Steve Wozniak.  Modified Nov 1978 by John A
; Copyright 1978 by Apple Computer, Inc.  All Rights Reserved. 
; ==============================================================================
; 
; ==============================================================================
; Monitor Low Resolution Graphics Plotting Routines:
; ==============================================================================
; 
; -----------------------------------;Plot a Point on Lo-Res Screen:
;                                    ;[Enter with (A)=Row; (Y)=Column]
MON_PLOT        LSR              ;(A)=(Y-Coordinate/2)
                PHP                  ;Push Status (P-Reg); Save Carry (LSB)
                JSR   GBASCALC       ;Calculate Base Address in GBASL,H
                PLP                  ;Pull Status (P-Reg); Retrieve Carry (LSB)
                LDA   #%00001111     ;Mask $0F if Even
                BCC   RTMASK         ;Branch if LSB (in Carry) is a Zero
                ADC   #%11100000     ;Mask $F0 if Odd; (Adds 1 with Carry Set)
;                                    ;^[($0F+$01)+($E0) = ($10)+($E0) = ($F0)]
RTMASK          STA   MASK           ;Store AND Mask (for High/Low Nibble)
; 
; -----------------------------------;Plot a Square Point on Lo-Res Screen:
;                                    ;[I/O: (GBASL,H & MASK)=Row; (Y)=Column]
PLOT1           LDA   (GBASL),Y      ;Get Data
                EOR   HMASK          ;XOR with Color; [Set HMASK 1st!]
                AND   MASK           ;AND with Nibble Mask
                EOR   (GBASL),Y      ;XOR with Data
                STA   (GBASL),Y      ;Set Data
                RTS                  ;Return to Caller

; -----------------------------------;Draw Horizontal Line on Lo-Res Screen:
;                                    ;[Enter with (A)=Row; (Y)~(H2)=Column
; Ends]
HLINE           JSR   MON_PLOT       ;Plot Square
; 
; -----------------------------------;Draw Horizontal Line on Lo-Res Screen:
;                                    ;[(GBASL,H & MASK)=Row
;                                    ; (Y)~(H2)=Column Ends]
HLINE1          CPY   H2             ;Done?
                BCS   MON_RTS1       ;YES, Return to Caller
                INY                  ;NO, Advance Index (X-Coordinate)
                JSR   PLOT1          ;Plot Next Square
                BCC   HLINE1         ;Loop; Always Taken
; 
; -----------------------------------;Draw Vertical Line on Lo-Res Screen:
; LOOP                               ;[(A+1+Carry)~(V2)=Row Ends; (Y)=Column]
VLINEZ          ADC   #1             ;(A)=[Next Row (Y-Coordinate)]
; 
; -----------------------------------;Draw Vertical Line on Lo-Res Screen:
;                                    ;[Enter w/ (A)~(V2)=Row Ends; (Y)=Column]
VLINE           PHA                  ;Push Next Row 
                JSR   MON_PLOT       ;Plot Square
                PLA                  ;Pull Next Row
;              vvv ------------------;"Apple II Monitors Peeled" Entry Point:
;              vvv                   ;[(A+1)~(V2)=Row Ends; (Y)=Column]
VLINE2          CMP   V2             ;Done?
                BCC   VLINEZ         ;NO, LOOP
MON_RTS1        RTS                  ;Return to Caller

; -----------------------------------;Clear Full (48 Lines on) Lo-Res Screen:
CLRSCR          LDY   #47            ;Maximize Y for Full Screen
                BNE   CLRSCR2        ;Always Taken

; -----------------------------------;Clear Top (40 Lines on) Lo-Res Screen:
CLRTOP          LDY   #39            ;Maximize Y for Top Screen
; 
; -----------------------------------;Clear Partial Lo-Res Screen:
;                                    ;^[(0~Y) Lines, 40 Columns]
CLRSCR2         STY   V2             ;Store as Bottom Coordinate for VLINE Calls
;              vvv ------------------;"Apple II Monitors Peeled" Entry Point:
;              vvv                   ;^[(0~V2) Lines, 40 Columns]
CLRSCR4         LDY   #39            ;Rightmost X-Coordinate (Column)
; 
; -----------------------------------;Clear Partial Lo-Res Screen:
;                                    ;^[(0~V2) Lines, (0~Y) Columns]
CLRSCR3         LDA   #0             ;Top Coordinate for VLINE Calls
                STA   HMASK          ;Clear Color (to Black)
;              vvv ----------------;"Apple II Monitors Peeled" Entry Point:
;              vvv                 ;Clear Color to whatever HMASK is upon entry
;              vvv                 ;^[(A) Must be Preset to Zero]
CLRSCR5         JSR   VLINE          ;Draw VLINE
                DEY                  ;Next Leftmost X-Coordinate
                BPL   CLRSCR3        ;Loop Until Done
                RTS                  ;Return to Caller

; ==============================================================================
; Calculate Graphics Base Address (BASH,BASL) for Left End of Screen Line Number
; (Not Lo-Res GR Line Number) in A-Reg [Range: (0~23)=($00~$17)=(%00000~%10111)]
; ==============================================================================
; GBASCALC [to set Graphics Base Address (GBASH,GBASL)] is almost identical to
;  BASCALC [to set Text Line Base Address (BASH,BASL)]
; ---------------------------vv-------------------------vv----------vv----vv----
; F847: 48 4A 29 03 09 04 85 27 68 29 18 90 02 69 7F 85 26 0A 0A 05 26 85 26 60
; FBC1: 48 4A 29 03 09 04 85 29 68 29 18 90 02 69 7F 85 28 0A 0A 05 28 85 28 60
; ------------------------------------------------------------------------------
; Note: Indexed Addressing of the Base Address ZP Pointers would allow S/R's 
; to be combined into one S/R with one or two different Entry Points to preset 
; which task is being processed (e.g., GBASL,X & GBASH,X & X=0 or X=2)
; ------------------------------------------------------------------------------
;     GBASL    EQU     $26           ;Graphics Base Address, Low
;     GBASH    EQU     $27           ;Graphics Base Address, High
;     BASL     EQU     $28           ;Text Base Address, Low
;     BASH     EQU     $29           ;Text Base Address, High
; ==============================================================================
; 
; -----------------------------------;Set Graphics Base Address (GBASH,GBASL):
;                                    ;^[RAM Address of Plotting Line Specified]
GBASCALC        PHA                  ;Push (A)=(GR_Line/2)=[(GBASL) for Input]
;                                    ;^[...(A)=(Text Screen Line # {0~23})]
;                                    ;^[...(A)=((Lo-Res Graphics Line #)/2)]
;                                    ;^[GBASH=ABCDEFGH; GBASL=IJKLMNOP]
;              ----------------------;Set Graphics Base Address, High (GBASH):
                LSR              ;Set (A)=(GR_Line/4) [GBASH=0ABCDEFG; C=H]
                AND   #%00000011     ;Generate GBASH=000000FG
                ORA   #%00000100     ;Generate GBASH=000001FG
                STA   GBASH          ;Set Graphics Base Address, High (GBASH)
;              ----------------------;Set Graphics Base Address, Low  (GBASL):
                PLA                  ;Pull (A)=(GBASL=IJKLMNOP)
                AND   #%00011000     ;Generate GBASL=000LM000
                BCC   GBCALC         ;Skip Next Op if Carry is Clear (C=H=0)
                ADC   #%01111111     ;Generate GBASL=I00LM000 (C=H=1: Adds 1)
;                                    ;^[%00011000 + (%01111111 + 1)= %10011000]
;                                    ;^[%00011000 + (%10000000)    = %10011000]
GBCALC          STA   GBASL          ;Set Graphics Base Address, Low  (GBASL)
;                                    ;       ^[GBASL=(000LM000 | I00LM000)]
                ASL              ;Generate GBASL=(00LM0000 = 00LM0000; C=I)
                ASL              ;Generate GBASL=(0LM00000 = 0LM00000; C=0)
                ORA   GBASL          ;Generate GBASL=(0LMLM000 | ILMLM000)
                STA   GBASL          ;Set Graphics Base Address, Low  (GBASL)
;              ----------------------;Now (GBASH,GBASL)=[%0000,01FG,ILML,M000]
; 
;                                    ;------------+---------+---------+
;                                    ; Lo-Res GR Line Base Addresses: |
;                                    ;------------+---------+---------+
;                                    ;            |  GBASH  |  GBASL  |
;                                    ;------------+---------+---------+
;                                    ;  Top 3rd of GR Screen:         |
;                                    ;------------+---------+---------+
;                                    ;$400, 1024, %0000,0100,0000,0000;
;                                    ;$480, 1152, %0000,0100,1000,0000;
;                                    ;$500, 1280, %0000,0101,0000,0000;
;                                    ;$580, 1408, %0000,0101,1000,0000;
;                                    ;$600, 1536, %0000,0110,0000,0000;
;                                    ;$680, 1664, %0000,0110,1000,0000;
;                                    ;$700, 1792, %0000,0111,0000,0000;
;                                    ;$780, 1920, %0000,0111,1000,0000;
;                                    ;------------+---------+---------+
;                                    ;  Middle 3rd of GR Screen:      |
;                                    ;------------+---------+---------+
;                                    ;$428, 1064, %0000,0100,0010,1000;
;                                    ;$4A8, 1192, %0000,0101,1010,1000;
;                                    ;$528, 1320, %0000,0101,0010,1000;
;                                    ;$5A8, 1448, %0000,0100,1010,1000;
;                                    ;$628, 1576, %0000,0110,0010,1000;
;                                    ;$6A8, 1704, %0000,0110,1010,1000;
;                                    ;$728, 1832, %0000,0111,0010,1000;
;                                    ;$7A8, 1960, %0000,0111,1010,1000;
;                                    ;------------+---------+---------+
;                                    ;  Bottom 3rd of GR Screen:      |
;                                    ;------------+---------+---------+
;                                    ;$450, 1104, %0000,0100,0101,0000;
;                                    ;$4D0, 1232, %0000,0100,1101,0000;
;                                    ;$550, 1360, %0000,0101,0101,0000;
;                                    ;$5D0, 1488, %0000,0101,1101,0000;
;                                    ;$650, 1616, %0000,0110,0101,0000;
;                                    ;$6D0, 1744, %0000,0110,1101,0000;
;                                    ;$750, 1872, %0000,0111,0101,0000;
;                                    ;$7D0, 2000, %0000,0111,1101,0000;
;                                    ;------------+---------+---------+
;                                    ;  GBASH,L:  %0000,01FG,ILML,M000;
;                                    ;------------+---------+---------+
; 
; -----------------------------------;Returns: GBASH=000001FG; GBASL=ILMLM000
                RTS                  ;Return to Caller

; ------------------------------------------------------------------------------
; NEXTCOLOR is Not in the New Monitor listing; NXTCOL is the Label here in the
; Old Monitor listing, but it is used elsewhere in this listing; (See below)
; ------------------------------------------------------------------------------
; 
; -----------------------------------;Next Color: Increment Plotting Color by 3
NEXTCOLOR       LDA   HMASK          ;Get Graphics On-the-Fly Color Bit Mask
                CLC                  ;Prepare for Add with Carry
                ADC   #3             ;Advance Plotting Color to Color+3
COLSET          AND   #%00001111     ;Discard High Nibble & Keep Low Nibble
;                                    ;^[Math'ly: Sets Color = 17*A Mod 16]
                STA   HMASK          ;Set Graphics On-the-Fly Color Bit Mask
; --<Undocumented User Entry Point>--;Shift Low Nibble to High Nibble:
NIBLOHI         ASL              ;Make Both Nibbles of Plotting Color Equal
                ASL              ;Shift Low Nibble to High Nibble
                ASL              ;(%####,0000 <-- <-- <-- <-- %0000,####)
                ASL              ;Now High Nibble is what Low Nibble was
                ORA   HMASK          ;OR with Graphics On-the-Fly Color Bit Mask
;                                    ;(%####,0000 OR %0000,#### = %####,####)
                STA   HMASK          ;Set Graphics On-the-Fly Color Bit Mask
                RTS                  ;Return to Caller

; ==============================================================================
; Miniassembler/Disassembler Instruction Display Subroutines
; ==============================================================================
; For an explanation about how this works (sort of), see:
; A 6502 Disassembler from Apple, Dr. Dobbs Journal, 09/76; 
; FTP://Public.Asimov.Net/Pub/Apple_II/Documentation/Programming/6502Assembly/65
; 02%20Disassembler%20-%201976.PDF
; ==============================================================================
; 
; -----------------------------------;Get 4-bit Color at Column,Row Coord's:
;                                    ;[Enter with (A)=Row; (Y)=Column]
SCRN            LSR              ;(A)=(Y-Coordinate/2)
                PHP                  ;Push Status (P-Reg); Save Carry (LSB)
                JSR   GBASCALC       ;Calculate Base Address in GBASL,H
                LDA   (GBASL),Y      ;Get Colors Byte at Column,Row Coordinates
                PLP                  ;Pull Status (P-Reg); Retrieve Carry (LSB)
;                                    ;Get Right or Left Half-Byte on Carry; 
;                                    ;AKA: Low or High Nibble, Respectively:
;                                    ;[SCRN2--Used by Mini-/Dis-Assembler]
SCRN2           BCC   RTMSKZ         ;If Even, use Low Nibble
; --<Undocumented User Entry Point>--;Shift High Nibble to Low Nibble:
NIBHILO         LSR              ;If Odd, use High Nibble
                LSR              ;Shift High Nibble
                LSR              ;... to Low Nibble
                LSR              ;Now Low Nibble is what High Nibble was
RTMSKZ          AND   #%00001111     ;Mask 4-Bit Color at Column,Row Coordinates
                RTS                  ;Return to Caller

; ==============================================================================
; Disassembler Instruction Display Subroutine: Prints Program Counter, followed
; by a Blank; Gets an OpCode; Then Generates FORMAT & LENGTH Bytes: 
; ==============================================================================
; 
; -----------------------------------;Display Instruction Line Address:
INSDS1          LDX   PCL            ;Get Program Counter, Low
                LDY   PCH            ;Get Program Counter, High
                JSR   PRYX2          ;Print Program Counter [(Y,X)={High,Low}]
;                                    ;Followed by a Dash
                JSR   PRBLNK         ;Followed by a Blank (3 Spaces)
; -----------------------------------;Get OpCode, Instruction FORMAT & LENGTH,
;                                    ;& Index into Mnemonic Table:
                LDA   (PCL,X)        ;Get OpCode
INSDS2          TAY                  ;Save OpCode
                LSR              ;Even/Odd Test: Put LSB (Bit 0) into (C)
GET816LEN       BCC   IEVEN          ;Branch if OpCode is (=%#######0) Even
;                                    ;^[OpCode Before Shifting & Rotatng Right]
;              ----------------------;Else, OpCode is (=%#######1) Odd
;                                    ;^[OpCode Before Shifting & Rotatng Right]
;                                    ;& Now (C=1) & (A)=(%0#######):
                ROR              ;Bit 1 Test: Put (C=1) in MSB & LSB in (C)
                BCS   ERR            ;Branch if OpCode is (=%######11) Invalid
;                                    ;^[OpCode Before Shifting & Rotatng Right]
;              ----------------------;Else, OpCode is (=%######01) Odd
;                                    ;^[OpCode Before Shifting & Rotatng Right]
;                                    ;& Now (C=0) & (A)=(%10######):
                CMP   #%10100010     ;Is OpCode a NOP?  (%10001001=$89=137):(?)
;                                    ;^[OpCode Before Shifting & Rotatng Right]
;                                    ;================= FMT1,X ================
;                                    ;(?) =         %10001001=$89=137
;                                    ;LSR =         %01000100=$44=68  ->(C=1)
;                                    ;ROR = (C=1)-> %10100010=$A2=162 ->(C=0)
;                                    ;================= FMT2,X ================
;                                    ;NOP =         %11101010=$EA=234
;                                    ;LSR =         %01110101=$75=117 ->(C=0)
;                                    ;ROR = (C=0)-> %00111010=$3A=58  ->(C=1)
;                                    ;Relative <- = %10011101=$9D=157 ->(C=0)
;                                    ;=========================================
                BEQ   ERR            ;Branch if OpCode is Invalid (=$89)
;              ----------------------;Else, OpCode is (=%######01) Odd & Valid
;                                    ;& Now (C=?) & (A)=(%10######):
                AND   #%10000111     ;Mask Bits: Keep Sign & 3 LSBs
;                                    ;& Discard the Rest [(A)=(%10000###)]
IEVEN           LSR              ;Put LSB into Carry for Left/Right Test
;                                    ;Also Sets (A)=(A/2) for Absolute,X-Index:
                TAX                  ;Set Absolute,X-Index [(X=A)=(%0#######)]
;                                    ;^[For Odd OpCodes: (X=A)=(%010000##)=
;                                    ;{(%01000000=$40=64)~(%01000011=$43=67)}]
                LDA   FMT1,X         ;Get Instruction Display Format Index Byte
;                                    ;^[See also (below): FMT1 NOTE]
                JSR   SCRN2          ;Get Right or Left Nibble Based on Carry
                BNE   GETFMT         ;Branch if Low Nibble <> 0: OpCode is Valid
ERR             LDY   #$80           ;Else, Substitute $80 for Invalid OpCodes
                LDA   #0             ;Clear Accumulator
GETFMT          TAX                  ;Set Absolute,X-Index
                LDA   FMT2,X         ;Get Instruction Display Print Format Byte
;                                    ;^[See also (below): FMT1 NOTE]
                STA   FORMAT         ;Save for Address Field Formatting
                AND   #%00000011     ;Mask to Get 2-Bit LENGTH (OpCodeBytes-1:
;                                    ; 0=1 Byte, 1=2 Byte, 2=3 Byte)
; 
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;  *** [The following section is different in the Apple IIE Autostart ROM] ***
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; 
                STA   LENGTH         ;Save Length (Number of OpCode Bytes -1)
; 
; ==============================================================================
; Form an Index into the Mnemonic Table from an OpCode: (A)=[(OpCode)-->(Index)]
; ==============================================================================
;     OpCode -> Index   for OpCd-Form; Example OpCodes & Exceptions
; -- -------- --------- --- ---------- -----------------------------------------
; 1) 1XXX1010->00101XXX  ~  %1###1010; $8A,$9A,$AA,$BA,$CA,$DA,$EA,$FA.
; 2) XXXYYY01->00111XXX  ~  %######01; Not $#3~$#4; $#1,$#5,$#9,$#D.
; 3) XXXYYY10->00110XXX  ~  %######10; Not $#0~$#1; $#2,$#6,$#A,$#E.
; 4) XXXYY100->00100XXX  ~  %#####100; Not $#0~$#3; $#4,$#C.
; 5) XXXXX000->000XXXXX  ~  %#####000; Not $#1~$#7; $#0,$#8.
; -- -------- --------- --- ---------- -----------------------------------------
;    ^^^^^^^^ Bits: X's, 0's, & 1's are Shifted Right; Y's are Discarded. 
;             #'s are Bits: 0 or 1; or Hexadecimal Numbers: 0~9,A~F
; ==============================================================================
; 
                TYA                  ;Get Saved {Valid or Invalid ($80)} OpCode
                AND   #%10001111     ;Mask for 6502 Bit Mapping Test (%1###1010)
                TAX                  ;Save Masked Byte for Test
                TYA                  ;Get Saved OpCode Again
                LDY   #3             ;Set Loop Counter
                CPX   #%10001010     ;Is Masked Byte for an OpCode=(%1###1010)?
;                                    ;                   ^[1 in Chart above]^
                BEQ   MNNDX3         ;YES, Form an Index into the Mnemonic Table
;                                    ;NO, Masked Byte's for OpCode<>(%1###1010)
;                                    ;                  ^[2~5 in Chart above]^
MNNDX1          LSR              ;Even/Odd Test: Put LSB into (C)
;              ----------------------;Shift until LSB was Odd or (Y) = 0:
                BCC   MNNDX3         ;Branch if LSB was Even; Else:
;              ----------------------;LSB was Odd, Discard & Set Bits:
                LSR              ;Put Next LSB into Carry (C) [Discarded]
MNNDX2          LSR              ;Put Next LSB into Carry (C) [Discarded]
                ORA   #%00100000     ;Set Current Bit 5
                DEY                  ;Reduce Loop Counter
                BNE   MNNDX2         ;Loop until Y=0
                INY                  ;Advance to Compensate for Next Reduction 
;              ----------------------;LSB was Even, Check Next:
MNNDX3          DEY                  ;Reduce Loop Counter
                BNE   MNNDX1         ;Loop until Y=0; Else:
;              ----------------------;Now: (A) = Index into the Mnemonic Table;
;                                    ;     (X) = Masked OpCode; & (Y) = 0
                RTS                  ;Return to Caller

; ------------------------------------------------------------------------------
                DS    3,$FF          ;Filler

; ==============================================================================
; Disassemble & Print Instruction at Program Counter
; ==============================================================================
; 
INSTDSP         JSR   INSDS1         ;Display Instruction Line Address &
;                                    ;Get Instruction FORMAT & LENGTH, & MTI:
                PHA                  ;Push/Save Index into Mnemonic Table ^
;              ----------------------;Print (1-3) OpCode Bytes [as Hex: "## "]
;                                    ;(in a 12 Char Field, Ending w/ Spaces)
;                                    ;=[4 Fields of 3 Characters each]:
PRNTOP          LDA   (PCL),Y        ;Get Byte at (Program Counter),Y
                JSR   PRBYTE         ;Print (A) as Two-Digit Hex Number
                LDX   #1             ;Prepare to Print One Space
PRNTBL          JSR   PRBL2          ;Print a Blank [(X) Spaces]
                CPY   LENGTH         ;Subtract (Number of OpCode Bytes -1)
                INY                  ;Advance OpCode Bytes Counter
                BCC   PRNTOP         ;BLT: Loop if Byte Count < LENGTH (^)
;                                    ;End 12 Char Field w/ Spaces; =[4*3]:
                LDX   #3             ;Get Blank Char Count (for No OpCode Byte)
;                                    ;^[Also used below for Mnemonic Chars]
                CPY   #4             ;Ending with (Y) Blanks of (X) Spaces each
                BCC   PRNTBL         ;BLT: Loop if OpCode Bytes Counter < 4
;              ----------------------;Fetch 3-Char Mnemonic (Packed In 2-Bytes)
                PLA                  ;Pull/Retrieve Index into Mnemonic Table
                TAY                  ;Set Indirect Addressing Index
                LDA   MNEML,Y        ;Get 1st Packed Byte of Mnemonic
                STA   LMNEM          ;Set Left  (ZP) Byte of Mnemonic
                LDA   MNEMR,Y        ;Get 2nd Packed Byte of Mnemonic
                STA   RMNEM          ;Set Right (ZP) Byte of Mnemonic
; 
; ------------------------------------------------------------------------------
; Note about NXTCOL here & there: NXTCOL is the Label used here in the New
; Monitor listing; NXTCOL was used elsewhere in the Old Monitor listing (See
; NEXTCOLOR above); PRMN1 was the Label used here in the Old Monitor listing.
; ------------------------------------------------------------------------------
; 
NXTCOL          LDA   #0             ;PRMN1: Clear Accumulator
                LDY   #5             ;Set to Shift 5 Bits into (A)
;                    ;[(%###CHAR1)<--(%CHAR1,CHA ~ %R2,CHAR3#)=(MNEML,MNEMR)]
; ------------------------------------------------------------------------------
; These are the Two Packed Bytes of the Mnemonics: There are 3 Packed Chars per
; 2 Byte Mnemonic [5 Bits/Char: (%CHAR1,CHA ~ %R2,CHAR3#) & a Trailing Bit];
; Each Mnemonic Character is a 5 Bit Number + High ASCII "?" [=(5 Bit #)+($BF)]
; ------------------------------------------------------------------------------
PRMN2           ASL   RMNEM          ;Shift Left 5 Bits of
                ROL   LMNEM          ;Packed Mnemonic Characters [^^^]
                ROL              ;into the Accumulator (Clears Carry)
                DEY                  ;Reduce Bit Counter
                BNE   PRMN2          ;Branch Until Shifted All 5 Bits
; <---[Page Boundary] (in the middle of the DWord above)
                ADC   #"?"     ;Add Offset to make Char High ASCII (>="?")
                JSR   COUT           ;Output 1 Character of Mnemonic
                DEX                  ;Reduce Mnemonic Character Counter
                BNE   NXTCOL         ;Loop Until 3 Packed Mnemonic Chars Printed
                JSR   PRBLNK         ;Print a Blank [(3) Spaces]
                LDY   LENGTH         ;Get LENGTH (Number of OpCode Bytes -1)
                LDX   #6             ;Count for 6 Format Bits
PRADR1          CPX   #3             ;3 Packed Mnemonic Chars Printed?
                BEQ   PRADR5         ;YES, Branch if X=3: Do Address Field
; -----------------------------------;Else, Do Address Field Formatting,
;                                    ;Print Addressing Field CHARS 1 & 2:
PRADR2          ASL   FORMAT         ;Shift Addressing Field Format MSB->(C)
                BCC   PRADR3         ;Branch if Shifted MSB is Zero; Else:
;                                    ;Address Printout CHAR1 Bytes: ",),#($"
                LDA   CHAR1-1,X      ;[-1 OK Here] Get Address Printout Byte
                JSR   COUT           ;Print Addressing CHAR1 Byte
;                                    ;Address Printout CHAR2 Bytes: "Y0X$$0"
                LDA   CHAR2-1,X      ;[-1 OK Here] Get Address Printout Byte
                BEQ   PRADR3         ;Branch if CHAR2 is a Zero (0)
                JSR   COUT           ;Else, Print Addressing CHAR2 Byte
PRADR3          DEX                  ;Reduce Format Bit Count
                BNE   PRADR1         ;Loop Until 6 Format Bits Counted
                RTS                  ;Else, Done, Return to Caller

; -----------------------------------;Do Addressing Field (Not a Branch):
PRADR4          DEY                  ;Reduce (Number of OpCode Bytes -1) Count
                BMI   PRADR2         ;Loop if All Instruction Bytes Processed
                JSR   PRBYTE         ;Else, Print (A) as Two-Digit Hex Number
;                                    ;^[Jumps to (CSW); Does NOT Return Here!]
; 
; -----------------------------------;Do Addressing Field (Entry Point):
PRADR5          LDA   FORMAT         ;Get Addressing Field Format
                CMP   #$E8           ;Subtract $E8 [(A)-Data -> NZC]
;                                    ;^[FORMAT for Relative = $9D = %10011101; 
;                                    ;FORMAT for Rel ASL *3 = $E8 = %11101000]
                LDA   (PCL),Y        ;Get Byte at (Program Counter),Y
                BCC   PRADR4         ;Branch if Addressing Mode is Not Relative
; -----------------------------------;Handle Relative Addressing Mode Special,
;                                    ;for BCC|BCS|BEQ|BMI|BNE|BPL|BVC|BVS,
;                                    ;Print Branch Target, Not Offset Value:
RELADR          JSR   PCADJ3         ;Add (A+C) to Instruction Address (PCL,H)
;                                    ;Set Target=1+[(PCL,H)+(Offset)+1]->(A,Y):
                TAX                  ;Get (Target Address -1), Low
                INX                  ;Add 1 to (Target Address -1), Low
                BNE   PRNTYX         ;Branch if Not Crossing Page Boundary
                INY                  ;Else, Add 1 to (Target Address -1), High
; -----------------------------------;Output Target Address of Branch
;                                    ;& Return to Caller:
PRNTYX          TYA                  ;Get Target Address, High
PRNTAX          JSR   PRBYTE         ;Print A-Reg as Two-Digit Hex Number
PRNTX           TXA                  ;Get Target Address, Low
                JMP   PRBYTE         ;Print A-Reg as Two-Digit Hex Number

; ------------------------------------------------------------------------------
; Print Blank Spaces Subroutine:
; ------------------------------------------------------------------------------
; 
PRBLNK          LDX   #3             ;Print a Blank [(3) Spaces]
PRBL2           LDA   #$A0           ;Print a Blank [(X) Spaces]
;                                    ;Print (A) Char + Blank [(X) Spaces]:
PRBL3           JSR   COUT           ;Print (A) to Output Device
                DEX                  ;Reduce Character Count
                BNE   PRBL2          ;LOOP Until All Characters are Done
                RTS                  ;Return to Caller

; ------------------------------------------------------------------------------
; Add (A+C) to Instruction Address (PCL,H) Subroutines:
; ------------------------------------------------------------------------------
; 
; -----------------------------------;Add Length+1 to Instruction Adrs (PCL,H):
PCADJ           SEC                  ;Prepare for Add with Carry Set (Adds 1)
; -----------------------------------;Add Length+(C) to Instr Adrs (PCL,H):
PCADJ2          LDA   LENGTH         ;Get LENGTH (Number of OpCode Bytes -1)
;                                    ;... ^[0=1-Byte, 1=2-Bytes, 2=3-Bytes]
; -----------------------------------;Add (A+C) to Instruction Address (PCL,H):
PCADJ3          LDY   PCH            ;Get Instruction Address, High
;                                    ;Test Relative Branch Displacement Sign:
                TAX                  ;Get Offset to Target Address
                BPL   PCADJ4         ;Branch if Offset to Target is Positive
                DEY                  ;Else, Extend Negative Target Offset
PCADJ4          ADC   PCL            ;Add Offset to Instruction Address, Low 
                BCC   MON_RTS2       ;Branch if No Carryover (or Page Crossed)
                INY                  ;Else, Add 1 to Instruction Address, High
MON_RTS2        RTS                  ;Return to Caller

; ==============================================================================
; Miniassembler/Disassembler Instruction Display Tables
; ==============================================================================
; 
; ============================= | ==============================================
;       FMT1 Index Bytes:       | Format Index Byte: XXXXXXY0 Instructions
; ========================v====-+-===v=====================^====================
; [*] Use: Left Nibble if Y=1   | If Y=1 then Left Half Byte   |    68 Bytes/2 |
;         Right Nibble if Y=0   | If Y=0 then Right Half Byte  | +  68 Bytes/2 |
;    [For: 14 Print Formats]    | [(X)=(Index into Table)]     | = 136 Nibbles |
; ------------------------------------------------------------------------------
; [*] These are opposite of what the Old Monitor listing shows in A2 Ref Manual!
; ==============================================================================
;                                   FMT1 NOTE
; ==============================================================================
; Used to get an Index into the next table to get FORMAT & LENGTH frm an OpCode;
; Noticeable Patterns: Alternating groups of 4 Defined Bytes (4 DFB lines);
; Nibble Comments are adapted from OpCodes(*) & the following table's Comments;
; The Nibble (sequence number) for an Even Operation Code (Instruction) is:
;     Nibble=(OpCode/2)+1-(2*Y): where Y is Bit 1 of the OpCode = (0 or 1);
;     OpCode=(Nibble-1+(2*Y))*2: " " " " (Ditto) " " " ";  <-[The way back!];
; The Nibble (sequence number) for an Odd OpCode is limited to the last group of
; eight nibbles [(X)=(64~67)]; Undefined Operations: ??? [All are still NOP's];
; (*) See a "6502 Hex to Instruction Conversion Chart" [& maybe: "UnDocumented
; 6502 OpCodes" by Nick Westgate (for Undefined Operations: ???)]
; ==============================================================================
; 
; ----------------------------- | ----------------------------------------------
;                               |   Nibble  Op  Address Mode | Bytes | Examples
; ----------------------------- | ----------------------------\-----/-----------
FMT1         DFB  $04            ;$00: ??? Error/Unknown  | 1 | {Empty}
;                                    ;$01: BRK Implied        | 1 | {Empty}
             DFB  $20            ;$02: ASL Zero-Page [ZP] | 2 | $NN
;                                    ;$03: ??? Error/Unknown  | 1 | {Empty}
             DFB  $54            ;$04: ASL Accumulator    | 1 | {Empty}
;                                    ;$05: PHP Implied        | 1 | {Empty}
             DFB  $30            ;$06: ASL Absolute       | 3 | $NNNN
;                                    ;$07: ??? Error/Unknown  | 1 | {Empty}
; ------------------------------------------------------------------------------
             DFB  $0D            ;$08: ??? Error/Unknown  | 1 | {Empty}
;                                    ;$09: BPL Relative       | 2 | $NN
             DFB  $80            ;$0A: ASL Zero-Page,X    | 2 | $NN,X
;                                    ;$0B: ??? Error/Unknown  | 1 | {Empty}
             DFB  $04            ;$0C: ??? Error/Unknown  | 1 | {Empty}
;                                    ;$0D: CLC Implied        | 1 | {Empty}
             DFB  $90            ;$0E: ASL Absolute,X     | 3 | $NNNN,X
;                                    ;$0F: ??? Error/Unknown  | 1 | {Empty}
; ------------------------------------------------------------------------------
             DFB  $03            ;$10: ??? Error/Unknown  | 1 | {Empty}
;                                    ;$11: JSR Absolute       | 3 | $NNNN
             DFB  $22            ;$12: ROL Zero-Page [ZP] | 2 | $NN
;                                    ;$13: BIT Zero-Page [ZP] | 2 | $NN
             DFB  $54            ;$14: ROL Accumulator    | 1 | {Empty}
;                                    ;$15: PLP Implied        | 1 | {Empty}
             DFB  $33            ;$16: ROL Absolute       | 3 | $NNNN
;                                    ;$17: BIT Absolute       | 3 | $NNNN
; ------------------------------------------------------------------------------
             DFB  $0D            ;$18: ??? Error/Unknown  | 1 | {Empty}
;                                    ;$19: BMI Relative       | 2 | $NN
             DFB  $80            ;$1A: ROL Zero-Page,X    | 2 | $NN,X
;                                    ;$1B: ??? Error/Unknown  | 1 | {Empty}
             DFB  $04            ;$1C: ??? Error/Unknown  | 1 | {Empty}
;                                    ;$1D: SEC Implied        | 1 | {Empty}
             DFB  $90            ;$1E: ROL Absolute,X     | 3 | $NNNN,X
;                                    ;$1F: ??? Error/Unknown  | 1 | {Empty}
; ------------------------------------------------------------------------------
             DFB  $04            ;$20: ??? Error/Unknown  | 1 | {Empty}
;                                    ;$21: RTI Implied        | 1 | {Empty}
             DFB  $20            ;$22: LSR Zero-Page [ZP] | 2 | $NN
;                                    ;$23: ??? Error/Unknown  | 1 | {Empty}
             DFB  $54            ;$24: LSR Accumulator    | 1 | {Empty}
;                                    ;$25: PHA Implied        | 1 | {Empty}
             DFB  $33            ;$26: LSR Absolute       | 3 | $NNNN
;                                    ;$27: JMP Absolute       | 3 | $NNNN
; ------------------------------------------------------------------------------
             DFB  $0D            ;$28: ??? Error/Unknown  | 1 | {Empty}
;                                    ;$29: BVC Relative       | 2 | $NN
             DFB  $80            ;$2A: LSR Zero-Page,X    | 2 | $NN,X
;                                    ;$2B: ??? Error/Unknown  | 1 | {Empty}
             DFB  $04            ;$2C: ??? Error/Unknown  | 1 | {Empty}
;                                    ;$2D: CLI Implied        | 1 | {Empty}
             DFB  $90            ;$2E: LSR Absolute,X     | 3 | $NNNN,X
;                                    ;$2F: ??? Error/Unknown  | 1 | {Empty}
; ------------------------------------------------------------------------------
             DFB  $04            ;$30: ??? Error/Unknown  | 1 | {Empty}
;                                    ;$31: RTS Implied        | 1 | {Empty}
             DFB  $20            ;$32: ROR Zero-Page [ZP] | 2 | $NN
;                                    ;$33: ??? Error/Unknown  | 1 | {Empty}
             DFB  $54            ;$34: ROR Accumulator    | 1 | {Empty}
;                                    ;$35: PLA Implied        | 1 | {Empty}
             DFB  $3B            ;$36: ROR Absolute       | 3 | $NNNN
;                                    ;$37: JMP (Abs.Indirect) | 3 | ($NNNN)
; ------------------------------------------------------------------------------
             DFB  $0D            ;$38: ??? Error/Unknown  | 1 | {Empty}
;                                    ;$39: BVS Relative       | 2 | $NN
             DFB  $80            ;$3A: ROR Zero-Page,X    | 2 | $NN,X
;                                    ;$3B: ??? Error/Unknown  | 1 | {Empty}
             DFB  $04            ;$3C: ??? Error/Unknown  | 1 | {Empty}
;                                    ;$3D: SEI Implied        | 1 | {Empty}
             DFB  $90            ;$3E: ROR Absolute,X     | 3 | $NNNN,X
;                                    ;$3F: ??? Error/Unknown  | 1 | {Empty}
; ------------------------------------------------------------------------------
             DFB  $00            ;$40: ??? Error/Unknown  | 1 | {Empty}
;                                    ;$41: ??? Error/Unknown  | 1 | {Empty}
             DFB  $22            ;$42: STX Zero-Page [ZP] | 2 | $NN
;                                    ;$43: STY Zero-Page [ZP] | 2 | $NN
             DFB  $44            ;$44: TYA Implied        | 1 | {Empty}
;                                    ;$45: DEY Implied        | 1 | {Empty}
             DFB  $33            ;$46: STX Absolute       | 3 | $NNNN
;                                    ;$47: STY Absolute       | 3 | $NNNN
; ------------------------------------------------------------------------------
             DFB  $0D            ;$48: ??? Error/Unknown  | 1 | {Empty}
;                                    ;$49: BCC Relative       | 2 | $NN
             DFB  $C8            ;$4A: STX Zero-Page,Y    | 2 | $NN,Y
;                                    ;$4B: STY Zero-Page,X    | 2 | $NN,X
             DFB  $44            ;$4C: TXS Implied        | 1 | {Empty}
;                                    ;$4D: TYA Implied        | 1 | {Empty}
             DFB  $00            ;$4E: ??? Error/Unknown  | 1 | {Empty}
;                                    ;$4F: ??? Error/Unknown  | 1 | {Empty}
; ------------------------------------------------------------------------------
             DFB  $11            ;$50: LDX Immediate      | 2 | #$NN
;                                    ;$51: LDY Immediate      | 2 | #$NN
             DFB  $22            ;$52: LDX Zero-Page [ZP] | 2 | $NN
;                                    ;$53: LDY Zero-Page [ZP] | 2 | $NN
             DFB  $44            ;$54: TAX Implied        | 1 | {Empty}
;                                    ;$55: TAY Implied        | 1 | {Empty}
             DFB  $33            ;$56: LDX Absolute       | 3 | $NNNN
;                                    ;$57: LDY Absolute       | 3 | $NNNN
; ------------------------------------------------------------------------------
             DFB  $0D            ;$58: ??? Error/Unknown  | 1 | {Empty}
;                                    ;$59: BCS Relative       | 2 | $NN
             DFB  $C8            ;$5A: LDX Zero-Page,Y    | 2 | $NN,Y
;                                    ;$5B: LDY Zero-Page,X    | 2 | $NN,X
             DFB  $44            ;$5C: TSX Implied        | 1 | {Empty}
;                                    ;$5D: CLV Implied        | 1 | {Empty}
             DFB  $A9            ;$5E: LDX Absolute,Y     | 3 | $NNNN,Y
;                                    ;$5F: LDY Absolute,X     | 3 | $NNNN,X
; ------------------------------------------------------------------------------
             DFB  $01            ;$60: ??? Error/Unknown  | 1 | {Empty}
;                                    ;$61: CPY Immediate      | 2 | #$NN
             DFB  $22            ;$62: DEC Zero-Page [ZP] | 2 | $NN
;                                    ;$63: CPY Zero-Page [ZP] | 2 | $NN
             DFB  $44            ;$64: DEX Implied        | 1 | {Empty}
;                                    ;$65: INY Implied        | 1 | {Empty}
             DFB  $33            ;$66: DEC Absolute       | 3 | $NNNN
;                                    ;$67: CPY Absolute       | 3 | $NNNN
; ------------------------------------------------------------------------------
             DFB  $0D            ;$68: ??? Error/Unknown  | 1 | {Empty}
;                                    ;$69: BNE Relative       | 2 | $NN
             DFB  $80            ;$6A: DEC Zero-Page,X    | 2 | $NN,X
;                                    ;$6B: ??? Error/Unknown  | 1 | {Empty}
             DFB  $04            ;$6C: ??? Error/Unknown  | 1 | {Empty}
;                                    ;$6D: CLD Implied        | 1 | {Empty}
             DFB  $90            ;$6E: DEC Absolute,X     | 3 | $NNNN,X
;                                    ;$6F: ??? Error/Unknown  | 1 | {Empty}
; ------------------------------------------------------------------------------
             DFB  $01            ;$70: ??? Error/Unknown  | 1 | {Empty}
;                                    ;$71: CPX Immediate      | 2 | #$NN
             DFB  $22            ;$72: INC Zero-Page [ZP] | 2 | $NN
;                                    ;$73: CPX Zero-Page [ZP] | 2 | $NN
             DFB  $44            ;$74: NOP Implied        | 1 | {Empty}
;                                    ;$75: INX Implied        | 1 | {Empty}
             DFB  $33            ;$76: INC Absolute       | 3 | $NNNN
;                                    ;$77: CPX Absolute       | 3 | $NNNN
; ------------------------------------------------------------------------------
             DFB  $0D            ;$78: ??? Error/Unknown  | 1 | {Empty}
;                                    ;$79: BEQ Relative       | 2 | $NN
             DFB  $80            ;$7A: INC Zero-Page,X    | 2 | $NN,X
;                                    ;$7B: ??? Error/Unknown  | 1 | {Empty}
             DFB  $04            ;$7C: ??? Error/Unknown  | 1 | {Empty}
;                                    ;$7D: SED Implied        | 1 | {Empty}
             DFB  $90            ;$7E: INC Absolute,X     | 3 | $NNNN,X
;                                    ;$7F: ??? Error/Unknown  | 1 | {Empty}
; ------------------------------------------------------------------------------
; Last 8 for Odd OpCode Mnemonics *** [ORA, AND EOR, ADC, STA, LDA, CMP, & SBC]:
; ------------------------------------------------------------------------------
             DFB  $26            ;$80: *** Zero-Page [ZP] | 2 | $NN
;                                    ;      ^ $(Even)5:Zero-Page
;                                    ;$81: *** (Zero-Page,X)  | 2 | ($NN,X)
;                                    ;      ^ $(Even)1 [(Indexed-Indirect)]
             DFB  $31            ;$82: *** Absolute       | 3 | $NNNN
;                                    ;      ^ $(Even)D
;                                    ;$83: *** Immediate      | 2 | #$NN
;                                    ;      ^ $(Even)9  [No STA Immediate!]
             DFB  $87            ;$84: *** Zero-Page,X    | 2 | $NN,X
;                                    ;      ^ $(Odd)5
;                                    ;$85: *** (Zero-Page),Y  | 2 | ($NN),Y
;                                    ;      ^ $(Odd)1  [(Indirect)-Indexed]
             DFB  $9A            ;$86: *** Absolute,X     | 3 | $NNNN,X
;                                    ;      ^ $(Odd)D
;                                    ;$87: *** Absolute,Y     | 3 | $NNNN,Y
;                                    ;      ^ $(Odd)9
; ------------------------------------------------------------------------------
; 
; ============================= | ==============================================
;     FMT2 Index Bytes (*):     | Print Format Index Byte $ZZXXXY01 Instructions
; ============================= | ==============================================
;   [(X)=(Index into Table)]    |      Address Mode | Bytes | Notes & Examples
; ----------------------------- | -------------------\-----/--------------------
FMT2         DFB  %00000000      ;Error/Unknown  | 1 | {MT}[All are NOP's]
             DFB  %00100001      ;Immediate      | 2 | #$NN
             DFB  %10000001      ;Zero-Page [ZP] | 2 | $NN
             DFB  %10000010      ;Absolute       | 3 | $NNNN
             DFB  %00000000      ;Implied        | 1 | {Empty} [& $EA=NOP]
             DFB  %00000000      ;Accumulator    | 1 | {Empty}
             DFB  %01011001      ;(Zero-Page,X)  | 2 | ($NN,X) [NDXD-NDRCT]
             DFB  %01001101      ;(Zero-Page),Y  | 2 | ($NN),Y [NDRCT-NDXD]
             DFB  %10010001      ;Zero-Page,X    | 2 | $NN,X
             DFB  %10010010      ;Absolute,X     | 3 | $NNNN,X
             DFB  %10000110      ;Absolute,Y     | 3 | $NNNN,Y
             DFB  %01001010      ;(Indirect)  *1 | 3 | JMP (Absolute)
             DFB  %10000101      ;Zero-Page,Y *2 | 2 | LDX ZP,Y & STX ZP,Y
             DFB  %10011101      ;Relative       | 2 | $NN
; ----------------------------- | ----------------------------------------------
; (*) Bytes will be Saved for   | Only those Noted: *1=One Op; *2=Two Ops
;     Address Field Formatting -> Mask Gets 2-Bit LENGTH: FMT2,X AND #%00000011
; [See also (above): FMT1 NOTE] | (OpCodeBytes-1: 0=1 Byte, 1=2 Byte, 2=3 Byte)
; ============================= | ==============================================
; 
; ============================= | ==============================================
;     Address Printout          | Apple II Reference Manual Listings:
;     CHAR1 Bytes: ",),#($"     | New Monitor <> Old Monitor: ASC ",),#($"
; ============================= | ==============================================
; 
CHAR1        DFB  ","      ;ASCII ","
             DFB  ")"      ;ASCII ")"
             DFB  ","      ;ASCII ","
             DFB  "#"      ;ASCII "#"
             DFB  "("      ;ASCII "("
             DFB  "$"      ;ASCII "$"
; 
; ============================= | ==============================================
;     Address Printout          | Apple II Reference Manual Listings:
;     CHAR2 Bytes: "Y0X$$0"     | New Monitor = Old Monitor: "Y",0,"X$$",0
; ============================= | ==============================================
CHAR2        DFB  "Y"      ;ASCII "Y"
             DFB  $00            ;VALUE "0"
             DFB  "X"      ;ASCII "X"
             DFB  "$"      ;ASCII "$"
             DFB  "$"      ;ASCII "$"
             DFB  $00            ;VALUE "0"
; 
; ============================= | ==============================================
;      Mnemonic Forms:          | MNEML & MNEMR Instruction Formats
;       (A) XXXXX000            |
;       (B) XXXYY100            | [(X)=(Index into Table)]
;       (C) 1XXX1010            |
;       (D) XXXYYY10            |
;       (E) XXXYYY01            |
; ============================= | ==============================================
;      Mnemonic Left Bytes      | MNEML Instruction Formats (64)
; ============================= | ==============================================
; 
; ------------------------------------------------------------------------------
; These are the 1st Packed Bytes of the Mnemonics: There are 3 Packed Chars per
; 2 Byte Mnemonic [5 Bits/Char: (%CHAR1,CHA ~ %R2,CHAR3#) & a Trailing Bit];
; Each Mnemonic Character is a 5 Bit Number + High ASCII "?" [=(5 Bit #)+($BF)]
; ------------------------------------------------------------------------------
; 
; -----------------------------------;(A)-Format Instructions (32)
;                                    ; |  vvv---------[MNEML+MNEMR]--------
;                                    ; |   v    CHAR1     CHAR2     CHAR3
;                                    ;--- ---  --------  --------  --------
MNEML        DFB  %00011100      ;(A) BRK: %00011=B; %10011=R; %01100=K
             DFB  %10001010      ;(A) PHP: %10001=P; %01001=H; %10001=P
             DFB  %00011100      ;(A) BPL: %00011=B; %10001=P; %01101=L
             DFB  %00100011      ;(A) CLC: %00100=C; %01101=L; %00100=C
             DFB  %01011101      ;(A) JSR: %01011=J; %10100=S; %10011=R
             DFB  %10001011      ;(A) PLP: %10001=P; %01101=L; %10001=P
             DFB  %00011011      ;(A) BMI: %00011=B; %01110=M; %01010=I
             DFB  %10100001      ;(A) SEC: %10100=S; %00110=E; %00100=C
             DFB  %10011101      ;(A) RTI: %10011=R; %10101=T; %01010=I
             DFB  %10001010      ;(A) PHA: %10001=P; %01001=H; %00010=A
             DFB  %00011101      ;(A) BVC: %00011=B; %10111=V; %00100=C
             DFB  %00100011      ;(A) CLI: %00100=C; %01101=L; %01010=I
             DFB  %10011101      ;(A) RTS: %10011=R; %10101=T; %10100=S
             DFB  %10001011      ;(A) PLA: %10001=P; %01101=L; %00010=A
             DFB  %00011101      ;(A) BVS: %00011=B; %10111=V; %10100=S
             DFB  %10100001      ;(A) SEI: %10100=S; %00110=E; %01010=I
             DFB  %00000000      ;(A) ???: %00000=?; %00000=?; %00000=?
             DFB  %00101001      ;(A) DEY: %00101=D; %00110=E; %11010=Y
             DFB  %00011001      ;(A) BCC: %00011=B; %00100=C; %00100=C
             DFB  %10101110      ;(A) TYA: %10101=T; %11010=Y; %00010=A
             DFB  %01101001      ;(A) LDY: %01101=L; %00101=D; %11010=Y
             DFB  %10101000      ;(A) TAY: %10101=T; %00010=A; %11010=Y
             DFB  %00011001      ;(A) BCS: %00011=B; %00100=C; %10100=S
             DFB  %00100011      ;(A) CLV: %00100=C; %01101=L; %10111=V
             DFB  %00100100      ;(A) CPY: %00100=C; %10001=P; %11010=Y
             DFB  %01010011      ;(A) INY: %01010=I; %01111=N; %11010=Y
             DFB  %00011011      ;(A) BNE: %00011=B; %01111=N; %00110=E
             DFB  %00100011      ;(A) CLD: %00100=C; %01101=L; %00101=D
             DFB  %00100100      ;(A) CPX: %00100=C; %10001=P; %11001=X
             DFB  %01010011      ;(A) INX: %01010=I; %01111=N; %11001=X
             DFB  %00011001      ;(A) BEQ: %00011=B; %00110=E; %10010=Q
             DFB  %10100001      ;(A) SED: %10100=S; %00110=E; %00101=D
; -----------------------------------;(B)-Format Instructions (8)
             DFB  %00000000      ;(B) ???: %00000=?; %00000=?; %00000=?
             DFB  %00011010      ;(B) BIT: %00011=B; %01010=I; %10101=T
             DFB  %01011011      ;(B) JMP: %01011=J; %01110=M; %10001=P
             DFB  %01011011      ;(B) JMP: %01011=J; %01110=M; %10001=P
             DFB  %10100101      ;(B) STY: %10100=S; %10101=T; %11010=Y
             DFB  %01101001      ;(B) LDY: %01101=L; %00101=D; %11010=Y
             DFB  %00100100      ;(B) CPY: %00100=C; %10001=P; %11010=Y
             DFB  %00100100      ;(B) CPX: %00100=C; %10001=P; %11001=X
; -----------------------------------;(C)-Format Instructions (8)
             DFB  %10101110      ;(C) TXA: %10101=T; %11001=X; %00010=A
             DFB  %10101110      ;(C) TXS: %10101=T; %11001=X; %10100=S
             DFB  %10101000      ;(C) TAX: %10101=T; %00010=A; %11001=X
             DFB  %10101101      ;(C) TSX: %10101=T; %10100=S; %11001=X
             DFB  %00101001      ;(C) DEX: %00101=D; %00110=E; %11001=X
             DFB  %00000000      ;(C) ???: %00000=?; %00000=?; %00000=?
             DFB  %01111100      ;(C) NOP: %01111=N; %10000=O; %10001=P
             DFB  %00000000      ;(C) ???: %00000=?; %00000=?; %00000=?
; -----------------------------------;(D)-Format Instructions (8)
             DFB  %00010101      ;(D) ASL: %00010=A; %10100=S; %01101=L
             DFB  %10011100      ;(D) ROL: %10011=R; %10000=O; %01101=L
             DFB  %01101101      ;(D) LSR: %01101=L; %10100=S; %10011=R
             DFB  %10011100      ;(D) ROR: %10011=R; %10000=O; %10011=R
             DFB  %10100101      ;(D) STX: %10100=S; %10101=T; %11001=X
             DFB  %01101001      ;(D) LDX: %01101=L; %00101=D; %11001=X
             DFB  %00101001      ;(D) DEC: %00101=D; %00110=E; %00100=C
             DFB  %01010011      ;(D) INC: %01010=I; %01111=N; %00100=C
; -----------------------------------;(E)-Format Instructions (8)
             DFB  %10000100      ;(E) ORA: %10000=O; %10011=R; %00010=A
             DFB  %00010011      ;(E) AND: %00010=A; %01111=N; %00101=D
             DFB  %00110100      ;(E) EOR: %00110=E; %10000=O; %10011=R
             DFB  %00010001      ;(E) ADC: %00010=A; %00101=D; %00100=C
             DFB  %10100101      ;(E) STA: %10100=S; %10101=T; %00010=A
             DFB  %01101001      ;(E) LDA: %01101=L; %00101=D; %00010=A
             DFB  %00100011      ;(E) CMP: %00100=C; %01110=M; %10001=P
             DFB  %10100000      ;(E) SBC: %10100=S; %00011=B; %00100=C
; 
; <---[Page Boundary]
; 
; ============================= | ==============================================
;     Mnemonic Right Bytes      | MNEMR Instruction Formats (64)
; ============================= | ==============================================
; 
; ------------------------------------------------------------------------------
; These are the 2nd Packed Bytes of the Mnemonics: There are 3 Packed Chars per
; 2 Byte Mnemonic [5 Bits/Char: (%CHAR1,CHA ~ %R2,CHAR3#) & a Trailing Bit];
; Each Mnemonic Character is a 5 Bit Number + High ASCII "?" [=(5 Bit #)+($BF)]
; ------------------------------------------------------------------------------
; 
; -----------------------------------;(A)-Format Instructions (32)
;                                    ; |  vvv---------[MNEML+MNEMR]--------
;                                    ; |   v    CHAR1     CHAR2     CHAR3
;                                    ;--- ---  --------  --------  --------
MNEMR        DFB  %11011000      ;(A) BRK: %00011=B; %10011=R; %01100=K
             DFB  %01100010      ;(A) PHP: %10001=P; %01001=H; %10001=P
             DFB  %01011010      ;(A) BPL: %00011=B; %10001=P; %01101=L
             DFB  %01001000      ;(A) CLC: %00100=C; %01101=L; %00100=C
             DFB  %00100110      ;(A) JSR: %01011=J; %10100=S; %10011=R
             DFB  %01100010      ;(A) PLP: %10001=P; %01101=L; %10001=P
             DFB  %10010100      ;(A) BMI: %00011=B; %01110=M; %01010=I
             DFB  %10001000      ;(A) SEC: %10100=S; %00110=E; %00100=C
             DFB  %01010100      ;(A) RTI: %10011=R; %10101=T; %01010=I
             DFB  %01000100      ;(A) PHA: %10001=P; %01001=H; %00010=A
             DFB  %11001000      ;(A) BVC: %00011=B; %10111=V; %00100=C
             DFB  %01010100      ;(A) CLI: %00100=C; %01101=L; %01010=I
             DFB  %01101000      ;(A) RTS: %10011=R; %10101=T; %10100=S
             DFB  %01000100      ;(A) PLA: %10001=P; %01101=L; %00010=A
             DFB  %11101000      ;(A) BVS: %00011=B; %10111=V; %10100=S
             DFB  %10010100      ;(A) SEI: %10100=S; %00110=E; %01010=I
             DFB  %00000000      ;(A) ???: %00000=?; %00000=?; %00000=?
             DFB  %10110100      ;(A) DEY: %00101=D; %00110=E; %11010=Y
             DFB  %00001000      ;(A) BCC: %00011=B; %00100=C; %00100=C
             DFB  %10000100      ;(A) TYA: %10101=T; %11010=Y; %00010=A
             DFB  %01110100      ;(A) LDY: %01101=L; %00101=D; %11010=Y
             DFB  %10110100      ;(A) TAY: %10101=T; %00010=A; %11010=Y
             DFB  %00101000      ;(A) BCS: %00011=B; %00100=C; %10100=S
             DFB  %01101110      ;(A) CLV: %00100=C; %01101=L; %10111=V
             DFB  %01110100      ;(A) CPY: %00100=C; %10001=P; %11010=Y
             DFB  %11110100      ;(A) INY: %01010=I; %01111=N; %11010=Y
             DFB  %11001100      ;(A) BNE: %00011=B; %01111=N; %00110=E
             DFB  %01001010      ;(A) CLD: %00100=C; %01101=L; %00101=D
             DFB  %01110010      ;(A) CPX: %00100=C; %10001=P; %11001=X
             DFB  %11110010      ;(A) INX: %01010=I; %01111=N; %11001=X
             DFB  %10100100      ;(A) BEQ: %00011=B; %00110=E; %10010=Q
             DFB  %10001010      ;(A) SED: %10100=S; %00110=E; %00101=D
; -----------------------------------;(B)-Format Instructions (8)
             DFB  %00000000      ;(B) ???: %00000=?; %00000=?; %00000=?
             DFB  %10101010      ;(B) BIT: %00011=B; %01010=I; %10101=T
             DFB  %10100010      ;(B) JMP: %01011=J; %01110=M; %10001=P
             DFB  %10100010      ;(B) JMP: %01011=J; %01110=M; %10001=P
             DFB  %01110100      ;(B) STY: %10100=S; %10101=T; %11010=Y
             DFB  %01110100      ;(B) LDY: %01101=L; %00101=D; %11010=Y
             DFB  %01110100      ;(B) CPY: %00100=C; %10001=P; %11010=Y
             DFB  %01110010      ;(B) CPX: %00100=C; %10001=P; %11001=X
; -----------------------------------;(C)-Format Instructions (8)
             DFB  %01000100      ;(C) TXA: %10101=T; %11001=X; %00010=A
             DFB  %01101000      ;(C) TXS: %10101=T; %11001=X; %10100=S
             DFB  %10110010      ;(C) TAX: %10101=T; %00010=A; %11001=X
             DFB  %00110010      ;(C) TSX: %10101=T; %10100=S; %11001=X
             DFB  %10110010      ;(C) DEX: %00101=D; %00110=E; %11001=X
             DFB  %00000000      ;(C) ???: %00000=?; %00000=?; %00000=?
             DFB  %00100010      ;(C) NOP: %01111=N; %10000=O; %10001=P
             DFB  %00000000      ;(C) ???: %00000=?; %00000=?; %00000=?
; -----------------------------------;(D)-Format Instructions (8)
             DFB  %00011010      ;(D) ASL: %00010=A; %10100=S; %01101=L
             DFB  %00011010      ;(D) ROL: %10011=R; %10000=O; %01101=L
             DFB  %00100110      ;(D) LSR: %01101=L; %10100=S; %10011=R
             DFB  %00100110      ;(D) ROR: %10011=R; %10000=O; %10011=R
             DFB  %01110010      ;(D) STX: %10100=S; %10101=T; %11001=X
             DFB  %01110010      ;(D) LDX: %01101=L; %00101=D; %11001=X
             DFB  %10001000      ;(D) DEC: %00101=D; %00110=E; %00100=C
             DFB  %11001000      ;(D) INC: %01010=I; %01111=N; %00100=C
; -----------------------------------;(E)-Format Instructions (8)
             DFB  %11000100      ;(E) ORA: %10000=O; %10011=R; %00010=A
             DFB  %11001010      ;(E) AND: %00010=A; %01111=N; %00101=D
             DFB  %00100110      ;(E) EOR: %00110=E; %10000=O; %10011=R
             DFB  %01001000      ;(E) ADC: %00010=A; %00101=D; %00100=C
             DFB  %01000100      ;(E) STA: %10100=S; %10101=T; %00010=A
             DFB  %01000100      ;(E) LDA: %01101=L; %00101=D; %00010=A
             DFB  %10100010      ;(E) CMP: %00100=C; %01110=M; %10001=P
             DFB  %11001000      ;(E) SBC: %10100=S; %00011=B; %00100=C

; ==============================================================================
; End of Miniassembler/Disassembler Instruction Display Tables
; ==============================================================================
; 
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Start of Section (FA40-FA61): Moved Here from FA86-FAA4 in Old Monitor ROM
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; 
; ==============================================================================
; IRQ/BRK Handler:
; ==============================================================================
; In this ROM Image, IRQ NEVER HAPPENS!...because OLDRST Vector ($FF59) is used:
; ------------------------------------------------------------------------------
; What Should & Should Not Be:            <-[From end of this ROM Image listing]
; ------------------------------------------------------------------------------
; FFFE: 40 FA  DW     IRQ            ;IRQ Vector    ($FA40) IS Right; 
; FFFE: 59 FF  DW     OLDRST         ;OLDRST Vector ($FF59) IS Wrong! << BUG >>
; ------------------------------------------------------------------------------
;        <<< BUG can be fixed in (Apple II Plus) Emulator ROM images! >>>
; ==============================================================================
; 
; -----------------------------------;IRQ Handler
IRQ             STA   ACC            ;Save (A) in Accumulator Safe
;                                    ;^[Destroys General Purpose A5-Reg, High]
                PLA                  ;Pull Processor Status from Top of STACK
                PHA                  ;Restore STACK Top: Push Processor Status
                ASL              ;Shift Break Flag (Bit 4)
                ASL              ;over into the
                ASL              ;Negative Flag (Bit 7)
                BMI   BREAK          ;Branch if Break Flag (Bit 4) was Set
                JMP   (IRQADDR)      ;Else, Go to (User Routine Vector) in RAM

; -----------------------------------;BRK Handler
BREAK           PLP                  ;Retrieve Processor Status
                JSR   SAV1           ;Save All 6502 Registers
;                                    ;Including Program Counter:
;                                    ;<<< BUG: SAV1 Does Not Save A-Reg! >>>
                PLA                  ;Pull Program Counter, Low
                STA   PCL            ;Save in Program Counter Safe, Low
                PLA                  ;Pull Program Counter, High
                STA   PCH            ;Save in Program Counter Safe, High
                JMP   (BRKV)         ;BRKV is Set to OLDBRK by Disk Bootup

; -----------------------------------;OLD BRK Handler
OLDBRK          JSR   INSDS1         ;New Monitor <> Old Monitor "XBRK"
                JSR   RGDSP1         ;Print User Program Counter & Registers
                JMP   MON            ;Go to Monitor

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; End of Section (FA40-FA61): Moved Here from FA86-FAA4 in Old Monitor ROM
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Start of Section (FA62-FAD6): New in Autostart [New Monitor] ROM
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; 
; ==============================================================================
; Autostart [New Monitor] "RESET"; <> [("OLDRST")=(Old Monitor "RESET")]
; ==============================================================================
; 
RESET           CLD                  ;Do this 1st this time;
;                                    ;"OLDRST" does NOT do it!
                JSR  NORMSET        ;Set Normal Video Mode & ...
                JSR  INITSCR        ;Init Keyboard & Screen as I/O Devices
                JSR  VIDSET         ;Reset CSW Output Vector to COUT1 <--+/
                JSR  KBDSET         ;Reset KSW Input Vector to KEYIN <--+/
; ------------------------------------------------------------------------------
; WARNING: Annunciator Terminology is/was Counter Intuitive!
; These New Mnemocics/Labels are NOT!
; ------------------------------------------------------------------------------
;                                    ;Initialize Annunciator Outputs:
INITAN          LDA   AN0OFF         ; Turn OFF: AN0
                LDA   AN1OFF         ; Turn OFF: AN1
                LDA   AN2ON          ; Turn  ON: AN2
                LDA   AN3ON          ; Turn  ON: AN3
; ------------------------------------------------------------------------------
                LDA   CLRROM         ;Tell slots to disable their extension ROM
                BIT   KBDSTRB        ;Clear KBD Strobe (KBD<128)
NEWMON          CLD                  ;[As opposed to the Old MON @ $FF65]
                JSR   BELL           ;BELL Causes Delay if Key Bounces
                LDA   SOFTEV+1       ;Soft Entry (Warm Start) Vector, High
                EOR   #$A5           ;PWREDUP must equal [(SOFTEV+1)EOR #$A5]
                CMP   PWREDUP        ;Power-Up Reset CHKSUM
                BNE   PWRUP          ;Not Equal, so in a Power-Up Reset cycle
                LDA   SOFTEV         ;Equal, so has Cold Start been done yet?
                BNE   NOFIX          ;Cold Start done, so don't reset SOFTEV
                LDA   #>BASIC2       ;Soft/Warm/Ctrl-C Entry Point, High
;                                    ;^(Do Not Reinitialize BASIC)
                CMP   SOFTEV+1       ;Soft Entry (Warm Start) Vector
                BNE   NOFIX          ;Cold Start done, so don't reset SOFTEV
FIXSEV          LDY   #<BASIC2       ;Soft/Warm/Ctrl-C Entry Point, Low
;                                    ;^(Do Not Reinitialize BASIC)
                STY   SOFTEV         ;Set Adrs of Reset Handler to Warm Start
;                                    ;^(next time)
                JMP   BASIC          ;Cold Start BASIC (Reinitialize)

NOFIX           JMP   (SOFTEV)       ;Go to Soft Entry (Warm Start) Address

; ==============================================================================
; Power-Up Reset
; ==============================================================================
; 
PWRUP           JSR   APPLEII        ;Display "Apple ]["
;                                    ;centered on top line of Screen
; 
; ------------------------------------------------------------------------------
; Set Page 3 Vectors:
; ------------------------------------------------------------------------------
;  Set New BRK Vector (BRKV) to OLDBRK ($FA59);
;  Set Soft Entry Vector (SOFTEV) to Cold Start BASIC Vector ($E000);
;  Set Powered-Up Flag (PWREDUP) to $45 = (SOFTEV+1) EOR #$A5.
; ------------------------------------------------------------------------------
; 
SETPG3          LDX   #5             ;Number of bytes to copy
PLPSET          LDA   PWRCON-1,X     ;Get Page 3 Vectors
                STA   GOBRKV,X       ;Set Page 3 Vectors
                DEX
                BNE  PLPSET         ;Loop until X=0
; 
; ------------------------------------------------------------------------------
; Find Disk Drive Controller Slot
; ------------------------------------------------------------------------------
; 
                LDA   #$C8           ;Load High Slot (7) Page Address ($C7) + 1
                STX   LOC0           ;Set Poiter, Low; X=0
                STA   LOC1           ;Set Poiter, High; (for JMP @ $FAD2 below)
SLOOP           LDY   #$07           ;Y is Byte Pointer
                DEC   LOC1           ;Decrement Slot Page Address
                LDA   LOC1           ;Get Slot Page Address for comparison
                CMP   #$C0           ;Down to last Slot yet?
                BEQ   FIXSEV         ;YES, it can't be a disk; Cold Start BASIC
                STA   MSLOT          ;NO, Save current Slot Page Address
NXTBYT          LDA   (LOC0),Y       ;Fetch a Slot Byte
                CMP   DISKID-1,Y     ;Is it a Disk?
                BNE   SLOOP          ;NO, so next Slot down
                DEY                  ;Skip over $FF bytes; See DISKID below
                DEY                  ;YES, so check next byte ...
                BPL   NXTBYT         ;Until 4 checked
                JMP   (LOC0)         ;Go there

; ------------------------------------------------------------------------------
MON_NOP1        NOP                  ;Fill
MON_NOP2        NOP                  ;Fuller;-)
; ------------------------------------------------------------------------------
; 
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; End of Section (FA62-FAD6): New in Autostart [New Monitor] ROM
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; 
; ==============================================================================
; Display User Register Contents with Labels
; ==============================================================================
; ACC          EQU    $45          ;A-Reg Safe (Accumulator) [Destroys A5H!]
; XREG         EQU    $46          ;X-Reg Safe (Index Register X)
; YREG         EQU    $47          ;Y-Reg Safe (Index Register Y)
; STATUS       EQU    $48          ;P-Reg Safe (Status Register)
; SPNT         EQU    $49          ;S-Reg Safe (Stack Pointer)
; ==============================================================================
; 
; REGDSP Must ORG $FAD7 for New Monitor to remain equal to Old Mmonitor ROM
REGDSP          JSR   CROUT          ;Print Carriage Return (Ctrl-M) Character
RGDSP1          LDA   #ACC           ;A-Reg Safe (Accumulator)
                STA   A3L            ;Save ACC/A5H-Reg Address in A3-Reg
                LDA   #>ACC          ;ACC/A5H-Reg is a Zero Page Address
                STA   A3H            ;Monitor General Purpose A3-Reg, High
;                                    ;[A3-Reg ($40-$41)]=[(ACC)=($0045)]**
                LDX   #$FB           ;Load Index (-5)
RDSP1           LDA   #$A0           ;Print a Space character
                JSR   COUT           ;Print A-Reg to Output Device
                LDA   RTBL-251,X     ;^"AXYPS"; 6502 Registers (Letter-Names)
;                                    ;^(X)=[($FB=251={-5})~($FF=255={-1})]
;                                    ;^[RTBL-251]=[MNEMR+30]
                JSR   COUT           ;Print A-Reg to Output Device
                LDA   #"="           ;Print an Equal-Sign character
                JSR   COUT           ;Print A-Reg to Output Device
                LDA   SAVE6502,X     ;6502 Registers Safe (Save Locations)+5
;                                    ;^(X)=[($FB=251={-5})~($FF=255={-1})]
                JSR   PRBYTE         ;Print A-Reg as Two-Digit Hex Number
                INX                  ;Count UP
                BMI   RDSP1          ;Loop until all 5 6502 Reg's are displayed
                RTS                  ;**; Return to Caller

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Start of Section (FAFD-FB18): New in Autostart [New Monitor] ROM
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; 
; ==============================================================================
; Power-Up Reset Data
; ==============================================================================
; 
PWRCON       DA    OLDBRK         ;To Set New BRK Vector (BRKV)
             DA    BASIC          ;To Set Soft Entry Vector (SOFTEV)
; <---[Page Boundary] (in the middle of the DWord above)
              DFB   $45            ;To Set Powered-Up Flag
;                                    ;^(PWREDUP)=(SOFTEV+1)EOR(#$A5)
; 
; ==============================================================================
; Disk Drive Controller ID-Bytes; For Slot (7 To 0) Scan [SLOOP/NXTBYT above]
; ==============================================================================
; 
DISKID        DFB   $20            ;20/00/03/3C is controller signature (**)
              DFB   $FF            ;$FFs are Skipped over; See NXTBYT above
              DFB   $00            ;** See DISK2ROM..MKDCTBL @ $C600..$C606
              DFB   $FF            ;$FF bytes are substitutes for OpCodes
              DFB   $03            ;that would otherwise make this data into
              DFB   $FF            ;functional code identical to the first 7
              DFB   $3C            ;bytes of code on the disk drive control-
;                                    ;ler, which would not be good!
; 
; ==============================================================================
; Title to be displayed, centered on top line of Screen
; ==============================================================================
; 
TITLE         DFB $C1,$D0,$D0,$CC ; "APPLE ][" with all MSBs set
              DFB $C5,$A0,$DD,$DB
; 
; ==============================================================================
; Cursor Keys Translation Table
; ==============================================================================
; 
XLTBL         DFB   "D"       ; High ASCII ($C4 = 196) "D"
              DFB   "B"       ; High ASCII ($C2 = 194) "B"
              DFB   "A"       ; High ASCII ($C1 = 193) "A"
              DFB   DELETE         ; High ASCII ($FF = 255) "Delete"
              DFB   "C"       ; High ASCII ($C3 = 195) "C"
              DFB   DELETE         ; High ASCII ($FF = 255) "Delete"
              DFB   DELETE         ; High ASCII ($FF = 255) "Delete"
              DFB   DELETE         ; High ASCII ($FF = 255) "Delete"
; 
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; End of Section (FAFD-FB18): New in Autostart [New Monitor] ROM
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; 
; ==============================================================================
; 6502 Registers (Letter-Names)
; ==============================================================================
; 
; RTBL Must ORG $FB19 for New Monitor to remain equal to Old Mmonitor ROM
RTBL          DFB   "A"      ;6502 Accumulator Register
              DFB   "X"      ;6502 X-Index Register
              DFB   "Y"      ;6502 Y-Index Register
              DFB   "P"      ;6502 Processor Status Register
              DFB   "S"      ;6502 Stack Pointer Register

; ==============================================================================
; Read Paddle (X-Reg), Return Time-Count in (Y-Reg)
; ==============================================================================
; 
PREAD           LDA   PTRIG          ;~($C07X)[R/W]; Trigger/Reset All Paddles
PREAD4          LDY   #0             ;Initialize Time-Counter
                NOP                  ;Compensate for First Time-Count: Do zip
                NOP                  ;for (2 NOPs)*(2 cycles/NOP)=4 cycles
PREAD2          LDA   PADDL0,X       ;Read Paddle (X-Reg)
                BPL   MON_RTS2D      ;Timed-Out if (A) is positive [0<=(A)<128]
                INY                  ;Count UP (Y) every 12 microseconds
                BNE   PREAD2         ;Exit at (Y=0) for a Max Count of 255
                DEY                  ;*: Return Last Time-Count in (Y)
MON_RTS2D       RTS                  ;* [Time=~(Y)*12us]; Return to Caller

; ==============================================================================
; Initialize Video Screen for Text Mode
; ==============================================================================
; 
INITSCR         LDA   #0             ;Clear Acc for Screen Initialization:
                STA   STATUS         ;Save Status Register in P-Reg Safe
TEXT01          LDA   LORES          ;Reset HiRes Mode to LoRes/Text Mode
TEXT02          LDA   TXTPAGE1       ;Display Text Page1; R/W Main V-RAM
TXTSET          LDA   TXTON        ;Set Screen to Text Mode
                LDA   #0             ;Clear Accumulator (Again)
                BEQ  WNDSET         ;Always Taken

; ==============================================================================
; Initialize Video Screen for Mixed Graphics & Text Mode
; ==============================================================================
; 
GRSET           LDA   TXTOFF         ;Set Screen to Graphics Mode
                LDA   MIXON         ;Set Mixed Graphics & Text Mode
                JSR   CLRTOP         ;Clear Top (40 Lines on) Lo-Res Screen
                LDA   #20            ;Normal Mixed Graphics & Text Window Top
WNDSET          STA   WNDTOP         ;Set Top of Scroll Window
                LDA   #0             ;Normal Lo-Res/Text Window Left
                STA   WNDLFT         ;Set Left Column of Scroll Window
WNDSET2         LDA   #40            ;Normal Lo-Res/Text Window Width
                STA   WNDWDTH        ;Set Width of Scroll Window
                LDA   #24            ;Normal Lo-Res/Text Window Bottom
                STA   WNDBTM         ;Set Bottom of Scroll Window
                LDA   #23            ;Normal Text Window Bottom Line Number
TABV            STA   CV             ;Place Cursor at Line (A) & Column (CH) 
                JMP   MON_VTAB       ;TAB to ROW specified in (A)

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Start of Section (FB60-FBC0): New in Autostart [New Monitor] ROM
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; 
; ==============================================================================
; Display TITLE ("Apple ][") centered on top line of Screen
; ==============================================================================
; 
APPLEII         JSR   HOME           ;Clear Text Display & Home Cursor
                LDY   #8             ;Prepare to Display 8 Title Characters
STITLE          LDA   TITLE-1,Y      ;Get a Title Character to Display
                STA   LINE1+14,Y     ;Put a Title Character in Display Memory
                DEY                  ;Reduce Loop Character Counter
                BNE   STITLE         ;Loop until all Title Characters Displayed
                RTS                  ;Return to Caller

; ==============================================================================
; Set Power-Up Reset CHKSUM [(SOFTEV+1)EOR #$A5]       [Done differently above!]
; ==============================================================================
; 
; ------------------------------------------------------------------------------
;STPWRC     [No Drop-In]         ;Never Referenced [Can Never Happen]
; (Only Exception: User-Callable Entry Point; BASIC: CALL -1,169 or CALL 64,367
; ------------------------------------------------------------------------------
; 
SETPWRC         LDA   SOFTEV+1       ;Get Soft Entry (Warm Start) Vector, High
                EOR   #$A5           ;Compute: [(SOFTEV+1)EOR #$A5]
                STA   PWREDUP        ;Power-Up Reset CHKSUM
                RTS                  ;Return to Caller

; ==============================================================================
; Pause: Check for a Computer Operator Pause Request; if Requested, Pause until
; another Key is Pressed; then continue on, unless Stop (Ctrl-C) is Requested!
; ==============================================================================
; 
VIDWAIT         CMP   #RTNH          ;Is (A)=(Carriage Return)?
                BNE   NOWAIT         ;NO, Do Not Wait
                LDY   KBD            ;YES, Has a Key been Pressed?
                BPL   NOWAIT         ;NO, Do Not Wait
                CPY   #CTRLSH        ;YES, was it a Ctrl+S Character?
                BNE   NOWAIT         ;NO, Do Not Wait
                BIT   KBDSTRB        ;YES, Clear KBD Strobe (Make KBD<128)
KBDWAIT         LDY   KBD            ;Wait until next Key to Resume
                BPL   KBDWAIT        ;Loop, Wait for Keypress
                CPY   #CTRLCH        ;Key Pressed, was it a Ctrl+C Character?
                BEQ   NOWAIT         ;YES, Do Not Wait
                BIT   KBDSTRB        ;NO, Clear KBD Strobe (Make KBD<128)
NOWAIT          JMP   VIDOUT         ;& Do as Before

; ==============================================================================
; Escape Character Handlers:
; ==============================================================================
; 
; -----------------------------------;Old Escape Character Handler:
ESCOLD          SEC                  ;Prepare for Add with Carry Set (Adds 1)
                JMP   ESC1           ;Handle Escape Character

; -----------------------------------;New Escape Character Handler:
ESCNOW          TAY                  ;Use Character as Index
                LDA   XLTBL-$C9,Y    ;Translate (I|J|K|M) to (C|B|A|D), I=$C9
                JSR   ESCOLD         ;Do Cursor Motion
                JSR   RDKEY          ;& Get in (A) & Make Cursor Char Flash
ESCNEW          CMP   #"N"      ;Was it an "N" Character?
                BCS   ESCOLD         ;YES, "N" or Greater, Do it
                CMP   #"I"      ;Was it an "I" Character?
                BCC   ESCOLD         ;YES, "I" or Less, Do it
                CMP   #"L"      ;Was it an "L" Character?
                BEQ   ESCOLD         ;YES, Do it
                BNE   ESCNOW         ;Loop: Handle New Character; Always Taken

; ==============================================================================
; NOP Free Space [that can be changed in (Apple II Plus) Emulator ROM images]:
; ==============================================================================
; 
VERSION       DFB   $EA            ;14 NOP Bytes . . .
              DFB   $EA
              DFB   $EA            ;This space could be used
              DFB   $EA            ;by anyone if this were in
              DFB   $EA            ;LC RAM instead of MB ROM!
              DFB   $EA
              DFB   $EA            ;This space (FBB3-FBBE) is used
              DFB   $EA            ;in the Apple IIE Autostart ROM
              DFB   $EA
              DFB   $EA
              DFB   $EA
              DFB   $EA
ZIDBYTE2      DFB   $EA            ;(Not Used Yet)
ZIDBYTE       DFB   $EA            ;(Not Used Yet)

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; End of Section (FB60-FBC0): New in Autostart [New Monitor] ROM
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; 
; ==============================================================================
; Calculate Text Base Address (BASH,BASL) for Left End of Screen Line Number
; (Not Window Line Number) in A-Reg [# Range: (0~23)=($00~$17)=(%00000~%10111)]
; ==============================================================================
;  BASCALC [to set Text Line Base Address (BASH,BASL)] is almost identical to 
; GBASCALC [to set Graphics Base Address (GBASH,GBASL)]
; ---------------------------vv-------------------------vv----------vv----vv----
; F847: 48 4A 29 03 09 04 85 27 68 29 18 90 02 69 7F 85 26 0A 0A 05 26 85 26 60
; FBC1: 48 4A 29 03 09 04 85 29 68 29 18 90 02 69 7F 85 28 0A 0A 05 28 85 28 60
; ------------------------------------------------------------------------------
; Note: Indexed Addressing of the Base Address ZP Pointers would allow S/R's 
; to be combined into one S/R with one or two different Entry Points to preset 
; which task is being processed (e.g., GBASL,X & GBASH,X & X=0 or X=2)
; ------------------------------------------------------------------------------
;     GBASL    EQU     $26           ;Graphics Base Address, Low
;     GBASH    EQU     $27           ;Graphics Base Address, High
;     BASL     EQU     $28           ;Text Base Address, Low
;     BASH     EQU     $29           ;Text Base Address, High
; ==============================================================================
; 
; BASCALC Must ORG $FBC1 for New Monitor to remain equal to Old Mmonitor ROM
; 
; -----------------------------------;Set Line Base Address (BASH,BASL):
;                                    ;^[RAM Address of Text Line Specified]
BASCALC         PHA                  ;Push Line Number Specified [%000ABCDE]
;              ----------------------;Compute Text Base Address, High (BASH):
                LSR              ;Shift %000ABCDE->%0000ABCD & %E->(C)**
;                                    ;[Shifts BASH->{%E->(C)**}->BASL, below]
                AND   #%00000011     ;Generate %000000CD
                ORA   #%00000100     ;Generate %000001CD
                STA   BASH           ;Set Text Base Address, High [Pages 4~7]
;              ----------------------;Compute Text Base Address, Low (BASL):
                PLA                  ;Pull Line Number Specified [%000ABCDE]
                AND   #%00011000     ;Generate %000AB000
                BCC   BASCALC2       ;Branch if %E->(C=0)**; Skip Next (Add):
                ADC   #$7F           ;Else, Add [$7F+(C=1)=$80]->[%100AB000]**
;                                    ;[Shifts BASH->{%E->(C=1)**}->BASL]
;                     ---------------;Generate: %E00AB000->%EABAB000:
BASCALC2        STA   BASL           ;Set Text Base Address, Low [%E00AB000]
                ASL              ;[(A)=(A*2)]: Generate %00AB0000
                ASL              ;[(A)=(A*2)]: Generate %0AB00000
                ORA   BASL           ;Generate %EABAB000=[%0AB00000|%E00AB000]
                STA   BASL           ;Set Text Base Address, Low [%EABAB000]
;                                    ;^[(0~$78)=(0~120)|($80~$F8)=(128~248)]
;                                    ;^[Off Screen Holes: $78~$7F & $F8~$FF]
;              ----------------------;Now (BASH,BASL)=[%0000,01CD,EABA,B000]
; 
;                                    ;------------+---------+---------+
;                                    ; Screen Line Base Addresses:    |
;                                    ;------------+---------+---------+
;                                    ;            |  BASH   |  BASL   |
;                                    ;------------+---------+---------+
;                                    ;  Top 3rd of Text Screen:       |
;                                    ;------------+---------+---------+
;                                    ;$400, 1024, %0000,0100,0000,0000;
;                                    ;$480, 1152, %0000,0100,1000,0000;
;                                    ;$500, 1280, %0000,0101,0000,0000;
;                                    ;$580, 1408, %0000,0101,1000,0000;
;                                    ;$600, 1536, %0000,0110,0000,0000;
;                                    ;$680, 1664, %0000,0110,1000,0000;
;                                    ;$700, 1792, %0000,0111,0000,0000;
;                                    ;$780, 1920, %0000,0111,1000,0000;
;                                    ;------------+---------+---------+
;                                    ;  Middle 3rd of Text Screen:    |
;                                    ;------------+---------+---------+
;                                    ;$428, 1064, %0000,0100,0010,1000;
;                                    ;$4A8, 1192, %0000,0101,1010,1000;
;                                    ;$528, 1320, %0000,0101,0010,1000;
;                                    ;$5A8, 1448, %0000,0100,1010,1000;
;                                    ;$628, 1576, %0000,0110,0010,1000;
;                                    ;$6A8, 1704, %0000,0110,1010,1000;
;                                    ;$728, 1832, %0000,0111,0010,1000;
;                                    ;$7A8, 1960, %0000,0111,1010,1000;
;                                    ;------------+---------+---------+
;                                    ;  Bottom 3rd of Text Screen:    |
;                                    ;------------+---------+---------+
;                                    ;$450, 1104, %0000,0100,0101,0000;
;                                    ;$4D0, 1232, %0000,0100,1101,0000;
;                                    ;$550, 1360, %0000,0101,0101,0000;
;                                    ;$5D0, 1488, %0000,0101,1101,0000;
;                                    ;$650, 1616, %0000,0110,0101,0000;
;                                    ;$6D0, 1744, %0000,0110,1101,0000;
;                                    ;$750, 1872, %0000,0111,0101,0000;
;                                    ;$7D0, 2000, %0000,0111,1101,0000;
;                                    ;------------+---------+---------+
;                                    ;  BASH,L:   %0000,01CD,EABA,B000;
;                                    ;------------+---------+---------+
; 
; -----------------------------------;Returns: BASH=000001CD; BASL=EABAB000
                RTS                  ;Return to Caller

; ==============================================================================
; Sound Bell                   [(*) BELLA & BELLB are Undocumented Entry Points]
; ==============================================================================
; 
; -----------------------------------;Assure Sound Bell Character:
BELL1           CMP   #BELL_H        ;Is (A) a Bell (Cntrl-G) Character?
                BNE   MON_RTS2B      ;NO, Return to Caller
; 
; (*) -------------------------------;Sound Bell regardless of Output Device:
BELLA           LDA   #64            ;Delay .01 Second
                JSR   MON_WAIT       ;Delay (26+27*Acc+5*(Acc*Acc))/2 Cycles
; 
; (*) -------------------------------;Sound Bell without first WAIT:
BELLB           LDY   #192           ;Toggle Speaker at 1 Khz for .1 Second
; 
;              ----------------------;Sound Bell Loop:
BELL2           LDA   #12            ;Toggle Speaker at 1 Khz for (Y) Time
                JSR   MON_WAIT       ;Delay (26+27*Acc+5*(Acc*Acc))/2 Cycles
                LDA   SPKR           ;Toggle Speaker Output
                DEY                  ;Reduce Loop Counter
                BNE   BELL2          ;Loop Until Done
MON_RTS2B       RTS                  ;Return to Caller

; ==============================================================================
; Output A-Reg as Text (Place Character in Screen Memory):
; ==============================================================================
; 
STORADV         LDY   CH             ;Set Y-Index to Cursor Horizontal (CH)
                STA   (BASL),Y       ;Put Char (A) in (Base Adrs) Line at (CH)
ADVANCE         INC   CH             ;Advance Cursor Horizontal (Move Right)
                LDA   CH             ;Get Cursor Horizontal
                CMP   WNDWDTH        ;Is Cursor Horizontal past Window Width?
                BCS   CARRETURN      ;YES, Return Cursor (CR) to Next Line
MON_RTS3        RTS                  ;NO, Return to Caller

; ==============================================================================
; Output A-Reg as Text (Place in Screen Memory) or Process Control Character:
; ==============================================================================
; 
VIDOUT          CMP   #$A0     ;Is (A) a Control Character [$80~$9F]?
                BCS   STORADV        ;BGE: NO, Output Char (A) as Text 
; <---[Page Boundary] (in the middle of the DWord above)
                TAY                  ;YES; Is Ctrl-Char an Inverse Video Char?
                BPL   STORADV        ;YES, Output Inverse Video Character
                CMP   #RTNH          ;NO; Is Ctrl-Char a Carriage Return (CR)?
                BEQ   CARRETURN      ;YES, Return Cursor (CR) to Next Line
                CMP   #LFH           ;NO; Is Ctrl-Char a Line Feed?
                BEQ   LINEFEED       ;If YES, Go Do a Line Feed
                CMP   #BSH           ;NO; Is Ctrl-Char a Back Space (Ctrl-H)?
                BNE   BELL1          ;NO; Go Check if it is a BELL (Ctrl-G)?
; -----------------------------------;YES, Char (A) is a Back Space (Ctrl-H)
BACKSPACE       DEC   CH             ;Reduce Cursor Horizontal
                BPL   MON_RTS3       ;If Positive, Return to Caller; Else:
;              ----------------------;Move to Rightmost Screen Column:
                LDA   WNDWDTH        ;Get Width of Scroll Window
                STA   CH             ;Set Cursor Horizontal (CH=WNDWDTH)
                DEC   CH             ;Reduce Cursor Horizontal (CH=CH-1)
;              ----------------------;Move Up (at Rightmost Screen Column):
CURSORUP        LDA   WNDTOP         ;Get Top of Scroll Window
                CMP   CV             ;Is Cursor Vertical (CV) at Top of Window?
                BCS   MON_RTS4       ;If at Top Line, Return to Caller
                DEC   CV             ;Else, Reduce Cursor Vertical (CV=CV-1)
; -----------------------------------;TAB to ROW specified in A-Reg:
MON_VTAB        LDA   CV             ;Get Cursor Vertical
VTABZ           JSR   BASCALC        ;Generate Base Address
                ADC   WNDLFT         ;Add Left Column of Scroll Window
                STA   BASL           ;Set Base Address, Low
;                                    ;^[There shouldn't be any Carryover!]
MON_RTS4        RTS                  ;Return to Caller

; ==============================================================================
; Escape Character Handler:
; ==============================================================================
; 
; ------------------------------------; Handle Escape Character
ESC1            EOR   #"@"     ;Is Char (A)=("@")?
                BEQ   HOME           ;Branch if Esc+@, Do Home & Clear
;                                    ;^[("@"=$C0)XOR("@"=$C0)=(0)**]
                ADC   #$FD           ;Is Char (A)=("A"|"B")?  [Adds (C=1)]
                BCC   ADVANCE        ;Branch if Esc+A, Advance
;                                    ;^[("@"=$C0)XOR("A"=$C1)=(1) ->
;                                    ; (1)+($FD)+(C=1)=($FF)=(-1) ->(C=0)**]
                BEQ   BACKSPACE      ;Branch if Esc+B, Backspace
;                                    ;^[("@"=$C0)XOR("B"=$C2)=(2) ->
;                                    ; (2)+($FD)+(C=1)=(0)**]
                ADC   #$FD           ;Is Char (A)=("C"|"D")?  [Adds (C=1)]
                BCC   LINEFEED       ;Branch if Esc+C, Down
;                                    ;^[("@"=$C0)XOR("C"=$C3)=(3) ->
;                                    ; (3)+($FD)+(C=1)=(1) ->(C=1)->
;                                    ; (1)+($FD)+(C=1)=($FF)=(-1) ->(C=0)**]
                BEQ   CURSORUP       ;Branch if Esc+D, Up
;                                    ;^[("@"=$C0)XOR("D"=$C4)=(4) ->
;                                    ; (4)+($FD)+(C=1)=(2) ->(C=1)->
;                                    ; (2)+($FD)+(C=1)=(0)**]
                ADC   #$FD           ;Is Char (A)=("E"|"F")?  [Adds (C=1)]
                BCC   CLREOL         ;Branch if Esc+E, Clear to End of Line
;                                    ;^[("@"=$C0)XOR("E"=$C5)=(5) ->
;                                    ; (5)+($FD)+(C=1)=(3) ->(C=1)->
;                                    ; (3)+($FD)+(C=1)=(1) ->(C=1)->
;                                    ; (1)+($FD)+(C=1)=($FF)=(-1) ->(C=0)**]
                BNE   MON_RTS4       ;Branch if Not Esc+F, Return to Caller
;                                    ;^[("@"=$C0)XOR("F"=$C6)=(6) ->
;                                    ; (6)+($FD)+(C=1)=(4) ->(C=1)->
;                                    ; (4)+($FD)+(C=1)=(2) ->(C=1)->
;                                    ; (2)+($FD)+(C=1)=(0)**]
; -----------------------------------;Else, Esc+F, Clear to End of Page
;                                    ;[Unused, User-Callable Entry Point]:
CLREOP          LDY   CH             ;Get Cursor Horizontal (CH)
                LDA   CV             ;Get Cursor  Vertical  (CV)
; -----------------------------------;Clear to End of Page Loop
;                                    ;[User-Callable Entry Point]:
CLEOP1          PHA                  ;Push Current Line (Save on STACK)
                JSR   VTABZ          ;Set Base Address (Updates BASL)
                JSR   CLREOLZ        ;Clear to End of Line (EOL) & Set Carry
                LDY   #0             ;Clear from Line Left End (CH=0) for Rest
                PLA                  ;Pull Current Line (Retrieve from STACK)
                ADC   #0             ;Advance Current Line  [Adds (C=1)]
                CMP   WNDBTM         ;Cleared to Bottom of Window?
                BCC   CLEOP1         ;NO, Keep Clearing Lines
                BCS   MON_VTAB       ;YES, Tab to Current Line; Always Taken

; ==============================================================================
; "HOME" Statement: Immediate & Deferred; No Parameters
; ==============================================================================
; Moves Cursor to Upper Left Screen Position within Scrolling Window & Clears
; all Text within Window; Same as "CALL -936" & "ESC @ RETURN"
; ==============================================================================
; 
; -----------------------------------;Initialize Cursor Vertical & Horizontal:
HOME            LDA   WNDTOP         ;Get Top of Scroll Window
                STA   CV             ;Set Cursor  Vertical  (CV)
                LDY   #0             ;Clear Y-Index Register
                STY   CH             ;Clear Cursor Horizontal (CH)
                BEQ   CLEOP1         ;Clear to End of Page; Always Taken

; ==============================================================================
; Return Cursor [Printer/Typewriter Carriage Return] (CR) to Start of Next Line:
; ==============================================================================
; Forget about Printer/Typewriter Carriage Returns; this is more about the
; Apple II Cursor (on Screen) than it is about those old mechanical devices! 
; ------------------------------------------------------------------------------
; 
; -----------------------------------;Return Cursor (CR) to Start of Next Line:
CARRETURN       LDA   #0             ;Clear Accumulator
                STA   CH             ;Clear Cursor Horizontal to Start of Line
; -----------------------------------;Down (Esc+C/Ctrl+J), Do a Line Feed:
LINEFEED        INC   CV             ;Advance Cursor Verical  to Next Line
                LDA   CV             ;Get Cursor Verical [Now Line # (0~23)]
                CMP   WNDBTM         ;Is Cursor Vertical Off Screen (CV>23)?
                BCC   VTABZ          ;NO, Set Base Address (Updates BASL)
                DEC   CV             ;YES, Reduce Cursor Vertical to Bottom
; -----------------------------------;Scroll Window Up (Line by Line)
;                                    ;[Unused, User-Callable Entry Point]:
SCROLL          LDA   WNDTOP         ;Start at Top of Scroll Window
                PHA                  ;Push Scroll Window Top (Save on STACK)
                JSR   VTABZ          ;Set Base Address (Updates BASL)
; -----------------------------------;Scrolling Loop:
;                     ---------------;Save Current Line Base Address;
;                                    ;Copy Base Address [(BASL,H)->(BAS2L,H)]:
SCRL1           LDA   BASL           ;Get Base Address (1), Low
                STA   BAS2L          ;Set Base Address Two, Low
                LDA   BASH           ;Get Base Address (1), High
                STA   BAS2H          ;Set Base Address Two, High
;                     ---------------;Initialize Y-Index Register to 
;                                    ;Rightmost Column of Scrolling Window:
                LDY   WNDWDTH        ;Get Window Width
                DEY                  ;Reduce to Rightmost Scroll Window Column
;                     ---------------;Check if at Bottom of Scrolling Window:
                PLA                  ;Pull Scroll Window Top (Retrieve STACK)
                ADC   #1             ;Advance Scroll Window Top (Now Line #)
                CMP   WNDBTM         ;Reached Bottom of Scroll Window, Done?
                BCS   SCRL3          ;BGE [Exit Loop]: YES, Go Finish Up
                PHA                  ;NO, Push Scroll Window Top (Now Line #)
                JSR   VTABZ          ;Set Base Address (Updates BASL)
;              ----------------------;Move Characters (A) Up One Line (Loop):
SCRL2           LDA   (BASL),Y       ;Get Character (on Now Line #) to Move Up
                STA   (BAS2L),Y      ;Move Up: Set Character (on Now Line # -1)
                DEY                  ;Reduce Column [Going from Right to Left]
                BPL   SCRL2          ;Move Up: Next Characater
;              ----------------------;Done with Chacracters on this Line
                BMI   SCRL1          ;Scroll Up: Next Line; Always Taken

; -----------------------------------;Scroll Window Up (Line by Line) Done;
;                                    ;Fininsh Up; Clear Bottom Line of Window:
SCRL3           LDY   #0             ;Clear (Indirect Addressing),Y-Index for:
                JSR   CLREOLZ        ;Clear to End of Line & Set Carry
                BCS   MON_VTAB       ;Always Taken
; 
; ==============================================================================
; (Esc+E): Clear from Cursor [(BASL),(CH|Y)] to End of Line [(BASL),(WNDWDTH)]:
; ==============================================================================
; 
; -----------------------------------;Clear from Cursor [(BASL),(CH)] to EOL:
CLREOL          LDY   CH             ;Get Cursor Horizontal Position
; -----------------------------------;Clear from Cursor [(BASL),(Y)] to EOL:
CLREOLZ         LDA   #$A0     ;Get a Blank/Space Character to Fill with
; -----------------------------------;Chr Fill from Cursor [(BASL),(Y)] to EOL
;                                    ;Loop [& User-Callable Entry Point]:
CLEOL2          STA   (BASL),Y       ;Set Char (A) at Line (BASL), Column (Y)
                INY                  ;Advance Column Counter
                CPY   WNDWDTH        ;Has End of Line been reached?
                BCC   CLEOL2         ;BLT [Loop]: NO, Continue Filling Line
                RTS                  ;YES, Done Filling; Return to Caller

; ==============================================================================
; Mon Wait Subroutine: [This is a Simple Algorithm for a Quadratic Equation!]
; ==============================================================================
; Wait Time is from Call (JSR MON_WAIT) to End of Return to Caller (End of RTS);
; Wait Time in Microseconds at the Non-Accelerated Speed of an Apple II Plus is:
;   [Time]=[Delay (5*(Acc*Acc)+27*Acc+26)/2 Cycles]*[1.023 Microseconds/Cycle]
; ------------------------------------------------------------------------------
; 
; -----------------------------------;Delay (26+27*Acc+5*(Acc*Acc))/2 Cycles
;                                    ;v--[Cycles/Operation]
;                                    ;6: For "JSR MON_WAIT" to get here!
MON_WAIT        SEC                  ;2: Prepare to Subtract w/o Borrow
MON_WAIT2       PHA                  ;3: Push Accumulator (Save on STACK)
MON_WAIT3       SBC   #1             ;2: Subtract w/o Borrow [A-Data-!C]
                BNE   MON_WAIT3      ;2+ Loop Until (A=0) [5 cycles/iteration]
;                                    ;   ^[4 cycles/iteration when (A=0)]
                PLA                  ;4: Pull Accumulator (Retrieve from STACK)
                SBC   #1             ;2: Subtract w/o Borrow [A-Data-!C]
                BNE   MON_WAIT2      ;2+ Loop Until (A=0) [~5*(A)+12 cycles/it]
;                                    ;   ^[~5*(A)+11 cycles/it when (A=0)]
                RTS                  ;6: Return to Caller

; ==============================================================================
; Next A4 & Next A1: Monitor General Purpose (16 Bit) Accumulator Registers
; ==============================================================================
; 
NXTA4           INC   A4L            ;Increment General Purpose A4-Reg, Low
                BNE   NXTA1          ;Branch if Not yet up to Next Page
                INC   A4H            ;Increment General Purpose A4-Reg, High
;              ----------------------;Has A1 Reached A2?
NXTA1           LDA   A1L            ;Get General Purpose A1-Reg, Low
                CMP   A2L            ;Subtract: (A)=(A1L-A2L)
                LDA   A1H            ;Get General Purpose A1-Reg, High
                SBC   A2H            ;Subtract: (A)=(A1H-A2H)
                INC   A1L            ;Increment General Purpose A1-Reg, Low
                BNE   MON_RTS4B      ;Branch if Not yet up to Next Page
                INC   A1H            ;Increment General Purpose A1-Reg, High
;              ----------------------;Caller should Check if A1 Has Reached A2:
MON_RTS4B       RTS                  ;Return to Caller

; ==============================================================================
; Internal Cassette Tape Write (Output) & Read (Input) Routines: HEADER, WRBIT,
; RDBYTE, RD2BIT, RDBIT, WRBYTE (See: "Apple II Monitors Peeled" pgs.81~84)
; ==============================================================================
; 
; ==============================================================================
; Cassette Tape Record Synchronization Header Subroutine:
; ==============================================================================
; Writes Synchronization Monotone to Audio-Out: The first part of every Tape
; Record is a 10 sec 770 hz (1300 usec/cycle) header tone (See TN/TIL# 495~496)
; ------------------------------------------------------------------------------
; (A)=[Synchronization Header Length (0.2~40 sec)]; (X)=[Audio Half-Cycle Toggle
; Count (Clear at Entry)]; (Y)=(Loop Duration Count); Writing to Tape/Audio-Out:
; (C)=[Clear for a Zero-Bit, or Set for a One-Bit (Set at Entry)]
; ------------------------------------------------------------------------------
; Write [(A)*256] 'Long-1' Half-Cycles (650 usec each); Then, Write a 'Short-0'
; Sync Bit, 2 Half-Cycles (200+250=450 usec/{1 cycle}); Normal (Not Short/Long)
; Half-Cycle Durations are 250 usec for a Zero-Bit & 500 usec for a One-Bit
; ------------------------------------------------------------------------------
; 
; -----------------------------------;Write Tape Synchronization Monotone:
HEADER          LDY   #75            ;Get Time Count for Zero-Bit Delay Loop
;                                    ;^[For 'Long-1' (650 usec) Half-Cycles]
                JSR   ZERODLY        ;Write a Half-Cycle [Returns (Y=44)]
                BNE   HEADER         ;Branch Until Done <-[when (X=0)]
                ADC   #254           ;Decrement (A) {Add w/ Carry [A+Data+C]}
;                                    ;^[Add to Subtract: {C=1}+{$FE=(-2)}=(-1)]
                BCS   HEADER         ;BGE: Branch Until Done <-[when (A=C=0)]
;              ----------------------;Finish with Sync Bit:
                LDY   #33            ;Get Time Count for Zero-Bit Delay Loop
;                                    ;^[For Sync Bit (200 usec) Half-Cycle]
; -----------------------------------;Write a Bit (2 Half-Cycles) to Tape:
WRBIT           JSR   ZERODLY        ;Write a Half-Cycle [Returns (Y=44)]
                INY                  ;Advance Time Count [Now (Y=Y+1=45)]
                INY                  ;Advance Time Count [Now (Y=Y+2=46)]
;                                    ;^[For Normal (250 usec) Half-Cycle]
;              ----------------------;Zero-Bit Delay Loop: Write a Half-Cycle
ZERODLY         DEY                  ;Reduce Time Count for Zero-Bit Delay Loop
                BNE   ZERODLY        ;Loop Until Delay Period is Done <-(Y=0)
                BCC   WRTAPE         ;Branch if Doing a Zero-Bit
;                                    ;Else, Do a One-Bit, Add more Delay:
                LDY   #50            ;Get Time Count for One-Bit Delay Loop
;                                    ;^[For Normal (250+250 usec) Half-Cycle]
;              ----------------------;One-Bit Delay Loop: Write a Half-Cycle
ONEDLY          DEY                  ;Reduce Time Count for One-Bit Delay Loop
                BNE   ONEDLY         ;Loop Until Delay Period is Done <-(Y=0)
;              ----------------------;Write (One Half-Cycle Only) to Tape:
WRTAPE          LDY   TAPEOUT        ;Toggle Audio Data Output [(Y)=(Unkown!)]
                LDY   #44            ;Return (Y=44) .. [Now (Y)=(Known Value)]
;                                    ;^[Adds Time to 2nd WRBIT Zero-Bit Delay]
                DEX                  ;Reduce (X) Audio Half-Cycle Toggle Count
                RTS                  ;Return to Caller; [Final (A=$FF):{A2RM}]

; ==============================================================================
; Read Byte Subroutine: Reads a Byte (8 Bits) from a Cassette Tape Record
; ==============================================================================
; The Duration between 2 Voltage Transitions from Tape determines whether a Bit
; is a Zero-Bit or a One-Bit; (Y) is used to Count this Period of Time; If it
; has Time to go Negative, the Duration is Longer, representing a One-Bit; If it
; does not go Negative, the Duration is Shorter, representing a Zero-Bit; Carry
; (C) is Set or Cleared, respectively, based on (Y), & Used to Rotate the Bit
; into the Accumulator (A); After 8 Bits, (A) represents a Byte Read from Tape
; ------------------------------------------------------------------------------
; 
RDBYTE          LDX   #8             ;Prepare to Read a Byte (8 Bits) from Tape
RDBYT2          PHA                  ;Push Accumulator (Save on STACK)
                JSR   RD2BIT         ;Read Two Transitions (Find Edge)
                PLA                  ;Pull Accumulator (Retrieve from STACK)
                ROL              ;Next Bit; Shift Carry into (A) Low Bit
;                                    ;& Discard Old (A) High Bit into Carry
                LDY   #$3A           ;Count for RD2BIT/RDBIT Sampling (58~0)
                DEX                  ;Reduce Bit Count
                BNE   RDBYT2         ;Loop Until Done <-(X=0)
                RTS                  ;Return to Caller

; ==============================================================================
; Read Bits Subroutines: Read Voltage Transitions (2 or 1) from a Tape Record
; ==============================================================================
;                         [See RDBYTE Description above]
; ------------------------------------------------------------------------------
; 
; -----------------------------------;Read 2 Transitions from Tape Record:
RD2BIT          JSR   RDBIT          ;Read 1st of Two Voltage Transitions
; -----------------------------------;Read 1 Transition from Tape Record:
RDBIT           DEY                  ;Reduce (Y) Until Voltage Transitions
                LDA   TAPEIN         ;Read Cassette Tape Data Input
; <---[Page Boundary] (in the middle of the DWord above)
                EOR   LASTIN         ;XOR with Last Input Voltage Detected
;                                    ;<<< LASTIN Unkown 1st time through! >>>
                BPL   RDBIT          ;Loop Until a Voltage Change is Detected
                EOR   LASTIN         ;XOR with Last Input Voltage Detected
                STA   LASTIN         ;Reset Last Input Voltage Detected
                CPY   #$80           ;Set Carry on (Y):(58~0) becoming Negative
                RTS                  ;Return to Caller

; ==============================================================================
; End Of Internal Cassette Tape Write (Output) & Read (Input) Routines
; ==============================================================================
; 
; 
; ==============================================================================
; Keyboard Character Input, Line Building, & Input Display Routines
; ==============================================================================
; Keyboard Input & Screen Output, Division Of Labor:
; ------------------------------------------------------------------------------
; Routines supporting Keyboard Input are designed to echo Keyboard Input to User
; Output (through COUT) to the Display Screen Scroll Window at the Current
; Cursor Position, & store the Characters Entered into the Keyboard Input Buffer
; ($0200~$02FF) for the convenience of the Calling Program, which may Position
; the Cursor anywhere (on Screen), before Calling the Keyboard Input Routines;
; on Entry of a Carriage Return from the Keyboard, the Keyboard Input Routines
; will Return back to the Calling Program, with the Character Count (plus one)
; in X-Reg & a Carriage Return in the Input Buffer as a Terminator; the Calling
; Program need not look within the Display Screen to Determine what was Entered;
; the X-Reg begins with a Zero, so if Five Characters are Entered, the X-Reg
; will reflect Four, although the Actual Value Returned will be Five--because
; the X-Reg is Incremented for the Carriage Return as well--[so X-Reg as the
; Character Count is actually accurate at plus one--as if (1) it started at One
; instead of Zero & (2) it is Not Counting the Carriage Return!].
; ==============================================================================
; 
; 
; ==============================================================================
; Read Key Subroutine: Makes Current Char Flash; & Puts it in (A) & (CH) in (Y)
; ==============================================================================
; RDKEY is the same as RDCHAR except that it bypasses Escape Key support--
; [because RDCHAR Calls RDKEY 1st, before doing the "ESC" Key Test!]
; ------------------------------------------------------------------------------
; 
; -----------------------------------;Get in (A) & Make Cursor Character Flash:
RDKEY           LDY   CH             ;Get Cursor Horizontal
                LDA   (BASL),Y       ;Get Char at (BASL,H) Line & Column (Y=CH)
RDKEY0          PHA                  ;Push/Save Current Character at Cursor
                AND   #%00111111     ;Truncate Character to 6 Lower Bits
                ORA   #%01000000     ;Set Bit 6 of Character to Make it Flash
                STA   (BASL),Y       ;Set Char at (BASL,H) Line & Column (Y=CH)
                PLA                  ;Pull/Retrieve Current Character at Cursor
;                                    ;Key Switch (KSW) Input Hook ...
RDKEY1          JMP   (KSWL)         ;Returns to Caller of RDKEY

; ==============================================================================
; KEYIN gets the Next Key Input from the Keyboard; 
; KEYIN is usually the Target of the Key Switch (KSW) Character Input Hook
; ==============================================================================
; 
; -----------------------------------;Get Key Press @ Keyboard Input Register:
KEYIN           INC   RNDL           ;Advance Keyin Random Counter Value, Low
                BNE   KEYIN2         ;Branch if High Advance Not Needed Yet
                INC   RNDH           ;Advance Keyin Random Counter Value, High
KEYIN2          BIT   KBD            ;Check Keyboard Input Reg for a Key Press
                BPL   KEYIN          ;Branch if No Key has been Pressed
                STA   (BASL),Y       ;Store (A) at (BASL,H) Line & Column (Y)
                LDA   KBD            ;Read Keyboard Input Reg; Get Key Pressed
                BIT   KBDSTRB        ;Clear KBD Strobe (KBD<128) for Next Key
                RTS                  ;Return to Caller

; ==============================================================================
; Escape Character Handler:
; ==============================================================================
; 
ESC             JSR   RDKEY          ;Get in (A) & Make Cursor Character Flash
                JSR   ESCNEW         ;Handle Escape Character [Doesn't Return!]
; 
; ==============================================================================
; Read Character Subroutine: Read a Character into (A)
; ==============================================================================
; 
RDCHAR          JSR   RDKEY          ;Get in (A) & Make Cursor Character Flash
                CMP   #ESCH          ;Is it The Escape Character?
                BEQ   ESC            ;YES, Handle The Escape Character
                RTS                  ;NO, Return to Caller

; ==============================================================================
; NOTCR: Character Input is NOT a Carriage Return; 
;        So, send it as Non Inverse Character to COUT
; ==============================================================================
; Receives control w/ Character of Interest in Input Buffer at ($0200,X)
; ------------------------------------------------------------------------------
; 
NOTCR           LDA   INVFLG         ;Get Current Setting of INVFLG (Text-Mask)
;                                    ;^[Normal=$FF, Flash=$7F, Inv=$3F]
                PHA                  ;Push/Save Setting of INVFLG
                LDA   #$FF           ;Get Normal-Text Text-Mask Value
                STA   INVFLG         ;Set Invers Flag/Mask to Normal-Text Value
                LDA   BUF,X       ;Get Character of Interest as Normal-Text
                JSR   COUT           ;Print Char of Interest as Normal-Text
                PLA                  ;Pull/Retrieve Prior Setting of INVFLG
                STA   INVFLG         ;Restore Current Setting of INVFLG
; --<Undocumented User Entry Point>--;Backspace or Cancel Check: 
NOTCR5          LDA   BUF,X       ;Get Character of Interest as was before
                CMP   #BSH           ;Is it a Ctrl-H: Backspace?
                BEQ   BCKSPC         ;Branch if it's a Backspace
                CMP   #CTRLXH        ;Is it a Ctrl-X: Cancelation?
                BEQ   CANCEL         ;Branch if it's a Cancelation
; --<Undocumented User Entry Point>--;Margin Check:
NOTCR4          CPX   #248           ;Is Character Pointer Near End of BUF?
; --<Undocumented User Entry Point>--;Wait for Next Char or a Carriage Return:
NOTCR3          BCC   NOTCR1         ;Branch if Not Near End of BUF
; --<Undocumented User Entry Point>--;Sound Warning Bell & Wait (as above):
NOTCR2          JSR   BELL           ;Else, Sound Bell, Warn: Near BUF End
NOTCR1          INX                  ;Advance to Next Character of Interest
                BNE   NXTCHAR        ;Branch if Not at Input Buffer End ($0300)
CANCEL          LDA   #"\"     ;Terminate Input w/ Backslash [Ctrl+X|EOL]
                JSR   COUT           ;Print the Terminal Backslash [)-:RIP:-(]
GETLNZ          JSR   CROUT          ;Print Carriage Return (Ctrl-M) Character
; -----------------------------------;Get Input with Prompt Entry Point:
GETLN           LDA   PROMPT         ;Get Command Prompt Character
GETLN0          JSR   COUT           ;Print Command Prompt Character
; -----------------------------------;Get Input without Prompt Entry Point:
;                                    ;Init Input Index & it will Reduce to 0:
GETLN1          LDX   #1             ;Point to Start of Input Buffer +1
BCKSPC          TXA                  ;Get Current Ptr to Character of Interest
                BEQ   GETLNZ         ;Branch if Char Ptr is at BUF Zero|End
                DEX                  ;Else, Retreat to Prior Char of Interest
NXTCHAR         JSR   RDCHAR         ;Read Current Cursor Character into (A)
                CMP   #PICK          ;Is it a Right-Arrow [Ctrl-U (NAK)]?
                BNE   CAPTST         ;Branch if NOT Right-Arrow [Ctrl-U (NAK)]
;                                    ;Else, Use Screen Char under Right-Arrow:
                LDA   (BASL),Y       ;Get Char at (BASL,H) Line & Column (Y)
CAPTST          CMP   #"`"     ;What is the Upper/Lower Case of Char (A)?
                BCC   ADDINP         ;BLT: Branch if Uppercase
                AND   #%11011111     ;Else, GE: Change Lowercase to Uppercase
ADDINP          STA   BUF,X       ;Set it in Input Line (to Uppercase)
                CMP   #RTNH          ;Is it a Carriage Return (Ctrl-M) Char?
                BNE   NOTCR          ;Branch if Not a Carriage Return (Ctrl-M)
CROUT1          JSR   CLREOL         ;Else, it's a CR, Clear to End of Line
; 
; ==============================================================================
; Print Carriage Return: Display Screen Scroll Window Output Routine
; ==============================================================================
; 
CROUT           LDA   #RTNH          ;Get a Carriage Return (Ctrl-M) Character
                BNE   COUT           ;Print (A) to Output Device; Always Taken

; ==============================================================================
; End Of Keyboard Character Input, Line Building, & Input Display Routines
; ==============================================================================
; 
; ==============================================================================
; Memory Dump Routines:
; ==============================================================================
; 
; ==============================================================================
; Print Memory Address: 
; ==============================================================================
; Print Carriage Return & Monitor General Purpose A1-Reg or Progrram Counter as
; 16-Bit Integer [(Y,X)={High,Low}] in Hexadecimal
; ------------------------------------------------------------------------------
; 
; -----------------------------------;Print Monitor General Purpose A1-Reg:
PRA1            LDY   A1H            ;Get General Purpose A1-Reg, High
                LDX   A1L            ;Get General Purpose A1-Reg, Low
; -----------------------------------;Print Carriage Return & 16-Bit Integer:
PRYX2           JSR   CROUT          ;Print Carriage Return (Ctrl-M) Character
; --<Undocumented User Entry Point>--;Sound Warning Bell & Wait (as above):
PRYX3           JSR   PRNTYX         ;Print 16-Bit Integer [(Y,X)={High,Low}]
                LDY   #0             ;Clear Y-Index Register
                LDA   #"-"     ;Get a Dash
                JMP   COUT           ;Print the Dash

; ==============================================================================
; Examine Eight Routine: Prints <= 8 Sequential Memory Locations Per Line in Hex
; ==============================================================================
; 
; -----------------------------------;[Y-Reg Must Be Zero on Entry]
XAM8            LDA   A1L            ;Get Monitor General Purpose A1-Reg, Low
                ORA   #%00000111     ;Get [(A1)OR(#7)]->[(A1)MOD(8 Bytes)]
                STA   A2L            ;Set Monitor General Purpose A2-Reg, Low
                LDA   A1H            ;Get Monitor General Purpose A1-Reg, High
                STA   A2H            ;Set Monitor General Purpose A2-Reg, High
; -----------------------------------;Modulus Check [(Adrs)MOD(8 Bytes)=(0)?]:
MOD8CHK         LDA   A1L            ;Get Monitor General Purpose A1-Reg, Low
                AND   #%00000111     ;[(A1)&(#7)]->[(A1)MOD(8 Bytes)] = Zero?
                BNE   DATAOUT        ;Branch if NOT at 1st of Mem Mod 8 Bytes
; ** Main Memory Dump Entry Point ** ;Examine Memory from (A1L,H) to (A2L,H):
XAM             JSR   PRA1           ;Else, Print Memory Address & a Dash, 1st
; -----------------------------------;Print Output Data to Output Device:
DATAOUT         LDA   #$A0     ;Get a Space Char to Print (between parts)
                JSR   COUT           ;Print A-Reg to Output Device
                LDA   (A1L),Y        ;Get a Memory Byte (1 of <= 8 in Sequence)
                JSR   PRBYTE         ;Print A-Reg as Two-Digit Hex Number
                JSR   NXTA1          ;Increment A1 & Compare to A2
                BCC   MOD8CHK        ;BLT: Branch if (A1) has NOT Reached (A2)
                RTS                  ;Return to Caller

; ==============================================================================
; "Is Monitor Mode: Examine, Add (Plus), or Subtract (Minus)?" (XAMPM) Routine: 
; ==============================================================================
; For Mode Commands: Address Range Delimiter ("."); Add ("+"); or Subtract ("-")
; [Command Characters are converted to Command Tokens during the Input Process!]
; ------------------------------------------------------------------------------
; 
XAMPM           LSR              ;Shift (A*):LSB into Carry Flag
                BCC   XAM            ;Branch if [A*:Bit 0 was 0]; Do XAM
;                                    ;^[Examine Memory from (A1L,H) to (A2L,H)]
                LSR              ;Shift LSB into Carry Flag (Discarded)
                LSR              ;Shift LSB into Carry Flag
                LDA   A2L            ;Get Monitor General Purpose A2-Reg, Low
                BCC   ADD            ;Branch if [A*:Bit 2 was 0]; Do ADD (Plus)
;                                    ;Else [A*:Bit 2 was 1] Do SUBTRACT (Minus)
                EOR   #%11111111     ;Negate (A) <-[from (A2L)]
ADD             ADC   A1L            ;(A) = (A1L) + [{+|-}(A)<-(A2L)] + (C=1)
                PHA                  ;Push Result
                LDA   #"="     ;Print "=", then Result:
                JSR   COUT           ;Print (A) to Output Device
                PLA                  ;Pull Result
; 
; ==============================================================================
; Print A-Reg as Two-Digit Hex Number:
; ==============================================================================
; 
PRBYTE          PHA                  ;Push Accumulator (A); Save on STACK
                LSR              ;Shift High Nibble
                LSR              ;... to Low Nibble
                LSR              ;These 4 Shifts also Clear High Nibble
                LSR              ;Now Low Nibble is what High Nibble was
                JSR   PRHEXZ         ;Print Hi-Digit in Lo-Nibble as Hex Number
                PLA                  ;Pull Accumulator (A); Retrieve from STACK
; <User Entry Point (Label Not Used)>;Print Low Nibble as Hex Number [0~9,A~F]:
PRHEX           AND   #%00001111     ;Mask Off High Nibble & Keep Low Nibble
PRHEXZ          ORA   #"0"     ;Assure Byte is Hex Number Chr [0~9 & A~F]
                CMP   #":"     ;Assure Byte is Dec Number Chr [0~9]<(":")
                BCC   COUT           ;Print # Now if Dec Number Chr [0~9]<(":")
                ADC   #6             ;Else Assure Letter [A~F]>=[(":")+6+(C=1)]
; 
; ==============================================================================
; Display Screen Scroll Window Output Routines:
; ==============================================================================
; 
; ==============================================================================
; Character Output Routine: Jump (Indirectly via Vector) to User Output Routine
; ==============================================================================
; 
COUT            JMP   (CSWL)         ;Print Accumulator (A) to Output Device

; ==============================================================================
; End of Memory Dump Routines
; ==============================================================================
; 
; ==============================================================================
; Character Output Routines:
; ==============================================================================
; COUT1 is usually the Target of the "Character Switch (CSW)" Output Hook/Vector
; ------------------------------------------------------------------------------
; COUT1: Write Byte in A-Reg to Display Screen at Current Cursor Position
;        [(CV),(CH)] using Inverse Flag Mask & supporting Cursor Move:
; ------------------------------------------------------------------------------
; COUTZ: Write Byte in A-Reg to Display Screen at Current Cursor Position
;        [(CV),(CH)] supporting Cursor Move but NOT using Inverse Flag Mask:
; ------------------------------------------------------------------------------
; 
COUT1           CMP   #$A0     ;Is Char (A) a Ctrl-Char or Printable?
                BCC   COUTZ          ;BLT: Don't Output Ctrl Chars as Inverse
                AND   INVFLG         ;Text Mask (Normal=$FF|Flash=$7F|Inv=$3F)
COUTZ           STY   YSAV1          ;Save Y-Reg
                PHA                  ;Push/Save A-Reg
                JSR   VIDWAIT        ;Go Check for Pause (Ctrl-S)
; --<Undocumented User Entry Point>--;Restore A-Reg & Y-Reg (frm STACK & YSAV1)
COUTA           PLA                  ;Pull/Retrieve A-Reg
                LDY   YSAV1          ;Retrieve Y-Reg
                RTS                  ;Return to Caller

; ==============================================================================
; End of Display Screen Scroll Window Output Routines
; ==============================================================================
; 
; <---[Page Boundary]
; 
; ==============================================================================
; Monitor Command Handlers: $FE is the High/Page Address of All Monitor Command
; Handlers Referenced via the Monitor Command Subroutine Address Table (@ $FFE3)
; ==============================================================================
; 
; ==============================================================================
; More Memory Dump Routines:
; ==============================================================================
; 
; ==============================================================================
; Monitor (& Miniassembler) "Blank" Command Handlers:
; ==============================================================================
; 
; -----------------------------------;Handle Carriage Return as a Blank:
BL1             DEC   YSAV           ;Reduce Monitor Command Processing Value
                BEQ   XAM8           ;Branch if MCPV is Zero; Do Memory Dump
; -----------------------------------;Monitor Blank Space Command Handler;
;                                    ;Referenced via Subroutine Address Table:
BLANK           DEX                  ;Reduce X-Index Register Value
                BNE  MDZSET         ;Branch if (X<>0); Save Token as Mode
                CMP   #":"     ;Are we in Data-Store/Fill-Memory Mode?
                BNE   XAMPM          ;NO, Do: "Examine|Add|Subtract Mode?"
                STA   MODE           ;YES, Save ":" Token as Mode
                LDA   A2L            ;Get Monitor General Purpose A2-Reg, Low
                STA   (A3L),Y        ;Set (A3-Reg),Y
                INC   A3L            ;Up Monitor General Purpose A3-Reg, Low
                BNE   MON_RTS5       ;Branch if No Carryover, yet
                INC   A3H            ;Up Monitor General Purpose A3-Reg, High
MON_RTS5        RTS                  ;Return to Caller

; ==============================================================================
; Monitor Mode Commands Handler:
; ==============================================================================
; Subtract ("-"), Add ("+"), Fill Memory (":"), or Address Range Delimiter (".")
; [Command Characters are converted to Command Tokens during the Input Process!]
; ------------------------------------------------------------------------------
; 
; -----------------------------------;Mode ("-"|"+"|":"|".") Commands Handler;
;                                    ;Referenced via Subroutine Address Table:
SETMODE         LDY   YSAV           ;Get Index for Monitor Command Processing
                LDA   BUF-1,Y     ;Get Command Token from Input Buffer
MDZSET          STA   MODE           ;Save Command Token as Monitor Mode
; -----------------------------------;JSR here to determine where one is:
; <User Entry Point (Label Not Used)>;[A JSR to an RTS STACKs Current Address]
IDROUTINE       RTS                  ;Return to Caller

; ==============================================================================
; End of More Memory Dump Routines:
; ==============================================================================
; 
; ==============================================================================
; Monitor "<" Move/Verify Delimiter
; ==============================================================================
; 
; -----------------------------------;Copy A2 (2 bytes) to A4 & A5;
;                                    ;Referenced via Subroutine Address Table:
LT              LDX   #1             ;Get Index to do High Bytes 1st
LT2             LDA   A2L,X          ;Get Monitor General Purpose A2-Reg, Hi/Lo
                STA   A4L,X          ;5et Monitor General Purpose A4-Reg, Hi/Lo
                STA   A5L,X          ;5et Monitor General Purpose A5-Reg, Hi/Lo
                DEX                  ;Reduce Index to do Low Bytes Last
                BPL   LT2            ;Loop Once to do Low Bytes Last
                RTS                  ;Then, Return to Caller

; ==============================================================================
; Monitor Move Memory ("M") Command Handler: *Adrs1<Adrs2.Adrs3M
; ==============================================================================
; 
; -----------------------------------;Copy/Move Bytes from (A1~A2),Y to (A4),Y;
;                                    ;Referenced via Subroutine Address Table:
MOVE            LDA   (A1L),Y        ;Get Byte at Source Address (A1)
                STA   (A4L),Y        ;Set Byte at Destination Address (A4)
                JSR   NXTA4          ;Increment General Purpose A4 & A1 Regs
                BCC   MOVE           ;BLT: Branch if A1 has NOT Reached A2
                RTS                  ;Return to Caller

; ==============================================================================
; Monitor Verify Memory ("V") Command Handler: *Adrs1<Adrs2.Adrs3V
; ==============================================================================
; 
; -----------------------------------;Verify Bytes from (A1~A2),Y with (A4),Y;
;                                    ;Referenced via Subroutine Address Table:
VFY             LDA   (A1L),Y        ;Get Byte at Source Address (A1)
                CMP   (A4L),Y        ;Compare Byte at Destination Address (A4)
                BEQ   VFYOK          ;Branch if Both are Identical; Do Next
; -----------------------------------;Else, Verify Failed:
                JSR   PRA1           ;Print Memory Address
                LDA   (A1L),Y        ;Get Byte at Source Address (A1)
                JSR   PRBYTE         ;Print A-Reg as Two-Digit Hex Number
                LDA   #$A0     ;Get a Space Character
                JSR   COUT           ;Print Char (A) to Output Device
                LDA   #"("     ;Get an Opening Parenthesis
                JSR   COUT           ;Print Char (A) to Output Device
                LDA   (A4L),Y        ;Get Byte at Destination Address (A4)
                JSR   PRBYTE         ;Print A-Reg as Two-Digit Hex Number
                LDA   #")"     ;Get an Closing Parenthesis
                JSR   COUT           ;Print Char (A) to Output Device
; -----------------------------------;Verify Succeeded; Do Next Byte:
VFYOK           JSR   NXTA4          ;Increment General Purpose A4 & A1 Regs
                BCC   VFY            ;BLT: Branch if A1 has NOT Reached A2
                RTS                  ;Return to Caller

; ==============================================================================
; Monitor List ("L") Command Handler: *AdrsL
; ==============================================================================
; Disassembles 20 Instructions per List ("L") Command [e.g., *AdrsLL; *LL; *LLL]
; If User Specified an Address, then (X) is Not Zero (0) & should be One (1)!
; ------------------------------------------------------------------------------
; 
; -----------------------------------;Disassemble 20 Instruction Lines;
;                                    ;Referenced via Subroutine Address Table:
MON_LIST        JSR   A1PC           ;Copy A1 (2 bytes) to PC if Specified
                LDA   #20            ;Prepare to Disassemble 20 Lines
MON_LIST2       PHA                  ;Push Line Count
                JSR   INSTDSP        ;Disassemble & Print Instruction at PC
                JSR   PCADJ          ;Add (A+C) to Instruction Address (PCL,H)
                STA   PCL            ;Save Updated Program Counter, Low
                STY   PCH            ;Save Updated Program Counter, High
                PLA                  ;Pull Line Count
                SEC                  ;Prepare to Subtract w/o Borrow [A-Data-!C]
                SBC   #1             ;Reduce Line Count
                BNE   MON_LIST2      ;Loop Until Done: Disassembled 20 Lines
                RTS                  ;Return to Caller

; ==============================================================================
; Copy A1 (2 bytes) to PC if Specified (X=1):      [<<< or Bug: if (0>X>1)! >>>]
; ==============================================================================
; If User Specified an Address, then (X) is Not Zero (0) & should be One (1)!
; ------------------------------------------------------------------------------
; 
; -----------------------------------;Copy A1 (2 bytes) to PC if Specified;
;                                    ;<<< (X) must be (0|1) upon Entry >>>:
A1PC            TXA                  ;Check Index to do High Bytes 1st
                BEQ   A1PCRTS        ;Return to Caller if (X) is Zero (<1)
;                                    ;<<< Catastrophic to A1~ if (0>X>1) >>>:
A1PCLP          LDA   A1L,X          ;Get Monitor General Purpose A1-Reg, Hi/Lo
                STA   PCL,X          ;5et Monitor General Purpose PC-Reg, Hi/Lo
                DEX                  ;Reduce Index to do Low Bytes Last
                BPL   A1PCLP         ;Loop Once to do Low Bytes Last
A1PCRTS         RTS                  ;Return to Caller

; ==============================================================================
; Monitor Set Inverse Video ("I") Command Handler: Black Chr on White Background
; ==============================================================================
; 
; -----------------------------------;Set Inverse Video;
;                                    ;Referenced via Subroutine Address Table:
SETINV          LDY   #$3F           ;Get Text Mask (Invese=$3F)
                BNE  IFLGSET        ;Always Taken

; ==============================================================================
; Monitor Set Normal Video ("N") Command Handler: White Chr on Black Background
; ==============================================================================
; 
; -----------------------------------;Set Normal Video;
;                                    ;Referenced via Subroutine Address Table:
NORMSET         LDY   #$FF           ;Get Text Mask (Normal=$FF)
; -----------------------------------;Set Inverse Flag (from Y-Reg):
IFLGSET         STY   INVFLG         ;Set Text Mask
;                                    ;^[Normal  = $FF = %11111111: N=%1 & V=%1]
;                                    ;^[Flash   = $7F = %01111111: N=%0 & V=%1]
;                                    ;^[Inverse = $3F = %00111111: N=%0 & V=%0]
                RTS                  ;Return to Caller

; ==============================================================================
; Reset "Key Switch (KSW)" Input Vector to KEYIN ($FD1B):
; ==============================================================================
; 
KBDSET          LDA   #>KSWL         ;Get Zero-Page Address of KSW, High (=0)
INPORT          STA   A2L            ;Set Monitor General Purpose A2-Reg, Low
; 
; ==============================================================================
; Monitor Set IN# Slot ("Ctrl+K") Command Handler: *<Slot# {0~7}><Ctrl+K>
; ==============================================================================
; 
; -----------------------------------;Set IN# Slot ("Ctrl-K"); 
;                                    ;Referenced via Subroutine Address Table:
MON_INPRT       LDX   #KSWL          ;Get Zero-Page Address of KSW, Low
                LDY   #<KEYIN        ;Get Address of KEYIN, Low
                BNE   IOPRT          ;Always Taken

; ==============================================================================
; Reset "Character Switch (CSW)" Output Vector to COUT1 ($FDF0):
; ==============================================================================
; 
VIDSET          LDA   #>CSWL         ;Get Zero-Page Address of CSW, High (=0)
OUTPORT         STA   A2L            ;Set Monitor General Purpose A2-Reg, Low
; 
; ==============================================================================
; Monitor Set PR# Slot ("Ctrl+P") Command Handler: *<Slot# {0~7}><Ctrl+P>
; ==============================================================================
; 
; -----------------------------------;Set PR# Slot ("Ctrl+P");
;                                    ;Referenced via Subroutine Address Table:
OUTPRT          LDX   #CSWL          ;Get Zero-Page Address of CSW, Low
                LDY   #<COUT1        ;Get Address of COUT1, Low
; 
; ==============================================================================
; Set Input/Output Vector (Port/Slot):
; ==============================================================================
; 
IOPRT           LDA   A2L            ;Get Monitor General Purpose A2-Reg, Low
                AND   #%00001111     ;Clear High Nibble & Keep Low Nibble
                BEQ   IOPRT1         ;Branch if Result is Zero (Page/Slot)
                ORA   #>IOADR        ;Set to Slot I/O Addresses ($CS00), High
                LDY   #0             ;Clear Y-Index Register (Force Branch)
                BEQ   IOPRT2         ;Always Taken

IOPRT1          LDA   #CIOPG         ;Get Mon Char I/O S/R Vectors Page Adrs
;                                    ;^[KEYIN ($FD1B) & COUT1 ($FDF0) S/Rs]
; <*** A Great User Entry Point! ***>;Set Any 2 Byte ZP Location Based on (X);
;                                    ;LOC0: Preset to JMP OpCode ($4C); (X=1):
IOPRT2          STY   LOC0,X         ;Set BASIC Soft/Warm/Ctrl-C Entry, Low
                STA   LOC1,X         ;Set BASIC Soft/Warm/Ctrl-C Entry, High
                RTS                  ;Return to Caller

; ==============================================================================
; 
MON_NOP3        NOP                  ;Fill
MON_NOP4        NOP                  ;Fuller;-)
; 
; ==============================================================================
; Monitor Cold Start BASIC: ("Ctrl-B") Command Handler: *<Ctrl-B><Return>
; ==============================================================================
; Jump to [Integer/Applesoft] BASIC [Hard/Cold/Control-B Entry Point (With
; Complete Reinitialization)]
; ------------------------------------------------------------------------------
; 
; -----------------------------------;Referenced via Subroutine Address Table:
XBASIC          JMP   BASIC          ;Cold Start BASIC ("Ctrl-B")

; 
; ==============================================================================
; Monitor Warm Start BASIC: ("Ctrl-C") Command Handler: *<Ctrl-C><Return>
; ==============================================================================
; Jump to [Integer/Applesoft] BASIC [Soft/Warm/Control-C Entry Point (Without
; Reinitialization of Symbol-Table, Variables or Data)]
; ------------------------------------------------------------------------------
; 
; -----------------------------------;Referenced via Subroutine Address Table:
BASCONT         JMP   BASIC2         ;Warm Start BASIC ("Ctrl-C")

; ==============================================================================
; Monitor Execute a Program ("G") Command Handler: *AdrsG
; ==============================================================================
; Jumps to Address Specified in Program Counter (PC) with 6502 Registers
; Restored from Save Area
; ------------------------------------------------------------------------------
; 
; -----------------------------------;Referenced via Subroutine Address Table:
GO              JSR   A1PC           ;Copy A1 (2 bytes) to PC if Specified
;              ----------------------;<Undocumented User Entry Point>:
GO1             JSR   MON_RESTORE    ;Restore (P), (A), (X), & (Y) Registers
;              ----------------------;<Undocumented User Entry Point>:
GO2             JMP   (PCL)          ;Go to User Subroutine [(PCL,H)=($3A,$3B)]

; ==============================================================================
; Monitor Display Registers ("Ctrl-E") Command Handler: *<Ctrl-E>
; ==============================================================================
; Display Current Values of A-Reg, X-Reg, Y-Reg, P-Reg, & S-Reg
; ------------------------------------------------------------------------------
; 
; -----------------------------------;Referenced via Subroutine Address Table:
REGZ            JMP   REGDSP         ;Show (A), (X), (Y), (P), & (S) Registers

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Start of Section (FEC2-FEC9): New in Autostart [New Monitor] ROM
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; 
; ==============================================================================
; Monitor Trace "T" Command Handler: *AdrsT                      [NOT USED NOW!]
; ==============================================================================
; 
; -----------------------------------;Referenced via Subroutine Address Table:
TRACE_RTS       RTS                  ;TRACE is Gone; This RTS is Not Used!

                NOP                  ;TRACE is now like USR (via CHRTBL)*
; 
; ==============================================================================
; Monitor Step "S" Command Handler: *AdrsS                       [NOT USED NOW!]
; ==============================================================================
; 
STEPZ_RTS       RTS                  ;STEP is Gone; This RTS is Not Used!

; -----------------------------------;Referenced via Subroutine Address Table:
STEPZ_USR       NOP                  ;STEP is now like USR (via CHRTBL)*
                NOP                  ;Now, the STEP (S) Command is the
                NOP                  ;same as the User (Ctrl-Y) Command
                NOP                  ;Do Nothing Else
                NOP                  ;*This whole S/T code block isn't used now!
; 
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; End of Section (FEC2-FEC9): New in Autostart [New Monitor] ROM
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; 
; ==============================================================================
; Monitor User ("Ctrl-Y") Command Handler: *<Ctrl-Y>
; ==============================================================================
; 
; -----------------------------------;Referenced via Subroutine Address Table:
USR             JMP   USRADDR        ;JMP to Autostart User Vector ("Ctrl-Y")

; 
; ==============================================================================
; Monitor WRITE to Audio Cassette Tape ("W") Command Handler: *Adrs1.Adrs2W
; ==============================================================================
; Writes 10 second Header Monotone to Audio-Out, followed by a Synchronization
; Bit, then the contents of the memory specified, then a one byte CheckSum
; ------------------------------------------------------------------------------
; Enter with: (A1L,A1H)=($3C,$3D)=(Address of first Data Byte)
;             (A2L,A2H)=($3E,$3F)=(Address of  last Data Byte)
; ------------------------------------------------------------------------------
; [See "A2 Monitors Peeled" pgs.81~84, TN/TIL# 495~496, & RDBYTE Description ^^]
; ------------------------------------------------------------------------------
; 
; -----------------------------------;Referenced via Subroutine Address Table:
MON_WRITE       LDA   #64            ;Prep to Write [(A)*256] Half-Cycles
;                                    ;^[For 'Long-1' (650 usec) Half-Cycles]
                JSR   HEADER         ;Write 10 second Header [10,649,600 usec]
;                                    ;^[A-Reg, X-Reg & Y-Reg are Altered!]
;              ----------------------;Write Memory Data to Cassette Tape Record
                LDY   #39            ;Set Half-Cycle Duration Counter
WR1             LDX   #0             ;Clear Indexed Indirect Addressing Index
                EOR   (A1L,X)        ;Get (A)=(A)XOR(A1L) [1st Time (A=$FF)]
                PHA                  ;Push XOR Result (Running CheckSum)
                LDA   (A1L,X)        ;Get a Memory Byte
                JSR   WRBYTE         ;Write 8 Bit Byte to Cassette Tape Record
                JSR   NXTA1          ;Increment A1 & Compare to A2
                LDY   #29            ;Set Half-Cycle Duration Counter
                PLA                  ;Pull XOR Result (Running CheckSum)
                BCC   WR1            ;BLT: Loop if A1 has NOT Reached A2
;              ----------------------;Write CheckSum to Cassette Tape Record
                LDY   #34            ;Set Half-Cycle Duration Counter
                JSR   WRBYTE         ;Write 8 Bit Byte to Cassette Tape Record
                BEQ   BELL           ;(X=0): Always Taken
; 
; ==============================================================================
; Internal Cassette Tape Write (Output) & Read (Input) Routines: HEADER, WRBIT,
; RDBYTE, RD2BIT, RDBIT, WRBYTE (See: "Apple II Monitors Peeled" pgs.81~84)
; ==============================================================================
; 
; ==============================================================================
; Write Byte Subroutine: Writes a Byte (8 Bits) to a Cassette Tape Record
; ==============================================================================
; <---["Feed Me!"--From the 1960 (J.Nickolson) Movie: "Little Shop of Horrors"]
;     [<Reminder>--Your Cassette Tape Recorder is hungry!  Feed it a Byte.;-D]
; ------------------------------------------------------------------------------
; 
WRBYTE          LDX   #16            ;Get (X) Audio Half-Cycle Toggle Count
WRBYT2          ASL              ;Shift High Bit into Carry
                JSR   WRBIT          ;Write a Bit [Returns: (X=X-2)]
                BNE   WRBYT2         ;Branch Until Done <-[when (X=0)]
                RTS                  ;Return to Caller

; ==============================================================================
; 2nd End Of Internal Cassette Tape Write (Output) & Read (Input) Routines
; ==============================================================================
; 
; 
; ==============================================================================
; Monitor End Input ("Carriage Return") Command Handler: *<Some Input><Ctrl-M>
; ==============================================================================
; 
; -----------------------------------;Referenced via Subroutine Address Table:
CRMON           JSR   BL1            ;Handle Carriage Return as a Blank
                PLA                  ;Pull/Discard Return Address, Low
                PLA                  ;Pull/Discard Return Address, High
                BNE   MONZ           ;Restart Monitor ("*" Prompt) Silently
; 
; ==============================================================================
; Monitor READ from Audio Cassette Tape ("R") Command Handler: *Adrs1.Adrs2R
; ==============================================================================
; Reads Tape Records from Audio-in, placing the input into the memory range
; specified, then a one byte CheckSum
; ------------------------------------------------------------------------------
; Enter with: (A1L,A1H)=($3C,$3D)=(Address of first Data Byte)
;             (A2L,A2H)=($3E,$3F)=(Address of  last Data Byte)
; ------------------------------------------------------------------------------
; [See "A2 Monitors Peeled" pgs.81~84, TN/TIL# 495~496, & RDBYTE Description ^^]
; ------------------------------------------------------------------------------
; 
; -----------------------------------;Referenced via Subroutine Address Table:
MON_READ        JSR   RD2BIT         ;Read Two Transitions (Find Edge)
; <---[Page Boundary]
                LDA   #22            ;Prep to Write [(A)*256] Half-Cycles
;                                    ;^[For 'Long-1' (650 usec) Half-Cycles]
; -----------------------------------;Entry Point to Read Shape Table
; <<< DANGEROUS if Accidentally Tape Recording instead of Playing Tape!  But,
; for a Program Tape, Accidentally Recording would be BAD all by itself! >>>:
MON_READ2       JSR   HEADER         ;Write used to Delay about 3.5 seconds
;                                    ;Writes 3.7 second Header [3,660,800 usec]
;                                    ;^[A-Reg, X-Reg & Y-Reg are Altered!]
                STA   CHKSUM         ;Initialize CheckSum (A=$FF):[A2RM]
                JSR   RD2BIT         ;Read Two Transitions (Find Edge)
;                                    ;Find 'Short-0' Sync Bit:
MON_RD2         LDY   #36            ;Set Half-Cycle Duration Counter
                JSR   RDBIT          ;Read 1 Transition from Tape Record
                BCS   MON_RD2        ;BGE: Loop Until 'Short-0' Sync Bit Found
                JSR   RDBIT          ;Skip Sync-Bit's 2nd Half-Cycle
                LDY   #59            ;Set Half-Cycle Duration Counter
MON_RD3         JSR   RDBYTE         ;Read 8 Bit Byte from Cassette Tape Record
                STA   (A1L,X)        ;Store Byte in Memory Range Specified
                EOR   CHKSUM         ;Compute New Running CheckSum
                STA   CHKSUM         ;Save New Running CheckSum
                JSR   NXTA1          ;Increment A1 & Compare to A2
                LDY   #53            ;Set Half-Cycle Duration Counter
                BCC   MON_RD3        ;BLT: Loop if A1 has NOT Reached A2
                JSR   RDBYTE         ;Read CheckSum Byte from Tape Record
                CMP   CHKSUM         ;Do the two CheckSums Match?
                BEQ   BELL           ;YES, Sound Bell & Return to Caller
; <User Entry Point (Label Not Used)>;Print "ERR" & Bell to Outpud Device:
MON_RDERR       LDA   #"E"     ;Get 1st Letter Char to Print
                JSR   COUT           ;Print A-Reg to Output Device
                LDA   #"R"     ;Get 2nd & 3rd Letter Char to Print
                JSR   COUT           ;Print A-Reg to Output Device
                JSR   COUT           ;Print A-Reg to Output Device
BELL            LDA   #BELL_H        ;BELL causes delay if Key bounces
                JMP   COUT           ;Print A-Reg to Output Device

; ==============================================================================
; Restore (P), (A), (X), & (Y) Register Contents            [Used for Debugging]
; ==============================================================================
; 
MON_RESTORE     LDA   STATUS         ;Retrieve Status from P-Reg Safe
                PHA                  ;Push Status
                LDA   ACC            ;Retrieve A-Reg from Safe
                LDX   XREG           ;Retrieve X-Reg from Safe
                LDY   YREG           ;Retrieve Y-Reg from Safe
                PLP                  ;Pull Status
                RTS                  ;Return to Caller

; ==============================================================================
; Save All 6502 Registers, Including Program Counter [(PCL,H)=($3A,$3B)]:
; ==============================================================================
; 
; <User Entry Point (Label Not Used)>;Save All Registers & Program Counter:
MON_SAVE        STA   ACC            ;Save A-Reg in Safe
; -----------------------------------;Save Registers on Break Entry Point:
;                                    ;<<< BUG: SAV1 Does Not Save A-Reg! >>>
SAV1            STX   XREG           ;Save X-Reg in Safe
                STY   YREG           ;Save Y-Reg in Safe
                PHP                  ;Push Status Register
                PLA                  ;Pull Status Value
                STA   STATUS         ;Save Status in P-Reg Safe
                TSX                  ;Get STACK Pointer
                STX   SPNT           ;Save STACK Pointer in Safe
                CLD                  ;Clear Decimal Flag; Sets Hex Mode
; -----------------------------------;JSR here to determine where one is:
;                                    ;[A JSR to an RTS STACKs Current Address]
IORTS           RTS                  ;Return to Caller

; ==============================================================================
; Old Reset Routine:
; ==============================================================================
; Monitor "Cold Start" Entry Point [Referenced via Reset Vector]: All Resets are
; Vectored here; Sets Normal Text Screen Mode & Initializes Keyboard & Screen as
; the I/O Devices
; ------------------------------------------------------------------------------
; 
; -----------------------------------;Referenced via Interrupt Vector Table:
;                                    ;<< BUG: OLDRST Vector ($FF59) IS Wrong >>
OLDRST          JSR  NORMSET        ;Set Normal Video Mode
                JSR  INITSCR        ;Initialize Video Screen for Text Mode
                JSR  VIDSET         ;Reset CSW Output Vector to COUT1 ($FDF0)
                JSR  KBDSET         ;Reset KSW Input Vector to KEYIN ($FD1B)
; 
; ==============================================================================
; Monitor "Warm Start" ("Loud Reset") Entry Point: Sets Hexadecimal Mode & Beeps
; ==============================================================================
; 
; -----------------------------------;Restart Monitor ("*" Prompt) Loudly:
MON             CLD                  ;Must Clear Decimal Flag; Sets Hex Mode
                JSR   BELL           ;Send BELL Char to Output Device
; 
; ==============================================================================
; Monitor "Warm Start" ("Silent Reset") Entry Point (from BASIC):
; ==============================================================================
; Sets Monitor "Star" ('*') Prompt & Reads a Line of User Input
; [See also, "The 3D0G (3-Dog-Night) Command Returns A User To Basic"]
; ------------------------------------------------------------------------------
; 
; -----------------------------------;Restart Monitor ("*" Prompt) Silently:
MONZ            LDA   #"*"     ;Get Monitor Prompt Character ("*")
                STA   PROMPT         ;Set Monitor Prompt Character ("*")
                JSR   GETLNZ         ;Prompt User for Input; Read a Line
; <User Entry Point (Label Not Used)>;Scan IDX [Input Buffer ($200..$2FF)?]:
SCANIDX         JSR   ZMODE          ;Clear Monitor Mode
; -----------------------------------;Process Monitor Commands; Get Next Item:
NXTITM          JSR   MGETNUM        ;Get Non-Hex Char; (X=0) If No Hex Input
                STY   YSAV           ;Save (Y) for Monitor Command Processing
                LDY   #23            ;There are only 23 Monitor Commands
; -----------------------------------;Search Character Table (Loop)
;                                    ;^[Used to Decode Keyboard Input]:
CHRSRCH         DEY                  ;Reduce Monitor Command Search Counter
                BMI   MON            ;If Not Found, Go Restart Monitor Loudly
                CMP   CHRTBL,Y       ;Else, Find Command Char in Char Table
                BNE   CHRSRCH        ;Loop until Search Counter is Zero
                JSR   TOSUB          ;Cmd Found: Call Corresponding Subroutine
                LDY   YSAV           ;Save (Y) for Monitor Command Processing
                JMP   NXTITM         ;Go Process Next Monitor Command

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; <<< ZMODE is NOT HERE (above) at $FF7C!  ZMODE is actually at $FFC7!  The
; $FF7C address, as documented in Luebbert's "What's Where in The Apple", is
; incorrect.  He mistakenly transposed the last two hexadecimal digits of the
; real $FFC7 address to get $FF7C.  [Or, was it on purpose, to confuse the enemy
; during the cold war?  IIRC, Luebbert was a professor at Anapolis then.] >>>
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; 
; ==============================================================================
; Hexadecimal Digit Shifter:
; ==============================================================================
; Bit Map: <- (A2H)=(%ABCD,EFGH); <- (A2L)=(%IJKL,MNOP); <- (A)=(%QRST,UVWX) <-
; ------------------------------------------------------------------------------
; 
DIGIT           LDX   #3             ;Set Index to Shift 4 Bits (Hi<-Lo Bytes)
                ASL              ;Got Hex Digit, Shift it into A2:
                ASL              ;1st Shift (A) Low Nibble into High Nibble
                ASL              ;(4 ASL's Discard High Nibble Bits
                ASL              ;& Zero Low Nibble Bits); (A)=(%UVWX,0000)
NXTBIT          ASL              ;2nd Shift (A) High Nibble
                ROL A2L            ;into (A2L) Low Nibble; (A2L)=(%MNOP,UVWX)
                ROL A2H            ;& (A2L) High Nibble into (A2H) Low Nibble
;                                    ;(Discards A2H Hi Nib); (A2H)=(%EFGH,IJKL)
                DEX                  ;Reduce Shift Count
                BPL   NXTBIT         ;Branch Until All 4 Bits have been Shifted
;                                    ;^[Leaves (X)=($FF)=(-1) & (A=0)]
; ------------------------------------------------------------------------------
; Note: If (0<=X<=$80) upon entry, NXTBIT could shift up to 128 bits left
; through A2 but, only the last 16 bits would be retained!
; ------------------------------------------------------------------------------

NXTBAS          LDA   MODE           ;Get Monitor Mode Flag [0 Mode = Mem Dump]
                BNE   NXTBS2         ;If Mode is Zero then Copy A2 to A1 & A3
                LDA   A2H,X          ;Get A2-Reg, Low then High
                STA   A1H,X          ;Set A1-Reg, Low then High
                STA   A3H,X          ;Set A3-Reg, Low then High
NXTBS2          INX                  ;Advance Indexed Adressing X-Index (-1~0)
                BEQ   NXTBAS         ;Branch if Lows Done; Do Highs
                BNE   NXTCHR         ;Else, Do Next Mon Cmd Char; Always Taken

; ==============================================================================
; Monitor Command Parser: Gets a Hexadecimal Digits from the Input Buffer
; ==============================================================================
; Get a Character from Input Buffer; If it is a Hexadecimal Digit, Branch to
; Digit; Else, Return to Caller
; ------------------------------------------------------------------------------
; 
MGETNUM         LDX   #0             ;Clear X-Index; Prepare to Clear A2
                STX   A2L            ;Clear A2-Reg, Low
                STX   A2H            ;Clear A2-Reg, High
NXTCHR          LDA   BUF,Y          ;Get Next Char from Input Buffer
                INY                  ;Advance Input Buffer Char Pointer
                EOR   #"0"           ;Is Char a Numeral >= 0?
                CMP   #10            ;Is Char a Numeral < 10?
                BCC   DIGIT          ;BLT: Branch if Hex/Dec Digit
                ADC   #$88           ;Is Char a Letter >=("A")? [Adds (C=1)]
;                                    ;[($88)+("A"=$C1)+(C=1)]=($14A)->(C=1)
                CMP   #$FA           ;Is Char a Letter <=("z") [A-Data->NZC]
;                                    ;[($4A)]-($FA="z")=($50)] [A<Data];
;                                    ; But (C=1) remains unchaged, so ...
                BCS   DIGIT          ;BGE: Branch if Hex Digit
                RTS                  ;Return to Caller
; 
; ==============================================================================
; Monitor Command Found; Push & Return to Corresponding Subroutine:
; ==============================================================================
; 
TOSUB           LDA   #>BL1          ;Get High Address of All Mon Cmd Handlers
;                                    ; Referenced via Subroutine Address Table
                PHA                  ;Push High-Order S/R Address
                LDA   SUBTBL,Y       ;Get Low Address from S/R Address Table
                PHA                  ;Push Low-Order S/R Address
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; This confirms the order of the return address pushed onto the stack during a
; subroutine call (JSR); the high-order subroutine address is pushed 1st and the
; low-order subroutine address is pushed 2nd (so, reverse order when pulling)
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                LDA   MODE           ;Get Old Mode
; -----------------------------------;Clear/Zero Monitor Mode:
ZMODE           LDY   #$00           ;Clear Y-Index Register
                STY   MODE           ;Clear Monitor Mode Flag
                RTS                  ;Go To S/R via Return to Caller

; ==============================================================================
; Character Table: Used to Decode Keyboard Input (23 Monitor Commands)
; ==============================================================================
; 
;            DFB    $NN = <-----> =;F({[High ASCII of "Char"] XOR $B0}+$89)
;              ==========            ;=========================================
;              \V/    \V/            ;  Mon.Cmds  Subroutines  Actions
;              ---    ---            ;  --------   --------   -----------------
CHRTBL        DFB   $BC            ;F("Ctrl-C"); BASCONT; Warm Start BASIC
              DFB   $B2            ;F("Ctrl-Y"); USR    ; JMP to User Vector
              DFB   $BE            ;F("Ctrl-E"); REGZ   ; Display Registers
              DFB   $B2            ;F("T")     ; TRACE  ; CMD now like USR *
              DFB   $EF            ;F("V")     ; VFY    ; Verify Memory
              DFB   $C4            ;F("Ctrl-K"); INPRT  ; Set IN# Slot
              DFB   $B2            ;F("S")     ; STEPZ  ; CMD now like USR *
              DFB   $A9            ;F("Ctrl-P"); OUTPRT ; Set PR# Slot
              DFB   $BB            ;F("Ctrl-B"); XBASIC ; Cold Start BASIC
              DFB   $A6            ;F("-")     ;STMODE; Subtract
              DFB   $A4            ;F("+")     ;STMODE; Add
              DFB   $06            ;F("M")     ; MOVE   ; Move Memory
              DFB   $95            ;F("<")     ; LT     ; MOVE/VFY Delimiter
              DFB   $07            ;F("N")     ;NORMSET; Set Normal Video
              DFB   $02            ;F("I")     ;STINV ; Set Inverse Video
              DFB   $05            ;F("L")     ; LIST   ; Disassemble 20 Instrs
              DFB   $F0            ;F("W")     ; WRITE  ; Write to Audio Tape
              DFB   $00            ;F("G")     ; GO     ; Execute a Program
              DFB   $EB            ;F("R")     ; READ   ; Read from Audio Tape
              DFB   $93            ;F(":")     ;STMODE; Fill Memory
              DFB   $A7            ;F(".")     ;STMODE; Address Range Delimiter
              DFB   $C6            ;F("CR")    ; CRMON  ; End Input
              DFB   $99            ;F(" ")     ; BLANK  ; Space Character
; 
; ==============================================================================
; Subroutine Address Table: Used by TOSUB to Push onto Stack for RTS;
; Index Program Counter (PC) with Table Item for Subroutine Entry;
; Addresses: (Subroutine)-1; (MSB)=(#$FE); (LSB)=(Table Entry)+1
; ==============================================================================
; 
;              LSB    Subroutines    ;Mon.Cmds   Actions 
;              ---    -----------    ;--------   ---------------- 
SUBTBL        DFB   <BASCONT-1     ;"Ctrl-C"; Warm Start BASIC
              DFB   <USR-1         ;"Ctrl-Y"; JMP to User Vector
              DFB   <REGZ-1        ;"Ctrl-E"; Display Registers
              DFB   <TRACE_RTS-1   ;"T"     ; TRACE: Now an 'RTS'; [TRACE_RTN]
; ------------------------------------------------------------------------------
; STEP & TRACE are now like USR (via CHRTBL): The way it is coded now, the Apple
; II Plus Autostart TRACE (T) Command is the same as the USER (Ctrl-Y) Command *
; ------------------------------------------------------------------------------
              DFB   <VFY-1         ;"V"     ; Verify Memory
              DFB   <MON_INPRT-1   ;"Ctrl-K"; Set IN# Slot
              DFB   <STEPZ_USR-1   ;"S"     ; STEPZ: Now an 'RTS'; [STEPZ_RTN]
; ------------------------------------------------------------------------------
; <<< BUG! -- Should Be: DFB $C3, Not DFB $C4; for STEPZ-1 ($FEC4-1 = $FEC3) >>>
; ------------------------------------------------------------------------------
; Turns out that this is not really a BUG.  The way it is coded now, the Apple
; II Plus Autostart STEP (S) Command is the same as the USER (Ctrl-Y) Command *
; ------------------------------------------------------------------------------
              DFB   <OUTPRT-1      ;"Ctrl-P"; Set PR# Slot
              DFB   <XBASIC-1      ;"Ctrl-B"; Cold Start BASIC
              DFB   <SETMODE-1     ;"-"     ; Subtract
              DFB   <SETMODE-1     ;"+"     ; Add
              DFB   <MOVE-1        ;"M"     ; Move Memory
              DFB   <LT-1          ;"<"     ; MOVE/VFY Delimiter
              DFB   <NORMSET-1     ;"N"     ; Set Normal Video
              DFB   <SETINV-1      ;"I"     ; Set Inverse Video
              DFB   <MON_LIST-1    ;"L"     ; Disassemble 20 Instrs
              DFB   <MON_WRITE-1   ;"W"     ; Write to Audio Tape
              DFB   <GO-1          ;"G"     ; Execute a Program
              DFB   <MON_READ-1    ;"R"     ; Read from Audio Tape
              DFB   <SETMODE-1     ;":"     ; Fill Memory
              DFB   <SETMODE-1     ;"."     ; Address Range Delimiter
              DFB   <CRMON-1       ;"CR"    ; End Input
              DFB   <BLANK-1       ;" "     ; Space Character (BLANK)
; 
; ==============================================================================
; 6502 Interrupt Vector Table
; ==============================================================================
; 
             DA    NMI            ;NMI Vector
             DA    RESET          ;RESET Vector
; ==============================================================================
; WHAT THE FOLLOWING SHOULD & SHOULD NOT BE:
; ------------------------------------------------------------------------------
;            DA    IRQ            ;IRQ Vector    ($FA40) IS Right;
;            DA    OLDRST         ;OLDRST Vector ($FF59) IS Wrong! << BUG >>
; ------------------------------------------------------------------------------
;        <<< BUG can be fixed in (Apple II Plus) Emulator ROM images! >>>
; ==============================================================================
             DA    OLDRST         ;OLDRST Vector ($FF59) IS Wrong! << BUG >>
