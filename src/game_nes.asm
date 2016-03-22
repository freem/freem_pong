; Game Code (NES-specific)
;==============================================================================;
;-- Defines/Constants --;
PADDLE_DEFAULT_Y_POS = (240/2)-16
PADDLE_MIN_Y_POS     = 44
PADDLE_MAX_Y_POS     = 240-64

BALL_DEFAULT_X = (256/2)-3 ; screen center x - 3 (7/2, rounded down)
BALL_DEFAULT_Y = (240/2)-3 ; screen center y - 3 (7/2, rounded down)

WALL_TOP = 30  ; top wall: ballY = 0x1E (30)
WALL_BOT = 204 ; bot wall: ballY = 0xCC (204)
WALL_LEFT  = 0   ; left wall  (P1)
WALL_RIGHT = 250 ; right wall (P2)

BALL_PADDLEX_P1 = 30  ; P1 paddle surface X = 0x1E (30)
BALL_PADDLEX_P2 = 219 ; P2 paddle surface X = 0xDB (219)

PADDLE_WIDTH_P1 = 17
PADDLE_WIDTH_P2 = 12

;------------------------------------------------------------------------------;
; Platform-specific routine aliases
	HANDLE_GAME_INPUT = game_InputsGame_nes
	RENDER_BALL       = game_renderBall_nes
	RENDER_PADDLE     = game_renderPaddle_nes
	DRAW_FIELD        = game_drawField_nes
	UPDATE_SCORE_DISP = game_updateScoreDisplay_nes
	INPUT_DEBUG       = game_InputsGame_Debug_nes
	INPUT_ATTRACT     = game_InputsAttract_nes

;==============================================================================;
; Platform-specific data

; Paddle attributes for player 1 and 2
tbl_PaddleAttrib_nes:     .byte $00,$01

; Starting sprite number for player 1 and 2
tbl_PaddleSpriteNum_nes:  .byte $01,$0A

; Sprite tile indexes for paddle
tbl_PaddleTiles_nes:
	.byte $00,$01 ; top
	.byte $02,$03 ; middle 1/2
	.byte $02,$03 ; middle 2/2
	.byte $04,$05 ; bottom

; Starting paddle X positions for player 1 and 2
tbl_PaddleXPos: .byte 16,256-32

