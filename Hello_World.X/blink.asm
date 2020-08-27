
; PIC16F628A Configuration Bit Settings

; Assembly source line config statements

#include "p16f628a.inc"

; CONFIG
; __config 0x3F11
 __CONFIG _FOSC_INTOSCCLK & _WDTE_OFF & _PWRTE_ON & _MCLRE_OFF & _BOREN_OFF & _LVP_OFF & _CPD_OFF & _CP_OFF
; PAGINA��O DE MEM�RIA
 
 #DEFINE    BANK0 BCF STATUS,RP0    ; SETA BANK P/ ZERO
 #DEFINE    BANK1 BSF STATUS,RP0    ; SETA BANK P/ UM
 
; VARI�VEIS
 
    CBLOCK	    0X20		    ; ENDERE�O INICIAL DA MEM�RIA DE USU�RIO
    
    AUX1
    AUX2
 
    ENDC				    ; FIM DAS VARI�VEIS
 
; ENTRADAS
 
; #DEFINE    BOTAO   PORTA,2	    ;

; SAIDAS
 
 #DEFINE    LED1    PORTB,0	    ;
 #DEFINE    LED2    PORTB,2
 
; VETOR RESET
 
    ORG		0X00		    ;ENDERE�O INICIAL DO PROCESSAMENTO
    GOTO	INICIO
 
; INTERRUP��ES
 
    ORG		0X04		    ;ENDERE�O INICIAL DA INTERRUP��O
    RETFIE			    ;RETORNA DA INTERRUP��O
 
; INICIO DO PROGRAMA
 
INICIO:
    CLRF    PORTA		    ;LIMPA PORTA
    CLRF    PORTB		    ;LIMPA PORTB
    
    BANK1			    ;ALTERNA P/ O BANCO 1
    MOVLW   B'00000100'
    MOVWF   TRISA

    MOVLW   B'00000000'
    MOVWF   TRISB
    MOVLW   B'10000000'
    MOVWF   OPTION_REG		    ;PRESCALER 1:2 NO TMR0, PULL-UPS DESABILITADOS
    
    MOVLW   B'00000000'
    MOVWF   INTCON		    ;TODAS AS INTERRUP��ES DESLIGADAS
    BANK0
    MOVLW   B'00000111'
    MOVWF   CMCON		    ;DEFINE O MODO DE OPERA��O DO COMPARADOR
    
;    ROTINA PRINCIPAL
    
MAIN:
    BSF	    LED1		    ;ACENDE O LED1
    BCF	    LED2		    ;APAGA O LED2
    CALL    DELAY		    ;
    BCF	    LED1		    ;APAGA O LED1
    BSF	    LED2		    ;ACENDE O LED2
    CALL    DELAY
    
    GOTO    MAIN		    ;VOLTA PARA O INICIO
    
DELAY:    
    MOVLW   D'200'		    ;MOVE 200 DECIAMAL P/ WORK
    MOVWF   AUX1		    ;MOVE O CONTEUDO DE WORK P/ VAR AUX1
    
BACK1:
    MOVLW   D'250'		    ;MOVE 250 P/ WORK
    MOVWF   AUX2		    ;MOVE O CONTEUDO DE WORK P/ VAR AUX2
    
BACK2:
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    DECFSZ  AUX2		    ;DECREMENTA AUX2 PULA LINHA SE FOR ZERO
    GOTO    BACK2
    
    DECFSZ  AUX1		    ;DECREMENTA AUX1, PULA SE FOR ZERO
    GOTO    BACK1
    
    RETURN
    
;FIM DO PROGRAMA
    
    END				    ;


