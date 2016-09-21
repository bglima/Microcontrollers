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
	
; BUILD MAX HEAP FUNCTION VARIABLES
index	EQU	0x23	; Current element index
larg	EQU	0x24	; Largest index element
size	EQU	0x25	; Total size of heap

; SWAP FUNCTION VARIABLES
temp	EQU	0x26	; Temporary variable

; GREAT FUNCTION VARIABLES
val1	EQU	0x27
val2	EQU	0x28
	
; EEPROM READ VARIABLES
maxB	EQU	0x30	; Max byte index of heap (size of heap)
curB	EQU	0x31	; Current address
iniAdd	EQU	0x32	; Initial address of heap
	GOTO	setup
	
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
	MOVLW	0x00	    ; byte index starts at 1
	MOVWF	curB	    ; first addres to be read from EEPROM

rEELoop:
	CALL	rEEByte
	MOVWF	INDF
	INCF	FSR	    ; Next RAM address to be filled
	INCF	curB	    ; Next byte index from EEPROM
	
	MOVF	maxB, W	    ; Max byte index read before stop 
	ADDLW	0x02	    ; Ofsset due two the first 2 bytes be used for control purposes	 
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

	; Testing great function call
	MOVLW	0x07
	MOVWF	val1
	MOVLW	0x06
	MOVWF	val2
	CALL	great
	NOP
	
loop:	
	GOTO	loop
	
	END