;==============================================================================;
; NES sprite map (using 8x8 mode, because it's less painful to deal with)
;-------------------------;-----;
; $00 - ball
;-------------------------;-----;
; $01 - paddle 1 top      | 1/2 ;
; $02 - paddle 1 top      | 2/2 ;
; $03 - paddle 1 middle 1 | 1/2 ;
; $04 - paddle 1 middle 1 | 2/2 ;
; $05 - paddle 1 middle 2 | 1/2 ;
; $06 - paddle 1 middle 2 | 2/2 ;
; $07 - paddle 1 bottom   | 1/2 ;
; $08 - paddle 1 bottom   | 2/2 ;
;-------------------------;-----;
; $09 - paddle 2 top      | 1/2 ;
; $0A - paddle 2 top      | 2/2 ;
; $0B - paddle 2 middle 1 | 1/2 ;
; $0C - paddle 2 middle 1 | 2/2 ;
; $0D - paddle 2 middle 2 | 1/2 ;
; $0E - paddle 2 middle 2 | 2/2 ;
; $0F - paddle 2 bottom   | 1/2 ;
; $10 - paddle 2 bottom   | 2/2 ;
;-------------------------;-----;

;==============================================================================;
; game_InputsAttract_nes
; Handle controller inputs in attract mode.

game_InputsAttract_nes:
	; check for Start button on the first controller
	lda nes_padTrigger
	sta tmp00
	and #PAD_START
	beq @game_InputsAttract_nes_CheckLeft

	; pressed start, begin game
	lda #1
	sta inGame

	; don't allow left/right input after pressing Start
	bne @game_InputsAttract_nes_end ; branch always

	; handle left/right for changing maximum score
@game_InputsAttract_nes_CheckLeft:
	lda tmp00
	and #PAD_LEFT
	beq @game_InputsAttract_nes_CheckRight

	; pressed left; decrement score or wrap around to max
	lda maxScore
	cmp #GAME_MIN_SCORE
	bne @game_InputsAttract_nes_NormalLeft

	; wrap around
	lda #GAME_MAX_SCORE
	sta maxScore
	bne @game_InputsAttract_nes_end ; branch always

@game_InputsAttract_nes_NormalLeft:
	dec maxScore
	bne @game_InputsAttract_nes_end ; branch always

@game_InputsAttract_nes_CheckRight:
	lda tmp00
	and #PAD_RIGHT
	beq @game_InputsAttract_nes_end

	; pressed right; increment score or wrap around to min
	lda maxScore
	cmp #GAME_MAX_SCORE
	bne @game_InputsAttract_nes_NormalRight

	; wrap around
	lda #GAME_MIN_SCORE
	sta maxScore
	bne @game_InputsAttract_nes_end ; branch always

@game_InputsAttract_nes_NormalRight:
	inc maxScore

@game_InputsAttract_nes_end:
	rts

;==============================================================================;
; game_InputsGame_nes
; NES controller input handler

; (Params)
; X - player number (0=p1, 1=p2)

game_InputsGame_nes:
	; save copies of inputs for operation later
	lda nes_padTrigger,x
	sta tmp01
	lda nes_padState,x
	sta tmp00

	; check for up
	and #PAD_UP
	beq @game_InputsGame_nes_CheckDown

	; pressed up
	lda player1Y,x
	cmp #PADDLE_MIN_Y_POS
	bcc @game_InputsGame_nes_ForceMin

	dec player1Y,x
	lda player1Y,x
	cmp #PADDLE_MIN_Y_POS
	bcc @game_InputsGame_nes_ForceMin

	dec player1Y,x
	lda player1Y,x
	cmp #PADDLE_MIN_Y_POS
	bcc @game_InputsGame_nes_ForceMin

	; don't allow up+down
	jmp @game_InputsGame_nes_Debug

@game_InputsGame_nes_ForceMin:
	lda #PADDLE_MIN_Y_POS
	sta player1Y,x
	; don't allow up+down
	jmp @game_InputsGame_nes_Debug

@game_InputsGame_nes_CheckDown:
	; check for down
	lda tmp00
	and #PAD_DOWN
	beq @game_InputsGame_nes_Debug

	; pressed down
	lda player1Y,x
	cmp #PADDLE_MAX_Y_POS
	bcs @game_InputsGame_nes_ForceMax

	inc player1Y,x
	lda player1Y,x
	cmp #PADDLE_MAX_Y_POS
	bcs @game_InputsGame_nes_ForceMax

	inc player1Y,x
	lda player1Y,x
	cmp #PADDLE_MAX_Y_POS
	bcs @game_InputsGame_nes_ForceMax

	jmp @game_InputsGame_nes_Debug

@game_InputsGame_nes_ForceMax:
	lda #PADDLE_MAX_Y_POS
	sta player1Y,x

@game_InputsGame_nes_Debug:
	.ifdef __DEBUGMODE__
	; select = debug
	lda tmp01
	and #PAD_SELECT
	beq @game_InputsGame_nes_end

	; debugger's high, a contra story
	lda #1
	sta p1Debug

	lda ballDir
	sta lastBallDir
	lda #0
	sta ballDir
	.endif

@game_InputsGame_nes_end:
	rts

;==============================================================================;
; game_InputsGame_Debug_nes
; debugger input mode: move the ball!

game_InputsGame_Debug_nes:
	.ifdef __DEBUGMODE__
	lda nes_padTrigger
	sta tmp01
	lda nes_padState
	sta tmp00

	; input up: ball goes up
	and #PAD_UP
	beq @game_InputsGame_Debug_nes_down

	dec ballY

@game_InputsGame_Debug_nes_down:
	; input down: ball goes down
	lda tmp00
	and #PAD_DOWN
	beq @game_InputsGame_Debug_nes_left

	inc ballY

@game_InputsGame_Debug_nes_left:
	; input left: ball goes left
	lda tmp00
	and #PAD_LEFT
	beq @game_InputsGame_Debug_nes_right

	dec ballX

@game_InputsGame_Debug_nes_right:
	; input right: ball goes right
	lda tmp00
	and #PAD_RIGHT
	beq @game_InputsGame_Debug_nes_select

	inc ballX

@game_InputsGame_Debug_nes_select:
	; input select: no more debuggery
	lda tmp01
	and #PAD_SELECT
	beq @game_InputsGame_Debug_nes_end

	lda #0
	sta p1Debug
	lda lastBallDir
	sta ballDir

@game_InputsGame_Debug_nes_end:
	.endif
	rts

;==============================================================================;
; game_renderBall_nes
; NES version of ball renderer.

game_renderBall_nes:
	; using sprite 0

	; Y position
	lda ballY
	; subtract 1 from Y position for correct display location
	sec
	sbc #1
	sta OAM_BUF

	; tile number
	lda #$06
	sta OAM_BUF+1

	; attributes
	lda #2
	.ifdef __DEBUGMODE__
	clc
	adc p1Debug
	.endif
	sta OAM_BUF+2

	; X position
	lda ballX
	sta OAM_BUF+3

	rts

;==============================================================================;
; game_renderPaddle_nes
; NES version of paddle renderer.

; (Params)
; X - Player number (0=p1, 1=p2)

game_renderPaddle_nes:
	; set up a counter for indexing into tables and sprite counting
	lda #0
	sta tmp02

	; get starting sprite number
	lda tbl_PaddleSpriteNum_nes,x
	asl
	asl
	tay

	; store base Y position
	lda player1Y,x
	sta tmp00
	; store base X position
	lda tbl_PaddleXPos,x
	sta tmp01

@game_renderPaddle_nes_loop:
	;-- Y position --;
	lda tmp00
	sta OAM_BUF,y
	iny

	;-- tile index --;
	; load proper tile from table
	tya
	pha

	ldy tmp02
	lda tbl_PaddleTiles_nes,y
	sta tmp03

	pla
	tay
	lda tmp03
	sta OAM_BUF,y
	iny

	;-- attributes --;
	lda tbl_PaddleAttrib_nes,x
	sta OAM_BUF,y
	iny

	;-- X position --;
	lda tmp01
	sta OAM_BUF,y
	iny

	; set up next X position
	lda tmp01
	eor #8
	sta tmp01

	; check for even/odd
	inc tmp02
	lda tmp02
	and #$01
	bne @game_renderPaddle_nes_loopLogic

	; set next row's Y position
	lda tmp00
	clc
	adc #8
	sta tmp00

@game_renderPaddle_nes_loopLogic:
	;-- check loop logic --;
	lda tmp02
	cmp #8
	bne @game_renderPaddle_nes_loop

	rts

;==============================================================================;
; game_drawField_nes
; Handles drawing the game field on NES.

game_drawField_nes:
	;-- horizontal top line ($2060) --;
	ldx #>$2060
	ldy #<$2060
	stx PPU_ADDR
	sty PPU_ADDR

	; tiles $48,$49,$4A,$4B
	lda #$48
	sta PPU_DATA
	lda #$49
	sta PPU_DATA
	lda #$4A
	sta PPU_DATA
	lda #$4B
	sta PPU_DATA

	; tile $03 x24
	lda #$03
	ldx #24
@game_drawField_nes_top:
	sta PPU_DATA
	dex
	bne @game_drawField_nes_top

	; tiles $4C,$4D,$4E,$4F
	lda #$4C
	sta PPU_DATA
	lda #$4D
	sta PPU_DATA
	lda #$4E
	sta PPU_DATA
	lda #$4F
	sta PPU_DATA

	;-- horizontal bottom line ($2340) --;
	; tile $03 x32
	ldx #>$2340
	ldy #<$2340
	stx PPU_ADDR
	sty PPU_ADDR

	; tiles $48,$49,$4A,$4B
	lda #$48
	sta PPU_DATA
	lda #$49
	sta PPU_DATA
	lda #$4A
	sta PPU_DATA
	lda #$4B
	sta PPU_DATA

	; tile $03 x24
	lda #$03
	ldx #24
@game_drawField_nes_bottom:
	sta PPU_DATA
	dex
	bne @game_drawField_nes_bottom

	; tiles $4C,$4D,$4E,$4F
	lda #$4C
	sta PPU_DATA
	lda #$4D
	sta PPU_DATA
	lda #$4E
	sta PPU_DATA
	lda #$4F
	sta PPU_DATA

	; set increment for vertical tiles
	lda int_ppuCtrl
	and #%11111011
	ora #%00000100
	sta int_ppuCtrl
	sta PPU_CTRL

	;-- vertical middle line 1/2 ($206F) --;
	ldx #>$206F
	ldy #<$206F
	stx PPU_ADDR
	sty PPU_ADDR
	; tiles $04,$08,$0A x1 each
	lda #$04
	sta PPU_DATA
	lda #$08
	sta PPU_DATA
	lda #$0A
	sta PPU_DATA

	; tile $0C x17
	lda #$0C
	ldx #17
@game_drawField_nes_mid1:
	sta PPU_DATA
	dex
	bne @game_drawField_nes_mid1

	; tiles $0E,$44,$46,$06 x1 each
	lda #$0E
	sta PPU_DATA
	lda #$44
	sta PPU_DATA
	lda #$46
	sta PPU_DATA
	lda #$06
	sta PPU_DATA

	;-- vertical middle line 2/2 ($2070) --;
	ldx #>$2070
	ldy #<$2070
	stx PPU_ADDR
	sty PPU_ADDR
	; tiles $05,$09,$0B x1 each
	lda #$05
	sta PPU_DATA
	lda #$09
	sta PPU_DATA
	lda #$0B
	sta PPU_DATA

	; tile $0D x17
	lda #$0D
	ldx #17
@game_drawField_nes_mid2:
	sta PPU_DATA
	dex
	bne @game_drawField_nes_mid2

	; tiles $0F,$45,$47,$07 x1 each
	lda #$0F
	sta PPU_DATA
	lda #$45
	sta PPU_DATA
	lda #$47
	sta PPU_DATA
	lda #$07
	sta PPU_DATA

	; reset increment for horizontal tiles
	lda int_ppuCtrl
	and #%11111011
	sta int_ppuCtrl
	sta PPU_CTRL

	;-- write attributes --;
	; $23CA = $44
	; $23CB = $99
	; $23CC = $66
	ldx #>$23CA
	ldy #<$23CA
	stx PPU_ADDR
	sty PPU_ADDR
	lda #$44
	sta PPU_DATA
	lda #$99
	sta PPU_DATA
	lda #$66
	sta PPU_DATA

	;------------;
	; $23D3 = $88
	; $23D4 = $22
	ldx #>$23D3
	ldy #<$23D3
	stx PPU_ADDR
	sty PPU_ADDR
	lda #$88
	sta PPU_DATA
	lda #$22
	sta PPU_DATA

	;------------;
	; $23DB = $88
	; $23DC = $22
	ldx #>$23DB
	ldy #<$23DB
	stx PPU_ADDR
	sty PPU_ADDR
	lda #$88
	sta PPU_DATA
	lda #$22
	sta PPU_DATA

	;------------;
	; $23E3 = $88
	; $23E4 = $22
	ldx #>$23E3
	ldy #<$23E3
	stx PPU_ADDR
	sty PPU_ADDR
	lda #$88
	sta PPU_DATA
	lda #$22
	sta PPU_DATA

	;------------;
	; $23EB = $88
	; $23EC = $22
	ldx #>$23EB
	ldy #<$23EB
	stx PPU_ADDR
	sty PPU_ADDR
	lda #$88
	sta PPU_DATA
	lda #$22
	sta PPU_DATA

	;------------;
	; $23F3 = $08
	; $23F4 = $02
	ldx #>$23F3
	ldy #<$23F3
	stx PPU_ADDR
	sty PPU_ADDR
	lda #$08
	sta PPU_DATA
	lda #$02
	sta PPU_DATA

	rts

;==============================================================================;
; game_updateScoreDisplay_nes
; Update score display (NES version)

; needs to go into VRAM buffer with specified commands.

game_updateScoreDisplay_nes:
	;-- update player 1 score display --;
	; (digit 1: $20AC,$20CC)
	ldx #>$20AC
	ldy #<$20AC
	lda #$82
	stx nes_vramBuf
	sty nes_vramBuf+1
	sta nes_vramBuf+2
	; get digit
	lda scoreP1
	and #$F0
	lsr
	lsr
	lsr
	lsr
	tay
	lda tbl_scoreTiles_Top,y
	sta nes_vramBuf+3
	lda tbl_scoreTiles_Bot,y
	sta nes_vramBuf+4

	; (digit 2: $20AD,$20CD)
	ldx #>$20AD
	ldy #<$20AD
	lda #$82
	stx nes_vramBuf+5
	sty nes_vramBuf+6
	sta nes_vramBuf+7
	; get digit
	lda scoreP1
	and #$0F
	tay
	lda tbl_scoreTiles_Top,y
	sta nes_vramBuf+8
	lda tbl_scoreTiles_Bot,y
	sta nes_vramBuf+9

	; update player 2 score display
	; (digit 1: $20B2,$20D2)
	ldx #>$20B2
	ldy #<$20B2
	lda #$82
	stx nes_vramBuf+10
	sty nes_vramBuf+11
	sta nes_vramBuf+12
	; get digit
	lda scoreP2
	and #$F0
	lsr
	lsr
	lsr
	lsr
	tay
	lda tbl_scoreTiles_Top,y
	sta nes_vramBuf+13
	lda tbl_scoreTiles_Bot,y
	sta nes_vramBuf+14

	; (digit 2: $20B3,$20D3)
	ldx #>$20B3
	ldy #<$20B3
	lda #$82
	stx nes_vramBuf+15
	sty nes_vramBuf+16
	sta nes_vramBuf+17
	; get digit
	lda scoreP2
	and #$0F
	tay
	lda tbl_scoreTiles_Top,y
	sta nes_vramBuf+18
	lda tbl_scoreTiles_Bot,y
	sta nes_vramBuf+19

	lda #1
	sta nes_ntUpdate
	rts
