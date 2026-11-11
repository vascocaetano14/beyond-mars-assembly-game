; *********************************************************************************
; IST
; PROJETO ACOM BEYOND MARS
;
; GRUPO 13
; Vasco Caetano and group colleagues, Instituto Superior Técnico
;
; Teclas:
; C - Começa o jogo
; 3 - Desce o asteroide
; 4 - Aumenta o contador
; 5 - Diminui o contador
; *********************************************************************************


; **************************************************************************************************************
; * CONSTANTES
; **************************************************************************************************************

APAGA_AVISO     		  EQU 6040H      ; endereço do comando para apagar o aviso de nenhum cenário selecionado
APAGA_ECRÃ	 		      EQU 6002H      ; endereço do comando para apagar todos os pixels já desenhados
SELECIONA_CENARIO_FUNDO   EQU 6042H      ; endereço do comando para selecionar uma imagem de fundo
APAGA_CENARIO_FRONTAL     EQU 6044H      ; endereço do comando para apagar a imagem frontal
SELECIONA_CENARIO_FRONTAL EQU 6046H      ; endereço do comando para selecionar uma imagem frontal
TOCA_SOM                  EQU 605AH      ; endereço do comando para tocar um som

DISPLAYS   EQU 0A000H  ; endereço dos displays de 7 segmentos (periférico POUT-1)

TEC_LIN    EQU 0C000H  ; endereço das linhas do teclado (periférico POUT-2)
TEC_COL    EQU 0E000H  ; endereço das colunas do teclado (periférico PIN)
LIN        EQU 8       ; linha a testar (4ª linha, 1000b)

MASCARA    EQU 0FH     ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
C          EQU 0CH
ATRASO     EQU 888H	   ; atraso para limitar a velocidade de movimento do boneco

DEFINE_LINHA    		EQU 600AH      ; endereço do comando para definir a linha
DEFINE_COLUNA   		EQU 600CH      ; endereço do comando para definir a coluna
DEFINE_PIXEL    		EQU 6012H      ; endereço do comando para escrever um pixel

MIN_COLUNA		EQU  0		   ; número da coluna mais à esquerda que o objeto pode ocupar
MAX_COLUNA		EQU  63        ; número da coluna mais à direita que o objeto pode ocupar

;************************
;LINHAS E COLUNAS DA NAVE
;************************
LINHA_NAVE        	        EQU  31        ; linha da nave (a meio do ecrã)
COLUNA_NAVE			        EQU  27        ; coluna da nave (a meio do ecrã)

;************************
;LINHAS E COLUNAS DA SONDA
;************************
LINHA_ORIGEM_SONDA        	EQU  27        ; linha da sonda (a meio do ecrã)
COLUNA_ORIGEM_SONDA		    EQU  32        ; coluna do boneco (a meio do ecrã)

;************************
;LINHAS E COLUNAS DO ASTEROIDE
;************************
LINHA_ASTEROIDE        	    EQU  5         ; linha do asteroide (a meio do ecrã)
COLUNA_ASTEROIDE		    EQU  4         ; coluna do asteroide (a meio do ecrã)


;************************
;DIMENSÕES DA NAVE
;************************
LARGURA		                EQU	 10                    
ALTURA                      EQU  5                     


;************************
;COR DOS PIXEIS UTILIZADOS
;************************
COR_PIXEL		            EQU	 0A00FH		
COR_PIXEL_2                 EQU  0FFFFH
COR_PIXEL_3                 EQU  0FF0FH
COR_PIXEL_SONDA             EQU  0FFF0H	


; ******************************************************************************************************************
; * DADOS
; ******************************************************************************************************************

     PLACE       1000H
pilha:
	STACK 100H			; espaço reservado para a pilha 
						; (200H bytes, pois são 100H words)
SP_inicial:				; este é o endereço (1200H) com que o SP deve ser 
						; inicializado. O 1.º end. de retorno será 
						; armazenado em 11FEH (1200H-2)
                        

;************************
;DESENHO DA NAVE
;************************                       
DEF_NAVE:				
	WORD		LARGURA
	WORD		COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL
    
