;========================================================================================
;
; Curso de Assembly para PIC WR Kits Aula 69
;
;
; Conversão AD com PIC12F675
;
;
; Compilador: MPASM v 5.51
;
; MCU: PIC12F675
;
; Clock: 4MHz (oscilador interno)    Ciclo de máquina = 1µs
;
; Autor: Eng. Wagner Rambo   Data: Março de 2017
;
;
;========================================================================================


;========================================================================================
; --- Listagem do Processador Utilizado ---
;	list	p=12F675						;Utilizado PIC16F675
		

;========================================================================================	
; --- Arquivos Inclusos no Projeto ---
    #include "p12f675.inc"					;inclui o arquivo do PIC 16F675
	

;========================================================================================
; --- FUSE Bits ---
; - Clock de 4MHz (oscilador interno sem habilitar saídas)
; - Watch Dog Timer desabilitado
; - Power Up Timer habilitado
; - Brown Out desabilitado
; - Sem proteção de código, sem proteção da memória EEPROM
; - Master Clear desabilitado
	__config _INTRC_OSC_NOCLKOUT & _WDT_OFF & _PWRTE_ON & _BOREN_OFF & _CP_OFF & _CPD_OFF & _MCLRE_OFF
	

;========================================================================================
; --- Paginação de Memória ---
	#define		bank0	bcf	STATUS,RP0		;Cria um mnemônico para selecionar o banco 0 de memória
	#define		bank1	bsf	STATUS,RP0		;Cria um mnemônico para selecionar o banco 1 de memória
	
	
;========================================================================================
; --- Mapeamento de Hardware ---
	#define		pot		GPIO,3				;Potenciômetro ligado no pino GP3
	#define		out		GPIO,5				;Saída de teste no pino GP5


;========================================================================================
; --- Registradores de Uso Geral ---
	cblock		H'20'						;Início da memória disponível para o usuário
	
	W_TEMP									;Registrador para armazenar o conteúdo temporário de work
	STATUS_TEMP								;Registrador para armazenar o conteúdo temporário de STATUS
	T0										;contador auxiliar para temporização
	value_adc								;registrador para comparação
	 
	endc									;Final da memória do usuário
	

;========================================================================================
; --- Vetor de RESET ---
	org			H'0000'						;Origem no endereço 00h de memória
	goto		inicio						;Desvia para a label início
	

;========================================================================================
; --- Vetor de Interrupção ---
	org			H'0004'						;As interrupções deste processador apontam para este endereço
	
; -- Salva Contexto --
	movwf 		W_TEMP						;Copia o conteúdo de Work para W_TEMP
	swapf 		STATUS,W  					;Move o conteúdo de STATUS com os nibbles invertidos para Work
	bank0									;Seleciona o banco 0 de memória (padrão do RESET) 
	movwf 		STATUS_TEMP					;Copia o conteúdo de STATUS com os nibbles invertidos para STATUS_TEMP
; -- Final do Salvamento de Contexto --




 
; -- Recupera Contexto (Saída da Interrupção) --
exit_ISR:

	swapf 		STATUS_TEMP,W				;Copia em Work o conteúdo de STATUS_TEMP com os nibbles invertidos
	movwf 		STATUS 						;Recupera o conteúdo de STATUS
	swapf 		W_TEMP,F 					;W_TEMP = W_TEMP com os nibbles invertidos 
	swapf 		W_TEMP,W  					;Recupera o conteúdo de Work
	
	retfie									;Retorna da interrupção


;========================================================================================	
; --- Principal ---	
inicio:

	bank1									;muda para o banco 1 de memória
	bcf			TRISIO,5					;configura GP5 como saída
	movlw		H'11'						;move literal 11h para work
	movwf		ANSEL						;Fosc/8, configura AN0 para utilização
	 

	bank0									;muda para o banco 0 de memória
	bcf			out							;saída inicia em LOW
	movlw		H'07'						;move literal 07h para work
	movwf		CMCON						;habilita comparadores com tensão de referência interna
	bsf		ADCON0,ADON					;habilita conversor AD
	movlw		H'64'						;move 64h para work
	movwf		T0							;inicializa contador auxiliar
	movlw		H'80'						;move 80h para work
	movwf		value_adc					;inicializa value_adc
 
 ; 1000 0000b  / 0111 1111b
	


loop:										;Loop infinito

	bsf			ADCON0,GO_DONE				;recebe dado do canal analógico
	
wait_adc:

	btfsc		ADCON0,GO_DONE					;dado está pronto?
	goto		wait_adc					;Não, aguarda
											;Sim
	movf		ADRESH,W					;carrega valor de conversão em work
	
	andwf		value_adc,W					;W = W and value_adc
	btfss		STATUS,Z					;adc menor que 128?
	goto		out_high					;sim, desvia para setar saída
	bcf		out						;não, SAIDA EM LOW
	goto		continua					;desvia para label continua
											
											
out_high:

	bsf			out							;saida em HIGH
	
continua:

	call		_100us						;aguarda 100us
	call		_100us						;aguarda 100us
	call		_100us						;aguarda 100us
	call		_100us						;aguarda 100us
	call		_100us						;aguarda 100us
 
	
	
   
 
	goto		loop				 
 
 
	
	
;========================================================================================
; --- Desenvolvimento das Sub-Rotinas ---
_100us:

	decfsz		T0,F						;decrementa T0. Chegou em zero?
	goto		_100us						;Não, desvia
	return									;Sim, retorna 							
 
     
 


;========================================================================================
; --- Final do Programa ---	
	end										;Final do Programa
	
	
	
