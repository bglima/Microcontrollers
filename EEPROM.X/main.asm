; PIC16F628A Configuration Bit Settings

; ASM source line config statements

#include "p16F628A.inc"

; CONFIG
; __config 0xFF18
 __CONFIG _FOSC_INTOSCIO & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _BOREN_OFF & _LVP_OFF & _CPD_OFF & _CP_OFF
  
	; Pre-writing data to EE memory, for test purporses
	ORG	0x2100
	DE	0x0A, "123456789A"
 
	; Start of code
	ORG	0x0000
	
; HEAPIFY FUNCTION VARIABLES
cInd	EQU	0x2B	; Current index of element
cAdd	EQU	0x20	; Current address of element
lAdd	EQU	0x21	; LeftC	  address of element
rAdd	EQU	0x22	; RightC  address of element
larger	EQU	0x23	; Largest address of element
	
; BUILD MAX HEAP FUNCTION VARIABLES
iniHAdd	EQU	0x2C
index	EQU	0x24	; Current element index
size	EQU	0x25	; Size of Heap

; SWAP FUNCTION VARIABLES
temp1	EQU	0x26	; Temporary variable
temp2	EQU	0x2D

; GREAT FUNCTION VARIABLES
val1	EQU	0x27
val2	EQU	0x28
	
; EEPROM READ VARIABLES
maxB	EQU	0x29	; Max byte index of heap (size of heap)
curB	EQU	0x2A	; Current address
iniAdd	EQU	0x30	; Initial address of heap
	GOTO	setup	; Initial setup of code
	
; "val1" and "val2" are the address of variables to be swapped
SWAPFF	macro	add1, add2
	MOVLW	add1
	MOVWF	FSR
	MOVF	INDF, W
	MOVWF	temp1	; variable from val1 to temp	
	
	MOVLW	add2
	MOVWF	FSR
	MOVF	INDF, W	
	MOVWF	temp2	; variable from val2 to temp
	
	MOVF	temp1, W
	MOVWF	INDF	; temp1 to val2
	MOVLW	add1
	MOVWF	FSR
	MOVF	temp2, W
	MOVWF	INDF	; temp2 to val1	
	ENDM

; Read value from address "add" to W
READF	macro	add
	MOVLW	add
	MOVWF	FSR
	MOVF	INDF, W
	ENDM
	
clearf:	; Function that clears flags Z and C from STATUS
	BCF STATUS, Z
	BCF STATUS, C
	RETURN
	
diff:	; Function that returns if val1 and value2 are equal
	; Uses registers val1 and val2 (as input) and register W (as output)
	CALL	clearf	    ; Clear flags before use it
	MOVF	val1, W
	SUBWF	val2, W
	BTFSC	STATUS, Z
	RETLW	0x01	    ; Values are equal
	BTFSC	STATUS, C
	RETLW	0x00	    ; Value2 is greater
	; val1IsGreater
	RETLW	0x00
	
great:	; Function that returns the greatest value among "cInd", "lInd" and "rInd"
	; Uses registers val1 and val2 (as input) and register W (as output)
	CALL	clearf	    ; Clear flags before use it
	MOVF	val1, W
	SUBWF	val2, W
	BTFSC	STATUS, Z
	RETLW	0x00	    ; Values are equal
	BTFSC	STATUS, C
	RETLW	0x00	    ; Value2 is greater
	; val1IsGreater
	RETLW	0x01

buildMH: ; buildMaxHeap function. Starts at node size/2 and goes back until it 
	; reaches the first node.
	; INDEX STARTS AT SIZE / 2 
	MOVF	size, W
	MOVWF	index
	BCF	index, 0    ; Clear LSB so that rotate does not set STATUS, C
	CALL	clearf	    ; Clear possible C flags
	RRF	index, 0    ; Rotate index to right (divide by two)
	MOVWF	index
	
loopBMH: ; Main loop of buildMaxHeap
	MOVF	index, W
	MOVWF	cInd
	CALL	heapify

	BSF	STATUS, Z
	DECFSZ	index, 1    ; If index is zero, stop.
	GOTO	loopBMH
	RETURN

heapify: ; Function that check which element is greater ammong addresses 
	 ; cAdd, rAdd and lAdd. Return the address of larger element
	MOVWF	cInd	    ; Storing current index
	MOVWF	cAdd	    ; Moving current index to cAdd
	
	
	ADDWF	iniHAdd, W
	MOVWF	cAdd	    ; Now, cAdd contains the address of cInd element