DEF_NAVE_2:
    WORD		LARGURA
	WORD		COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL_2, COR_PIXEL_2, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL
    
DEF_NAVE_3:
    WORD		LARGURA
	WORD		COR_PIXEL, 0, COR_PIXEL, COR_PIXEL_2, COR_PIXEL_2, COR_PIXEL_2, COR_PIXEL_2, COR_PIXEL, 0, COR_PIXEL
    
DEF_NAVE_4:
    WORD		LARGURA
	WORD		COR_PIXEL, 0, 0, COR_PIXEL_2, COR_PIXEL_2, COR_PIXEL_2, COR_PIXEL_2, 0, 0, COR_PIXEL
    
    
;************************
;DESENHO DO ASTEROIDE
;************************    
DEF_ASTEROIDE:
    WORD        COR_PIXEL_3, 0, COR_PIXEL_3, 0, COR_PIXEL_3

DEF_ASTEROIDE_2:
    WORD        0, COR_PIXEL_3, 0, COR_PIXEL_3, 0
    



TECLA:
    WORD        0

CONTADOR:
    WORD        0      ; indicar onde está o contador 
   


; ********************************************************************************************************************
; * CODIGO
; ********************************************************************************************************************

PLACE   0				; o código tem de começar em 0000H
     
inicio:

    MOV  SP, SP_inicial	
    MOV  [APAGA_AVISO], R1	; apaga o aviso de nenhum cenário selecionado (o valor de R1 não é relevante)
    MOV  [APAGA_ECRÃ], R1	; apaga todos os pixels já desenhados (o valor de R1 não é relevante)
	MOV	 R1, 0			; cenário de fundo número 0
    MOV  [SELECIONA_CENARIO_FUNDO], R1	; seleciona o cenário de fundo
    MOV  R2, 1
    MOV [SELECIONA_CENARIO_FRONTAL], R2
	MOV  R0, DISPLAYS       ; por o display a 0's aqui para que comece tudo bem
	MOV  R1, 256            
	MOV  [R0], R1
    MOV  R10, 0
    MOV  R11,1



; ********************************************************************************************************************
; * TECLADO
; ********************************************************************************************************************

ciclo_teclado:
    MOV  R2, TEC_LIN   ; endereço do periférico das linhas
    MOV  R3, TEC_COL   ; endereço do periférico das colunas
    MOV  R5, MASCARA   ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
    MOV  R1, LIN       ; testar a linha 4
    MOV  R6, 0         ; iniciar counter das linhas
    MOV  R7, 0         ; iniciar counter das colunas

espera_tecla:          ; neste ciclo espera-se até uma tecla ser premida
    MOVB [R2], R1      ; escrever no periférico de saída (linhas)
    MOVB R0, [R3]      ; ler do periférico de entrada (colunas)
    AND  R0, R5        ; elimina bits para além dos bits 0-3
    CMP  R0, 0         ; há tecla premida?
    JZ   muda_lin    ; se nenhuma tecla premida, muda de linha
    JMP  calcula_lin ; uma tecla foi premida

muda_lin:
    SHR R1, 1          ; passa a linha atual para a linha anterior (1000 para 0100, etc.)
    CMP R1, 0	       ; 
    JZ  ciclo_teclado  ; todas as linhas foram testadas, então voltamos para a linha 4 (sair_teclado later)
    JMP espera_tecla   ;

calcula_lin:
    SHR  R1, 1         ; desloca o conteúdo do registo R1 (linha atual) uma posição para a direita
    CMP  R1, 0         ;
    JZ   calcula_col   ; salta para a função "calcula_col" se a comparação anterior for igual a zero (linha atual é zero)
    ADD  R6, 1         ; incrementa o valor do registo R6 (contador de linhas testadas) em 1
    JMP  calcula_lin   ; salta para a função "calcula_lin"

calcula_col:
    SHR  R0, 1         ; desloca o conteúdo do registrador R0 (valor lido do periférico das colunas do teclado) uma posição para a direita
    CMP  R0, 0         ; 
    JZ   formula       ; salta para a função "formula" se a comparação anterior for igual a zero (valor lido é zero)
    ADD  R7, 1         ; incrementa o valor do registo R7 (contador de colunas testadas) em 1
    JMP  calcula_col   ; salta para a função "calcula_col"

