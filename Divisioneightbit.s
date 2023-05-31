;====================================================================		
STACK0	EQU   0X00000100
	
	AREA  STACK, NOINIT, READWRITE, ALIGN=3
Stackmem SPACE 256
;====================================================================	
	AREA RESET, DATA, READONLY
	
	EXPORT  __Vectors

__Vectors
  
    DCD   Stackmem + STACK0     
	DCD   Reset_Handler	
		
	ALIGN	
;====================================================================	
	AREA  |.text|, CODE, READONLY, ALIGN=2
	ENTRY
;=====================================================================	
    EXPORT Reset_Handler
		
Reset_Handler		
;========================  Assembly Code =============================
;division function 4-bits
    SUB R8, R15, R15; 
    ADD R0,R8,#159 ; A
	ADD R1,R8,#50 ;B
Func PUSH {R4,R5,R6,R7,R10,R11,LR}
    MOV R4,R0
	MOV R5,R1
	MOV R6,#128 ; masking to get the 8th bit 
	MOV R11,#0
	MOV R10,#0 ; counter for the loop 
	MOV R7,#0 ;prepare the input for the next stage 
LOOP 
    CMP R10,#8
	BGE DONE 
    AND R0,R4,R6
	LSR R0,R0,#7 ; to make the bit be the least significant bit 
	ORR R0,R0,R7 ; concatinate bit 1:3 from the prev stage with the current bit from A 
	MOV R1,R5
	BL  Fstage
	MOV R7,R0
	LSL R11,R11,#1 ; keeping the quotient in R11 , need to invert 
	ORR R11,R12,R11 ;extract the q bit 
	LSL R4,R4,#1
	ADD R10,R10,#1
	B LOOP
DONE 
    LSR R0,R0,#1 ; contain remainder, R12 contain quotient
	MVN R11,R11;
    AND R1,R11,#255
	;MOV R1,R11;
	POP {R4,R5,R6,R7,R10,R11,LR}
	MOV PC,LR 
Fstage
    SUB R2,R0,R1
	MOV R12,0x00000100 ; Mask to extract the 9th bit
	AND R12,R12,R2 ; extract the 5th bit from the difference held in R2
	CMP R12,#0
	BNE SKIP
	MOV R0,R2
SKIP	
	LSL R0,R0,#1 
	LSR R12,R12,#8 ; get the bit 
	MOV PC, LR
;========================================================================
; TestBench 2

SUB R0, R15, R15; ;R0 = 0
ADD R1, R0, #20 ; store 5 numbers R1 = 20

BIC R3, R1, #7 ; R3 = 16
STR R3, [R0] ;

Loop: 
SUBS R12, R0, R1 ;R0 = 20
BGE Done
LDR R2, [R0]
ADD R2, R2, # 1
ADD R0, R0, # 4 
STR R2, [R0]
B Loop
Done SUB R0,R0,#4 ; R0 = 16
LDR R2, [R0] ; R2 = 20
ADD	R2,R2,#5; ; R2 = 25
ADD R0, R0, # 4 ; R0 = 20
STR R2, [R0] ; mem[20] = 25

;========================================================================
; TestBench  

MAIN 
SUB R0, R15, R15 ; R0 = 0
ADD R2, R0, #5 ; R2 = 5
ADD R3, R0, #12 ; R3 = 12
SUB R7, R3, #9 ; R7 = 3
ORR R4, R7, R2 ; R4 = 3 OR 5 = 7
AND R5, R3, R4 ; R5 = 12 AND 7 = 4
ADD R5, R5, R4 ; R5 = 4 + 7 = 11
SUBS R8, R5, R7 ; R8 = 11 - 3 = 8, set Flags
BEQ END ; shouldn't be taken
SUBS R8, R3, R4 ; R8 = 12 - 7 = 5
BGE 
AROUND ; should be taken
ADD R5, R0, #0 ; should be ski pped
AROUND 
SUBS R8, R7, R2 ; R8 = 3 - 5 = -2, set Flags
ADDLT R7, R5, #1 ; R7 = 11 + 1 = 12
SUB R7, R7, R2 ; R7 = 12 - 5 = 7
STR R7, [R3, #84] ; mem[12+84] = 7
LDR R2, [R0, #96] ; R2 = mem[96] = 7
BIC R12,R2, #1; ; R12 = 6 
EOR R2, R12, #13; ; R2 = 11
ADD R15, R15, #4 ; PC = PC+8 (skips next)
ADD R0, R15, #10; shouldn't happen
ADD R2, R0, #14 ; shouldn't happen
B END ; always taken
ADD R2, R0, #13 ; shouldn't happen
ADD R2, R0, #10 ; shouldn't happen
END 
STR R2, [R0, #100] ; mem[100] = 11

;=====================================================================
;; EXAMPLE OF ASSEMBLY CODE 
	;MOV R0, #0x3
;FACTORIAL PUSH {R0, LR} ; push n and LR on stack
	;CMP R0, #1 ; R0 <= 1?
	;BGT ELSE0 ; no: branch to else
	;MOV R0, #1 ; otherwise, return 1
	;ADD SP, SP, #8 ; restore SP
	;MOV PC, LR ; return
;ELSE0
	;SUB R0, R0, #1 ; n = n - 1
	;BL FACTORIAL ; recursive call
	;POP {R1, LR} ; pop n (into R1) and LR
	;MUL R0, R1, R0 ; R0 = n * factorial(n - 1)
	;MOV PC, LR ; return
;=====================================================================  	
STOP
    B   STOP
	END