loopHY	; Left child
	CALL	clearf
	
	MOVF	cInd, W
	MOVWF	cAdd
	MOVWF	lAdd	    ; Left child
	MOVWF	rAdd	    ; Right child
	
	; Initiate cInd as larger
	MOVF	iniHAdd, W
	ADDWF	cAdd, 1
	MOVF	cAdd, W
	MOVWF	larger	    ; Address of larger number initiate as cAdd
	
	; Calculating left child address
	BCF	lAdd, 7	    ; Clean MSB so that rotate does not set STATUS, C
	RLF	lAdd, 1	    ; Rotate rAdd to left and store on its own
	; if lAdd (stil an index of leftChild)  is greater than size, stop
	MOVF	lAdd, W
	MOVWF	val1
	MOVF	size, W
	MOVWF	val2
	CALL	great
	BTFSC	W, 0   ; If W is equal to 1, return from here
	RETURN
	; Keep calculating address
	MOVF	iniHAdd, W
	ADDWF	lAdd, 1	    ; Calculating lChild address
	
	; Compare element of cAdd with element lAdd
	MOVF	cAdd, W	    ; val1
	MOVWF	FSR
	MOVF	INDF, W
	MOVWF	val1	    
	MOVF	lAdd, W	    ; val2
	MOVWF	FSR
	MOVF	INDF, W
	MOVWF	val2
	call	great  
	BTFSS	W, 0
	GOTO	lNotLarger
	
	MOVF	larger, W   ; If got here, lChild is larger
	MOVWF	FSR
	MOVF	val2, W
	MOVWF	INDF

lNotLarger:
	; Right child address
	BCF	rAdd, 7
	RLF	rAdd, 1
	INCF	rAdd, 1
	

	MOVF	iniHAdd, W
	ADDWF	rAdd, 1	    ; Calculating rChild address
	; check if rAdd (stil an index of rightChild)  is greater than size
	MOVF	rAdd, W
	MOVWF	val1
	MOVF	size, W
	MOVWF	val2
	CALL	great
	BTFSC	W, 0   ; If W is equal to 1, return from here
	GOTO	compareLarger
	
	; Compare element of rChild with element of Larger add
	MOVF	larger, W	    ; val1
	MOVWF	FSR
	MOVF	INDF, W
	MOVWF	val1	    
	MOVF	rAdd, W	    ; val2
	MOVWF	FSR
	MOVF	INDF, W
	MOVWF	val2
	call	great  
	BTFSS	W, 0
	GOTO	compareLarger
	
	MOVF	larger, W   ; If got here, lChild is larger
	MOVWF	FSR
	MOVF	val2, W
	MOVWF	INDF
	

compareLarger:
	; Compare if larger address is different than cAdd
	MOVF	larger, W
	MOVWF	val1
	MOVF	cAdd, W
	MOVWF	val2
	CALL	diff
	BTFSS	W, 0
	RETURN
	
largAndCAddDifferent:
	SWAPFF	larger, cAdd

; Call Heapify at next element
	MOVF	larger, W
	SUBWF	iniHAdd, 0
	MOVWF	cInd
	GOTO	loopHY
    
	RETURN

rEEByte:		    ; Address to be read must be in W register. The result will override W.
	BANKSEL	EEADR
	MOVWF	EEADR	    ; Setting address W at EEPROM
	BSF	EECON1, RD  ; Enabling read
	MOVF	EEDATA, W   ; Moving result to W
	BANKSEL	PORTA
	RETURN	

rEEData:		    ; Read maxB bytes from EEPROM. curB is the current byte index. 
	MOVLW	iniAdd      ; Start to store values at iniAdd addres = 0x22
	MOVWF	FSR	    ; indirect address starts at 0x22
	MOVLW	0x01	    ; byte index starts at 1
	MOVWF	curB	    ; first addres to be read from EEPROM

rEELoop:
	CALL	rEEByte
	MOVWF	INDF
	INCF	FSR	    ; Next RAM address to be filled
	INCF	curB	    ; Next byte index from EEPROM
	
	MOVF	maxB, W	    ; Max byte index read before stop 
	ADDLW	0x01	    ; Ofsset due two the first byte be used for control purposes (size)	 
	SUBWF	curB, W	    ; Subtract value from current index
	BTFSC	STATUS, Z   ; Check if zero
	RETURN
	MOVF	curB, W
	GOTO	rEELoop	

setup:
	BANKSEL	PORTA
	MOVLW	maxB	; Setting maxB as current pointer
	MOVWF	FSR
	MOVLW	0x00	; Read first address of EEPROM
	CALL	rEEByte	; Reading bytes max qnt to W
	MOVWF	INDF	; Moving value read to maxB address
	CALL	rEEData

	;DECF	maxB, W	; Decrement one from maxB (due to control byte in heap) and store in W
	MOVF	maxB, W
	MOVWF	size	; Size of HEAP
	
	MOVLW	iniAdd
	MOVWF	iniHAdd
	DECF	iniHAdd, 1
	
	CALL buildMH

	NOP

	
loop:	
	GOTO	loop
	
	END