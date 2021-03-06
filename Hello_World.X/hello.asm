
; PIC16F628A Configuration Bit Settings

; Assembly source line config statements

 #include "p16f628a.inc"

; CONFIG
; __config 0x3F79
 __CONFIG _FOSC_INTOSCCLK & _WDTE_OFF & _PWRTE_ON & _MCLRE_ON & _BOREN_ON & _LVP_OFF & _CPD_OFF & _CP_OFF
 
; PAGINA��O DE MEM�RIA
 
 #DEFINE    BANK0 BCF STATUS,RP0    ; SETA BANK P/ ZERO
 #DEFINE    BANK1 BSF STATUS,RP0    ; SETA BANK P/ UM
 
; VARI�VEIS
 
    CBLOCK	    0X20		    ; ENDERE�O INICIAL DA MEM�RIA DE USU�RIO
 
    ENDC				    ; FIM DAS VARI�VEIS
 
; ENTRADAS
 
 #DEFINE    BOTAO   PORTA,2	    ;

; SAIDAS
 
 #DEFINE    LED	    PORTB,0	    ;
 
; VETOR RESET
 
    ORG		0X00		    ;ENDERE�O INICIAL DO PROCESSAMENTO
    GOTO	INICIO
 
; INTERRUP��ES
 
    ORG		0X04		    ;ENDERE�O INICIAL DA INTERRUP��O
    RETFIE			    ;RETORNA DA INTERRUP��O
 
; INICIO DO PROGRAMA
 
INICIO
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
    
MAIN
    BTFSS   BOTAO		    ;PULA 1 LINHA SE O BOT�O ESTIVER EM 0
    GOTO    BOTAO_LIB
    GOTO    BOTAO_PRESS
    
BOTAO_LIB
    BCF	    LED			    ;APAGA O LED
    GOTO    MAIN 
   
BOTAO_PRESS
    BSF	    LED
    GOTO    MAIN
    
;FIM DO PROGRAMA
    
    END				    ;


