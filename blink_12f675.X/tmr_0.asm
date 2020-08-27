; PIC12F675 Configuration Bit Settings

; Assembly source line config statements

#include "p12f675.inc"

; CONFIG
; __config 0x3185
 __CONFIG _FOSC_INTRCCLK & _WDTE_OFF & _PWRTE_ON & _MCLRE_OFF & _BOREN_OFF & _CP_OFF & _CPD_OFF
 
; PAGINA��O DE MEMORIA
 
 #DEFINE	BANK0	BCF STATUS,RP0	    ;BANCO 0 DE MEM�RIA
 #DEFINE	BANK1	BSF STATUS,RP0	    ;BANCO 1 DE MEMORIA
 
; CONSTANTES
 #DEFINE	TEMPO	D'005'		    ;FLAG DO TMR0
 
 ; VARI�VEIS
 
   CBLOCK   0X20			    ;INICIO MEM�RIA - REGISTRADORES DE USO GERAL 
   DECSEC				    ;100 MILISEGUNDOS
   CONT_100M				    ;TEMPO X 100 MILISEGUNDOS
   ENDC					    ;FIM DA ALOCA��O DE REGISTRADORES DE USO GERAL
   
 ; SA�DAS
 
 #DEFINE	LED1	GPIO,2		    ;SA�DA LED 1 NA PORTA 4
 #DEFINE	LED2	GPIO,0		    ;SAIDA LED 2 NA PORTA 2
 
 ; VETOR RESET
 
    ORG	    0X00			    ;
    GOTO    SETUP			    ;CONFIGURA��O INICIAL DOS REGISTRADORES
    
; VETOR DE INTERRUP��O    
    ORG	    0X04
    
    BTFSC   INTCON,2			    ;TESTA T0IF, PULA SE = A ZERO   
    CALL    DELAY			    ;CHAMA A FUN��O INVERTE
    
    RETFIE				    ;RETORNA DE INTERRUP��O
    
SETUP:    
        
    BANK1				    ;MOVE P/ O BANCO 1 DE MEMORIA
    
    MOVLW   0X00
    MOVWF   ANSEL			    ;DESABILITA I/O ANAL�GICO			    ;
    
    MOVLW   B'00000000'			    ;
    MOVWF   TRISIO			    ;CONFIG PORTAS 2 E 4 COMO SAIDAS
        
    MOVLW   B'10000001'			    ;
    MOVWF   OPTION_REG			    ;CONFIGURA O PRESCALER DO TMR0 (1:4)
    MOVLW   B'11100000'			    ;
    MOVWF   INTCON			    ;HABILITA O TMR0 NA INTCON
    
    BANK0				    ;VOLTA P/ O BANCO 0
    MOVLW   0X06			    ;MOVE 6H P/ WORK
    MOVWF   TMR0			    ;INICIALIZA O VALOR DO CONTADOR DO TMR0
    MOVLW   B'00000111'			    ;
    MOVWF   CMCON			    ;DESLIGA OS COMPARADORES
    MOVLW   B'00000001'			    ;
    MOVWF   GPIO			    ;INICIA COM O PINO 0 EM HIGH
    CLRF    DECSEC			    ;LIMPA A VARI�VEL MILISEC
    MOVLW   TEMPO			    ;MOVE O VALOR DE TEMPO P/ W
    MOVWF   CONT_100M			    ;MOVE O VALOR DE TEMPO P/ CONT_100M   
    
; ROTINA PRINCIPAL    
    
MAIN:

    
    GOTO    MAIN

INVERTE:    
    MOVLW   B'00000101'			    ;MASCARA P/ INVERS�O DOS PINOS
    XORWF   GPIO,F			    ;OU EXCLUSIVO, COMPARA E INVERTE OS PINOS 0 E 2
    RETURN
    
DELAY:					    ;ENTRA A CADA 1 MILISEG
    BCF	    INTCON,2			    ;LIMPA O BIT DA INTERRUP��O DO TMR0
    MOVLW   D'006'			    ;MOVE 6 DECIMAL P/ WORK
    MOVWF   TMR0			    ;INICIALIZA O VALOR DO CONTADOR DO TMR0 EM 6
    INCFSZ  DECSEC			    ;INCREMENTA DECSEG PULA A CADA 100 MILSEG
    RETURN       
    MOVLW   D'156'			    ;MOVE 156 DECIMAL P/ W
    MOVWF   DECSEC			    ;INICIALIZA MILISEC EM 6
    DECFSZ  CONT_100M			    ;DECREMENTA CONT_100M A CADA 100 MILSEC PULA QUANDO 0
    RETURN
    MOVLW   TEMPO			    ;MOVE O VALOR DE TEMPO P/ W
    MOVWF   CONT_100M			    ;MOVE O VALOR DE TEMPO P/ CONT_100M   
    CALL    INVERTE			    ;CHAMA A FUN��O INVERTE LED
    RETURN

    
    END
   
 


