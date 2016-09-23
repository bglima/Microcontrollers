; PIC16F628A Configuration Bit Settings

; ASM source line config statements

#include "p16F628A.inc"

; CONFIG
; __config 0xFF18
 __CONFIG _FOSC_INTOSCIO & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _BOREN_OFF & _LVP_OFF & _CPD_OFF & _CP_OFF
  
	; Pre-writing data to EE memory, for test purporses
	ORG	0x2100
	DE	0x0A, "HelloWorld"
 
	; Start of code
	ORG	0x0000
	
; HEAPIFY FUNCTION VARIABLES
cAdd	EQU	0x20	; Current address of element
lAdd	EQU	0x21	; LeftC	  address of element
rAdd	EQU	0x22	; RightC  address of element
larger	EQU	0x23	; Largest index element
	
; BUILD MAX HEAP FUNCTION VARIABLES
index	EQU	0x24	; Current element index
size	EQU	0x25	; Size of Heap

; SWAP FUNCTION VARIABLES
temp	EQU	0x26	; Temporary variable

; GREAT FUNCTION VARIABLES
val1	EQU	0x27
val2	EQU	0x28
	
; EEPROM READ VARIABLES
maxB	EQU	0x29	; Max byte index of heap (size of heap)
curB	EQU	0x2A	; Current address
iniAdd	EQU	0x30	; Initial address of heap
	GOTO	setup	; Initial setup of code
	
clearf:	; Function that clears flags Z and C from STATUS
	BCF STATUS, Z
	BCF STATUS, C
	RETURN
	
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
	RRF	index, 1    ; Rotate index to right (divide by two). Store result in index
	
loopBMH: ; Main loop of buildMaxHeap
    
	DECFSZ	index, 1    ; If index is zero, stop.
	GOTO	loopBMH
	RETURN

heapify: ; Function that check which element is greater ammong addresses 
	 ; cAdd, rAdd and lAdd. Return the address of larger element
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

	DECF	maxB, W	; Decrement one from maxB (due to control byte in heap) and store in W
	MOVWF	size	; Size of HEAP
	
	CALL buildMH
	NOP
	
loop:	
	GOTO	loop
	
	END