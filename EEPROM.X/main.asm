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
	
cInd	EQU	0x20
lInd	EQU	0x21
rInd	EQU	0x22
cont	EQU	0x23
larg	EQU	0x24
temp	EQU	0x25 
size	EQU	0x26
	
maxB	EQU	0x30
curB	EQU	0x31
iniAdd	EQU	0x32	
	GOTO	setup
	
CLEARF	MACRO
	BCF STATUS, Z
	BCF STATUS, C
	ENDM
	
GREATEQ	MACRO	VAL1, VAL2
	CLEARF
	MOVF  VAL1, W
	SUBWF VAL2, W
	MOVLW 0x01	    ; Assume VAL1 >= VAL2
	BTFSC STATUS,C	    ; If VAL2 is greater... Return 0
	MOVLW 0x00
	BTFSC STATUS, Z	    ; If VAL1 is greater... Return 1
	MOVLW 0x01
	ENDM
	
GREAT	MACRO	VAL1, VAL2
	CLEARF
	MOVF  VAL1,w
	SUBWF VAL2,w
	MOVLW 0x01	    ; Assume value 1 is greater... Return 1
	BTFSC STATUS,C	    ; Values are equal...   Return 0
	MOVLW 0x00
	BTFSC STATUS,Z	    ; Values are equal...   Return 0
	MOVLW 0x00
	ENDM

HEAPIFY	MACRO	index
	MOVLW	index	    ; Currrent index
	MOVWF	cInd
	MOVLW	index*2	    ; Left child index
	MOVWF	lInd
	MOVLW	index*2 + 1 ; Right child idex
	MOVWF	rInd
	MOVF	maxB, W	    ; Size of array
	MOVWF	size
	
	GREAT	0x22, 0x21  ; Testing greater and greaterOrEq function
	MOVWF	cont
	ENDM

	
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

	HEAPIFY	1
	NOP
	
loop:	
	GOTO	loop
	
	END