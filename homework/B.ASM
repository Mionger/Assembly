DATA    SEGMENT  
A       DB      70H
B       DB      60H
C       DB      40H
D       DB      20H
S       DW      ?
Z       DB      05H
G1      DW      ?
G2      DW      ?
DATA    ENDS
CODE    SEGMENT
ASSUME  CS:CODE,DS:DATA
START:
        MOV     AX,DATA
        MOV     DS,AX

        MOV     AL,A
        IMUL    B
        MOV     G1,AX 

        MOV     CH,0
        MOV     CL,C       
        ADD     CL,D
        MOV     G2,CX

        MOV     DX,0
        IDIV    CX
        MOV     S,AX

        MOV     AL,A
        SUB     AL,B
        CBW
        IMUL    Z
        SAR     AX,1
        ADD     S,AX

        MOV     AL,D
        CBW
        MOV     BX,AX
        MOV     AL,C
        CBW
        MOV     DX,0
        IDIV    BX
        ADD     S,AX
                 
        MOV AX, 4C00H
        INT 21H
CODE    ENDS
        END START
