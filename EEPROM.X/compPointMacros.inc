LOADPF	macro	add1, add2
	MOVF	add1, W
	MOVWF	FSR
	MOVF	INDF, W
	MOVWF	val1
	
	MOVF	add2, W
	MOVWF	FSR
	MOVF	INDF, W
	MOVWF	val2
	
	ENDM	
	
; Compare pointer elements from add1 and add2 skip if >
CSGTP macro	add1, add2
	LOADPF	add1, add2	    
	CSGTF	val1, val2
        endm

; Compare pointer elements from add1 and add2 skip if >=
CSGEP macro	add1, add2
	LOADPF	add1, add2	
	CSGEF	val1, val2
        endm

; Compare pointer elements from add1 and add2 skip if <
CSLTP macro	add1, add2
	LOADPF	add1, add2	
	CSLTF	val1, val2
        endm

; Compare pointer elements from add1 and add2 skip if <=
CSLEP macro	add1, add2
	LOADPF	add1, add2	
	CSLEF	val1, val2
        endm

; Compare pointer elements from add1 and add2 skip if <=
CSEQP macro	add1, add2
	LOADPF	add1, add2	
	CSEQF	val1, val2
        endm

; Compare pointer elements from add1 and add2 skip if <=
CSNEP macro	add1, add2
	LOADPF	add1, add2	
	CSNEF	val1, val2
        endm

; "add1" and "add2" are the pointers to variables to be swapped
SWAPPP	macro	add1, add2
MOVF	add1, W
MOVWF	FSR
MOVF	INDF, W
MOVWF	temp1	; variable from val1 to temp	

MOVF	add2, W
MOVWF	FSR
MOVF	INDF, W	
MOVWF	temp2	; variable from val2 to temp

MOVF	temp1, W
MOVWF	INDF	; temp1 to val2
MOVF	add1, W
MOVWF	FSR
MOVF	temp2, W
MOVWF	INDF	; temp2 to val1	
ENDM