; PIC16F628A Configuration Bit Settings

; ASM source line config statements

#include "p16F628A.inc"
#include compRegMacros.inc
#include compPointMacros.inc
    
; CONFIG
; __config 0xFF18
 __CONFIG _FOSC_INTOSCIO & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _BOREN_OFF & _LVP_OFF & _CPD_OFF & _CP_OFF
  
	; Pre-writing data to EE memory, for test purporses
	ORG	0x2100
	DE	0x0A, 24, 21, 23, 22, 36, 29, 30, 34, 28, 27 
	; Start of code
	ORG	0x0000
	
; HEAPIFY FUNCTION VARIABLES
cInd	EQU	0x2B	; Current index of element
cAdd	EQU	0x20	; Current address of element
lAdd	EQU	0x21	; LeftC	  address of element
rAdd	EQU	0x22	; RightC  address of element
largest	EQU	0x23	; Largest address of element
	
; BUILD MAX HEAP FUNCTION VARIABLES
iniHAdd	EQU	0x2C
index	EQU	0x24	; Current element index
size	EQU	0x25	; Size of Heap

; SWAP FUNCTION VARIABLES
temp1	EQU	0x26	; Temporary variable
temp2	EQU	0x2D

; GRGENERAL PURPOSEE FUNCTION VARIABLES
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

	BCF	STATUS, Z
	DECFSZ	index, 1    ; If index is zero, stop.
	GOTO	loopBMH
	
	; One last time!
	MOVLW	0x01
	MOVWF	cInd
	CALL	heapify
	
	RETURN

heapify: ; Function that check which element is greater ammong addresses 
	CALL	clearf
	
	MOVF	cInd, W
	MOVWF	lAdd	    ; Left child. Used for now as an index.
	MOVWF	rAdd	    ; Right child. Used for now as an index.
	ADDWF	iniHAdd, W  ; Adding iniHAddress to cInd in order to from cAdd
	MOVWF	cAdd	    ; Now, cAdd contains the address of cInd element

	
	MOVWF	largest	    ; Address of largest number initiate as cAdd
	
	; ---- LEFT CHILD INDEX -----
	RLF	lAdd, 1	    ; Rotate rAdd to left and store on its own
	
	; ---- PASS i*2 ALSO TO rAdd ---
	MOVF	lAdd, W
	MOVWF	rAdd
	; ---- THEN GO BACK TO lAdd ----
	BCF	STATUS, C
	CSLEF	lAdd, size  ; If index > Size, return
	RETURN
	; --- TRANSFORM INDEX INTO ADDRESS -----
	MOVF	iniHAdd, W
	ADDWF	lAdd, 1	    ; Adress = Index + InitialAddress
	CSGTP	lAdd, cAdd  ; If parent is largest, just go check rightChild
	GOTO	calcRightChild	
	MOVF	lAdd, W   ; If got here, leftChild is largest than parent
	MOVWF	largest

calcRightChild:
	; ---- RIGHT CHILD INDEX -----
	BCF	STATUS, C
	INCF	rAdd, 1
	CSLEF	rAdd, size  ; If index > size, return
	GOTO	compareLargestWithParent
	; --- TRANSFORM INDEX INTO ADDRESS ------
	MOVF	iniHAdd, W
	ADDWF	rAdd, 1	    ; Adress = Index + InitialAddress
	
	CSGTP	rAdd, largest	; If rChild is larger than largest, change largest variable
	GOTO	compareLargestWithParent
	MOVF	rAdd, W   ; If got here, rChild is largest
	MOVWF	largest

compareLargestWithParent:
	; Compare if largest address is different than cAdd
	CSNEF	largest, cAdd
	RETURN
	
largAndCAddDifferent:
	SWAPPP	largest, cAdd

; Call Heapify at next element
	MOVF	iniHAdd, W
	SUBWF	largest, W	
	MOVWF	cInd
	GOTO	heapify
    
	RETURN

rEEByte:		    ; Address to be read must be in W register. The result will override W.
	BANKSEL	EEADR
	MOVWF	EEADR	    ; Setting address W at EEPROM
	BSF	EECON1, RD  ; Enabling read
	MOVF	EEDATA, W   ; Moving result to W
	BANKSEL	PORTA
	RETURN	

rEEData:		    ; Read maxB bytes from EEPROM. curB is the current byte index. 
	MOVLW	iniAdd      ; Start to store values at iniAdd address
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
	
wEEByte:
	BSF	STATUS, RP0  ;Bank 1
	BSF	EECON1, WREN ;Enable write
	BCF	INTCON, GIE  ;Disable INTs.
	BTFSC	INTCON,GIE   ;See AN576
	GOTO	$-2
	MOVLW	0x55 ;
	MOVWF	EECON2	    ;Write 55h
	MOVLW	0xAA ;
	MOVWF	EECON2	    ;Write AAh
	BSF	EECON1,WR   ;Set WR bit
	 ;begin write
	BSF INTCON, GIE	    ;Enable INTs.
	BCF	STATUS, RP0 ;Bank 0
	RETURN

wEEData:
	BANKSEL	EEADR
	MOVLW	0x10
	MOVWF	EEADR
	BANKSEL PORTA
	MOVF	size, W	    ; Write size to frist byte
	BANKSEL EEADR
	MOVWF	EEDATA
	CALL	wEEByte	    ; Initiate writing
	
	BCF	STATUS, RP0 ; Bank0
	MOVLW	iniAdd	    ; Initial address
	MOVWF	FSR	
	MOVLW	0x11	    ; First data adress from EEPROM
	
	MOVWF	curB	    ; EEPROM address counter. Starts at 0x11
	ADDWF	size, W	    ; Max adress to be written to
	MOVWF	maxB	    ; Stores at maxB
	MOV
wEELoop:
	BCF	STATUS, RP0 ; Bank 0
	MOVF	curB, W
	BSF	STATUS, RP0 ; Bank 1
	MOVWF	EEADR	    ; Set EE address
	MOVF	INDF, W
	MOVWF	EEDATA	    ; Set EE data
	CALL	wEEByte
	
	BCF	STATUS, RP0
	INCF	FSR
	INCF	curB
	
	CSGEF	curB, maxB
	GOTO	wEELoop	
	
	RETURN

setup:
	BANKSEL	PORTA
	MOVLW	maxB	; Setting maxB as current pointer
	MOVWF	FSR
	MOVLW	0x00	; Read first address of EEPROM
	CALL	rEEByte	; Reading bytes max qnt to W
	MOVWF	INDF	; Moving value read to maxB address
	CALL	rEEData

	MOVF	maxB, W
	MOVWF	size	; Size of HEAP
	
	MOVLW	iniAdd
	MOVWF	iniHAdd
	DECF	iniHAdd, 1
	
	CALL	buildMH	
	CALL	wEEData	
	NOP
	
loop:	
	GOTO	loop
	
	END