; Game Code (PCE-specific)
;==============================================================================;
;-- Defines/Constants --;
PADDLE_DEFAULT_Y_POS = (240/2)+48
PADDLE_MIN_Y_POS     = 109
PADDLE_MAX_Y_POS     = 240

BALL_DEFAULT_X = (256/2)+29 ; screen center x + 29
BALL_DEFAULT_Y = (240/2)+61 ; screen center x + 61

WALL_TOP = 94 ; top wall: ballY = 0x5E (94)
WALL_BOT = 12   ; bottom wall low byte  0x0C (12)
WALL_BOT_HI = 1 ; bottom wall high byte 0x01 (1)

WALL_LEFT  = 0+32   ; left wall
WALL_RIGHT = 25     ; right wall low byte  0x19 (25)
WALL_RIGHT_HI = 1   ; right wall high byte 0x01 (1)

BALL_PADDLEX_P1 = 62  ; P1 paddle surface X = 0x3E (62)
BALL_PADDLEX_P2 = 250 ; P2 paddle surface X = 0xFA (250)

PADDLE_WIDTH_P1 = 17
PADDLE_WIDTH_P2 = 6 ; xxxxx

;------------------------------------------------------------------------------;
; Platform-specific routine aliases
	HANDLE_GAME_INPUT = game_InputsGame_pce
	RENDER_BALL       = game_renderBall_pce
	RENDER_PADDLE     = game_renderPaddle_pce
	DRAW_FIELD        = game_drawField_pce
	UPDATE_SCORE_DISP = game_updateScoreDisplay_pce
	INPUT_DEBUG       = game_InputsGame_Debug_pce
	INPUT_ATTRACT     = game_InputsAttract_pce

;==============================================================================;
; Platform-specific data

; Starting sprite number for player 1 and 2
tbl_PaddleSpriteNum_pce:  .byte $01,$02

; Sprite tile indexes for paddle
; sprite tiles are loaded into VRAM at $2000
; actual address is addr>>5, so VRAM $2000 = tile addr $0100
tbl_PaddleTiles_pce:
	.word $2000>>5 ; top half
	.word $2040>>5 ; bottom half

; Starting paddle X positions for player 1 and 2
tbl_PaddleXPos: .byte 32+16,255

;==============================================================================;
; PCE sprite map:
; $00 - ball
; $01 - paddle 1 top 16x16
; $02 - paddle 1 bottom 16x16
; $03 - paddle 2 top 16x16
; $04 - paddle 2 bottom 16x16

;==============================================================================;
; game_InputsAttract_pce
; Handle controller inputs in attract mode.

game_InputsAttract_pce:
	; check for Run button on the first controller
	lda pce_padTrigger
	sta tmp00

	; run (bit 3)
	bbr3 tmp00,@game_InputsAttract_pce_CheckLeft

	; pressed Run, begin game
	lda #1
	sta inGame

	; don't allow left/right input after pressing Run
	bra @game_InputsAttract_pce_end

	; todo: handle left/right for changing maximum score
@game_InputsAttract_pce_CheckLeft:
	; left (bit 7)
	bbr7 tmp00,@game_InputsAttract_pce_CheckRight
	beq @game_InputsAttract_pce_CheckRight

	; pressed left; decrement score or wrap around to max
	lda maxScore
	cmp #GAME_MIN_SCORE
	bne @game_InputsAttract_pce_NormalLeft

	; wrap around
	lda #GAME_MAX_SCORE
	sta maxScore
	bra @game_InputsAttract_pce_CheckRight

@game_InputsAttract_pce_NormalLeft:
	dec maxScore
	bra @game_InputsAttract_pce_end

@game_InputsAttract_pce_CheckRight:
	; right (bit 5)
	bbr5 tmp00,@game_InputsAttract_pce_end
	beq @game_InputsAttract_pce_end

	; pressed right; increment score or wrap around to min
	lda maxScore
	cmp #GAME_MAX_SCORE
	bne @game_InputsAttract_pce_NormalRight

	; wrap around
	lda #GAME_MIN_SCORE
	sta maxScore
	bra @game_InputsAttract_pce_end

