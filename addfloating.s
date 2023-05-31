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
; EXAMPLE OF ASSEMBLY CODE   
	LDR R0, =0x42730000 ; two floating point numbers 
	LDR R1, =0xC2C81800
;R4,R5 = mantissa of a and b
;R6,R7 = exponent of a and b
;R9,R10= sign bit of a and b 
FlaPAdd
    push{R4,R5,R6,R7,R8,R9,R10,R11}
	LDR R2,=0x007fffff ;mantissa mask ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;mov did not work 
	MOV R3,0x7f800000 ;Exponent mask 
	MOV R11,0x80000000 ;sign mask 
	
	AND R4,R2,R0 ; get mantissa of a
	AND R5,R2,R1 ; get mantissa of b 
	ORR R4,R4,0x800000
	ORR R5,R5,0x800000 ; adding implicit leading 1
	
	AND R6,R3,R0 ; get exponent of a 
	AND R7,R3,R1 ; get exponent of b
	LSR R6,R6,#23; right shift exponent 
	LSR R7,R7,#23; right shift exponent 
	
	AND R9,R11,R0 ;extract sign of a 
	AND R10,R11,R1;extract dign of b
	
MATCH ; two numbers have the same exponent no shift needed 
    CMP R6,R7
	BEQ ADDMANTISSA
	BHI SHIFTB ; R6>R7 
SHIFTA ; R7>R6
    SUB R8,R7,R6
	ASR R4,R4,R8
	ADD R6,R6,R8
	B ADDMANTISSA
SHIFTB
    SUB R8,R6,R7
	ASR R5,R5,R8
	ADD R7,R7,R8
	
ADDMANTISSA
    CMP R9,R10 ; compare signs of both numbers 
	BNE SUBMANTISSA
	ADD R4,R4,R5
	MOV R12,R9 ; keep the sign 
	B NORMALIZE 
	
SUBMANTISSA
    CMP R4,R5 ; decide the greater of the two numbers 
	BGE ASUBB ;R4>R5
BSUBA ; R5>R4
    SUB R4,R5,R4
	MOV R12,R10 ;keep the sign of the greater
    B NORMALIZE
ASUBB
    SUB R4,R4,R5
	MOV R12,R9
	
NORMALIZE
    CMP R9,R10 ; compare signs of both numbers 
	BNE SUBNORMALIZE
	AND R5,R4,0x1000000;extract 25th bit----> overflow bit 
	CMP R5,#0 ;if zero no need to shift
	BEQ DONE 
	LSR R4,R4,#1 ; right shidt one position to normalize 
	ADD R6,R6,#1
	B DONE
SUBNORMALIZE
    AND R5,R4,0x800000 ; extract bit 24 
	CMP R5,0x800000 ; if bit 24 is equal to 1 ---> done shifting 
	BEQ DONE
	LSL R4,R4,#1
	SUB R6,R6,#1
	B SUBNORMALIZE
	
DONE 
   AND R4,R4,R2
   LSL R6,R6,#23
   ORR R0,R4,R6 
   ORR R0,R0,R12 ; add the sign bit 
   POP{R4,R5,R6,R7,R8,R9,R10,R11}
   MOV PC,LR
;=====================================================================  	
STOP
    B   STOP
	END