formula:
    MOV  R8, 04H       ; 
    MUL  R6, R8        ; multiplica o número da linha pelo valor de R8 (4)
    ADD  R7, R6        ; adiciona o valor da coluna ao resultado anterior
    MOV  [TECLA], R7   ; indicação da tecla selecionada



; ********************************************************************************************************************
; * TECLAS
; ********************************************************************************************************************

atribuir_teclas:
    MOV  R0, C         ; associar tecla C
    MOV  R1, TECLA     ;
    MOV  R2, [R1]      ;
    CMP  R10, 1        ;
    JZ teclas_jogo     ; se for igual a 1, salta para a função teclas_jogo 
    CMP  R2, R0        ;
    MOV  [APAGA_CENARIO_FRONTAL], R3
    JZ  posição_sonda  ; se a tecla C tiver sido pressionada, salta para a função posição_onda
    
teclas_jogo:
    MOV  R0, 4              ; associar tecla 4
    MOV  R1, TECLA          ;
    MOV  R2, [R1]           ;
    CMP  R10, 0             ; 
    JZ  ciclo_teclado       ; se for igual a 0, salta para a função ciclo_teclado 
    CMP  R2, R0             ;
    JZ  display_aumenta     ; se a tecla 4 tiver sido pressionada, salta para a função display_aumenta
    
    MOV  R0, 5              ; associar tecla 5
    MOV  R1, TECLA          
    MOV  R2, [R1]      
    CMP  R10, 0        
    JZ  ciclo_teclado       ; se for igual a 0, salta para a função ciclo_teclado 
    CMP  R2, R0             ;
    JZ  display_diminui     ; se a tecla 5 tiver sido pressionada, salta para a função display_diminui
    MOV  R0, 3              ; associar tecla 3
    MOV  R1, TECLA          
    MOV  R2, [R1]      
    CMP  R10, 0        
    JZ  ciclo_teclado       ; se for igual a 0, salta para a função ciclo_teclado 
    CMP  R2, R0             
    JZ posição_asteroide    ; se a tecla 3 tiver sido pressionada, salta para a função posição_asteroide
    
    
reset_tecla:
    MOV  R4, 0         
    MOV  [TECLA], R4   
    
atraso_3: 
    MOV    R9, ATRASO       ; atraso para limitar a velocidade de movimento do asteroide
    
ciclo_atraso_3:
    SUB    R9, 1
    JNZ    ciclo_atraso_3
    JMP    ciclo_teclado



; *********************************************************************************
; * CONTADORES - Responsável pelo aumento ou diminuição da energia da nave
; *********************************************************************************

display_aumenta:
    MOV R0, DISPLAYS
    MOV R1, CONTADOR
    MOV R2, [R1]
    ADD R2, 1
    MOV [CONTADOR], R2
    MOV [R0], R2
    MOV R4, 0
    MOV [TECLA], R4
    JMP ciclo_teclado

display_diminui:
    MOV R0, DISPLAYS
    MOV R1, CONTADOR
    MOV R2, [R1]
    SUB R2, 1
    MOV [CONTADOR], R2
    MOV [R0], R2
    MOV R4, 0
    MOV [TECLA], R4
    JMP ciclo_teclado


; *********************************************************************************
; * SONDA
; *********************************************************************************

posição_sonda:
     MOV  R1, LINHA_ORIGEM_SONDA
     MOV  R2, COLUNA_ORIGEM_SONDA
     MOV  R3, COR_PIXEL_SONDA
     MOV  R4, 1
     
desenha_sonda_2:
     MOV  R3, COR_PIXEL_SONDA
     CALL escreve_pixel
     CMP  R4, 0
     JZ   ciclo_teclado
     
     

; *********************************************************************************
; * NAVE
; *********************************************************************************

;************************
;PRIMEIRA LINHA DA NAVE
;************************    
posição_nave:
     MOV  R1, LINHA_NAVE	  ; linha do boneco
     MOV  R2, COLUNA_NAVE     ; coluna do boneco

