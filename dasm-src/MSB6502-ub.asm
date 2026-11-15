         .PROCESSOR 6502

0001 ; TITLE    BASIC M6502 8K VER 1.1 BY MICRO-SOFT
0002 ; SEARCH   M6502              ; (UB Note: loads additional symbol table)
0003 ; SALL                        ; (UB Note: listing control)
0004 ; RADIX 10                    ; THROUGHOUT ALL BUT MATH-PAK.
0005                               ; (UB Note: RADIX feature not used anymore)
0006 ; $Z::                        ; STARTING POINT FOR M6502 SIMULATOR
0007         ORG     0             ; START OFF AT LOCATION ZERO.
;
; *****************************************************************************
; *                                                                           *
; *               U N C L E   B E R N I E ' S   E D I T I O N                 *
; *                                                                           *
; *                                  O F                                      *
; *                                                                           *
; *               M I C R O S O F T ' S   6 5 0 2   B A S I C                 *
; *                                                                           *
; *                             2 0 2 5  A. D.                                *
; *                                                                           *
; *****************************************************************************
;
; This work was done in the hope that 6502 aficionados of Y2025 and posterity
; find it useful for studying and modifying Microsoft 6502 BASIC using standard
; 6502 macro assemblers who choke on the original source code as published and
; given to the world by Microsoft here:
;
; https://github.com/microsoft/BASIC-M6502
;
; This source code (referred to in the following text as 'original source') was
; for the MACRO-10 assembler of the DEC PDP-10 and although this assembler was
; very powerful (as evidenced by the way they bent it to assemble 6502 code), it
; is not compatible with the 6502 macro assemblers we use today. So the original
; source code had to be rendered into a form compatible with today's assemblers.
;
; The result of this work is "Uncle Bernie's Edition of Microsoft's 6502 BASIC".
; It can be assembled with the "DASM" macro assembler available here:
;
; https://github.com/dasm-assembler/dasm
;
; ... but some minor functional upgrades of DASM are necessary, which, alas,
; were rejected by the maintainers of DASM. So feel free to port this code to
; any 6502 macro assembler which can set the MSB of an ASCII string in a .BYTE
; or equivalent command. I chose DASM because it is available in source code
; form and readily compiles on Linux without any edits. Other open source 6502
; assemblers failed me, they would not compile. ATASM has been my favorite 6502
; assembler for many years as it has all the required capabilities such as
; setting the MSB of strings, but it breaks when code is assembled into the zero
; page ('seqmentation fault'), which is a feature being used in Microsoft 6502
; BASIC. My time is too precious to fix bugs and incompatibilities in third
; party tools. DASM had no problems for this mission and was easily upgraded
; with the added functions needed for the mission. See DASM_UPGRADE in the
; tarball. Note: DASM has a very relaxed handling of keywords which in some
; cases helps but in other cases causes issues, for instance, it does not like
; label names which begin with DASM keywords, and 'SET' being the worst offender
; for that. As a consequence, all labels beginning with 'SET' were turned around
; like the following example: 'SETCOL' was turned into 'COLSET', and this was
; done with all offending labels.
;
; LIABILITY DISCLAIMER
;
; This work is for educational purposes only - be aware that despite the fact
; Microsoft has given us a very generous open source license (visit the above
; link to read it), the published original source code by Microsoft is not able
; to generate complete ROM images for any of the target systems: there are some
; small (and sometimes large) differences and add-ons of unknown origin, but we
; can suspect that these were done by the licensees of Microsoft who bought the
; source code for Microsoft 6502 BASIC and then proceeded to add their own code.
;
; This means that third parties may still own the Copyright on any code pieces
; they have added to the original Microsoft code. One particular example are
; the extra BASIC commands found in 'Applesoft BASIC', which most likely were
; coded by Apple, and hence, cannot be considered to be free of Copyright.
;
; So, if you want to derive your own 6502 BASIC interpreter from this source
; code, proceed with caution, and substitute the third party sections with your
; own code.
;
; Use this source code at your own risk only. The author ("Uncle Bernie") shall
; not be liable for any incidental or consequential damages which may arise from
; use of this source code ("work"). It is not implied that any parts of this
; work are free from Copyright of third parties. Any Trademarks which may be
; mentioned in this work are owned by their respective owners and are used only
; as a reference.
;
; NOTES ON THE APPLESOFT TARGET CASE
;
; Except for the Applesoft BASIC case (REALIO = 4, APPLE2 = 1), no attempt has
; been made to add any third party components to the source code other than for
; minor differences found within the body of Microsoft's code, which may or
; may not have been originated by third parties. The Applesoft BASIC case makes
; use of the files 'applesoft.head' and 'applesoft.tail' which were derived from
; commented disassembly listing by James P. Davis found here:
;
; https://6502disassembly.com/a2-rom/
;
; Click on 'download the project file.ZIP' there and you will get a file called:
;
; 'Apple II Plus ROM Disassembly.zip'
;
; from which you take the 'APPLE2.ROM.txt' file which is a complete disassembly
; listing for the Apple II Plus ROM space. Applesoft BASIC as such begins at
; address $D000 and the disassembly ends at address $FFFF.
;
; Thanks to all the contributors to this giant disassembly effort which are
; listed in the 'APPLE2.ROM.txt' file - without their work I could not have
; completed my own work of rendering the original Microsoft 6502 BASIC source
; into a form that can be used with modern 6502 Macro Assemblers.
;
; Note that a few minor edits were done in 'applesoft.head' and 'applesoft.tail'
; to make them compatible with the symbol names found in the original Microsoft
; source code. This was only done when needed ... so there are still symbols
; with different names but meaning the same thing.
;
; Note that most of the code in 'applesoft.tail' most likely is copyrighted by
; Apple. It has been included for educational purposes only, so readers can
; learn how Apple (?) has added the extra commands, especially those which deal
; with graphics functions of the Apple II. These functions form an extra layer
; between the original Microsoft 6502 BASIC code and the lower level graphics
; functions found in Apple's AUTOSTART ROM LISTING and MONITOR ROM LISTING which
; were published as source code in the "APPLE II REFERENCE MANUAL" of Y1979,
; Apple product number A2L0001A (030-0004-01).
;
; NOTES ON THE COMMODORE PET 2001 BASIC TARGET CASE
;
; For sake of readability of PET BASIC (REALIO = 3, PET = 1), the known patches
; coming immediately after the end of the original Microsoft source code have
; been included as the file 'pet1.tail'. All these patch functions jump right
; back into the original Microsoft code in the vicinity of where the JMP to the
; patch is. Other than the "Kernel" / "Kernal" functions written by Commodore -
; which are not present in this work - the full source code of Commodore BASIC 1
; is present in this work and can be read and understood, but you may need to
; consult one of the disassembly listings found on the web to gain full insight
; how the "Kernel" / "Kernal" functions interact with Microsoft 6502 BASIC.
;
; NOTES ON THE OHIO SCIENTIFIC ("OSI") BASIC-IN-ROM TARGET CASE
;
; OSI BASIC (REALIO = 2, OSI = 1) contains the option to have the infamous
; "Garbage Collection Bug" fixed, using a fix 'Uncle Bernie' has developed all
; by himself, back in the day, when being the owner of an early 'SUPERBOARD II'.
; There are many other known fixes of this nasty bug by third parties, and even
; Microsoft's 6502 BASIC V1.1 (their published source code) comes with its own
; fix. It is not known if some of these fixes are better than others ... back in
; the day there were some proposed 'fixes' which simply did not work and just
; avoided the 'hanging' of the system, but still corrupted some strings under
; some unfathomable conditions. So, take all these 'fixes' with a grain of salt.
; Not included in this work are images for OSI's monitor ROM, but these can be
; found on the web, and are not needed to understand how Microsoft 6502 BASIC
; interacts with the rest of the system, as there are only few subroutines to
; be implemented, such as get a character, put a character, and test for CTRL-C.
; The 'LOAD' and 'SAVE' subroutines in the OSI SUPERBOARD II did not to anything
; other than reverting the get character and put character functions to and from
; the ACIA which was hooked to the cassette interface. So after 'SAVE' you had
; to type 'LIST' and your BASIC program would be listed to the cassette. For
; 'LOAD', the keyboard input was rerouted to take the 'keystrokes' from cassette
; and this just re-'typed' the stored program as if it had been entered by the
; user. A very primitive solution which has the advantage that OSI BASIC is the
; most easy version of Microsoft 6502 BASIC to port to homebrewed machines.
; OSI BASIC is interesting for yet another reason: it reflects V1.0 of Microsoft
; 6502 BASIC, and so, if the OSI switch is activated, the published original
; source, which is V1.1, reverts back to V1.0, the much earlier version of
; Microsoft's 6502 BASIC, for which Microsoft did not publish the source (yet).
; Do not forget the infamous "Garbage Collection Bug" - without the fix, OSI
; BASIC string functions are practically useless, as the program will only work
; for a short while and then crash / hang, possibly shredding the BASIC program.
;
; NOTES ON THE MOS TECHNOLOGY "KIM" BASIC TARGET CASE
;
; KIM BASIC (REALIO = 1, KIM = 1) was included as an option because it's the
; only version among the four possible choices which is loaded into RAM, and
; it exercises a lot of code options which are disabled in ROM-only versions.
;
; NOTES ON THE PDP-10 SIMULATING 6502 TARGET CASE
;
; This has not been tried or tested, for lack of a PDP-10. Also, be aware that
; the original source code for Microsoft 6502 BASIC as published by Microsoft
; does not include the file 'M6502' which - I guess - contained symbols which
; would implement the 6502 simulator itself. We do not need that anymore, as
; plenty of emulators for all the target machines are available on the web.
;
; NOTES ON THE 'STM' TARGET CASE
;
; This has not been tried or tested, as the actual target machine could not be
; identified, and no ROM images for checks could be found.
;
; HOW TO PREPARE ASSEMBLY FOR A TARGET SYSTEM
;
; Let's start to define for which target the code must be generated:
;

0010 ; 5=STM
0011 ; 4=APPLE.
0012 ; 3=COMMODORE.
0013 ; 2=OSI
0014 ; 1=MOS TECH,KIM
0015 ; 0=PDP-10 SIMULATING 6502

0010      REALIO: SET 3

; ... but wait, this is not all. If you only use the REALIO setting, with all
; switches in Uncle Bernie's switchbox set to zero, you get what the original
; source code would generate, and none of the binaries for any of the targets
; would match with the authentic binaries that can be found on the web. This
; is due to the differences mentioned above. So you also have to set the KIM,
; OSI, PET or APPLE2 switch in the switchbox, either manually or by:
;
; DASM COMMAND LINE OPTIONS
;
; To automate this process, a new symbol TARGET was introduced which sets
; REALIO and the appropriate switches in the switchbox below. You can set TARGET
; to any of the choices for REALIO (above) by using the DASM command line option
;
; -DTARGET=n
;
; ... where 'n' is the number of the choosen target. As a further example, for
; OSI BASIC-IN_ROM with Uncle Bernie's "Garbage Collection Bug Fix", use:
;
; -DTARGET=2 -DFIX
;
; ... but note that the binary created with the fix does not match any of the
; binaries found on the web. To get a match needs omission of the '-DFIX'.
;
; If you use the -DTARGET command line option, you don't need to manipulate the
; following switchbox:
;
; =================  Switchbox added by Uncle Bernie  ====================
;
;    KIM if set, generates KIM's KB9 BASIC loaded into KIM's RAM.
;    OSI if set, generates the BASIC ROM images for the Superboard II
; OSIFIX if set  with OSI, add's Uncle Bernie's Y1980 garbage collection
;                bug fix, that affects ROM#3. Also see comments at GARBAG.
;    PET if set, generates the BASIC ROM images for the first PET 2001.
; APPLE2 if set, generates Applesoft ROM images for the Apple II+
;
; If none of these switches are set, assembly reverts to the original
; source code as published by Microsoft. It has none of the modifications
; or extensions found in the ROMs of the machine selected by REALIO, so
; be aware that the binaries will not match the contents of the real ROMs
; =======================================================================

    KIM:    SET 0
    OSI:    SET 0
    OSIFIX: SET 0
    PET:    SET 0
    APPLE2: SET 0

; =======================================================================

     .IFCONST TARGET                       ; check if TARGET is defined
     |                 REALIO: SET TARGET
     |                 KIM:    SET 0
     |                 OSI:    SET 0
     |                 OSIFIX: SET 0
     |                 PET:    SET 0
     |                 APPLE2: SET 0
     |.IF TARGET==1
     ||                .ECHO "TARGET: KIM"
     ||                KIM:    SET 1
     |.ENDIF
     |.IF TARGET==2
     ||                .ECHO "TARGET: OSI"
     ||                OSI:    SET 1
     ||.IFCONST FIX
     |||               .ECHO "with Garbage Collection Bug fix"
     |||               OSIFIX: SET 1
     ||.ELSE
     |||               OSIFIX: SET 0
     ||.ENDIF
     |.ENDIF
     |.IF TARGET==3
     ||                .ECHO "TARGET: PET"
     ||                PET:    SET 1
     |.ENDIF
     |.IF TARGET==4
     ||                .ECHO "TARGET: APPLE2"
     ||                APPLE2: SET 1
     |.ENDIF
     .ENDIF

     .IF APPLE2
     |.INCLUDE "applesoft.head"
     .ENDIF

     ; =======================================================================
     ;             Declarations from original Microsoft source code
     ; =======================================================================

0008 ; SUBTTL     SWITCHES,MACROS.

0016              INTPRC SET 1     ; INTEGER ARRAYS.
0017              ADDPRC SET 1     ; FOR ADDITIONAL PRECISION.
0018              LNGERR SET 0     ; LONG ERROR MESSAGES.
0019              TIME   SET 0     ; CAPABILITY TO SET AND READ A CLK.
0020              EXTIO  SET 0     ; EXTERNAL I/O.
0021              DISKO  SET 0     ; SAVE AND LOAD COMMANDS
0022              NULCMD SET 1     ; FOR THE "NULL" COMMAND
0023              GETCMD SET 1
0024              RORSW  SET 1
0025              ROMSW  SET 1     ; TELLS IF THIS IS ON ROM.
0026              CLMWID SET 14
0027              LONGI  SET 1     ; LONG INITIALIZATION SWITCH.
0028              STKEND SET 511
0029              BUFPAG SET 0
0030              LINLEN SET 72    ; TERMINAL LINE LENGTH.
0031              BUFLEN SET 72    ; INPUT BUFFER SIZE.
0032              ROMLOC SET $2000 ; ADDRESS OF START OF PURE SEGMENT.
0033              KIMROM SET 1
                  FCELIM SET 240   ; added by UB
                  STKGAP SET 259   ; added by UB
     .IF KIM
     |            ROMSW  SET 0
     |            REMSTK SET $FC
     |            FCELIM SET 242
     .ENDIF
0034 .IF !ROMSW
     |            KIMROM SET 0
     .ENDIF
0035 .IF REALIO != 1
     |            KIMROM SET 0
     .ENDIF
0036 .IF ROMSW
0037 |            RAMLOC SET $4000 ; USED ONLY IF ROMSW=1
0038 |.IF REALIO == 0              ; START AT 8K.
     ||           ROMLOC SET $2000
0039 ||           RAMLOC SET $0300
     |.ENDIF
     .ENDIF
0040 .IF REALIO == 3
0041 |            DISKO  SET 1
0042 |            RAMLOC SET $0400
0043 |            ROMLOC SET $C000
0044 |            NULCMD SET 0
0045 |            GETCMD SET 1
0046 |            LINLEN SET 40
0047 |            BUFLEN SET 81
0048 |            CQOPEN = $FFC0   ; JMP KOPEN
0049 |            CQCLOS = $FFC3   ; JMP KCLOSE
0050 |            CQOIN  = $FFC6   ; JMP KCHKIN: OPEN CHANNEL FOR INPUT
0051 |            CQOOUT = $FFC9   ; JMP KCKOUT: FILL FOR COMMO.
0052 |            CQCCHN = $FFCC   ; JMP KCLRCH: clear I/O
0053 |            CQINCH = $FFCF   ; JMP KBASIN: INCHR'S CALL TO GET A CHARACTER
0054 |            OUTCH  = $FFD2   ; JMP KBSOUT: kernel output
0055 |            CQLOAD = $FFD5   ; JMP KLOAD
0056 |            CQSAVE = $FFD8   ; JMP KSAVE
0057 |            CQVERF = $FFDB   ; JMP KVERIFY
0058 |            CQSYS  = $FFDE   ; JMP KSYS
0059 |            ISCNTC = $FFE1   ; JMP IECABORT
0060 |            CZGETL = $FFE4   ; JMP KGET  : CALL POINT FOR "GET"
0061 |            CQCALL = $FFE7   ; JMP KCLALL: CLOSE ALL CHANNELS
0062 |            CQTIMR SET $8D
0063 |            BUFPAG SET 2
     |.IF !PET
0064 ||           BUF = 256*BUFPAG
     |.ENDIF
0063 |            BUFPAG SET 0
0065 |            STKEND SET 507
0066 |            CQSTAT SET $96
0067 |            CQHTIM SET $E844
0068 |            EXTIO  SET 1
0069 |            TIME   SET 1
0070 |            GETCMD SET 1
0071 |            CLMWID SET 10
0072 |            PI      = 255    ; VALUE OF PI CHARACTER FOR COMMODORE.
0073 |            ROMSW  SET 1
0074 |            RORSW  SET 1
     |.IF !PET
0075 ||           TRMPOS SET $C6
     |.ELSE         ; deviations from Microsoft's original source code for PET:
     ||           RDYJSR EQU $00
     ||           START  EQU $A3
     ||           REMSTK EQU $FC
     ||           STKGAP SET 255
     ||           LNGERR SET 1
     ||           FCELIM SET 10
     ||           BUFLEN SET 80
     ||           CQTIMR SET $200
0066 ||           CQSTAT SET $20C
0067 ||           CQHTIM SET $9044
     ||           GOEND  SET ENDCON
     ||           ZERO   SET CON_ZERO
     |.ENDIF
     .ENDIF
0076 .IF REALIO == 1
     |            GOEND  SET ENDCON
     |            LNGERR SET 1
     |            GETCMD SET 1
0077 |            DISKO  SET 1
0078 |            OUTCH  = $1EA0   ; 1EA0
0079 |            ROMLOC SET $2000
0080 |            RORSW  SET 0
0081 |            CZGETL = $1E5A
     .ENDIF
0082 .IF REALIO == 2
0083 |            RORSW  SET 1     ; changed from 0 to 1 /UB
0084 |            RAMLOC SET $0200
0085 |.IF ROMSW
0086 ||           RORSW  SET 1
0087 ||           RAMLOC SET $0300 ; changed from $8000 to $0300 /UB
     ||           ROMLOC SET $A000
     |.ENDIF
0088 |            OUTCH  = $FE0B
     |            CZGETL = $FFE4
     |            OUTVEC = $FFEE
     |            INPVEC = $FFEB
     |            CTLCCK = $FFF1
     |            LOAD   = $FFF4
     |            SAVE   = $FFF7
     |            ADDPRC SET 0
     |            INTPRC SET 0
     |            DISKO  SET 1
     |            GETCMD SET 0
     |            GOEND  SET ENDCON ; OSI goes directly to ENDCON
     |            FCELIM SET 10
     |            REMSTK = $FC
     |                PI = $FF
     .ENDIF
0089 .IF REALIO == 4
0090 |            RORSW  SET 1
0091 |            NULCMD SET 0
0092 |            GETCMD SET 1
0093 |            CQINLN = $FD67
0094 |            CQPRMP = $33
0095 |            CQINCH = $FD0C
0096 |            CQCOUT = $FECD
0097 |            CQCSIN = $FEFD
0098 |            BUFPAG SET 2
0099 |            BUF = BUFPAG*256
0100 |            ROMLOC SET $D000
     |.IF APPLE2
     ||           RAMLOC SET $0800
     ||           STLGAP SET 259
     |.ELSE
0101 ||           RAMLOC SET $2A00 ; PAGE 2A
     |.ENDIF
0102 |            OUTCH  = $FDED
0103 |            CZGETL = $FD0C
0104 |            LINLEN SET 40
0105 |            BUFLEN SET 240
0106 |            RORSW  SET 1
0107 |            STKEND SET 507
     |            LNGERR SET 1
     |            DISKO  SET 1     ; added by UB
     .ENDIF

     ; =======================================================================
     ;                          M  A  C  R  O  S
     ; =======================================================================

0108 .IF !RORSW
0109 |.MAC RAR
0110 |  LDA #0
0111 |  BCC * + 4
0112 |  LDA #$80
0113 |  LSR {1}
0114 |  ORA {1}
0115 |  STA {1}
     |.ENDM
     .ELSE         ; Added by Uncle Bernie: this is necessary to make it work
     |.MAC RAR     ; with assemblers which do not allow macros to have the
     |  ROR {1}    ; same name as 6502 mnemonics. So all the 'ROR' instructions
     |.ENDM        ; were replaced with 'RAR' which this added macro section
     .ENDIF        ; then turns back into 'ROR' if RORSW is set.

0117 .MAC ACRLF
0118   .BYTE $0D, $0A
     .ENDM

0120 .MAC SYNCHK
0121   LDA #{1}
0122   JSR SYNCHR
     .ENDM

0123 .MAC DTQ
0124  ;IRPC %1,<IFDIF <Q><'>,<EXP 'Q >>
     .ENDM

0125 .MAC LDWD
0126   LDA {1}
0127   LDY {1} + 1
     .ENDM

0128 .MAC LDWDI
0129   LDA # {1} & $FF
0130   LDY # {1} / 256
     .ENDM

0131 .MAC LDWX
0132   LDA {1}
0133   LDX {1} + 1
     .ENDM

0134 .MAC LDWXI
0135   LDA # {1} & $FF
0136   LDX # {1} / 256
     .ENDM

0137 .MAC LDXY
0138   LDX {1}
0139   LDY {1} + 1
     .ENDM

0140 .MAC LDXYI
0141   LDX # {1} & $FF
0142   LDY # {1} / 256
     .ENDM

0143 .MAC STWD
0144   STA {1}
0145   STY {1} + 1
     .ENDM

0146 .MAC STWX
0147   STA {1}
0148   STX {1} + 1
     .ENDM

0149 .MAC STXY
0150   STX {1}
0151   STY {1} + 1
     .ENDM

0152 .MAC CLR
0153   LDA #0
0154   STA {1}
     .ENDM

0155 .MAC COM
0156   LDA {1}
0157   EOR #$FF
0158   STA {1}
     .ENDM

0159 .MAC PULWD
0160   PLA
0161   STA {1}
0162   PLA
0163   STA {1} + 1
     .ENDM

0164 .MAC PSHWD
0165   LDA {1} + 1
0166   PHA
0167   LDA {1}
0168   PHA
     .ENDM

0169 .MAC JEQ
0170   BNE * + 5
0171   JMP {1}
     .ENDM

0172 .MAC JNE
0173   BEQ * + 5
0174   JMP {1}
     .ENDM

0175 ; BRANCHES THAT ALWAYS BRANCH
     ; THESE ARE USED ON THE 6502 BECAUSE
     ; THERE IS NO UNCONDITIONAL BRANCH

     .MAC BCCA
       BCC {1}
     .ENDM

0176 .MAC BCSA
       BCS {1}
     .ENDM

0177 .MAC BEQA
       BEQ {1}
     .ENDM

0178 .MAC BNEA
       BNE {1}
     .ENDM

0179 .MAC BMIA
       BMI {1}
     .ENDM
0180 .MAC BPLA
       BPL {1}
     .ENDM

0181 .MAC BVCA
       BVC {1}
     .ENDM

0182 .MAC BVSA
       BVS {1}
     .ENDM

0183 .MAC INCWR
0184   INC {1}
0185   BNE .L1
0186   INC {1}+1
0187  .L1:
     .ENDM

0188 .MAC SKIP1                    ; BIT ZERO PAGE TRICK.
      .BYTE $24                    ; BIT zp  opcode to skip next byte
     .ENDM

0189 .MAC SKIP2                    ; BIT ABS TRICK.
      .BYTE $2C                    ; BIT abs opcode to skip next two bytes
     .ENDM

     PASS: SET 1                  ; replacing the IF1 / UB

0190 .IF (PASS==1)                 ; was IF1
     |            .ECHO ""
0191 |.IF REALIO == 0
     ||           .ECHO "/SIMULATE/"
     |.ENDIF
0192 |.IF REALIO == 1
     ||           .ECHO "KIM"
     |.ENDIF
0193 |.IF REALIO == 2
     ||           .ECHO "OSI"
     |.ENDIF
0194 |.IF REALIO == 3
     ||           .ECHO "COMMODORE"
     |.ENDIF
0195 |.IF REALIO == 4
     ||           .ECHO "APPLE"
     |.ENDIF
0196 |.IF REALIO == 5
     ||           .ECHO "STM"
     |.ENDIF
0197 |.IF ADDPRC
     ||           .ECHO "ADDITIONAL PRECISION"
     |.ENDIF
0198 |.IF INTPRC
     ||           .ECHO "INTEGER ARRAYS"
     |.ENDIF
0199 |.IF LNGERR
     ||           .ECHO "LONG ERRORS"
     |.ENDIF
0200 |.IF DISKO
     ||           .ECHO "SAVE AND LOAD"
     |.ENDIF
0201 |.IF !ROMSW
     ||           .ECHO "RAM"
     |.ENDIF
0202 |.IF ROMSW
     ||           .ECHO "ROM"
     |.ENDIF
0203 |.IF !RORSW
     ||           .ECHO "NO ROR"
     |.ENDIF
0204 |.IF RORSW
     ||           .ECHO "ROR ASSUMED"
     |.ENDIF
     .ENDIF
;
; -------- ---- -- ---------
; COPYRIGHT 1976 BY MICROSOFT
; --------- ---- -- ---------
;
; 7/27/78 FIXED BUG WHERE FOR VARIABLE AT BYTE FF MATCHED RETURN SEARCHING
;         FOR GOSUB ENTRY ON STACK IN FNDFOR CALL BY CHANGING STA FORPNT
;         TO STA FORPNT+1. THIS IS A SERIOUS BUG IN ALL VERSIONS.
; 7/27/78 FIXED BUG AT NEWSTT UNDER IFN BUFPAG WHEN CHECK OF CURLIN
;         WAS DONE BEFORE CURLIN SET UP SO INPUT RETRIES OF FIRST STATEMENT
;         WAS GIVING SYNTAX ERROR INSTEAD OF REDO FROM START
;         (CODE WAS 12/1/77 FIX)
; 7/1/78  SAVED A FEW BYTES IN INIT FOR COMMODORE (14)
; 7/1/78  FIXED BUG WHERE REPLACING A LINE OVERFLOWING MEMORY LEFT LINKS
;         IN A BAD STATE. (CODE AT NODEL AND FINI) BUG#4
; 7/1/78  FIXED BUG WHERE GARBAGE COLLECTION NEVER(!) COLLECTS TEMPS
;         (STY GRBPNT  AT FNDVAR, LDA GRBPNT ORA GRBPNT+1 AT GRBPAS)
;         THIS WAS COMMODORE BUG #2
; 7/1/78  FIXED BUG WHERE DELETE/INSERT OF LINE COULD CAUSE AGARBAGE COLLECTION
;         WITH BAD VARTAB IF OUT OF MEMORY
;         (LDWD MEMSIZ STWD FRETOP=JSR RUNC CLC ALSO AT NODEL)
; 3/9/78  EDIT TO FIX COMMO TRMPOS AND CHANGE LEFT$ AND RIGHT$ TO ALLOW A SECOND
;         ARGUMENT OF 0 AND RETURN A NULL STRING
; 2/25/78 FIXED BUG THAT INPFLG WAS SET WRONG WHEN BUFPAG.NE.0
;         INCREASED NUMLEV FROM 19 TO 23
; 2/11/78 DISALLOWED SPACES IN RESERVED WORDS. PUT IN SPECIAL CHECK FOR "GO TO"
; 2/11/78 FIXED BUG WHERE ROUNDING OF THE FAC BEFORE PUSHING COULD CAUSE A
;         STRING POINTER IN THE FAC TO BE INCREMENTED
; 1/24/78 fixed problem where user defined function undefined check fix was
;         smashing error number in [x]
; 12/1/77 FIXED PROBLEM WHERE PEEK WAS SMASHING (POKER) CAUSING POKE OF PEEK TO
;         FAIL
; 12/1/77 FIXED PROBLEM WHERE PROBLEM WITH VARTXT=LINNUM=BUF-2 CAUSING BUF-1
;         COMMA TO DISAPPEAR
; 12/1/77 FIXED BUFPAG.NE.0 PROBLEM AT NEWSTT AND STOP : CODE WAS STILL
;         ASSUMING TXTPTR+1.EQ.0 IFF STATEMENT WAS DIRECT
;

0205 ; PAGE
0206 ; SUBTTL     INTRODUCTION AND COMPILATION PARAMETERS.

     .IF APPLE2+OSI+KIM+PET        ; none of these use the Microsoft setting for
     |            NUMLEV = 19      ; NUMLEV which was increased on 2/25/78, see
     .ELSE                         ; above comments on the bug fixes done.
0238 |            NUMLEV = 23      ; NUMBER OF STACK LEVELS RESERVED
0239 |                             ; BY AN EXPLICIT CALL TO "GETSTK".
     .ENDIF
0240              STRSIZ =  3      ; # OF LOCS PER STRING DESCRIPTOR.
0241              NUMTMP =  3      ; NUMBER OF STRING TEMPORARIES.
0242              CONTW  = 15      ; CHARACTER TO SUPPRESS OUTPUT.

0244 ; PAGE
0245 ; SUBTTL     SOME EXPLANATION.

0247 ;
0248 ; M6502 BASIC CONFIGURES BASIC AS FOLLOWS
0249 ;
0250 ; LOW LOCATIONS
0251 ;    PAGE    ZERO
0252 ;
0253 ;            STARTUP:
0254 ;            INITIALLY A JMP TO INITIALIZATION CODE BUT
0255 ;            CHANGED TO A JMP TO "READY".
0256 ;            RESTARTING THE MACHINE AT LOC 0 DURING PROGRAM
0257 ;            EXECUTION CAN LEAVE THINGS MESSED UP.
0258 ;
0259 ;            LOC OF FAC TO INTEGER AND INTEGER TO FAC
0260 ;            ROUTINES.
0261 ;
0262 ;            "DIRECT" MEMORY:
0263 ;            THESE ARE THE MOST COMMONLY USED LOCATIONS.
0264 ;            THEY HOLD BOOKKEEPING INFO AND ALL OTHER
0265 ;            FREQUENTLY USED INFORMATION.
0266 ;            ALL TEMPORARIES, FLAGS, POINTERS, THE BUFFER AREA,
0267 ;            THE FLOATING ACCUMULATOR, AND ANYTHING ELSE THAT
0268 ;            IS USED TO STORE A CHANGING VALUE SHOULD BE LOCATED
0269 ;            IN THIS AREA. CARE MUST BE MADE IN MOVING LOCATIONS
0270 ;            IN THIS AREA SINCE THE JUXTAPOSITION OF TWO LOCATIONS
0271 ;            IS OFTEN DEPENDED UPON.
0272 ;
0273 ;            STILL IN RAM WE HAVE THE BEGINNING OF THE "CHRGET"
0274 ;            SUBROUTINE. IT IS HERE SO [TXTPTR] CAN BE THE
0275 ;            EXTENDED ADDRESS OF A LOAD INSTRUCTION.
0276 ;            THIS SAVES HAVING TO BOTHER ANY REGISTERS.
0277 ;
0278 ;    PAGE    ONE
0279 ;            THE STACK.
0280 ;
0281 ;    STORAGE PAGE TWO AND ON
0282 ;            IN RAM VERSIONS THESE DATA STRUCTURES COME AT THE
0283 ;            END OF BASIC. IN ROM VERSON THEY ARE AT RAMLOC WHICH
0284 ;            CAN EITHER BE ABOVE OR BELOW ROMLOC, WHICH IS WHERE
0285 ;            BASIC ITSELF RESIDES.
0286 ;
0287 ;                            A ZERO.
0288 ;            [TXTTAB]        POINTER TO NEXT LINE'S POINTER.
0289 ;                            LINE # OF THIS LINE (2 BYTES).
0290 ;                            CHARACTERS ON THIS LINE.
0291 ;                            ZERO.
0292 ;                            POINTER AT NEXT LINE'S POINTER
0293 ;                                    (POINTED TO BY THE ABOVE POINTER).
0294 ;                            ... REPEATS ...
0295 ;            LAST LINE:      POINTER AT ZERO POINTER.
0296 ;                            LINE # OF THIS LINE.
0297 ;                            CHARACTERS ON THIS LINE.
0298 ;                            ZERO.
0299 ;                            DOUBLE ZERO (POINTED TO BY THE ABOVE POINTER).
0300 ;            [VARTAB]        SIMPLE VARIABLES. 6 BYTES PER VALUE.
0301 ;                            2 BYTES GIVE THE NAME, 4 BYTES THE VALUE.
0302 ;                            ... REPEATS ...
0303 ;            [ARYTAB]        ARRAY VARIABLES. 2 BYTES NAME, 2 BYTE
0304 ;                            LENGTH, NUMBER OF DIMENSIONS , EXTENT OF
0305 ;                            EACH DIMENSION (2BYTES/), VALUES
0306 ;                            ... REPEATS ...
0307 ;            [STREND]        FREE SPACE.
0308 ;                            ... REPEATS ...
0309 ;            [FRETOP]        STRING SPACE IN USE.
0310 ;                            ... REPEATS ...
0311 ;            [MEMSIZ]        HIGHEST MACHINE LOCATION.
0312 ;                            UNUSED EXCEPT BY THE VAL FUNCTION.
0313 ;
0314 ;            ROM -- CONSTANTS AND CODE.
0315 ;
0316 ;    FUNCTION DISPATCH ADDRESSES (AT ROMLOC)
0317 ;            "FUNDSP" CONTAINS THE ADDRESSES OF THE
0318 ;            FUNCTION ROUTINES IN THE ORDER OF THE
0319 ;            FUNCTION NAMES IN THE CRUNCH LIST.
0320 ;            THE FUNCTIONS THAT TAKE MORE THAN ONE ARGUMENT
0321 ;            ARE AT THE END. SEE THE EXPLANATION AT "ISFUN".
0322 ;
0323 ;    THE OPERATOR LIST
0324 ;            THE "OPTAB" LIST CONTAINS AN OPERATOR'S PRECEDENCE
0325 ;            FOLLOWED BY THE ADDRESS OF THE ROUTINE TO PERFORM
0326 ;            THE OPERATION. THE INDEX INTO THE
0327 ;            OPERATOR LIST IS MADE BY SUBTRACTING OFF THE CRUNCH VALUE
0328 ;            OF THE LOWEST NUMBERED OPERATOR. THE ORDER
0329 ;            OF OPERATORS IN THE CRUNCH LIST AND IN "OPTAB" IS IDENTICAL.
0330 ;            THE PRECEDENCES ARE ARBITRARY EXCEPT FOR THEIR
0331 ;            COMPARATIVE SIZES. NOTE THAT THE PRECEDENCE FOR
0332 ;            UNARY OPERATORS SUCH AS "NOT" AND NEGATION ARE
0333 ;            SETUP SPECIALLY WITHOUT USING THE LIST.
0334 ;
0335 ;    THE RESERVED WORD OR CRUNCH LIST
0336 ;            WHEN A COMMAND OR PROGRAM LINE IS TYPED IN
0337 ;            IT IS STORED IN "BUF". AS SOON AS THE WHOLE LINE
0338 ;            HAS BEEN TYPED IN ("INLIN" RETURNS) "CRUNCH" IS
0339 ;            CALLED TO CONVERT ALL RESERVED WORDS TO THEIR
0340 ;            CRUNCHED VALUES. THIS REDUCES THE SIZE OF THE
0341 ;            PROGRAM AND SPEEDS UP EXECUTION BY ALLOWING
0342 ;            LIST DISPATCHES TO PERFORM FUNCTIONS, STATEMENTS,
0343 ;            AND OPERATIONS. THIS IS BECAUSE ALL THE STATEMENT
0344 ;            NAMES ARE STORED CONSECUTIVELY IN THE CRUNCH LIST.
0345 ;            WHEN A MATCH IS FOUND BETWEEN A STRING
0346 ;            OF CHARACTERS AND A WORD IN THE CRUNCH LIST
0347 ;            THE ENTIRE TEXT OF THE MATCHED WORD IS TAKEN OUT OF
0348 ;            THE INPUT LINE AND A RESERVED WORD TOKEN IS PUT
0349 ;            IN ITS PLACE. A RESERVED WORD TOKEN IS ALWAYS EQUAL
0350 ;            TO OCTAL 200 PLUS THE POSITION OF THE MATCHED WORD
0351 ;            IN THE CRUNCH LIST.
0352 ;
0353 ;    STATEMENT DISPATCH ADDRESSES
0354 ;            WHEN A STATEMENT IS TO BE EXECUTED, THE FIRST
0355 ;            CHARACTER OF THE STATEMENT IS EXAMINED
0356 ;            TO SEE IF IT IS LESS THAN THE RESERVED
0357 ;            WORD TOKEN FOR THE LOWEST NUMBERED STATEMENT NAME.
0358 ;            IF SO, THE "LET" CODE IS CALLED TO
0359 ;            TREAT THE STATEMENT AS AN ASSIGNMENT STATEMENT.
0360 ;            OTHERWISE A CHECK IS MADE TO MAKE SURE THE
0361 ;            RESERVED WORD NUMBER IS NOT TOO LARGE TO BE A
0362 ;            STATEMENT TYPE NUMBER. IF NOT THE ADDRESS
0363 ;            TO DISPATCH TO IS FETCHED FROM "STMDSP" (THE STATEMENT
0364 ;            DISPATCH LIST) USING THE RESERVED WORD
0365 ;            NUMBER FOR THE STATEMENT TO CALCULATE AN INDEX INTO
0366 ;            THE LIST.
0367 ;
0368 ;    ERROR MESSAGES
0369 ;            WHEN AN ERROR CONDITION IS DETECTED,
0370 ;            [ACCX] MUST BE SET UP TO INDICATE WHICH ERROR
0371 ;            MESSAGE IS APPROPRIATE AND A BRANCH MUST BE MADE
0372 ;            TO "ERROR". THE STACK WILL BE RESET AND ALL
0373 ;            PROGRAM CONTEXT WILL BE LOST. VARIABLES
0374 ;            VALUES AND THE ACTUAL PROGRAM REMAIN INTACT.
0375 ;            ONLY THE VALUE OF [ACCX] IS IMPORTANT WHEN
0376 ;            THE BRANCH IS MADE TO ERROR. [ACCX] IS USED AS AN
0377 ;            INDEX INTO "ERRTAB" WHICH GIVES THE TWO
0378 ;            CHARACTER ERROR MESSAGE THAT WILL BE PRINTED ON THE
0379 ;            USER'S TERMINAL.
0380 ;
0381 ;
0382 ;    TEXTUAL MESSAGES
0383 ;            CONSTANT MESSAGES ARE STORED HERE. UNLESS
0384 ;            THE CODE TO CHECK IF A STRING MUST BE COPIED
0385 ;            IS CHANGED THESE STRINGS MUST BE STORED ABOVE
0386 ;            PAGE ZERO, OR ELSE THEY WILL BE COPIED BEFORE
0387 ;            THEY ARE PRINTED.
0388 ;
0389 ;    FNDFOR
0390 ;            MOST SMALL ROUTINES ARE FAIRLY SIMPLE
0391 ;            AND ARE DOCUMENTED IN PLACE. "FNDFOR" IS
0392 ;            USED FOR FINDING "FOR" ENTRIES ON
0393 ;            THE STACK. WHENEVER A "FOR" IS EXECUTED, A
0394 ;            16-BYTE ENTRY IS PUSHED ONTO THE STACK.
0395 ;            BEFORE THIS IS DONE, HOWEVER, A CHECK
0396 ;            MUST BE MADE TO SEE IF THERE
0397 ;            ARE ANY "FOR" ENTRIES ALREADY ON THE STACK
0398 ;            FOR THE SAME LOOP VARIABLE. IF SO, THAT "FOR" ENTRY
0399 ;            AND ALL OTHER "FOR" ENTRIES THAT WERE MADE AFTER IT
0400 ;            ARE ELIMINATED FROM THE STACK. THIS IS SO A
0401 ;            PROGRAM THAT JUMPS OUT OF THE MIDDLE
0402 ;            OF A "FOR" LOOP AND THEN RESTARTS THE LOOP AGAIN
0403 ;            AND AGAIN WON'T USE UP 18 BYTES OF STACK
0404 ;            SPACE EVERY TIME. THE "NEXT" CODE ALSO
0405 ;            CALLS "FNDFOR" TO SEARCH FOR A "FOR" ENTRY WITH
0406 ;            THE LOOP VARIABLE IN
0407 ;            THE "NEXT". AT WHATEVER POINT A MATCH IS FOUND
0408 ;            THE STACK IS RESET. IF NO MATCH IS FOUND A
0409 ;            "NEXT WITHOUT FOR"  ERROR OCCURS. GOSUB EXECUTION
0410 ;            ALSO PUTS A 5-BYTE ENTRY ON STACK.
0411 ;            WHEN A RETURN IS EXECUTED "FNDFOR" IS
0412 ;            CALLED WITH A VARIABLE POINTER THAT CAN'T
0413 ;            BE MATCHED. WHEN "FNDFOR" HAS RUN
0414 ;            THROUGH ALL THE "FOR" ENTRIES ON THE STACK
0415 ;            IT RETURNS AND THE RETURN CODE MAKES
0416 ;            SURE THE ENTRY THAT WAS STOPPED
0417 ;            ON IS A GOSUB ENTRY. THIS ASSURES THAT
0418 ;            IF YOU GOSUB TO A SECTION OF CODE
0419 ;            IN WHICH A FOR LOOP IS ENTERED BUT NEVER
0420 ;            EXITED THE RETURN WILL STILL BE
0421 ;            ABLE TO FIND THE MOST RECENT
0422 ;            GOSUB ENTRY. THE "RETURN" CODE ELIMINATES THE
0423 ;            "GOSUB" ENTRY AND ALL "FOR" ENTRIES MADE AFTER
0424 ;            THE GOSUB ENTRY.
0425 ;
0426 ;    NON-RUNTIME STUFF
0427 ;            THE CODE TO INPUT A LINE, CRUNCH IT, GIVE ERRORS,
0428 ;            FIND A SPECIFIC LINE IN THE PROGRAM,
0429 ;            PERFORM A "NEW", "CLEAR", AND "LIST" ARE
0430 ;            ALL IN THIS AREA. GIVEN THE EXPLANATION OF
0431 ;            PROGRAM STORAGE SET FORTH ABOVE, THESE ARE
0432 ;            ALL STRAIGHTFORWARD.
0433 ;
0434 ;    NEWSTT
0435 ;            WHENEVER A STATEMENT FINISHES EXECUTION IT
0436 ;            DOES A "RTS" WHICH TAKES
0437 ;            EXECUTION BACK TO "NEWSTT". STATEMENTS THAT
0438 ;            CREATE OR LOOK AT SEMI-PERMANENT STACK ENTRIES
0439 ;            MUST GET RID OF THE RETURN ADDRESS OF "NEWSTT" AND
0440 ;            JMP TO "NEWSTT" WHEN DONE. "NEWSTT" ALWAYS
0441 ;            CHRGETS THE FIRST CHARACTER AFTER THE STATEMENT
0442 ;            NAME BEFORE DISPATCHING. WHEN RETURNING
0443 ;            BACK TO "NEWSTT" THE ONLY THING THAT
0444 ;            MUST BE SET UP IS THE TEXT POINTER IN
0445 ;            "TXTPTR". "NEWSTT" WILL CHECK TO MAKE SURE
0446 ;            "TXTPTR" IS POINTING TO A STATEMENT TERMINATOR.
0447 ;            IF A STATEMENT SHOULDN'T BE PERFORMED UNLESS
0448 ;            IT IS PROPERLY FORMATTED (I.E. "NEW") IT CAN
0449 ;            SIMPLY DO A RETURN AFTER READING ALL OF
0450 ;            ITS ARGUMENTS. SINCE THE ZERO FLAG
0451 ;            BEING OFF INDICATES THERE IS NOT
0452 ;            A STATEMENT TERMINATOR "NEWSTT" WILL
0453 ;            DO THE JMP TO THE "SYNTAX ERROR"
0454 ;            ROUTINE. IF A STATEMENT SHOULD BE STARTED
0455 ;            OVER IT CAN DO LDWD OLDTXT, STWD TXTPTR RTS SINCE THE TEXT
0456 ;            PNTR AT "NEWSTT" IS ALWAYS STORED IN "OLDTXT".
0457 ;            THE ^C CODE STORES [CURLIN] (THE
0458 ;            CURRENT LINE NUMBER) IN "OLDLIN" SINCE THE ^C CHECK
0459 ;            IS MADE BEFORE THE STATEMENT POINTED TO IS
0460 ;            EXECUTED. "STOP" AND "END" STORE THE TEXT POINTER
0461 ;            FROM "TXTPTR", WHICH POINTS AT THEIR TERMINATING
0462 ;            CHARACTER, IN "OLDTXT".
0463 ;
0464 ;    STATEMENT CODE
0465 ;            THE INDIVIDUAL STATEMENT CODE COMES
0466 ;            NEXT. THE APPROACH USED IN EXECUTING EACH
0467 ;            STATEMENT IS DOCUMENTED IN THE STATEMENT CODE
0468 ;            ITSELF.
0469 ;
0470 ;    FRMEVL, THE FORMULA EVALUATOR
0471 ;            GIVEN A TEXT POINTER POINTING TO THE STARTING
0472 ;            CHARACTER OF A FORMULA, "FRMEVL"
0473 ;            EVALUATES THE FORMULA AND LEAVES
0474 ;            THE VALUE IN THE FLOATING ACCUMULATOR (FAC).
0475 ;            "TXTPTR" IS RETURNED POINTING TO THE FIRST CHARACTER
0476 ;            THAT COULD NOT BE INTERPRETED AS PART OF THE
0477 ;            FORMULA. THE ALGORITHM USES THE STACK
0478 ;            TO STORE TEMPORARY RESULTS:
0479 ;
0480 ;                    0. PUT A DUMMY PRECEDENCE OF ZERO ON
0481 ;                            THE STACK.
0482 ;                    1. READ LEXEME (CONSTANT,FUNCTION,
0483 ;                            VARIABLE,FORMULA IN PARENS)
0484 ;                            AND TAKE THE LAST PRECEDENCE VALUE
0485 ;                            OFF THE STACK.
0486 ;                    2. SEE IF THE NEXT CHARACTER IS AN OPERATOR.
0487 ;                            IF NOT, CHECK PREVIOUS ONE. THIS MAY CAUSE
0488 ;                            OPERATOR APPLICATION OR AN ACTUAL
0489 ;                            RETURN FROM "FRMEVL".
0490 ;                    3. IF IT IS, SEE WHAT PRECEDENCE IT HAS
0491 ;                            AND COMPARE IT TO THE PRECEDENCE
0492 ;                            OF THE LAST OPERATOR ON THE STACK.
0493 ;                    4. IF = OR LESS REMEMBER THE OPERATOR
0494 ;                            POINTER OF THIS OPERATOR
0495 ;                            AND BRANCH TO "QCHNUM" TO CAUSE
0496 ;                            APPLICATION OF THE LAST OPERATOR.
0497 ;                            EVENTUALLY RETURN TO STEP 2
0498 ;                            BY RETURNING TO JUST AFTER "DOPREC".
0499 ;                    5. IF GREATER PUT THE LAST PRECEDENCE
0500 ;                            BACK ON, SAVE THE OPERATOR ADDRESS,
0501 ;                            CURRENT TEMPORARY RESULT,
0502 ;                            AND PRECEDENCE AND RETURN TO STEP 1.
0503 ;
0504 ;            RELATIONAL OPERATORS ARE ALL HANDLED THROUGH
0505 ;            A COMMON ROUTINE. SPECIAL
0506 ;            CARE IS TAKEN TO DETECT TYPE MISMATCHES SUCH AS 3+"F".
0507 ;
0508 ;    EVAL -- THE ROUTINE TO READ A LEXEME
0509 ;            "EVAL" CHECKS FOR THE DIFFERENT TYPES OF
0510 ;            ENTITIES IT IS SUPPOSED TO DETECT.
0511 ;            LEADING PLUSES ARE IGNORED,
0512 ;            DIGITS AND "." CAUSE "FIN" (FLOATING INPUT)
0513 ;            TO BE CALLED. FUNCTION NAMES CAUSE THE
0514 ;            FORMULA INSIDE THE PARENTHESES TO BE EVALUATED
0515 ;            AND THE FUNCTION ROUTINE TO BE CALLED. VARIABLE
0516 ;            NAMES CAUSE "PTRGET" TO BE CALLED TO GET A POINTER
0517 ;            TO THE VALUE, AND THEN THE VALUE IS PUT INTO
0518 ;            THE FAC. AN OPEN PARENTHESIS CAUSES "FRMEVL"
0519 ;            TO BE CALLED (RECURSIVELY), AND THE ")" TO
0520 ;            BE CHECKED FOR. UNARY OPERATORS (NOT AND
0521 ;            NEGATION)  PUT THEIR PRECEDENCE ON THE STACK
0522 ;            AND ENTER FORMULA EVALUATION AT STEP 1, SO
0523 ;            THAT EVERYTHING UP TO AN OPERATOR GREATER THAN
0524 ;            THEIR PRECEDENCE OR THE END OF THE FORMULA
0525 ;            WILL BE EVALUATED.
0526 ;
0527 ;    DIMENSION AND VARIABLE SEARCHING
0528 ;            SPACE IS ALLOCATED FOR VARIABLES AS THEY ARE
0529 ;            ENCOUNTERED. THUS "DIM" STATEMENTS MUST BE
0530 ;            EXECUTED TO HAVE EFFECT. 6 BYTES ARE ALLOCATED
0531 ;            FOR EACH SIMPLE VARIABLE, WHETHER IT IS A STRING,
0532 ;            NUMBER OR USER DEFINED FUNCTION. THE FIRST TWO
0533 ;            BYTES GIVE THE NAME OF THE VARIABLE AND THE LAST FOUR
0534 ;            GIVE ITS VALUE. [VARTAB] GIVES THE FIRST LOCATION
0535 ;            WHERE A SIMPLE VARIABLE NAME IS FOUND AND [ARYTAB]
0536 ;            GIVES THE LOCATION TO STOP SEARCHING FOR SIMPLE
0537 ;            VARIABLES. A "FOR" ENTRY HAS A TEXT POINTER
0538 ;            AND A POINTER TO A VARIABLE VALUE SO NEITHER
0539 ;            THE PROGRAM OR THE SIMPLE VARIABLES CAN BE
0540 ;            MOVED WHILE THERE ARE ACTIVE "FOR" ENTRIES ON THE STACK.
0541 ;            USER DEFINED FUNCTION VALUES ALSO CONTAIN
0542 ;            POINTERS INTO SIMPLE VARIABLE SPACE SO NO USER-DEFINED
0543 ;            FUNCTION VALUES CAN BE RETAINED IF SIMPLE VARIABLES
0544 ;            ARE MOVED. ADDING A SIMPLE VARIABLE IS JUST
0545 ;            ADDING SIX TO [ARYTAB] AND [STREND], BLOCK TRANSFERING
0546 ;            THE ARRAY VARIABLES UP BY SIX AND MAKING SURE THE
0547 ;            NEW [STREND] IS NOT TOO CLOSE TO THE STRINGS.
0548 ;            THIS MOVEMENT OF ARRAY VARIABLES MEANS
0549 ;            THAT NO POINTER TO AN ARRAY WILL STAY VALID WHEN
0550 ;            NEW SIMPLE VARIABLES CAN BE ENCOUNTERED. THIS IS
0551 ;            WHY ARRAY VARIABLES ARE NOT ALLOWED FOR "FOR"
0552 ;            LOOP VARIABLES. SETTING UP A NEW ARRAY VARIABLE
0553 ;            MERELY INVOLVES BUILDING THE DESCRIPTOR,
0554 ;            UPDATING [STREND], AND MAKING SURE THERE IS
0555 ;            STILL ENOUGH ROOM BETWEEN [STREND] AND STRING SPACE.
0556 ;            "PTRGET", THE ROUTINE WHICH RETURNS A POINTER
0557 ;            TO A VARIABLE VALUE, HAS TWO IMPORTANT FLAGS. ONE IS
0558 ;            "DIMFLG" WHICH INDICATES WHETHER "DIM" CALLED "PTRGET"
0559 ;            OR NOT. IF SO, NO PRIOR ENTRY FOR THE VARIABLE IN
0560 ;            QUESTION SHOULD BE FOUND, AND THE INDEX INDICATES
0561 ;            HOW MUCH SPACE TO SET ASIDE. SIMPLE VARIABLES CAN
0562 ;            BE "DIMENSIONED", BUT THE ONLY EFFECT WILL BE TO
0563 ;            SET ASIDE SPACE FOR THE VARIABLE IF IT HASN'T BEEN
0564 ;            ENCOUNTERED YET. THE OTHER IMPORTANT FLAG IS "SUBFLG"
0565 ;            WHICH INDICATES WHETHER A SUBSCRIPTED VARIABLE SHOULD BE
0566 ;            ALLOWED IN THE CURRENT CONTEXT. IF [SUBFLG] IS NON-ZERO
0567 ;            THE OPEN PARENTHESIS FOR A SUBSCRIPTED VARIABLE
0568 ;            WILL NOT BE SCANNED BY "PTRGET", AND "PTRGET" WILL RETURN
0569 ;            WITH A TEXT POINTER POINTING TO THE "(", IF
0570 ;            THERE WAS ONE.
0571 ;    STRINGS
0572 ;            IN THE VARIABLE TABLES STRINGS ARE STORED JUST LIKE
0573 ;            NUMERIC VARIABLES. SIMPLE STRINGS HAVE THREE VALUE
0574 ;            BYTES WHICH ARE INITIALIZED TO ALL ZEROS (WHICH
0575 ;            REPRESENTS THE NULL STRING). THE ONLY DIFFERENCE
0576 ;            IN HANDLING IS THAT WHEN "PTRGET" SEES A "$" AFTER THE
0577 ;            NAME OF A VARIABLE, "PTRGET" SETS [VALTYP]
0578 ;            TO NEGATIVE ONE AND TURNS
0579 ;            ON THE MSB (MOST-SIGNIFIGANT-BIT) OF THE VALUE OF
0580 ;            THE FIRST CHARACTER OF THE VARIABLE NAME.
0581 ;            HAVING THIS BIT ON IN THE NAME OF THE VARIABLE ENSURES
0582 ;            THAT THE SEARCH ROUTINE WILL NOT MATCH
0583 ;            'A' WITH 'A$' OR 'A$' WITH 'A'. THE MEANING OF
0584 ;            THE THREE VALUE BYTES ARE:
0585 ;                    LOW
0586 ;                            LENGTH OF THE STRING
0587 ;                            LOW 8 BITS
0588 ;                            HIGH 8 BITS  OF THE ADDRESS
0589 ;                                    OF THE CHARACTERS IN THE
0590 ;                                    STRING IF LENGTH.NE.0.
0591 ;                                    MEANINGLESS OTHERWISE.
0592 ;                    HIGH
0593 ;            THE VALUE OF A STRING VARIABLE (THESE 3 BYTES)
0594 ;            IS CALLED THE STRING DESCRIPTOR TO DISTINGUISH
0595 ;            IT FROM THE ACTUAL STRING DATA. WHENEVER A
0596 ;            STRING CONSTANT IS ENCOUNTERED IN A FORMULA OR AS
0597 ;            PART OF AN INPUT STRING, OR AS PART OF DATA, "STRLIT"
0598 ;            IS CALLED, CAUSING A DESCRIPTOR TO BE BUILT FOR
0599 ;            THE STRING. WHEN ASSIGNMENT IS MADE TO A STRING POINTING INTO
0600 ;            "BUF" THE VALUE IS COPIED INTO STRING SPACE SINCE [BUF]
0601 ;            IS ALWAYS CHANGING.
0602 ;
0603 ;            STRING FUNCTIONS AND THE ONE STRING OPERATOR "+"
0604 ;            ALWAYS RETURN THEIR VALUES IN STRING SPACE.
0605 ;            ASSIGNING A STRING A CONSTANT VALUE IN A PROGRAM
0606 ;            THROUGH A "READ" OR ASSIGNMENT STATEMENT
0607 ;            WILL NOT USE ANY STRING SPACE SINCE
0608 ;            THE STRING DESCRIPTOR  WILL POINT INTO THE
0609 ;            PROGRAM ITSELF. IN GENERAL, COPYING IS DONE
0610 ;            WHEN A STRING VALUE IS IN "BUF", OR IT IS IN STRING
0611 ;            SPACE AND THERE IS AN ACTIVE POINTER TO IT.
0612 ;            THUS F$=G$ WILL CAUSE COPYING IF G$ HAS ITS
0613 ;            STRING DATA IN STRING SPACE. F$=CHR$(7)
0614 ;            WILL USE ONE BYTE OF STRING SPACE TO STORE THE
0615 ;            NEW ONE CHARACTER STRING CREATED BY "CHR$", BUT
0616 ;            THE ASSIGNMENT ITSELF WILL CAUSE NO COPYING SINCE
0617 ;            THE ONLY POINTER AT THE NEW STRING IS A
0618 ;            TEMPORARY DESCRIPTOR CREATED BY "FRMEVL" WHICH WILL
0619 ;            GO AWAY AS SOON AS THE ASSIGNMENT IS DONE.
0620 ;            IT IS THE NATURE OF GARBAGE COLLECTION THAT
0621 ;            DISALLOWS HAVING TWO STRING DESCRIPTORS POINT TO THE SAME
0622 ;            AREA IN STRING SPACE. STRING FUNCTIONS AND OPERATORS
0623 ;            MUST PROCEED AS FOLLOWS:
0625 ;
0624 ;                    1) FIGURE OUT THE LENGTH OF THEIR RESULT.
0626 ;                    2) CALL "GETSPA" TO FIND SPACE FOR THEIR
0627 ;                       RESULT. THE ARGUMENTS TO THE FUNCTION
0628 ;                       OR OPERATOR MAY CHANGE SINCE GARBAGE COLLECTION
0629 ;                       MAY BE INVOKED. THE ONLY THING THAT CAN
0630 ;                       BE SAVED DURING THE CALL TO "GETSPA" IS A POINTER
0631 ;                       TO THE DESCRIPTORS OF THE ARGUMENTS.
0632 ;                    3) CONSTRUCT THE RESULT DESCRIPTOR IN "DSCTMP".
0633 ;                       "GETSPA" RETURNS THE LOCATION OF THE AVAILABLE
0634 ;                       SPACE.
0635 ;                    4) CREATE THE NEW VALUE BY COPYING PARTS
0636 ;                       OF THE ARGUMENTS OR WHATEVER.
0637 ;                    5) FREE UP THE ARGUMENTS BY CALLING "FRETMP".
0638 ;                    6) JUMP TO "PUTNEW" TO GET THE DESCRIPTOR IN
0639 ;                       "DSCTMP" TRANSFERRED INTO A NEW STRING TEMPORARY.
0640 ;
0641 ;            THE REASON FOR STRING TEMPORARIES IS THAT GARBAGE
0642 ;            COLLECTION HAS TO KNOW ABOUT ALL ACTIVE STRING DESCRIPTORS
0643 ;            SO IT KNOWS WHAT IS AND ISN'T IN USE. STRING TEMPORARIES ARE
0644 ;            USED TO STORE THE DESCRIPTORS OF STRING EXPRESSIONS.
0645 ;
0646 ;            INSTEAD OF HAVING AN ACTUAL VALUE STORED IN THE
0647 ;            FAC, AND HAVING THE VALUE OF A TEMPORARY RESULT
0648 ;            BEING SAVED ON THE STACK, AS HAPPENS WITH NUMERIC
0649 ;            VARIABLES, STRINGS HAVE THE POINTER TO A STRING DESCRIPTOR
0650 ;            STORED IN THE FAC, AND IT IS THIS POINTER
0651 ;            THAT GETS SAVED ON THE STACK BY FORMULA EVALUATION.
0652 ;            STRING FUNCTIONS CANNOT FREE THEIR ARGUMENTS UP RIGHT
0653 ;            AWAY SINCE "GETSPA" MAY FORCE
0654 ;            GARBAGE COLLECTION AND THE ARGUMENT STRINGS
0655 ;            MAY BE OVER-WRITTEN SINCE GARBAGE COLLECTION
0656 ;            WILL NOT BE ABLE TO FIND AN ACTIVE POINTER TO
0657 ;            THEM. FUNCTION AND OPERATOR RESULTS ARE BUILT IN
0658 ;            "DSCTMP" SINCE STRING TEMPORARIES ARE ALLOCATED
0659 ;            (PUTNEW) AND DEALLOCATED (FRETMP) IN A FIFO ORDERING
0660 ;            (I.E. A STACK) SO THE NEW TEMPORARY CANNOT
0661 ;            BE SET UP UNTIL THE OLD ONE(S) ARE FREED. TRYING
0662 ;            TO BUILD A RESULT IN A TEMPORARY AFTER
0663 ;            FREEING UP THE ARGUMENT TEMPORARIES COULD RESULT
0664 ;            IN ONE OF THE ARGUMENT TEMPORARIES BEING OVERWRITTEN
0665 ;            TOO SOON BY THE NEW RESULT.
0666 ;
0667 ;            STRING SPACE IS ALLOCATED AT THE VERY TOP
0668 ;            OF MEMORY. "MEMSIZ" POINTS BEYOND THE LAST LOCATION OF
0669 ;            STRING SPACE. STRINGS ARE STORED IN HIGH LOCATIONS
0670 ;            FIRST. WHENEVER STRING SPACE IS ALLOCATED (GETSPA).
0671 ;            [FRETOP], WHICH IS INITIALIZED TO [MEMSIZ], IS UPDATED
0672 ;            TO GIVE THE HIGHEST LOCATION IN STRING SPACE
0673 ;            THAT IS NOT IN USE. THE RESULT IS THAT
0674 ;            [FRETOP] GETS SMALLER AND SMALLER, UNTIL SOME
0675 ;            ALLOCATION WOULD MAKE [FRETOP] LESS THAN OR EQUAL TO
0676 ;            [STREND]. THIS MEANS STRING SPACE HAS RUN INTO THE
0677 ;            THE ARRAYS AND THAT GARBAGE COLLECTION MUST BE CALLED.
0678 ;
0679 ;            GARBAGE COLLECTION:
0680 ;                    0. [MINPTR]=[STREND] [FRETOP]=[MEMSIZ]
0681 ;                    1. [REMMIN]=0
0682 ;                    2. FOR EACH STRING DESCRIPTOR
0683 ;                       (TEMPORARIES, SIMPLE STRINGS, STRING ARRAYS)
0684 ;                       IF THE STRING IS NOT NULL AND ITS POINTER IS
0685 ;                       .GT.MINPTR AND .LT.FRETOP,
0686 ;                       [MINPTR]=THIS STRING DESCRIPTOR'S POINTER,
0687 ;                       [REMMIN]=POINTER AT THIS STRING DESCRIPTOR.
0688 ;                       END.
0689 ;                    3. IF REMMIN.NE.0 (WE FOUND AN UNCOLLECTED STRING),
0690 ;                       BLOCK TRANSFER THE STRING DATA POINTED
0691 ;                       TO IN THE STRING DESCRIPTOR POINTED TO BY "REMMIN"
0692 ;                       SO THAT THE LAST BYTE OF STRING DATA IS AT
0693 ;                       [FRETOP]. UPDATE [FRETOP] SO THAT IT
0694 ;                       POINTS TO THE LOCATION JUST BELOW THE ONE
0695 ;                       THE STRING DATA WAS MOVED INTO. UPDATE
0696 ;                       THE POINTER IN THE DESCRIPTOR SO IT POINTS
0697 ;                       TO THE NEW LOCATION OF THE STRING DATA.
0698 ;                       GO TO STEP 1.
0699 ;
0700 ;            AFTER CALLING GARBAGE COLLECTION "GETSPA" AGAIN CHECKS
0701 ;            TO SEE IF [ACCA] CHARACTERS ARE AVAILABLE BETWEEN
0702 ;            [STREND] AND [FRETOP]; IF NOT, AN "OUT OF STRING"
0703 ;            ERROR IS INVOKED.
0704 ;
0705 ;    MATH PACKAGE
0706 ;            THE MATH PACKAGE CONTAINS FLOATING INPUT (FIN),
0707 ;            FLOATING OUTPUT (FOUT), FLOATING COMPARE (FCOMP)
0708 ;            ... AND ALL THE NUMERIC OPERATORS AND FUNCTIONS.
0709 ;            THE FORMATS, CONVENTIONS AND ENTRY POINTS ARE ALL
0710 ;            DESCRIBED IN THE MATH PACKAGE ITSELF.
0711 ;
0712 ;    INIT -- THE INITIALIZATION ROUTINE
0713 ;            THE AMOUNT OF MEMORY,
0714 ;            TERMINAL WIDTH, AND WHICH FUNCTIONS TO BE RETAINED
0715 ;            ARE ASCERTAINED FROM THE USER. A ZERO IS PUT DOWN
0716 ;            AT THE FIRST LOCATION NOT USED BY THE MATH-PACKAGE
0717 ;            AND [TXTTAB] IS SET UP TO POINT AT THE NEXT LOCATION.
0718 ;            THIS DETERMINES WHERE PROGRAM STORAGE WILL START.
0719 ;            SPECIAL CHECKS ARE MADE TO MAKE SURE
0720 ;            ALL QUESTIONS IN "INIT" ARE ANSWERED REASONABLY, SINCE
0721 ;            ONCE "INIT" FINISHES, THE LOCATIONS IT USES ARE
0722 ;            USED FOR PROGRAM STORAGE. THE LAST THING "INIT" DOES IS
0723 ;            CHANGE LOCATION ZERO TO BE A JUMP TO "READY" INSTEAD
0724 ;            OF "INIT". ONCE THIS IS DONE THERE IS NO WAY TO RESTART
0725 ;            "INIT".
0727 ;
0726 ; HIGH LOCATIONS

0729 ; PAGE
0730 ; SUBTTL     PAGE ZERO.

0731 .IF REALIO != 3
0732 |    START:  JMP INIT         ; INITIALIZE - SETUP CERTAIN LOCATIONS
0733 |                             ; AND DELETE FUNCTIONS IF NOT NEEDED,
0734 |                             ; AND CHANGE THIS TO "JMP READY"
0735 |                             ; IN CASE USER RESTARTS AT LOC ZERO.
0736 |    RDYJSR: JMP INIT         ; CHANGED TO "JMP STROUT" BY "INIT"
0737 |                             ; TO HANDLE ERRORS.
0738 |    ADRAYI: .WORD AYINT      ; STORE HERE THE ADDR OF THE
0739 |                             ; ROUTINE TO TURN THE FAC INTO A
0740 |                             ; TWO BYTE SIGNED INTEGER IN [Y,A]
0741 |    ADRGAY: .WORD GIVAYF     ; STORE HERE THE ADDR OF THE
0742 |                             ; ROUTINE TO CONVERT [Y,A] TO A FLOATING
0743 |                             ; POINT NUMBER IN THE FAC.
     .ENDIF

0744 .IF ROMSW
0745 |    USRPOK: JMP FCERR        ; SET UP ORIG BY INIT.
     .ENDIF

0747 ;
0746 ; THIS IS THE "VOLATILE" STORAGE AREA AND NONE OF IT
0748 ; CAN BE KEPT IN ROM. ANY CONSTANTS IN THIS AREA CANNOT
0749 ; BE KEPT IN A ROM, BUT MUST BE LOADED IN BY THE
0750 ; PROGRAM INSTRUCTIONS IN ROM.
0751 ;
0752 ; --- GENERAL RAM ---:

     .IF PET
     |    CHANNL: DS 1
     .ENDIF
     .IF OSI+PET
     |    NULCNT: DS 1
     |    TRMPOS: DS 1
     |    LINWID: DS 1
     |    NCMWID: DS 1
     |    LINNUM: .BYTE 0, 44
     |       BUF: DS BUFLEN
     .ENDIF

0753      CHARAC: DS 1             ; A DELIMITING CHARACTER.
0754              INTEGR=CHARAC    ; A ONE-BYTE INTEGER FROM "QINT".
0755      ENDCHR: DS 1             ; THE OTHER DELIMITING CHARACTER.
0756      COUNT:  DS 1             ; A GENERAL COUNTER.

0758 ; --- FLAGS ---:

0759      DIMFLG: DS 1             ; IN GETTING A POINTER TO A VARIABLE
0760                               ; IT IS IMPORTANT TO REMEMBER WHETHER IT
0761                               ; IS BEING DONE FOR "DIM" OR NOT.
0762                               ; DIMFLG AND VALTYP MUST BE
0763                               ; CONSECUTIVE LOCATIONS.
0764              KIMY=DIMFLG      ; PLACE TO PRESERVE Y DURING OUT.
0765      VALTYP: DS 1             ; THE TYPE INDICATOR.
0766                               ; 0=NUMERIC 1=STRING.
0767 .IF INTPRC
0768 |    INTFLG: DS 1             ; TELLS IF INTEGER.
     .ENDIF
0769      DORES:  DS 1             ; WHETHER CAN OR CAN'T CRUNCH RES'D WORDS.
0770                               ; TURNED ON WHEN "DATA"
0771                               ; BEING SCANNED BY CRUNCH SO UNQUOTED
0772                               ; STRINGS WON'T BE CRUNCHED.
0773              GARBFL=DORES     ; WHETHER TO DO GARBAGE COLLECTION.
0774      SUBFLG: DS 1             ; FLAG WHETHER SUB'D VARIABLE ALLOWED.
0775                               ; "FOR" AND USER-DEFINED FUNCTION
0776                               ; POINTER FETCHING TURN
0777                               ; THIS ON BEFORE CALLING "PTRGET"
0778                               ; SO ARRAYS WON'T BE DETECTED.
0779                               ; "STKINI" AND "PTRGET" CLEAR IT.
0780                               ; ALSO DISALLOWS INTEGERS THERE.
0781      INPFLG: DS 1             ; FLAGS WHETHER WE ARE DOING "INPUT"
0782                               ; OR "READ".
0783      TANSGN: DS 1             ; USED IN DETERMINING SIGN OF TANGENT.
0784 .IF REALIO
0785 |    CNTWFL: DS 1             ; SUPPRESS OUTPUT FLAG.
     .ENDIF
0786                               ; NON-ZERO MEANS SUPPRESS.
0787                               ; RESET BY "INPUT", READY AND ERRORS.
0788                               ; COMPLEMENTED BY INPUT OF ^O.
0790 .IF REALIO == 4               ; ROOM FOR APPLE PAGE 0 STUFF.
     |.IF !APPLE2
     ||           ORG 80           ; Can't do this for Applesoft BASIC yet ...
     |.ENDIF
     .ENDIF

0791 ; --- RAM DEALING WITH TERMINAL HANDLING ---:

0792 .IF EXTIO && !PET
0793 |    CHANNL: DS 1             ; HOLDS CHANNEL NUMBER.
     .ENDIF
0794 .IF NULCMD && !OSI
0795 |    NULCNT: .BYTE 0          ; NUMBER OF NULLS TO PRINT.
     .ENDIF
0796 .IF (REALIO != 3) && !OSI
0797 |    TRMPOS: DS 1             ; POSITION OF TERMINAL CARRIAGE.
     .ENDIF
     .IF !(OSI+PET)
0798 |    LINWID: .BYTE LINLEN     ; LENGTH OF LINE (WIDTH).
0799 |    NCMWID: .BYTE NCMPOS     ; POSITION BEYOND WHICH THERE ARE
0800 |                             ; NO MORE FIELDS.
     .ENDIF
     .IF APPLE2
     |            ORG 80           ; ... now it's time to do this for Applesoft
     .ENDIF
     .IF !(OSI+PET)
0801 |     LINNUM: .BYTE 0         ; LOCATION TO STORE LINE NUMBER BEFORE BUF
0802 |                             ; SO THAT "BLTUC" CAN STORE IT ALL AWAY AT
     |                             ; ONCE.
0803 |             .BYTE 44        ; A COMMA (PRELOAD OR FROM ROM)
0804 |                             ; USED BY INPUT STATEMENT SINCE THE
0805 |                             ; DATA POINTER ALWAYS STARTS ON A
0806 |                             ; COMMA OR TERMINATOR.
     .ENDIF

     ; NOTE: this late allocation of a zero page input buffer may not work to
     ; ===== get a matching zero page layout. OSI BASIC-in-ROM is one example.

0807 .IF !(BUFPAG+OSI+PET)
0808 |    BUF:    DS BUFLEN        ; TYPE IN STORED HERE.
     .ENDIF
0809                               ; DIRECT STATEMENTS EXECUTE OUT OF
0810                               ; HERE. REMEMBER "INPUT" SMASHES BUF.
0811                               ; MUST BE ON PAGE ZERO
0812                               ; OR ASSIGNMENT OF STRING
0813                               ; VALUES IN DIRECT STATEMENTS WON'T COPY
0814                               ; INTO STRING SPACE -- WHICH IT MUST.
0815                               ; N.B. TWO NONZERO BYTES MUST
                                   ; PRECEDE "BUFLNM".

0817 ; --- STORAGE FOR TEMPORARY THINGS ---:

0818      TEMPPT: DS 1             ; POINTER AT FIRST FREE TEMP DESCRIPTOR.
0819                               ; INITIALIZED TO POINT TO TEMPST.
0820      LASTPT: DS 2             ; POINTER TO LAST-USED STRING TEMPORARY.
0821      TEMPST: DS STRSIZ*NUMTMP ; STORAGE FOR NUMTMP TEMP DESCRIPTORS.
0822      INDEX1: DS 2             ; INDEXES.
0823              INDEX = INDEX1
0824      INDEX2: DS 2
0825      RESHO:  DS 1             ; RESULT OF MULTIPLIER AND DIVIDER.
0826 .IF ADDPRC
0827 |    RESMOH: DS 1             ; ONE MORE BYTE.
     .ENDIF
0828      RESMO:  DS 1
0829      RESLO:  DS 1
0830              ADDEND = RESMO   ; TEMPORARY USED BY "UMULT".
0831              .BYTE 0          ; OVERFLOW FOR RES.

0833 ; --- POINTERS INTO DYNAMIC DATA STRUCTURES ---:

0834      TXTTAB: DS 2             ; POINTER TO BEGINNING OF TEXT.
0835                               ; DOESN'T CHANGE AFTER BEING
0836                               ; SETUP BY "INIT".
0837      VARTAB: DS 2             ; POINTER TO START OF SIMPLE
0838                               ; VARIABLE SPACE.
0839                               ; UPDATED WHENEVER THE SIZE OF THE
0840                               ; PROGRAM CHANGES, SET TO [TXTTAB]
0841                               ; BY "SCRATCH" ("NEW").
0842      ARYTAB: DS 2             ; POINTER TO BEGINNING OF ARRAY
0843                               ; TABLE.
0844                               ; INCREMENTED BY 6 WHENEVER
0845                               ; A NEW SIMPLE VARIABLE IS FOUND, AND
0846                               ; SET TO [VARTAB] BY "CLEARC".
0847      STREND: DS 2             ; END OF STORAGE IN USE.
0848                               ; INCREASED WHENEVER A NEW ARRAY
0849                               ; OR SIMPLE VARIABLE IS ENCOUNTERED.
0850                               ; SET TO [VARTAB] BY "CLEARC".
0851      FRETOP: DS 2             ; TOP OF STRING FREE SPACE.
0852      FRESPC: DS 2             ; POINTER TO NEW STRING.
0853      MEMSIZ: DS 2             ; HIGHEST LOCATION IN MEMORY.

0855 ; --- LINE NUMBERS AND TEXTUAL POINTERS ---:

0856      CURLIN: DS 2             ; CURRENT LINE #.
0857                               ; SET TO 0,255 FOR DIRECT STATEMENTS.
0858      OLDLIN: DS 2             ; OLD LINE NUMBER (SETUP BY ^C,"STOP"
0859                               ; OR "END" IN A PROGRAM).
0860              POKER = LINNUM   ; SET UP LOCATION USED BY POKE.
0861                               ; TEMPORARY FOR INPUT AND READ CODE
0862      OLDTXT: DS 2             ; OLD TEXT POINTER.
0863                               ; POINTS AT STATEMENT TO BE EXEC'D NEXT.
0864      DATLIN: DS 2             ; DATA LINE # -- REMEMBER FOR ERRORS.
0865      DATPTR: DS 2             ; POINTER TO DATA. INITIALIZED TO POINT
0866                               ; AT THE ZERO IN FRONT OF [TXTTAB]
0867                               ; BY "RESTORE" WHICH IS CALLED BY "CLEARC".
0868                               ; UPDATED BY EXECUTION OF A "READ".
0869      INPPTR: DS 2             ; THIS REMEMBERS WHERE INPUT IS COMING FROM.

0871 ; --- STUFF USED IN EVALUATIONS ---:

0872      VARNAM: DS 2             ; VARIABLE'S NAME IS STORED HERE.
0873      VARPNT: DS 2             ; POINTER TO VARIABLE IN MEMORY.
0874              FDECPT = VARPNT  ; POINTER INTO POWER OF TENS OF "FOUT".
0875      FORPNT: DS 2             ; A VARIABLE'S POINTER FOR "FOR" LOOPS
0876                               ; AND "LET" STATEMENTS.
0877              LSTPNT = FORPNT  ; PNTR TO LIST STRING.
0878              ANDMSK = FORPNT  ; THE MASK USED BY WAIT FOR ANDING.
0879              EORMSK = FORPNT+1; THE MASK FOR EORING IN WAIT.
0880      OPPTR:  DS 2             ; POINTER TO CURRENT OP'S ENTRY IN "OPTAB".
     .IF OSI+PET
     |    VARTXT: SET LINNUM
     .ELSE
0881 |    VARTXT: SET OPPTR        ; POINTER INTO LIST OF VARIABLES.
     .ENDIF
0882      OPMASK: DS 1             ; MASK CREATED BY CURRENT OPERATOR.
0883              DOMASK = TANSGN  ; MASK IN USE BY RELATION OPERATIONS.
0884      DEFPNT: DS 2             ; POINTER USED IN FUNCTION DEFINITION.
0885              GRBPNT = DEFPNT  ; ANOTHER USED IN GARBAGE COLLECTION.
0886      DSCPNT: DS 2             ; POINTER TO A STRING DESCRIPTOR.
0887 .IF ADDPRC                    ; FOR TEMPF3.
     |            DS 1
     .ENDIF
         DSCLEN:                   ; temporary for string descriptor length
0888      FOUR6:  .BYTE STRSIZ     ; VARIABLE CONSTANT USED BY GARB COLLECT.

0890 ; --- ET CETERA ---:

0891      JMPER:  JMP 60000
0892              SIZE   = JMPER+1
0893              OLDOV  = JMPER+2 ; THE OLD OVERFLOW.
0894              TEMPF3 = DEFPNT  ; A THIRD FAC TEMPORARY (4 BYTES).
0895      TEMPF1:
0896 .IF ADDPRC                    ; FOR TEMPF1S EXTRA BYTE.
     |    .BYTE 0
     .ENDIF
0897      HIGHDS: DS 2             ; DESINATION OF HIGHEST ELEMENT IN BLT.
0898      HIGHTR: DS 2             ; SOURCE OF HIGHEST ELEMENT TO MOVE.
0899      TEMPF2:
0900 .IF ADDPRC                    ; FOR TEMPF2S EXTRA BYTE.
     |    .BYTE 0
     .ENDIF
0901      LOWDS:  DS 2             ; LOCATION OF LAST BYTE TRANSFERRED INTO.
0902      LOWTR:  DS 2             ; LAST THING TO MOVE IN BLT.
0903              ARYPNT = HIGHDS  ; A POINTER USED IN ARRAY BUILDING.
0904              GRBTOP = LOWTR   ; A POINTER USED IN GARBAGE COLLECTION.
0905              DECCNT = LOWDS   ; NUMBER OF PLACES BEFORE DECIMAL POINT.
0906              TENEXP = LOWDS+1 ; HAS A DPT BEEN INPUT?
0907              DPTFLG = LOWTR   ; BASE TEN EXPONENT.
;     .IF !PET
0908 |            EXPSGN = LOWTR+1 ; SIGN OF BASE TEN EXPONENT.
;     .ENDIF

0910 ; --- THE FLOATING ACCUMULATOR ---:

0911      FAC:
0912      FACEXP: .BYTE 0
0913      FACHO:  .BYTE 0          ; MOST SIGNIFICANT BYTE OF MANTISSA.
0914 .IF ADDPRC
0915 |    FACMOH: .BYTE 0          ; ONE MORE.
     .ENDIF
0916      FACMO:  .BYTE 0          ; MIDDLE ORDER OF MANTISSA.
0917      FACLO:  .BYTE 0          ; LEAST SIG BYTE OF MANTISSA.
0918      FACSGN: .BYTE 0          ; SIGN OF FAC (0 OR -1) WHEN UNPACKED.
0919      SGNFLG: .BYTE 0          ; SIGN OF FAC IS PRESERVED BERE BY "FIN".
0920              DEGREE = SGNFLG  ; A COUNT USED BY POLYNOMIALS.
0921              DSCTMP = FAC     ; THIS IS WHERE TEMP DESCS ARE BUILT.
0922              INDICE = FACMO   ; INDICE IS SET UP HERE BY "QINT".
0923      BITS:   .BYTE 0          ; SOMETHING FOR "SHIFTR" TO USE.

0925 ; --- THE FLOATING ARGUMENT (UNPACKED) ---:

0926      ARGEXP: .BYTE 0
0927      ARGHO:  .BYTE 0
0928 .IF ADDPRC
     |    ARGMOH: .BYTE 0
     .ENDIF
0929      ARGMO:  .BYTE 0
0930      ARGLO:  .BYTE 0
0931      ARGSGN: .BYTE 0

0933      ARISGN: .BYTE 0          ; A SIGN REFLECTING THE RESULT.
0934      FACOV:  .BYTE 0          ; OVERFLOW BYTE OF THE FAC.
0935              STRNG1 = ARISGN  ; POINTER TO A STRING OR DESCRIPTOR.

0937      FBUFPT: DS 2             ; POINTER INTO FBUFFR USED BY FOUT.
0938              BUFPTR = FBUFPT  ; POINTER TO BUF USED BY "CRUNCH".
0939              STRNG2 = FBUFPT  ; POINTER TO STRING OR DESC.
0940              POLYPT = FBUFPT  ; POINTER INTO POLYNOMIAL COEFFICIENTS.
0941              CURTOL = FBUFPT  ; ABSOLUTE LINEAR INDEX IS FORMED HERE.
     .IF APPLE2
     |    PRGEND: .DS 2
     .ENDIF

0942 ; PAGE
0943 ; SUBTTL     RAM CODE.

0944 ; THIS CODE GETS CHANGED THROUGHOUT EXECUTION.
0945 ; IT IS MADE TO BE FAST THIS WAY.
0946 ; ALSO, [X] AND [Y] ARE NOT DISTURBED
0947 ;
0948 ; "CHRGET" USING [TXTPTR] AS THE CURRENT TEXT PNTR
0949 ; FETCHES A NEW CHARACTER INTO ACCA AFTER INCREMENTING [TXTPTR]
0950 ; AND SETS CONDITION CODES ACCORDING TO WHAT'S IN ACCA.
0951 ;       NOT C=  NUMERIC   ("0" THRU "9")
0952 ;       Z=      ":" OR END-OF-LINE (A NULL)
0953 ;
0954 ; [ACCA] = NEW CHAR.
0955 ; [TXTPTR]=[TXTPTR]+1
0956 ;
0957 ; THE FOLLOWING EXISTS IN ROM IF ROM EXISTS AND IS LOADED
0958 ; DOWN HERE BY INIT. OTHERWISE IT IS JUST LOADED INTO THIS
0959 ; RAM LIKE ALL THE REST OF RAM IS LOADED.
0960 ;
0961      CHRGET: INC CHRGET+7     ; INCREMENT THE WHOLE TXTPTR.
0962              BNE CHRGOT
0963              INC CHRGET+8
0964      CHRGOT: LDA 60000        ; A LOAD WITH AN EXT ADDR.
0965              TXTPTR = CHRGOT+1
0966              CMP #$20         ; SKIP SPACES.
0967              BEQ CHRGET
0968      QNUM:   CMP #':          ; IS IT A ":"?
0969              BCS CHRRTS       ; IT IS .GE. ":"
0970              SEC
0971              SBC #'0          ; ALL CHARS .GT. "9" HAVE RET'D SO
0972              SEC
0973              SBC #256-'0      ; SEE IF NUMERIC.
0974                               ; TURN CARRY ON IF NUMERIC.
0975                               ; ALSO, SET Z IF NULL.
0976      CHRRTS: RTS              ; RETURN TO CALLER.

0978      RNDX:   .BYTE 128        ; LOADED OR FROM ROM.
0979              .BYTE 79         ; THE INITIAL RANDOM NUMBER.
0980              .BYTE 199
0981              .BYTE 82
0982 .IF ADDPRC                    ; ONE MORE BYTE.
     |            .BYTE 89
     .ENDIF

0984              ORG 255          ; PAGE 1 STUFF COMING UP.
0985      LOFBUF: DS 1             ; THE LOW FAC BUFFER. COPYABLE.

0986 ; --  PAGE ZERO/ONE BOUNDARY ---.

0987                               ; MUST HAVE 13 CONTIGUOUS BYTES.
0988      FBUFFR: DS 3*ADDPRC+13   ; BUFFER FOR "FOUT".
0989                               ; ON PAGE 1 SO THAT STRING IS NOT COPIED.
0990
0991 ; STACK IS LOCATED HERE. IE FROM THE END OF FBUFFR TO STKEND.

0992 ; PAGE
0993 ; SUBTTL     DISPATCH TABLES, RESERVED WORDS, AND ERROR TEXTS.

0995              ORG ROMLOC       ; BASIC interpreter ROM starts here

          STMDSP:
0997      .WORD END-1
0998      .WORD FOR-1
0999      .WORD NEXT-1
1000      .WORD DATA-1
1001 .IF EXTIO
1002 |    .WORD INPUTN-1
     .ENDIF
1003      .WORD INPUT-1
     .IF APPLE2
     |    .WORD DEL-1
     .ENDIF
1004      .WORD DIM-1
1005      .WORD READ-1
     .IF APPLE2
     |    .WORD GR-1
     |    .WORD TEXT-1
     |    .WORD PR_NUMBER-1
     |    .WORD IN_NUMBER-1
     |    .WORD CALL-1
     |    .WORD BAS_PLOT-1
     |    .WORD HLIN-1
     |    .WORD VLIN-1
     |    .WORD HGR2-1
     |    .WORD HGR-1
     |    .WORD HCOLOR-1
     |    .WORD HPLOT-1
     |    .WORD DRAW-1
     |    .WORD XDRAW-1
     |    .WORD HTAB-1
     |    .WORD HOME-1
     |    .WORD ROT-1
     |    .WORD SCALE-1
     |    .WORD SHLOAD-1
     |    .WORD TRACE-1
     |    .WORD NOTRACE-1
     |    .WORD NORMAL-1
     |    .WORD INVERSE-1
     |    .WORD FLASH-1
     |    .WORD COLOR-1
     |    .WORD RETURN-1
     |    .WORD VTAB-1
     |    .WORD HIMEM-1
     |    .WORD LOMEM-1
     |    .WORD ONERR-1
     |    .WORD RESUME-1
     |    .WORD RECALL-1
     |    .WORD STORE-1
     |    .WORD SPEED-1
     .ENDIF
1006      .WORD LET-1
1007      .WORD GOTO-1
1008      .WORD RUN-1
1009      .WORD BAS_IF-1
1010      .WORD RESTOR-1
     .IF APPLE2
     |    .WORD AMPERV-1           ; Ampersand '&' vector
     .ENDIF
1011      .WORD GOSUB-1
1012      .WORD RETURN-1
1013      .WORD REM-1
1014      .WORD STOP-1
1015      .WORD ONGOTO-1
1016 .IF NULCMD
1017 |    .WORD NULL-1
     .ENDIF
1018      .WORD FNWAIT-1
1019 .IF DISKO
1020 |.IF REALIO == 3
1021 ||   .WORD CQLOAD-1
1022 ||   .WORD CQSAVE-1
1023 ||   .WORD CQVERF-1
     |.ENDIF
1024 |.IF REALIO
1025 ||.IF (REALIO != 2) || OSI
1026 |||.IF REALIO != 3
1027 ||||.IF REALIO != 5
1028 |||||.WORD LOAD-1
1029 |||||.WORD SAVE-1
     ||||.ENDIF
     |||.ENDIF
     ||.ENDIF
     |.ENDIF
1030 |.IF REALIO != 1
     ||.IF REALIO != 2
1031 |||.IF REALIO != 3
1032 ||||.IF REALIO != 4
1033 ||||| .WORD 511               ; ADDRESS OF LOAD
1034 ||||| .WORD 511               ; ADDRESS OF SAVE
     ||||.ENDIF
     |||.ENDIF
     ||.ENDIF
     |.ENDIF
     .ENDIF
1035      .WORD DEF-1
1036      .WORD POKE-1
1037 .IF EXTIO
1038 |    .WORD PRINTN-1
     .ENDIF
1039      .WORD PRINT-1
1040      .WORD CONT-1
1041 .IF REALIO == 0
1042 |    .WORD DDT-1
     .ENDIF
1043      .WORD LIST-1
1044      .WORD CLEAR-1
1045 .IF EXTIO
1046 |    .WORD CMD-1
1047 |    .WORD CQSYS-1
1048 |    .WORD CQOPEN-1
1049 |    .WORD CQCLOS-1
     .ENDIF
1050 .IF GETCMD
1051 |    .WORD GET-1              ; FILL W/ GET ADDR.
     .ENDIF
1052      .WORD SCRATH-1
1054  FUNDSP:  .WORD SGN
1055           .WORD INT
1056           .WORD ABS
1057 .IF !ROMSW
1058 | USRLOC: .WORD FCERR         ; INITIALLY NO USER ROUTINE.
     .ENDIF
1059 .IF ROMSW
1060 | USRLOC: .WORD USRPOK
     .ENDIF
1061      .WORD FRE
     .IF APPLE2
     |    .WORD ERROR
     |    .WORD PDL
     .ENDIF
1062      .WORD POS
1063      .WORD SQR
1064      .WORD RND
1065      .WORD LOG
1066      .WORD EXP
1067 .IF KIMROM
1068 |    .REPEAT 4
     |     .WORD FCERR
     |    .REPEND
     .ENDIF
1070 .IF !KIMROM
1071 |    COSFIX: .WORD COS
1072 |    SINFIX: .WORD SIN
1073 |    TANFIX: .WORD TAN
1074 |    ATNFIX: .WORD ATN
     .ENDIF
1075        .WORD PEEK
1076        .WORD LEN
1077        .WORD STR
1078        .WORD VAL
1079        .WORD ASC
1080        .WORD CHR
1081        .WORD LEFT
1082        .WORD RIGHT
1083        .WORD MID
1084 OPTAB: .BYTE 121
1085        .WORD FADDT-1
1086        .BYTE 121
1087        .WORD FSUBT-1
1088        .BYTE 123
1089        .WORD FMULTT-1
1090        .BYTE 123
1091        .WORD FDIVT-1
     .IF APPLE2
     |      .BYTE 125
     |      .WORD FPWRT-1
     |      .BYTE 80
     |      .WORD AND-1
     |      .BYTE 70
     |      .WORD OR-1
     |  NEGTAB: .BYTE 127
     |      .WORD NEGOP-1
     |  NOTTAB: .BYTE 127
     |      .WORD NOTOP-1
     |  PTDORL: .BYTE 100
     |      .WORD DOREL-1
     .ELSE
1092 |    .BYTE 127
1093 |    .WORD FPWRT-1
1094 |    .BYTE 80
1095 |    .WORD AND-1
1096 |    .BYTE 70
1097 |    .WORD OR-1
1098 |    NEGTAB: .BYTE 125
1099 |    .WORD NEGOP-1
1100 |    NOTTAB: .BYTE 90
1101 |    .WORD NOTOP-1
1102 |    PTDORL: .BYTE 100        ; PRECEDENCE.
1103 |    .WORD DOREL-1            ; OPERATOR ADDRESS.
     .ENDIF

1104 ;
1105 ; TOKENS FOR RESERVED WORDS ALWAYS HAVE THE MOST
1106 ; SIGNIFICANT BIT ON.
1107 ; THE LIST OF RESERVED WORDS:
1108 ;
1109          Q: SET 128-1

1110  .MAC DCI                     ; output string, then increment Q
                 .DCX {1}          ; DCX inverts MSB of last byte in string
              Q: SET Q + 1         ; this counts up the token number
     .ENDM

1112      RESLST: DCI "END"
1113              ENDTK=Q
1114              DCI "FOR"
1115              FORTK=Q
1116              DCI "NEXT"
1117              DCI "DATA"
1118              DATATK=Q
1119 .IF EXTIO
1120 |            DCI "INPUT#"
     .ENDIF
1121              DCI "INPUT"
     .IF APPLE2
     |            DCI "DEL"
     .ENDIF
1122              DCI "DIM"
1123              DCI "READ"
     .IF APPLE2
     |            DCI "GR"
     |            DCI "TEXT"
     |            DCI "PR#"
     |            DCI "IN#"
     |            DCI "CALL"
     |            DCI "PLOT"
     |            DCI "HLIN"
     |            DCI "VLIN"
     |            DCI "HGR2"
     |            DCI "HGR"
     |            DCI "HCOLOR="
     |            DCI "HPLOT"
     |            DCI "DRAW"
     |            DCI "XDRAW"
     |            DCI "HTAB"
     |            DCI "HOME"
     |            DCI "ROT="
     |            DCI "SCALE="
     |            DCI "SHLOAD"
     |            DCI "TRACE"
     |            DCI "NOTRACE"
     |            DCI "NORMAL"
     |            DCI "INVERSE"
     |            DCI "FLASH"
     |            DCI "COLOR="
     |            DCI "POP"
     |            DCI "VTAB"
     |            DCI "HIMEM:"
     |            DCI "LOMEM:"
     |            DCI "ONERR"
     |            DCI "RESUME"
     |            DCI "RECALL"
     |            DCI "STORE"
     |            DCI "SPEED="
     .ENDIF
1124              DCI "LET"
1125              DCI "GOTO"
1126              GOTOTK=Q
1127              DCI "RUN"
1128              DCI "IF"
1129              DCI "RESTORE"
     .IF APPLE2
     |            DCI "&"
     .ENDIF
1130              DCI "GOSUB"
1131              GOSUTK=Q
1132              DCI "RETURN"
1133              DCI "REM"
1134              REMTK=Q
1135              DCI "STOP"
1136              DCI "ON"
1137 .IF NULCMD
1138 |            DCI "NULL"
     .ENDIF
1139              DCI "WAIT"
1140 .IF DISKO
1141 |            DCI "LOAD"
1142 |            DCI "SAVE"
1143 |.IF REALIO == 3
1144 ||           DCI "VERIFY"
     |.ENDIF
     .ENDIF
1145              DCI "DEF"
1146              DCI "POKE"
1147 .IF EXTIO && !OSI
1148 |            DCI "PRINT#"
     .ENDIF
1149              DCI "PRINT"
1150              PRINTK=Q
1151              DCI "CONT"
1152 .IF REALIO == 0
1153 |            DCI "DDT "
     .ENDIF
1154              DCI "LIST"
1155 .IF REALIO != 3
1156 |            DCI "CLEAR"
     .ENDIF
1157 .IF REALIO == 3
1158 |            DCI "CLR"
     .ENDIF
1159 .IF EXTIO
1160 |            DCI "CMD"
1161 |            DCI "SYS"
1162 |            DCI "OPEN"
1163 |            DCI "CLOSE"
     .ENDIF
1164 .IF GETCMD
1165 |            DCI "GET"
     .ENDIF
1166              DCI "NEW"
1167              SCRATK = Q
1168 ; END OF COMMAND LIST.
1169              DCI "TAB("
1174              TABTK = Q
1175              DCI "TO"
1176              TOTK = Q
1177              DCI "FN"
1178              FNTK = Q
1179              DCI "SPC("
1184              SPCTK = Q
1185              DCI "THEN"
1186              THENTK = Q
     .IF !(OSI+KIM+PET)
1175 |            DCI "AT"
1176 |            ATTK = Q
     .ENDIF
1187              DCI "NOT"
1188              NOTTK = Q
1189              DCI "STEP"
1190              STEPTK = Q
1191              DCI "+"
1192              PLUSTK = Q
1193              DCI "-"
1194              MINUTK = Q
1195              DCI "*"
1196              DCI "/"
1197              DCI "^"
1198              DCI "AND"
1199              DCI "OR"
1200              DCI ">"          ; A GREATER THAN SIGN
1202              GREATK = Q
1203              DCI "="
1204              EQLTK = Q
1205              DCI "<"          ; A LESS THAN SIGN
1207              LESSTK = Q
1208 ;
1209 ; NOTE DANGER OF ONE RESERVED WORD BEING A PART
1210 ; OF ANOTHER:
1211 ; IE . . IF 2 GREATER THAN F OR T=5 THEN...
1212 ; WILL NOT WORK!!! SINCE "FOR" WILL BE CRUNCHED!!
1213 ; IN ANY CASE MAKE SURE THE SMALLER WORD APPEARS
1214 ; SECOND IN THE RESERVED WORD TABLE ("INP" AND "INPUT")
1215 ; ANOTHER EXAMPLE: IF T OR Q THEN ... "TO" IS CRUNCHED
1216 ;
1217              DCI "SGN"
1218              ONEFUN = Q
1219              DCI "INT"
1220              DCI "ABS"
1221              DCI "USR"
1222              DCI "FRE"
     .IF APPLE2
     |            DCI "SCRN("
     |            SCRNTK = Q
     |            DCI "PDL"
     .ENDIF
1223              DCI "POS"
1224              DCI "SQR"
1225              DCI "RND"
1226              DCI "LOG"
1227              DCI "EXP"
1228              DCI "COS"
1229              DCI "SIN"
1230              DCI "TAN"
1231              DCI "ATN"
1232              DCI "PEEK"
1233              DCI "LEN"
1234              DCI "STR$"
1235              DCI "VAL"
1236              DCI "ASC"
1237              DCI "CHR$"
1238              LASNUM = Q       ; NUMBER OF LAST FUNCTION
1239                               ; THAT TAKES ONE ARG
1240              DCI "LEFT$"
1241              DCI "RIGHT$"
1242              DCI "MID$"
     .IF !(APPLE2+OSI+KIM+PET)
1243 |            DCI "GO"
     .ENDIF
1244              GOTK = Q
1245      .BYTE 0                  ; MARKS END OF RESERVED WORD LIST
1246
1247 .IF !LNGERR
1248 |         Q: SET 0-2
1249 |.MAC DCE                     ; output a string, then ...
1250 |           .DCX {1}
     |         Q: SET Q + 2        ; ... increase Q by two.
     |.ENDM
1251 |    ERRTAB: DCE "NF"
1252 |            ERRNF = Q        ; NEXT WITHOUT FOR.
1253 |            DCE "SN"
1254 |            ERRSN = Q        ; SYNTAX
1255 |            DCE "RG"
1256 |            ERRRG = Q        ; RETURN WITHOUT GOSUB.
1257 |            DCE "OD"
1258 |            ERROD = Q        ; OUT OF DATA.
1259 |            DCE "FC"
1260 |            ERRFC = Q        ; ILLEGAL QUANTITY.
1261 |            DCE "OV"
1262 |            ERROV = Q        ; OVERFLOW.
1263 |            DCE "OM"
1264 |            ERROM = Q        ; OUT OF MEMORY.
1265 |            DCE "US"
1266 |            ERRUS = Q        ; UNDEFINED STATEMENT.
1267 |            DCE "BS"
1268 |            ERRBS = Q        ; BAD SUBSCRIPT.
1269 |            DCE "DD"
1270 |            ERRDD = Q        ; REDIMENSIONED ARRAY.
1271 |            DCE "/0"
1272 |            ERRDV0 = Q       ; DIVISION BY ZERO.
1273 |            DCE "ID"
1274 |            ERRID = Q        ; ILLEGAL DIRECT.
1275 |            DCE "TM"
1276 |            ERRTM = Q        ; TYPE MISMATCH.
1277 |            DCE "LS"
1278 |            ERRLS = Q        ; STRING TOO LONG.
1279 |.IF EXTIO
1280 ||           DCE "FD"         ; FILE DATA.
1281 ||           ERRBD = Q
     |.ENDIF
1282 |            DCE "ST"
1283 |            ERRST = Q        ; STRING FORMULA TOO COMPLEX.
1284 |            DCE "CN"
1285 |            ERRCN = Q        ; CAN'T CONTINUE.
1286 |            DCE "UF"
1287 |            ERRUF = Q        ; UNDEFINED FUNCTION.
1289 .ELSE
1290 |         Q: SET 0
1291 |    ; NOTE: THIS ERROR COUNT TECHNIQUE WILL NOT WORK IF THERE ARE MORE
1292 |    ; THAN 256 CHARACTERS OF ERROR MESSAGES
1293 |    ERRTAB: DCX "NEXT WITHOUT FOR"
1294 |            ERRNF = Q
1295 |         Q: SET Q+16
1296 |            DCX "SYNTAX"
1297 |            ERRSN = Q
1298 |         Q: SET Q+6
1299 |            DCX "RETURN WITHOUT GOSUB"
1300 |            ERRRG = Q
1301 |         Q: SET Q+20
1302 |            DCX "OUT OF DATA"
1303 |            ERROD = Q
1304 |         Q: SET Q+11
1305 |            DCX "ILLEGAL QUANTITY"
1306 |            ERRFC = Q
     |.IF PET
     ||           .BYTE 0, 0, 0, 0, 0
     ||        Q: SET Q+5
     |.ENDIF
1307 |         Q: SET Q+16
1308 |            DCX "OVERFLOW"
1309 |            ERROV = Q
1310 |         Q: SET Q+8
1311 |            DCX "OUT OF MEMORY"
1312 |            ERROM = Q
1313 |         Q: SET Q+13
1314 |            DCX "UNDEF'D STATEMENT"
1315 |            ERRUS = Q
1316 |         Q: SET Q+17
1317 |            DCX "BAD SUBSCRIPT"
1318 |            ERRBS = Q
1319 |         Q: SET Q+13
1320 |            DCX "REDIM'D ARRAY"
1321 |            ERRDD = Q
1322 |         Q: SET Q+13
1323 |            DCX "DIVISION BY ZERO"
1324 |            ERRDV0 = Q
1325 |         Q: SET Q+16
1326 |            DCX "ILLEGAL DIRECT"
1327 |            ERRID = Q
1328 |         Q: SET Q+14
1329 |            DCX "TYPE MISMATCH"
1330 |            ERRTM = Q
1331 |         Q: SET Q+13
1332 |            DCX "STRING TOO LONG"
1333 |            ERRLS = Q
1334 |         Q: SET Q+15
1335 |.IF EXTIO
     ||.IF !PET
1336 |||          DCX "FILE DATA"
     ||.ELSE
     |||          DCX "BAD DATA"
     ||.ENDIF
1337 ||           ERRBD = Q
1338 ||        Q: SET Q+9-PET      ; PET message is shorter
     |.ENDIF
1339 |            DCX "FORMULA TOO COMPLEX"
1340 |            ERRST = Q
1341 |         Q: SET Q+19
1342 |            DCX "CAN'T CONTINUE"
1343 |            ERRCN = Q
1344 |         Q: SET Q+14
1345 |            DCX "UNDEF'D FUNCTION"
1346 |            ERRUF = Q
     .ENDIF
1347
1348 ;
1349 ; NEEDED FOR MESSAGES IN ALL VERSIONS.
1350 ;
1351      ERRTXT: .DC " ERROR"
     .IF APPLE2
     |            .BYTE $07        ; ring bell
     .ENDIF
1352      .BYTE 0
1353      INTXT:  .DC " IN "
1354      .BYTE 0
     .IF !APPLE2
1355 |     REDDY: ACRLF
1356 |.IF REALIO == 3
1357 ||           .DC "READY."
     |.ENDIF
1358 |.IF REALIO != 3
1359 ||           .DC "OK"
     |.ENDIF
1360 |            ACRLF
1361 |            .BYTE 0
1362 |    BRKTXT: ACRLF
1363 |            .DC "BREAK"
1364 |    .BYTE 0
     .ELSE
     |    BRKTXT: .BYTE $0D, "BREAK", $07, 0
     .ENDIF

1365 ; PAGE
1366 ; SUBTTL     GENERAL STORAGE MANAGEMENT ROUTINES.

1367 ;
1368 ; FIND A "FOR" ENTRY ON THE STACK VIA "VARPNT".
1369 ;
1370              FORSIZ = 2*ADDPRC+16
1371      FNDFOR: TSX              ; LOAD XREG WITH STK PNTR.
1372              .REPEAT 4        ; IGNORE ADR(NEWSTT) AND RTS ADDR.
                   INX
                  .REPEND
1373      FFLOOP: LDA 257,X        ; GET STACK ENTRY.
1374              CMP #FORTK       ; IS IT A "FOR" TOKEN?
1375              BNE FFRTS        ; NO, NO "FOR" LOOPS WITH THIS PNTR.
1376              LDA FORPNT+1     ; GET HIGH.
1377              BNE CMPFOR
1378              LDA 258,X        ; PNTR IS ZERO, SO ASSUME THIS ONE.
1379              STA FORPNT
1380              LDA 259,X
1381              STA FORPNT+1
1382      CMPFOR: CMP 259,X
1383              BNE ADDFRS       ; NOT THIS ONE.
1384              LDA FORPNT       ; GET DOWN.
1385              CMP 258,X
1386              BEQ FFRTS        ; WE GOT IT! WE GOT IT!
1387      ADDFRS: TXA
1388              CLC              ; ADD 16 TO X.
1389              ADC #FORSIZ
1390              TAX              ; RESULT BACK INTO X.
1391              BNE FFLOOP
1392      FFRTS:  RTS              ; RETURN TO CALLER.
1393
1394 ;
1395 ; THIS IS THE BLOCK TRANSFER ROUTINE.
1396 ; IT MAKES SPACE BY SHOVING EVERYTHING FORWARD.
1397 ;
1398 ; ON ENTRY:
1399 ; [Y,A]=[HIGHDS]    (FOR REASON).
1400 ; [HIGHDS]= DESTINATION OF [HIGH ADDRESS].
1401 ; [LOWTR]= LOWEST ADDR TO BE TRANSFERRED.
1402 ; [HIGHTR]= HIGHEST ADDR TO BE TRANSFERRED.
1403 ;
1404 ; A CHECK IS MADE TO ASCERTAIN THAT A REASONABLE
1405 ; AMOUNT OF SPACE REMAINS BETWEEN THE BOTTOM
1406 ; OF THE STRINGS AND THE HIGHEST LOCATION TRANSFERRED INTO.
1407 ;
1408 ; ON EXIT:
1409 ; [LOWTR] ARE UNCHANGED.
1410 ; [HIGHTR]=[LOWTR]-200 OCTAL.
1411 ; [HIGHDS]=LOWEST ADDR TRANSFERRED INTO MINUS 200 OCTAL.
1412 ;
1413      BLTU:   JSR REASON       ; ASCERTAIN THAT STRING SPACE WON'T
1414                               ; BE OVERRUN.
1415              STWD STREND
1416      BLTUC:  SEC              ; PREPARE TO SUBTRACT.
1417              LDA HIGHTR
1418              SBC LOWTR        ; COMPUTE NUMBER OF THINGS TO MOVE.
1419              STA INDEX        ; SAVE FOR LATER.
1420              TAY
1421              LDA HIGHTR+1
1422              SBC LOWTR+1
1423              TAX              ; PUT IT IN A COUNTER REGISTER.
1424              INX              ; SO THAT COUNTER ALGORITHM WORKS.
1425              TYA              ; SEE IF LOW PART OF COUNT IS ZERO.
1426              BEQ DECBLT       ; YES, GO START MOVING BLOCKS.
1427              LDA HIGHTR       ; NO, MUST MODIFY BASE ADDR.
1428              SEC
1429              SBC INDEX        ; BORROW IS OFF SINCE [HIGHTR].GT.[LOWTR].
1430              STA HIGHTR       ; SAVE MODIFIED BASE ADDR.
1431              BCS BLT1         ; IF NO BORROW, GO SHOVE IT.
1432              DEC HIGHTR+1     ; BORROW IMPLIES SUB 1 FROM HIGH ORDER.
1433              SEC
1434      BLT1:   LDA HIGHDS       ; MOD BASE OF DEST ADDR.
1435              SBC INDEX
1436              STA HIGHDS
1437              BCS MOREN1       ; NO BORROW.
1438              DEC HIGHDS+1     ; DECREMENT HIGH ORDER BYTE.
1439              BCC MOREN1       ; ALWAYS SKIP.
1440      BLTLP:  LDA (HIGHTR),Y   ; FETCH BYTE TO MOVE
1441              STA (HIGHDS),Y   ; MOVE IT IN, MOVE IT OUT.
1442      MOREN1: DEY
1443              BNE BLTLP
1444              LDA (HIGHTR),Y   ; MOVE LAST OF THE BLOCK.
1445              STA (HIGHDS),Y
1446      DECBLT: DEC HIGHTR+1
1447              DEC HIGHDS+1     ; START ON NEW BLOCKS.
1448              DEX
1449              BNE MOREN1
1450              RTS              ; RETURN TO CALLER.
1451
1452 ;
1453 ; THIS ROUTINE IS USED TO ASCERTAIN THAT A GIVEN
1454 ; NUMBER OF LOCS REMAIN AVAILABLE FOR THE STACK.
1455 ;    THE CALL IS:
1456 ;       LDAI    NUMBER OF 2-BYTE ENTRIES NEEDED.
1457 ;       JSR     GETSTK
1458 ;
1459 ; THIS ROUTINE MUST BE CALLED BY ANY ROUTINE WHICH PUTS
1460 ; AN ARBITRARY AMOUNT OF STUFF ON THE STACK,
1461 ; I.E., ANY RECURSIVE ROUTINE LIKE "FRMEVL".
1462 ; IT IS ALSO CALLED BY ROUTINES SUCH AS "GOSUB" AND "FOR"
1463 ; WHICH MAKE PERMANENT ENTRIES ON THE STACK.
1464 ;
1465 ; ROUTINES WHICH MERELY USE AND FREE UP THE GUARANTEED
1466 ; NUMLEV LOCATIONS NEED NOT CALL THIS.
1467 ;
1468 ;
1469 ; ON EXIT:
1470 ;    [A] AND [X] HAVE BEEN MODIFIED.
1471 ;
1472      GETSTK: ASL              ; MULT [A] BY 2. NB, CLEARS C BIT.
1473              ADC #2*NUMLEV+[3*ADDPRC]+13; MAKE SURE 2*NUMLEV+13 LOCS
1474                               ; (13 BECAUSE OF FBUFFR)
1475              BCS OMERR        ; WILL REMAIN IN STACK.
1476              STA INDEX
1477              TSX              ; GET STACKED.
1478              CPX INDEX        ; COMPARE.
1479              BCC OMERR        ; IF STACK.LE.INDEX1, OM.
1480              RTS
1482 ;
1483 ; [Y,A] IS A CERTAIN ADDRESS. "REASON" MAKES SURE
1484 ; IT IS LESS THAN [FRETOP].
1485 ;
1486      REASON: CPY FRETOP+1
1487              BCC REARTS
1488              BNE TRYMOR       ; GO GARB COLLECT.
1489              CMP FRETOP
1490              BCC REARTS
1491      TRYMOR: PHA
1492              LDX #8+ADDPRC    ; IF TEMPF2 HAS ZERO IN BETWEEN.
1493              TYA
1494      REASAV: PHA
1495              LDA HIGHDS-1,X   ; SAVE HIGHDS ON STACK.
1496              DEX
1497              BPL REASAV       ; PUT 8 OF THEM ON STK.
1498              JSR GARBA2       ; GO GARB COLLECT.
1499              LDX #256-8-ADDPRC
1500      REASTO: PLA
1501              STA HIGHDS+8+ADDPRC,X; RESTORE AFTER GARB COLLECT.
1502              INX
1503              BMI REASTO
1504              PLA
1505              TAY
1506              PLA              ; RESTORE A AND Y.
1507              CPY FRETOP+1     ; COMPARE HIGHS
1508              BCC REARTS
1509              BNE OMERR        ; HIGHER IS BAD.
1510              CMP FRETOP       ; AND THE LOWS.
1511              BCS OMERR
1512      REARTS: RTS

1514 ; PAGE
1515 ; SUBTTL     ERROR HANDLER, READY, TERMINAL INPUT, COMPACTIFY, NEW, REINIT.

1516      OMERR:  LDX #ERROM
1517      ERROR:
1518 .IF REALIO && !APPLE2
1519 |            LSR CNTWFL       ; FORCE OUTPUT.
     .ENDIF
1520 .IF EXTIO
1521 |            LDA CHANNL       ; CLOSE NON-TERMINAL CHANNEL.
1522 |            BEQ ERRCRD
1523 |            JSR CQCCHN       ; CLOSE IT.
1524 |            LDA #0
1525 |            STA CHANNL
     .ENDIF
1526      ERRCRD:                  ; OUTPUT CRLF.
     .IF APPLE2
     |            BIT ERRFLG       ; is ONERR turned on
     |            BPL * + 5        ; yes, on
     |            JMP ERRHND
     .ENDIF
                  JSR CRDO
1527              JSR OUTSET       ; PRINT A QUESTION MARK
1528 .IF !LNGERR
1529 |            LDA ERRTAB,X     ; GET FIRST CHR OF ERR MSG.
1530 |            JSR OUTDO        ; OUTPUT IT.
1531 |            LDA ERRTAB+1,X   ; GET SECOND CHR.
1532 |            JSR OUTDO        ; OUTPUT IT.
     .ENDIF
1533 .IF LNGERR
1534 |    GETERR: LDA ERRTAB,X
1535 |            PHA
     |.IF !APPLE2
1536 ||           AND #127         ; GET RID OF HIGH BIT.
     |.ENDIF
1537 |            JSR OUTDO        ; OUTPUT IT.
1538 |            INX
1539 |            PLA              ; LAST CHAR OF MESSAGE?
1540 |            BPL GETERR       ; NO. GO GET NEXT AND OUTPUT IT.
     .ENDIF
1541      TYPERR: JSR STKINI       ; RESET THE STACK AND FLAGS.
1542              LDWDI ERRTXT     ; GET PNTR TO " ERROR".
1543      ERRFIN: JSR STROUT       ; OUTPUT IT.
1544              LDY CURLIN+1
1545              INY              ; WAS NUMBER 64000?
1546              BEQ READY        ; YES, DON'T TYPE LINE NUMBER.
1547              JSR INPRT
1548      READY:
     .IF !APPLE2
1549 |.IF REALIO
1550 ||           LSR CNTWFL       ; TURN OUTPUT BACK ON IF SUPRESSED
     |.ENDIF
1551 |            LDWDI REDDY      ; SAY "OK".
1552 |.IF REALIO != 3
1553 ||           JSR RDYJSR       ; OR GO TO INIT IF INIT ERROR.
     |.ENDIF
1554 |.IF REALIO == 3
1555 ||           JSR STROUT       ; NO INIT ERRORS POSSIBLE.
     |.ENDIF
1556 |    MAIN:   JSR INLIN        ; GET A LINE FROM TERMINAL.
     .ELSE ; APPLE2
     |            JSR CRDO
     |            LDX #'] | $80    ; print Applesoft prompt
     |    MAIN:   JSR INLIN2
     .ENDIF
1557              STXY TXTPTR      ; this is back to normal
     .IF APPLE2
     |            LSR ERRFLG       ; Clear ONERR error flag
     .ENDIF
1558              JSR CHRGET
     .IF !(OSI+PET)
1559 |            TAX              ; SET ZERO FLAG BASED ON [A]
1560 |                             ; THIS DISTINGUISHES ":" AND 0
     .ENDIF
     .IF APPLE2
     |            BEQ READY
     .ELSE
1561 |            BEQ MAIN         ; IF BLANK LINE, GET ANOTHER.
     .ENDIF
1562              LDX #255         ; SET DIRECT LINE NUMBER.
1563              STX CURLIN+1
1564              BCC MAIN1        ; IS A LINE NUMBER. NOT DIRECT.
1565              JSR CRUNCH       ; COMPACTIFY.
1566              JMP GONE         ; EXECUTE IT.
1567       MAIN1:                  ; READ LINE NUMBER INTO "LINNUM".
     .IF APPLE2
     |            LDX PRGEND
     |            STX VARTAB
     |            LDX PRGEND+1
     |            STX VARTAB+1
     .ENDIF
                  JSR LINGET
1568              JSR CRUNCH
1569              STY COUNT        ; RETAIN CHARACTER COUNT.
1570              JSR FNDLIN
1571              BCC NODEL        ; NO MATCH, SO DON'T DELETE.
1572              LDY #1
1573              LDA (LOWTR),Y
1574              STA INDEX1+1
1575              LDA VARTAB
1576              STA INDEX1
1577              LDA LOWTR+1      ; SET TRANSFER TO.
1578              STA INDEX2+1
1579              LDA LOWTR
1580              DEY
1581              SBC (LOWTR),Y    ; COMPUTE NEGATIVE LENGTH.
1582              CLC
1583              ADC VARTAB       ; COMPUTE NEW VARTAB.
1584              STA VARTAB
1585              STA INDEX2       ; SET LOW OF TRANS TO.
1586              LDA VARTAB+1
1587              ADC #255
1588              STA VARTAB+1     ; COMPUTE HIGH OF VARTAB.
1589              SBC LOWTR+1      ; COMPUTE NUMBER OF BLOCKS TO MOVE.
1590              TAX
1591              SEC
1592              LDA LOWTR
1593              SBC VARTAB       ; COMPUTE OFFSET.
1594              TAY
1595              BCS QDECT1       ; IF VARTAB.LE.LOWTR,
1596              INX              ; DECR DUE TO CARRY, AND
1597              DEC INDEX2+1     ; DECREMENT STORE SO CARRY WORKS.
1598      QDECT1: CLC
1599              ADC INDEX1
1600              BCC MLOOP
1601              DEC INDEX1+1
1602              CLC              ; FOR LATER ADCQ
1603      MLOOP:  LDA (INDEX1),Y
1604              STA (INDEX2),Y
1605              INY
1606              BNE MLOOP        ; BLOCK DONE?
1607              INC INDEX1+1
1608              INC INDEX2+1
1609              DEX
1610              BNE MLOOP        ; DO ANOTHER BLOCK. ALWAYS.
1611      NODEL:                   ; RESET ALL VARIABLE INFO SO GARBAGE
1612                               ; COLLECTION CAUSED BY REASON WILL WORK
     .IF APPLE2+OSI+KIM+PET
     |            LDA BUF
     |            BEQ FINI
     |            LDA MEMSIZ
     |            LDY MEMSIZ+1
     |            STA FRETOP
     |            STY FRETOP+1
     .ELSE
1613 |            JSR LNKPRG       ; FIX UP THE LINKS
1614 |            LDA BUF          ; SEE IF ANYTHNG THERE
1615 |            BEQ MAIN
1616 |            CLC
     .ENDIF
1617              LDA VARTAB
1618              STA HIGHTR       ; SETUP HIGHTR.
1619              ADC COUNT        ; ADD LENGTH OF LINE TO INSERT.
1620              STA HIGHDS       ; THIS GIVES DEST ADDR.
1621              LDY VARTAB+1
1622              STY HIGHTR+1     ; SAME FOR HIGH ORDERS.
1623              BCC NODELC
1624              INY
1625      NODELC: STY HIGHDS+1
1626              JSR BLTU
1627 .IF BUFPAG && !PET
1628 |            LDWD LINNUM      ; POSITION THE BINARY LINE NUMBER
1629 |            STWD BUF-2       ; IN FRONT OF BUF
     .ENDIF
1630              LDWD STREND
1631              STWD VARTAB
1632              LDY COUNT
     .IF APPLE2
     |    STOLOP: LDA BUF-5,Y
     |            DEY
     |            STA (LOWTR),Y
     |            BNE STOLOP
     |      FINI: JSR RUNC
     .ELSE
1633 |            DEY
1634 |    STOLOP: LDA BUF-4,Y
1635 |            STA (LOWTR),Y
1636 |            DEY
1637 |            BPL STOLOP
1638 |    FINI:   JSR RUNC         ; DO CLEAR & SET UP STACK.
1639 |                             ; AND SET [TXTPTR] TO [TXTTAB]-1.
     |.IF !(OSI+KIM+PET)
1640 ||           JSR LNKPRG       ; FIX UP PROGRAM LINKS
1641 ||           JMP MAIN
     |.ENDIF
     .ENDIF
1642      LNKPRG: LDWD TXTTAB      ; SET [INDEX] TO [TXTTAB].
1643              STWD INDEX
1644              CLC
1645 ;
1646 ; CHEAD GOES THROUGH PROGRAM STORAGE AND FIXES
1647 ; UP ALL THE LINKS. THE END OF EACH LINE IS FOUND
1648 ; BY SEARCHING FOR THE ZERO AT THE END.
1649 ; THE DOUBLE ZERO LINK IS USED TO DETECT THE END OF THE PROGRAM.
1650 ;
1651      CHEAD:  LDY #1
1652              LDA (INDEX),Y    ; ARRIVED AT DOUBLE ZEROES?
      .IF APPLE2
      |           BNE PUTLNK
      |           LDA VARTAB
      |           STA PRGEND
      |           LDA VARTAB+1
      |           STA PRGEND+1
      |           JMP READY
      .ENDIF
      .IF OSI+KIM+PET
      |           BNE PUTLNK
      |           JMP MAIN
      .ELSE
      |.IF !APPLE2 && !OSI
1653  ||          BEQ LNKRTS
      |.ENDIF
      .ENDIF
1654      PUTLNK: LDY #4
1655      CZLOOP: INY              ; THERE IS AT LEAST ONE BYTE.
1656              LDA (INDEX),Y
1657              BNE CZLOOP       ; NO, CONTINUE SEARCHING.
1658              INY              ; GO ONE BEYOND.
1659              TYA
1660              ADC INDEX
1661              TAX
1662              LDY #0
1663              STA (INDEX),Y
1664              LDA INDEX+1
1665              ADC #0
1666              INY
1667              STA (INDEX),Y
1668              STX INDEX
1669              STA INDEX+1
1670              BCCA CHEAD       ; ALWAYS BRANCHES.
1671      LNKRTS:
     .IF !(APPLE2+OSI+KIM+PET)
     |            RTS
     .ENDIF
1672 ;
1673 ; THIS IS THE LINE INPUT ROUTINE.
1674 ; IT READS CHARACTERS INTO BUF USING BACKARROW (UNDERSCORE, OR
1675 ; SHIFT O) AS THE DELETE CHARACTER AND @ AS THE
1676 ; LINE DELETE CHARACTER. IF MORE THAN BUFLEN CHARACTERS
1677 ; ARE TYPED, NO ECHOING IS DONE UNTIL A BACKARROW OR @ OR CR
1678 ; IS TYPED. CONTROL-G WILL BE TYPED FOR EACH EXTRA CHARACTER.
1679 ; THE ROUTINE IS ENTERED AT INLIN.
1680 ;
1681 .IF REALIO == 4
1682 |    INLIN:  LDX #128         ; NO PROMPT CHARACTER
1683 |   INLIN2:  STX CQPRMP
     |.IF APPLE2
     ||           JSR GETLN
     ||           CPX #BUFLEN-1
     ||           BCC GDBUFS
     |.ELSE
1684 ||           JSR CQINLN       ; GET A LINE ONTO PAGE 2
1685 ||           CPX #BUFLEN-1
1686 ||           BCS GDBUFS       ; NOT TOO MANY CHARACTERS
     |.ENDIF
1687 |            LDX #BUFLEN-1
1688 |    GDBUFS: LDA #0           ; PUT A ZERO AT THE END
1689 |            STA BUF,X
1690 |            TXA
1691 |            BEQ NOCHR
1692 |    LOPBHT: LDA BUF-1,X
1693 |            AND #127
1694 |            STA BUF-1,X
1695 |            DEX
1696 |            BNE LOPBHT
1697 |    NOCHR:  LDA #0
1698 |            LDXYI [BUF-1]    ; POINT AT THE BEGINNING
1699 |            RTS
     .ENDIF
1700 .IF REALIO != 4
1701 |.IF REALIO != 3
1702 ||   LINLIN:
     ||.IF REALIO == 2
1703 |||          JSR OUTDO        ; ECHO IT.
     ||.ENDIF
     |.ENDIF
1704 |            DEX              ; BACKARROW SO BACKUP PNTR AND
1705 |            BPL INLINC       ; GET ANOTHER IF COUNT IS POSITIVE.
1706 |    INLINN:
     |.IF REALIO == 2
1707 ||           JSR OUTDO        ; PRINT THE @ OR A SECOND BACKARROW
1708 ||                            ; IF THERE WERE TOO MANY.
     |.ENDIF
1709 |            JSR CRDO
1710 |    INLIN:  LDX #0
1711 |    INLINC: JSR INCHR        ; GET A CHARACTER.
1712 |.IF REALIO != 3
1713 ||           CMP #7           ; IS IT BOB ALBRECHT RINGING THE BELL
1714 ||                            ; FOR SCHOOL KIDS?
1715 ||           BEQ GOODCH
     |.ENDIF
1716 |            CMP #13          ; CARRIAGE RETURN?
1717 |            BEQ FININ1       ; YES, FINISH UP.
1718 |.IF REALIO != 3
1719 ||           CMP #32          ; CHECK FOR FUNNY CHARACTERS.
1720 ||           BCC INLINC
1721 ||           CMP #125         ; IS IT TILDA OR DELETE?
1722 ||           BCS INLINC       ; BIG BAD ONES TOO.
1723 ||           CMP #'@          ; LINE DELETE?
1724 ||           BEQ INLINN       ; YES.
1725 ||           CMP #'_          ; CHARACTER DELETE?
1726 ||           BEQ LINLIN       ; YES.
     |.ENDIF
1727 |    GOODCH:
1728 |.IF REALIO != 3
1729 ||           CPX #BUFLEN-1    ; LEAVE ROOM FOR NULL.
1730 ||                            ; COMMO ASSURES US NEVER MORE THAN BUFLEN.
1731 ||           BCS OUTBEL
     |.ENDIF
1732 |            STA BUF,X
1733 |            INX
1734 |.IF REALIO == 2
     ||           SKIP2
     |.ENDIF
1735 |.IF REALIO != 2
     ||           BNE INLINC
     |.ENDIF
1736 |.IF REALIO != 3
1737 ||   OUTBEL: LDA #7
1738 ||.IF REALIO
1739 |||          JSR OUTDO        ; ECHO IT.
     ||.ENDIF
1740 ||           BNE INLINC       ; CYCLE ALWAYS.
     |.ENDIF
1741 |    FININ1: JMP FININL       ; GO TO FININL FAR, FAR AWAY.
     .ENDIF
1742      INCHR:
1743 .IF REALIO == 3
1744 |            JSR CQINCH       ; FOR COMMODORE.
     .ENDIF
1745 .IF REALIO == 2
     |.IF !OSI
1746 ||   INCHRL: LDA $FC00
1747 ||           .REPEAT 4
     ||            NOP
     ||           .REPEND
1748 ||           LSR
1749 ||           BCC INCHRL
1750 ||           LDA $FC01        ; GET THE CHARACTER.
1751 ||           .REPEAT 4
     ||           NOP
     ||           .REPEND
     |.ELSE
     ||   INCHRL: JSR INPVEC       ; OSI input vector
     ||           .REPEAT 14
     ||            NOP
     ||           .REPEND
     |.ENDIF
1752 |            AND #127
     .ENDIF
1753 .IF REALIO == 1
1754 |            JSR $1E5A        ; 1E5A FOR MOS TECH.
     .ENDIF
1755 .IF REALIO == 4
1756 |            JSR CQINCH       ; FD0C FOR APPLE COMPUTER.
1757 |            AND #127
     .ENDIF
1758 .IF REALIO == 0
1759 |            TJSR INSIM##     ; GET A CHARACTER FROM SIMULATOR
     .ENDIF
1761 .IF REALIO
1762 |.IF EXTIO
1763 ||           LDY CHANNL       ; CNT-O HAS NO EFFECT IF NOT FROM TERM.
1764 ||           BNE INCRTS
     |.ENDIF
     |.IF !APPLE2
1765 ||           CMP #CONTW       ; SUPPRESS OUTPUT CHARACTER (^W).
1766 ||           BNE INCRTS       ; NO, RETURN.
1767 ||           PHA
1768 ||           COM CNTWFL       ; COMPLEMENT ITS STATE.
1769 ||           PLA
     |.ENDIF
     .ENDIF
1770      INCRTS: RTS              ; END OF INCHR.

1772 ;
1773 ; ALL "RESERVED" WORDS ARE TRANSLATED INTO SINGLE
1774 ; BYTES WITH THE MSB ON. THIS SAVES SPACE AND TIME
1775 ; BY ALLOWING FOR TABLE DISPATCH DURING EXECUTION.
1776 ; THEREFORE ALL STATEMENTS APPEAR TOGETHER IN THE
1777 ; RESERVED WORD LIST IN THE SAME ORDER THEY
1778 ; APPEAR IN STMDSP.
1779 ;
1780      BUFOFS: SET 0            ; THE AMOUNT TO OFFSET THE LOW BYTE
1781                               ; OF THE TEXT POINTER TO GET TO BUF AFTER
1782                               ; TXTPTR HAS BEEN SETUP TO POINT INTO BUF
1783 .IF BUFPAG
1784 |    BUFOFS: SET [BUF/256]*256
     .ENDIF
1785      CRUNCH: LDX TXTPTR       ; SET SOURCE POINTER.
     .IF APPLE2
     |            DEX
     .ENDIF
1786              LDY #4           ; SET DESTINATION OFFSET.
1787              STY DORES        ; ALLOW CRUNCHING.
     .IF APPLE2
     |            BIT AUTORUN
     |            BPL PARSE
     |            PLA
     |            PLA
     |            JSR RUNC
     |            JMP NEWSTT
     |   PARSE:   INX
     .ENDIF
1788      KLOOP:  LDA BUFOFS,X
1789 .IF REALIO == 3
1790 |            BPL CMPSPC       ; GO LOOK AT SPACES.
1791 |            CMP #PI          ; PI??
1792 |            BEQ STUFFH       ; GO SAVE IT.
1793 |            INX              ; SKIP NO PRINTING.
1794 |            BNE KLOOP        ; ALWAYS GOES.
     .ENDIF
     .IF APPLE2
     |            BIT DATAFLG
     |            BVS DASTATE
     .ENDIF
1795      CMPSPC: CMP #$20         ; IS IT A SPACE TO SAVE?
     .IF APPLE2
     |            BEQ PARSE
     .ELSE
1796 |            BEQ STUFFH       ; YES, GO SAVE IT.
     .ENDIF
1797   DASTATE:   STA ENDCHR       ; IF IT'S A QUOTE, THIS WILL
1798                               ; STOP LOOP WHEN OTHER QUOTE APPEARS.
1799              CMP #34          ; QUOTE SIGN?
     .IF !APPLE2
1800 |            BEQ STRNG        ; YES, DO SPECIAL STRING HANDLING.
1801 |            BIT DORES        ; TEST FLAG.
1802 |            BVS STUFFH       ; NO CRUNCH, JUST STORE.
     .ELSE
     |            BEQ STRNG
     |            BVS STUFFH
     .ENDIF
1803              CMP #'?          ; A QMARK?
1804              BNE KLOOP1
1805              LDA #PRINTK      ; YES, STUFF A "PRINT" TOKEN.
1806              BNE STUFFH       ; ALWAYS GO TO STUFFH.
1807      KLOOP1: CMP #'0          ; SKIP NUMERICS.
1808              BCC MUSTCR
1809              CMP #60          ; ":" AND ";" ARE ENTERED STRAIGHTAWAY.
1810              BCC STUFFH
1811      MUSTCR: STY BUFPTR       ; SAVE BUFFER POINTER.
     .IF !APPLE2
1812 |            LDY #0           ; LOAD RESLST POINTER.
1813 |            STY COUNT        ; ALSO CLEAR COUNT.
1814 |            DEY
1815 |            STX TXTPTR       ; SAVE TEXT POINTER FOR LATER USE.
1816 |            DEX
1817 |    RESER:  INY
1818 |    RESPUL: INX
1819 |    RESCON: LDA BUFOFS,X
     |.IF OSI+KIM+PET
     ||           CMP #$20         ; compare with SPACE character
     ||           BEQ RESPUL       ; skip spaces
     |.ENDIF
1820 |            SEC              ; PREPARE TO SUBSTARCT.
1821 |            SBC RESLST,Y     ; CHARACTERS EQUAL?
1822 |            BEQ RESER        ; YES, CONTINUE SEARCH.
1823 |            CMP #128         ; NO BUT MAYBE THE END IS HERE.
1824 |            BNE NTHIS        ; NO, TRULY UNEQUAL.
1825 |            ORA COUNT
     .ELSE
     |            LDA #<RESLST     ; Get Token-Name-Table's Address-1, Low
     |            STA FAC          ; Set Search Pointer, Low
     |            LDA #>RESLST-1   ; Get Token-Name-Table's Address-1, High
     |            STA FAC+1        ; Set Search Pointer, High
     |            LDY #0           ; Use Y-Reg with FAC to address Table
     |            STY COUNT        ; Holds Current Token - $80
     |            DEY              ; Prepare for INY a few lines down
     |            STX TXTPTR       ; Save Position in Input Line
     |            DEX              ; Prepare for INX a few lines down
     |      INCY: INY              ; Advance Pointer to Token Table
     |            BNE INCX         ; If No Carry Over, No Need to Bump the Page
     |            INC FAC+1        ; If Carry Over, Need to Bump the Page
     |      INCX: INX              ; Advance Pointer into Input Line
     |       LIN: LDA BUF,X        ; Get next Character from Input Line
     |            CMP #$20         ; Is Character a Blank?
     |            BEQ INCX         ; YES, Ignore All Blanks
     |            SEC              ; NO, Compare to Character in Table
     |            SBC (FAC),Y      ; Same as next Character of Token Name?
     |            BEQ INCY         ; YES, Continue Matching
     |            CMP #$80         ; MAYBE; Was it same except for bit 7?
     |            BNE NTHIS        ; NO, Skip to Next Token
     |            ORA COUNT        ; YES, End of Token Name; Get Token Number
     |            CMP #ATTK        ; Did we match AT?
     |            BNE GETBPT       ; NO, So No Ambiguity
     |            LDA BUF+1,X      ; AT could be ATN or "A TO"
     |            CMP #'N          ; ATN has precedence over AT
     |            BEQ NTHIS        ; It is ATN, Find It The Hard Way
     |            CMP #'O          ; TO has precedence over AT
     |            BEQ NTHIS        ; It is "A To", Find It The Hard Way
     |            LDA #ATTK        ; #TOK_AT   ; Not ATN Or "A TO", So Use AT
     .ENDIF
1826      GETBPT: LDY BUFPTR       ; GET BUFFER PNTR.
1827      STUFFH: INX
1828              INY
1829              STA BUF-5,Y
1830              LDA BUF-5,Y
1831              BEQ CRDONE       ; NULL IMPLIES END OF LINE.
1832              SEC              ; PREPARE TO SUBSTARCT.
1833              SBC #':          ; IS IT A ":"?
1834              BEQ COLIS        ; YES, ALLOW CRUNCHING AGAIN.
1835              CMP #DATATK-':   ; IS IT A DATATK?
1836              BNE NODATT       ; NO, SEE IF IT IS REM TOKEN.
1837      COLIS:  STA DORES        ; SETUP FLAG.
1838      NODATT: SEC              ; PREP TO SBCQ
1839              SBC #REMTK-':    ; REM ONLY STOPS ON NULL.
1840              BNE KLOOP        ; NO, CONTINUE CRUNCHING.
1841              STA ENDCHR       ; REM STOPS ONLY ON NULL, NOT : OR ".
1842      STR1:   LDA BUFOFS,X
1843              BEQ STUFFH       ; YES, END OF LINE, SO DONE.
1844              CMP ENDCHR       ; END OF GOBBLE?
1845              BEQ STUFFH       ; YES, DONE WITH STRING.
1846      STRNG:  INY              ; INCREMENT BUFFER POINTER.
1847              STA BUF-5,Y
1848              INX
1849              BNE STR1         ; PROCESS NEXT CHARACTER.
1850      NTHIS:  LDX TXTPTR       ; RESTORE TEXT POINTER.
1851              INC COUNT        ; INCREMENT RES WORD COUNT.
     .IF APPLE2                    ; Skip Over Current Keyword:
     |  SKIPOVER: LDA (FAC),Y      ; Scan Table for High ASCII Characters
     |            INY              ; Next Token, one beyond that,
     |            BNE CHKTNCH      ; It is usually enough to just INC Y-Reg
     |            INC FAC+1        ; Next Set of 256 Token Name Characters
     |   CHKTNCH: ASL              ; Is Character's Sign Bit Set?
     |            BCC SKIPOVER     ; NO, Loop until Next Token Name reached
     |            LDA (FAC),Y      ; YES, We're at Next Name; End Of Table?
     |            BNE LIN          ; NO, Loop until End of TN Table reached
     |            LDA BUF,X        ; YES, So Not a Keyword
     |            BPL GETBPT       ; Copy Char "As Is"; Always Taken
     .ELSE
1852 |    NTHIS1: INY
1853 |            LDA RESLST-1,Y   ; GET RES CHARACTER.
1854 |            BPL NTHIS1       ; END OF ENTRY?
1855 |            LDA RESLST,Y     ; YES. IS IT THE END?
1856 |            BNE RESCON       ; NO, TRY THE NEXT WORD.
1857 |            LDA BUFOFS,X     ; YES, END OF TABLE. GET 1ST CHR.
1858 |            BPL GETBPT       ; STORE IT AWAY (ALWAYS BRANCHES).
1861 |.IF [[BUF+BUFLEN]/256]-[[BUF-1]/256]
     ||           DEC TXTPTR+1
     |.ENDIF
     .ENDIF
1859      CRDONE: STA BUF-3,Y      ; SO THAT IF THIS IS A DIR STATEMENT
1860                               ; ITS END WILL LOOK LIKE END OF PROGRAM.
     .IF !(OSI+KIM+PET)
1862 |            DEC TXTPTR+1
     .ENDIF
1863              LDA #[BUF&255]-1 ; MAKE TXTPTR POINT TO
1864              STA TXTPTR       ; CRUNCHED LINE.
1865      LISTRT: RTS              ; RETURN TO CALLER.
1866 ;
1867 ; FNDLIN SEARCHES THE PROGRAM TEXT FOR THE LINE
1868 ; WHOSE NUMBER IS PASSED IN "LINNUM".
1869 ; THERE ARE TWO POSSIBLE RETURNS:
1870 ;
1871 ;       1) CARRY SET.
1872 ;          LOWTR POINTS TO THE LINK FIELD IN THE LINE
1873 ;          WHICH IS THE ONE SEARCHED FOR.
1874 ;
1875 ;       2) CARRY NOT SET.
1876 ;          LINE NOT FOUND. [LOWTR] POINTS TO THE LINE IN THE
1877 ;          PROGRAM GREATER THAN THE ONE SOUGHT AFTER.
1878 ;
1879      FNDLIN: LDWX TXTTAB      ; LOAD [X,A] WITH [TXTTAB]
1880      FNDLNC: LDY #1
1881              STWX LOWTR       ; STORE [X,A] INTO LOWTR
1882              LDA (LOWTR),Y    ; SEE IF LINK IS 0
1883              BEQ FLINRT
1884              INY
1885              INY
1886              LDA LINNUM+1     ; COMP HIGH ORDERS OF LINE NUMBERS.
1887              CMP (LOWTR),Y
1888              BCC FLNRTS       ; NO SUCH LINE NUMBER.
1889              BEQ FNDLO1
1890              DEY
1891              BNE AFFRTS       ; ALWAYS BRANCH.
1892      FNDLO1: LDA LINNUM
1893              DEY
1894              CMP (LOWTR),Y    ; COMPARE LOW ORDERS.
1895              BCC FLNRTS       ; NO SUCH NUMBER.
1896              BEQ FLNRTS       ; GO TIT.
1897      AFFRTS: DEY
1898              LDA (LOWTR),Y    ; FETCH LINK.
1899              TAX
1900              DEY
1901              LDA (LOWTR),Y
1902              BCS FNDLNC       ; ALWAYS BRANCHES.
1903      FLINRT: CLC              ; C MAY BE HIGH.
1904      FLNRTS: RTS              ; RETURN TO CALLER.
1905 ;
1906 ; THE "NEW" COMMAND CLEARS THE PROGRAM TEXT AS WELL
1907 ; AS VARIABLE SPACE.
1908 ;
1909      SCRATH: BNE FLNRTS       ; MAKE SURE THERE IS A TERMINATOR.
1910      SCRTCH: LDA #0           ; GET A CLEARER.
     .IF APPLE2
     |            STA AUTORUN
     .ENDIF
1911              TAY              ; SET UP INDEX.
1912              STA (TXTTAB),Y   ; CLEARFIRST LINK.
1913              INY
1914              STA (TXTTAB),Y
1915              LDA TXTTAB
     .IF !(APPLE2+OSI+KIM+PET)
1916 |            CLC
     .ENDIF
1917              ADC #2
1918              STA VARTAB       ; SETUP [VARTAB].
     .IF APPLE2
     |            STA PRGEND
     .ENDIF
1919              LDA TXTTAB+1
1920              ADC #0
1921              STA VARTAB+1
     .IF APPLE2
     |            STA PRGEND+1
     .ENDIF
1922      RUNC:   JSR STXTPT
1924 ;
1925 ; THIS CODE IS FOR THE CLEAR COMMAND.
1926 ;
     .IF !(OSI+PET)
1923 |            LDA #0           ; SET ZERO FLAG
1927 |    CLEAR:  BNE STKRTS       ; SYNTAX ERROR IF NO TERMINATOR.
     .ENDIF
1928 ;
1929 ; CLEAR INITIALIZES THE VARIABLE AND
1930 ; ARRAY SPACE BY RESETING ARYTAB (THE END OF SIMPLE VARIABLE SPACE)
1931 ; AND STREND (THE END OF ARRAY STORAGE). IT FALLS INTO "STKINI"
1932 ; WHICH RESETS THE STACK.
1933 ;
1934      CLEARC: LDWD MEMSIZ      ; FREE UP STRING SPACE.
1935              STWD FRETOP
1936 .IF EXTIO
1937 |            JSR CQCALL       ; CLOSE ALL OPEN FILES.
     .ENDIF
1938              LDWD VARTAB      ; LIBERATE THE
1939              STWD ARYTAB      ; VARIABLES AND
1940              STWD STREND      ; ARRAYS.
1941      FLOAD:  JSR RESTOR       ; RESTORE DATA.
1942 ;
1943 ; STKINI RESETS THE STACK POINTER ELIMINATING
1944 ; GOSUB AND FOR CONTEXT. STRING TEMPORARIES ARE FREED
1945 ; UP, SUBFLG IS RESET. CONTINUING IS PROHIBITED.
1946 ; AND A DUMMY ENTRY IS LEFT AT THE BOTTOM OF THE STACK SO "FNDFOR" WILL
1947 ; ALWAYS FIND A NON-"FOR" ENTRY AT THE BOTTOM OF THE STACK.
1948 ;
1949      STKINI: LDX #TEMPST      ; INITIALIZE STRING TEMPORARIES.
1950              STX TEMPPT
1951              PLA              ; SETUP RETURN ADDRESS.
     .IF !(OSI+KIM+PET)
1952 |            TAY
1953 |            PLA
     .ELSE
     |            STA $1FD
     |            PLA
     |            STA $1FE
     .ENDIF
1954              LDX #STKEND-STKGAP
1955              TXS
     .IF !(OSI+KIM+PET)
1956 |            PHA
1957 |            TYA
1958 |            PHA
     .ENDIF
1959              LDA #0
1960              STA OLDTXT+1     ; DISALLOWING CONTINUING
1961              STA SUBFLG       ; ALLOW SUBSCRIPTS.
1962      STKRTS: RTS
1964      STXTPT: CLC
1965              LDA TXTTAB
1966              ADC #255
1967              STA TXTPTR
1968              LDA TXTTAB+1
1969              ADC #255
1970              STA TXTPTR+1     ; SETUP TEXT POINTER.
1971              RTS

1972 ; PAGE
1973 ; SUBTTL     THE "LIST" COMMAND.

1975      LIST:   BCC GOLST        ; IT IS A DIGIT.
1976              BEQ GOLST        ; IT IS A TERMINATOR.
1977              CMP #MINUTK      ; DASH PRECEDING?
     .IF !APPLE2
1978 |            BNE STKRTS       ; NO, SO SYNTAX ERROR.
     .ELSE ; for APPLE2
1978 |            BEQ GOLST        ; NO, SO SYNTAX ERROR.
     |            CMP #',
     |            BNE STKRTS
     .ENDIF
1979      GOLST:  JSR LINGET       ; GET LINE NUMBER INTO NUMLIN.
1980              JSR FNDLIN       ; FIND LINE .GE. [NUMLIN].
1981              JSR CHRGOT       ; GET LAST CHARACTER.
1982              BEQ LSTEND       ; IF END OF LINE, # IS THE END.
1983              CMP #MINUTK      ; DASH?
     .IF APPLE2
     |            BEQ ENDRNG
     |            CMP #',
     .ENDIF
1984              BNE FLNRTS       ; IF NOT, SYNTAX ERROR.
1985      ENDRNG: JSR CHRGET       ; GET NEXT CHAR.
1986              JSR LINGET       ; GET END #.
     .IF !APPLE2
1987 |            BNE FLNRTS       ; IF NOT TERMINATOR, ERROR.
     .ELSE
     |            BNE STKRTS
     .ENDIF
1988      LSTEND: PLA
1989              PLA              ; GET RID OF "NEWSTT" RTS ADDR.
1990              LDA LINNUM       ; SEE IF IT WAS EXISTENT.
1991              ORA LINNUM+1
1992              BNE LIST4        ; IT WAS TYPED.
1993              LDA #255
1994              STA LINNUM
1995              STA LINNUM+1     ; MAKE IT HUGE.
1996      LIST4:  LDY #1
1997 .IF (REALIO == 2) || (REALIO == 3)
1998 |            STY DORES
     .ENDIF
1999              LDA (LOWTR),Y    ; IS LINK ZERO?
2000              BEQ GRODY        ; YES, GO TO READY.
2001 .IF REALIO
2002 |            JSR ISCNTC       ; LISTEN FOR CONT-C.
     .ENDIF
2003              JSR CRDO         ; PRINT CRLF TO START WITH.
2004              INY
2005              LDA (LOWTR),Y
2006              TAX
2007              INY
2008              LDA (LOWTR),Y    ; GET LINE NUMBER.
2009              CMP LINNUM+1     ; SEE IF BEYOND LAST.
2010              BNE TSTDUN       ; GO DETERMINE RELATION.
2011              CPX LINNUM       ; WAS EQUAL SO TEST LOW ORDER.
2012              BEQ TYPLIN       ; EQUAL, SO LIST IT.
2013      TSTDUN: BCS GRODY        ; IF LINE IS GR THAN LAST, THEN DUNE.
2014      TYPLIN: STY LSTPNT
2015              JSR LINPRT       ; PRINT AS INT WITHOUT LEADING SPACE.
2016              LDA #$20         ; ALWAYS PRINT SPACE AFTER NUMBER.
2017      PRIT4:  LDY LSTPNT       ; GET POINTER TO LINE BACK.
2018              AND #127
2019      PLOOP:  JSR OUTDO        ; PRINT CHAR.
2020 .IF (REALIO == 2) || (REALIO == 3)
2021 |            CMP #34
2022 |            BNE PLOOP1
2023 |            COM DORES        ; IF QUOTE, COMPLEMENT FLAG.
     .ENDIF
     .IF APPLE2
     |            LDA CH           ; Get Horizontal Cursor Position
     |            CMP #33          ; If CH is over 32, Print a CR & Tab(5)
     |            BCC NOCRTAB      ; BLT: Else, Branch (if less than 33)
     |            JSR CRDO         ; Print a Carriage <Return> Character
     |            LDA #5           ; Indent Cursor 5 spaces
     |            STA CH           ; Set Horizontal Cursor Position
     |   NOCRTAB:
     .ENDIF
2024      PLOOP1: INY
2020 .IF !(APPLE2+OSI+PET)
2025 |            BEQ GRODY        ; IF WE HAVE PRINTED 256 CHARACTERS
2026 |                             ; THE PROGRAM MUST BE MISFORMATED IN
2027 |                             ; MEMORY DUE TO A BAD LOAD OR BAD
2028 |                             ; HARDWARE. LET THE GUY RECOVER
     .ENDIF
2029              LDA (LOWTR),Y    ; GET NEXT CHAR. IS IT ZERO?
2030              BNE QPLOP        ; YES. END OF LINE.
2031              TAY
2032              LDA (LOWTR),Y
2033              TAX
2034              INY
2035              LDA (LOWTR),Y
2036              STX LOWTR
2037              STA LOWTR+1
2038              BNE LIST4        ; BRANCH IF SOMETHING TO LIST.
     .IF APPLE2
      |  GRODY:
      |  LISTED:  LDA #$0D         ; Get a Carriage Return Character
      |           JSR OUTDO        ; Print Character in A-Reg
      |           JMP NEWSTT       ; Execute a New Statement
      |                            ; Get character from table, pointer is (FAC)
      |  GETCHAR: INY              ; Advance Index
      |           BNE GC1
      |           INC FAC+1
      |      GC1: LDA (FAC),Y
      |           RTS
      .ELSE
2039  |   GRODY:  JMP READY
      .ENDIF
2040                               ; IS IT A TOKEN?
2041      QPLOP:  BPL PLOOP        ; NO, HEAD FOR PRINTER.
2042 .IF (REALIO == 2) || (REALIO == 3)
2043 |            CMP #PI
2044 |            BEQ PLOOP
2045 |            BIT DORES        ; INSIDE QUOTE MARKS?
2046 |            BMI PLOOP        ; YES, JUST TYPE THE CHARACTER.
     .ENDIF
2047              SEC
2048              SBC #127         ; GET RID OF SIGN BIT AND ADD 1.
2049              TAX              ; MAKE IT A COUNTER.
2050              STY LSTPNT       ; SAVE POINTER TO LINE.
     .IF APPLE2
     |            LDY #$D0         ; TKMNTBL.L
     |            STY FAC
     |            LDY #$CF         ; [TKNMTBL-$100].H
     |            STY FAC+1
     .ENDIF
2051              LDY #255         ; LOOK AT RES'D WORD LIST.
2052      RESRCH: DEX              ; IS THIS THE RES'D WORD?
     .IF APPLE2
     |            BEQ PT           ; Branch when Token Name needed is reached
     |      TOKL: JSR GETCHAR      ; Inc(Y), Get Char from Table; Ptr is (FAC)
     |            BPL TOKL         ; Names are Dextral Character Inverted (DCI)
     |            BMI RESRCH       ; Do Next Token Name; Always Taken
     |        PT: LDA #$20         ; Print Space, then print token name
     |            JSR OUTDO        ; Print the Space Character
     |     TOKLP: JSR GETCHAR      ; Inc(Y), Get Char from Table; Ptr is (FAC)
     |            BMI TOKDUN       ; Got Last Character of Token Name
     |            JSR OUTDO        ; Print Character in A-Reg
     |            BNE TOKLP        ; Names are Dextral Character Inverted (DCI)
     |    TOKDUN: JSR OUTDO        ; Print Last Character of Token Name
     |            LDA #$20         ; Get a SPACE Character to End TN with
     |            BNE PRIT4        ; Continue listing the line
     .ELSE
2053 |            BEQ PRIT3        ; YES, GO TOSS IT UP..
2054 |    RESCR1: INY
2055 |            LDA RESLST,Y     ; END OF ENTRY?
2056 |            BPL RESCR1       ; NO, CONTINUE PASSING.
2057 |            BMI RESRCH
2058 |    PRIT3:  INY
2059 |            LDA RESLST,Y
2060 |            BMI PRIT4        ; END OF RESERVED WORD.
2061 |            JSR OUTDO        ; PRINT IT.
2062 |            BNE PRIT3        ; END OF ENTRY? NO, TYPE REST.
     .ENDIF

2063 ; PAGE
2064 ; SUBTTL      THE "FOR" STATEMENT.

2065 ;
2066 ; A "FOR" ENTRY ON THE STACK HAS THE FOLLOWING FORMAT:
2067 ;
2068 ; LOW ADDRESS
2069 ;       TOKEN (FORTK) 1 BYTE
2070 ;       A POINTER TO THE LOOP VARIABLE 2 BYTES
2071 ;       THE STEP 4+ADDPRC BYTES
2072 ;       A BYTE REFLECTING THE SIGN OF THE INCREMENT 1 BYTE
2073 ;       THE UPPER VALUE 4+ADDPRC BYTES
2074 ;       THE LINE NUMBER OF THE "FOR" STATEMENT 2 BYTES
2075 ;       A TEXT POINTER INTO THE "FOR" STATEMENT 2 BYTES
2076 ; HIGH ADDRESS
2077 ;
2078 ; TOTAL 16+2*ADDPRC BYTES.
2079 ;
2081      FOR:    LDA #128         ; DON'T RECOGNIZE
2082              STA SUBFLG       ; SUBSCRIPTED VARIABLES.
2083              JSR LET          ; READ THE VARIABLE AND ASSIGN IT
2084                               ; THE CORRECT INITIAL VALUE AND STORE
2085                               ; A POINTER TO THE VARIABLE IN VARPNT.
2086              JSR FNDFOR       ; PNTR IS IN VARPNT, AND FORPNT.
2087              BNE NOTOL        ; IF NO MATCH, DON'T ELIMINATE ANYTHING.
2088              TXA              ; MAKE IT ARITHMETICAL.
2089              ADC #FORSIZ-3    ; ELIMINATE ALMOST ALL.
2090              TAX              ; NOTE C=1, THEN PLA, PLA.
2091              TXS              ; MANIFEST.
2092      NOTOL:  PLA              ; GET RID OF NEWSTT RETURN ADDRESS
2093              PLA              ; IN CASE THIS IS A TOTALLY NEW ENTRY.
2094              LDA #8+ADDPRC
2095              JSR GETSTK       ; MAKE SURE 16 BYTES ARE AVAILABLE.
2096              JSR DATAN        ; GET A COUNT IN [Y] OF THE NUMBER OF
2097                               ; CHACRACTERS LEFT IN THE "FOR" STATEMENT
2098                               ; [TXTPTR] IS UNAFFECTED.
2099              CLC              ; PREP TO ADD.
2100              TYA              ; SAVE IT FOR PUSHING.
2101              ADC TXTPTR
2102              PHA
2103              LDA TXTPTR+1
2104              ADC #0
2105              PHA
2106              PSHWD CURLIN     ; PUT LINE NUMBER ON STACK.
2107              SYNCHK TOTK      ; "TO" IS NECESSARY.
2108              JSR CHKNUM       ; VALUE MUST BE A NUMBER.
2109              JSR FRMNUM       ; GET UPPER VALUE INTO FAC.
2110              LDA FACSGN       ; PACK FAC.
2111              ORA #127
2112              AND FACHO
2113              STA FACHO        ; SET PACKED SIGN BIT.
2114              LDWDI LDFONE
2115              STWD INDEX1
2116              JMP FORPSH       ; PUT FAC ONTO STACK, PACKED.
2117      LDFONE: LDWDI FONE       ; PUT 1.0 INTO FAC.
2118              JSR MOVFM
2119              JSR CHRGOT
2120              CMP #STEPTK      ; A STEP IS GIVEN?
2121              BNE ONEON        ; NO. ASSUME 1.0.
2122              JSR CHRGET       ; YES. ADVANCE POINTER.
2123              JSR FRMNUM       ; READ THE STEP.
2124      ONEON:  JSR SIGN         ; GET SIGN IN ACCA.
2125              JSR PUSHF        ; PUSH FAC ONTO STACK (THRU A).
2126              PSHWD FORPNT     ; PUT PNTR TO VARIABLE ON STACK.
2127      NXTCON: LDA #FORTK       ; PUT A FORTK ONTO STACK.
2128              PHA
2129 ;            BNEA NEWSTT      ;SIMULATE BNE TO NEWSTT. JUST FALL IN.

2130 ; PAGE
2131 ; SUBTTL     NEW STATEMENT FETCHER.

2132 ;
2133 ; BACK HERE FOR NEW STATEMENT. CHARACTER POINTED TO BY TXTPTR
2134 ; IS ":" OR END-OF-LINE. THE ADDRESS OF THIS LOC IS LEFT
2135 ; ON THE STACK WHEN A STATEMENT IS EXECUTED SO THAT
2136 ; IT CAN MERELY DO A RTS WHEN IT IS DONE.
2137 ;
2138      NEWSTT:
     .IF APPLE2
     |            TSX
     |            STX REMSTK
     .ENDIF
     .IF REALIO
2139 |            JSR ISCNTC       ; LISTEN FOR CONTROL-C.
     .ENDIF
2140              LDWD TXTPTR      ; LOOK AT CURRENT CHARACTER.
     .IF APPLE2
     |            LDX CURLIN+1
     |            INX
     .ELSE
2141 |.IF BUFPAG
2142 ||           CPY #BUFPAG      ; SEE IF IT WAS DIRECT BY CHECK FOR
     ||                            ; BUF'S PAGE NUMBER
     |.ENDIF
     .ENDIF
2143              BEQ DIRCON
2144              STWD OLDTXT      ; SAVE IN CASE OF RESTART BY INPUT.
2145 .IF BUFPAG
     |    DIRCON:
     .ENDIF
2146              LDY #0
2147 .IF !BUFPAG
     |    DIRCON:
     .ENDIF
2148              LDA (TXTPTR),Y
     .IF OSI+PET
     |            BEQ DIRCO1
     |            CMP #$3A
     |            BEQ GONE
     |    SNERRJ: JMP SNERR
     .ELSE
2149 |            BNE MORSTS       ; NOT NULL -- CHECK WHAT IT IS
     .ENDIF
2150      DIRCO1: LDY #2           ; LOOK AT LINK.
2151              LDA (TXTPTR),Y   ; IS LINK 0?
2152              CLC              ; CLR CARRY FOR ENDCON AND MATH THAT FOLLOWS
     .IF APPLE2+OSI+KIM+PET
     |            BEQ GOEND
     .ELSE
2153 |            JEQ ENDCON       ; YES - RAN OFF THE END.
     .ENDIF
2154              INY              ; PUT LINE NUMBER IN CURLIN.
2155              LDA (TXTPTR),Y
2156              STA CURLIN
2157              INY
2158              LDA (TXTPTR),Y
2159              STA CURLIN+1
2160              TYA
2161              ADC TXTPTR
2162              STA TXTPTR
2163              BCC GONE
2164              INC TXTPTR+1
2165      GONE:                    ; GET THE STATEMENT TYPE.
     .IF APPLE2
     |    TRACEQ: BIT TRCFLG       ; Is TRACE ON? [(bit7)=(OFF<128/ON>127)]
     |            BPL EXECUTE      ; NO, TRACE is OFF, Go Execute Statements
     |                             ; YES, TRACE is ON, are we in Direct Mode ?
     |            LDX CURLIN+1     ; Get Current Line Number, High
     |            INX              ; Line Number is $FF if in Direct Mode
     |            BEQ EXECUTE      ; YES, Direct Command, Go Execute Statements
     |                             ; NO, Deferred Command, Print Tracing Info:
     |            LDA #'#          ; Get '#' Character in A-Reg
     |            JSR OUTDO        ; Print '#' Character in A-Reg
     |            LDX CURLIN       ; Get Current Line Number, Low
     |            LDA CURLIN+1     ; Get Current Line Number, High
     |            JSR LINPRT       ; Print the Line Number [(X,A)={Low,High}]
     |            JSR OUTSPC       ; Print a Space (' ') Character
     .ENDIF
         EXECUTE: JSR CHRGET
2166              JSR GONE3
2167              JMP NEWSTT
     .IF APPLE2
     |     GOEND: BEQ ENDCON
     .ENDIF
     .IF OSI+PET
     |    GONE3:  BEQ CONTRT
     |            SEC
     |    GONE2:  SBC #ENDTK
     |            BCS GONE4
     |            JMP LET
     .ELSE
2168 |    GONE3:  BEQ ISCRTS       ; IF TERMINATOR, TRY AGAIN.
2169 |                             ; NO NEED TO SET UP CARRY SINCE IT WILL
2170 |                             ; BE ON IF NON-NUMERIC AND NUMERICS
2171 |                             ; WILL CAUSE A SYNTAX ERROR LIKE THEY SHOULD
2172 |    GONE2:  SBC #ENDTK       ; " ON ... GOTO AND GOSUB" COME HERE.
2173 |            BCC GLET
     .ENDIF
2174      GONE4:  CMP #SCRATK-ENDTK+1
     .IF !(APPLE2+OSI+KIM+PET)
2175 |            BCS SNERRX       ; SOME RES'D WORD BUT NOT
2176 |                             ; A STATEMENT RES'D WORD.
     .ENDIF
     .IF APPLE2 || KIM
     |            BCS SNERR1
     .ENDIF
     .IF OSI || PET
     |            BCS SNERRJ
     .ENDIF
2177              ASL              ; MULTIPLY BY TWO.
2178              TAY              ; MAKE AN INDEX.
2179              LDA STMDSP+1,Y
2180              PHA
2181              LDA STMDSP,Y
2182              PHA              ; PUT DISP ADDR ONTO STACK.
2183              JMP CHRGET
     .IF !(OSI+PET)
2184 |    GLET:   JMP LET          ; MUST BE A LET
2185 |    MORSTS: CMP #':
2186 |            BEQ GONE         ; IF A ":" CONTINUE STATEMENT
2187 |    SNERR1: JMP SNERR        ; NEITHER 0 OR ":" SO SYNTAX ERROR
     .ENDIF
     .IF !(APPLE2+OSI+KIM+PET)
2188 |    SNERRX: CMP #GOTK-ENDTK
2189 |            BNE SNERR1
2190 |            JSR CHRGET       ; READ IN THE CHARACTER AFTER "GO "
2191 |            SYNCHK TOTK
2192 |            JMP GOTO
     .ENDIF

2193 ; PAGE
2194 ; SUBTTL     RESTORE,STOP,END,CONTINUE,NULL,CLEAR.

2196      RESTOR: SEC
2197              LDA TXTTAB
2198              SBC #1
2199              LDY TXTTAB+1
2200              BCS RESFIN
2201              DEY
2202      RESFIN: STWD DATPTR      ; READ FINISHES COME TO "RESFIN".
2203      ISCRTS: RTS
2205 .IF REALIO == 1
2206 |    ISCNTC: LDA #1
2207 |            BIT $1740
2208 |            BMI ISCRTS
2209 |            LDX #8
2210 |            LDA #3
     |.IF KIM
     ||           CLC              ; ineffective but is so in KIM BASIC ...
     |.ENDIF
2211 |            CMP #3           ; ... this CMP makes it be ineffective.
     .ENDIF
2212 .IF REALIO == 2
     |.IF OSI
     ||   ISCNTC: JMP CTLCCK       ; Check CTRL-C key
     |.ELSE
2213 ||   ISCNTC: LDA $FC00
     |.ENDIF
2214 |            .REPEAT 4
     |             NOP
     |            .REPEND
2215 |            LSR
2216 |            BCC ISCRTS
2217 |            JSR INCHR        ; EAT CHAR THAT WAS TYPED
2218 |            CMP #3           ; WAS IT A CONTROL-C??
     .ENDIF
2220 .IF REALIO == 4
2221 |    ISCNTC: LDA KBD          ; CHECK THE CHARACTER
2222 |            CMP #$83
2223 |            BEQ ISCCAP
2224 |            RTS
2225 |    ISCCAP: JSR INCHR
     |.IF APPLE2
     ||CKONERR:   LDX #$FF         ; $FF is the code for 'attempted CTRL-C'
     ||           BIT ERRFLG       ; is ONERR GOTO enabled ?
     ||           BPL ISCTRLC      ; no, disabled
     ||           JMP ERRHND       ; error handler
     ||  ISCTRLC: CMP #$03         ; aka CTRLC   ; double check for CTRL-C
     |.ELSE                        ; ... then fall through to STOP
2226 ||           CMP #$83
     |.ENDIF
     .ENDIF
2227      STOP:   BCS STOPC        ; MAKE [C] NONZERO AS A FLAG.
2228      END:    CLC
2229      STOPC:  BNE CONTRT       ; RETURN IF NOT CONT-C OR
2230                               ; IF NO TERMINATOR FOR STOP OR END.
2231                               ; [C]=0 SO WILL NOT PRINT "BREAK".
2232              LDWD TXTPTR
2233 .IF BUFPAG
2234 |            LDX CURLIN+1
2235 |            INX
     .ENDIF
2236              BEQ DIRIS
2237              STWD OLDTXT
2238      STPEND: LDWD CURLIN
2239              STWD OLDLIN
2240      DIRIS:  PLA              ; POP OFF NEWSTT ADDR.
2241              PLA
2242      ENDCON: LDWDI BRKTXT
2243 .IF REALIO && !APPLE2
2244 |            LDX #0
2245 |            STX CNTWFL
     .ENDIF
2246              BCC GORDY        ; CARRY CLEAR SO DON'T PRINT "BREAK".
2247              JMP ERRFIN
2248      GORDY:  JMP READY        ; TYPE "READY".
2250 .IF REALIO == 0
2251 |    DDT:    PLA              ; GET RID OF NEWSTT RETURN.
2252 |            PLA
2253 |            HRRZ 14,.JBDDT##
2254 |            JRST 0(14)
     .ENDIF
2255      CONT:   BNE CONTRT       ; MAKE SURE THERE IS A TERMINATOR.
2256              LDX #ERRCN       ; CONTINUE ERROR.
2257              LDY OLDTXT+1     ; A STORED TXTPTR OF ZERO IS SETUP
2258                               ; BY STKINI AND INDICATES THERE IS
2259                               ; NOTHING TO CONTINUE.
2260              JEQ ERROR        ; "STOP", "END", TYPING CRLF TO
2261                               ; "INPUT" AND  ^C SETUP OLDTXT.
2262              LDA OLDTXT
2263              STWD TXTPTR
2264              LDWD OLDLIN
2265              STWD CURLIN
2266      CONTRT: RTS              ; RETURN TO CALLER.
2268 .IF NULCMD+PET
2269 |    NULL:   JSR GETBYT
2270 |            BNE CONTRT       ; MAKE SURE THERE IS TERMINATOR.
2271 |            INX
2272 |            CPX #FCELIM      ; IS THE NUMBER REASONABLE?
2273 |            BCS FCERR1       ; "FUNCTION CALL" ERROR.
2274 |            DEX              ; BACK -1
2275 |            STX NULCNT
2276 |            RTS
2277 |    FCERR1: JMP FCERR
     .ENDIF

2278 ; PAGE
2279 ; SUBTTL     LOAD AND SAVE SUBROUTINES.

2281 .IF REALIO == 1               ; KIM CASSETTE I/O
2282 |    SAVE:   TSX              ; SAVE STACK POINTER
2283 |            STX INPFLG
2284 |            LDA #STKEND-256-200
2285 |            STA $F2          ; SETUP DUMMY STACK FOR KIM MONITOR
2286 |            LDA #254         ; MAKE ID BYTE EQUAL TO FF HEX
2287 |            STA $17F9        ; STORE INTO KIM ID
2288 |            LDWD TXTTAB      ; START DUMPING FROM TXTTAB
2289 |            STWD $17F5       ; SETUP SAL,SAH
2290 |            LDWD VARTAB      ; STOP AT VARTAB
2291 |            STWD $17F7       ; SETUP EAL,EAH
2292 |            JMP $1800
2293 |    RETSAV: LDX INPFLG       ; RESTORE THE REAL STACK POINTER
2294 |            TXS
2295 |            LDWDI TAPMES     ; SAY IT WAS DONE
2296 |            JMP STROUT
2297 |    GLOAD:  .DC "LOADED"
2298 |    .BYTE 0
2299 |    TAPMES: .DC "SAVED"
2300 |            ACRLF
2301 |    .BYTE 0
2302 |    PATSAV: DS 20
2303 |    LOAD:   LDWD TXTTAB      ; START DUMPING IN AT TXTTAB
2304 |            STWD $17F5       ; SETUP SAL,SAH
2305 |            LDA #255
2306 |            STA $17F9
2307 |            LDWDI RTLOAD
2308 |            STWD $01         ; SET UP RETURN ADDRESS FOR LOAD
2309 |            JMP $1873        ; GO READ THE DATA IN
2310 |    RTLOAD: LDX #STKEND-256  ; RESET THE STACK
2311 |            TXS
2312 |            LDWDI READY
2313 |            STWD $01
2314 |            LDWDI GLOAD      ; TELL HIM IT WORKED
2315 |            JSR STROUT
2316 |            LDXY $17ED       ; GET LAST LOCATION
2317 |            TXA              ; ITS ONE TOO BIG
2318 |            BNE DECVRT       ; DECREMENT [X,Y]
2319 |            NOP
2320 |    DECVRT: NOP
2321 |            STXY VARTAB      ; SETUP NEW VARIABLE LOCATION
2322 |            JMP FINI         ; RELINK THE PROGRAM
     .ENDIF
     .IF OSI+PET
     | CLEAR:     BNE CONTRT
     |            JMP CLEARC
     .ENDIF
2323 .IF REALIO == 4
2324 |    SAVE:   SEC              ; CALCULATE PROGRAM SIZE IN POKER
     |.IF APPLE2
     ||           LDA PRGEND
     |.ELSE
2325 ||           LDA VARTAB
     |.ENDIF
2326 |            SBC TXTTAB
2327 |            STA POKER
     |.IF APPLE2
     ||           LDA PRGEND+1
     |.ELSE
2328 ||           LDA VARTAB+1
     |.ENDIF
2329 |            SBC TXTTAB+1
2330 |            STA POKER+1
2331 |            JSR VARTIO
2332 |            JSR CQCOUT       ; WRITE PROGRAM SIZE [POKER]
2333 |            JSR PROGIO
2334 |            JMP CQCOUT       ; WRITE PROGRAM.
2336 |    LOAD:   JSR VARTIO
2337 |            JSR CQCSIN       ; READ SIZE OF PROGRAM INTO POKER
2338 |            CLC
2339 |            LDA TXTTAB       ; CALCULATE VARTAB FROM SIZE AND
2340 |            ADC POKER        ; TXTTAB
2341 |            STA VARTAB
2342 |            LDA TXTTAB+1
2343 |            ADC POKER+1
2344 |            STA VARTAB+1
     |.IF APPLE2
     ||           LDA TEMPPT
     ||           STA AUTORUN
     |.ENDIF
2345 |            JSR PROGIO
2346 |            JSR CQCSIN       ; READ PROGRAM.
     |.IF APPLE2
     ||           BIT AUTORUN
     ||           BPL BASLDED
     ||           JMP $D665    ;STPTRS
     ||BASLDED:   JMP $D4F2    ; FIXLINKS
     |.ELSE ;!APPLE2
2347 ||           LDWDI TPDONE
2348 ||           JSR STROUT
2349 ||           JMP FINI
2351 ||   TPDONE: .DC "LOADED"
2352 ||           .BYTE 0
     |.ENDIF
2354 |    VARTIO: LDWDI POKER
2355 |            STWD $3C
2356 |            LDA #POKER+2
2357 |            STWD $3E
     |.IF APPLE2
     ||           STY AUTORUN
     |.ENDIF
2358 |            RTS
2359 |    PROGIO: LDWD TXTTAB
2360 |            STWD $3C
2361 |            LDWD VARTAB
2362 |            STWD $3E
2363 |            RTS
     .ENDIF
     .IF APPLE2
     |       RUN: PHP              ; Save Processor Status while subtracting
     |            DEC CURLIN+1     ; If in Direct Mode ($FF), make it Run Mode
     |            PLP              ; Restore Processor Status
     |            BNE RUNLIN       ; Branch if Given a Line Number
     |            JMP RUNC         ; Run from Program Start
     .ELSE
2366 |    RUN:    JEQ RUNC         ; IF NO LINE # ARGUMENT.
     .ENDIF

2364 ; PAGE
2365 ; SUBTTL     RUN,GOTO,GOSUB,RETURN.

2367     RUNLIN:  JSR CLEARC       ; CLEAN UP -- RESET THE STACK.
2368              JMP RUNC2        ; MUST REPLACE RTS ADDR.
2369 ;
2370 ; A GOSUB ENTRY ON THE STACK HAS THE FOLLOWING FORMAT:
2371 ;
2372 ; LOW ADDRESS:
2373 ;       THE GOSUTK ONE BYTE
2374 ;       THE LINE NUMBER OF THE GOSUB STATEMENT TWO BYTES
2375 ;       A POINTER INTO THE TEXT OF THE GOSUB TWO BYTES
2376 ;
2377 ; HIGH ADDRESS.
2378 ;
2379 ; TOTAL FIVE BYTES.
2380 ;
2381      GOSUB:  LDA #3
2382              JSR GETSTK       ; MAKE SURE THERE IS ROOM.
2383              PSHWD TXTPTR     ; PUSH ON THE TEXT POINTER.
2384              PSHWD CURLIN     ; PUSH ON THE CURRENT LINE NUMBER.
2385              LDA #GOSUTK
2386              PHA              ; PUSH ON A GOSUB TOKEN.
2387      RUNC2:  JSR CHRGOT       ; GET CHARACTER AND SET CODES FOR LINGET.
2388              JSR GOTO         ; USE RTS SCHEME TO "NEWSTT".
2389              JMP NEWSTT
2390
2391      GOTO:   JSR LINGET       ; PICK UP THE LINE NUMBER IN "LINNUM".
2392              JSR REMN         ; SKIP TO END OF LINE.
2393              LDA CURLIN+1
2394              CMP LINNUM+1
2395              BCS LUK4IT
2396              TYA
2397              SEC
2398              ADC TXTPTR
2399              LDX TXTPTR+1
2400              BCC LUKALL
2401              INX
2402              BCSA LUKALL      ; ALWAYS GOES.
2403      LUK4IT: LDWX TXTTAB
2404      LUKALL: JSR FNDLNC       ; [X,A] ARE ALL SET UP.
2405      QFOUND: BCC USERR        ; GOTO LINE IS NONEXISTANT.
2406              LDA LOWTR
2407              SBC #1
2408              STA TXTPTR
2409              LDA LOWTR+1
2410              SBC #0
2411              STA TXTPTR+1
2412      GORTS:  RTS              ; PROCESS THE STATEMENT.
2413 ;
2414 ; "RETURN" RESTORES THE LINE NUMBER AND TEXT PNTR FROM THE STACK
2415 ; AND ELIMINATES ALL THE "FOR" ENTRIES IN FRONT OF THE "GOSUB" ENTRY.
2416 ;
2417      RETURN: BNE GORTS        ; NO TERMINATOR=BLOW HIM UP.
2418              LDA #255
     .IF (APPLE2+OSI+KIM+PET)      ; all of these machines deviate from ...
     |            STA FORPNT       ; (is this the FOR/NEXT *** BUG *** ?)
     .ELSE                         ; ... the original Microsoft source code:
2419 |            STA FORPNT+1     ; MAKE SURE THE VARIABLE'S PNTR
2420 |                             ; NEVER GETS MATCHED.
     .ENDIF                        ; ... which is believed to not have the bug.
2421              JSR FNDFOR       ; GO PAST ALL THE "FOR" ENTRIES.
2422              TXS
2423              CMP #GOSUTK      ; RETURN WITHOUT GOSUB?
2424              BEQ RETU1
2425              LDX #ERRRG
2426              SKIP2
2427      USERR:  LDX #ERRUS       ; NO MATCH SO "US" ERROR.
2428              JMP ERROR        ; YES.
2429      SNERR2: JMP SNERR
2430      RETU1:  PLA              ; REMOVE GOSUTK.
      .IF APPLE2
      |           PLA
      |           CPY #$42         ; a ***BUG*** ??? Or Not ?
      |           BEQ PULL3
      |           STA CURLIN
      |           PLA
      |           STA CURLIN+1
      .ELSE
2431  |           PULWD CURLIN     ; GET LINE NUMBER "GOSUB" WAS FROM.
      .ENDIF
2432              PULWD TXTPTR     ; GET TEXT PNTR FROM "GOSUB".

2433      DATA:   JSR DATAN        ; SKIP TO END OF STATEMENT,
2434                               ; SINCE WHEN "GOSUB" STUCK THE TEXT  PNTR
2435                               ; ONTO THE STACK, THE LINE NUMBER ARG
2436                               ; HADN'T BEEN READ YET.
2437      ADDON:  TYA
2438              CLC
2439              ADC TXTPTR
2440              STA TXTPTR
2441              BCC REMRTS
2442              INC TXTPTR+1
2443      REMRTS: RTS              ; "NEWSTT" RTS ADDR IS STILL THERE.
2445      DATAN:  LDX #':          ; "DATA" TERMINATES ON ":" AND NULL.
2446              SKIP2
2447      REMN:   LDX #0           ; THE ONLY TERMINATOR IS NULL.
2448              STX CHARAC       ; PRESERVE IT.
2449              LDY #0           ; THIS MAKES CHARAC=0 AFTER SWAP.
2450              STY ENDCHR
2451      EXCHQT: LDA ENDCHR
2452              LDX CHARAC
2453              STA CHARAC
2454              STX ENDCHR
2455      REMER:  LDA (TXTPTR),Y
2456              BEQ REMRTS       ; NULL ALWAYS TERMINATES.
2457              CMP ENDCHR       ; IS IT THE OTHER TERMINATOR?
2458              BEQ REMRTS       ; YES, IT'S FINISHED.
2459              INY              ; PROGRESS TO NEXT CHARACTER.
2460              CMP #34          ; IS IT A QUOTE?
     .IF !(OSI+PET)
2461 |            BNE REMER        ; NO, JUST CONTINUE.
2462 |            BEQA EXCHQT      ; YES, TIME TO TRADE.
     .ELSE
     |            BEQ EXCHQT
     |            BNEA REMER
     .ENDIF
     .IF APPLE2
     |     PULL3: PLA
     |            PLA
     |            PLA
     |            RTS
     .ENDIF

2463 ; PAGE
2464 ; SUBTTL     "IF ... THEN" CODE.

2465      BAS_IF: JSR FRMEVL       ; EVALUATE A FORMULA (IF: changed to BAS_IF)
2466              JSR CHRGOT       ; GET CURRENT CHARACTER.
2467              CMP #GOTOTK      ; IS TERMINATING CHARACTER A GOTOTK?
2468              BEQ OKGOTO       ; YES.
2469              SYNCHK THENTK    ; NO, IT MUST BE "THEN".
2470      OKGOTO: LDA FACEXP       ; 0=FALSE. ALL OTHERS TRUE.
2471              BNE DOCOND       ; TRUE !
2472      REM:    JSR REMN         ; SKIP REST OF STATEMENT.
2473              BEQA ADDON       ; WILL ALWAYS BRANCH.
2474      DOCOND: JSR CHRGOT       ; TEST CURRENT CHARACTER.
2475              BCS DOCO         ; IF A NUMBER, GOTO IT.
2476              JMP GOTO
2477      DOCO:   JMP GONE3        ; INTERPRET NEW STATEMENT.

2478 ; PAGE
2479 ; SUBTTL     "ON ... GO TO ..." CODE.

2480      ONGOTO: JSR GETBYT       ; GET VALUE IN FACLO.
2481              PHA              ; SAVE FOR LATER.
2482              CMP #GOSUTK      ; AN "ON ... GOSUB" PERHAPS?
2483              BEQ ONGLOP       ; YES.
2484      SNERR3: CMP #GOTOTK      ; MUST BE "GOTOTK".
2485              BNE SNERR2
2486      ONGLOP: DEC FACLO
2487              BNE ONGLP1       ; SKIP ANOTHER LINE NUMBER.
2488              PLA              ; GET DISPATCH CHARACTER.
2489              JMP GONE2
2490      ONGLP1: JSR CHRGET       ; ADVANCE AND SET CODES.
2491              JSR LINGET
2492              CMP #44          ; IS IT A COMMA?
2493              BEQ ONGLOP
2494              PLA              ; REMOVE STACK ENTRY (TOKEN).
2495      ONGRTS: RTS              ; EITHER END-OF-LINE OR SYNTAX ERROR.

2496 ; PAGE
2497 ; SUBTTL     LINGET -- READ A LINE NUMBER INTO LINNUM

2498 ;
2499 ; "LINGET" READS A LINE NUMBER FROM THE CURRENT TEXT POSITION.
2500 ;
2501 ; LINE NUMBERS RANGE FROM 0 TO 64000-1.
2502 ;
2503 ; THE ANSWER IS RETURNED IN "LINNUM".
2504 ; "TXTPTR" IS UPDATED TO POINT TO THE TERMINATING CHARCTER
2505 ; AND [A] = THE TERMINATING CHARACTER WITH CONDITION
2506 ; CODES SET UP TO REFLECT ITS VALUE.
2507 ;
2508      LINGET: LDX #0
2509              STX LINNUM       ; INITIALIZE LINE NUMBER TO ZERO.
2510              STX LINNUM+1
2511      MORLIN: BCS ONGRTS       ; IT IS NOT A DIGIT.
2512              SBC #'0 -1       ; -1 SINCE C=0.
2513              STA CHARAC       ; SAVE CHARACTER.
2514              LDA LINNUM+1
2515              STA INDEX
2516              CMP #25          ; LINE NUMBER WILL BE .LT. 64000?
2517              BCS SNERR3
2518              LDA LINNUM
2519              ASL              ; MULTIPLY BY 10.
2520              ROL INDEX
2521              ASL
2522              ROL INDEX
2523              ADC LINNUM
2524              STA LINNUM
2525              LDA INDEX
2526              ADC LINNUM+1
2527              STA LINNUM+1
2528              ASL LINNUM
2529              ROL LINNUM+1
2530              LDA LINNUM
2531              ADC CHARAC       ; ADD IN DIGIT.
2532              STA LINNUM
2533              BCC NXTLGC
2534              INC LINNUM+1
2535      NXTLGC: JSR CHRGET
2536              JMP MORLIN

2538 ; PAGE
2539 ; SUBTTL     "LET" CODE.

2540      LET:    JSR PTRGET       ; GET PNTR TO VARIABLE INTO "VARPNT".
2541              STWD FORPNT      ; PRESERVE POINTER.
2542              SYNCHK EQLTK     ; "=" IS NECESSARY.
2543 .IF INTPRC
2544 |            LDA INTFLG       ; SAVE FOR LATER.
2545 |            PHA
     .ENDIF
2546              LDA VALTYP       ; RETAIN THE VARIABLE'S VALUE TYPE.
2547              PHA
2548              JSR FRMEVL       ; GET VALUE OF FORMULA INTO "FAC".
2549              PLA
2550              ROL              ; CARRY SET FOR STRING, OFF FOR
2551                               ; NUMERIC.
2552              JSR CHKVAL       ; MAKE SURE "VALTYP" MATCHES CARRY.
2553                               ; AND SET ZERO FLAG FOR NUMERIC.
2554              BNE COPSTR       ; IF NUMERIC, COPY IT.
2555      COPNUM:
2556 .IF INTPRC
2557 |            PLA              ; GET NUMBER TYPE.
2558 |    QINTGR: BPL COPFLT       ; STORE A FLTING NUMBER.
2559 |            JSR ROUND        ; ROUND INTEGER.
2560 |            JSR AYINT        ; MAKE 2-BYTE NUMBER.
2561 |            LDY #0
2562 |            LDA FACMO        ; GET HIGH.
2563 |            STA (FORPNT),Y   ; STORE IT.
2564 |            INY
2565 |            LDA FACLO        ; GET LOW.
2566 |            STA (FORPNT),Y
2567 |            RTS
     .ENDIF
2568      COPFLT: JMP MOVVF        ; PUT NUMBER @FORPNT.
2570      COPSTR:
2571 .IF INTPRC                    ; IF STRING, NO INTFLG.
     |            PLA
     .ENDIF
2572      INPCOM:
2573 .IF TIME
2574 |            LDY FORPNT+1     ; TI$?
2575 |            CPY #ZERO/256    ; ONLY TI$ CAN BE THIS ON ASSIG.
2576 |            BNE GETSPT       ;  WAS NOT TI$.
2577 |            JSR FREFAC       ; WE WONT NEEDIT.
2578 |            CMP #6           ; LENGTH CORRECT?
     |.IF !PET
2579 ||           BNE FCERR2
     |.ELSE
     ||           BEQ TIMEBG
     ||           JMP FCERR
     |.ENDIF
2580 |    TIMEBG: LDY #0           ; YES. DO SETUP.
2581 |            STY FACEXP       ; ZERO FAC TO START WITH.
2582 |            STY FACSGN
2583 |    TIMELP: STY FBUFPT       ; SAVE POSOTION.
2584 |            JSR TIMNUM       ; GET A DIGIT.
2585 |            JSR MUL10        ; WHOLE QTY BY 10.
2586 |            INC FBUFPT
2587 |            LDY FBUFPT
2588 |            JSR TIMNUM
2589 |            JSR MOVAF
2590 |            TAX              ; IF NUM=0 THEN NO MULT.
2591 |            BEQ NOML6        ; IF =0, GO TIT.
2592 |            INX              ; MULT BY TWO.
2593 |            TXA
2594 |            JSR FINML6       ; ADD IN AND MULT BY 2 GIVES *6.
2595 |    NOML6:  LDY FBUFPT
2596 |            INY
2597 |            CPY #6           ; DONE ALL SIX?
2598 |            BNE TIMELP
2599 |            JSR MUL10        ; ONE LAST TIME.
2600 |            JSR QINT         ; SHIFT IT OVER TO THE RIGHT.
2601 |            LDX #2
2602 |            SEI              ; DISALLOW INTERRUPTS.
2603 |    TIMEST: LDA FACMOH,X
2604 |            STA CQTIMR,X
2605 |            DEX
2606 |            BPL TIMEST       ; LOOP 3 TIMES.
2607 |            CLI              ; TURN ON INTS AGAIN.
2608 |            RTS
2609 |    TIMNUM: LDA (INDEX),Y    ; INDEX SET UP BY FREFAC.
2610 |            JSR QNUM
2611 |            BCC GOTNUM
2612 |    FCERR2: JMP FCERR        ; MUST BE NUMERIC STRING.
2613 |    GOTNUM: SBC #'0 -1       ; C IS OFF.
2614 |            JMP FINLOG       ; ADD IN DIGIT TO FAC.
     .ENDIF
2615
2616      GETSPT: LDY #2           ; GET PNTR TO DESCRIPTOR.
2617              LDA (FACMO),Y
2618              CMP FRETOP+1     ; SEE IF IT POINTS INTO STRING SPACE.
2619              BCC DNTCPY       ; IF [FRETOP],GT.[2&3,FACMO], DON'T COPY.
2620              BNE QVARIA       ; IT IS LESS.
2621              DEY
2622              LDA (FACMO),Y
2623              CMP FRETOP       ; COMPARE LOW ORDERS.
2624              BCC DNTCPY
2625      QVARIA: LDY FACLO
2626              CPY VARTAB+1     ; IF [VARTAB].GT.[FACMO], DON'T COPY.
2627              BCC DNTCPY
2628              BNE COPY         ; IT IS LESS.
2629              LDA FACMO
2630              CMP VARTAB       ; COMPARE LOW ORDERS.
2631              BCS COPY
2632      DNTCPY: LDWD FACMO
2633              JMP COPYZC
2634      COPY:   LDY #0
2635              LDA (FACMO),Y
2636              JSR STRINI       ; GET ROOM TO COPY STRING INTO.
2637              LDWD DSCPNT      ; GET POINTER TO OLD DESCRIPTOR, SO
2638              STWD STRNG1      ; MOVINS CAN FIND STRING.
2639              JSR MOVINS       ; COPY IT.
2640              LDWDI DSCTMP     ; GET POINTER TO OLD DESCRIPTOR.
2641      COPYZC: STWD DSCPNT      ; REMEMBER POINTER TO DESCRIPTOR.
2642              JSR FRETMS       ; FREE UP THE TEMPORARY WITHOUT
2643                               ; FREEING UP ANY STRING SPACE.
2644              LDY #0
2645              LDA (DSCPNT),Y
2646              STA (FORPNT),Y
2647              INY              ; POINT TO STRING PNTR.
2648              LDA (DSCPNT),Y
2649              STA (FORPNT),Y
2650              INY
2651              LDA (DSCPNT),Y
2652              STA (FORPNT),Y
2653              RTS

2654 ; PAGE
2655 ; SUBTTL     PRINT CODE.

2656 .IF EXTIO
2657 |    PRINTN: JSR CMD          ; DOCMD
2658 |            JMP IODONE       ; RELEASE CHANNEL.
2659 |    CMD:    JSR GETBYT
2660 |            BEQ SAVEIT
2661 |            SYNCHK 44        ; COMMA?
2662 |    SAVEIT: PHP
2663 |            JSR CQOOUT       ; CHECK AND OPEN OUTPUT CHANNL.
2664 |            STX CHANNL       ; CHANNL TO OUTPUT ON.
2665 |            PLP              ; GET STATUS BACK.
2666 |            JMP PRINT
     .ENDIF
2667      STRDON: JSR STRPRT
2668      NEWCHR: JSR CHRGOT       ; REGET LAST CHARACTER.
2669      PRINT:  BEQ CRDO         ; TERMINATOR SO TYPE CRLF.
2670      PRINTC: BEQ PRTRTS       ; HERE AFTER SEEING TAB(X) OR , OR ;
2671                               ; IN WHICH CASE A TERMINATOR DOES NOT
2672                               ; MEAN TYPE A CRLF BUT JUST RTS.
2673              CMP #TABTK       ; TAB FUNCTION?
2674              BEQ TABER        ; YES.
2675              CMP #SPCTK       ; SPACE FUNCTION?
     .IF !(OSI+KIM+PET)
2676 |            CLC
     .ENDIF
2677              BEQ TABER
2678              CMP #44          ; A COMMA?
     .IF APPLE2+KIM
     |            CLC
     .ENDIF
2679              BEQ COMPRT       ; YES.
2680              CMP #59          ; A SEMICOLON?
2681              BEQ NOTABR       ; YES.
2682              JSR FRMEVL       ; EVALUATE THE FORMULA.
2683              BIT VALTYP       ; A STRING?
2684              BMI STRDON       ; YES.
2685              JSR FOUT
2686              JSR STRLIT       ; BUILD DESCRIPTOR.
     .IF APPLE2
     |            JMP STRDON
     .ELSE
2687 |.IF REALIO != 3
2688 ||           LDY #0           ; GET THE POINTER.
2689 ||           LDA (FACMO),Y
2690 ||           CLC
2691 ||           ADC TRMPOS       ; MAKE SURE LEN+POS.LT.WIDTH.
2692 ||           CMP LINWID       ; GREATER THAN LINE LENGTH?
2693 ||                            ; REMEMBER SPACE PRINTED AFTER NUMBER.
2694 ||           BCC LINCHK       ; GO TYPE.
2695 ||           JSR CRDO         ; YES, TYPE CRLF FIRST.
     |.ENDIF
2696 |    LINCHK: JSR STRPRT       ; PRINT THE NUMBER.
2697 |            JSR OUTSPC       ; PRINT A SPACE
2698 |            BNEA NEWCHR      ; ALWAYS GOES.
     .ENDIF
2699 .IF REALIO != 4
2700 |.IF BUFPAG
2701 ||   FININL: LDA #0
2702 ||           STA BUF,X
2703 ||           LDXYI [BUF-1]
     |.ENDIF
2704 |.IF !BUFPAG
2705 ||   FININL: LDY #0           ; PUT A ZERO AT END OF BUF.
2706 ||           STY BUF,X
2707 ||           LDX #BUF-1       ; SETUP POINTER.
     |.ENDIF
2708 |.IF EXTIO
2709 ||           LDA CHANNL       ; NO CRDO IF NOT TERMINAL.
2710 ||           BNE PRTRTS
     |.ENDIF
2711 |    CRDO:
2712 |.IF !EXTIO
2713 ||           LDA #13          ; MAKE TRMPOS LESS THAN LINE LENGTH.
2714 ||           STA TRMPOS
     |.ENDIF
     .ENDIF
     .IF !APPLE2                   ; **** Code taken out in Applesoft ***
2715 |.IF EXTIO
2716 ||.IF (REALIO != 3) || PET
2717 |||          LDA CHANNL
2718 |||          BNE GOCR
2719 |||          STA TRMPOS
     ||.ENDIF
2720 ||    GOCR:  LDA #13          ; X AND Y MUST BE PRESERVED.
     |.ENDIF
2721 |            JSR OUTDO
2722 |            LDA #10
2723 |            JSR OUTDO
2724 |     CRFIN:
2725 |.IF EXTIO
2726 ||.IF (REALIO != 3) || PET
2727 |||          LDA CHANNL
2728 |||          BNE PRTRTS
     ||.ENDIF
     |.ENDIF
2729 |.IF !NULCMD
2730 ||.IF REALIO != 3
2731 |||          LDA #0
2732 |||          STA TRMPOS
     ||.ENDIF
     |.ENDIF
     |.IF !(OSI+KIM+PET)
2733 ||           EOR #255
     |.ENDIF
2734 |.IF NULCMD || PET
2735 ||           TXA              ; PRESERVE [ACCX]. SOME NEED IT.
2736 ||           PHA
2737 ||           LDX NULCNT       ; GET NUMBER OF NULLS.
2738 ||           BEQ CLRPOS
2739 ||           LDA #0
2740 ||   PRTNUL: JSR OUTDO
2741 ||           DEX              ; DONE WITH NULLS?
2742 ||           BNE PRTNUL
2743 ||   CLRPOS: STX TRMPOS
2744 ||           PLA
2745 ||           TAX
     |.ENDIF
2746 |    PRTRTS: RTS
2748 |    COMPRT: LDA TRMPOS
2749 |    NCMPOS: SET [[[LINLEN/CLMWID]-1]*CLMWID] ; CLMWID BEYOND WHICH THERE
2751 |                                             ; ARE NO MORE COMMA FIELDS.
2750 |.IF REALIO != 3
2752 ||           CMP NCMWID       ; SO ALL COMMA DOES IS "CRDO".
2754 ||           BCC MORCOM
2755 ||           JSR CRDO         ; TYPE CRLF.
2756 ||           JMP NOTABR       ; AND QUIT IF BEYOND LAST FIELD.
     |.ENDIF
2757 |    MORCOM: SEC
2758 |    MORCO1: SBC #CLMWID      ; GET [A] MODULUS CLMWID.
2759 |            BCS MORCO1
2760 |            EOR #255         ; FILL PRINT POS OUT TO EVEN CLMWID SO
2761 |            ADC #1
2762 |            BNE ASPAC        ; PRINT [A] SPACES.
     .ENDIF  ; !APPLE2
     .IF APPLE2                    ; *** lots of code added in AppleSoft ***
     |
     |      CRDO: LDA #$0D         ; Get a Carriage Return (Ctrl-M) Character
     |            JSR OUTDO
     |     CRFIN:
     |    NEGATE: EOR #$FF
     |    PRTRTS: RTS              ; Return to Caller
     |    COMPRT: LDA CH           ; Get Cursor's Horizontal Displacement
     |            CMP #24          ; *BUG* (40-16)=24 to keep cursor on screen
     |                             ; ===== should be 32, not 24
     |            BCC PRCMMA       ; Print NxtChr at Next Tab Column, Same Line
     |            JSR CRDO         ; Print a Carriage <Return> Character
     |            BNE NOTABR       ; Print NxtChr at Start of Next Line; Always
     |                             ; Advance Cursor to Next Comma Column:
     |    PRCMMA: ADC #16          ; Advance 16 Columns, Same Line
     |            AND #$F0         ; Truncate to Column 16 or 32, Same Line
     |            STA CH           ; Set Cursor's New Horizontal Displacement
     |            BCC NOTABR       ; Print NxtChr at Column 16|32, Always Taken
     |  PRTABSPC:
     .ENDIF
     .IF OSI+PET
     |    TABER:  PHA              ; REMEMBER IF SPC OR TAB FUNCTION.
     .ELSE
2764 |    TABER:  PHP              ; REMEMBER IF SPC OR TAB FUNCTION.
     .ENDIF
2765              JSR GTBYTC       ; GET VALUE INTO ACCX.
2766              CMP #41
     .IF APPLE2+KIM
     |            BEQ PRTAB        ; If == Go Print: TAB(X) or SPC(X)?
     |            JMP SNERR        ; Else, Throw a "?Syntax" Error
     .ELSE
2767 |            BNE SNERR4
     .ENDIF

     .IF !(OSI+PET)
2768 |    PRTAB:  PLP
2769 |            BCC XSPAC        ; PRINT [X] SPACES.
     .ELSE
     |    PRTAB:  PLA
     |            CMP #TABTK
     |            BNE ASPACL
     .ENDIF
     .IF APPLE2
     |            DEX
2770 |            TXA
2771 |            SBC CH
     .ELSE
2770 |            TXA
2771 |            SBC TRMPOS
     .ENDIF
2772              BCC NOTABR       ; NEGATIVE, DON'T PRINT ANY.
     .IF OSI+PET
     |            BEQ NOTABR
     .ENDIF
2773      ASPAC:  TAX
     .IF OSI+PET
     |   ASPACL:  JSR OUTSPC
     |            DEX
     |            BNE ASPACL
     .ELSE
2774 |    XSPAC:  INX
2775 |    XSPAC2: DEX              ; DECREMENT THE COUNT.
2776 |            BNE XSPAC1
     .ENDIF
2777      NOTABR: JSR CHRGET       ; REGET LAST CHARACTER.
2778              JMP PRINTC       ; DON'T CALL CRDO.
     .IF !(OSI+PET)
2779 |    XSPAC1: JSR OUTSPC
2780 |            BNEA XSPAC2
     .ENDIF
2781 ;
2782 ; PRINT THE STRING POINTED TO BY [Y,A] WHICH ENDS WITH A ZERO.
2783 ; IF THE STRING IS BELOW DSCTMP IT WILL BE COPIED INTO STRING SPACE.
2784 ;
2785      STROUT: JSR STRLIT       ; GET A STRING LITERAL.
2786 ;
2787 ; PRINT THE STRING WHOSE DESCRIPTOR IS POINTED TO BY FACMO.
2788 ;
2789      STRPRT: JSR FREFAC       ; RETURN TEMP POINTER.
2790              TAX              ; PUT COUNT INTO COUNTER.
2791              LDY #0
2792              INX              ; MOVE ONE AHEAD.
2793      STRPR2: DEX
2794              BEQ PRTRTS       ; ALL DONE.
2795              LDA (INDEX),Y    ; PNTR TO ACT STRNG SET BY FREFAC.
2796              JSR OUTDO
2797              INY
2798              CMP #13
2799              BNE STRPR2
          ; CRFIN:  .EQU NEGATE
2800              JSR CRFIN        ; TYPE REST OF CARRIAGE RETURN.
2801              JMP STRPR2       ; AND ON AND ON.
2802 ;
2803 ; OUTDO OUTPUTS THE CHARACTER IN ACCA, USING CNTWFL
2804 ; (SUPPRESS OR NOT), TRMPOS (PRINT HEAD POSITION),
2805 ; TIMING, ETCQ. NO REGISTERS ARE CHANGED.
2806 ;
2807      OUTSPC:
2808 .IF REALIO != 3
2809 |            LDA #$20
     .ENDIF
2810 .IF (REALIO == 3)
     |.IF !PET
2811 ||           LDA CHANNL
2812 ||           BEQ CRTSKP
2813 ||           LDA #$20
2814 ||           SKIP2
     |.ENDIF
2815 |    CRTSKP: LDA #29          ; COMMODORE'S SKIP CHARACTER.
     .ENDIF
2816              SKIP2
2817      OUTSET: LDA #'?
2818      OUTDO:
     .IF REALIO && !APPLE2
2819 |            BIT CNTWFL       ; SHOULDN'T AFFECT CHANNEL I/O!
2820 |            BMI OUTRTS
2821 |.IF (REALIO != 3)
2822 ||           PHA
2823 ||           CMP #32          ; IS THIS A PRINTING CHAR?
2824 ||           BCC TRYOUT       ; NO, DON'T INCLUDE IT IN TRMPOS.
2825 ||           LDA TRMPOS
2826 ||           CMP LINWID       ; LENGTH = TERMINAL WIDTH?
2827 ||           BNE OUTDO1
2828 ||           JSR CRDO         ; YES, TYPE CRLF
2829 ||    OUTDO1:
2830 ||.IF EXTIO
2831 |||          LDA CHANNL
2832 |||          BNE TRYOUT
     ||.ENDIF
2833 ||   INCTRM: INC TRMPOS       ; INCREMENT COUNT.
2834 ||   TRYOUT: PLA              ; RESTORE THE A REGISTER
     |.ENDIF
     .ENDIF
     .IF PET
     |    PET00:  PHA
     |            CMP #$1D
     |            BEQ PET03
     |            CMP #$9D
     |            BEQ PET01
     |            CMP #$14
     |            BNE PET02
     |    PET01:  LDA TRMPOS
     |            BEQ PET04
     |            LDA CHANNL
     |            BNE PET04
     |            DEC TRMPOS
     |    PET02:  AND #$7F
     |            CMP #$20
     |            BCC PET04
     |    PET03:  LDA CHANNL
     |            JSR PATCH6
     |            NOP
     |    PET04:  PLA
     |            JSR OUTCH
     .ENDIF
2836 .IF REALIO == 1
2837 |            STY KIMY         ; PRESERVE Y.
     .ENDIF
2838 .IF REALIO == 4               ; TURN ON B7 FOR APPLE.
     |            ORA #$80
     .ENDIF
2839 .IF REALIO && !(APPLE2+PET+OSI)
2840 |    OUTLOC: JSR OUTCH        ; OUTPUT THE CHARACTER.
     .ENDIF
2841 .IF REALIO == 1
2842 |            LDY KIMY         ; GET Y BACK.
     .ENDIF
2843 .IF REALIO == 2
     |.IF OSI
     ||           JSR OUTVEC
     |.ENDIF
     |            .REPEAT 4
     |             NOP
     |            .REPEND
     .ENDIF
     .IF !APPLE2
2844 |.IF (REALIO == 4)            ; GET [A] BACK FROM APPLE.
     ||            AND #$7F
     |.ENDIF
     .ENDIF
2846 .IF REALIO == 0
2847 |            TJSR OUTSIM##    ; CALL SIMULATOR OUTPUT ROUTINE
     .ENDIF
     .IF APPLE2
     |            CMP #$20|$80     ; Is it a Control or Visible Character ?
     |            BCC ISCTRL       ; Branch if it is a Control Character
     |            ORA FLASHBIT     ; Show (Flash=$40, Lowercase=$20, Else=$00)
     |    ISCTRL: JSR COUT         ; Print A-Reg (via Output Device)
     |            AND #$7F         ; Clear High Bit; Make Character Low ASCII
     |            PHA              ; Push/Save/Protect Character, temporarily
     |            LDA SPDBYT       ; Get Output Speed Limit
     |            JSR MON_WAIT     ; Limit Output Speed
     |            PLA              ; Pull/Retieve Saved/Protected Character
     |            RTS              ; Return to Caller
     |    TRMNOK: LDA INPFLG
     |            BEQ RESPERR      ; is this = TRMNO1 ??? FIXME
     .ELSE
2848 |    OUTRTS: AND #255         ; SET Z=0.
2849 |    GETRTS: RTS
     .ENDIF

2851 ; PAGE
2852 ; SUBTTL     INPUT AND READ CODE.

2853 ;
2854 ; HERE WHEN THE DATA THAT WAS TYPED IN OR IN "DATA" STATEMENTS
2855 ; IS IMPROPERLY FORMATTED. FOR "INPUT" WE START AGAIN.
2856 ; FOR "READ" WE GIVE A SYNTAX ERROR AT THE DATA LINE.
2857 ;
     .IF !APPLE2
2858 |    TRMNOK: LDA INPFLG
2859 |            BEQ TRMNO1       ; IF INPUT TRY AGAIN.
     .ENDIF
2860 .IF GETCMD && !PET
2861 |            BMI GETDTL
2862 |            LDY #255         ; MAKE IT LOOK DIRECT.
2863 |            BNEA STCURL      ; ALWAYS GOES.
2864 |   GETDTL:
     .ENDIF
     .IF PET
     |            JSR PATCH5
     |            NOP
     .ELSE
2865 |            LDWD DATLIN      ; GET DATA LINE NUMBER.
     .ENDIF
2866      STCURL: STWD CURLIN      ; MAKE IT CURRENT LINE.
2867      SNERR4: JMP SNERR
2868      TRMNO1:
2869 .IF EXTIO
2870 |           LDA CHANNL        ; IF NOT TERMINAL, GIVE BAD DATA.
2871 |           BEQ DOAGIN
2872 |           LDX #ERRBD
2873 |           JMP ERROR
     .ENDIF
     .IF APPLE2
     |    INPERR: PLA              ; Pull/Retrieve Last Character Got
     |   RESPERR: BIT ERRFLG       ; Is ON ERR turned on ?
     |            BPL DOAGIN       ; NO, Give Reentry a try
     |            LDX #BADRESP     ; 'Bad Response to Input' Error Code
     |            JMP ERRHND       ; Go to Error Handler (Part 2)
     .ENDIF
2874      DOAGIN: LDWDI TRYAGN     ; aka DOREENTRY
2875              JSR STROUT       ; PRINT "?REDO FROM START".
2876              LDWD OLDTXT      ; POINT AT START
2877              STWD TXTPTR      ; OF THIS CURRENT LINE.
2878              RTS              ; GO TO "NEWSTT".
2879 .IF GETCMD
2880 |    GET:    JSR ERRDIR       ; DIRECT IS NOT OK.
2881 |.IF EXTIO
2882 ||           CMP #'#          ; SEE IF "GET#".
2883 ||           BNE GETTTY       ; NO, JUST GET TTY INPUT.
2884 ||           JSR CHRGET       ; MOVE UP TO NEXT BYTE.
2885 ||           JSR GETBYT       ; GET CHANNEL INTO X
2886 ||           SYNCHK 44        ; COMMA?
2887 ||           JSR CQOIN        ; GET CHANNEL OPEN FOR INPUT.
2888 ||           STX CHANNL
     |.ENDIF
2889 |    GETTTY: LDXYI [BUF+1]    ; POINT TO 0.
2890 |.IF BUFPAG
2891 ||           LDA #0           ; TO STUFF AND TO POINT.
2892 ||           STA BUF+1
     |.ENDIF
2893 |.IF !BUFPAG
2894 ||           STY BUF+1        ; ZERO IT.
     |.ENDIF
2895 |            LDA #64          ; TURN ON V-BIT.
2896 |            JSR INPCO1       ; DO THE GET.
2897 |.IF EXTIO
2898 ||           LDX CHANNL
2899 ||           BNE IORELE       ; RELEASE.
     |.ENDIF
2900 |            RTS
     .ENDIF
2902 .IF EXTIO
2903 |    INPUTN: JSR GETBYT       ; GET CHANNEL NUMBER.
2904 |            SYNCHK 44        ; A COMMA?
2905 |            JSR CQOIN        ; GO WHERE COMMODORE CHECKS IN OPEN.
2906 |            STX CHANNL
2907 |            JSR NOTQTI       ; DO INPUT TO VARIABLES.
2908 |    IODONE: LDA CHANNL       ; RELEASE CHANNEL.
2909 |    IORELE: JSR CQCCHN
2910 |            LDX #0           ; RESET CHANNEL TO TERMINAL.
2911 |            STX CHANNL
2912 |            RTS
     .ENDIF
2913      INPUT:
     .IF REALIO && !APPLE2
2914 |            LSR CNTWFL       ; BE TALKATIVE.
     .ENDIF
2915              CMP #34          ; A QUOTE?
     .IF APPLE2
     |            BNE QOUT
     .ELSE
2916 |            BNE NOTQTI       ; NO MESSAGE.
     .ENDIF
2917              JSR STRTXT       ; LITERALIZE THE STRING IN TEXT
2918              SYNCHK 59        ; MUST END WITH SEMICOLON.
2919              JSR STRPRT       ; PRINT IT OUT.
     .IF APPLE2
     |            JMP NOTQTI
     |      QOUT: JSR OUTSET
     .ENDIF
2920      NOTQTI: JSR ERRDIR       ; USE COMMON ROUTINE SINCE DEF DIRECT
2921              LDA #44          ; GET COMMA.
2922              STA BUF-1
2923                               ; IS ALSO ILLEGAL.
     .IF APPLE2
2924 |    GETAGN: JSR INLIN        ; TYPE "?" AND INPUT A LINE OF TEXT.
     .ELSE                         ; FIXME: is APPLE2 INLIN = QINLIN ?
2924 |    GETAGN: JSR QINLIN       ; TYPE "?" AND INPUT A LINE OF TEXT.
     .ENDIF
2925 .IF EXTIO
2926 |            LDA CHANNL
2927 |            BEQ BUFFUL
2928 |            LDA CQSTAT       ; GET STATUS BYTE.
2929 |            AND #2
2930 |            BEQ BUFFUL       ; A-OK.
2931 |            JSR IODONE       ; BAD. CLOSE CHANNEL.
2932 |            JMP DATA         ; SKIP REST OF INPUT.
2933 |    BUFFUL:
     .ENDIF
2934              LDA BUF          ; ANYTHING INPUT?
     .IF !(OSI+KIM+PET)
     |  CMP #$03
     .ENDIF
2935              BNE INPCON       ; YES, CONTINUE.
2936 .IF EXTIO
2937 |            LDA CHANNL       ; BLANK LINE MEANS GET ANOTHER.
2938 |            BNE GETAGN       ; IF NOT TERMINAL.
     .ENDIF
     .IF !(APPLE2+PET)
2939 |            CLC              ; MAKE SURE DONT PRINT BREAK
2940 |            JMP STPEND       ; NO, STOP.
     .ELSE
     |.IF PET
     ||           JMP PATCH1
     |.ELSE
     ||           JMP CKONERR
     |.ENDIF
     .ENDIF
2941      QINLIN:
2942 .IF EXTIO
2943 |            LDA CHANNL
2944 |            BNE GINLIN
     .ENDIF
2945              JSR OUTSET
     .IF !APPLE2
2946 |            JSR OUTSPC
     .ENDIF
2947      GINLIN: JMP INLIN
2948      READ:   LDXY DATPTR      ; GET LAST DATA LOCATION.
2949              .BYTE $A9        ; LDAI TYA TO MAKE IT NONZERO.
2950 .IF !BUFPAG
2951 |    INPCON:
     .ENDIF
2952              TYA
2953 .IF BUFPAG
2954 |            SKIP2
2955 |    INPCON: LDA #0           ; SET FLAG THAT THIS IS INPUT
     .ENDIF
2956      INPCO1: STA INPFLG       ; STORE THE FLAG.
2957 ;
2958 ; IN THE PROCESSING OF DATA AND READ STATEMENTS:
2959 ; ONE POINTER POINTS TO THE DATA (IE, THE NUMBERS BEING FETCHED)
2960 ; AND ANOTHER POINTS TO THE LIST OF VARIABLES.
2961 ;
2962 ; THE POINTER INTO THE DATA ALWAYS STARTS POINTING TO A
2963 ; TERMINATOR -- A , : OR END-OF-LINE.
2964 ;
2965 ; AT THIS POINT TXTPTR POINTS TO LIST OF VARIABLES AND
2966 ; [Y,X] POINTS TO DATA OR INPUT LINE.
2967 ;
2968              STXY INPPTR
2969      INLOOP: JSR PTRGET       ; READ VARIABLE LIST.
2970              STWD FORPNT      ; SAVE POINTER FOR "LET" STRING STUFFING.
2971                               ; RETURNS PNTR TOP VAR IN VARPNT.
2972              LDWD TXTPTR      ; SAVE TEXT PNTR.
     .IF !KIM
2973 |            STWD VARTXT
     .ELSE
     |            STWD LINNUM
     .ENDIF
2974              LDXY INPPTR
2975              STXY TXTPTR
2976              JSR CHRGOT       ; GET IT AND SET Z IF TERM.
2977              BNE DATBK1
2978              BIT INPFLG
2979 .IF GETCMD
2980 |            BVC QDATA
2981 |            JSR CZGETL       ; DON'T WANT INCHR. JUST ONE.
2982 |.IF REALIO == 4
2983 ||           AND #127
     |.ENDIF
2984 |            STA BUF          ; MAKE IT FIRST CHARACTER.
     |.IF !PET                     ; macro to load BUF-1 address into X, Y ...
2985 ||           LDXYI [BUF-1]    ; POINT JUST BEFORE IT.
     |.ELSE                        ; ... but PET does it in different order:
     ||           LDY #[BUF-1]/256
     ||           LDX #[BUF-1]&$FF
     |.ENDIF
2986 |.IF !(BUFPAG+KIM+PET)
2987 ||           BEQA DATBK
     |.ENDIF
2988 |.IF BUFPAG+KIM+PET
2989 ||           BNEA DATBK       ; GO PROCESS.
     |.ENDIF
     .ENDIF

2990      QDATA:  BMI DATLOP       ; SEARCH FOR ANOTHER DATA STATEMENT.
2991 .IF EXTIO
2992 |            LDA CHANNL
2993 |            BNE GETNTH
     .ENDIF
2994              JSR OUTSET
2995      GETNTH: JSR QINLIN       ; GET ANOTHER LINE.
2996      DATBK:  STXY TXTPTR      ; SET FOR "CHRGET".
2997      DATBK1: JSR CHRGET
2998              BIT VALTYP       ; GET VALUE TYPE.
2999              BPL NUMINS       ; INPUT A NUMBER IF NUMERIC.
3000 .IF GETCMD && !PET
3001 |            BIT INPFLG       ; GET?
3002 |            BVC STOUT        ; NO, GO SET QUOTE.
3003 |            INX
3004 |            STX TXTPTR
3005 |            LDA #0           ; ZERO TERMINATORS.
3006 |            STA CHARAC
3007 |            BEQA RESETC
     .ENDIF
     .IF PET
3001 |            BIT INPFLG       ; GET?
3002 |            BVC STOUT        ; NO, GO SET QUOTE.
     |            LDA #$00
     |            JSR PATCH4
     |            NOP
     .ENDIF
3008      STOUT:  STA CHARAC       ; ASSUME QUOTED STRING.
3009              CMP #34          ; TERMINATORS OK?
3010              BEQ NOWGET       ; YES.
3011              LDA #':          ; SET TERMINATORS TO ":" AND
3012              STA CHARAC
3013              LDA #44          ; COMMA.
3014      RESETC: CLC
3015      NOWGET: STA ENDCHR
3016              LDWD TXTPTR
3017              ADC #0           ; C IS SET PROPERLY ABOVE.
3018              BCC NOWGE1
3019              INY
3020      NOWGE1: JSR STRLT2       ; MAKE A STRING DESCRIPTOR FOR THE VALUE
3021                               ; AND COPY IF NECESSARY.
3022              JSR ST2TXT       ; SET TEXT POINTER.
3023              JSR INPCOM       ; DO ASSIGNMENT.
3024              JMP STRDN2
3025      NUMINS:
     .IF APPLE2
     |            PHA
     |            LDA BUF
     |            BEQ INPFIN
     |     DATIN: PLA
     .ENDIF
                  JSR FIN

3026 .IF !INTPRC
3027 |            JSR MOVVF
     .ENDIF
3028 .IF INTPRC
3029 |            LDA INTFLG       ; SET CODES ON FLAG.
3030 |            JSR QINTGR       ; GO DECIDE ON FLOAT.
     .ENDIF

3031      STRDN2: JSR CHRGOT       ; READ LAST CHARACTER.
3032              BEQ TRMOK        ; ":" OR EOL IS OK.
3033              CMP #44          ; A COMMA?
3034              JNE TRMNOK
3035      TRMOK:  LDWD TXTPTR
3036              STWD INPPTR      ; SAVE FOR MORE READS.
     .IF !KIM
3037 |            LDWD VARTXT
     .ELSE
3037 |            LDWD LINNUM
     .ENDIF
3038              STWD TXTPTR      ; POINT TO VARIABLE LIST.
3039              JSR CHRGOT       ; LOOK AT LAST VARIABLE LIST CHARACTER.
3040              BEQ VAREND       ; THAT'S THE END OF THE LIST.
3041              JSR CHKCOM       ; NOT END. CHECK FOR COMMA.
3042              JMP INLOOP
     .IF APPLE2                    ; READ/DATA input ?
     |  INPFIN:   LDA INPFLG
     |            BNE DATIN
     |            JMP INPERR
     .ENDIF
3043 ;
3044 ; SUBROUTINE TO FIND DATA
3045 ; THE SEARCH IS MADE BY USING THE EXECUTION CODE FOR DATA TO
3046 ; SKIP OVER STATEMENTS. THE START WORD OF EACH STATEMENT
3047 ; IS COMPARED WITH "DATATK". EACH NEW LINE NUMBER
3048 ; IS STORED IN "DATLIN" SO THAT IF AN ERROR OCCURS
3049 ; WHILE READING DATA THE ERROR MESSAGE CAN GIVE THE LINE
3050 ; NUMBER OF THE ILL-FORMATTED DATA.
3051 ;
3052      DATLOP: JSR DATAN        ; SKIP SOME TEXT.
3053              INY
3054              TAX              ; END OF LINE?
3055              BNE NOWLIN       ; SHO AIN'T.
3056              LDX #ERROD       ; YES = "NO DATA" ERROR.
3057              INY
3058              LDA (TXTPTR),Y
3059              BEQ ERRGO5
3060              INY
3061              LDA (TXTPTR),Y   ; GET HIGH BYTE OF LINE NUMBER.
3062              STA DATLIN
3063              INY
3064              LDA (TXTPTR),Y   ; GET LOW BYTE.
3065              INY
3066              STA DATLIN+1
3067      NOWLIN: LDA (TXTPTR),Y   ; HOW IS IT?
3068              TAX
3069              JSR ADDON        ; ADD [Y] TO [TXTPTR].
3070              CPX #DATATK      ; IS IT A "DATA" STATEMENT.
3071              BNE DATLOP       ; NOT QUITE RIGHT. KEEP LOOKING.
3072              JMP DATBK1       ; THIS IS THE ONE !
3073      VAREND: LDWD INPPTR      ; PUT AWAY A NEW DATA PNTR MAYBE.
3074              LDX INPFLG
     .IF OSI
     |            BEQ VARY0
     .ELSE
3075 |            BPL VARY0
     .ENDIF
3076              JMP RESFIN
3077      VARY0:  LDY #0
3078              LDA (INPPTR),Y   ; LAST DATA CHR COULD HAVE BEEN
3079                               ; COMMA OR COLON BUT SHOULD BE NULL.
3080              BEQ INPRTS       ; IT IS NULL.
3081 .IF EXTIO
3082 |            LDA CHANNL       ; IF NOT TERMINAL, NO TYPE.
3083 |            BNE INPRTS
     .ENDIF
3084              LDWDI EXIGNT
3085              JMP STROUT       ; TYPE "?EXTRA IGNORED"
3086      INPRTS: RTS              ; DO NEXT STATEMENT.
3087      EXIGNT: .DC "?EXTRA IGNORED"
     .IF APPLE2
     |            .BYTE $0D, 0
     |    TRYAGN: .DC "?REENTER"
     |            .BYTE $0D, 0
     .ELSE
3088 |            ACRLF
3089 |    .BYTE 0
3090 |    TRYAGN: .DC "?REDO FROM START"
3091 |            ACRLF
3092 |    .BYTE 0
     .ENDIF

3093 ; PAGE
3094 ; SUBTTL     THE NEXT CODE IS THE "NEXT CODE"

3095 ;
3096 ; A "FOR" ENTRY ON THE STACK HAS THE FOLLOWING FORMAT:
3097 ;
3098 ; LOW ADDRESS
3099 ;       TOKEN (FORTK) 1 BYTE
3100 ;       A POINTER TO THE LOOP VARIABLE 2 BYTES
3101 ;       THE STEP 4+ADDPRC BYTES
3102 ;       A BYTE REFLECTING THE SIGN OF THE INCREMENT 1 BYTE
3103 ;       THE UPPER VALUE (PACKED) 4+ADDPRC BYTES
3104 ;       THE LINE NUMBER OF THE "FOR" STATEMENT 2 BYTES
3105 ;       A TEXT POINTER INTO THE "FOR" STATEMENT 2 BYTES
3106 ; HIGH ADDRESS
3107 ;
3108 ; TOTAL 16+2*ADDPRC BYTES.
3109 ;
3110      NEXT:   BNE GETFOR
3111              LDY #0           ; WITHOUT ARG CALL "FNDFOR" WITH
3112              BEQA STXFOR      ; [FORPNT]=0.
3113      GETFOR: JSR PTRGET       ; GET A POINTER TO LOOP VARIABLE
3114      STXFOR: STWD FORPNT      ; INTO "FORPNT".
3115              JSR FNDFOR       ; FIND THE MATCHING ENTRY IF ANY.
3116              BEQ HAVFOR
3117              LDX #ERRNF       ; "NEXT WITHOUT FOR".
3118      ERRGO5: BEQ ERRGO4
3119      HAVFOR: TXS              ; SETUP STACK. CHOP FIRST.
     .IF APPLE2+OSI+KIM+PET
     |           .REPEAT 4
     |            INX
     |           .REPEND
     |            TXA
     |           .REPEAT 6-OSI
     |            INX
     |           .REPEND
     |            STX INDEX2
     .ELSE
3120 |            TXA
3121 |            CLC
3122 |            ADC #4           ; POINT TO INCREMENT
3123 |            PHA              ; SAVE THIS POINTER TO RESTORE TO [A]
3124 |            ADC #5+ADDPRC    ; POINT TO UPPER LIMIT
3125 |            STA INDEX2       ; SAVE AS INDEX
3126 |            PLA              ; RESTORE POINTER TO INCREMENT
     .ENDIF
3127              LDY #1           ; SET HI ADDR OF THING TO MOVE.
3128              JSR MOVFM        ; GET QUANTITY INTO THE FAC.
3129              TSX
3130              LDA 257+7+ADDPRC,X ; SET SIGN CORRECTLY. (FIXME, UGLY)
3131              STA FACSGN
3132              LDWD FORPNT
3133              JSR FADD         ; ADD INC TO LOOP VARIABLE.
3134              JSR MOVVF        ; PACK THE FAC INTO MEMORY.
3135              LDY #1
3136              JSR FCOMPN       ; COMPARE FAC WITH UPPER VALUE.
3137              TSX
3138              SEC
3139              SBC 257+7+ADDPRC,X ; SUBTRACT SIGN OF INC FROM SIGN OF
3140                               ; OF (CURRENT VALUE-FINAL VALUE).
3141              BEQ LOOPDN       ; IF SIGN (FINAL-CURRENT)-SIGN STEP=0
3142                               ; THEN LOOP IS DONE.
3143              LDA 2*ADDPRC+12+257,X
3144              STA CURLIN       ; STORE LINE NUMBER OF "FOR" STATEMENT.
3145              LDA 257+13+[2*ADDPRC],X
3146              STA CURLIN+1
3147              LDA 2*ADDPRC+15+257,X
3148              STA TXTPTR       ; STORE TEXT PNTR INTO "FOR" STATEMENT.
3149              LDA 2*ADDPRC+14+257,X
3150              STA TXTPTR+1
3151      NEWSGO: JMP NEWSTT       ; PROCESS NEXT STATEMENT.
3152      LOOPDN: TXA
3153              ADC #2*ADDPRC+15 ; ADDS 16 WITH CARRY.
3154              TAX
3155              TXS              ; NEW STACK PNTR.
3156              JSR CHRGOT
3157              CMP #44          ; COMMA AT END?
3158              BNE NEWSGO
3159              JSR CHRGET
3160              JSR GETFOR       ; DO NEXT BUT DON'T ALLOW BLANK VARIABLE
3161                               ; PNTR. [VARPNT] IS THE STK PNTR WHICH
3162                               ; NEVER MATCHES ANY POINTER.
3163                               ; JSR TO PUT ON DUMMY NEWSTT ADDR.
3164 ; SUBTTL      FORMULA EVALUATION CODE
3165 ;
3166 ; THESE ROUTINES CHECK FOR CERTAIN "VALTYP".
3167 ; [C] IS NOT PRESERVED.
3168 ;
3169      FRMNUM: JSR FRMEVL
3170      CHKNUM: CLC
3171              SKIP1
3172      CHKSTR: SEC              ; SET CARRY.
3173      CHKVAL: BIT VALTYP       ; WILL NOT F UP "VALTYP".
3174              BMI DOCSTR
3175              BCS CHKERR
3176      CHKOK:  RTS
3177      DOCSTR: BCS CHKOK
3178      CHKERR: LDX #ERRTM
3179      ERRGO4: JMP ERROR
3180 ;
3181 ; THE FORMULA EVALUATOR STARTS WITH
3182 ; [TXTPTR] POINTING TO THE FIRST CHARACTER OF THE FORMULA.
3183 ; AT THE END [TXTPTR] POINTS TO THE TERMINATOR.
3184 ; THE RESULT IS LEFT IN THE FAC.
3185 ; ON RETURN [A] DOES NOT REFLECT THE TERMINATOR.
3186 ;
3187 ; THE FORMULA EVALUATOR USES THE OPERATOR LIST (OPTAB)
3188 ; TO DETERMINE PRECEDENCE AND DISPATCH ADDRESSES FOR
3189 ; EACH OPERATOR.
3190 ; A TEMPORARY RESULT ON THE STACK HAS THE FOLLOWING FORMAT.
3191 ;       THE ADDRESS OF THE OPERATOR ROUTINE.
3192 ;       THE FLOATING POINT TEMPORARY RESULT.
3193 ;       THE PRECEDENCE OF THE OPERATOR.
3194 ;
3195      FRMEVL: LDX TXTPTR
3196              BNE FRMEV1
3197              DEC TXTPTR+1
3198      FRMEV1: DEC TXTPTR
3199              LDX #0           ; INITIAL DUMMY PRECEDENCE IS 0.
3200              SKIP1
3201      LPOPER: PHA              ; SAVE LOW PRECEDENCE. (MASK.)
3202              TXA
3203              PHA              ; SAVE HIGH PRECEDENCE.
3204              LDA #1
3205              JSR GETSTK       ; MAKE SURE THERE IS ROOM FOR
3206                               ; RECURSIVE CALLS.
3207              JSR EVAL         ; EVALUATE SOMETHING.
3208              CLR OPMASK       ; PREPARE TO BUILD MASK MAYBE.
3209      TSTOP:  JSR CHRGOT       ; REGET LAST CHARACTER.
3210      LOPREL: SEC              ; PREP TO SUBTRACT.
3211              SBC #GREATK      ; IS CURRENT CHARACTER A RELATION?
3212              BCC ENDREL       ; NO. RELATIONS ALL THROUGH.
3213              CMP #LESSTK-GREATK+1 ; REALLY RELATIONAL?
3214              BCS ENDREL       ; NO -- JUST BIG.
3215              CMP #1           ; RESET CARRY FOR ZERO ONLY.
3216              ROL              ; 0 TO 1, 1 TO 2, 2 TO 4.
3217              EOR #1
3218              EOR OPMASK       ; BRING IN THE OLD BITS.
3219              CMP OPMASK       ; MAKE SURE THE NEW MASK IS BIGGER.
3220              BCC SNERR5       ; SYNTAX ERROR. BECAUSE TWO OF THE SAME.
3221              STA OPMASK       ; SAVE MASK.
3222              JSR CHRGET
3223              JMP LOPREL       ; GET THE NEXT CANDIDATE.
3224      ENDREL: LDX OPMASK       ; WERE THERE ANY?
3225              BNE FINREL       ; YES, HANDLE AS SPECIAL OP.
3226              BCS QOP          ; NOT AN OPERATOR.
3227              ADC #GREATK-PLUSTK
3228              BCC QOP          ; NOT AN OPERATOR.
3229              ADC VALTYP       ; [C]=1.
3230              JEQ CAT          ; ONLY IF [A]=0 AND [VALTYP]=-1 (A STR).
3231              ADC #$FF         ; GET BACK ORIGINAL [A].
3232              STA INDEX1
3233              ASL              ; MULTIPLY BY 2.
3234              ADC INDEX1       ; BY THREE.
3235              TAY              ; SET UP FOR LATER.
3236      QPREC:  PLA              ; GET PREVIOUS PRECEDENCE.
3237              CMP OPTAB,Y      ; IS OLD PRECEDENCE GREATER OR EQUAL?
3238              BCS QCHNUM       ; YES, GO OPERATE.
3239              JSR CHKNUM       ; CAN'T BE STRING HERE.
3240      DOPREC: PHA              ; SAVE OLD PRECEDENCE.
3241      NEGPRC: JSR DOPRE1       ; SET A RETURN ADDRESS FOR OP.
3242              PLA              ; PULL OFF PREVIOUS PRECEDENCE.
3243              LDY OPPTR        ; GET POINTER TO OP.
3244              BPL QPREC1       ; THAT'S A REAL OPERATOR.
3245              TAX              ; DONE ?
3246              BEQ QOPGO        ; DONE !
3247              BNE PULSTK
3248      FINREL: LSR VALTYP       ; GET VALUE TYPE INTO "C".
3249              TXA
3250              ROL              ; PUT VALTYP INTO LOW ORDER BIT OF MASK.
3251              LDX TXTPTR       ; DECREMENT TEXT POINTER.
3252              BNE FINRE2
3253              DEC TXTPTR+1
3254      FINRE2: DEC TXTPTR
3255              LDY #PTDORL-OPTAB ; MAKE [YREG] POINT AT OPERATOR ENTRY.
3256              STA OPMASK       ; SAVE THE OPERATION MASK.
3257              BNE QPREC        ; SAVE IT ALL. BR ALWAYS.
3258                               ; NOTE B7(VALTYP)=0 SO CHKNUM CALL IS OK.
3259      QPREC1: CMP OPTAB,Y      ; LAST PRECEDENCE IS GREATER?
3260              BCS PULSTK       ; YES, GO OPERATE.
3261              BCC DOPREC       ; NO SAVE ARGUMENT AND GET OTHER OPERAND.
3262      DOPRE1: LDA OPTAB+2,Y
3263              PHA              ; DISP ADDR GOES ONTO STACK.
3264              LDA OPTAB+1,Y
3265              PHA
3266              JSR PUSHF1       ; SAVE FAC ON STACK UNPACKED.
3267              LDA OPMASK       ; [ACCA] MAY BE MASK FOR REL.
3268              JMP LPOPER
3269      SNERR5: JMP SNERR        ; GO TO AN ERROR.
3270      PUSHF1: LDA FACSGN
3271              LDX OPTAB,Y      ; GET HIGH PRECEDENCE.
3272      PUSHF:  TAY              ; GET POINTER INTO STACK.
3273              PLA
3274              STA INDEX1
3275              INC INDEX1
3276              PLA
3277              STA INDEX1+1
3278              TYA
3279                               ; STORE FAC ON STACK UNPACKED.
3280              PHA              ; START WITH SIGN SET UP.
3281      FORPSH: JSR ROUND        ; PUT ROUNDED FAC ON STACK.
3282              LDA FACLO        ; ENTRY POINT TO SKIP STORING SIGN.
3283              PHA
3284              LDA FACMO
3285              PHA
3286 .IF ADDPRC
3287 |            LDA FACMOH
3288 |            PHA
     .ENDIF
3289              LDA FACHO
3290              PHA
3291              LDA FACEXP
3292              PHA
3293              JMP (INDEX1)     ; RETURN.
3294      QOP:    LDY #255
3295              PLA              ; GET HIGH PRECEDENCE OF LAST OP.
3296      QOPGO:  BEQ QOPRTS       ; DONE !
3297      QCHNUM: CMP #100         ; RELATIONAL OPERATOR?
3298              BEQ UNPSTK       ; YES, DON'T CHECK OPERAND.
3299              JSR CHKNUM       ; MUST BE NUMBER.
3300      UNPSTK: STY OPPTR        ; SAVE OPERATOR'S POINTER FOR NEXT TIME.
3301      PULSTK: PLA              ; GET MASK FOR REL OP IF IT IS ONE.
3302              LSR              ; SETUP [C] FOR DOREL'S "CHKVAL".
3303              STA DOMASK       ; SAVE FOR "DOCMP".
3304              PLA              ; UNPACK STACK INTO ARG.
3305              STA ARGEXP
3306              PLA
3307              STA ARGHO
3308 .IF ADDPRC
3309 |            PLA
3310 |            STA ARGMOH
     .ENDIF
3311              PLA
3312              STA ARGMO
3313              PLA
3314              STA ARGLO
3315              PLA
3316              STA ARGSGN
3317              EOR FACSGN       ; GET PROBABLE RESULT SIGN.
3318              STA ARISGN       ; ARITHMETIC SIGN. USED BY
3319                               ; ADD, SUB, MULT, DIV.
3320      QOPRTS: LDA FACEXP       ; GET IT AND SET CODES.
3321      UNPRTS: RTS              ; RETURN.
3323      EVAL:   CLR VALTYP       ; ASSUME VALUE WILL BE NUMERIC.
3324      EVAL0:  JSR CHRGET       ; GET A CHARACTER.
3325              BCS EVAL2
3326      EVAL1:  JMP FIN          ; IT IS A NUMBER.
3327      EVAL2:  JSR ISLETC       ; VARIABLE NAME?
3328              BCS ISVAR        ; YES.
3329 .IF REALIO == 3
3330 |            CMP #PI
3331 |            BNE QDOT
3332 |            LDWDI PIVAL
3333 |            JSR MOVFM        ; PUT VALUE IN FOR PI.
3334 |            JMP CHRGET
3335 |    PIVAL:  .BYTE $82, $49, $0F, $DA, $A1
     .ENDIF
3340      QDOT:   CMP #'.          ; LEADING CHARACTER OF CONSTANT?
3341              BEQ EVAL1
3342              CMP #MINUTK      ; NEGATION?
3343              BEQ DOMIN        ; SHO IS.
3344              CMP #PLUSTK
3345              BEQ EVAL0
3346              CMP #34          ; A QUOTE? A STRING?
3347              BNE EVAL3
3348      STRTXT: LDWD TXTPTR
3349              ADC #0           ; TO INC, ADD C=1.
3350              BCC STRTX2
3351              INY
3352      STRTX2: JSR STRLIT       ; YES. GO PROCESS IT.
3353              JMP ST2TXT
3354      EVAL3:  CMP #NOTTK       ; CHECK FOR "NOT" OPERATOR.
3355              BNE EVAL4
3356              LDY #NOTTAB-OPTAB; "NOT" HAS PRECEDENCE 90.
3357              BNE GONPRC       ; GO DO ITS EVALUATION.
     .IF APPLE2
     |     NOTOP: LDA FAC          ; Get FAC Exponent
     |            BNE NOTOP1       ; If FACX<>0, Set as FALSE
     |            LDY #$01         ; Else, FACX=0: Set as TRUE
     |            SKIP2
     |    NOTOP1: LDY #$00         ; FACX<>0: Set as FALSE
     |            JMP SNGFLT       ; Float Unsign Int & Flag as a Number
     .ELSE
3358 |    NOTOP:  JSR AYINT        ; INTEGERIZE.
3359 |            LDA FACLO        ; GET THE ARGUMENT.
3360 |            EOR #255
3361 |            TAY
3362 |            LDA FACMO
3363 |            EOR #255
3364 |            JMP GIVAYF       ; FLOAT [Y,A] AS RESULT IN FAC.
3365 |                             ; AND RETURN.
     .ENDIF
3366      EVAL4:  CMP #FNTK        ; USER-DEFINED FUNCTION?
3367              JEQ FNDOER
3368              CMP #ONEFUN      ; A FUNCTION NAME?
3369              BCC PARCHK       ; FUNCTIONS ARE THE HIGHEST NUMBERED
3370              JMP ISFUN        ; CHARACTERS SO NO NEED TO CHECK
3371                               ; AN UPPER-BOUND.
3372      PARCHK: JSR CHKOPN       ; ONLY POSSIBILITY LEFT IS
3373              JSR FRMEVL       ; A FORMULA IN PARENTHESIS.
3374                               ; RECURSIVELY EVALUATE THE FORMULA.
3375      CHKCLS: LDA #41          ; CHECK FOR A RIGHT PARENTHESE
3376              SKIP2
3377      CHKOPN: LDA #40
3378              SKIP2
3379      CHKCOM: LDA #44
3380 ;
3381 ; "SYNCHK" LOOKS AT THE CURRENT CHARACTER TO MAKE SURE IT
3382 ; IS THE SPECIFIC THING LOADED INTO ACCA JUST BEFORE THE CALL TO
3383 ; "SYNCHK". IF NOT, IT CALLS THE "SYNTAX ERROR" ROUTINE.
3384 ; OTHERWISE IT GOBBLES THE NEXT CHAR AND RETURNS,
3385 ;
3386 ; [A]=NEW CHAR AND TXTPTR IS ADVANCED BY "CHRGET".
3387 ;
3388      SYNCHR: LDY #0
3389              CMP (TXTPTR),Y   ; CHARACTERS EQUAL?
3390              BNE SNERR
3391      CHRGO5: JMP CHRGET
3392      SNERR:  LDX #ERRSN       ; "SYNTAX ERROR"
3393              JMP ERROR
3394      DOMIN:  LDY #NEGTAB-OPTAB; A PRECEDENCE BELOW "^".
3395      GONPRC: PLA              ; GET RID OF RTS ADDR.
3396              PLA
3397              JMP NEGPRC       ; EVALUTE FOR NEGATION.
3399      ISVAR:  JSR PTRGET       ; GET A PNTR TO VARIABLE.
3400      ISVRET: STWD FACMO
3401 .IF TIME || EXTIO
3402 |            LDWD VARNAM      ; CHECK TIME,TIME$,STATUS.
     .ENDIF
3403              LDX VALTYP
3404              BEQ GOOO         ; THE STRING IS SET UP.
     .IF !(OSI+KIM+PET)
3405 |            LDX #0
3406 |            STX FACOV
     .ENDIF
3407 .IF TIME
     |.IF !PET
3408 ||           BIT FACLO        ; AN ARRAY?
3409 ||           BPL STRRTS       ; YES.
3410 ||           CMP #'T          ; TI$?
3411 ||           BNE STRRTS
     |.ELSE                        ; PET
     ||           JMP PATCH2       ; jumps back to PATCO2 below
     ||           CLC
     |.ENDIF
3412 |   PATCO2:  CPY #'I +128
3413 |            BNE STRRTS
3414 |            JSR GETTIM       ; YES. PUT TIME IN FACMOH-LO.
3415 |            STY TENEXP       ; Y=0.
3416 |            DEY
3417 |            STY FBUFPT
3418 |            LDY #6           ; SIX DIGITS TO PRINT.
3419 |            STY DECCNT
3420 |            LDY #FDCEND-FOUTBL
3421 |            JSR FOUTIM       ; CONVERT TO ASCII.
3422 |            JMP TIMSTR
     .ENDIF
3423      STRRTS: RTS
3424      GOOO:
3425 .IF INTPRC
3426 |            LDX INTFLG
3427 |            BPL GOOOOO
3428 |            LDY #0
3429 |            LDA (FACMO),Y    ; FETCH HIGH.
3430 |            TAX
3431 |            INY
3432 |            LDA (FACMO),Y
3433 |            TAY              ; PUT LOW IN Y.
3434 |            TXA              ; GET HIGH IN A.
3435 |            JMP GIVAYF       ; FLOAT AND RETURN.
     .ENDIF
3436      GOOOOO:
3437 .IF TIME
     |.IF !PET
3438 ||           BIT FACLO        ; AN ARRAY?
3439 ||           BPL GOMOVF       ; YES.
3440 ||           CMP #'T
3441 ||           BNE QSETATV
3442 ||           CPY #'I
3443 ||           BNE GOMOVF
     |.ELSE
     ||           JMP PATCH3
     ||           .BYTE $19        ; leftover from before inserting JMP PATCH3
     ||   PATCO3: CPY #'I          ; continuation from PATCH3
     ||           BNE QSETATV
     |.ENDIF
3444 |            JSR GETTIM
3445 |            TYA              ; FOR FLOATB.
3446 |            LDX #160         ; SET EXPONNENT.
3447 |            JMP FLOATB
3448 |    GETTIM: LDWDI [CQTIMR-2]
3449 |            SEI              ; TURN OF INT SYS.
3450 |            JSR MOVFM
3451 |            CLI              ; BACK ON.
3452 |            STY FACHO        ; ZERO HIGHEST.
3453 |            RTS
     .ENDIF
3454      QSETATV:
3455 .IF EXTIO
3456 |            CMP #'S
3457 |            BNE GOMOVF
3458 |            CPY #'T
3459 |            BNE GOMOVF
3460 |            LDA CQSTAT
3461 |            JMP FLOAT
3462 |    GOMOVF:
     .ENDIF
3463 .IF TIME || EXTIO
3464 |            LDWD FACMO
     .ENDIF
3465              JMP MOVFM        ; MOVE ACTUAL VALUE IN.
3466                               ; AND RETURN.
     .IF APPLE2
     |    SCREEN: JSR CHRGET       ; Get Next Char/Token
     |            JSR PLOTFNS      ; Get Column,Row Coordinates [(0-47),(0-47)]
     |            TXA              ; Get Row Coordinate    [Set (A)=(X)=(0-47)]
     |            LDY FIRST        ; Get Column Coordinate     [Set (Y)=(0-47)]
     |            JSR SCRN         ; Get 4-bit Color at Column,Row Coordinates
     |            TAY              ; Set [(Y)=(A)]=[(%0000nnnn)=($0-$F)=(0-16)]
     |                             ; Convert (Y) to Real/FP Number in FAC:
     |            JSR SNGFLT       ; Float Unsigned Integer & Flag as a Number
     |            JMP CHKCLS       ; Require a Closing Parenthesis [")"]
     |     ISFUN: CMP #SCRNTK      ; check for SCRN( token
     |            BEQ SCREEN       ; do SCRN( function
     .ELSE
     |    ISFUN:
     .ENDIF
3468              ASL              ; MULTIPLY BY TWO.
3469              PHA
3470              TAX
3471              JSR CHRGET       ; SET UP FOR SYNCHK.
3472              CPX #2*LASNUM-256+1; IS IT PAST "LASNUM"?
3473              BCC OKNORM       ; NO, MUST BE NORMAL FUNCTION.
3474 ;
3475 ; MOST FUNCTIONS TAKE A SINGLE ARGUMENT.
3476 ; THE RETURN ADDRESS OF THESE FUNCTIONS IS "CHKNUM"
3477 ; WHICH ASCERTAINS THAT [VALTYP]=0  (NUMERIC).
3478 ; NORMAL FUNCTIONS THAT RETURN STRING RESULTS
3479 ; (E.G., CHR$) MUST POP OFF THAT RETURN ADDR AND
3480 ; RETURN DIRECTLY TO "FRMEVL".
3481 ;
3482 ; THE SO-CALLED "FUNNY" FUNCTIONS CAN TAKE MORE THAN ONE ARGUMENT,
3483 ; THE FIRST OF WHICH MUST BE STRING AND THE SECOND OF WHICH
3484 ; MUST BE A NUMBER BETWEEN 0 AND 255.
3485 ; THE CLOSED PARENTHESIS MUST BE CHECKED AND RETURN IS DIRECTLY
3486 ; TO "FRMEVL" WITH THE TEXT PNTR POINTING BEYOND THE ")".
3487 ; THE POINTER TO THE DESCRIPTOR OF THE STRING ARGUMENT
3488 ; IS STORED ON THE STACK UNDERNEATH THE VALUE OF THE
3489 ; INTEGER ARGUMENT.
3490 ;
3491              JSR CHKOPN       ; CHECK FOR AN OPEN PARENTHESE
3492              JSR FRMEVL       ; EAT OPEN PAREN AND FIRST ARG.
3493              JSR CHKCOM       ; TWO ARGS SO COMMA MUST DELIMIT.
3494              JSR CHKSTR       ; MAKE SURE FIRST WAS STRING.
3495              PLA              ; GET FUNCTION NUMBER.
3496              TAX
3497              PSHWD FACMO      ; SAVE POINTER AT STRING DESCRIPTOR
3498              TXA
3499              PHA              ; RESAVE FUNCTION NUMBER.
3500                               ; THIS MUST BE ON STACK SINCE RECURSIVE.
3501              JSR GETBYT       ; [X]=VALUE OF FORMULA.
3502              PLA              ; GET FUNCTION NUMBER.
3503              TAY
3504              TXA
3505              PHA
3506              JMP FINGO        ; DISPATCH TO FUNCTION.
3507      OKNORM: JSR PARCHK       ; READ A FORMULA SURROUNDED BY PARENS.
3508              PLA              ; GET DISPATCH FUNCTION.
3509              TAY
3510      FINGO:  LDA FUNDSP-2*ONEFUN+256,Y; MODIFY DISPATCH ADDRESS.
3511              STA JMPER+1
3512              LDA FUNDSP-2*ONEFUN+257,Y
3513              STA JMPER+2
3514              JSR JMPER        ; DISPATCH!
3515                               ; STRING FUNCTIONS REMOVE THIS RET ADDR.
3516              JMP CHKNUM       ; CHECK IT FOR NUMERICNESS AND RETURN.
     .IF !APPLE2        ; original Microsoft OR and AND functions taken out ...
3518 |      OR:   LDY #255         ; MUST ALWAYS COMPLEMENT..
3519 |            SKIP2
3520 |      AND:  LDY #0
3521 |            STY COUNT        ; OPERATOR.
3522 |            JSR AYINT        ; [FACMO&LO]=INT VALUE AND CHECK SIZE.
3523 |            LDA FACMO        ; USE DEMORGAN'S LAW ON HIGH
3524 |            EOR COUNT
3525 |            STA INTEGR
3526 |            LDA FACLO        ; AND LOW.
3527 |            EOR COUNT
3528 |            STA INTEGR+1
3529 |            JSR MOVFA
3530 |            JSR AYINT        ; [FACMO&LO]=INT OF ARG.
3531 |            LDA FACLO
3532 |            EOR COUNT
3533 |            AND INTEGR+1
3534 |            EOR COUNT        ; FINISH OUT DEMORGAN.
3535 |            TAY              ; SAVE HIGH.
3536 |            LDA FACMO
3537 |            EOR COUNT
3538 |            AND INTEGR
3539 |            EOR COUNT
3540 |            JMP GIVAYF       ; FLOAT [A.Y] AND RET TO USER.
     .ELSE                         ; ... and replaced by Apple's (?) functions:
     |                             ; Note: might be older Microsoft code ?
     |        OR: LDA ARGEXP       ; Get 2nd FAC Exponent (ARGX)
     |            ORA FAC          ; OR w/ 1st FAC Exponent (FACX)
     |            BNE TRUE         ; Branch if [(ARGX)|(FACX)]<>0
     |       AND: LDA ARGEXP       ; Get 2nd FAC Exponent (ARGX)
     |            BEQ FALSE        ; Branch if [(A)=(ARGX)]==0
     |            LDA FAC          ; Else, Get 1st FAC Exponent (FACX)
     |            BNE TRUE         ; Branch if [(A)=(FACX)]<>0
     |     FALSE: LDY #$00         ; Set to FALSE [(Y)=(0)]
     |            SKIP2
     |      TRUE: LDY #$01
     |            JMP SNGFLT
     .ENDIF
3542 ;
3543 ; TIME TO PERFORM A RELATIONAL OPERATOR.
3544 ; [DOMASK] CONTAINS THE BITS AS TO WHICH RELATIONAL
3545 ; OPERATOR IT WAS. CARRY BIT ON=STRING COMPARE.
3546 ;
3547      DOREL:  JSR CHKVAL       ; CHECK FOR MATCH.
3548              BCS STRCMP       ; IT IS A STRING.
3549              LDA ARGSGN       ; PACK ARG FOR FCOMP.
3550              ORA #127
3551              AND ARGHO
3552              STA ARGHO
3553              LDWDI ARGEXP
3554              JSR FCOMP
3555              TAX
3556              JMP QCOMP
3557      STRCMP: CLR VALTYP       ; RESULT WILL BE NUMERIC.
3558              DEC OPMASK       ; TURN OFF VALTYP WHICH WAS STRING.
3559              JSR FREFAC       ; FREE THE FACLO STRING.
3560              STA DSCTMP       ; SAVE FOR LATER.
3561              STXY DSCTMP+1
3562              LDWD ARGMO       ; GET POINTER TO OTHER STRING.
3563              JSR FRETMP       ; FREES FIRST DESC POINTER.
3564              STXY ARGMO
3565              TAX              ; COPY COUNT INTO X.
3566              SEC
3567              SBC DSCTMP       ; WHICH IS GREATER. IF 0, ALL SET UP.
3568              BEQ STASGN       ; JUST PUT SIGN OF DIFFERENCE AWAY.
3569              LDA #1
3570              BCC STASGN       ; SIGN IS POSITIVE.
3571              LDX DSCTMP       ; LENGTH OF FAC IS SHORTER.
3572              LDA #$FF         ; GET A MINUS 1 FOR NEGATIVES.
3573      STASGN: STA FACSGN       ; KEEP FOR LATER.
3574              LDY #255         ; SET POINTER TO FIRST STRING. (ARG.)
3575              INX              ; TO LOOP PROPERLY.
3576      NXTCMP: INY
3577              DEX              ; ANY CHARACTERS LEFT TO COMPARE?
3578              BNE GETCMP       ; NOT DONE YET.
3579              LDX FACSGN       ; USE SIGN OF LENGTH DIFFERENCE
3580                               ; SINCE ALL CHARACTERS ARE THE SAME.
3581      QCOMP:  BMI DOCMP        ; C IS ALWAYS SET THEN.
3582              CLC
3583              BCC DOCMP        ; ALWAYS BRANCH.
3584      GETCMP: LDA (ARGMO),Y    ; GET NEXT CHAR TO COMPARE.
3585              CMP (DSCTMP+1),Y ; SAME?
3586              BEQ NXTCMP       ; YEP. TRY FURTHER.
3587              LDX #$FF         ; SET A POSITIVE DIFFERENCE.
3588              BCS DOCMP        ; PUT STACK BACK TOGETHER.
3589              LDX #1           ; SET A NEGATIVE DIFFERENCE.
3590      DOCMP:  INX              ; -1 TO 1, 0 TO 2, 1 TO 4.
3591              TXA
3592              ROL
3593              AND DOMASK
3594              BEQ GOFLOT
     .IF !APPLE2
3595 |            LDA #$FF         ; MAP 0 TO 0. ALL OTHERS TO -1.
     .ELSE
     |            LDA #$01
     .ENDIF
3596      GOFLOT: JMP FLOAT        ; FLOAT THE ONE-BYTE RESULT INTO FAC.
     .IF APPLE2
     |       PDL: JSR CONINT       ; Convert FAC to Number in (X) & (FAC+4)
     |            JSR PREAD        ; Read Paddle (X) - Returns Time-Count in (Y)
     |            JMP SNGFLT       ; Conv (Y) to Real Number in FAC
     .ENDIF

3598 ; PAGE
3599 ; SUBTTL     DIMENSION AND VARIABLE SEARCHING.

3600 ;
3601 ; THE "DIM" CODE SETS [DIMFLG] AND THEN FALLS INTO THE VARIABLE SEARCH
3602 ; ROUTINE, WHICH LOOKS AT DIMFLG AT THREE DIFFERENT POINTS.
3603 ;       1) IF AN ENTRY IS FOUND, "DIMFLG" BEING ON INDICATES
3604 ;               A "DOUBLY" DIMENSIONED VARIABLE.
3605 ;       2) WHEN A NEW ENTRY IS BEING BUILT "DIMFLG" BEING ON
3606 ;               INDICTAES THE INDICES SHOULD BE USED FOR THE
3607 ;               SIZE OF EACH INDEX. OTHERWISE THE DEFAULT OF TEN
3608 ;               IS USED.
3609 ;       3) WHEN THE BUILD ENTRY CODE FINISHES, ONLY IF "DIMFLG" IS OFF
3610 ;               WILL INDEXING BE DONE.
3611 ;
3612      DIM3:   JSR CHKCOM       ; MUST BE A COMMA
3613      DIM:    TAX              ; SET [ACCX] NONZERO.
3614                               ; [ACCA] MUST BE NONZERO TO WORK RIGHT.
3615      DIM1:   JSR PTRGT1
3616      DIMCON: JSR CHRGOT       ; GET LAST CHARACTER.
3617              BNE DIM3
3618              RTS
3619 ;
3620 ; ROUTINE TO READ THE VARIABLE NAME AT THE CURRENT TEXT POSITION
3621 ; AND  PUT A POINTER TO ITS VALUE IN VARPNT. [TXTPTR]
3622 ; POINTS TO THE TERMINATING CHARCTER.. NOT THAT EVALUATING SUBSCRIPTS
3623 ; IN A VARIABLE NAME CAN CAUSE RECURSIVE CALLS TO "PTRGET" SO AT
3624 ; THAT POINT ALL VALUES MUST BE STORED ON THE STACK.
3625 ;
3626      PTRGET: LDX #0           ; MAKE [ACCX]=0.
3627              JSR CHRGOT       ; RETRIEVE LAST CHARACTER.
3628      PTRGT1: STX DIMFLG       ; STORE FLAG AWAY.
3629      PTRGT2: STA VARNAM
3630              JSR CHRGOT       ; GET CURRENT CHARACTER
3631                               ; MAYBE WITH FUNCTION BIT OFF.
3632              JSR ISLETC       ; CHECK FOR LETTER.
3633              BCS PTRGT3       ; MUST HAVE A LETTER.
3634      INTERR: JMP SNERR
3635      PTRGT3: LDX #0           ; ASSUME NO SECOND CHARACTER.
3636              STX VALTYP       ; DEFAULT IS NUMERIC.
3637 .IF INTPRC
3638 |            STX INTFLG       ; ASSUME FLOATING.
     .ENDIF
     .IF APPLE2
     |            JMP PTRGTX       ; jump over Applesoft entry points
     |     BASIC: JMP INIT         ; COLDSTART
     |    BASIC2: JMP READY        ; WARMSTART
     |            BRK
     .ENDIF
3639      PTRGTX: JSR CHRGET       ; GET FOLLOWING CHARACTER.
3640              BCC ISSEC        ; CARRY RESET BY CHRGET IF NUMERIC.
3641              JSR ISLETC       ; SET CARRY IF NOT ALPHABETIC.
3642              BCC NOSEC        ; ALLOW ALPHABETICS.
3643      ISSEC:  TAX              ; IT IS A NUMBER -- SAVE IN ACCX.
3644      EATEM:  JSR CHRGET       ; LOOK AT NEXT CHARACTER.
3645              BCC EATEM        ; SKIP NUMERICS.
3646              JSR ISLETC
3647              BCS EATEM        ; SKIP ALPHABETICS.
3648      NOSEC:  CMP #'$          ; IS IT A STRING?
3649              BNE NOTSTR       ; IF NOT, [VALTYP]=0.
3650              LDA #$FF         ; SET [VALTYP]=255 (STRING !).
3651              STA VALTYP
3652 .IF INTPRC
3653 |            BNEA TURNON      ; ALWAYS GOES.
3654 |    NOTSTR: CMP #'%          ; INTEGER VARIABLE?
3655 |            BNE STRNAM       ; NO.
3656 |            LDA SUBFLG
     |.IF APPLE2
     ||           BMI INTERR
     |.ELSE
3657 ||           BNE INTERR
     |.ENDIF
3658 |            LDA #128
3659 |            STA INTFLG       ; SET FLAG.
3660 |            ORA VARNAM       ; TURN ON BOTH HIGH BITS.
3661 |            STA VARNAM
     .ENDIF
3662      TURNON: TXA
3663              ORA #128         ; TURN ON MSB OF SECOND CHARACTER.
3664              TAX
3665              JSR CHRGET       ; GET CHARACTER AFTER $.

3666 .IF !INTPRC || OSI
3667 |    NOTSTR:
     .ENDIF
3668      STRNAM: STX VARNAM+1     ; STORE AWAY SECOND CHARACTER.
3669              SEC
3670              ORA SUBFLG       ; ADD FLAG WHETHER TO ALLOW ARRAYS.
3671              SBC #40          ; (CHECK FOR "(") WON'T MATCH IF SUBFLG SET.
     .IF !APPLE2
3672 |    PT2ARY: JEQ ISARY        ; IT IS!
     .ELSE
     |            BNE PTRTYP
     |    PT2ARY: JMP ISARY
     |    PTRTYP: BIT SUBFLG       ; Check Top 2 Bits (NV) of SUBFLG
     |            BMI PT2IVP       ; ($80): Branch if from FOR, DEF or FN
     |            BVS PT2ARY       ; ($40): Branch if called from GETARYPTR
     .ENDIF
3673      PT2IVP: CLR SUBFLG       ; ALLOW SUBSCRIPTS AGAIN.
3674              LDA VARTAB       ; PLACE TO START SEARCH.
3675              LDX VARTAB+1
3676              LDY #0
3677      STXFND: STX LOWTR+1
3678      LOPFND: STA LOWTR
3679              CPX ARYTAB+1     ; AT END OF TABLE YET?
3680              BNE LOPFN
3681              CMP ARYTAB
3682              BEQ NOTFNS       ; YES. WE COULDN'T FIND IT.
3683      LOPFN:  LDA VARNAM
3684              CMP (LOWTR),Y    ; COMPARE HIGH ORDERS.
3685              BNE NOTIT        ; NO COMPARISON.
3686              LDA VARNAM+1
3687              INY
3688              CMP (LOWTR),Y    ; AND THE LOW PART?
3689              BEQ FINPTR       ; THAT'S IT ! THAT'S IT !
3690              DEY
3691      NOTIT:  CLC
3692              LDA LOWTR
3693              ADC #6+ADDPRC    ; MAKES NO DIF AMONG TYPES.
3694              BCC LOPFND
3695              INX
3696              BNEA STXFND      ; ALWAYS BRANCHES.
3698 ;
3699 ; TEST FOR A LETTER.     / CARRY OFF= NOT A LETTER.
3700 ;                          CARRY ON= A LETTER.
3701 ;
3702      ISLETC: CMP #'A
3703              BCC ISLRTS       ; IF LESS THAN "A", RET.
3704              SBC #'Z +1
3705              SEC
3706              SBC #256-'Z -1   ; RESET CARRY IF [A] .GT. "Z".
3707      ISLRTS: RTS              ; RETURN TO CALLER.
3709      NOTFNS: PLA              ; CHECK WHO'S CALLING.
3710              PHA              ; RESTORE IT.
3711              CMP #ISVRET-1-[ISVRET-1]/256*256; IS EVAL CALLING?
     .IF !OSI
3712 |            BNE NOTEVL       ; NO, CARRY ON.
     .ELSE
     |            BNE VAROK
     .ENDIF
3713 .IF (REALIO != 3) && !OSI
3714 |            TSX
3715 |            LDA 258,X
3716 |            CMP #[[ISVRET-1]/256]
3717 |            BNE NOTEVL
     .ENDIF
     .IF APPLE2+KIM+PET
     |    LDZR:   LDA #<CON_ZERO
     |            LDY #>CON_ZERO
     |            RTS
     |  CON_ZERO: .WORD 0
     .ELSE
3718 |    LDZR:   LDWDI ZERO       ; SET UP PNTR TO SIMULATED ZERO.
3719 |            RTS              ; FOR STRINGS OR NUMERIC.
3720 |                             ; AND FOR INTEGERS TOO.
     .ENDIF
3721      NOTEVL:
3722 .IF TIME || EXTIO
3723 |            LDWD VARNAM
     .ENDIF
3724 .IF TIME
3725 |            CMP #'T
3726 |            BNE QSETAVR
3727 |            CPY #'I +128
3728 |            BEQ LDZR
3729 |            CPY #'I
3730 |            BNE QSETAVR
     .ENDIF
3731 .IF TIME || EXTIO
3732 |    GOBADV: JMP SNERR
     .ENDIF
3733     QSETAVR:
3734 .IF EXTIO
3735 |            CMP #'S
3736 |            BNE VAROK
3737 |            CPY #'T
3738 |            BEQ GOBADV
     .ENDIF
     .IF OSI
     |      ZERO: .BYTE 0, 0
     .ENDIF
3739      VAROK:  LDWD ARYTAB
3740              STWD LOWTR       ; LOWEST THING TO MOVE.
3741              LDWD STREND      ; GET HIGHEST ADDR TO MOVE.
3742              STWD HIGHTR
3743              CLC
3744              ADC #6+ADDPRC
3745              BCC NOTEVE
3746              INY
3747      NOTEVE: STWD HIGHDS      ; PLACE TO STUFF IT.
3748              JSR BLTU         ; MOVE IT ALL.
3749                               ; NOTE [Y,A] HAS [HIGHDS] FOR REASON.
3750              LDWD HIGHDS      ; AND SET UP
3751              INY
3752              STWD ARYTAB      ; NEW START OF ARRAY TABLE.
3753              LDY #0           ; GET ADDR OF VARIABLE ENTRY.
3754              LDA VARNAM
3755              STA (LOWTR),Y
3756              INY
3757              LDA VARNAM+1
3758              STA (LOWTR),Y    ; STORE NAME OF VARIABLE.
3759              LDA #0
3760              INY
3761              STA (LOWTR),Y
3762              INY
3763              STA (LOWTR),Y
3764              INY
3765              STA (LOWTR),Y
3766              INY
3767              STA (LOWTR),Y    ; FOURTH ZERO FOR DEF FUNC.

3768 .IF ADDPRC
3769 |            INY
3770 |            STA (LOWTR),Y
     .ENDIF

3771      FINPTR: LDA LOWTR
3772              CLC
3773              ADC #2
3774              LDY LOWTR+1
3775              BCC FINNOW
3776              INY
3777      FINNOW: STWD VARPNT      ; THIS IS IT.
3778              RTS

3779 ; PAGE
3780 ; SUBTTL     MULTIPLE DIMENSION CODE.

3781      FMAPTR: LDA COUNT
3782      GETAR2: ASL
3783              ADC #5           ; POINT TO ENTRIES. C CLR'D BY ASL.
3784              ADC LOWTR
3785              LDY LOWTR+1
3786              BCC JSRGM
3787              INY
3788      JSRGM:  STWD ARYPNT
3789              RTS
3791      N32768: .BYTE 144,128,0,0 ; -32768.
3793 ;
3794 ; INTIDX READS A FORMULA FROM THE CURRENT POSITION AND
3795 ; TURNS IT INTO A POSITIVE INTEGER
3796 ; LEAVING THE RESULT IN FACMO&LO. NEGATIVE ARGUMENTS
3797 ; ARE NOT ALLOWED.
3798 ;
3799      INTIDX: JSR CHRGET
     .IF APPLE2
     |            JSR FRMNUM
     |    POSINT:
     .ELSE
     |.IF !(OSI+KIM+PET)
3800 ||           JSR FRMEVL       ; GET A NUMBER
     |.ENDIF
3801 |            JSR FRMNUM
     |    POSINT:
     .ENDIF
3802              LDA FACSGN
3803              BMI NONONO       ; IF NEGATIVE, BLOW HIM OUT.
3804      AYINT:  LDA FACEXP
3805              CMP #144         ; FAC .GT. 32767?
3806              BCC QINTGO
3807              LDWDI N32768     ; GET ADDR OF -32768.
3808              JSR FCOMP        ; SEE IF FAC=[[Y,A]].
3809      NONONO: BNE FCERR        ; NO, FAC IS TOO BIG.
3810      QINTGO: JMP QINT         ; GO TO QINT AND SHOVE IT.
          ISARY:
     .IF APPLE2
     |            LDA SUBFLG       ; Subscripts allowed ?
     |            BNE LOPSTS       ; no --- label LOPSTS added by UB
     .ENDIF
3811 ;
3812 ; FORMAT OF ARRAYS IN CORE.
3813 ;
3814 ; DESCRIPTOR:
3815 ;       LOWBYTE = FIRST CHARACTER.
3816 ;       HIGHBYTE = SECOND CHARACTER (200 BIT IS STRING FLAG).
3817 ;       LENGTH OF ARRAY IN CORE IN BYTES (INCLUDES EVERYTHING).
3818 ;       NUMBER OF DIMENSIONS.
3819 ;       FOR EACH DIMENSION STARTING WITH THE FIRST A LIST
3820 ;           (2 BYTES EACH) OF THE MAX INDICE+1
3821 ;       THE VALUES
3822 ;
3823              LDA DIMFLG
3824 .IF INTPRC
3825 |            ORA INTFLG
     .ENDIF
3826              PHA              ; SAVE [DIMFLG] FOR RECURSION.
3827              LDA VALTYP
3828              PHA              ; SAVE [VALTYP] FOR RECURSION.
3829              LDY #0           ; SET NUMBER OF DIMENSIONS TO ZERO.
3830      INDLOP: TYA              ; SAVE NUMBER OF DIMS.
3831              PHA
3832              PSHWD VARNAM     ; SAVE LOOKS.
3833              JSR INTIDX       ; EVALUATE INDICE INTO FACMO&LO.
3834              PULWD VARNAM     ; GET BACK ALL... WE'RE HOME.
3835              PLA              ; (# OF DIMS).
3836              TAY
3837              TSX
3838              LDA 258,X
3839              PHA              ; PUSH DIMFLG AND VALTYP FURTHER.
3840              LDA 257,X
3841              PHA
3842              LDA INDICE       ; PUT INDICE ONTO STACK.
3843              STA 258,X        ; UNDER DIMFLG AND VALTYP.
3844              LDA INDICE+1
3845              STA 257,X
3846              INY              ; INCREMENT # OF DIMS.
3847              JSR CHRGOT       ; GET TERMINATING CHARACTER.
3848              CMP #44          ; A COMMA?
3849              BEQ INDLOP       ; YES.
3850              STY COUNT        ; SAVE COUNT OF DIMS.
3851              JSR CHKCLS       ; MUST BE CLOSED PAREN.
3852              PLA
3853              STA VALTYP       ; GET VALTYP AND
3854              PLA
3855 .IF INTPRC
3856 |            STA INTFLG
3857 |            AND #127
     .ENDIF
3858              STA DIMFLG       ; DIMFLG OFF STACK.
3859      LOPSTS: LDX ARYTAB       ; PLACE TO START SEARCH.
3860              LDA ARYTAB+1
3861      LOPFDA: STX LOWTR
3862              STA LOWTR+1
3863              CMP STREND+1     ; END OF ARRAYS?
3864              BNE LOPFDV
3865              CPX STREND
      .IF APPLE2
      |           BEQ NEWARV
      .ELSE
3866  |           BEQ NOTFDD       ; A FINE THING! NO ARRAY!.
      .ENDIF
3867      LOPFDV: LDY #0
3868              LDA (LOWTR),Y
3869              INY
3870              CMP VARNAM       ; COMPARE HIGH ORDERS.
3871              BNE NMARY1       ; NO WAY IS IT THIS. GET OUT OF HERE.
3872              LDA VARNAM+1
3873              CMP (LOWTR),Y    ; LOW ORDERS?
3874              BEQ GOTARY       ; WELL, HERE IT IS !!
3875      NMARY1: INY
3876              LDA (LOWTR),Y    ; GET LENGTH.
3877              CLC
3878              ADC LOWTR
3879              TAX
3880              INY
3881              LDA (LOWTR),Y
3882              ADC LOWTR+1
3883              BCC LOPFDA       ; ALWAYS BRANCHES.
3884      BSERR:  LDX #ERRBS       ; GET BAD SUB ERROR NUMBER.
3885              SKIP2
3886      FCERR:  LDX #ERRFC       ; TOO BIG. "FUNCTION CALL" ERROR.
3887      ERRGO3: JMP ERROR

3888      GOTARY: LDX #ERRDD       ; PERHAPS A "RE-DIMENSION" ERROR
3889              LDA DIMFLG       ; TEST THE DIMFLG
3890              BNE ERRGO3
     .IF APPLE2
     |            LDA SUBFLG       ; Subscripts allowed ?
     |            BEQ CHKDIM       ; yes
     |            SEC              ; error flag
     |            RTS
     .ENDIF
3891      CHKDIM: JSR FMAPTR
3892              LDA COUNT        ; GET NUMBER OF DIMS INPUT.
3893              LDY #4
3894              CMP (LOWTR),Y    ; # OF DIMS THE SAME?
3895              BNE BSERR        ; SAME SO GO GET DEFINITION.
3896              JMP GETDEF
     .IF APPLE2
     |  NEWARV:   LDA SUBFLG       ; Subscripts allowed ?
     |            BEQ NOTFDD       ; yes, go make new array variable
     |  NODATERR: LDX #ERROD       ; "?Out Of Data" error
     |            JMP ERROR
     .ENDIF


3898 ;
3899 ; HERE WHEN VARIABLE IS NOT FOUND IN THE ARRAY TABLE.
3900 ;
3901 ; BUILDING AN ENTRY.
3902 ;
3903 ;       PUT DOWN THE DESCRIPTOR.
3904 ;       SETUP NUMBER OF DIMENSIONS.
3905 ;       MAKE SURE THERE IS ROOM FOR THE NEW ENTRY.
3906 ;       REMEMBER "VARPNT".
3907 ;       TALLY=4.
3908 ;       SKIP 2 LOCS FOR LATER FILL IN OF SIZE.
3909 ; LOOP: GET AN INDICE
3910 ;       PUT DOWN NUMBER+1 AND INCREMENT VARPTR.
3911 ;       TALLY=TALLY*NUMBER+1.
3912 ;       DECREMENT NUMBER-DIMS.
3913 ;       BNE LOOP
3914 ;       CALL "REASON" WITH [Y,A] REFLECTING LAST LOC OF VARIABLE.
3915 ;       UPDATE STREND.
3916 ;       ZERO ALL.
3917 ;       MAKE TALLY INCLUDE MAXDIMS AND DESCRIPTOR.
3918 ;       PUT DOWN TALLY.
3919 ;       IF CALLED BY DIMENSION, RETURN.
3920 ;       OTHERWISE INDEX INTO THE VARIABLE AS IF IT
3921 ;        WERE FOUND ON THE INITIAL SEARCH.
3922 ;
3923      NOTFDD: JSR FMAPTR       ; FORM ARYPNT.
3924              JSR REASON
3925              LDA #0
3926              TAY
3927              STA CURTOL+1
3928 .IF !ADDPRC
3929 |            LDX #4
     .ENDIF
3930 .IF ADDPRC
3931 |            LDX #5
     .ENDIF
     .IF !OSI
3932 |            LDA VARNAM       ; THIS CODE ONLY WORKS FOR INTPRC=1
3933 |            STA (LOWTR),Y    ; IF ADDPRC=1.
3934 |.IF ADDPRC
3935 ||           BPL NOTFLT
3936 ||           DEX
     |.ENDIF
3937 |    NOTFLT: INY
3938 |            LDA VARNAM+1
3939 |            STA (LOWTR),Y
3940 |            BPL STOMLT
3941 |            DEX
3942 |.IF ADDPRC
3943 ||           DEX
     |.ENDIF
     .ENDIF
3944      STOMLT: STX CURTOL
     .IF OSI
     |            LDA VARNAM
     |            STA (LOWTR),Y
     |            INY
     |            LDA VARNAM+1
     |            STA (LOWTR),Y
     .ENDIF
3945              LDA COUNT
3946              .REPEAT 3
                   INY
                  .REPEND
3947              STA (LOWTR),Y    ; SAVE NUMBER OF DIMENSIONS.
3948      LOPPTA: LDX #11          ; DEFAULT SIZE.
3949              LDA #0
3950              BIT DIMFLG
3951              BVC NOTDIM       ; NOT IN A DIM STATEMENT.
3952              PLA              ; GET LOW ORDER OF INDICE.
3953              CLC
3954              ADC #1
3955              TAX
3956              PLA              ; GET HIGH PART OF INDICE.
3957              ADC #0
3958      NOTDIM: INY
3959              STA (LOWTR),Y    ; STORE HIGH PART OF INDICE.
3960              INY
3961              TXA
3962              STA (LOWTR),Y    ; STORE LOW ORDER OF INDICE.
3963              JSR UMULT        ; [X,A]=[CURTOL]*[LOWTR,Y]
3964              STX CURTOL       ; SAVE NEW TALLY.
3965              STA CURTOL+1
3966              LDY INDEX
3967              DEC COUNT        ; ANY MORE INDICES LEFT?
3968              BNE LOPPTA       ; YES.
3969              ADC ARYPNT+1
3970              BCS OMERR1       ; OVERFLOW.
3971              STA ARYPNT+1     ; COMPUTE WHERE TO ZERO.
3972              TAY
3973              TXA
3974              ADC ARYPNT
3975              BCC GREASE
3976              INY
3977              BEQ OMERR1
3978      GREASE: JSR REASON       ; GET ROOM.
3979              STWD STREND      ; NEW END OF STORAGE.
3980              LDA #0           ; STORING [ACCA] IS FASTER THAN CLEAR.
3981              INC CURTOL+1
3982              LDY CURTOL
3983              BEQ DECCUR
3984      ZERITA: DEY
3985              STA (ARYPNT),Y
3986              BNE ZERITA       ; NO. CONTINUE.
3987      DECCUR: DEC ARYPNT+1
3988              DEC CURTOL+1
3989              BNE ZERITA       ; DO ANOTHER BLOCK.
3990              INC ARYPNT+1     ; BUMP BACK UP. WILL USE LATER.
3991              SEC
3992              LDA STREND       ; RESTORE [ACCA].
3993              SBC LOWTR        ; DETERMINE LENGTH.
3994              LDY #2
3995              STA (LOWTR),Y    ; LOW.
3996              LDA STREND+1
3997              INY
3998              SBC LOWTR+1
3999              STA (LOWTR),Y    ; HIGH.
4000              LDA DIMFLG
4001              BNE DIMRTS       ; BYE.
4002              INY
4003 ;
4004 ; AT THIS POINT [LOWTR,Y] POINTS BEYOND THE SIZE TO THE NUMBER OF
4005 ; DIMENSIONS. STRATEGY:
4006 ;         NUMDIM=NUMBER OF DIMENSIONS.
4007 ;         CURTOL=0.
4008 ; INLPNM: GET A NEW INDICE.
4009 ;         MAKE SURE INDICE IS NOT TOO BIG.
4010 ;         MULTIPLY CURTOL BY CURMAX.
4011 ;         ADD INDICE TO CURTOL.
4012 ;         NUMDIM=NUMDIM-1.
4013 ;         BNE INLPNM.
4014 ;         USE [CURTOL]*4 AS OFFSET.
4015 ;
4016      GETDEF: LDA (LOWTR),Y
4017              STA COUNT        ; SAVE A COUNTER.
4018              LDA #0           ; ZERO [CURTOL].
4019              STA CURTOL
4020      INLPNM: STA CURTOL+1
4021              INY
4022              PLA              ; GET LOW INDICE.
4023              TAX
4024              STA INDICE
4025              PLA              ; AND THE HIGH PART
4026              STA INDICE+1
4027              CMP (LOWTR),Y    ; COMPARE WITH MAX INDICE.
4028              BCC INLPN2
4029              BNE BSERR7       ; IF GREATER, "BAD SUBSCRIPT" ERROR.
4030              INY
4031              TXA
4032              CMP (LOWTR),Y
4033              BCC INLPN1
4034      BSERR7: JMP BSERR
4035      OMERR1: JMP OMERR
4036      INLPN2: INY
4037      INLPN1: LDA CURTOL+1     ; DON'T MULTIPLY IF CURTOL=0.
4038              ORA CURTOL
4039              CLC              ; PREPARE TO GET INDICE BACK.
4040              BEQ ADDIND       ; GET HIGH PART OF INDICE BACK.
4041              JSR UMULT        ; MULTIPLY [CURTOL] BY [LOWTR,Y,Y+1].
4042              TXA
4043              ADC INDICE       ; ADD IN [INDICE].
4044              TAX
4045              TYA
4046              LDY INDEX1
4047      ADDIND: ADC INDICE+1
4048              STX CURTOL
4049              DEC COUNT        ; ANY MORE?
4050              BNE INLPNM       ; YES.
     .IF !OSI
     |.IF !PET
4051 ||           STA CURTOL+1     ; FIX ARRAY BUG ****
     |.ENDIF
4052 |.IF !ADDPRC
4053 ||           LDX #4
     |.ENDIF
4054 |.IF ADDPRC
4055 ||           LDX #5           ; THIS CODE ONLY WORKS FOR INTPRC=1
4056 ||           LDA VARNAM       ; IF ADDPRC=1.
4057 ||           BPL NOTFL1
4058 ||           DEX
     |.ENDIF
4059 |    NOTFL1: LDA VARNAM+1
4060 |            BPL STOML1
4061 |            DEX
4062 |.IF ADDPRC
4063 ||           DEX
     |.ENDIF
4064 |    STOML1: STX ADDEND
4065 |            LDA #0
4066 |            JSR UMULTD       ; ON RTS, A&Y=HI . X=LO.
4067 |            TXA
     .ELSE
     |            ASL CURTOL
     |            ROL
     |            BCS BSERR7
     |            ASL CURTOL
     |            ROL
     |            BCS BSERR7
     |            TAY
     |            LDA CURTOL
     .ENDIF
4068              ADC ARYPNT
4069              STA VARPNT
4070              TYA
4071              ADC ARYPNT+1
4072              STA VARPNT+1
4073              TAY
4074              LDA VARPNT
4075      DIMRTS: RTS              ; RETURN TO CALLER.

4076 ; SUBTTL     INTEGER ARITHMETIC ROUTINES.

4077              ; TWO BYTE UNSIGNED INTEGER MULTIPLY.
4078              ; THIS IS FOR MULTIPLY DIMENSIONED ARRAYS.
4079              ;  [X,Y]=[X,A]=[CURTOL]*[LOWTR,Y,Y+1].
4080      UMULT:  STY INDEX
4081              LDA (LOWTR),Y
4082              STA ADDEND       ; LOW, THEN HIGH.
4083              DEY
4084              LDA (LOWTR),Y    ; PUT [LOWTR,Y,Y+1] IN FASTER MEMORY.
4085      UMULTD: STA ADDEND+1
4086              LDA #16
4087              STA DECCNT
4088              LDX #0           ; CLR THE ACCS.
4089              LDY #0           ; RESULT INITIALLY ZERO.
4090      UMULTC: TXA
4091              ASL              ; MULTIPLY BY TWO.
4092              TAX
4093              TYA
4094              ROL
4095              TAY
4096              BCS OMERR1       ; TWO MUCH !
4097              ASL CURTOL
4098              ROL CURTOL+1
4099              BCC UMLCNT       ; NOTHING IN THIS POSITION TO MULTIPLY.
4100              CLC
4101              TXA
4102              ADC ADDEND
4103              TAX
4104              TYA
4105              ADC ADDEND+1
4106              TAY
4107              BCS OMERR1       ; MAN, JUST TOO MUCH !
4108      UMLCNT: DEC DECCNT       ; DONE?
4109              BNE UMULTC       ; KEEP IT UP.
4110      UMLRTS: RTS              ; YES, ALL DONE.

4111 ; PAGE
4112 ; SUBTTL     FRE FUNCTION AND INTEGER TO FLOATING ROUTINES.

4113      FRE:    LDA VALTYP
4114              BEQ NOFREF
4115              JSR FREFAC
4116      NOFREF: JSR GARBA2
4117              SEC
4118              LDA FRETOP       ; WE WANT
4119              SBC STREND       ; [FRETOP]-[STREND].
4120              TAY
4121              LDA FRETOP+1
4122              SBC STREND+1
4124      GIVAYF: LDX #0
4125              STX VALTYP
4126              STWD FACHO
4127              LDX #144         ; SET EXPONENT TO 2^16.
4128              JMP FLOATS       ; TURN IT TO A FLOATING PNT #.
     .IF APPLE2
     |    POS:    LDY CH
     |    SNGFLT: LDA #0
     |            SEC
     .ELSE
4130 |    POS:    LDY TRMPOS       ; GET POSITION.
4131 |    SNGFLT: LDA #0
     .ENDIF
4132              BEQA GIVAYF      ; FLOAT IT.
4133 ; PAGE
4134 ; SUBTTL     SIMPLE-USER-DEFINED-FUNCTION CODE.

4135 ;
4136 ; NOTE ONLY SINGLE ARGUMENTS ARE ALLOWED TO FUNCTIONS
4137 ; AND FUNCTIONS MUST BE OF THE SINGLE LINE FORM:
4138 ;       DEF FNA(X)=X^2+X-2
4139 ; NO STRINGS CAN BE INVOLVED WITH THESE FUNCTIONS.
4140 ;
4141 ; IDEA: CREATE A SIMPLE VARIABLE ENTRY
4142 ; WHOSE FIRST CHARACTER HAS THE 200 BIT SET.
4143 ; THE VALUE WILL BE:
4144 ;
4145 ;       A TEXT PNTR TO THE FORMULA.
4146 ;       A PNTR TO THE ARGUMENT VARIABLE.
4147 ;
4148 ; FUNCTION NAMES CAN BE LIKE "FNA4".
4149 ;
4150 ;
4151 ; SUBROUTINE TO SEE IF WE ARE IN DIRECT MODE.
4152 ; AND COMPLAIN IF SO.
4153 ;
4154      ERRDIR: LDX CURLIN+1     ; DIR MODE HAS [CURLIN]=0,255
4155              INX              ; SO NOW, IS RESULT ZERO?
4156              BNE DIMRTS       ; YES.
4157              LDX #ERRID       ; INPUT DIRECT ERROR CODE.
     .IF !(OSI+KIM+PET)
4158 |            SKIP2
4159 |    ERRGUF: LDX #ERRUF       ; USER DEFINED FUNCTION NEVER DEFINED
     .ELSE
     |    ERRGUF:
     .ENDIF
4160      ERRGO1: JMP ERROR
4162      DEF:    JSR GETFNM       ; GET A PNTR TO THE FUNCTION.
4163              JSR ERRDIR
4164              JSR CHKOPN       ; MUST HAVE "(".
4165              LDA #128
4166              STA SUBFLG       ; PROHIBIT SUBSCRIPTED VARIABLES.
4167              JSR PTRGET       ; GET PNTR TO ARGUMENT.
4168              JSR CHKNUM       ; IS IT A NUMBER?
4169              JSR CHKCLS       ; MUST HAVE ")"
4170              SYNCHK EQLTK     ; MUST HAVE "=".
4171 .IF ADDPRC                    ; PUT CRAZY BYTE ON.
     |            PHA
     .ENDIF
4172              PSHWD VARPNT
4173              PSHWD TXTPTR
4174              JSR DATA
4175              JMP DEFFIN
4176 ;
4177 ; SUBROUTINE TO GET A PNTR TO A FUNCTION NAME.
4178 ;
4179      GETFNM: SYNCHK FNTK      ; MUST START WITH FN.
4180              ORA #128         ; PUT FUNCTION BIT ON.
4181              STA SUBFLG
4182              JSR PTRGT2       ; GET POINTER TO FUNCTION OR CREATE ANEW.
4183              STWD DEFPNT
4184              JMP CHKNUM       ; MAKE SURE IT'S NOT A STRING AND RETURN.
4186      FNDOER: JSR GETFNM       ; GET THE FUNCTION'S NAME.
4187              PSHWD DEFPNT
4188              JSR PARCHK       ; EVALUATE PARAMETER.
4189              JSR CHKNUM
4190              PULWD DEFPNT
4191              LDY #2
     .IF OSI
     |            LDX #$20
     .ENDIF
     .IF KIM
     |            LDX #$E0
     .ENDIF
     .IF PET
     |            LDX #$ED
     .ENDIF
     .IF OSI+KIM+PET
     |            LDA (DEFPNT),Y
     |            BEQ ERRGO1
     |            STA VARPNT
     .ELSE
4192 |            LDA (DEFPNT),Y   ; GET POINTER TO VARIABLE.
4193 |            STA VARPNT       ; SAVE VARIABLE POINTER.
     .ENDIF
4194              TAX
4195              INY
4196              LDA (DEFPNT),Y
     .IF !(OSI+KIM+PET)
4197 |            BEQ ERRGUF
     .ENDIF
4198              STA VARPNT+1
4199 .IF ADDPRC                    ; SINCE DEF USES ONLY 4.
     |            INY
     .ENDIF
4200      DEFSTF: LDA (VARPNT),Y
4201              PHA              ; PUSH IT ALL ON STACK.
4202              DEY              ; SINCE WE ARE RECURSING MAYBE.
4203              BPL DEFSTF
4204              LDY VARPNT+1
4205              JSR MOVMF        ; PUT CURRENT FAC INTO OUR ARG VARIABLE.
4206              PSHWD TXTPTR     ; SAVE TEXT POINTER.
4207              LDA (DEFPNT),Y   ; PNTR TO FUNCTION.
4208              STA TXTPTR
4209              INY
4210              LDA (DEFPNT),Y
4211              STA TXTPTR+1
4212              PSHWD VARPNT     ; SAVE VARIABLE POINTER.
4213              JSR FRMNUM       ; EVALUATE FORMULA AND CHECK NUMERIC.
4214              PULWD DEFPNT
4215              JSR CHRGOT
4216              JNE SNERR        ; IT DIDN'T TERMINATE. HUH?
4217              PULWD TXTPTR     ; RESTORE TEXT PNTR.
4218      DEFFIN: LDY #0
4219              PLA              ; GET OLD ARG VALUE OFF STACK
4220              STA (DEFPNT),Y   ; AND PUT IT BACK IN VARIABLE.
4221              PLA
4222              INY
4223              STA (DEFPNT),Y
4224              PLA
4225              INY
4226              STA (DEFPNT),Y
4227              PLA
4228              INY
4229              STA (DEFPNT),Y
4230 .IF ADDPRC
4231 |            PLA
4232 |            INY
4233 |            STA (DEFPNT),Y
     .ENDIF
4234      DEFRTS: RTS

4236 ; SUBTTL     STRING FUNCTIONS.

4237 ;
4238 ; THE STR$ FUNCTION TAKES A NUMBER AND GIVES A STRING
4239 ; WITH THE CHARACTERS THE OUTPUT OF THE NUMBER
4240 ; WOULD HAVE GIVEN.
4241 ;
4242      STR:    JSR CHKNUM       ; ARG HAS TO BE NUMERIC.
4243              LDY #0
4244              JSR FOUTC        ; DO ITS OUTPUT.
4245              PLA
4246              PLA
4247      TIMSTR: LDWDI LOFBUF
4248              BEQA STRLIT      ; SCAN IT AND TURN IT INTO A STRING.
4249 ;
4250 ; "STRINI" GET STRING SPACE FOR THE CREATION OF A STRING AND
4251 ; CREATES A DESCRIPTOR FOR IT IN "DSCTMP".
4252 ;
4253      STRINI: LDXY FACMO       ; GET FACMO TO STORE IN DSCPNT.
4254              STXY DSCPNT      ; RETAIN THE DESCRIPTOR POINTER.
4255      STRSPA: JSR GETSPA       ; GET STRING SPACE.
4256              STXY DSCTMP+1    ; SAVE LOCATION.
4257              STA DSCTMP       ; SAVE LENGTH.
4258              RTS              ; ALL DONE.
4259 ;
4260 ; "STRLT2" TAKES THE STRING LITERAL WHOSE FIRST CHARACTER
4261 ; IS POINTED TO BY [Y,A] AND BUILDS A DESCRIPTOR FOR IT.
4262 ; THE DESCRIPTOR IS INITIALLY BUILT IN "DSCTMP", BUT "PUTNEW"
4263 ; TRANSFERS IT INTO A TEMPORARY AND LEAVES A POINTER
4264 ; AT THE TEMPORARY IN FACMO&LO. THE CHARACTERS OTHER THAN
4265 ; ZERO THAT TERMINATE THE STRING SHOULD BE SET UP IN "CHARAC"
4266 ; AND "ENDCHR". IF THE TERMINATOR IS A QUOTE, THE QUOTE IS SKIPPED
4267 ; OVER. LEADING QUOTES SHOULD BE SKIPPED BEFORE JSR. ON RETURN
4268 ; THE CHARACTER AFTER THE STRING LITERAL IS POINTED TO
4269 ; BY [STRNG2].
4270 ;
4271      STRLIT: LDX #34          ; ASSUME STRING ENDS ON QUOTE.
4272              STX CHARAC
4273              STX ENDCHR
4274      STRLT2: STWD STRNG1      ; SAVE POINTER TO STRING.
4275              STWD DSCTMP+1    ; IN CASE NO STRCPY.
4276              LDY #255         ; INITIALIZE CHARACTER COUNT.
4277      STRGET: INY
4278              LDA (STRNG1),Y   ; GET CHARACTER.
4279              BEQ STRFI1       ; IF ZERO.
4280              CMP CHARAC       ; THIS TERMINATOR?
4281              BEQ STRFIN       ; YES.
4282              CMP ENDCHR
4283              BNE STRGET       ; LOOK FURTHER.
4284      STRFIN: CMP #34          ; QUOTE?
4285              BEQ STRFI2
4286      STRFI1: CLC              ; NO, BACK UP.
4287      STRFI2: STY DSCTMP       ; RETAIN COUNT.
4288              TYA
4289              ADC STRNG1       ; WISHING TO SET [TXTPTR].
4290              STA STRNG2
4291              LDX STRNG1+1
4292              BCC STRST2
4293              INX
4294      STRST2: STX STRNG2+1
4295              LDA STRNG1+1     ; IF PAGE 0, COPY SINCE IT IS EITHER
4296                               ; A STRING CONSTANT IN BUF OR A STR$
4297                               ; RESULT IN LOFBUF
4298 .IF BUFPAG
4299 |            BEQ STRCP
4300 |            CMP #BUFPAG
     .ENDIF
4301              BNE PUTNEW
4302      STRCP:  TYA
4303              JSR STRINI
4304              LDXY STRNG1
4305              JSR MOVSTR       ; MOVE STRING.
4306 ;
4307 ; SOME STRING FUNCTION IS RETURNING A RESULT IN DSCTMP.
4308 ; SETUP A TEMP DESCRIPTOR WITH DSCTMP IN IT.
4309 ; PUT A POINTER TO THE DESCRIPTOR IN FACMO&LO AND FLAG THE
4310 ; RESULT AS TYPE STRING.
4311 ;
4312      PUTNEW: LDX TEMPPT       ; POINTER TO FIRST FREE TEMP.
4313              CPX #TEMPST+STRSIZ*NUMTMP
4314              BNE PUTNW1
4315              LDX #ERRST       ; STRING TEMPORARY ERROR.
4316      ERRGO2: JMP ERROR        ; GO TELL HIM.
4317      PUTNW1: LDA DSCTMP
4318              STA 0,X
4319              LDA DSCTMP+1
4320              STA 1,X
4321              LDA DSCTMP+2
4322              STA 2,X
4323              LDY #0
4324              STXY FACMO
     .IF !(APPLE2+OSI+KIM+PET)
4325 |            STY FACOV
     .ENDIF
4326              DEY
4327              STY VALTYP       ; TYPE IS "STRING".
4328              STX LASTPT       ; SET POINTER TO LAST-USED TEMP.
4329              INX
4330              INX
4331              INX              ; POINT FURTHER.
4332              STX TEMPPT       ; SAVE POINTER TO NEXT TEMP IF ANY.
4333              RTS              ; ALL DONE.
4335 ;
4336 ; GETSPA - GET SPACE FOR CHARACTER STRING.
4337 ; MAY FORCE GARBAGE COLLECTION.
4338 ;
4339 ; # OF CHARACTERS (BYTES) IN ACCA.
4340 ; RETURNS WITH POINTER IN [Y,X]. OTHERWISE (IF CAN'T GET
4341 ; SPACE) BLOWS OFF TO "OUT OF STRING SPACE" TYPE ERROR.
4342 ; ALSO PRESERVES [ACCA] AND SETS [FRESPC]=[Y,X]=PNTR AT SPACE.
4343 ;
4344      GETSPA: LSR GARBFL       ; SIGNAL NO GARBAGE COLLECTION YET.
4345      TRYAG2: PHA              ; SAVE FOR LATER.
4346              EOR #255
4347              SEC              ; ADD ONE TO COMPLETE NEGATION.
4348              ADC FRETOP
4349              LDY FRETOP+1
4350              BCS TRYAG3
4351              DEY
4352      TRYAG3: CPY STREND+1     ; COMPARE HIGH ORDERS.
4353              BCC GARBAG       ; MAKE ROOM FOR MORE.
4354              BNE STRFRE       ; SAVE NEW FRETOP.
4355              CMP STREND       ; COMPARE LOW ORDERS.
4356              BCC GARBAG       ; CLEAN UP.
4357      STRFRE: STWD FRETOP      ; SAVE NEW [FRETOP].
4358              STWD FRESPC      ; PUT IT THERE OLD MAN.
4359              TAX              ; PRESERVE A IN X.
4360              PLA              ; GET COUNT BACK IN ACCA.
4361              RTS              ; ALL DONE.
4362      GARBAG: LDX #ERROM       ; "OUT OF STRING SPACE"
4363              LDA GARBFL
4364              BMI ERRGO2
4365              JSR GARBA2
4366              LDA #128
4367              STA GARBFL
4368              PLA              ; GET BACK STRING LENGTH.
4369              BNE TRYAG2       ; ALWAYS BRANCHES.
4370      GARBA2:                  ; START FROM TOP DOWN.
4371 .IF !(REALIO+DISKO)
4372 |            LDA #7           ; TYPE "BELL".
4373 |            JSR OUTDO
     .ENDIF
4374              LDX MEMSIZ
4375              LDA MEMSIZ+1
4376      FNDVAR: STX FRETOP       ; LIKE SO.
4377              STA FRETOP+1
4378              LDY #0
     .IF OSIFIX                    ; Uncle Bernie's OSI garbage collection fix
     |            STY GRBTOP       ; of Y1980 starts here, but be warned that
     |            STY GRBTOP+1     ; it's unknown whether it is better or worse
     |            LDX #3           ; than Microsoft's fix: (FIX BUG) below.
     |            STX FOUR6        ; set length of temporary string descriptor
     .ELSE
4379 |            STY GRBPNT+1
     |.IF !(APPLE2+OSI+KIM+PET)    ; these don't have Microsoft's fix:
4380 ||           STY GRBPNT       ; BOTH BYTES SET TO ZERO (FIX BUG)
     |.ENDIF
4381 |            LDWX STREND
4382 |            STWX GRBTOP
     .ENDIF
4383              LDWXI TEMPST
4384              STWX INDEX1
4385      TVAR:   CMP TEMPPT       ; DONE WITH TEMPS?
     .IF !OSIFIX
4386 |            BEQ SVARS        ; YEP.
     .ELSE
     |            BCS SVARS
     .ENDIF
4387              JSR DVAR
4388              BEQ TVAR         ; LOOP.
4389      SVARS:  LDA #6+ADDPRC
4390              STA FOUR6
4391              LDWX VARTAB      ; GET START OF SIMPLE VARIABLES.
4392              STWX INDEX1
4393      SVAR:   CPX ARYTAB+1     ; DONE WITH SIMPLE VARIABLES?
4394              BNE SVARGO       ; NO.
4395              CMP ARYTAB
4396              BEQ ARYVAR       ; YEP.
4397      SVARGO: JSR DVARS        ; DO IT , AGAIN.
4398              BEQ SVAR         ; LOOP.
4399      ARYVAR: STWX ARYPNT      ; SAVE FOR ADDITION.
4400              LDA #STRSIZ+OSIFIX
4401              STA FOUR6
4402      ARYVA2: LDWX ARYPNT      ; GET THE POINTER TO VARIABLE.
4403      ARYVA3: CPX STREND+1     ; DONE WITH ARRAYS?
4404              BNE ARYVGO       ; NO.
4405              CMP STREND
4406              JEQ GRBPAS       ; YES, GO FINISH UP.
4407      ARYVGO: STWX INDEX1
4408              LDY #1-ADDPRC
4409 .IF ADDPRC
4410 |            LDA (INDEX1),Y
4411 |            TAX
4412 |            INY
     .ENDIF
4413              LDA (INDEX1),Y
4414              PHP
4415              INY
4416              LDA (INDEX1),Y
4417              ADC ARYPNT
4418              STA ARYPNT       ; FORM POINTER TO NEXT ARRAY VAR.
4419              INY
4420              LDA (INDEX1),Y
4421              ADC ARYPNT+1
4422              STA ARYPNT+1
4423              PLP
4424              BPL ARYVA2
4425 .IF ADDPRC
4426 |            TXA
4427 |            BMI ARYVA2
     .ENDIF
4428              INY
4429              LDA (INDEX1),Y
     .IF !(OSI+PET)
4430 |            LDY #0           ; RESET INDEX Y.
     .ENDIF
     .IF !PET
4431 |            ASL
4432 |            ADC #5           ; CARRY IS OFF AND OFF AFTER ADD.
     .ELSE
     |            JSR PATCH7
     .ENDIF
     .IF OSIFIX
     |            JSR ADDP
     .ELSE
4433 |            ADC INDEX1
4434 |            STA INDEX1
4435 |            BCC ARYGET
4436 |            INC INDEX1+1
4437 |    ARYGET: LDX INDEX1+1
     .ENDIF
4438      ARYSTR: CPX ARYPNT+1     ; END OF THE ARRAY?
4439              BNE GOGO
4440              CMP ARYPNT
     .IF !OSIFIX
4441 |            BEQ ARYVA3       ; YES.
     .ELSE
     |            BEQ ARYVA2
     .ENDIF
4442      GOGO:   JSR DVAR
4443              BEQ ARYSTR       ; CYCLE.
4444      DVARS:
4445 .IF INTPRC
4446 |            LDA (INDEX1),Y
4447 |            BMI DVARTS
     .ENDIF
     .IF !OSIFIX
4448 |            INY
     .ELSE
     |            LDY #1
     .ENDIF
4449              LDA (INDEX1),Y
4450              BPL DVARTS
4451              INY
4452      DVAR:   LDA (INDEX1),Y   ; IS LENGTH=0?
4453              BEQ DVARTS       ; YES, RETURN.
4454              INY
4455              LDA (INDEX1),Y   ; GET LOW(ADR).
4456              TAX
4457              INY
4458              LDA (INDEX1),Y
4459              CMP FRETOP+1     ; COMPARE HIGHS.
4460              BCC DVAR2        ; IF THIS STRING'S PNTR .GE. [FRETOP]
4461              BNE DVARTS       ; NO NEED TO MESS WITH IT FURTHER.
4462              CPX FRETOP       ; COMPARE LOWS.
4463              BCS DVARTS
4464      DVAR2:  CMP GRBTOP+1
4465              BCC DVARTS       ; IF THIS STRING IS BELOW PREVIOUS,
4466                               ; FORGET IT.
4467              BNE DVAR3
4468              CPX GRBTOP       ; COMPARE LOW ORDERS.
4469              BCC DVARTS       ; [X,A] .LE. [GRBTOP].
4470      DVAR3:  STX GRBTOP
4471              STA GRBTOP+1
4472              LDWX INDEX1
4473              STWX GRBPNT
4474              LDA FOUR6
4475              STA SIZE
4476      DVARTS: LDA FOUR6
4477      ADDP:   CLC
4478              ADC INDEX1
4479              STA INDEX1
4480              BCC GRBRTS
4481              INC INDEX1+1
4482      GRBRTS: LDX INDEX1+1
4483              LDY #0
4484              RTS              ; DONE.
     .IF !(APPLE2+OSI+KIM+PET)     ; the original source way to check GC done
4485 |;
4486 |; HERE WHEN MADE ONE COMPLETE PASS THROUGH STRING VARIABLES.
4487 |;
4488 |    GRBPAS: LDA GRBPNT+1     ; VARIABLE POINTER.
4489 |            ORA GRBPNT
     .ENDIF
     .IF APPLE2 || (OSI && !OSIFIX); Applesoft and unfixed OSI checks DEFPNT+1
     |    GRBPAS: LDX DEFPNT+1
     .ENDIF
     .IF KIM+PET                   ; KIM+PET do the same ... a bug or not ?
     |   GRBPAS:  LDX DEFPNT+1
     .ENDIF
     .IF OSIFIX                    ; Uncle Bernie's OSI fix checks GRBTOP+1
     |   GRBPAS:  LDX GRBTOP+1
     .ENDIF
4490              BEQ GRBRTS       ; ALL DONE.
     .IF !OSIFIX                   ; the original botched SIZE calculation ...
4491 |            LDA SIZE
     |.IF !PET
4492 ||           AND #4           ; LEAVES C OFF.
     |.ELSE
     ||           SBC #$03         ; ... with PET exception. Did this fix it ?
     |.ENDIF
4493 |            LSR
4494 |            TAY
4495 |            STA SIZE
     .ELSE                         ; ... and the OSI only fix by Uncle Bernie
     |            LDY #00          ; if descriptor length is 3 or 4, Y = 0
     |            LDA SIZE         ; if descriptor length is 6, Y =2
     |            CMP #6
     |            BNE NSIM
     |            LDY #2
     |     NSIM:  STY SIZE
     |            CLC              ; added CLC because of no LSR being above
     .ENDIF
4496              LDA (GRBPNT),Y
4497                               ; NOTE: GRBTOP=LOWTR SO NO NEED TO SET LOWTR.
4498              ADC LOWTR
4499              STA HIGHTR
4500              LDA LOWTR+1
4501              ADC #0
4502              STA HIGHTR+1
4503              LDWX FRETOP
4504              STWX HIGHDS      ; WHERE IT ALL GOES.
4505              JSR BLTUC
4506              LDY SIZE
4507              INY
4508              LDA HIGHDS       ; GET POSITION OF START OF RESULT.
4509              STA (GRBPNT),Y
4510              TAX
4511              INC HIGHDS+1
4512              LDA HIGHDS+1
4513              INY
4514              STA (GRBPNT),Y   ; CHANGE ADDR OF STRING IN VAR.
4515              JMP FNDVAR       ; GO TO FNDVAR WITH SOMETHING FOR
4516                               ; [FRETOP].
     .IF OSIFIX
     |            NOP
     |            NOP
     |            NOP
     .ENDIF
4517 ;
4518 ; THE FOLLOWING ROUTINE CONCATENATES TWO STRINGS.
4519 ; THE FAC CONTAINS THE FIRST ONE AT THIS POINT.
4520 ; [TXTPTR] POINTS TO THE + SIGN.
4521 ;
4522      CAT:    LDA FACLO        ; PSH HIGH ORDER ONTO STACK.
4523              PHA
4524              LDA FACMO        ; AND THE LOW.
4525              PHA
4526              JSR EVAL         ; CAN COME BACK HERE SINCE
4527                               ; OPERATOR IS KNOWN.
4528              JSR CHKSTR       ; RESULT MUST BE STRING.
4529              PLA
4530              STA STRNG1       ; GET HIGH ORDER OF OLD DESC.
4531              PLA
4532              STA STRNG1+1
4533              LDY #0
4534              LDA (STRNG1),Y   ; GET LENGTH OF OLD STRING.
4535              CLC
4536              ADC (FACMO),Y
4537              BCC SIZEOK       ; RESULT IS LESS THAN 256.
4538              LDX #ERRLS       ; ERROR "LONG STRING".
4539              JMP ERROR
4540      SIZEOK: JSR STRINI       ; INITIALIZE STRING.
4541              JSR MOVINS       ; MOVE IT.
4542              LDWD DSCPNT      ; GET POINTER TO SECOND.
4543              JSR FRETMP       ; FREE IT.
4544              JSR MOVDO
4545              LDWD STRNG1
4546              JSR FRETMP
4547              JSR PUTNEW
4548              JMP TSTOP        ; "CAT" REENTERS FORM EVAL AT TSTOP.
4550      MOVINS: LDY #0           ; GET ADDR OF STRING.
4551              LDA (STRNG1),Y
4552              PHA
4553              INY
4554              LDA (STRNG1),Y
4555              TAX
4556              INY
4557              LDA (STRNG1),Y
4558              TAY
4559              PLA
4560      MOVSTR: STXY INDEX
4561      MOVDO:  TAY
4562              BEQ MVDONE
4563              PHA
4564      MOVLP:  DEY
4565              LDA (INDEX),Y
4566              STA (FRESPC),Y
4567      QMOVE:  TYA
4568              BNE MOVLP
4569              PLA
4570      MVDONE: CLC
4571              ADC FRESPC
4572              STA FRESPC
4573              BCC MVSTRT
4574              INC FRESPC+1
4575      MVSTRT: RTS
4576 ;
4577 ; "FRETMP" IS PASSED A STRING DESCRIPTOR PNTR IN [Y,A].
4578 ; A CHECK IS MADE TO SEE IF THE STRING DESCRIPTOR POINTS TO THE LAST
4579 ; TEMPORARY DESCRIPTOR ALLOCATED BY PUTNEW.
4580 ; IF SO, THE TEMPORARY IS FREED UP BY THE UPDATING OF [TEMPPT].
4581 ; IF A TEMP IS FREED UP, A FURTHER CHECK SEES IF THE STRING DATA THAT
4582 ; THAT STRING TEMP PNT'D TO IS THE LOWEST PART OF STRING SPACE IN USE.
4583 ; IF SO, [FRETOP] IS UPDATED TO REFLECT THE FACT THE FACT THAT THE SPACE
4584 ; IS NO LONGER IN USE.
4585 ; THE ADDR OF THE ACTUAL STRING IS RETURNED IN [Y,X] AND
4586 ; ITS LENGTH IN ACCA.
4587 ;
4588      FRESTR: JSR CHKSTR       ; MAKE SURE ITS A STRING.
4589      FREFAC: LDWD FACMO       ; FREE UP STR PNT'D TO BY FAC.
4590      FRETMP: STWD INDEX       ; GET LENGTH FOR LATER.
4591              JSR FRETMS       ; FREE UP THE TEMPORARY DESC.
4592              PHP              ; SAVE CODES.
4593              LDY #0           ; PREP TO GET STUFF.
4594              LDA (INDEX),Y    ; GET COUNT AND
4595              PHA              ; SAVE IT.
4596              INY
4597              LDA (INDEX),Y
4598              TAX              ; SAVE LOW ORDER.
4599              INY
4600              LDA (INDEX),Y
4601              TAY              ; SAVE HIGH ORDER.
4602              PLA
4603              PLP              ; RETURN STATUS.
4604              BNE FRETRT
4605              CPY FRETOP+1     ; STRING IS LAST ONE IN?
4606              BNE FRETRT
4607              CPX FRETOP
4608              BNE FRETRT
4609              PHA
4610              CLC
4611              ADC FRETOP
4612              STA FRETOP
4613              BCC FREPLA
4614              INC FRETOP+1
4615      FREPLA: PLA              ; GET COUNT BACK.
4616      FRETRT: STXY INDEX       ; SAVE FOR LATER USE.
4617              RTS
4618      FRETMS: CPY LASTPT+1     ; LAST ENTRY TO TEMP?
4619              BNE FRERTS
4620              CMP LASTPT
4621              BNE FRERTS
4622              STA TEMPPT
4623              SBC #STRSIZ      ; POINT TO LAST ONE.
4624              STA LASTPT       ; UPDATE TEMP PNTR.
4625              LDY #0           ; ALSO CLEARS ZFLG SO WE DO REST OF FRETMP.
4626      FRERTS: RTS              ; ALL DONE.
4627 ;
4628 ; CHR$(#) CREATES A STRING WHICH CONTAINS AS ITS ONLY
4629 ; CHARACTER THE ASCII EQUIVALENT OF THE INTEGER ARGUMENT (#)
4630 ; WHICH MUST BE .LT. 255.
4631 ;
4632      CHR:    JSR CONINT       ; GET INTEGER IN RANGE.
4633              TXA
4634              PHA
4635              LDA #1           ; ONE-CHARACTER STRING.
4636              JSR STRSPA       ; GET SPACE FOR STRING.
4637              PLA
4638              LDY #0
4639              STA (DSCTMP+1),Y
4640              PLA              ; GET RID OF "CHKNUM" RETURN ADDR.
4641              PLA
4642      RLZRET: JMP PUTNEW       ; SETUP FAC TO POINT TO DESC.
4643 ;
4644 ; THE FOLLOWING IS THE LEFT$($,#) FUNCTION.
4645 ; IT TAKES THE LEFTMOST # CHARACTERS OF THE STRING.
4646 ; IF # .GT. THE LEN OF THE STRING, IT RETURNS THE WHOLE STRING.
4647 ;
4648      LEFT:   JSR PREAM        ; TEST PARAMETERS.
4649              CMP (DSCPNT),Y
4650              TYA
4651      RLEFT:  BCC RLEFT1
4652              LDA (DSCPNT),Y
4653              TAX              ; PUT LENGTH INTO X.
4654              TYA              ; ZERO A, THE OFFSET.
4655      RLEFT1: PHA              ; SAVE OFFSET.
4656      RLEFT2: TXA
4657      RLEFT3: PHA              ; SAVE LENGTH.
4658              JSR STRSPA       ; GET SPACE.
4659              LDWD DSCPNT
4660              JSR FRETMP
4661              PLA
4662              TAY
4663              PLA
4664              CLC
4665              ADC INDEX        ; COMPUTE WHERE TO COPY.
4666              STA INDEX
4667              BCC PULMOR
4668              INC INDEX+1
4669      PULMOR: TYA
4670              JSR MOVDO        ; GO MOVE IT.
4671              JMP PUTNEW
4672      RIGHT:  JSR PREAM
4673              CLC              ; [LENGTH DES'D]-[LENGTH]-1.
4674              SBC (DSCPNT),Y
4675              EOR #255         ; NEGATE.
4676              JMP RLEFT
4677 ;
4678 ; MID ($,#) RETURNS STRING WITH CHARS FROM # POSITION
4679 ; ONWARD. IF # .GT. LEN ($) THEN RETURN NULL STRING.
4680 ; MID ($,#,#) RETURNS STRING WITH CHARACTERS FROM
4681 ; # POSITION FOR #2 CHARACTERS. IF #2 GOES PAST END OF STRING
4682 ; RETURN AS MUCH AS POSSIBLE.
4683 ;
4684      MID:    LDA #255         ; DEFAULT.
4685              STA FACLO        ; SAVE FOR LATER COMPARE.
4686              JSR CHRGOT       ; GET CURRENT CHARACTER.
4687              CMP #41          ; IS IT A RIGHT PAREN )?
4688              BEQ MID2         ; NO THIRD PARAM.
4689              JSR CHKCOM       ; MUST HAVE COMMA.
4690              JSR GETBYT       ; GET THE LENGTH INTO "FACLO".
4691      MID2:   JSR PREAM        ; CHECK IT OUT.
     .IF !(APPLE2+OSI+KIM+PET)
4692 |            BEQ GOFUC        ; THERE IS NO POSTION 0
     .ENDIF
4693              DEX              ; COMPUTE OFFSET.
4694              TXA
4695              PHA              ; PRSERVE AWHILE.
4696              CLC
4697              LDX #0
4698              SBC (DSCPNT),Y   ; GET LENGTH OF WHAT'S LEFT.
4699              BCS RLEFT2       ; GIVE NULL STRING.
4700              EOR #255         ; IN SUB C WAS 0 SO JUST COMPLEMENT.
4701              CMP FACLO        ; GREATER THAN WHAT'S DESIRED?
4702              BCC RLEFT3       ; NO, COPY THAT MUCH.
4703              LDA FACLO        ; GET LENGTH OF WHAT'S DESIRED.
4704              BCS RLEFT3       ; COPY IT.
4705
4706 ;
4707 ; USED BY RIGHT$, LEFT$, MID$ FOR PARAMETER CHECKING AND SETUP.
4708 ;
4709      PREAM:  JSR CHKCLS       ; PARAM LIST SHOULD END.
4710              PLA              ; GET THE RETURN ADDRESS INTO
     .IF !(OSI+PET)
4711 |            TAY              ; [JMPER+1,Y]
4712 |            PLA
4713 |            STA JMPER+1
     .ELSE
     |            STA JMPER+1
     |            PLA
     |            STA JMPER+2
     .ENDIF
4714              PLA              ; GET RID OF FINGO'S JSR RET ADDR.
4715              PLA
4716              PLA              ; GET LENGTH.
4717              TAX
4718              PULWD DSCPNT
     .IF !(OSI+PET)
4719 |            LDA JMPER+1      ; PUT RETURN ADDRESS BACK ON
4720 |            PHA
4721 |            TYA
4722 |            PHA
     .ENDIF
4723              LDY #0
4724              TXA
     .IF APPLE2+OSI+KIM+PET
     |            BEQ GOFUC
     .ENDIF
     .IF OSI+PET
     |            INC JMPER+1
     |            JMP (JMPER+1)
     .ELSE
4725 |            RTS
     .ENDIF
4726 ;
4727 ; THE FUNCTION LEN($) RETURNS THE LENGTH OF THE STRING
4728 ; PASSED AS AN ARGUMENT.
4729 ;
4730      LEN:    JSR LEN1
4731      LEN0:   JMP SNGFLT
4732      LEN1:   JSR FRESTR       ; FREE UP STRING.
4733              LDX #0
4734              STX VALTYP       ; FORCE NUMERIC.
4735              TAY              ; SET CODES ON LENGTH.
4736              RTS              ; DONE.
4737 ;
4738 ; THE FOLLOWING IS THE ASC($) FUNCTION. IT RETURNS
4739 ; AN INTEGER WHICH IS THE DECIMAL ASCII EQUIVALENT.
4740 ;
4741      ASC:    JSR LEN1
4742              BEQ GOFUC        ; NULL STRING, BAD ARG.
4743              LDY #0
4744              LDA (INDEX1),Y   ; GET CHARACTER.
4745              TAY
     .IF !(OSI+PET)
4746 |            JMP SNGFLT
     .ELSE
     |            JMP LEN0
     .ENDIF
4747      GOFUC:  JMP FCERR        ; YES.
4749      GTBYTC: JSR CHRGET
4750      GETBYT: JSR FRMNUM       ; READ FORMULA INTO FAC.
4751      CONINT: JSR POSINT       ; CONVERT THE FAC TO A SINGLE BYTE INT.
4752              LDX FACMO
4753              BNE GOFUC        ; RESULT MUST BE .LE. 255.
4754              LDX FACLO
4755      CHRGO2: JMP CHRGOT       ; SET CONDITION CODES ON TERMINATOR.
4756 ;
4757 ; THE "VAL" FUNCTION TAKES A STRING AND TURNS IT INTO
4758 ; A NUMBER BY INTERPRETING THE ASCII DIGITS ETCQ
4759 ; EXCEPT FOR THE PROBLEM THAT A TERMINATOR MUST BE SUPPLIED
4760 ; BY REPLACING THE CHARACTER BEYOND THE STRING, VAL IS MERELY
4761 ; A CALL TO FLOATING POINT INPUT ("FIN").
4762 ;
4763      VAL:    JSR LEN1         ; DO SETUP. SET RESULT=NUMERIC.
4764              JEQ ZEROFC       ; ZERO THE FAC ON A NULL STRING
4765              LDXY TXTPTR
4766              STXY STRNG2      ; SAVE FOR LATER.
4767              LDX INDEX1
4768              STX TXTPTR
4769              CLC
4770              ADC INDEX1
4771              STA INDEX2
4772              LDX INDEX1+1
4773              STX TXTPTR+1
4774              BCC VAL2         ; NO CARRY, NO INC.
4775              INX
4776      VAL2:   STX INDEX2+1
4777              LDY #0
4778              LDA (INDEX2),Y   ; PRESERVE CHARACTER.
4779              PHA
4780              LDA #0           ; SET A TERMINATOR.
4781              STA (INDEX2),Y
4782              JSR CHRGOT       ; GET CHARACTER PNT'D TO AND SET FLAGS.
4783              JSR FIN
4784              PLA              ; GET PRES'D CHARACTER.
4785              LDY #0
4786              STA (INDEX2),Y   ; STUFF IT BACK.
4787      ST2TXT: LDXY STRNG2
4788              STXY TXTPTR
4789      VALRTS: RTS              ; ALL DONE WITH STRINGS.

4790 ; PAGE
4791 ; SUBTTL     PEEK, POKE, AND FNWAIT.
4792
4793      GETNUM: JSR FRMNUM       ; GET ADDRESS.
4794              JSR GETADR       ; GET THAT LOCATION.
4795      COMBYT: JSR CHKCOM       ; CHECK FOR A COMMA.
4796              JMP GETBYT       ; GET SOMETHING TO STORE AND RETURN.
          GETADR:
     .IF !APPLE2
4797 |            LDA FACSGN       ; EXAMINE SIGN.
4798 |            BMI GOFUC        ; FUNCTION CALL ERROR.
     .ENDIF
4799              LDA FACEXP       ; EXAMINE EXPONENT.
4800              CMP #145
4801              BCS GOFUC        ; FUNCTION CALL ERROR.
4802              JSR QINT         ; INTEGERIZE IT.
4803              LDWD FACMO
4804              STY POKER
4805              STA POKER+1
4806              RTS              ; IT'S DONE !.
          PEEK:
     .IF !APPLE2
     |.IF !(OSI+KIM+PET)           ; OSI, KIM, PET don't push POKER at all
4808 ||            PSHWD POKER
     |.ENDIF
     .ELSE                         ; Applesoft does it in reverse order !
     |             LDA POKER
     |             PHA
     |             LDA POKER+1
     |             PHA
     .ENDIF
4809              JSR GETADR
4810              LDY #0
4811 .IF REALIO == 3
4812 |            CMP #ROMLOC/256  ; IF WITHIN BASIC,
4813 |            BCC GETCON
4814 |            CMP #LASTWR/256
4815 |            BCC DOSGFL       ; GIVE HIM ZERO FOR AN ANSWER.
     .ENDIF
4816      GETCON: LDA (POKER),Y    ; GET THAT BYTE.
4817              TAY
          DOSGFL:
     .IF !APPLE2
     |.IF !(OSI+KIM+PET)           ; OSI, KIM, PET don't push POKER, so no pull
4818 ||           PULWD POKER
     |.ENDIF
     .ELSE                         ; this pulls POKER bytes in reverse order
     |            PLA              ; see at PEEK above. Why did Apple (?) this?
     |            STA POKER+1
     |            PLA
     |            STA POKER
     .ENDIF
4819              JMP SNGFLT       ; FLOAT IT.
4821      POKE:   JSR GETNUM
4822              TXA
4823              LDY #0
4824              STA (POKER),Y    ; STORE VALUE AWAY.
4825              RTS              ; SCANNED  EVERYTHING.
4826
4827 ; THE WAIT LOCATION,MASK1,MASK2 STATEMENT WAITS UNTIL THE CONTENTS
4828 ; OF LOCATION IS NONZERO WHEN XORED WITH MASK2
4829 ; AND THEN ANDED WITH MASK1. IF MASK2 IS NOT PRESENT, IT
4830 ; IS ASSUMED TO BE ZERO.
4827
4832      FNWAIT: JSR GETNUM
4833              STX ANDMSK
4834              LDX #0
4835              JSR CHRGOT
4836              BEQ STORDO
4837              JSR COMBYT       ; GET MASK2.
4838      STORDO: STX EORMSK
4839              LDY #0
4840      WAITER: LDA (POKER),Y
4841              EOR EORMSK
4842              AND ANDMSK
4843              BEQ WAITER
4844      ZERRTS: RTS              ; GOT A NONZERO.

4845 ; SUBTTL     FLOATING POINT MATH PACKAGE CONFIGURATION.
4846
4847 ; RADIX   8                   !!!! ALERT !!!!
4848                               ; THROUGHOUT THE MATH PACKAGE.
     ; Note: Alert kept for historic reasons. You can safely ignore this as
     ; ===== all constants were automatically converted from octal to hex.
4949
4850 ; THE FLOATING POINT FORMAT IS AS FOLLOWS:
4851 ;
4852 ; THE SIGN IS THE FIRST BIT OF THE MANTISSA.
4853 ; THE MANTISSA IS 24 BITS LONG.
4854 ; THE BINARY POINT IS TO THE LEFT OF THE MSB.
4855 ; NUMBER = MANTISSA * 2 ^ EXPONENT.
4856 ; THE MANTISSA IS POSITIVE WITH A ONE ASSUMED TO BE WHERE THE SIGN BIT IS.
4857 ; THE SIGN OF THE EXPONENT IS THE FIRST BIT OF THE EXPONENT.
4858 ; THE EXPONENT IS STORED IN EXCESS 200, I.E. WITH A BIAS OF +200.
4859 ; SO, THE EXPONENT IS A SIGNED 8-BIT NUMBER WITH 200 ADDED TO IT.
4860 ; AN EXPONENT OF ZERO MEANS THE NUMBER IS ZERO.
4861 ; THE OTHER BYTES MAY NOT BE ASSUMED TO BE ZERO.
4862 ; TO KEEP THE SAME NUMBER IN THE FAC WHILE SHIFTING,
4863 ;         TO SHIFT RIGHT, EXP:=EXP+1
4864 ;         TO SHIFT LEFT,  EXP:=EXP-1
4865 ;
4866 ; IN MEMORY THE NUMBER LOOKS LIKE THIS:
4867 ;         [THE EXPONENT AS A SIGNED NUMBER +200]
4868 ;         [THE SIGN BIT IN 7, BITS 2-8 OF MANTISSA ARE IN BITS 6-0].
4869 ;                 (REMEMBER BIT 1 OF MANTISSA IS ALWAYS A ONE.)
4870 ;         [BITS 9-16 OF THE MANTISSA]
4871 ;         [BITS 17-24] OF THE MANTISSA]
4872 ;
4873 ; ARITHMETIC ROUTINE CALLING CONVENTIONS:
4874 ;
4875 ; FOR ONE ARGUMENT FUNCTIONS:
4876 ;         THE ARGUMENT IS IN THE FAC.
4877 ;         THE RESULT IS LEFT IN THE FAC.
4878 ; FOR TWO ARGUMENT OPERATIONS:
4879 ;         THE FIRST ARGUMENT IS IN ARG (ARGEXP,HO,MO,LO AND ARGSGN).
4880 ;         THE SECOND ARGUMENT IS IN THE FAC.
4881 ;         THE RESULT IS LEFT IN THE FAC.
4882 ;
4883 ; THE "T" ENTRY POINTS TO THE TWO-ARGUMENT OPERATIONS HAVE BOTH ARGUMENTS
4884 ; SETUP IN THE RESPECTIVE REGISTERS. BEFORE CALLING ARG MAY HAVE BEEN
4885 ; POPPED OFF THE STACK AND INTO ARG, FOR EXAMPLE.
4886 ; THE OTHER ENTRY POINT ASSUMES [Y,A] POINTS TO THE ARGUMENT
4887 ; SOMEWHERE IN MEMORY. IT IS UNPACKED INTO ARG BY "CONUPK".
4888 ;
4889 ; ON THE STACK, THE SGN IS PUSHED ON FIRST, THE LO,MO,HO AND FINALLY EXP.
4890 ; NOTE ALL THINGS ARE KEPT UNPACKED IN ARG, FAC AND ON THE STACK.
4891 ;
4892 ; IT IS ONLY WHEN SOMETHING IS STORED AWAY THAT IT IS PACKED TO FOUR
4893 ; BYTES. THE UNPACKED FORMAT HAS A SGN BYTE REFLECTING THE SIGN OF THE
4894 ; NUMBER (POSITIVE=0, NEGATIVE=-1) A HO,MO AND LO WITH THE HIGH BIT
4895 ; OF THE HO TURNED ON. THE EXP IS THE SAME AS STORED FORMAT.
4896 ; THIS IS DONE FOR SPEED OF OPERATION.

4898 ; PAGE
4899 ; SUBTTL     FLOATING POINT ADDITION AND SUBTRACTION.

4900      FADDH:  LDWDI FHALF      ; ENTRY TO ADD 1/2.
4901              JMP FADD         ; UNPACK AND GO ADD IT.
4902      FSUB:   JSR CONUPK       ; UNPACK ARGUMENT INTO ARG.
4903      FSUBT:  LDA FACSGN
4904              EOR #$FF         ; COMPLEMENT IT.
4905              STA FACSGN
4906              EOR ARGSGN       ; COMPLEMENT ARISGN.
4907              STA ARISGN
4908              LDA FACEXP       ; SET CODES ON FACEXP.
4909              JMP FADDT        ; [Y]=ARGEXP..
4912 .IF REALIO != 3
     |            ZSTORDO: SET STORDO
     .ENDIF
4913 .IF (REALIO == 3) && !PET
4914 |    ZSTORD: LDA POKER
4915 |            CMP #$66
4916 |            BNE STORDO
4917 |            LDA POKER+1
4918 |            SBC #$19
4919 |            BNE STORDO
4920 |            STA POKER
4921 |            TAY
4922 |            LDA #$80
4923 |            STA POKER+1
4924 |    MRCHKR: LDX #$0A
4925 |.IF (PASS == 1)              ; this was 'IF1', true in MACRO-10 pass #1
4926 ||   MRCHR:  LDA $6000,X
     |.ENDIF
4927 |.IF (PASS == 2)              ; this was 'IF2', true in MACRO-10 pass #2
4928 ||   MRCHR:  LDA SINCON+30,X  ; ... we don't define 'PASS' because this
     |.ENDIF                       ; ... piece of code is not used in PET BASIC.
4929 |            AND #$3F
4930 |            STA (POKER),Y
4931 |            INY
4932 |            BNE PKINC
4933 |            INC POKER+1
4934 |    PKINC:  DEX
4935 |            BNE MRCHR
4936 |            DEC ANDMSK
4937 |            BNE MRCHKR
4938 |            RTS
     .ENDIF
           PASS:  SET 0            ; avoid the 'PURGE'
4939 .IF (PASS == 2)               ; this was 'IF2', true in MACRO-10 pass #2
     |            PURGE ZSTORD     ; tell MACRO-10 to delete symbol 'ZSTORD'
     .ENDIF
4942      FADD5:  JSR SHIFTR       ; DO A LONG SHIFT.
4943              BCC FADD4        ; CONTINUE WITH ADDITION.
4944      FADD:   JSR CONUPK
4945      FADDT:  JEQ MOVFA        ; IF FAC=0, RESULT IS IN ARG.
4946              LDX FACOV
4947              STX OLDOV
4948              LDX #ARGEXP      ; DEFAULT IS SHIFT ARGUMENT.
4949              LDA ARGEXP       ; IF ARG=0, FAC IS RESULT.
4950      FADDC:  TAY              ; ALSO COPY ACCA INTO ACCY.
4951              BEQ ZERRTS       ; RETURN.
4952              SEC
4953              SBC FACEXP
4954              BEQ FADD4        ; NO SHIFTING.
4955              BCC FADDA        ; BR IF ARGEXP.LT.FACEXP.
4956              STY FACEXP       ; RESULTING EXPONENT.
4957              LDY ARGSGN       ; SINCE ARG IS BIGGER, IT'S
4958              STY FACSGN       ; SIGN IS SIGN OF RESULT.
4959              EOR #$FF         ; SHIFT A NEGATIVE NUMBER OF PLACES.
4960              ADC #0           ; COMPLETE NEGATION. W/ C=1.
4961              LDY #0           ; ZERO OLDOV.
4962              STY OLDOV
4963              LDX #FAC         ; SHIFT THE FAC INSTEAD.
4964              BNE FADD1
4965      FADDA:  LDY #0
4966              STY FACOV
4967      FADD1:  CMP #256-7       ; FOR SPEED AND NECESSITY.  GETS
4968                               ; MOST LIKELY CASE TO SHIFTR FASTEST
4969                               ; AND ALLOWS SHIFTING OF NEG NUMS
4970                               ; BY "QINT".
4971              BMI FADD5        ; SHIFT BIG.
4972              TAY
4973              LDA FACOV        ; SET FACOV.
4974              LSR 1,X          ; GETS 0 IN MOST SIG BIT.
4975              JSR ROLSHF       ; DO THE ROLLING.
4976      FADD4:  BIT ARISGN       ; GET RESULTING SIGN.
4977              BPL FADD2        ; IF POSITIVE, ADD.
4978                               ; CARRY IS CLEAR.
4979      FADD3:  LDY #FACEXP
4980              CPX #ARGEXP      ; FAC IS BIGGER.
4981              BEQ SUBIT
4982              LDY #ARGEXP      ; ARG IS BIGGER.
4983      SUBIT:  SEC
4984              EOR #$FF
4985              ADC OLDOV
4986              STA FACOV
4987              LDA 3+ADDPRC,Y
4988              SBC 3+ADDPRC,X
4989              STA FACLO
4990              LDA 2+ADDPRC,Y
4991              SBC 2+ADDPRC,X
4992              STA FACMO
4993 .IF ADDPRC
4994 |            LDA 2,Y
4995 |            SBC 2,X
4996 |            STA FACMOH
     .ENDIF
4997              LDA 1,Y
4998              SBC 1,X
4999              STA FACHO
5000      FADFLT: BCS NORML        ; HERE IF SIGNS DIFFER. IF CARRY,
5001                               ; FAC IS SET OK.
5002              JSR NEGFAC       ; NEGATE [FAC].
5003      NORML:  LDY #0
5004              TYA
5005              CLC
5006      NORM3:  LDX FACHO
5007              BNE NORM1
5008              LDX FACHO+1      ; SHIFT 8 BITS AT A TIME FOR SPEED.
5009              STX FACHO
5010 .IF ADDPRC
5011 |            LDX FACMOH+1
5012 |            STX FACMOH
     .ENDIF
5013              LDX FACMO+1
5014              STX FACMO
5015              LDX FACOV
5016              STX FACLO
5017              STY FACOV
5018              ADC #8
5019              CMP #8*ADDPRC+$18
5020              BNE NORM3
5021      ZEROFC: LDA #0           ; NOT NEED BY NORMAL BUT BY OTHERS.
5022      ZEROF1: STA FACEXP       ; NUMBER MUST BE ZERO.
5023      ZEROML: STA FACSGN       ; MAKE SIGN POSITIVE.
5024              RTS              ; ALL DONE.
5025      FADD2:  ADC OLDOV
5026              STA FACOV
5027              LDA FACLO
5028              ADC ARGLO
5029              STA FACLO
5030              LDA FACMO
5031              ADC ARGMO
5032              STA FACMO
5033 .IF ADDPRC
5034 |            LDA FACMOH
5035 |            ADC ARGMOH
5036 |            STA FACMOH
     .ENDIF
5037              LDA FACHO
5038              ADC ARGHO
5039              STA FACHO
5040              JMP SQUEEZ       ; GO ROUND IF SIGNS SAME.
5042      NORM2:  ADC #1           ; DECREMENT SHIFT COUNT.
5043              ASL FACOV        ; SHIFT ALL LEFT ONE BIT.
5044              ROL FACLO
5045              ROL FACMO
5046 .IF ADDPRC
5047 |            ROL FACMOH
     .ENDIF
5048              ROL FACHO
5049      NORM1:  BPL NORM2        ; IF MSB=0 SHIFT AGAIN.
5050              SEC
5051              SBC FACEXP
5052              BCS ZEROFC
5053              EOR #$FF
5054              ADC #1           ; COMPLEMENT.
5055              STA FACEXP
5056      SQUEEZ: BCC RNDRTS       ; BITS TO SHIFT?
5057      RNDSHF: INC FACEXP
5058              BEQ OVERR
5059              RAR FACHO
5060 .IF ADDPRC
5061 |            RAR FACMOH
     .ENDIF
5062              RAR FACMO
5063              RAR FACLO
5064              RAR FACOV
5065      RNDRTS: RTS              ; ALL DONE ADDING.
5067      NEGFAC: COM FACSGN       ; COMPLEMENT FAC ENTIRELY.
5068      NEGFCH: COM FACHO        ; COMPLEMENT JUST THE NUMBER.
5069 .IF ADDPRC
5070 |            COM FACMOH
     .ENDIF
5071              COM FACMO
5072              COM FACLO
5073              COM FACOV
5074              INC FACOV
5075              BNE INCFRT
5076      INCFAC: INC FACLO
5077              BNE INCFRT
5078              INC FACMO
5079              BNE INCFRT       ; IF NO CARRY, RETURN.
5080 .IF ADDPRC
5081 |            INC FACMOH
5082 |            BNE INCFRT
     .ENDIF
5083              INC FACHO        ; CARRY INCREMENT.
5084      INCFRT: RTS
5086      OVERR:  LDX #ERROV
5087              JMP ERROR        ; TELL USER.
5088 ;
5089 ; "SHIFTR" SHIFTS [X+1:X+3] [-ACCA]  BITS RIGHT.
5090 ; SHIFTS BYTES TO START WITH IF POSSIBLE.
5091 ;
5092      MULSHF: LDX #RESHO-1     ; ENTRY POINT FOR MULTIPLIER.
5093      SHFTR2: LDY 3+ADDPRC,X   ; SHIFT BYTES FIRST.
5094              STY FACOV
5095 .IF ADDPRC
5096 |            LDY 3,X
5097 |            STY 4,X
     .ENDIF
5098              LDY 2,X          ; GET MO.
5099              STY 3,X          ; STORE LO.
5100              LDY 1,X          ; GET HO.
5101              STY 2,X          ; STORE MO.
5102              LDY BITS
5103              STY 1,X          ; STORE HO.
5104      SHIFTR: ADC #$08
5105              BMI SHFTR2
5106              BEQ SHFTR2
5107              SBC #$08         ; C CAN BE EITHER 1,0 AND IT WORKS.
5108              TAY
5109              LDA FACOV
5110              BCS SHFTRT       ; EQUIV TO BEQ HERE.
5111 .IF RORSW
5112 |    SHFTR3: ASL 1,X
5113 |            BCC SHFTR4
5114 |            INC 1,X
5115 |    SHFTR4: ROR 1,X
5116 |            ROR 1,X          ; YES, TWO OF THEM.
     .ENDIF
5117 .IF !RORSW
5118 |    SHFTR3: PHA
5119 |            LDA 1,X
5120 |            AND #$80
5121 |            LSR 1,X
5122 |            ORA 1,X
5123 |            STA 1,X
5124 |            SKIP1
     .ENDIF
5125      ROLSHF:
5126 .IF RORSW
5127 |            ROR 2,X
5128 |            ROR 3,X
5129 |.IF ADDPRC                   ; ONE MO TIME.
     ||           ROR 4,X
     |.ENDIF
     .ENDIF
5131 .IF !RORSW
5132 |            PHA
5133 |            LDA #0
5134 |            BCC SHFTR5
5135 |            LDA #$80
5136 |    SHFTR5: LSR 2,X
5137 |            ORA 2,X
5138 |            STA 2,X
5139 |            LDA #0
5140 |            BCC SHFTR6
5141 |            LDA #$80
5142 |    SHFTR6: LSR 3,X
5143 |            ORA 3,X
5144 |            STA 3,X
5145 |.IF ADDPRC
5146 ||           LDA #0
5147 ||           BCC SHFT6A
5148 ||           LDA #$80
5149 ||   SHFT6A: LSR 4,X
5150 ||           ORA 4,X
5151 ||           STA 4,X
     |.ENDIF
     .ENDIF
5152 .IF RORSW                     ; ROTATE ARGUMENT 1 BIT RIGHT.
     |            ROR
     .ENDIF
5153 .IF !RORSW
5154 |            PLA
5155 |            PHP
5156 |            LSR
5157 |            PLP
5158 |            BCC SHFTR7
5159 |            ORA #$80
     .ENDIF
5160      SHFTR7: INY
5161              BNE SHFTR3       ; $$$ ( MOST EXPENSIVE ! )
5162      SHFTRT: CLC              ; CLEAR OUTPUT OF FACOV.
5163              RTS

5164 ; PAGE
5165 ; SUBTTL     NATURAL LOG FUNCTION.

5166 ;
5167 ; CALCULATION IS BY:
5168 ; LN(F*2^N)=(N+LOG2(F))*LN(2)
5169 ; AN APPROXIMATION POLYNOMIAL IS USED TO CALCULATE LOG2(F).
5170 ;  CONSTANTS USED BY LOG:
5171      FONE: .BYTE $81, 0, 0, 0 ; 1.0
5175 .IF ADDPRC
     |    .BYTE 0
     .ENDIF
5176 .IF !ADDPRC
5177 |    LOGCN2:
     |    .BYTE 2                       ; DEGREE-1
5178 |    .BYTE $80, $19, $56, $62      ; 0.59897437
5182 |    .BYTE $80, $76, $22, $F3      ; 0.96147080
5186 |    .BYTE $82, $38, $AA, $40      ; 2.88539129
     .ENDIF
5191 .IF ADDPRC
5192 |    LOGCN2:
     |    .BYTE 3                       ; DEGREE-1
5193 |    .BYTE $7F, $5E, $56, $CB, $79 ; 0.43425594188
5198 |    .BYTE $80, $13, $9B, $0B, $64 ; 0.57658454134
5203 |    .BYTE $80, $76, $38, $93, $16 ; 0.96180075921
5208 |    .BYTE $82, $38, $AA, $3B, $20 ; 2.8853900728
     .ENDIF
5213      SQRHLF:                  ;  SQR(0.5)
          .BYTE $80, $35, $04, $F3
5217 .IF ADDPRC
     |    .BYTE $34
     .ENDIF
5218      SQRTWO:                  ;  SQR(2.0)
          .BYTE $81, $35, $04, $F3
5222 .IF ADDPRC
     |    .BYTE $34
     .ENDIF
5223      NEGHLF:                  ;  -1/2
          .BYTE $80, $80, $0, $0
5227 .IF ADDPRC
     |    .BYTE 0
     .ENDIF
5228      LOG2:                    ;  LN(2)
          .BYTE $80, $31, $72
5231 .IF !ADDPRC
     |    .BYTE $18
     .ENDIF
5232 .IF ADDPRC
     |    .BYTE $17, $F8
     .ENDIF
5334
5235      LOG:    JSR SIGN         ; IS IT POSITIVE?
5236              BEQ LOGERR
5237              BPL LOG1
5238      LOGERR: JMP FCERR        ; CAN'T TOLERATE NEG OR ZERO.
5239      LOG1:   LDA FACEXP       ; GET EXPONENT INTO ACCA.
5240              SBC #$7F         ; REMOVE BIAS. (CARRY IS OFF)
5241              PHA              ; SAVE AWHILE.
5242              LDA #$80
5243              STA FACEXP       ; RESULT IS FAC IN RANGE [0.5,1].
5244              LDWDI SQRHLF     ; GET POINTER TO SQR(0.5).
5245
5246              ; CALCULATE (F-SQR(.5))/(F+SQR(.5))
5247
5248              JSR FADD         ; ADD TO FAC.
5249              LDWDI SQRTWO     ; GET SQR(2.).
5250              JSR FDIV
5251              LDWDI FONE
5252              JSR FSUB
5253              LDWDI LOGCN2
5254              JSR POLYX        ; EVALUATE APPROXIMATION POLYNOMIAL.
5255              LDWDI NEGHLF     ; ADD IN LAST CONSTANT.
5256              JSR FADD
5257              PLA              ; GET EXPONENT BACK.
5258              JSR FINLOG       ; ADD IT IN.
5259      MULLN2: LDWDI LOG2       ; MULTIPLY RESULT BY LOG(2.0).
5260              ;JMP FMULT       ; MULTIPLY TOGETHER. (fall through)

5261 ; PAGE
5262 ; SUBTTL     FLOATING MULTIPLICATION AND DIVISION.

5263              ; MULTIPLICATION FAC:=ARG*FAC.
5264      FMULT:  JSR CONUPK       ; UNPACK THE CONSTANT INTO ARG FOR USE.
     .IF !(OSI+PET)
5265 |    FMULTT: JEQ MULTRT       ; IF FAC=0, RETURN. FAC IS SET.
     .ELSE
     |    FMULTT: BEQ MULTRT
     .ENDIF
5266              JSR MULDIV       ; FIX UP THE EXPONENTS.
5267              LDA #0           ; TO CLEAR RESULT.
5268              STA RESHO
5269 .IF ADDPRC
5270 |            STA RESMOH
     .ENDIF
5271              STA RESMO
5272              STA RESLO
5273              LDA FACOV
5274              JSR MLTPLY
5275              LDA FACLO        ; MLTPLY ARG BY FACLO.
5276              JSR MLTPLY
5277              LDA FACMO        ; MLTPLY ARG BY FACMO.
5278              JSR MLTPLY
5279 .IF ADDPRC
5280 |            LDA FACMOH
5281 |            JSR MLTPLY
     .ENDIF
5282              LDA FACHO        ; MLTPLY ARG BY FACHO.
5283              JSR MLTPL1
5284              JMP MOVFR        ; MOVE RESULT INTO FAC,
5285                               ; NORMALIZE RESULT, AND RETURN.
5286      MLTPLY: JEQ MULSHF       ; SHIFT RESULT RIGHT 1 BYTE.
5287      MLTPL1: LSR
5288              ORA #$80
5289      MLTPL2: TAY
5290              BCC MLTPL3       ; IT MULT BIT=0, JUST SHIFT.
5291              CLC
5292              LDA RESLO
5293              ADC ARGLO
5294              STA RESLO
5295              LDA RESMO
5296              ADC ARGMO
5297              STA RESMO
5298 .IF ADDPRC
5299 |            LDA RESMOH
5300 |            ADC ARGMOH
5301 |            STA RESMOH
     .ENDIF
5302              LDA RESHO
5303              ADC ARGHO
5304              STA RESHO
5305      MLTPL3: RAR RESHO
5306 .IF ADDPRC
5307 |            RAR RESMOH
     .ENDIF
5308              RAR RESMO
5309              RAR RESLO
5310              RAR FACOV        ; SAVE FOR ROUNDING.
5311              TYA
5312              LSR              ; CLEAR MSB SO WE GET A CLOSER TO 0.
5313              BNE MLTPL2       ; SLOW AS A TURTLE !
5314      MULTRT: RTS
5315
5316              ; ROUTINE TO UNPACK MEMORY INTO ARG.
5317      CONUPK: STWD INDEX1
5318              LDY #3+ADDPRC
5319              LDA (INDEX1),Y
5320              STA ARGLO
5321              DEY
5322              LDA (INDEX1),Y
5323              STA ARGMO
5324              DEY
5325 .IF ADDPRC
5326 |            LDA (INDEX1),Y
5327 |            STA ARGMOH
5328 |            DEY
     .ENDIF
5329              LDA (INDEX1),Y
5330              STA ARGSGN
5331              EOR FACSGN
5332              STA ARISGN
5333              LDA ARGSGN
5334              ORA #$80
5335              STA ARGHO
5336              DEY
5337              LDA (INDEX1),Y
5338              STA ARGEXP
5339              LDA FACEXP       ; SET CODES OF FACEXP.
5340              RTS
5341
5342              ; CHECK SPECIAL CASES AND ADD EXPONENTS FOR FMULT, FDIV.
5343      MULDIV: LDA ARGEXP       ; EXP OF ARG=0?
5344      MLDEXP: BEQ ZEREMV       ; SO WE GET ZERO EXPONENT.
5345              CLC
5346              ADC FACEXP       ; RESULT IS IN ACCA.
5347              BCC TRYOFF       ; FIND [C] XOR [N].
5348              BMI GOOVER       ; OVERFLOW IF BITS MATCH.
5349              CLC
5350              SKIP2
5351      TRYOFF: BPL ZEREMV       ; UNDERFLOW.
5352              ADC #$80         ; ADD BIAS.
5353              STA FACEXP
5354              JEQ ZEROML       ; ZERO THE REST OF IT.
5355              LDA ARISGN
5356              STA FACSGN       ; ARISGN IS RESULT'S SIGN.
5357              RTS              ; DONE.
5358      MLDVEX: LDA FACSGN       ; GET SIGN.
5359              EOR #$FF         ; COMPLEMENT IT.
5360              BMI GOOVER
5361      ZEREMV: PLA              ; GET ADDR OFF STACK.
5362              PLA
5363              JMP ZEROFC       ; UNDERFLOW.
5364      GOOVER: JMP OVERR        ; OVERFLOW.
5365
5366              ; MULTIPLY FAC BY 10.
5367      MUL10:  JSR MOVAF        ; COPY FAC INTO ARG.
5368              TAX
5369              BEQ MUL10R       ; IF [FAC]=0, GOT ANSWER.
5370              CLC
5371              ADC #2           ; AUGMENT EXP BY 2.
5372              BCS GOOVER       ; OVERFLOW.
5373      FINML6: LDX #0
5374              STX ARISGN       ; SIGNS ARE SAME.
5375              JSR FADDC        ; ADD TOGETHER.
5376              INC FACEXP       ; MULTIPLY BY TWO.
5377              BEQ GOOVER       ; OVERFLOW.
5378      MUL10R: RTS

5380              ;  DIVIDE FAC BY 10.
5381      TENZC:  .BYTE $84, $20, 0, 0
5385 .IF ADDPRC
     |    .BYTE 0
     .ENDIF
5386      DIV10:  JSR MOVAF        ; MOVE FAC TO ARG.
5387              LDWDI TENZC      ; POINT TO CONSTANT OF 10.0
5388              LDX #0           ; SIGNS ARE BOTH POSITIVE.
5389      FDIVF:  STX ARISGN
5390              JSR MOVFM        ; PUT IT INTO FAC.
5391              JMP FDIVT        ; SKIP OVER NEXT TWO BYTES.
5392      FDIV:   JSR CONUPK       ; UNPACK CONSTANT.
5393      FDIVT:  BEQ DV0ERR       ; CAN'T DIVIDE BY ZERO !
5394                               ; (NOT ENOUGH ROOM TO STORE RESULT.)
5395              JSR ROUND        ; TAKE FACOV INTO ACCT IN FAC.
5396              LDA #0           ; NEGATE FACEXP.
5397              SEC
5398              SBC FACEXP
5399              STA FACEXP
5400              JSR MULDIV       ; FIX UP EXPONENTS.
5401              INC FACEXP       ; SCALE IT RIGHT.
5402              BEQ GOOVER       ; OVERFLOW.
5403              LDX #256-3-ADDPRC; SETUP PROCEDURE.
5404              LDA #1
5405      DIVIDE:                  ; THIS IS THE BEST CODE IN THE WHOLE PILE.
5406              LDY ARGHO        ; SEE WHAT RELATION HOLDS.
5407              CPY FACHO
5408              BNE SAVQUO       ; [C]=0,1. N(C=0)=0.
5409 .IF ADDPRC
5410 |            LDY ARGMOH
5411 |            CPY FACMOH
5412 |            BNE SAVQUO
     .ENDIF
5413              LDY ARGMO
5414              CPY FACMO
5415              BNE SAVQUO
5416              LDY ARGLO
5417              CPY FACLO
5418      SAVQUO: PHP
5419              ROL              ; SAVE RESULT.
5420              BCC QSHFT        ; IF NOT DONE, CONTINUE.
5421              INX
5422              STA RESLO,X
5423              BEQ LD100
5424              BPL DIVNRM       ; NOTE THIS REQ 1 MO RAM THEN NECESS.
5425              LDA #1
5426      QSHFT:  PLP              ; RETURN CONDITION CODES.
5427              BCS DIVSUB       ; FAC .LE. ARG.
5428      SHFARG: ASL ARGLO        ; SHIFT ARG ONE PLACE LEFT.
5429              ROL ARGMO
5430 .IF ADDPRC
5431 |            ROL ARGMOH
     .ENDIF
5432              ROL ARGHO
5433              BCS SAVQUO       ; SAVE A RESULT OF ONE FOR THIS POSITION
5434 ; AND DIVIDE.
5435              BMI DIVIDE       ; IF MSB ON, GO DECIDE WHETHER TO SUB.
5436              BPL SAVQUO
5437      DIVSUB: TAY              ; NOTICE C MUST BE ON HERE.
5438              LDA ARGLO
5439              SBC FACLO
5440              STA ARGLO
5441              LDA ARGMO
5442              SBC FACMO
5443              STA ARGMO
5444 .IF ADDPRC
5445 |            LDA ARGMOH
5446 |            SBC FACMOH
5447 |            STA ARGMOH
     .ENDIF
5448              LDA ARGHO
5449              SBC FACHO
5450              STA ARGHO
5451              TYA
5452              JMP SHFARG
5453      LD100:  LDA #$40         ; ONLY WANT TWO MORE BITS.
5454              BNE QSHFT        ; ALWAYS BRANCHES.
5455      DIVNRM: .REPEAT 6        ; GET LAST TWO BITS INTO MSB AND B6.
                   ASL
                  .REPEND
5456              STA FACOV
5457              PLP              ; TO GET GARBAGE OFF STACK.
5458              JMP MOVFR        ; MOVE RESULT INTO FAC, THEN
5459                               ; NORMALIZE RESULT AND RETURN.
5460      DV0ERR: LDX #ERRDV0
5461              JMP ERROR

5462 ; PAGE
5463 ; SUBTTL     FLOATING POINT MOVEMENT ROUTINES.

5464              ; MOVE RESULT TO FAC.
5465      MOVFR:  LDA RESHO
5466              STA FACHO
5467 .IF ADDPRC
5468 |            LDA RESMOH
5469 |            STA FACMOH
     .ENDIF
5470              LDA RESMO
5471              STA FACMO
5472              LDA RESLO        ; MOVE LO AND SGN.
5473              STA FACLO
5474              JMP NORML        ; ALL DONE.
5475
5476              ; MOVE MEMORY INTO FAC (UNPACKED).
5477      MOVFM:  STWD INDEX1
5478              LDY #3+ADDPRC
5479              LDA (INDEX1),Y
5480              STA FACLO
5481              DEY
5482              LDA (INDEX1),Y
5483              STA FACMO
5484              DEY
5485 .IF ADDPRC
5486 |            LDA (INDEX1),Y
5487 |            STA FACMOH
5488 |            DEY
     .ENDIF
5489              LDA (INDEX1),Y
5490              STA FACSGN
5491              ORA #$80
5492              STA FACHO
5493              DEY
5494              LDA (INDEX1),Y
5495              STA FACEXP       ; LEAVE SWITCHES SET ON EXP.
5496              STY FACOV
5497              RTS
5478
5499              ; MOVE NUMBER FROM FAC TO MEMORY.
5500      MOV2F:  LDX #TEMPF2
5501              SKIP2
5502      MOV1F:  LDX #TEMPF1
5503      MOVML:  LDY #0
5504              BEQ MOVMF        ; ALWAYS BRANCHES.
5505      MOVVF:  LDXY FORPNT
5506      MOVMF:  JSR ROUND
5507              STXY INDEX1
5508              LDY #3+ADDPRC
5509              LDA FACLO
5510              STA (INDEX),Y
5511              DEY
5512              LDA FACMO
5513              STA (INDEX),Y
5514              DEY
5515 .IF ADDPRC
5516 |            LDA FACMOH
5517 |            STA (INDEX),Y
5518 |            DEY
     .ENDIF
5519              LDA FACSGN       ; INCLUDE SIGN IN HO.
5520              ORA #$7F
5521              AND FACHO
5522              STA (INDEX),Y
5523              DEY
5524              LDA FACEXP
5525              STA (INDEX),Y
5526              STY FACOV        ; ZERO IT SINCE ROUNDED.
5527              RTS              ; [Y]=0.
5528
5529              ; MOVE ARG INTO FAC.
5530      MOVFA:  LDA ARGSGN
5531      MOVFA1: STA FACSGN
5532              LDX #4+ADDPRC
5533      MOVFAL: LDA ARGEXP-1,X
5534              STA FACEXP-1,X
5535              DEX
5536              BNE MOVFAL
5537              STX FACOV
5538              RTS
5539
5540              ; MOVE FAC INTO ARG.
5541      MOVAF:  JSR ROUND
5542      MOVEF:  LDX #5+ADDPRC
5543      MOVAFL: LDA FACEXP-1,X
5544              STA ARGEXP-1,X
5545              DEX
5546              BNE MOVAFL
5547              STX FACOV        ; ZERO IT SINCE ROUNDED.
5548      MOVRTS: RTS
5550      ROUND:  LDA FACEXP       ; ZERO?
5551              BEQ MOVRTS       ; YES. DONE ROUNDING.
5552              ASL FACOV        ; ROUND?
5553              BCC MOVRTS       ; NO. MSB OFF.
5554      INCRND: JSR INCFAC       ; YES, ADD ONE TO LSB(FAC).
5555              BNE MOVRTS       ; NO CARRY MEANS DONE.
5556              JMP RNDSHF       ; SQUEEZ MSB IN AND RTS.
5557                               ; NOTE [C]=1 SINCE INCFAC DOESNT TOUCH C.
5558 ; PAGE
5559 ; SUBTTL     SIGN, SGN, FLOAT, NEG, ABS.
5560
5561              ; PUT SIGN OF FAC IN ACCA.
5562      SIGN:   LDA FACEXP
5563              BEQ SIGNRT       ; IF NUMBER IS ZERO, SO IS RESULT.
5564      FCSIGN: LDA FACSGN
5565      FCOMPS: ROL
5566              LDA #$FF         ; ASSUME NEGATIVE.
5567              BCS SIGNRT
5568              LDA #1           ; GET +1.
5569      SIGNRT: RTS
5570
5571              ; SGN FUNCTION.
5572      SGN:    JSR SIGN
5573
5574              ; FLOAT THE SIGNED INTEGER IN ACCA.
5575      FLOAT:  STA FACHO        ; PUT [ACCA] IN HIGH ORDER.
5576              LDA #0
5577              STA FACHO+1
5578              LDX #$88         ; GET THE EXPONENT.
5579
5580              ; FLOAT THE SIGNED NUMBER IN FAC.
5581      FLOATS: LDA FACHO
5582              EOR #$FF
5583              ROL              ; GET COMP OF SIGN IN CARRY.
5584      FLOATC: LDA #0           ; ZERO [ACCA] BUT NOT CARRY.
5585              STA FACLO
5586 .IF ADDPRC
5587 |            STA FACMO
     .ENDIF
5588      FLOATB: STX FACEXP
5589              STA FACOV
5590              STA FACSGN
5591              JMP FADFLT
5592
5593              ; ABSOLUTE VALUE OF FAC.
5594      ABS:    LSR FACSGN
5595              RTS

5597 ; PAGE
5598 ; SUBTTL     COMPARE TWO NUMBERS.
5599             ; A=1  IF ARG .LT. FAC.
5600             ; A=0  IF ARG == FAC.
5601             ; A=-1 IF ARG .GT. FAC.
5602      FCOMP:  STA INDEX2
5603      FCOMPN: STY INDEX2+1
5604              LDY #0
5605              LDA (INDEX2),Y   ; HAS ARGEXP.
5606              INY              ; BUMP PNTR UP.
5607              TAX              ; SAVE A IN X AND RESET CODES.
5608              BEQ SIGN
5609              LDA (INDEX2),Y
5610              EOR FACSGN       ; SIGNS THE SAME.
5611              BMI FCSIGN       ; SIGNS DIFFER SO RESULT IS
5612                               ; SIGN OF FAC AGAIN.
5613      FOUTCP: CPX FACEXP
5614              BNE FCOMPC
5615              LDA (INDEX2),Y
5616              ORA #$80
5617              CMP FACHO
5618              BNE FCOMPC
5619              INY
5620 .IF ADDPRC
5621 |            LDA (INDEX2),Y
5622 |            CMP FACMOH
5623 |            BNE FCOMPC
5624 |            INY
     .ENDIF
5625              LDA (INDEX2),Y
5626              CMP FACMO
5627              BNE FCOMPC
5628              INY
5629              LDA #$7F
5630              CMP FACOV
5631              LDA (INDEX2),Y
5632              SBC FACLO        ; GET ZERO IF EQUAL.
5633              BEQ QINTRT
5634      FCOMPC: LDA FACSGN
5635              BCC FCOMPD
5636              EOR #$FF
5637      FCOMPD: JMP FCOMPS       ; A PART OF SIGN SETS ACCA UP.
5638
5639 ; PAGE
5640 ; SUBTTL     GREATEST INTEGER FUNCTION.

5641              ; QUICK GREATEST INTEGER FUNCTION.
5642              ; LEAVES INT(FAC) IN FACHO&MO&LO SIGNED.
5643              ; ASSUMES FAC .LT. 2^23 = 8388608
5644      QINT:   LDA FACEXP
5645              BEQ CLRFAC       ; IF ZERO, GOT IT.
5646              SEC
5647              SBC #8*ADDPRC+$98; GET NUMBER OF PLACES TO SHIFT.
5648              BIT FACSGN
5649              BPL QISHFT
5650              TAX
5651              LDA #$FF
5652              STA BITS         ; PUT 377 IN WHEN SHFTR SHIFTS BYTES.
5653              JSR NEGFCH       ; TRULY NEGATE QUANTITY IN FAC.
5654              TXA
5655      QISHFT: LDX #FAC
5656              CMP #256-7
5657              BPL QINT1        ; IF NUMBER OF PLACES .GE. 7
5658                               ; SHIFT 1 PLACE AT A TIME.
5659              JSR SHIFTR       ; START SHIFTING BYTES, THEN BITS.
5660              STY BITS         ; ZERO BITS SINCE ADDER WANTS ZERO.
5661      QINTRT: RTS
5662      QINT1:  TAY              ; PUT COUNT IN COUNTER.
5663              LDA FACSGN
5664              AND #$80         ; GET SIGN BIT.
5665              LSR FACHO        ; SAVE FIRST SHIFTED BYTE.
5666              ORA FACHO
5667              STA FACHO
5668              JSR ROLSHF       ; SHIFT THE REST.
5669              STY BITS         ; ZERO [BITS].
5670              RTS
5671
5672              ; GREATEST INTEGER FUNCTION.
5673      INT:    LDA FACEXP
5674              CMP #8*ADDPRC+$98
5675              BCS INTRTS       ; FORGET IT.
5676              JSR QINT
5677              STY FACOV        ; CLR OVERFLOW BYTE.
5678              LDA FACSGN
5679              STY FACSGN       ; MAKE FAC LOOK POSITIVE.
5680              EOR #$80         ; GET COMPLEMENT OF SIGN IN CARRY.
5681              ROL
5682              LDA #8*ADDPRC+$98
5683              STA FACEXP
5684              LDA FACLO
5685              STA INTEGR
5686              JMP FADFLT
5687      CLRFAC: STA FACHO        ; MAKE IT REALLY ZERO.
5688 .IF ADDPRC
     |            STA FACMOH
     .ENDIF
5689              STA FACMO
5690              STA FACLO
5691              TAY
5692      INTRTS: RTS

5693 ; PAGE
5694 ; SUBTTL     FLOATING POINT INPUT ROUTINE.

5695      ; NUMBER INPUT IS LEFT IN FAC.
5696      ; AT ENTRY [TXTPTR] POINTS TO THE FIRST CHARACTER IN A TEXT BUFFER.
5697      ; THE FIRST CHARACTER IS ALSO IN ACCA. FIN PACKS THE DIGITS
5698      ; INTO THE FAC AS AN INTEGER AND KEEPS TRACK OF WHERE THE
5699      ; DECIMAL POINT IS. [DPTFLG] TELL WHETHER A DP HAS BEEN
5700      ; SEEN. [DECCNT] IS THE NUMBER OF DIGITS AFTER THE DP.
5701      ; AT THE END [DECCNT] AND THE EXPONENT ARE USED TO
5702      ; DETERMINE HOW MANY TIMES TO MULTIPLY OR DIVIDE BY TEN
5703      ; TO GET THE CORRECT NUMBER.
5704      FIN:    LDY #0           ; ZERO FACSGN&SGNFLG.
5705              LDX #9+ADDPRC    ; ZERO EXP AND HO (AND MOH).
5706      FINZLP: STY DECCNT,X     ; ZERO MO AND LO.
5707              DEX              ; ZERO TENEXP AND EXPSGN
5708              BPL FINZLP       ; ZERO DECCNT, DPTFLG.
5709              BCC FINDGQ       ; FLAGS STILL SET FROM CHRGET.
5710              CMP #'-          ; A NEGATIVE SIGN?
5711              BNE QPLUS        ; NO, TRY PLUS SIGN.
5712              STX SGNFLG       ; IT'S NEGATIVE. (X=377).
5713              BEQ FINC         ; ALWAYS BRANCHES.
5714      QPLUS:  CMP #'+          ; PLUS SIGN?
5715              BNE FIN1         ; YES, SKIP IT.
5716      FINC:   JSR CHRGET
5717      FINDGQ: BCC FINDIG
5718      FIN1:   CMP #'.          ; THE DP?
5719              BEQ FINDP        ; NO KIDDING.
5720              CMP #'E          ; EXPONENT FOLLOWS.
5721              BNE FINE         ; NO.
5722              ; HERE TO CHECK FOR SIGN OF EXP.
5723              JSR CHRGET       ; YES. GET ANOTHER.
5724              BCC FNEDG1       ; IT IS A DIGIT. (EASIER THAN
5725                               ; BACKING UP POINTER.)
5726              CMP #MINUTK      ; MINUS?
5727              BEQ FINEC1       ; NEGATE.
5728              CMP #'-          ; MINUS SIGN?
5729              BEQ FINEC1
5730              CMP #PLUSTK      ; PLUS?
5731              BEQ FINEC
5732              CMP #'+          ; PLUS SIGN?
5733              BEQ FINEC
5734              BNE FINEC2
5735      FINEC1: RAR EXPSGN       ; TURN IT ON.
5736      FINEC:  JSR CHRGET       ; GET ANOTHER.
5737      FNEDG1: BCC FINEDG       ; IT IS A DIGIT.
5738      FINEC2: BIT EXPSGN
5739              BPL FINE
5740              LDA #0
5741              SEC
5742              SBC TENEXP
5743              JMP FINE1
5744      FINDP:  RAR DPTFLG
5745              BIT DPTFLG
5746              BVC FINC
5747      FINE:   LDA TENEXP
5748      FINE1:  SEC
5749              SBC DECCNT       ; GET NUMBER OF PLACES TO SHIFT.
5750              STA TENEXP
5751              BEQ FINQNG       ; NEGATE?
5752              BPL FINMUL       ; POSITIVE SO MULTIPLY.
5753      FINDIV: JSR DIV10
5754              INC TENEXP       ; DONE?
5755              BNE FINDIV       ; NO.
5756              BEQ FINQNG       ; YES.
5757      FINMUL: JSR MUL10
5758              DEC TENEXP       ; DONE?
5759              BNE FINMUL       ; NO
5760      FINQNG: LDA SGNFLG
5761              BMI NEGXQS       ; IF POSITIVE, RETURN.
5762              RTS
5763      NEGXQS: JMP NEGOP        ; OTHERWISE, NEGATE AND RETURN.
5765      FINDIG: PHA
5766              BIT DPTFLG
5767              BPL FINDG1
5768              INC DECCNT
5769      FINDG1: JSR MUL10
5770              PLA              ; GET IT BACK.
5771              SEC
5772              SBC #'0
5773              JSR FINLOG       ; ADD IT IN.
5774              JMP FINC
5776      FINLOG: PHA
5777              JSR MOVAF        ; SAVE FAC FOR LATER.
5778              PLA
5779              JSR FLOAT        ; FLOAT THE VALUE IN ACCA.
5780              LDA ARGSGN
5781              EOR FACSGN
5782              STA ARISGN       ; RESULTANT SIGN.
5783              LDX FACEXP       ; SET SIGNS ON THING TO ADD.
5784              JMP FADDT        ; ADD TOGETHER AND RETURN.
5785
5786              ; HERE PACK IN THE NEXT DIGIT OF THE EXPONENT.
5787              ; MULTIPLY THE OLD EXP BY 10 AND ADD IN THE NEXT
5788              ; DIGIT. NOTE: EXP OVERFLOW IS NOT CHECKED FOR.
5789      FINEDG: LDA TENEXP       ; GET EXP SO FAR.
     .IF !PET
5790 |            CMP #$0A         ; WILL RESULT BE .GE. 100?
5791 |            BCC MLEX10
5792 |            LDA #$64         ; GET 100.
5793 |            BIT EXPSGN
5794 |            BMI MLEXMI       ; IF NEG EXP, NO CHK FOR OVERR.
5795 |            JMP OVERR
     .ELSE
     |            CMP #$0C
     |            BCC MLEX10
     |            BIT EXPSGN
     |            BMI *+5
     |            JMP OVERR
     |            LDA #$0B
     .ENDIF
5796      MLEX10: ASL              ; MULT BY 2 TWICE
5797              ASL
5798              CLC              ; POSSIBLE SHIFT OUT OF HIGH.
5799              ADC TENEXP       ; LIKE MULTIPLYING BY FIVE.
5800              ASL              ; AND NOW BY TEN.
5801              CLC
5802              LDY #0
5803              ADC (TXTPTR),Y
5804              SEC
5805              SBC #'0
5806      MLEXMI: STA TENEXP       ; SAVE RESULT.
5807              JMP FINEC

5808 ; PAGE
5809 ; SUBTTL     FLOATING POINT OUTPUT ROUTINE.
5810
5811 .IF !ADDPRC
5812 |    NZ0999: .BYTE $91, $43, $4F, $F8          ; 99999.9499
5816 |    NZ9999: .BYTE $94, $74, $23, $F7          ; 999999.499
5820 |    NZMIL:  .BYTE $94, $74, $24, $00          ; 10^6
     .ENDIF
5824 .IF ADDPRC
5825 |    NZ0999: .BYTE $9B, $3E, $BC, $1F, $FD     ; 99999999.9499
5830 |    NZ9999: .BYTE $9E, $6E, $6B, $27, $FD+PET ; 999999999.499
5835 |    NZMIL:  .BYTE $9E, $6E, $6B, $28, $00     ; 10^9
     .ENDIF
5840              ; ENTRY TO LINPRT.
5841      INPRT:  LDWDI INTXT
5842              JSR STROU2
5843              LDA CURLIN+1
5844              LDX CURLIN
5845      LINPRT: STWX FACHO
5846              LDX #$90         ; EXPONENT OF 16.
5847              SEC              ; NUMBER IS POSITIVE.
5848              JSR FLOATC
5849              JSR FOUT
5850      STROU2: JMP STROUT       ; PRINT AND RETURN.
5852      FOUT:   LDY #1
     .IF !APPLE2
5853 |    FOUTC:  LDA #$20         ; PRINT SPACE IF POSITIVE.
5854 |            BIT FACSGN
5855 |            BPL FOUT1
5856 |            LDA #'-
     .ELSE
     |    FOUTC:  LDA #'-
     |            DEY
     |            BIT FACSGN
     |            BPL FOUTP
     |            INY
     .ENDIF
5857      FOUT1:  STA FBUFFR-1,Y   ; STORE THE CHARACTER.
5858      FOUTP:  STA FACSGN       ; MAKE FAC POS FOR QINT.
5859              STY FBUFPT       ; SAVE FOR LATER.
5860              INY
5861              LDA #'0          ; GET ZERO TO TYPE IF FAC=0.
5862              LDX FACEXP
5863              JEQ FOUT19
5864              LDA #0
5865              CPX #$80         ; IS NUMBER .LT. 1.0 ?
5866              BEQ FOUT37       ; NO.
5867              BCS FOUT7
5868      FOUT37: LDWDI NZMIL      ; MULTIPLY BY 10^6.
5869              JSR FMULT
5870              LDA #256-3*ADDPRC-6
5871      FOUT7:  STA DECCNT       ; SAVE COUNT OR ZERO IT.
5872      FOUT4:  LDWDI NZ9999
5873              JSR FCOMP        ; IS NUMBER .GT. 999999.499 ?
5874                               ; OR 999999999.499?
5875              BEQ BIGGES
5876              BPL FOUT9        ; YES. MAKE IT SMALLER.
5877      FOUT3:  LDWDI NZ0999
5878              JSR FCOMP        ; IS NUMBER .GT. 99999.9499 ?
5879                               ;  OR 99999999.9499?
5880              BEQ FOUT38
5881              BPL FOUT5        ; YES. DONE MULTIPLYING.
5882      FOUT38: JSR MUL10        ; MAKE IT BIGGER.
5883              DEC DECCNT
5884              BNE FOUT3        ; SEE IF THAT DOES IT.
5885                               ; THIS ALWAYS GOES.
5886      FOUT9:  JSR DIV10        ; MAKE IT SMALLER.
5887              INC DECCNT
5888              BNE FOUT4        ; SEE IF THAT DOES IT.
5889                               ; THIS ALWAYS GOES.
5891      FOUT5:  JSR FADDH        ; ADD A HALF TO ROUND UP.
5892      BIGGES: JSR QINT
5893              LDX #1           ; DECIMAL POINT COUNT.
5894              LDA DECCNT
5895              CLC
5896              ADC #3*ADDPRC+7  ; SHOULD NUMBER BE PRINTED IN E NOTATION?
5897                               ; IE, IS NUMBER .LT. .01 ?
5898              BMI FOUTPI       ; YES.
5899              CMP #3*ADDPRC+8  ; IS IT .GT. 999999 (999999999)?
5900              BCS FOUT6        ; YES. USE E NOTATION.
5901              ADC #$FF         ; NUMBER OF PLACES BEFORE DECIMAL POINT.
5902              TAX              ; PUT INTO ACCX.
5903              LDA #2           ; NO E NOTATION.
5904      FOUTPI: SEC
5905      FOUT6:  SBC #2           ; EFFECTIVELY ADD 5 TO ORIG EXP.
5906              STA TENEXP       ; THAT IS THE EXPONENT TO PRINT.
5907              STX DECCNT       ; NUMBER OF DECIMAL PLACES.
5908              TXA
5909              BEQ FOUT39
5910              BPL FOUT8        ; SOME PLACES BEFORE DEC PNT.
5911      FOUT39: LDY FBUFPT       ; GET POINTER TO OUTPUT.
5912              LDA #'.          ; PUT IN "."
5913              INY
5914              STA FBUFFR-1,Y
5915              TXA
5916              BEQ FOUT16
5917              LDA #'0          ; GET THE ENSUING ZERO.
5918              INY
5919              STA FBUFFR-1,Y
5920      FOUT16: STY FBUFPT       ; SAVE FOR LATER.
5921      FOUT8:  LDY #0
5922      FOUTIM: LDX #$80         ; FIRST PASS THRU, ACCX HAS MSB SET.
5923      FOUT2:  LDA FACLO
5924              CLC
5925              ADC FOUTBL+2+ADDPRC,Y
5926              STA FACLO
5927              LDA FACMO
5928              ADC FOUTBL+1+ADDPRC,Y
5929              STA FACMO
5930 .IF ADDPRC
5931 |            LDA FACMOH
5932 |            ADC FOUTBL+1,Y
5933 |            STA FACMOH
     .ENDIF
5934              LDA FACHO
5935              ADC FOUTBL,Y
5936              STA FACHO
5937              INX              ; IT WAS DONE YET ANOTHER TIME.
5938              BCS FOUT41
5939              BPL FOUT2
5940              BMI FOUT40
5941      FOUT41: BMI FOUT2
5942      FOUT40: TXA
5943              BCC FOUTYP       ; CAN USE ACCA AS IS.
5944              EOR #$FF         ; FIND 11.-[A].
5945              ADC #$0A         ; C IS STILL ON TO COMPLETE NEGATION.
5946                               ; AND WILL ALWAYS BE ON AFTER.
5947      FOUTYP: ADC #'0 -1       ; GET A CHARACTER TO PRINT.
5948              .REPEAT 3+ADDPRC ; BUMP POINTER UP.
                   INY
                  .REPEND
5949              STY FDECPT
5950              LDY FBUFPT
5951              INY              ; POINT TO PLACE TO STORE OUTPUT.
5952              TAX
5953              AND #$7F         ; GET RID OF MSB.
5954              STA FBUFFR-1,Y
5955              DEC DECCNT
5956              BNE STXBUF       ; NOT TIME FOR DP YET.
5957              LDA #'.
5958              INY
5959              STA FBUFFR-1,Y   ; STORE DP.
5960      STXBUF: STY FBUFPT       ; STORE PNTR FOR LATER.
5961              LDY FDECPT
5962      FOUTCM: TXA              ; COMPLEMENT ACCX
5963              EOR #$FF         ; COMPLEMENT ACCA.
5964              AND #$80         ; SAVE ONLY MSB.
5965              TAX
5966              CPY #FDCEND-FOUTBL
5967 .IF TIME
5968 |            BEQ FOULDY
5969 |            CPY #TIMEND-FOUTBL
     .ENDIF
5970              BNE FOUT2        ; CONTINUE WITH OUTPUT.
5971      FOULDY: LDY FBUFPT       ; GET BACK OUTPUT PNTR.
5972      FOUT11: LDA FBUFFR-1,Y   ; REMOVE TRAILING ZEROES.
5973              DEY
5974              CMP #'0
5975              BEQ FOUT11
5976              CMP #'.
5977              BEQ FOUT12       ; RUN INTO DP. STOP.
5978              INY              ; SOMETHING ELSE. SAVE IT.
5979      FOUT12: LDA #'+
5980              LDX TENEXP
5981              BEQ FOUT17       ; NO EXPONENT TO OUTPUT.
5982              BPL FOUT14
5983              LDA #0
5984              SEC
5985              SBC TENEXP
5986              TAX
5987              LDA #'-          ; EXPONENT IS NEGATIVE.
5988      FOUT14: STA FBUFFR-1+2,Y ; STORE SIGN OF EXP
5989              LDA #'E
5990              STA FBUFFR-1+1,Y ; STORE THE "E" CHARACTER.
5991              TXA
5992              LDX #'0 -1
5993              SEC
5994      FOUT15: INX              ; MOVE CLOSER TO OUTPUT VALUE.
5995              SBC #$0A         ; SUBTRACT 10.
5996              BCS FOUT15       ; NOT NEGATIVE YET.
5997              ADC #'0 +$0A     ; GET SECOND OUTPUT CHARACTER.
5998              STA FBUFFR-1+4,Y ; STORE HIGH DIGIT.
5999              TXA
6000              STA FBUFFR-1+3,Y ; STORELOW DIGIT.
6001              LDA #0           ; PUT IN TERMINATOR.
6002              STA FBUFFR-1+5,Y
6003              BEQA FOUT20      ; RETURN. (ALWAYS BRANCHES).
6004      FOUT19: STA FBUFFR-1,Y   ; STORE THE CHARACTER.
6005      FOUT17: LDA #0           ; A TERMINATOR.
6006              STA FBUFFR-1+1,Y
6007      FOUT20: LDWDI FBUFFR
6008      FPWRRT: RTS              ; ALL DONE.
6009      FHALF:  .BYTE $80, 0     ; 1/2
     .IF !(OSI+PET)                ; OSI and PET use CON_ZERO
6011 |    ZERO:
     .ENDIF
                  .BYTE 0, 0
6013 .IF ADDPRC
     |    .BYTE 0
     .ENDIF
6015 ; POWER OF TEN TABLE
6016 .IF !ADDPRC
6017 |    FOUTBL:
     |    .BYTE $FE, $79, $60      ; -100000
6020 |    .BYTE $00, $27, $10      ;   10000
6023 |    .BYTE $FF, $FC, $18      ;   -1000
6026 |    .BYTE $00, $00, $64      ;     100
6029 |    .BYTE $FF, $FF, $F6      ;     -10
6032 |    .BYTE $00, $00, $01      ;       1
     .ENDIF
6036 .IF ADDPRC
6037 |    FOUTBL:
     |    .BYTE $FA, $0A, $1F, $00 ; -100,000,000
6041 |    .BYTE $00, $98, $96, $80 ;   10,000,000
6045 |    .BYTE $FF, $F0, $BD, $C0 ;   -1,000,000
6049 |    .BYTE $00, $01, $86, $A0 ;      100,000
6053 |    .BYTE $FF, $FF, $D8, $F0 ;      -10,000
6057 |    .BYTE $00, $00, $03, $E8 ;        1,000
6061 |    .BYTE $FF, $FF, $FF, $9C ;         -100
6065 |    .BYTE $00, $00, $00, $0A ;           10
6069 |    .BYTE $FF, $FF, $FF, $FF ;           -1
     .ENDIF
6073      FDCEND:
6074 .IF TIME
6075 |    .BYTE $FF, $DF, $0A, $80 ; -2160000 FOR TIME CONVERTER.
6079 |    .BYTE $00, $03, $4B, $C0 ;   216000
6083 |    .BYTE $FF, $FF, $73, $60 ;   -36000
6087 |    .BYTE $00, $00, $0E, $10 ;     3600
6091 |    .BYTE $FF, $FF, $FD, $A8 ;     -600
6895 |    .BYTE $00, $00, $00, $3C ;       60
6099 |    TIMEND:
     .ENDIF

6101 ; PAGE
6102 ; SUBTTL     EXPONENTIATION AND SQUARE ROOT FUNCTION.

6103              ; SQUARE ROOT FUNCTION --- SQR(A)
6104              ; USE SQR(X)=X^.5
6105      SQR:    JSR MOVAF        ; MOVE FAC INTO ARG.
6106              LDWDI FHALF
6107              JSR MOVFM        ; PUT MEMORY INTO FAC.
6108                               ; LAST THING FETCHED IS FACEXP. INTO ACCX.
6109              ; JMP FPWRT      ;FALL INTO FPWRT.
6110
6111              ; EXPONENTIATION ---  X^Y.
6112              ; N.B.  0^0=1
6113              ; FIRST CHECK IF Y=0. IF SO, THE RESULT IS 1.
6114              ; NEXT CHECK IF X=0. IF SO THE RESULT IS 0.
6115              ; THEN CHECK IF X.GT.0. IF NOT CHECK THAT Y IS AN INTEGER.
6116              ; IF SO, NEGATE X, SO THAT LOG DOESN'T GIVE FCERR.
6117              ; IF X IS NEGATIVE AND Y IS ODD, NEGATE THE RESULT
6118              ; RETURNED BY EXP.
6119              ; TO COMPUTE THE RESULT USE X^Y=EXP((Y*LOG(X)).
6120      FPWRT:  BEQ EXP          ; IF FAC=0, JUST EXPONENTIATE THAT.
6121              LDA ARGEXP       ; IS X=0?
6122              BNE FPWRT1
6123              JMP ZEROF1       ; ZERO FAC.
6124      FPWRT1: LDXYI TEMPF3     ; SAVE FOR LATER IN A TEMP.
6125              JSR MOVMF
6126              ; Y=0 ALREADY. GOOD IN CASE NO ONE CALLS INT.
6127              LDA ARGSGN
6128              BPL FPWR1        ; NO PROBLEMS IF X.GT.0.
6129              JSR INT          ; INTEGERIZE THE FAC.
6130              LDWDI TEMPF3     ; GET ADDR OF COMPERAND.
6131              JSR FCOMP        ; EQUAL?
6132              BNE FPWR1        ; LEAVE X NEG. LOG WILL BLOW HIM OUT.
6133                               ; A=-1 AND Y IS IRRELEVANT.
6134              TYA              ; NEGATE X. MAKE POSITIVE.
6135              LDY INTEGR       ; GET EVENNESS.
6136      FPWR1:  JSR MOVFA1       ; ALTERNATE ENTRY POINT.
6137              TYA
6138              PHA              ; SAVE EVENNESS FOR LATER.
6139              JSR LOG          ; FIND LOG.
6140              LDWDI TEMPF3     ; MULTIPLY FAC TIMES LOG(X).
6141              JSR FMULT
6142              JSR EXP          ; EXPONENTIATE THE FAC.
6143              PLA
6144              LSR              ; IS IT EVEN?
6145              BCC NEGRTS       ; YES. OR X.GT.0.
6146              ; NEGATE THE NUMBER IN FAC.
6147      NEGOP:  LDA FACEXP
6148              BEQ NEGRTS
6149              COM FACSGN
6150      NEGRTS: RTS
6151
6152 ; PAGE
6153 ; SUBTTL     EXPONENTIATION FUNCTION.
6154            ; FIRST SAVE THE ORIGINAL ARGUMENT AND MULTIPLY THE FAC BY
6155            ; LOG2(E). THE RESULT IS USED TO DETERMINE IF OVERFLOW
6156            ; WILL OCCUR SINCE EXP(X)=2^(X*LOG2(E)) WHERE
6157            ; LOG2(E)=LOG(E) BASE 2. THEN SAVE THE INTEGER PART OF
6158            ; THIS TO SCALE THE ANSWER AT THE END. SINCE
6159            ; 2^Y=2^INT(Y)*2^(Y-INT(Y)) AND 2^INT(Y) IS EASY TO COMPUTE.
6160            ; NOW COMPUTE 2^(X*LOG2(E)-INT(X*LOG2(E)) BY
6161            ; P(LN(2)*(INT(X*LOG2(E))+1)-X) WHERE P IS AN APPROXIMATION
6162            ; POLYNOMIAL. THE RESULT IS THEN SCALED BY THE POWER OF 2
6163            ; PREVIOUSLY SAVED.
6165      LOGEB2: .BYTE $81, $38, $AA, $3B   ; LOG(E) BASE 2.
6169 .IF ADDPRC
     |    .BYTE $29
     .ENDIF
6171 .IF !ADDPRC
6172 |    EXPCON:
     |    .BYTE 6                       ; degree -1.
6173 |    .BYTE $74, $63, $90, $8C      ; 0.00021702255
6177 |    .BYTE $77, $23, $0C, $AB      ; 0.0012439688
6181 |    .BYTE $7A, $1E, $94, $00      ; 0.0096788410
6185 |    .BYTE $7C, $63, $42, $80      ; 0.055483342
6189 |    .BYTE $7E, $75, $FE, $D0      ; 0.24022984
6193 |    .BYTE $80, $31, $72, $15      ; 0.69314698
6197 |    .BYTE $81, $00, $00, $00      ; 1.0
     .ENDIF
6203 .IF ADDPRC
6204 |    EXPCON:
     |    .BYTE 7                       ; DEGREE-1
6205 |    .BYTE $71, $34, $58, $3E, $56 ; 0.000021498763697
6210 |    .BYTE $74, $16, $7E, $B3, $1B ; 0.00014352314036
6215 |    .BYTE $77, $2F, $EE, $E3, $85 ; 0.0013422634824
6220 |    .BYTE $7A, $1D, $84, $1C, $2A ; 0.0096140170119
6225 |    .BYTE $7C, $63, $59, $58, $0A ; 0.055505126860
6230 |    .BYTE $7E, $75, $FD, $E7, $C6 ; 0.24022638462
6235 |    .BYTE $80, $31, $72, $18, $10 ; 0.69314718608
6240 |    .BYTE $81, $00, $00, $00, $00 ; 1.0
     .ENDIF
6245
6246      EXP:
6247              LDWDI LOGEB2     ; MULTIPLY BY LOG(E) BASE 2.
6248              JSR FMULT
6249              LDA FACOV
6250              ADC #$50
6251              BCC STOLD
6252              JSR INCRND
6253      STOLD:  STA OLDOV
6254              JSR MOVEF        ; TO SAVE IN ARG WITHOUT ROUND.
6255              LDA FACEXP
6256              CMP #$88         ; IF ABS(FAC) .GE. 128, TOO BIG.
6257              BCC EXP1
6258      GOMLDV: JSR MLDVEX       ; OVERFLOW OR OVERFLOW.
6259      EXP1:   JSR INT
6260              LDA INTEGR       ; GET LOW PART.
6261              CLC
6262              ADC #$81
6263              BEQ GOMLDV       ; OVERFLOW OR OVERFLOW !!
6264              SEC
6265              SBC #1           ; SUBTRACT 1.
6266              PHA              ; SAVE A WHILE.
6267              LDX #4+ADDPRC    ; PREP TO SWAP FAC AND ARG.
6268      SWAPLP: LDA ARGEXP,X
6269              LDY FACEXP,X
6270              STA FACEXP,X
6271              STY ARGEXP,X
6272              DEX
6273              BPL SWAPLP
6274              LDA OLDOV
6275              STA FACOV
6276              JSR FSUBT
6277              JSR NEGOP        ; NEGATE FAC.
6278              LDWDI EXPCON
6279              JSR POLY
6280              CLR ARISGN       ; MULTIPLY BY POSITIVE 1.0.
6281              PLA              ; GET SCALE FACTOR.
6282              JSR MLDEXP       ; MODIFY FACEXP AND CHECK FOR OVERFLOW.
6283              RTS              ; HAS TO DO JSR DUE TO PULAS IN MULDIV.
6284
6285
6286 ; PAGE
6287 ; SUBTTL       POLYNOMIAL EVALUATOR AND THE RANDOM NUMBER GENERATOR.

6288              ; EVALUATE P(X^2)*X
6289              ; POINTER TO DEGREE IS IN [Y,A].
6290              ; THE CONSTANTS FOLLOW THE DEGREE.
6291              ; FOR X=FAC, COMPUTE:
6292              ;  C0*X+C1*X^3+C2*X^5+C3*X^7+...+C(N)*X^(2*N+1)
6293      POLYX:  STWD POLYPT      ; RETAIN POLYNOMIAL POINTER FOR LATER.
6294              JSR MOV1F        ; SAVE FAC IN FACTMP.
6295              LDA #TEMPF1
6296              JSR FMULT        ; COMPUTE X^2.
6297              JSR POLY1        ; COMPUTE P(X^2).
6298              LDWDI TEMPF1
6299              JMP FMULT        ; MULTIPLY BY FAC AGAIN.
6300
6301              ; POLYNOMIAL EVALUATOR.
6302              ; POINTER TO DEGREE IS IN [Y,A].
6303              ; COMPUTE:
6304              ;  C0+C1*X+C2*X^2+C3*X^3+C4*X^4+...+C(N-1)*X^(N-1)+C(N)*X^N.
6305      POLY:   STWD POLYPT
6306      POLY1:  JSR MOV2F        ; SAVE FAC.
6307              LDA (POLYPT),Y
6308              STA DEGREE
6309              LDY POLYPT
6310              INY
6311              TYA
6312              BNE POLY3
6313              INC POLYPT+1
6314      POLY3:  STA POLYPT
6315              LDY POLYPT+1
6316      POLY2:  JSR FMULT
6317              LDWD POLYPT      ; GET CURRENT POINTER.
6318              CLC
6319              ADC #4+ADDPRC
6320              BCC POLY4
6321              INY
6322      POLY4:  STWD POLYPT
6323              JSR FADD         ; ADD IN CONSTANT.
6324              LDWDI TEMPF2     ; MULTIPLY THE ORIGINAL FAC.
6325              DEC DEGREE       ; DONE?
6326              BNE POLY2
6327      RANDRT: RTS              ; YES.
6328
6329              ; PSEUDO-RANDOM NUMBER GENERATOR.
6330              ; IF ARG=0, THE LAST RANDOM NUMBER GENERATED IS RETURNED.
6331              ; IF ARG .LT. 0, A NEW SEQUENCE OF RANDOM NUMBERS IS
6332              ; STARTED USING THE ARGUMENT.
6333              ;    TO FORM THE NEXT RANDOM NUMBER IN THE SEQUENCE,
6334              ; MULTIPLY THE PREVIOUS RANDOM NUMBER BY A RANDOM CONSTANT
6335              ; AND ADD IN ANOTHER RANDOM CONSTANT. THE THEN HO
6336              ; AND LO BYTES ARE SWITCHED, THE EXPONENT IS PUT WHERE
6337              ; IT WILL BE SHIFTED IN BY NORMAL, AND THE EXPONENT IN THE FAC
6338              ; IS SET TO 200 SO THE RESULT WILL BE LESS THAN 1. THIS
6339              ; IS THEN NORMALIZED AND SAVED FOR THE NEXT TIME.
6340              ; THE HO AND LOW BYTES WERE SWITCHED SO THERE WILL BE A
6341              ; RANDOM CHANCE OF GETTING A NUMBER LESS THAN OR GREATER
6342              ; THAN .5 .
6343
6344      RMULZC: .BYTE $98, $35, $44, $7A
6348      RADDZC: .BYTE $68, $28, $B1, $46
6353      RND:    JSR SIGN         ; GET SIGN INTO ACCX.
6354 .IF REALIO != 3
6355 |            TAX              ; GET INTO ACCX, SINCE "MOVFM" USES ACCX.
     .ENDIF
6356              BMI RND1         ; START NEW SEQUENCE IF NEGATIVE.
6357 .IF REALIO == 3
6358 |            BNE QSETNR
6359 |            ; TIMERS ARE AT 9044(L0),45(HI),48(LO),49(HI) HEX.
6360 |            ; FIRST TWO ARE ALWAYS FREE RUNNING.
6361 |            ; SECOND PAIR IS NOT. LO IS FREER THAN HI THEN.
6362 |            ; SO ORDER IN FAC IS 44,48,45,49.
6363 |            LDA CQHTIM
6364 |            STA FACHO
6365 |            LDA CQHTIM+4
6366 |            STA FACMOH
6367 |            LDA CQHTIM+1
6368 |            STA FACMO
6369 |            LDA CQHTIM+5
6370 |            STA FACLO
6371 |            JMP STRNEX
     .ENDIF
6372      QSETNR: LDWDI RNDX       ; GET LAST ONE INTO FAC.
6373              JSR MOVFM
6374 .IF REALIO != 3
6375 |            TXA              ; FAC WAS ZERO?
6376 |            BEQ RANDRT       ; RESTORE LAST ONE.
     .ENDIF
6377              LDWDI RMULZC     ; MULTIPLY BY RANDOM CONSTANT.
6378              JSR FMULT
6379              LDWDI RADDZC
6380              JSR FADD         ; ADD RANDOM CONSTANT.
6381      RND1:   LDX FACLO
6382              LDA FACHO
6383              STA FACLO
6384              STX FACHO        ; REVERSE HO AND LO.
6385 .IF REALIO == 3
6386 |            LDX FACMOH
6387 |            LDA FACMO
6388 |            STA FACMOH
6389 |            STX FACMO
     .ENDIF
6390      STRNEX: CLR FACSGN       ; MAKE NUMBER POSITIVE.
6391              LDA FACEXP       ; PUT EXP WHERE IT WILL
6392              STA FACOV        ; BE SHIFTED IN BY NORMAL.
6393              LDA #$80
6394              STA FACEXP       ; MAKE RESULT BETWEEN 0 AND 1.
6395              JSR NORML        ; NORMALIZE.
6396              LDXYI RNDX
6397      GMOVMF: JMP MOVMF        ; PUT NEW ONE INTO MEMORY.
6398
6399 ; PAGE
6400 ; SUBTTL     SINE, COSINE AND TANGENT FUNCTIONS.

6401 .IF !KIMROM
6402 |            ; COSINE FUNCTION.
6403 |            ; USE COS(X)=SIN(X+PI/2)
6404 |    COS:    LDWDI PI2        ; PNTR TO PI/2.
6405 |            JSR FADD         ; ADD IT IN.
6406 |                             ; FALL INTO SIN.
6407 |
6408 |
6409 |            ; SINE FUNCTION.
6410 |            ; USE IDENTITIES TO GET FAC IN QUADRANTS I OR IV.
6411 |            ; THE FAC IS DIVIDED BY 2*PI AND THE INTEGER PART IS IGNORED
6412 |            ; BECAUSE SIN(X+2*PI)=SIN(X). THEN THE ARGUMENT CAN BE
6413 |            ; COMPARED WITH PI/2 BY COMPARING THE RESULT OF THE DIVISION
6414 |            ; WITH PI/2/(2*PI)=1/4.
6415 |            ; IDENTITIES ARE THEN USED TO GET THE RESULT IN QUADRANTS
6416 |            ; I OR IV. AN APPROXIMATION POLYNOMIAL IS THEN USED TO
6417 |            ; COMPUTE SIN(X).
6418 |    SIN:    JSR MOVAF
6419 |            LDWDI TWOPI      ; GET PNTR TO DIVISOR.
6420 |            LDX ARGSGN       ; GET SIGN OF RESULT.
6421 |            JSR FDIVF
6422 |            JSR MOVAF        ; GET RESULT INTO ARG.
6423 |            JSR INT          ; INTEGERIZE FAC.
6424 |            CLR ARISGN       ; ALWAYS HAVE THE SAME SIGN.
6425 |            JSR FSUBT        ; KEEP ONLY THE FRACTIONAL PART.
6426 |            LDWDI FR4        ; GET PNTR TO 1/4.
6427 |            JSR FSUB         ; COMPUTE 1/4-FAC.
6428 |            LDA FACSGN       ; SAVE SIGN FOR LATER.
6429 |            PHA
6430 |            BPL SIN1         ; FIRST QUADRANT.
6431 |            JSR FADDH        ; ADD 1/2 TO FAC.
6432 |            LDA FACSGN       ; SIGN IS NEGATIVE?
6433 |            BMI SIN2
6434 |            COM TANSGN       ; QUADRANTS II AND III COME HERE.
6435 |    SIN1:   JSR NEGOP        ; IF POSITIVE, NEGATE IT.
6436 |    SIN2:   LDWDI FR4        ; POINTER TO 1/4.
6437 |            JSR FADD         ; ADD IT IN.
6438 |            PLA              ; GET ORIGINAL QUADRANT.
6439 |            BPL SIN3
6440 |            JSR NEGOP        ; IF NEGATIVE, NEGATE RESULT.
6441 |    SIN3:   LDWDI SINCON
6442 |    GPOLYX: JMP POLYX        ; DO APPROXIMATION POLYNOMIAL.
6443 |
6444 |
6445 |            ; TANGENT FUNCTION.
6446 |    TAN:    JSR MOV1F        ; MOVE FAC INTO TEMPORARY.
6447 |            CLR TANSGN       ; REMEMBER WHETHER TO NEGATE.
6448 |            JSR SIN          ; COMPUTE THE SIN.
6449 |            LDXYI TEMPF3
6450 |            JSR GMOVMF       ; PUT SIGN INTO OTHER TEMP.
6451 |            LDWDI TEMPF1
6452 |            JSR MOVFM        ; PUT THIS MEMORY LOC INTO FAC.
6453 |            CLR FACSGN       ; START OFF POSITIVE.
6454 |            LDA TANSGN
6455 |            JSR COSC         ; COMPUTE COSINE.
6456 |            LDWDI TEMPF3     ; ADDRESS OF SINE VALUE.
6457 |    GFDIV:  JMP FDIV         ; DIVIDE SINE BY COSINE AND RETURN.
6458 |    COSC:   PHA
6459 |            JMP SIN1
6461 |    PI2:    .BYTE $81, $49, $0F, $DB-ADDPRC; PI/2
6465 |.IF ADDPRC
     ||   .BYTE $A2
     |.ENDIF
6466 |    TWOPI:  .BYTE $83, $49, $0F, $DB-ADDPRC; 2*PI.
6470 |.IF ADDPRC
     ||   .BYTE $A2
     |.ENDIF
6471 |    FR4:    .BYTE $7F, 0, 0, 0; 1/4
6475 |.IF ADDPRC
     ||   .BYTE 0
     |.ENDIF
6476 |.IF !ADDPRC
     ||   SINCON:
     ||   .BYTE 4                       ; DEGREE-1.
6477 ||   .BYTE $86, $1E, $D7, $FB      ;  39.710899
6481 ||   .BYTE $87, $99, $26, $65      ; -76.574956
6485 ||   .BYTE $87, $23, $34, $58      ;  81.602231
6489 ||   .BYTE $86, $A5, $5D, $E1      ; -41.341677
6493 ||   .BYTE $83, $49, $0F, $DB      ;   6.2831853
     |.ENDIF
6498 |.IF ADDPRC
6499 ||   SINCON:
     ||   .BYTE 5                       ; DEGREE-1.
6500 ||   .BYTE $84, $E6, $1A, $2D, $1B ; -14.381383816
6505 ||   .BYTE $86, $28, $07, $FB, $F8 ;  42.07777095
6510 ||   .BYTE $87, $99, $68, $89, $01 ; -76.704133676
6515 ||   .BYTE $87, $23, $35, $DF, $E1 ;  81.605223690
6520 ||   .BYTE $86, $A5, $5D, $E7, $28 ; -41.34170209
6525 ||   .BYTE $83, $49, $0F, $DA, $A2 ;   6.2831853070
     ||.IF !(APPLE2+KIM+PET)
6530 |||  .BYTE $A1, $54, $46, $8F, $13 ;   7.2362932E7
6535 |||  .BYTE $8F, $52, $43, $89, $CD ;   73276.2515
     ||.ELSE
     |||.IF !PET
     |||| .BYTE $A6, $D3, $C1, $C8, $D4 ; "Easter Egg: XOR #$87 and spelled
     |||| .BYTE $C8, $D5, $C4, $CE, $CA ; backwards is "MICROSOFT!"
     |||.ENDIF
     ||.ENDIF
     |.ENDIF
6536 |
6540 |; PAGE
6541 |; SUBTTL    ARCTANGENT FUNCTION.
6542 |            ; USE IDENTITIES TO GET ARG BETWEEN 0 AND 1 AND THEN USE AN
6543 |            ; APPROXIMATION POLYNOMIAL TO COMPUTE ARCTAN(X).
6544 |    ATN:    LDA FACSGN       ; WHAT IS SIGN?
6545 |            PHA              ; (MEANWHILE SAVE FOR LATER.)
6546 |            BPL ATN1
6547 |            JSR NEGOP        ; IF NEGATIVE, NEGATE FAC.
6548 |                             ; USE ARCTAN(X)=-ARCTAN(-X) .
6549 |    ATN1:   LDA FACEXP
6550 |            PHA              ; SAVE THIS TOO FOR LATER.
6551 |            CMP #$81         ; SEE IF FAC .GE. 1.0 .
6552 |            BCC ATN2         ; IT IS LESS THAN 1.
6553 |            LDWDI FONE       ; GET PNTR TO 1.0 .
6554 |            JSR FDIV         ; COMPUTE RECIPROCAL.
6555 |                             ; USE ARCTAN(X)=PI/2-ARCTAN(1/X) .
6556 |    ATN2:   LDWDI ATNCON     ; PNTR TO ARCTAN CONSTANTS.
6557 |            JSR POLYX
6558 |            PLA
6559 |            CMP #$81         ; WAS ORIGINAL ARGUMENT .LT. 1 ?
6560 |            BCC ATN3         ; YES.
6561 |            LDWDI PI2
6562 |            JSR FSUB         ; SUBTRACT ARCTAGN FROM PI/2.
6563 |    ATN3:   PLA              ; WAS ORIGINAL ARGUMENT POSITIVE?
6564 |            BPL ATN4         ; YES.
6565 |            JMP NEGOP        ; IF NEGATIVE, NEGATE RESULT.
6566 |    ATN4:   RTS              ; ALL DONE.
6568 |.IF !ADDPRC
6569 ||   ATNCON:
     ||   .BYTE 8                       ; DEGREE-1.
6570 ||   .BYTE $78, $3A, $C5, $37      ;  0.0028498896
6574 ||   .BYTE $7B, $83, $A2, $5C      ; -0.016068629
6578 ||   .BYTE $7C, $2E, $DD, $4D      ;  0.042691519
6582 ||   .BYTE $7D, $99, $B0, $1E      ; -0.075042945
6586 ||   .BYTE $7D, $59, $ED, $24      ;  0.10640934
6590 ||   .BYTE $7E, $91, $72, $00      ; -0.14203644
6594 ||   .BYTE $7E, $4C, $B9, $73      ;  0.19992619
6598 ||   .BYTE $7F, $AA, $AA, $53      ; -0.33333073
6602 ||   .BYTE $81, $00, $00, $00      ;  1.0
     |.ENDIF
6607 |.IF ADDPRC
6608 ||   ATNCON:
     ||   .BYTE 11                      ; DEGREE-1
6609 ||   .BYTE $76, $B3, $83, $BD, $D3 ; -0.0006847939119
6614 ||   .BYTE $79, $1E, $F4, $A6, $F5 ;  0.004850942156
6619 ||   .BYTE $7B, $83, $FC, $B0, $10 ; -0.01611170184
6624 ||   .BYTE $7C, $0C, $1F, $67, $CA ;  0.03420963805
6629 ||   .BYTE $7C, $DE, $53, $CB, $C1 ; -0.05427913276
6634 ||   .BYTE $7D, $14, $64, $70, $4C ;  0.07245719654
6639 ||   .BYTE $7D, $B7, $EA, $51, $7A ; -0.08980239538
6644 ||   .BYTE $7D, $63, $30, $88, $7E ;  0.1109324134
6649 ||   .BYTE $7E, $92, $44, $99, $3A ; -0.1428398077
6654 ||   .BYTE $7E, $4C, $CC, $91, $C7 ;  0.1999991205
6659 ||   .BYTE $7F, $AA, $AA, $AA, $13 ; -0.3333333157
6664 ||   .BYTE $81, $00, $00, $00, $00 ;  1.0
     |.ENDIF
     .ENDIF
6669 ; PAGE
6670 ; SUBTTL     SYSTEM INITIALIZATION CODE.
6671 ; RADIX 10             IN ALL NON-MATH-PACKAGE CODE.
6672 ; THIS INITIALIZES THE BASIC INTERPRETER FOR THE M6502 AND SHOULD BE
6673 ; LOCATED WHERE IT WILL BE WIPED OUT IN RAM IF CODE IS ALL IN RAM.
6674
6675 .IF !ROMSW
6676 |            DS 1             ; SO ZEROING AT TXTTAB DOESN'T PREVENT
6677 |                             ; RESTARTING INIT
     .ENDIF
6678      INITAT: INC CHRGET+7     ; INCREMENT THE WHOLE TXTPTR.
6679              BNE CHZGOT
6680              INC CHRGET+8
6681      CHZGOT: LDA 60000        ; A LOAD WITH AN EXT ADDR.
6682              CMP #':          ; IS IT A ":"?
6683              BCS CHZRTS       ; IT IS .GE. ":"
6684              CMP #$20         ; SKIP SPACES.
6685              BEQ INITAT
6686              SEC
6687              SBC #'0          ; ALL CHARS .GT. "9" HAVE RET'D SO
6688              SEC
6689              SBC #256-'0      ; SEE IF NUMERIC.
6690                               ; TURN CARRY ON IF NUMERIC.
6691                               ; ALSO, SET Z IF NULL.
6692      CHZRTS: RTS              ; RETURN TO CALLER.
6694      .BYTE 128, 79, 199, 82   ; LOADED OR FROM ROM.
6695                               ; THE INITIAL RANDOM NUMBER.
6698 .IF ADDPRC
     |    .BYTE 88+PET             ; PET is 1 higher here ... a bug ?
     .ENDIF
6699 .IF REALIO != 3
6700 |.IF !KIMROM & !APPLE2
6701 ||   TYPAUT: LDWDI AUTTXT
6702 ||           JSR STROUT
     |.ENDIF
     .ENDIF
6703      INIT:
6704 .IF (REALIO != 3) || PET
6705 |            LDX #255         ; MAKE IT LOOK DIRECT IN CASE OF
6706 |            STX CURLIN+1     ; ERROR MESSAGE.
     .ENDIF
6707 .IF (STKEND-511) && !PET
6708 |            LDX #STKEND-256
     .ENDIF
6709              TXS
6710 .IF (REALIO != 3)
6711 |            LDWDI INIT       ; ALLOW RESTART.
6712 |            STWD START+1
6713 |            STWD RDYJSR+1    ; RTS HERE ON ERRORS.
     .ENDIF
     .IF (KIM+OSI)
6714 |           LDWDI AYINT
6715 |           STWD ADRAYI
6716 |           LDWDI GIVAYF
6717 |           STWD ADRGAY
     .ENDIF
     .IF APPLE2
     |           JSR NORMAL
     |           LDA #$4C          ; JMP opcode for vectors:
     |           STA START
     |           STA RDYJSR
     |           STA JMPER
     |           STA USRPOK
     |           LDWDI FCERR
     |           STWD USRPOK+1
     .ENDIF
     .IF !APPLE2
6718 |            LDA #$4C         ; JMP INSTRUCTION.
6719 |.IF REALIO == 0              ; MAKE AN INST.
     ||           HRLI 1,$0200
     |.ENDIF
6721 |            STA START
6720 |.IF (REALIO != 3)
6722 ||           STA RDYJSR
6723 ||           STA JMPER
     |.ENDIF
6724 |.IF ROMSW
6725 ||           STA USRPOK
6726 ||           LDWDI FCERR
6727 ||           STWD USRPOK+1
     |.ENDIF
     |.IF !PET
6728 ||           LDA #LINLEN      ; THESE MUST BE NON-ZERO SO CHEAD WILL
6729 ||           STA LINWID       ; WORK AFTER MOVING A NEW LINE IN BUF
6730 ||                            ; INTO THE PROGRAM
6731 ||           LDA #NCMPOS
6732 ||           STA NCMWID
     |.ENDIF
     .ENDIF
6733              LDX #RNDX+4-CHRGET ; *** BUG *** it should be +1 more
6734      MOVCHG: LDA INITAT-1,X
6735              STA CHRGET-1,X   ; MOVE TO RAM.
     .IF APPLE2
     |            STX SPDBYT
     .ENDIF
6736              DEX
6737              BNE MOVCHG
     .IF !(APPLE2+OSI+KIM+PET)
6738 |            LDA #STRSIZ
6739 |            STA FOUR6
     .ELSE
     |.IF !(OSI+KIM+PET)
     ||           STX TRCFLG       ; clear trace flag
     |.ENDIF
     .ENDIF
6740              TXA              ; SET CONST IN RAM.
6741              STA BITS
6742 .IF EXTIO
6743 |            STA CHANNL
     .ENDIF
6744              STA LASTPT+1
6745 .IF NULCMD+PET
6746 |            STA NULCNT
     .ENDIF
     .IF OSI+PET
     |            STA TRMPOS
     .ENDIF
6747              PHA              ; PUT ZERO AT THE END OF THE STACK
6748                               ; SO FNDFOR WILL STOP
6749 .IF REALIO && !APPLE2
6750 |            STA CNTWFL       ; BE TALKATIVE.
     .ENDIF
6751 .IF BUFPAG && !APPLE2
6752 |            INX              ; MAKE [X]=1
6753 |            STX BUF-3        ; SET PRE-BUF BYTES NON-ZERO FOR CHEAD
6754 |            STX BUF-4
     .ENDIF
     .IF OSI+KIM+PET
     |            LDA #$03
     |            STA DSCLEN
     .ENDIF
     .IF OSI+PET
     |            LDA #44          ; see LINNUM: .BYTE 0, 44 in zero page
     |            STA LINNUM+1
     .ENDIF
6755 .IF !APPLE2
6756 |            JSR CRDO         ; TYPE A CR.
     .ENDIF
     .IF APPLE2
     |            LDA #3           ; Get 3 to set TSD Length:
     |            STA DSCLEN       ; Set Temporary String Descriptor Length
     |            JSR CRDO         ; Print a Carriage <Return> Character
     |                             ; Setup Fake Forward Link:
     |            LDA #$01         ; Initialize Input Line's Next Line Pointer
     |            STA BUF-3        ; Set Input Line's Next Line Pointer, High
     |            STA BUF-4        ; Set Input Line's Next Line Pointer, Low
     .ENDIF
6757              LDX #TEMPST
6758              STX TEMPPT       ; SET UP STRING TEMPORARIES.
6759 .IF (REALIO || LONGI) && !APPLE2
6760 |.IF REALIO != 3
6761 ||           LDWDI MEMORY
6762 ||           JSR STROUT
6763 ||           JSR QINLIN       ; GET A LINE OF INPUT.
6764 ||           STXY TXTPTR      ; READ THIS !
6765 ||           JSR CHRGET       ; GET THE FIRST CHARACTER.
6766 ||.IF !KIMROM
6767 |||          CMP #'A          ; IS IT AN "A"?
6768 |||          BEQ TYPAUT       ; YES TYPE AUTHOR'S NAME.
     ||.ENDIF
6769 ||           TAY              ; NULL INPUT?
6770 ||           BNE USEDE9       ; NO.
     |.ENDIF
6771 |.IF REALIO == 3
     ||.IF PET
     |||          LDA #0
     ||.ENDIF
6772 ||           LDY #RAMLOC/256
     |.ENDIF
6773 |.IF REALIO != 3
6774 ||.IF !ROMSW
6775 |||          LDWDI LASTWR     ; YES GET PNTR TO LAST WORD.
     ||.ENDIF
6776 ||.IF ROMSW
6777 |||          LDWDI RAMLOC
     ||.ENDIF
     |.ENDIF
6778 |.IF ROMSW && !(OSI+PET)
6779 ||           STWD TXTTAB      ; SET UP START OF PROGRAM LOCATION
     |.ENDIF
6780 |            STWD LINNUM
6781 |.IF (REALIO == 3) && !PET
6782 ||           TAY
     |.ENDIF
6783 |.IF (REALIO != 3) || PET
6784 ||           LDY #0
     |.ENDIF
6785 |    LOOPMM: INC LINNUM
6786 |            BNE LOOPM1
6787 |            INC LINNUM+1
6788 |.IF REALIO == 3
     ||.IF !PET
6789 |||          BMI USEDEC
     ||.ELSE
     |||          LDA LINNUM+1
     |||          CMP #$80
     |||          BEQ USEDEC
     ||.ENDIF
     |.ENDIF
6790 |    LOOPM1:                  ; PUT RANDOM INFO INTO MEM.
     |.IF OSI+KIM+PET
     ||           LDA #146
     |.ELSE
     ||           LDA #85
     |.ENDIF
6791 |            STA (LINNUM),Y
6792 |            CMP (LINNUM),Y   ; WAS IT SAVED?
6793 |            BNE USEDEC       ; NO. THAT IS END OF MEMORY.
6794 |            ASL              ; LOOKS LIKE IT. TRY ANOTHER.
6795 |            STA (LINNUM),Y
6796 |            CMP (LINNUM),Y   ; WAS IT SAVED?
6797 |.IF !OSI && (REALIO != 3)
6798 ||           BNE USEDEC       ; NO. THIS IS THE END.
     |.ENDIF
6800 |            BEQ LOOPMM
6801 |.IF REALIO == 2
6802 ||           BNE USEDEC
     ||.IF !OSI                    ; OSI ROM does not have these:
6803 |||          CMP 0            ; SEE IF HITTING PAGE 0
6804 |||          BNE LOOPMM
6805 |||          LDA #76
6806 |||          STA 0
6807 |||          BNEA USEDEC
     ||.ENDIF
     |.ENDIF
6808 |.IF REALIO != 3
6809 ||   USEDE9: JSR CHRGOT       ; GET CURRENT CHARACTER.
6810 ||           JSR LINGET       ; GET DECIMAL ARGUMENT.
6811 ||           TAY              ; MAKE SURE A TERMINATOR EXISTS.
6812 ||           BEQ USEDEC       ; IT DOES.
6813 ||           JMP SNERR        ; IT DOESN'T.
     |.ENDIF
6814 |    USEDEC: LDWD LINNUM      ; GET SIZE OF MEMORY INPUT.
6815 |    USEDEF:                  ; HIGHEST ADDRESS.
     .ENDIF
6816 .IF !(REALIO+LONGI)
6817 |            LDWDI 16190      ; A STRANGE NUMBER.
     .ENDIF
     ; Applesoft available RAM memory search /alloction routines
     .IF APPLE2
     |            LDA #<PRGMEM     ; Get Start of Program Memory, Low (=0)
     |            LDY #>PRGMEM     ; Get Start of Program Memory, High
     |            STA LINNUM       ; Set Memory Scan Pointer, Low,  for Zip!
     |            STY LINNUM+1     ; Set Memory Scan Pointer, High, for Paging
     |            LDY #$00         ; Set for Indirect Addressing of Mem Pages
     |   FNDMEM:  INC LINNUM+1     ; Increment Memory Scan Paging Pointer
     |            LDA (LINNUM),Y   ; Test first Byte on Page
     |            EOR #$FF         ; Invert Bits: Test if RAM|ROM|MT-RAM-SKT
     |            STA (LINNUM),Y   ; Can change RAM
     |            CMP (LINNUM),Y   ; Cannot change ROM/MT-RAM-SKT
     |            BNE MEMFND       ; ROM/MT-RAM-SKT found!
     |            EOR #$FF         ; Invert Bits: Put back in RAM as found
     |            STA (LINNUM),Y   ; Can change/fix RAM
     |            CMP (LINNUM),Y   ; Cannot change/fix ROM/MT-RAM-SKT
     |            BEQ FNDMEM       ; Test & Fix RAM until ROM/MT-RAM-SKT found
     |   MEMFND:  LDY LINNUM       ; Get Memory Scan Pointer, Low (=0)
     |            LDA LINNUM+1     ; Get Memory Scan Pointer, High
     |            AND #$F0         ; Keep High Nibble and Zero Low Nibble
     |            ; same as STWD MEMSIZ STWD FRETOP below,
     |            ; except STY/STA, not STA/STY
     |            STY MEMSIZ       ; Set End of String Space (HIMEM)
     |            STA MEMSIZ+1
     |            STY FRETOP       ; Set Top of Free Space
     |            STA FRETOP+1
     .ELSE
6818 |            STWD MEMSIZ      ; THIS IS THE SIZE OF MEMORY.
6819 |            STWD FRETOP      ; TOP OF STRINGS TOO.
     .ENDIF
     ;
     ; Teletype support of original Microsoft BASIC source code ... ancient.
     ; Applesoft uses none of that code, OSI does.
     ;
6820      TTYW:
6821 .IF !APPLE2 && [REALIO != 3]
6822 |.IF REALIO+LONGI
6823 ||           LDWDI TTYWID
6824 ||           JSR STROUT
6825 ||           JSR QINLIN       ; GET LINE OF INPUT.
6826 ||           STXY TXTPTR      ; READ THIS !
6827 ||           JSR CHRGET       ; GET FIRST CHARACTER.
6828 ||           TAY              ; TEST ACCA BUT DON'T AFFECT CARRY.
6829 ||           BEQ ASKAGN
6830 ||           JSR LINGET       ; GET ARGUMENT.
6831 ||           LDA LINNUM+1
6832 ||           BNE TTYW         ; WIDTH MUST BE .LT. 256.
6833 ||           LDA LINNUM
6834 ||           CMP #16          ; WIDTH MUST BE GREATER THAN 16.
6835 ||           BCC TTYW
6836 ||           STA LINWID       ; THAT IS THE LINE WIDTH.
6837 ||   MORCPS: SBC #CLMWID      ; COMPUTE POSITION BEYOND WHICH
6838 ||           BCS MORCPS       ; THERE ARE NO MORE FIELDS.
6839 ||           EOR #255
6840 ||           SBC #CLMWID-2
6841 ||           CLC
6842 ||           ADC LINWID
6843 ||           STA NCMWID
     |.ENDIF
6844 |    ASKAGN:
6845 |.IF !ROMSW
6846 ||.IF (REALIO+LONGI)
6847 |||          LDWDI FNS
6848 |||          JSR STROUT
6849 |||          JSR QINLIN
6850 |||          STXY TXTPTR      ; READ THIS !
6851 |||          JSR CHRGET
6852 |||          LDXYI INITAT     ; DEFAULT.
6853 |||          CMP #'Y
6854 |||          BEQ HAVFNS       ; SAVE ALL FUNCTIONS.
6855 |||          CMP #'A
6856 |||          BEQ OKCHAR       ; SAVE ALL BUT ATN.
6857 |||          CMP #'N
6858 |||          BNE ASKAGN       ; BAD INPUT.
6859 |||                           ; SAVE NOTHING.
6860 |||  OKCHAR: LDXYI FCERR
6861 |||          STXY ATNFIX      ; GET RID OF ATN FUNCTION.
6862 |||          LDXYI ATN        ; UNTIL WE KNOW THAT WE SHOULD DEL MORE.
6863 |||          CMP #'A
6864 |||          BEQ HAVFNS       ; JUST GET RID OF ATN.
6865 |||          LDXYI FCERR
6866 |||          STXY COSFIX      ; GET RID OF THE REST.
6867 |||          STXY TANFIX
6868 |||          STXY SINFIX
6869 |||          LDXYI COS        ; AND GET RID OF ALL BACK TO "COS".
6870 |||  HAVFNS:
     ||.ENDIF
6871 ||.IF !(REALIO+LONGI)
6872 |||          LDXYI INITAT-1   ; GET RID OF ALL UP TO "INITAT".
     ||.ENDIF
     |.ENDIF
     .ENDIF
6873 .IF ROMSW
6874 |            LDXYI RAMLOC
     .ENDIF
6875              STXY TXTTAB
6876              LDY #0
     .IF APPLE2
     |            STY AUTORUN      ; turn off AUTORUN flag
     .ENDIF
6877              TYA
6878              STA (TXTTAB),Y   ; SET UP TEXT TABLE.
6879              INC TXTTAB
6880 .IF (REALIO != 3) || PET
6881 |            BNE QROOM
6882 |            INC TXTTAB+1
     .ENDIF
6883      QROOM:  LDWD TXTTAB      ; PREPARE TO USE "REASON".
6884              JSR REASON
6885 .IF (REALIO == 3) && !PET
6886 |            LDWDI FREMES
6887 |            JSR STROUT
     .ENDIF
6888 .IF !APPLE2
6889 |            JSR CRDO
6890 |            LDA MEMSIZ       ; COMPUTE [MEMSIZ]-[VARTAB].
6891 |            SEC
6892 |            SBC TXTTAB
6893 |            TAX
6894 |            LDA MEMSIZ+1
6895 |            SBC TXTTAB+1
6896 |            JSR LINPRT       ; TYPE THIS VALUE.
6897 |            LDWDI WORDS      ; MORE BULLSHIT.
6898 |            JSR STROUT
     .ENDIF
     .IF !OSI
6899 |            JSR SCRTCH       ; SET UP EVERYTHING ELSE.
     .ENDIF
     ;
     ; The JSR SCRTCH above is the last instruction of the original Microsoft
     ; source code used by Applesoft. All the leftover original source code
     ; below until the ***APPLESOFT*** comment is unused.
     ;
6900 .IF REALIO == 3
6901 |            JMP READY
     .ENDIF
6902 .IF !APPLE2 && [REALIO != 3]
6903 |            LDWDI STROUT
6904 |            STWD  RDYJSR+1
     |.IF OSI
     ||           JSR SCRTCH
     |.ENDIF
6905 |            LDWDI READY
6906 |            STWD  START+1
6907 |            JMP  (START+1)
6909 |.IF !ROMSW || OSI
6910 ||   FNS:    .DC "WANT SIN-COS-TAN-ATN"
6911 ||   .BYTE 0
     |.ENDIF
6912 |.IF !KIMROM
6913 ||   AUTTXT: ACRLF
6914 ||   .BYTE 12                 ; ANOTHER LINE FEED.
6915 ||           .DC "WRITTEN "
     ||.IF !OSI
6916 |||          .DC "BY WEILAND & GATES"
6917 |||          ACRLF
     ||.ELSE                       ; OSI has a different message:
     |||          .DC "BY RICHARD W. WEILAND."
     |||          ACRLF
     ||.ENDIF
6918 ||           .BYTE 0
     |.ENDIF
6919 |    MEMORY: .DC "MEMORY SIZE"
6920 |    .BYTE 0
6921 |    TTYWID:
6922 |.IF !KIMROM
6923 ||           .DC "TERMINAL "
     |.ENDIF
6924 |            .DC "WIDTH"
6925 |    .BYTE 0
     .ENDIF
     .IF !APPLE2
6926 |     WORDS:  .DC " BYTES FREE"
6927 |.IF REALIO != 3
6928 ||            ACRLF
6929 ||            ACRLF
     |.ENDIF
6930 |.IF REALIO == 3
     ||.IF !PET
6931 |||   .BYTE $0D
6932 |||   .BYTE 0
     ||.ELSE
     |||   .BYTE $13
     ||.ENDIF
6933 ||    FREMES:
     |.ENDIF
6934 |.IF REALIO == 0
     ||            .DC "SIMULATED BASIC FOR THE 6502 V1.1"
     |.ENDIF
6935 |.IF REALIO == 1
     ||.IF KIM
     |||           .DC "MOS TECH 6502 BASIC V1.1"
     ||.ELSE
     |||           .DC "KIM BASIC V1.1"
     ||.ENDIF
     |.ENDIF
6936 |.IF REALIO == 2
     ||.IF OSI
     |||            .DC "OSI 6502 BASIC VERSION 1.0 REV 3.2"
     ||.ELSE
     |||            .DC "OSI 6502 BASIC VERSION 1.1"
     ||.ENDIF
     |.ENDIF
6937 |.IF REALIO == 3
     ||.IF !PET
     |||            .DC "### COMMODORE BASIC ###"
6938 |||            .BYTE $0D
6939 |||            .BYTE $0D
     ||.ELSE
     |||            .DC "*** COMMODORE BASIC ***"
     |||            .BYTE $11, $11, $11
     ||.ENDIF
     |.ENDIF
6940 |.IF REALIO == 4
     ||            .DC "APPLE BASIC V1.1"
     |.ENDIF
6941 |.IF REALIO == 5
     ||            .DC "STM BASIC V1.1"
     |.ENDIF
6942 |.IF REALIO != 3
6943 ||            ACRLF
     ||.IF OSI+KIM
6944 |||            .DC "COPYRIGHT 1977 BY MICROSOFT CO."
     ||.ELSE
6944 |||            .DC "COPYRIGHT 1978 MICROSOFT"
     ||.ENDIF
6945 ||            ACRLF
     |.ENDIF
6946 |     .BYTE 0
6947 |     LASTWR:
     |.IF !(OSI+KIM+PET)           ; none of these waste these 100 bytes
6948 ||            DS 100          ; SPACE FOR TEMP STACK.
     |.ENDIF
6949 |.IF !REALIO                  ; this reserves space for 6502 simulation
6950 ||            TSTACK DS 13600
     |.ENDIF
6952 |.IF (PASS == 2)              ; this was 'IF2', true in MACRO-10 pass #2
6953 ||            PURGE A,X,Y     ; tell MACRO-10 to delete symbols A, X, Y
     |.ENDIF
     .ENDIF

     ; =========================================================
     ; ======= End of the original Microsoft source code =======
     ; =========================================================

     .IF PET                       ; for sake of understanding and completeness
     |.include "pet1.tail"         ; of the above code, we include the patches
     .ENDIF                        ; PATCH1 to PATCH7 as found in PET BASIC 1.

     .IF APPLE2                    ; for APPLE II+ we want the whole ROM image,
     |.INCLUDE "applesoft.tail"    ; we add this 'tail' based on the annotated
     .ENDIF                        ; disassembly listing by James P. Davis

     .END ; =====================  E N D   O F   F I L E  =====================