@game_InputsAttract_pce_NormalRight:
	inc maxScore

@game_InputsAttract_pce_end:
	rts

;==============================================================================;
; game_InputsGame_pce
; PCE controller input handler

; (Params)
; X - player number (0=p1, 1=p2)

game_InputsGame_pce:
	; save copies of inputs for operation later
	lda pce_padTrigger,x
	sta tmp01
	lda pce_padState,x
	sta tmp00

	; check if paused
	lda gamePaused
	beq @game_InputsGame_pce_Normal
	; if paused, only check for start/run (bit 3)
	bbs3 tmp01,@game_InputsGame_pce_Unpause
	rts

@game_InputsGame_pce_Unpause:
	stz gamePaused
	rts


@game_InputsGame_pce_Normal:
	; check for up (bit 4)
	bbr4 tmp00,@game_InputsGame_pce_CheckDown

	; pressed up
	lda player1Y,x
	cmp #PADDLE_MIN_Y_POS
	bcc @game_InputsGame_pce_ForceMin

	dec player1Y,x
	lda player1Y,x
	cmp #PADDLE_MIN_Y_POS
	bcc @game_InputsGame_pce_ForceMin

	dec player1Y,x
	lda player1Y,x
	cmp #PADDLE_MIN_Y_POS
	bcc @game_InputsGame_pce_ForceMin

	bra @game_InputsGame_pce_Run

@game_InputsGame_pce_ForceMin:
	lda #PADDLE_MIN_Y_POS
	sta player1Y,x
	bra @game_InputsGame_pce_end

@game_InputsGame_pce_CheckDown:
	; check for down (bit 6)
	bbr6 tmp00,@game_InputsGame_pce_Run

	; pressed down
	lda player1Y,x
	cmp #PADDLE_MAX_Y_POS
	bcs @game_InputsGame_pce_ForceMax

	inc player1Y,x
	lda player1Y,x
	cmp #PADDLE_MAX_Y_POS
	bcs @game_InputsGame_pce_ForceMax

	inc player1Y,x
	lda player1Y,x
	cmp #PADDLE_MAX_Y_POS
	bcs @game_InputsGame_pce_ForceMax

	bra @game_InputsGame_pce_Run

@game_InputsGame_pce_ForceMax:
	lda #PADDLE_MAX_Y_POS
	sta player1Y,x

@game_InputsGame_pce_Run:
	; check for start/run (bit 3)
	bbr3 tmp01,@game_InputsGame_pce_Debug

	lda #1
	sta gamePaused

@game_InputsGame_pce_Debug:
	.ifdef __DEBUGMODE__
	; check for select (bit 2)
	bbr2 tmp01,@game_InputsGame_pce_end

	; pressed select, enable debug mode
	lda #1
	sta p1Debug

	lda ballDir
	sta lastBallDir
	stz ballDir
	.endif

@game_InputsGame_pce_end:
	rts

;==============================================================================;
; game_InputsGame_Debug_pce
; debugger input mode: move the ball!

game_InputsGame_Debug_pce:
	.ifdef __DEBUGMODE__
	; gimme back my input
	lda pce_padTrigger
	sta tmp01
	lda pce_padState
	sta tmp00

	; up (bit 4)
	bbr4 tmp00,@game_InputsGame_Debug_pce_right

	; ball up
	dec ballY
	lda ballY
	cmp #$FF
	bne @game_InputsGame_Debug_pce_right

@game_InputsGame_Debug_pce_Y_Up_Under256:
	stz ballY_Hi
	bra @game_InputsGame_Debug_pce_right

@game_InputsGame_Debug_pce_right:
	; right (bit 5)
	bbr5 tmp00,@game_InputsGame_Debug_pce_down

	; ball right
	inc ballX
	lda ballX
	bne @game_InputsGame_Debug_pce_down

	lda #1
	sta ballX_Hi
	stz ballX