desenha_nave:       		  ; desenha o boneco a partir da tabela
	MOV	R4, DEF_NAVE		  ; endereço da tabela que define o boneco
	MOV	R5, [R4]			  ; obtém a largura do boneco
	ADD	R4, 2			      ; endereço da cor do 1º pixel (2 porque a largura é uma word)
    
desenha_pixels:       		  ; desenha os pixels do boneco a partir da tabela
	MOV	R3, [R4]			  ; obtém a cor do próximo pixel do boneco
	CALL escreve_pixel
	ADD	R4, 2			      ;  endereço da cor do próximo pixel (2 porque cada cor de pixel é uma word)
     ADD  R2, 1               ; próxima coluna
     SUB  R5, 1			      ; menos uma coluna para tratar
     JNZ  desenha_pixels      ; continua até percorrer toda a largura do objeto
     

;************************
;SEGUNDA LINHA DA NAVE
;************************ 
posição_nave_2:
     SUB  R1, 1			        ; linha do boneco
     MOV  R2, COLUNA_NAVE		; coluna do boneco     
     
desenha_nave_2:       		    ; desenha o boneco a partir da tabela
	MOV	R4, DEF_NAVE_2		    ; endereço da tabela que define o boneco
	MOV	R5, [R4]			    ; obtém a largura do boneco
	ADD	R4, 2			        ; endereço da cor do 1º pixel (2 porque a largura é uma word)
    
desenha_pixels_2:       		; desenha os pixels do boneco a partir da tabela
	MOV	R3, [R4]			    ; obtém a cor do próximo pixel do boneco
	CALL escreve_pixel
	ADD	R4, 2			        ; endereço da cor do próximo pixel (2 porque cada cor de pixel é uma word)
     ADD  R2, 1                 ; próxima coluna
     SUB  R5, 1			        ; menos uma coluna para tratar
     JNZ  desenha_pixels_2      ; continua até percorrer toda a largura do objeto
     

;************************
;TERCEIRA LINHA DA NAVE
;************************ 
posição_nave_3:
     SUB  R1, 1			        ; linha do boneco
     MOV  R2, COLUNA_NAVE		; coluna do boneco     
     
desenha_nave_3:       		    ; desenha o boneco a partir da tabela
	MOV	R4, DEF_NAVE_3		    ; endereço da tabela que define o boneco
	MOV	R5, [R4]			    ; obtém a largura do boneco
	ADD	R4, 2			        ; endereço da cor do 1º pixel (2 porque a largura é uma word)
    
desenha_pixels_3:       		; desenha os pixels do boneco a partir da tabela
	MOV	R3, [R4]			    ; obtém a cor do próximo pixel do boneco
	CALL escreve_pixel
	ADD	R4, 2			        ; endereço da cor do próximo pixel (2 porque cada cor de pixel é uma word)
     ADD  R2, 1                 ; próxima coluna
     SUB  R5, 1			        ; menos uma coluna para tratar
     JNZ  desenha_pixels_3      ; continua até percorrer toda a largura do objeto
     

;************************
;QUARTA LINHA DA NAVE
;************************ 
posição_nave_4:
     SUB  R1, 1			        ; linha do boneco
     MOV  R2, COLUNA_NAVE		; coluna do boneco     
     
desenha_nave_4:       		    ; desenha o boneco a partir da tabela
	MOV	R4, DEF_NAVE_4		    ; endereço da tabela que define o boneco
	MOV	R5, [R4]			    ; obtém a largura do boneco
	ADD	R4, 2			        ; endereço da cor do 1º pixel (2 porque a largura é uma word)
    
desenha_pixels_4:       		; desenha os pixels do boneco a partir da tabela
	MOV	R3, [R4]			    ; obtém a cor do próximo pixel do boneco
    CALL escreve_pixel
	ADD	R4, 2			        ; endereço da cor do próximo pixel (2 porque cada cor de pixel é uma word)
     ADD  R2, 1                 ; próxima coluna
     SUB  R5, 1			        ; menos uma coluna para tratar
     JNZ  desenha_pixels_4      ; continua até percorrer toda a largura do objeto
     
     
     
; *********************************************************************************
; * ASTEROIDE
; *********************************************************************************
     
