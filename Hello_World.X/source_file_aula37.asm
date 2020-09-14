;
; Curso de Assembly para PIC WR Kits Aula 37
;
;
; Interrup��o Externa
;
;
;
; Sistema Embarcado Sugerido: PARADOXUS PEPTO
;
; Dispon�vel em https://wrkits.com.br/catalog/show/141 
;
; Clock: 4MHz    Ciclo de m�quina = 1�s
;
; Autor: Eng. Wagner Rambo   Data: Julho de 2016
;
;

; --- Listagem do Processador Utilizado ---
;	list	p=16F628A						;Utilizado PIC16F628A
	
	
; --- Arquivos Inclusos no Projeto ---
#include "p16f628a.inc"
	
	
; --- FUSE Bits ---
; - Cristal de 4MHz
; - Desabilitamos o Watch Dog Timer
; - Habilitamos o Power Up Timer
; - Brown Out desabilitado
; - Sem programa��o em baixa tens�o, sem prote��o de c�digo, sem prote��o da mem�ria EEPROM
; - Master Clear Habilitado
 __CONFIG _FOSC_INTOSCCLK & _WDTE_OFF & _PWRTE_ON & _MCLRE_OFF & _BOREN_OFF & _LVP_OFF & _CPD_OFF & _CP_OFF
	
	
; --- Pagina��o de Mem�ria ---
	#define		bank0	bcf	STATUS,RP0		;Cria um mnem�nico para selecionar o banco 0 de mem�ria
	#define		bank1	bsf	STATUS,RP0		;Cria um mnem�nico para selecionar o banco 1 de mem�ria
	
	
; --- Mapeamento de Hardware (PARADOXUS PEPTO) ---
	#define		LED1	PORTA,3				;LED1 ligado ao pino RA3
	#define		LED2	PORTA,2				;LED2 ligado ao pino RA2

; --- Registradores de Uso Geral ---
	cblock		H'20'						;In�cio da mem�ria dispon�vel para o usu�rio
	
	W_TEMP									;Registrador para armazenar o conte�do tempor�rio de work
	STATUS_TEMP								;Registrador para armazenar o conte�do tempor�rio de STATUS
	counter1								;Registrador auxiliar para contagem
	counter2								;Registrador auxiliar para contagem	
	tempo0									;Registrador auxiliar para temporiza��o
	tempo1									;Registrador auxiliar para temporiza��o 
 
	endc									;Final da mem�ria do usu�rio
	

; --- Vetor de RESET ---
	org			H'0000'						;Origem no endere�o 00h de mem�ria
	goto		inicio						;Desvia para a label in�cio
	

; --- Vetor de Interrup��o ---
	org			H'0004'						;As interrup��es deste processador apontam para este endere�o
	
; -- Salva Contexto --
	movwf 		W_TEMP						;Copia o conte�do de Work para W_TEMP
	swapf 		STATUS,W  					;Move o conte�do de STATUS com os nibbles invertidos para Work
	bank0									;Seleciona o banco 0 de mem�ria (padr�o do RESET) 
	movwf 		STATUS_TEMP					;Copia o conte�do de STATUS com os nibbles invertidos para STATUS_TEMP
; -- Final do Salvamento de Contexto --


	; Trata ISR...
	btfss		INTCON,INTF					;Houve interrup��o externa?
	goto		exit_ISR					;N�o, desvia para sa�da da interrup��o
	bcf			INTCON,INTF					;Sim, limpa flag
	
	comf		PORTB						;Complementa o PORTB
	




; -- Recupera Contexto (Sa�da da Interrup��o) --
exit_ISR:

	swapf 		STATUS_TEMP,W				;Copia em Work o conte�do de STATUS_TEMP com os nibbles invertidos
	movwf 		STATUS 						;Recupera o conte�do de STATUS
	swapf 		W_TEMP,F 					;W_TEMP = W_TEMP com os nibbles invertidos 
	swapf 		W_TEMP,W  					;Recupera o conte�do de Work
	
	retfie									;Retorna da interrup��o
	
	
inicio:

	bank1									;Seleciona o banco 1 de mem�ria
	movlw		H'FD'						;w = FDh
	movwf		TRISB						;Configura RB1 como sa�da e demais pinos como entrada
	bsf			OPTION_REG,6				;Configura interrup��o externa por borda de subida
	bank0									;Seleciona o banco 0 de mem�ria
	movlw		H'90'						;w = 90h
	movwf		INTCON						;Habilita interrup��o global e interrup��o externa
	bcf			PORTB,1						;Inicia RB1 em 0
	
 
 

; --- Loop Infinito ---	
	goto		$							;Aguarda interrup��o
	
	
	

; --- Final do Programa ---	
	end										;Final do Programa
	
	
	
