 .PROCESSOR 6502    

0001              ORG 0
0002 .IF 1
               NOP
0002 |  LAB0:  NOP
0003 | .LAB1: .DCX "CDE"
0004 | @LAB2: .DCX "A", "B" 
0005 | _LAB3:  NOP
0005 .ENDIF
;
        CPY0S   SET  LAB0
       .CPY1S   SET .LAB1
       @CPY2S   SET @LAB2
       _CPY3S   SET _LAB3

        CPY0E   EQU  LAB0
       .CPY1E   EQU .LAB1
       @CPY2E   EQU @LAB2
       _CPY3E   EQU _LAB3

        CPY0  =  LAB0
       .CPY1  = .LAB1
       @CPY2  = @LAB2
       _CPY3  = _LAB3