@game_InputsGame_Debug_pce_down:
	; down (bit 6)
	bbr6 tmp00,@game_InputsGame_Debug_pce_left

	; ball down
	inc ballY
	bne @game_InputsGame_Debug_pce_left

@game_InputsGame_Debug_pce_Y_Down_Past256:
	lda #1
	sta ballY_Hi
	stz ballY

@game_InputsGame_Debug_pce_left:
	; left (bit 7)
	bbr7 tmp00,@game_InputsGame_Debug_pce_run

	; ball left
	dec ballX
	lda ballX
	cmp #$FF
	bne @game_InputsGame_Debug_pce_run

	stz ballX_Hi

@game_InputsGame_Debug_pce_run:
	; start/run (bit 3)
	bbr3 tmp01,@game_InputsGame_Debug_pce_select

	lda #1
	sta gamePaused

@game_InputsGame_Debug_pce_select:
	; select (bit 2)
	bbr2 tmp01,@game_InputsGame_Debug_pce_end

	stz p1Debug
	lda lastBallDir
	sta ballDir

@game_InputsGame_Debug_pce_end:
	.endif
	rts

;==============================================================================;
; game_renderBall_pce
; PCE version of ball renderer.

game_renderBall_pce:
	; using sprite 0
	cly

	;-- y position --;
	; todo: this is somewhat broken?
	lda ballY
	sta pce_satbBuf,y
	iny
	lda ballY_Hi
	sta pce_satbBuf,y
	iny

	;-- x position --;
	; todo: this is somewhat broken?
	lda ballX
	sta pce_satbBuf,y
	iny
	lda ballX_Hi
	sta pce_satbBuf,y
	iny

	;-- pattern address --;
	lda #<($2100>>5)
	sta pce_satbBuf,y
	iny
	lda #>($2100>>5)
	sta pce_satbBuf,y
	iny

	;-- attributes --;
	; (set priority=1 so the ball appears over the background. all other values can be 0)
	lda #<%0000000010000000
	sta pce_satbBuf,y
	iny
	lda #>%0000000010000000
	sta pce_satbBuf,y

	rts

;==============================================================================;
; game_renderPaddle_pce
; PCE version of paddle renderer.

; (Params)
; X - Player number (0=p1, 1=p2)

; (Notes)
; - 16x32 sprite size
; - both paddles share same palette

game_renderPaddle_pce:
	; set up pointer to tile values
	lda #<tbl_PaddleTiles_pce
	ldy #>tbl_PaddleTiles_pce
	sta tmp00
	sty tmp01

	; get tile values
	txa
	asl
	tay
	lda (tmp00),y
	sta tmp02
	iny
	lda (tmp00),y
	sta tmp03

	; get starting sprite number
	lda tbl_PaddleSpriteNum_pce,x
	; get starting index into pce_satbBuf (one sprite = 8 bytes)
	asl
	asl
	asl
	tay

	;-- Y position --;
	lda player1Y,x
	sta pce_satbBuf,y
	iny
	lda #0
	sta pce_satbBuf,y
	iny

	;-- X position --;
	lda tbl_PaddleXPos,x
	sta pce_satbBuf,y
	iny
	lda #0
	sta pce_satbBuf,y
	iny

	;-- Tile Address --;
	lda tmp02
	sta pce_satbBuf,y
	iny
	lda tmp03
	sta pce_satbBuf,y
	iny

	;-- Attributes --;
	;%0001000010000000
	; |x|||xx||xxx|__|
	; | |||  ||     |
	; | |||  ||     +-- palette
	; | |||  |+-------- priority
	; | |||  +--------- sprite width
	; | ||+------------ horiz. flip
	; | ++------------- sprite height
	; +---------------- vert. flip
	lda #<%0001000010000000
	sta pce_satbBuf,y
	iny
	lda #>%0001000010000000
	sta pce_satbBuf,y

	rts

