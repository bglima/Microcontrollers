; PIC16F628A Configuration Bit Settings
; ASM source line config statements
;
;   Para um delay de 20ms, com o clock em 48KHz ( simulador configurado em 12KHz ),
;   utilizamos os valores de timer_h e timer_l em 0xFF e 0xC9, respectivamente.
	
#include "p16F628A.inc"
__CONFIG _FOSC_INTOSCIO & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _BOREN_OFF & _LVP_OFF & _CPD_OFF & _CP_OFF
 
	ORG	0x0000	
	GOTO	setup
	
	ORG	0x0004		    ; Vetor de Interrup��o 	
	
	BTFSC	INTCON, RBIF	    ; A flag de interrup��o dos bot�es foi ativada?
	call 	button
	BTFSC	PIR1, TMR1IF	    ; A flag de interrup��o do timer overflow foi ativada?
	CALL	tout
	RETFIE			    ; Retorna da rotina de interrup��o	    

tout:
	BCF	PIR1, TMR1IF	     ; Limpe a flag de interrup��o do timer
	BCF	T1CON, TMR1ON	     ; Desative a interrup��o do timer
	BSF	INTCON, RBIE	     ; E re-ative a interrup��o dos bot�es
	RETURN
	
button:
	BTFSS	PORTB, RB6	    ; Quando o RB6 for apertado
	CALL	btn6		    ; Fa�a isso
	BTFSS	PORTB, RB7	    ; Quando o RB7 for apertado
	CALL	btn7		    ; Fa�a isso	 
	BCF	INTCON, RBIF	    ; Quando qualquer bot�o for apertado, limpe a flag de interrup��o deles
	RETURN	
	
btn6:	
	BTFSC	T1CON, TMR1ON	    ; Se o timer1 estiver rodando, apenas retorne e n�o fa�a nada     
	RETURN

	INCF	PORTB		    ; Do contr�rio, incremente PORTB
	
	MOVLW	0xFF		    ; Configure os valores no Timer1
	MOVWF	TMR1H		    ; 8 bits iniciais do TMR1 <0xA 0xB --- ----> 
	MOVLW	0xC9
	MOVWF	TMR1L		    ; 8 bits finais do TMR1   <--- ---  0xC  0xD>

	BCF	INTCON, RBIE	    ; Desabilite a interrup��o dos bot�es
	BCF	PIR1, TMR1IF
	BSF	T1CON, TMR1ON	    ; E habilite o timer1
        RETURN
	
btn7:	
	MOVLW	0x00		    ; Limpe a sa�da em PORTB
	MOVWF	PORTB
        RETURN
	
setup:
	BANKSEL	TRISB		    ; Selecionando BANK0
	MOVLW	b'11000000'	    ; RA7 e RA6 como entrada, demais como sa�da
	MOVWF	TRISB		    ; Seta PORTB para sa�da
	
	BANKSEL	OPTION_REG
	BCF	OPTION_REG, NOT_RBPU ; Ativa o pullup nas entradas do portb
	
	BANKSEL PORTB
	CLRF	PORTB	
	MOVLW	0x00		    ; Configure os valores no Timer1
	MOVWF	TMR1H		    ; 8 bits iniciais do TMR1 <0xA 0xB --- ----> 
	MOVLW	0x00
	MOVWF	TMR1L		    ; 8 bits finais do TMR1   <--- ---  0xC  0xD>	
				    
	BANKSEL INTCON
	MOVLW	b'11001000'	    ; Habilitando a interrup��o global, interrup��es perif�ricas e as interrup��es RB7:4
	MOVWF	INTCON		    ; Habilitando GIE, o PIE e o RBIE
	MOVLW	b'00101100'	    ; Bit 0 � o TMR1ON -> Inicia desligado. Para iniciar o contador, basta colocar pra 1.
				    ; NO PROTEUS FOI NECESSARIO DESABILITAR O OSCILADOR PARA O TIMER CONTAR
	MOVWF	T1CON	
				    
	BANKSEL PIE1		    ; BANK1
	BSF	PIE1, TMR1IE	    ; Ativa a interrup��o de overflow. A flag respons�vel pela interrup��o � o bit <BANK0> PIR1, TMR1IF		
	BCF	PCON, OSCF	    ; Setando clock interno para 48kHz
	
	BANKSEL PORTA
        BSF	PORTB, RB0

loop:	SLEEP
	GOTO loop
    
	END