posição_asteroide:
    MOV   R1, LINHA_ASTEROIDE
    MOV   R2, COLUNA_ASTEROIDE
    MOV   R4, ALTURA
    MOV   R5, DEF_ASTEROIDE
    MOV   R6, DEF_ASTEROIDE_2
    MOV   R7, 3
    MOV   R8, 3
    CMP   R10, 1
    JZ    atraso
    
desenhe_asteroide:
    MOV R3, [R5]
    CALL	escreve_pixel  
    ADD R5, 2
    ADD  R2, 1                  ; próxima coluna
    SUB  R4, 1			        ; menos uma coluna para tratar
    JNZ  desenhe_asteroide      ; continua até percorrer toda a largura do objeto
    ADD R1, 1
    SUB R2, 5
    ADD R4, 5
    SUB R7,1
    MOV R5, DEF_ASTEROIDE
    CMP R7, 0
    JZ desenhe_asteroide_3
     
desenhe_asteroide_2:
    MOV R9, [R6]
    MOV  [DEFINE_LINHA], R1		; seleciona a linha
	MOV  [DEFINE_COLUNA], R2    ; seleciona a coluna
	MOV  [DEFINE_PIXEL], R9		; altera a cor do pixel na linha e coluna já selecionadas
    ADD R6, 2
    ADD R2, 1
    SUB R4, 1
    JNZ desenhe_asteroide_2
    ADD R1, 1
    SUB R2, 5
    
desenhe_asteroide_3:
    ADD R4, 5
     SUB R8,1
    MOV R6, DEF_ASTEROIDE_2
    JNZ desenhe_asteroide
    SUB R1, 5
    JMP reset_incremento
    
atraso:
    MOV	R9, ATRASO		        ; atraso para limitar a velocidade de movimento do boneco
    
ciclo_atraso:
	SUB	R9, 1
	JNZ	ciclo_atraso
    
asteroide:
    SUB R11, 1
    ADD R1, R11
    ADD R2, R11
    ADD R11, 1
    MOV    R9, 0                ; som com número 0
    MOV [TOCA_SOM], R9          ; comando para tocar o som
    
desenhe_asteroide_4:
    MOV R3, 0
    CALL	escreve_pixel  
     ADD  R2, 1                 ; próxima coluna
     SUB  R4, 1			        ; menos uma coluna para tratar
     JNZ  desenhe_asteroide_4   ; continua até percorrer toda a largura do objeto
    ADD R1, 1
    SUB R2, 5
    ADD R4, 5
     SUB R7,1
    CMP R7, 0
     JZ desenhe_asteroide_6
     
desenhe_asteroide_5:
    CALL	escreve_pixel	     ; altera a cor do pixel na linha e coluna já selecionada
      ADD R2, 1
      SUB R4, 1
      JNZ desenhe_asteroide_5
    ADD R1, 1
    SUB R2, 5
    
desenhe_asteroide_6:
    ADD R4, 5
     SUB R8,1
    JNZ desenhe_asteroide_4
    SUB R1, 4
    SUB R2, 4
    ADD R11, 1
    MOV   R4, ALTURA
    MOV   R5, DEF_ASTEROIDE
    MOV   R6, DEF_ASTEROIDE_2
    MOV   R7, 3
    MOV   R8, 3
    ADD   R2, 5
    JMP desenhe_asteroide
    

reset_incremento:
   ADD R10, 1
   CMP R10, 2
    JZ subtração
    
atraso_2:
    MOV	R9, ATRASO		        ; atraso para limitar a velocidade de movimento do boneco	
    
ciclo_atraso_2:
	SUB	R9, 1
	JNZ	ciclo_atraso_2
   JMP reset_tecla
     
     
escreve_pixel:
	MOV  [DEFINE_LINHA], R1		; seleciona a linha
	MOV  [DEFINE_COLUNA], R2	; seleciona a coluna
	MOV  [DEFINE_PIXEL], R3		; altera a cor do pixel na linha e coluna já selecionadas
	RET

subtração:
    SUB R10, 1
    JMP reset_tecla
    
fim:
     JMP  fim                   ; termina programa