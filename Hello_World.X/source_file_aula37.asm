;
; Curso de Assembly para PIC WR Kits Aula 37
;
;
; Interrupção Externa
;
;
;
; Sistema Embarcado Sugerido: PARADOXUS PEPTO
;
; Disponível em https://wrkits.com.br/catalog/show/141 
;
; Clock: 4MHz    Ciclo de máquina = 1µs
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
; - Sem programação em baixa tensão, sem proteção de código, sem proteção da memória EEPROM
; - Master Clear Habilitado
 __CONFIG _FOSC_INTOSCCLK & _WDTE_OFF & _PWRTE_ON & _MCLRE_OFF & _BOREN_OFF & _LVP_OFF & _CPD_OFF & _CP_OFF
	
	
; --- Paginação de Memória ---
	#define		bank0	bcf	STATUS,RP0		;Cria um mnemônico para selecionar o banco 0 de memória
	#define		bank1	bsf	STATUS,RP0		;Cria um mnemônico para selecionar o banco 1 de memória
	
	
; --- Mapeamento de Hardware (PARADOXUS PEPTO) ---
	#define		LED1	PORTA,3				;LED1 ligado ao pino RA3
	#define		LED2	PORTA,2				;LED2 ligado ao pino RA2

; --- Registradores de Uso Geral ---
	cblock		H'20'						;Início da memória disponível para o usuário
	
	W_TEMP									;Registrador para armazenar o conteúdo temporário de work
	STATUS_TEMP								;Registrador para armazenar o conteúdo temporário de STATUS
	counter1								;Registrador auxiliar para contagem
	counter2								;Registrador auxiliar para contagem	
	tempo0									;Registrador auxiliar para temporização
	tempo1									;Registrador auxiliar para temporização 
 
	endc									;Final da memória do usuário
	

; --- Vetor de RESET ---
	org			H'0000'						;Origem no endereço 00h de memória
	goto		inicio						;Desvia para a label início
	

; --- Vetor de Interrupção ---
	org			H'0004'						;As interrupções deste processador apontam para este endereço
	
; -- Salva Contexto --
	movwf 		W_TEMP						;Copia o conteúdo de Work para W_TEMP
	swapf 		STATUS,W  					;Move o conteúdo de STATUS com os nibbles invertidos para Work
	bank0									;Seleciona o banco 0 de memória (padrão do RESET) 
	movwf 		STATUS_TEMP					;Copia o conteúdo de STATUS com os nibbles invertidos para STATUS_TEMP
; -- Final do Salvamento de Contexto --


	; Trata ISR...
	btfss		INTCON,INTF					;Houve interrupção externa?
	goto		exit_ISR					;Não, desvia para saída da interrupção
	bcf			INTCON,INTF					;Sim, limpa flag
	
	comf		PORTB						;Complementa o PORTB
	




; -- Recupera Contexto (Saída da Interrupção) --
exit_ISR:

	swapf 		STATUS_TEMP,W				;Copia em Work o conteúdo de STATUS_TEMP com os nibbles invertidos
	movwf 		STATUS 						;Recupera o conteúdo de STATUS
	swapf 		W_TEMP,F 					;W_TEMP = W_TEMP com os nibbles invertidos 
	swapf 		W_TEMP,W  					;Recupera o conteúdo de Work
	
	retfie									;Retorna da interrupção
	
	
inicio:

	bank1									;Seleciona o banco 1 de memória
	movlw		H'FD'						;w = FDh
	movwf		TRISB						;Configura RB1 como saída e demais pinos como entrada
	bsf			OPTION_REG,6				;Configura interrupção externa por borda de subida
	bank0									;Seleciona o banco 0 de memória
	movlw		H'90'						;w = 90h
	movwf		INTCON						;Habilita interrupção global e interrupção externa
	bcf			PORTB,1						;Inicia RB1 em 0
	
 
 

; --- Loop Infinito ---	
	goto		$							;Aguarda interrupção
	
	
	

; --- Final do Programa ---	
	end										;Final do Programa
	
	
	
