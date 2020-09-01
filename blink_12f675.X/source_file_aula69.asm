;========================================================================================
;
; Curso de Assembly para PIC WR Kits Aula 69
;
;
; Convers�o AD com PIC12F675
;
;
; Compilador: MPASM v 5.51
;
; MCU: PIC12F675
;
; Clock: 4MHz (oscilador interno)    Ciclo de m�quina = 1�s
;
; Autor: Eng. Wagner Rambo   Data: Mar�o de 2017
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
; - Clock de 4MHz (oscilador interno sem habilitar sa�das)
; - Watch Dog Timer desabilitado
; - Power Up Timer habilitado
; - Brown Out desabilitado
; - Sem prote��o de c�digo, sem prote��o da mem�ria EEPROM
; - Master Clear desabilitado
	__config _INTRC_OSC_NOCLKOUT & _WDT_OFF & _PWRTE_ON & _BOREN_OFF & _CP_OFF & _CPD_OFF & _MCLRE_OFF
	

;========================================================================================
; --- Pagina��o de Mem�ria ---
	#define		bank0	bcf	STATUS,RP0		;Cria um mnem�nico para selecionar o banco 0 de mem�ria
	#define		bank1	bsf	STATUS,RP0		;Cria um mnem�nico para selecionar o banco 1 de mem�ria
	
	
;========================================================================================
; --- Mapeamento de Hardware ---
	#define		pot		GPIO,3				;Potenci�metro ligado no pino GP3
	#define		out		GPIO,5				;Sa�da de teste no pino GP5


;========================================================================================
; --- Registradores de Uso Geral ---
	cblock		H'20'						;In�cio da mem�ria dispon�vel para o usu�rio
	
	W_TEMP									;Registrador para armazenar o conte�do tempor�rio de work
	STATUS_TEMP								;Registrador para armazenar o conte�do tempor�rio de STATUS
	T0										;contador auxiliar para temporiza��o
	value_adc								;registrador para compara��o
	 
	endc									;Final da mem�ria do usu�rio
	

;========================================================================================
; --- Vetor de RESET ---
	org			H'0000'						;Origem no endere�o 00h de mem�ria
	goto		inicio						;Desvia para a label in�cio
	

;========================================================================================
; --- Vetor de Interrup��o ---
	org			H'0004'						;As interrup��es deste processador apontam para este endere�o
	
; -- Salva Contexto --
	movwf 		W_TEMP						;Copia o conte�do de Work para W_TEMP
	swapf 		STATUS,W  					;Move o conte�do de STATUS com os nibbles invertidos para Work
	bank0									;Seleciona o banco 0 de mem�ria (padr�o do RESET) 
	movwf 		STATUS_TEMP					;Copia o conte�do de STATUS com os nibbles invertidos para STATUS_TEMP
; -- Final do Salvamento de Contexto --




 
; -- Recupera Contexto (Sa�da da Interrup��o) --
exit_ISR:

	swapf 		STATUS_TEMP,W				;Copia em Work o conte�do de STATUS_TEMP com os nibbles invertidos
	movwf 		STATUS 						;Recupera o conte�do de STATUS
	swapf 		W_TEMP,F 					;W_TEMP = W_TEMP com os nibbles invertidos 
	swapf 		W_TEMP,W  					;Recupera o conte�do de Work
	
	retfie									;Retorna da interrup��o


;========================================================================================	
; --- Principal ---	
inicio:

	bank1									;muda para o banco 1 de mem�ria
	bcf			TRISIO,5					;configura GP5 como sa�da
	movlw		H'11'						;move literal 11h para work
	movwf		ANSEL						;Fosc/8, configura AN0 para utiliza��o
	 

	bank0									;muda para o banco 0 de mem�ria
	bcf			out							;sa�da inicia em LOW
	movlw		H'07'						;move literal 07h para work
	movwf		CMCON						;habilita comparadores com tens�o de refer�ncia interna
	bsf		ADCON0,ADON					;habilita conversor AD
	movlw		H'64'						;move 64h para work
	movwf		T0							;inicializa contador auxiliar
	movlw		H'80'						;move 80h para work
	movwf		value_adc					;inicializa value_adc
 
 ; 1000 0000b  / 0111 1111b
	


loop:										;Loop infinito

	bsf			ADCON0,GO_DONE				;recebe dado do canal anal�gico
	
wait_adc:

	btfsc		ADCON0,GO_DONE					;dado est� pronto?
	goto		wait_adc					;N�o, aguarda
											;Sim
	movf		ADRESH,W					;carrega valor de convers�o em work
	
	andwf		value_adc,W					;W = W and value_adc
	btfss		STATUS,Z					;adc menor que 128?
	goto		out_high					;sim, desvia para setar sa�da
	bcf		out						;n�o, SAIDA EM LOW
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
	goto		_100us						;N�o, desvia
	return									;Sim, retorna 							
 
     
 


;========================================================================================
; --- Final do Programa ---	
	end										;Final do Programa
	
	
	
