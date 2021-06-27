.MODEL SMALL 
.STACK 100H 
.DATA 

;The string to be printed 
StartMessage DB 'Simple Calculator( + , - , * , / , % )',0AH, '$'

.CODE 
;****************************************************************MAIN
MAIN PROC FAR 
MOV AX,@DATA 
MOV DS,AX 

; load address of the string 
LEA DX,StartMessage 

;output the string 
MOV AH,09H 
INT 21H 

CALL ReadBCD    ;read number 1 in BX, Operation in AL
PUSH BX         ;save read number
PUSH AX         ;operation in AL

CALL ReadBCD    ;read number 2 in BX

POP CX          ;operation
POP AX          ;number 1, number 2 in BX

CALL Math       ;result in AX
CALL PrintBin   ;Print AX

;interrupt to exit
MOV AH,4CH 
INT 21H 

MAIN ENDP 
;****************************************************************Functions

;AX,BX as input
;AX as output(Multi is AX,BX as output)
;CL as operate(+/*-%)
Math PROC 
    PUSH DX

    Operate:
        CMP CL,'+'
        JE Plus 
        CMP CL,'-' 
        JE Mines 
        CMP CL,'*'
        JE Multi 
        CMP CL,'/'
        JE Divid
        CMP CL,'%'
        JE Remain
        ;exit if not find
        MOV AX,0000H
        MOV BX,0000H
        JMP ExitMath

    Plus:
        ADD AX,BX
        JMP ExitMath

    Mines:
        SUB AX,BX
        JMP ExitMath
    
    Multi:
        Mul BX
        MOV BX,DX
        JMP ExitMath
    
    Divid:
        MOV DX,0000H 
        DIV BX 
        JMP ExitMath 
    
    Remain:
        MOV DX,0000H 
        DIV BX
        MOV AX,DX
        JMP ExitMath 

    ExitMath:
        POP DX 
        RET

Math ENDP

;return BX(number) and AL(last enter char)
ReadBCD PROC 
    PUSH CX 
    PUSH DX 
    MOV DX,0000H    ;result 
    MOV CX,0000H    ;counter
    MOV BX,0000H    ;mult temp
    Read:
        ;Read key from keyboard 
        MOV AH,01H
        INT 21H 

        CMP AL,'0'
        JB ExitReadBCD     ;return if below of 0
        CMP AL,'9'
        JA ExitReadBCD     ;return if above of 9

        SUB AL,30H
        MOV CH,00H 
        MOV CL,AL

        MOV DX,10D 
        MOV AX,BX
        MUL DX 

        ADD AX,CX
        MOV BX,AX   ;save result in BX

        JMP Read 
    
    ExitReadBCD:
        POP DX 
        POP CX
        RET 

ReadBCD ENDP

;AX as input(max 16bit)
;note: save the CX,SI,DX,AX
PrintBin proc
    PUSH AX 
    PUSH CX
    PUSH DX
    PUSH SI 
    mov cx,5
    mov si,10D

    DivTo10:
        mov dx,0000H
        div si  ;remain in dx
        push dx ;push to save digits
        loop DivTo10
    
    mov cx,5    ;print counter
    Print:
        POP dx  ;pop to load digits
        add dx,30H  ;change to ASCII
        ;interupt to show
        MOV AH,02H
        INT 21H
        ;/interupt to show
        LOOP Print  ;loop until end counter(cx)

    ;pop
        POP SI
        POP DX
        POP CX
        POP AX
        Ret
PrintBin ENDP

END MAIN 