;==============================================================================;
; game_drawField_pce
; Handles drawing the game field on PCE.

game_drawField_pce:
	;-- horizontal top line ($0060) --;
	st0 #VDCREG_MAWR
	st1 #<((32*3))
	st2 #>((32*3))

	st0 #VDCREG_VRWD
	; tiles $0148,$0149,$014A,$014B
	st1 #<$0148
	st2 #>$0148
	st1 #<$0149
	st2 #>$0149
	st1 #<$014A
	st2 #>$014A
	st1 #<$014B
	st2 #>$014B

	; tile $0103 x24
	clx
@game_drawField_pce_top:
	st1 #<$0103
	st2 #>$0103
	inx
	cpx #24
	bne @game_drawField_pce_top

	; tiles $014C,$014D,$014E,$014F
	st1 #<$014C
	st2 #>$014C
	st1 #<$014D
	st2 #>$014D
	st1 #<$014E
	st2 #>$014E
	st1 #<$014F
	st2 #>$014F

	;-- horizontal bottom line ($0340) --;
	st0 #VDCREG_MAWR
	st1 #<((32*26))
	st2 #>((32*26))

	st0 #VDCREG_VRWD
	; tiles $0148,$0149,$014A,$014B
	st1 #<$0148
	st2 #>$0148
	st1 #<$0149
	st2 #>$0149
	st1 #<$014A
	st2 #>$014A
	st1 #<$014B
	st2 #>$014B

	; tile $0103 x24
	clx
@game_drawField_pce_bot:
	st1 #<$0103
	st2 #>$0103
	inx
	cpx #24
	bne @game_drawField_pce_bot

	; tiles $014C,$014D,$014E,$014F
	st1 #<$014C
	st2 #>$014C
	st1 #<$014D
	st2 #>$014D
	st1 #<$014E
	st2 #>$014E
	st1 #<$014F
	st2 #>$014F

	; set increment for vertical tiles
	st0 #VDCREG_CR
	st1 #<(VDC_CR_VBL|VDC_CR_SPR|VDC_CR_BG|VDC_CR_INC_32)
	st2 #>(VDC_CR_VBL|VDC_CR_SPR|VDC_CR_BG|VDC_CR_INC_32)

	;-- vertical middle line 1/2 ($????) --;
	st0 #VDCREG_MAWR
	st1 #<((32*3)+15)
	st2 #>((32*3)+15)

	; tile $0104,$0108,$010A x1 each
	st0 #VDCREG_VRWD
	st1 #<$0104
	st2 #>$0104
	st1 #<$2108
	st2 #>$2108
	st1 #<$210A
	st2 #>$210A

	; tile $010C x17
	clx
@game_drawField_pce_mid1:
	st1 #<$210C
	st2 #>$210C
	inx
	cpx #17
	bne @game_drawField_pce_mid1

	; tiles $010E,$0144,$0146,$0106 x1
	st1 #<$210E
	st2 #>$210E
	st1 #<$2144
	st2 #>$2144
	st1 #<$2146
	st2 #>$2146
	st1 #<$0106
	st2 #>$0106

	;-- vertical middle line 2/2 ($????) --;
	st0 #VDCREG_MAWR
	st1 #<((32*3)+16)
	st2 #>((32*3)+16)

	; tile $0105,$0109,$010B x1 each
	st0 #VDCREG_VRWD
	st1 #<$0105
	st2 #>$0105
	st1 #<$2109
	st2 #>$2109
	st1 #<$210B
	st2 #>$210B

	; tile $010D x17
	clx
