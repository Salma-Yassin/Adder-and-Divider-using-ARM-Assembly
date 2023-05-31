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
    MOV R0,#12
	MOV R1,#10
Func PUSH {R4,R5,R6,R7,R10,R11,LR}
    MOV R4,R0
	MOV R5,R1
	MOV R6,0x8
	MOV R11,#0
	MOV R10,#0 ; counter for the loop 
	MOV R7,#0 ;prepare the input for the next stage 
LOOP 
    CMP R10,#4
	BGE DONE 
    AND R0,R4,R6
	LSR R0,R0,#3
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
    AND R1,R11,#15
	;MOV R1,R11;
	POP {R4,R5,R6,R7,R10,R11,LR}
	MOV PC,LR 
Fstage
    SUB R2,R0,R1
	MOV R12,0x00000010 ; Mask to extract the 5th bit
	AND R12,R12,R2 ; extract the 5th bit from the difference held in R2
	CMP R12,#0
	BNE SKIP
	MOV R0,R2
SKIP	
	LSL R0,R0,#1 
	LSR R12,R12,#4 ; get the bit 
	MOV PC, LR
	
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