@game_drawField_pce_mid2:
	st1 #<$210D
	st2 #>$210D
	inx
	cpx #17
	bne @game_drawField_pce_mid2

	; tiles $010F,$0145,$0147,$0107 x1
	st1 #<$210F
	st2 #>$210F
	st1 #<$2145
	st2 #>$2145
	st1 #<$2147
	st2 #>$2147
	st1 #<$0107
	st2 #>$0107

	; reset increment for horizontal tiles
	st0 #VDCREG_CR
	st1 #<(VDC_CR_VBL|VDC_CR_SPR|VDC_CR_BG|VDC_CR_INC_1)
	st2 #>(VDC_CR_VBL|VDC_CR_SPR|VDC_CR_BG|VDC_CR_INC_1)

	rts

;==============================================================================;
; game_updateScoreDisplay_pce
; Update score display (PCE version)

game_updateScoreDisplay_pce:
	; set increment for vertical tiles
	st0 #VDCREG_CR
	st1 #<(VDC_CR_VBL|VDC_CR_SPR|VDC_CR_BG|VDC_CR_INC_32)
	st2 #>(VDC_CR_VBL|VDC_CR_SPR|VDC_CR_BG|VDC_CR_INC_32)

	;-- update player 1 score display --;
	; (digit 1: 12,5)
	st0 #VDCREG_MAWR
	st1 #<((32*5)+12)
	st2 #>((32*5)+12)

	st0 #VDCREG_VRWD
	lda scoreP1
	and #$F0
	lsr
	lsr
	lsr
	tay
	lda tbl_scoreTiles_Top,y
	sta a:VDC_DATA_LO
	iny
	lda tbl_scoreTiles_Top,y
	sta a:VDC_DATA_HI
	dey
	lda tbl_scoreTiles_Bot,y
	sta a:VDC_DATA_LO
	iny
	lda tbl_scoreTiles_Bot,y
	sta a:VDC_DATA_HI

	; (digit 2: 13,5)
	st0 #VDCREG_MAWR
	st1 #<((32*5)+13)
	st2 #>((32*5)+13)

	st0 #VDCREG_VRWD
	lda scoreP1
	and #$0F
	asl
	tay
	lda tbl_scoreTiles_Top,y
	sta a:VDC_DATA_LO
	iny
	lda tbl_scoreTiles_Top,y
	sta a:VDC_DATA_HI
	dey
	lda tbl_scoreTiles_Bot,y
	sta a:VDC_DATA_LO
	iny
	lda tbl_scoreTiles_Bot,y
	sta a:VDC_DATA_HI

	; update player 2 score display
	; (digit 1: 18,5)
	st0 #VDCREG_MAWR
	st1 #<((32*5)+18)
	st2 #>((32*5)+18)

	st0 #VDCREG_VRWD
	lda scoreP2
	and #$F0
	lsr
	lsr
	lsr
	tay
	lda tbl_scoreTiles_Top,y
	sta a:VDC_DATA_LO
	iny
	lda tbl_scoreTiles_Top,y
	sta a:VDC_DATA_HI
	dey
	lda tbl_scoreTiles_Bot,y
	sta a:VDC_DATA_LO
	iny
	lda tbl_scoreTiles_Bot,y
	sta a:VDC_DATA_HI

	; (digit 2: 19,5)
	st0 #VDCREG_MAWR
	st1 #<((32*5)+19)
	st2 #>((32*5)+19)

	st0 #VDCREG_VRWD
	lda scoreP2
	and #$0F
	asl
	tay
	lda tbl_scoreTiles_Top,y
	sta a:VDC_DATA_LO
	iny
	lda tbl_scoreTiles_Top,y
	sta a:VDC_DATA_HI
	dey
	lda tbl_scoreTiles_Bot,y
	sta a:VDC_DATA_LO
	iny
	lda tbl_scoreTiles_Bot,y
	sta a:VDC_DATA_HI

@game_updateScoreDisplay_pce_end:
	; reset increment for horizontal tiles
	st0 #VDCREG_CR
	st1 #<(VDC_CR_VBL|VDC_CR_SPR|VDC_CR_BG|VDC_CR_INC_1)
	st2 #>(VDC_CR_VBL|VDC_CR_SPR|VDC_CR_BG|VDC_CR_INC_1)

	rts
