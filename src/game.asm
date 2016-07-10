; game code (Main)
;==============================================================================;
; current status: get the game part working first before the damned menu system
;==============================================================================;
; shared defines
DEFAULT_GAME_MAX_SCORE = 5 ; todo: allow this to be configurable in-game
GAME_MIN_SCORE = 5
GAME_MAX_SCORE = 15

BALL_SPEED_START = $11 ; X speed = 1, Y speed = 1
BALL_SPEED_MAX   = $99 ; to be determined later

SPEED_Y_ADD_PADDLE_TOPMAX = $02
SPEED_Y_ADD_PADDLE_TOPMID = $01
SPEED_Y_ADD_PADDLE_TOPMIN = $01
SPEED_Y_ADD_PADDLE_BOTMIN = $01
SPEED_Y_ADD_PADDLE_BOTMID = $01
SPEED_Y_ADD_PADDLE_BOTMAX = $02

SPEED_X_ADD_PADDLE = $10

;==============================================================================;
; shared data

; table for use with wall reflection
tbl_BallDir_ReflectY:      .byte 0,3,2,1,6,5,4

; tables for use with ball collision
tbl_PaddleDir_SectionTop: .byte 1,6
tbl_PaddleDir_SectionMid: .byte 2,5
tbl_PaddleDir_SectionBot: .byte 3,4

; pointer table for ball direction changes
ptbl_BallDirUpdate:
	.addr dummyRTS
	.addr game_updateBall_Dir1 ; northeast
	.addr game_updateBall_Dir2 ; east
	.addr game_updateBall_Dir3 ; southeast
	.addr game_updateBall_Dir4 ; southwest
	.addr game_updateBall_Dir5 ; west
	.addr game_updateBall_Dir6 ; northwest

;==============================================================================;
game_setup:
	jsr DRAW_FIELD ; draw field
	jsr sound_StopAll ; stop sound

	jsr randNum ; poke the random number generator

	;-- perform necessary setup --;
	; reset scores
	lda #0
	.ifdef __DEBUGMODE__
	sta p1Debug
	.endif
	sta scoreP1
	sta scoreP2

	; set default max score
	lda #DEFAULT_GAME_MAX_SCORE
	sta maxScore

	; set default player Y
	lda #PADDLE_DEFAULT_Y_POS
	sta player1Y
	sta player2Y

	; set ball variables
	ldx #BALL_DEFAULT_X
	ldy #BALL_DEFAULT_Y
	stx ballX
	sty ballY
	lda #0
	.ifdef __PCE__
	sta ballX_Hi
	sta ballY_Hi
	.endif
	sta ballStatus
	sta ballDir

	lda #$11
	sta ballSpeed

	; zero out timers
	lda #0
	sta runTimers
	sta timer1
	sta timer2
	; game not paused
	sta gamePaused

	; temporary: get the game part working first before the damned menu system
	;--------------------------------------------------------------------------;
	lda #1
	sta inGame

	; mainly for trying to debug PCE version
	lda #0
	sta curServe
	jsr game_newServe ; and serve the ball
	;--------------------------------------------------------------------------;

	jsr randNum ; poke the random number generator

	; I'd rather not split this part out, actually.
	.ifdef __NES__
		; reset PPU address so scrolling doesn't botch up
		lda #0
		sta PPU_ADDR
		sta PPU_ADDR

		;-- enable NMIs, put sprites on PPU $1000 --;
		lda int_ppuCtrl
		ora #%10001000
		sta int_ppuCtrl
		sta PPU_CTRL

		; turn ppu on
		lda int_ppuMask
		ora #%00011110
		sta int_ppuMask
		sta PPU_MASK
	.else
		.ifdef __PCE__
		;-- re-enable interrupts --;
		lda #1 ; inhibit IRQ2, allow IRQ1 and Timer
		sta IRQ_DISABLE
		stz IRQ_STATUS
		cli

		;-- Turn on display --;
		st0 #VDCREG_CR
		;%0000000011001000/$04C8
		lda #<(VDC_CR_VBL|VDC_CR_SPR|VDC_CR_BG|VDC_CR_INC_1)
		sta a:VDC_DATA_LO
		sta int_vdcCtrl
		lda #>(VDC_CR_VBL|VDC_CR_SPR|VDC_CR_BG|VDC_CR_INC_1)
		sta a:VDC_DATA_HI
		sta int_vdcCtrl+1
		.endif
	.endif

	; execution continues into game loop
;==============================================================================;
; game_MainLoop
; Main loop, which should only be run once...?

game_MainLoop:
	jsr UPDATE_SCORE_DISP

	; inGame==0 and inGame==1 need to behave differently.
	lda inGame
	beq game_AttractLoop
	bne game_GameLoop

@game_MainLoop_end:
	mac_alwaysjump game_MainLoop

;==============================================================================;
; game_AttractLoop
; Attract mode execution loop.

game_AttractLoop:
	;-- things to do before vblank --;
	jsr INPUT_ATTRACT

;------------------------------------------------------------------------------;
@game_AttractLoop_VBlank:
	; wait for vblank
	jsr randNum ; poke the random number generator
	jsr waitVBlank

;------------------------------------------------------------------------------;
@game_AttractLoop_PostVBlank:
	;-- things to do after vblank --;
	.ifdef __NES__
	jsr ppu_ClearVRAMBuf
	.endif

	jsr ReadPads

;------------------------------------------------------------------------------;
@game_AttractLoop_end:
	mac_alwaysjump game_AttractLoop

;==============================================================================;
; game_GameLoop
; Game mode execution loop.

game_GameLoop:
	;-- things to do before vblank --;
	jsr game_InputsGame

	lda gamePaused
	bne @game_GameLoop_VBlank

	jsr game_updatePaddles
	jsr game_updateBall

	lda runTimers
	beq @game_GameLoop_VBlank

@game_GameLoop_Timers:
	inc timer1
	lda timer1
	cmp #80
	bne @game_GameLoop_VBlank

	; ok, timer is done
	lda #0
	sta timer1
	sta timer2
	sta runTimers

	
	jsr game_newServe

;------------------------------------------------------------------------------;
@game_GameLoop_VBlank:
	; wait for vblank
	jsr randNum ; poke the random number generator
	jsr waitVBlank

;------------------------------------------------------------------------------;
@game_GameLoop_postVBlank:
	;-- things to do after vblank --;
	.ifdef __NES__
	jsr ppu_ClearVRAMBuf
	.endif

	jsr ReadPads

;------------------------------------------------------------------------------;
@game_GameLoop_end:
	mac_alwaysjump game_GameLoop

;==============================================================================;
; game_startNew
; Starts a new game.

game_startNew:
	jsr randNum ; poke the random number generator

	;-- initialize game variables --;
	; set scores
	lda #0
	sta scoreP1
	sta scoreP2
	; set default max score
	lda #DEFAULT_GAME_MAX_SCORE
	sta maxScore

	; set default player Y
	lda #PADDLE_DEFAULT_Y_POS
	sta player1Y
	sta player2Y

	; set game as active
	lda #1
	sta inGame

	; set curServe based off of a random value (0/1)
	jsr randNum ; poke the random number generator
	and #1 ; the extra free throw after a foul in basketball.
	sta curServe
	jsr game_newServe ; and serve the ball

	mac_alwaysjump game_GameLoop ; go back to the game loop.

;==============================================================================;
; game_InputsGame
; Handle controller inputs in game mode.

game_InputsGame:
	.ifdef __DEBUGMODE__
	lda p1Debug
	beq @game_InputsGame_normal

	; debugger mode: p1 moves ball
	jsr INPUT_DEBUG
	jmp @game_InputsGame_p2
	.endif

@game_InputsGame_normal:
	; controller 1
	ldx #0
	jsr HANDLE_GAME_INPUT
@game_InputsGame_p2:
	; controller 2
	ldx #1
	jmp HANDLE_GAME_INPUT

;==============================================================================;
; game_updateBall
; Update ball position and other variables. Also renders the ball.

game_updateBall:
	lda ballDir
	bne @game_updateBall_CheckCollisions
	.ifdef __DEBUGMODE__
	lda p1Debug
	bne @game_updateBall_CheckCollisions
	.endif
	rts

@game_updateBall_CheckCollisions:
	;-- check for collisions --;
	; [wall collisions (ballY)]
	.ifdef __PCE__
	lda ballY_Hi
	bne @game_updateBall_CheckWallBottom
	.endif
	lda ballY
	cmp #WALL_TOP
	beq @game_updateBall_CollideTopWall
	bcs @game_updateBall_CheckWallBottom

@game_updateBall_CollideTopWall:
	; collided with top wall; change vertical direction
	ldy ballDir
	lda tbl_BallDir_ReflectY,y
	sta ballDir

	; keep ball in-bounds if the speed makes the ball go out of bounds
	.ifdef __PCE__
	lda ballY_Hi
	bne @game_updateBall_CheckWallBottom
	.endif
	lda ballY
	cmp #WALL_TOP
	bcs @game_updateBall_CheckWallBottom

@game_updateBall_FixPosition_Top:
	; todo: this isn't perfect, but it works for now
	lda #WALL_TOP
	sta ballY
	.ifdef __PCE__
	stz ballY_Hi
	.endif
	jmp @game_updateBall_CheckPaddle

@game_updateBall_CheckWallBottom:
	.ifdef __PCE__
	lda ballY_Hi
	beq @game_updateBall_CheckPaddle
	.endif
	lda ballY
	cmp #WALL_BOT
	bcc @game_updateBall_CheckPaddle

@game_updateBall_CollideBotWall:
	; collided with bottom wall; change vertical direction
	ldy ballDir
	lda tbl_BallDir_ReflectY,y
	sta ballDir

	; keep ball in-bounds if the speed makes the ball go out of bounds
	; todo: PCE check
	lda ballY
	cmp #WALL_BOT
	beq @game_updateBall_CheckPaddle
	bcs @game_updateBall_FixPosition_Bot

@game_updateBall_FixPosition_Bot:
	; todo: this isn't perfect
	lda #WALL_BOT
	sta ballY
	.ifdef __PCE__
	lda #WALL_BOT_HI
	sta ballY_Hi
	.endif

@game_updateBall_CheckPaddle:
	; [player collisions (ballX and ballY)]
	ldx #0
	jsr game_ballToPlayerCollisionCheck
	ldx #1
	jsr game_ballToPlayerCollisionCheck

	; [screen boundaries (ballX)]
@game_updateBall_CheckLeft:
	.ifdef __PCE__
	lda ballX_Hi
	bne @game_updateBall_CheckRight
	.endif
	lda ballX
	cmp #WALL_LEFT
	bne @game_updateBall_CheckRight

	; P2 scored on P1
	lda #0
	sta ballDir
	; set curServe to player who got scored on
	sta curServe
	; add point and update score display
	inc scoreP2
	jsr UPDATE_SCORE_DISP

	; set timers
	lda #1
	sta runTimers
	lda #0
	sta timer1
	sta timer2

	jmp game_updateBall_render

@game_updateBall_CheckRight:
	.ifdef __PCE__
	lda ballX_Hi
	cmp #WALL_RIGHT_HI
	bne @game_updateBall_move
	.endif
	lda ballX
	cmp #WALL_RIGHT
	bne @game_updateBall_move

	; P1 scored on P2
	lda #0
	sta ballDir
	; set curServe to player who got scored on
	lda #1
	sta curServe
	; add point and update score display
	inc scoreP1
	jsr UPDATE_SCORE_DISP

	; set timers
	lda #1
	sta runTimers
	lda #0
	sta timer1
	sta timer2

	jmp game_updateBall_render

@game_updateBall_move:
	;-- do ball movement --;

	; check for direction 0 (ball has passed side)
	lda ballDir
	beq game_updateBall_render

	; ballDir diagram: (numbers go clockwise)
	; \---N---/
	; | 6 x 1 | Y-1
	; W 5 0 2 E ---
	; | 4 x 3 | Y+1
	; /---S---\
	; X-1 | X+1

	; (ballSpeed & 0xF0) >> 4 = X speed
	; (ballSpeed & 0x0F) = Y speed

	lda ballDir
	asl
	tay
	lda ptbl_BallDirUpdate,y
	sta tmp00
	iny
	lda ptbl_BallDirUpdate,y
	sta tmp01
	.ifdef __NES__
		jmp (tmp00)
	.else
		.ifdef __PCE__
		jmp (tmp00+__PCE_ZP_START__)
		.endif
	.endif

game_updateBall_render:
	; on PCE, set the upper part of the X/Y positions
	.ifdef __PCE__
	lda ballX
	beq @game_updateBall_X_Past256
	cmp #$FF
	beq @game_updateBall_X_Under256
	bra @game_updateBall_CheckY

@game_updateBall_X_Past256:
	lda #1
	sta ballX_Hi
	stz ballX
	bra @game_updateBall_CheckY

@game_updateBall_X_Under256:
	stz ballX_Hi

@game_updateBall_CheckY:
	lda ballY
	beq @game_updateBall_Y_Past256
	cmp #$FF
	beq @game_updateBall_Y_Under256
	bra game_updateBall_render_real

@game_updateBall_Y_Past256:
	lda #1
	sta ballY_Hi
	bra game_updateBall_render_real

@game_updateBall_Y_Under256:
	stz ballY_Hi
	.endif

game_updateBall_render_real:
	;-- render ball --;
	jmp RENDER_BALL

;------------------------------------------------------------------------------;
; game_updateBall_Dir1
; ballDir 1: +X -Y

game_updateBall_Dir1:
	; update X
	lda ballSpeed
	and #$F0
	lsr
	lsr
	lsr
	lsr
	clc
	adc ballX
	sta ballX

@game_updateBall_Dir1_UpdateY:
	; update Y
	lda ballSpeed
	and #$0F
	sta tmp00
	sec
	lda ballY
	sbc tmp00
	sta ballY

@game_updateBall_Dir1_end:
	jmp game_updateBall_render

;------------------------------------------------------------------------------;
; game_updateBall_Dir2
; ballDir 2: +X 0Y

game_updateBall_Dir2:
	; update X
	lda ballSpeed
	and #$F0
	lsr
	lsr
	lsr
	lsr
	clc
	adc ballX
	sta ballX

	; PCE: update ballX_Hi
	.ifdef __PCE__
	.endif

	; don't update Y

@game_updateBall_Dir2_end:
	jmp game_updateBall_render

;------------------------------------------------------------------------------;
; game_updateBall_Dir3
; ballDir 3: +X +Y

game_updateBall_Dir3:
	; update X
	lda ballSpeed
	and #$F0
	lsr
	lsr
	lsr
	lsr
	clc
	adc ballX
	sta ballX

	; PCE: update ballX_Hi
	.ifdef __PCE__
	.endif

	; update Y
	lda ballSpeed
	and #$0F
	clc
	adc ballY
	sta ballY

	; PCE: update ballY_Hi
	.ifdef __PCE__
	.endif

@game_updateBall_Dir3_end:
	jmp game_updateBall_render

;------------------------------------------------------------------------------;
; game_updateBall_Dir4
; ballDir 4: -X +Y

game_updateBall_Dir4:
	; update X
	lda ballSpeed
	and #$F0
	lsr
	lsr
	lsr
	lsr
	sta tmp00
	sec
	lda ballX
	sbc tmp00
	sta ballX

	; PCE: update ballX_Hi
	.ifdef __PCE__
	.endif

	; update Y
	lda ballSpeed
	and #$0F
	clc
	adc ballY
	sta ballY

	; PCE: update ballY_Hi
	.ifdef __PCE__
	.endif

@game_updateBall_Dir4_end:
	jmp game_updateBall_render

;------------------------------------------------------------------------------;
; game_updateBall_Dir5
; ballDir 5: -X 0Y

game_updateBall_Dir5:
	; update X
	lda ballSpeed
	and #$F0
	lsr
	lsr
	lsr
	lsr
	sta tmp00
	sec
	lda ballX
	sbc tmp00
	sta ballX

	; PCE: update ballX_Hi
	.ifdef __PCE__
	.endif

	; don't update Y

@game_updateBall_Dir5_end:
	jmp game_updateBall_render

;------------------------------------------------------------------------------;
; game_updateBall_Dir6
; ballDir 6: -X -Y

game_updateBall_Dir6:
	; update X
	lda ballSpeed
	and #$F0
	lsr
	lsr
	lsr
	lsr
	sta tmp00
	sec
	lda ballX
	sbc tmp00
	sta ballX

	; PCE: update ballX_Hi
	.ifdef __PCE__
	.endif

	; update Y
	lda ballSpeed
	and #$0F
	sta tmp00
	sec
	lda ballY
	sbc tmp00
	sta ballY

	; PCE: update ballY_Hi
	.ifdef __PCE__
	.endif

@game_updateBall_Dir6_end:
	jmp game_updateBall_render

;==============================================================================;
; game_ballToPlayerCollisionCheck
; Checks if the ball has hit the specified player's paddle.

; (Params)
; X - Player number (0=p1, 1=p2)

game_ballToPlayerCollisionCheck:
	; compare ballX to BALL_PADDLEX_P1 or BALL_PADDLEX_P2 as needed
	; remember to allow some leeway for faster ball speeds
	cpx #1
	beq @game_ballToPlayerCollisionCheck_CheckP2X

	; player 1 X check
	.ifdef __PCE__
	lda ballX_Hi
	beq @game_ballToPlayerCollisionCheck_CheckP1X_Part1
	rts
	.endif

@game_ballToPlayerCollisionCheck_CheckP1X_Part1:
	lda ballX
	cmp #BALL_PADDLEX_P1
	bcc @game_ballToPlayerCollisionCheck_CheckP1X_Part2
	beq @game_ballToPlayerCollisionCheck_CheckP1X_Part2
	jmp @game_ballToPlayerCollisionCheck_end

@game_ballToPlayerCollisionCheck_CheckP1X_Part2:
	; perform behind P1 check
	lda ballX
	cmp #BALL_PADDLEX_P1-PADDLE_WIDTH_P1
	bcs @game_ballToPlayerCollisionCheck_CheckYMin
	jmp @game_ballToPlayerCollisionCheck_end

;------------------------------------------------------------------------------;
@game_ballToPlayerCollisionCheck_CheckP2X:
	; player 2 X check
	.ifdef __PCE__
	lda ballX_Hi
	bne @game_ballToPlayerCollisionCheck_CheckP2X_Part3 ; high X > 0: check for behind p2 paddle
	.endif

	; high X = 0: check for surface
@game_ballToPlayerCollisionCheck_CheckP2X_Part2:
	lda ballX
	cmp #BALL_PADDLEX_P2
	bcs @game_ballToPlayerCollisionCheck_CheckP2X_Part3
	jmp @game_ballToPlayerCollisionCheck_end

@game_ballToPlayerCollisionCheck_CheckP2X_Part3:
	; perform behind P2 check
	.ifdef __PCE__
	lda ballX_Hi
	bne @game_ballToPlayerCollisionCheck_CheckP2X_Part4
	rts
	.endif

@game_ballToPlayerCollisionCheck_CheckP2X_Part4:
	lda ballX
	.ifdef __NES__
	cmp #BALL_PADDLEX_P2+PADDLE_WIDTH_P2
	.else
		.ifdef __PCE__
			cmp #PADDLE_WIDTH_P2
		.endif
	.endif
	bcc @game_ballToPlayerCollisionCheck_CheckYMin
	beq @game_ballToPlayerCollisionCheck_CheckYMin
	jmp @game_ballToPlayerCollisionCheck_end

;------------------------------------------------------------------------------;
@game_ballToPlayerCollisionCheck_CheckYMin:
	; compare ballY to player's hitbox
	lda ballY
	cmp p1HitboxMinY,x
	beq @game_ballToPlayerCollisionCheck_CheckYMax
	bcs @game_ballToPlayerCollisionCheck_CheckYMax
	jmp @game_ballToPlayerCollisionCheck_end

	; ball Y is >= to the minimum hitbox, so check for the upper bound.
@game_ballToPlayerCollisionCheck_CheckYMax:
	lda ballY
	cmp p1HitboxMaxY,x
	bcc @game_ballToPlayerCollisionCheck_PaddleSection
	beq @game_ballToPlayerCollisionCheck_PaddleSection
	jmp @game_ballToPlayerCollisionCheck_end

;------------------------------------------------------------------------------;
@game_ballToPlayerCollisionCheck_PaddleSection:
	; at this point, the ball has hit the paddle. check which section.
	lda ballY
	sec
	sbc p1HitboxMinY,x
	sta tmp00

	; Section 1: 0-3px
	cmp #3
	bcc @game_ballToPlayerCollisionCheck_DoSection1
	beq @game_ballToPlayerCollisionCheck_DoSection1
	jmp @game_ballToPlayerCollisionCheck_Section2

@game_ballToPlayerCollisionCheck_DoSection1:
	; high angle {(up+left),(up+right)}
	lda tbl_PaddleDir_SectionTop,x
	sta ballDir

	; ballSpeed = (X) | SPEED_Y_ADD_PADDLE_TOPMAX
	lda ballSpeed
	and #$F0
	ora #SPEED_Y_ADD_PADDLE_TOPMAX
	sta ballSpeed

	jmp @game_ballToPlayerCollisionCheck_end

;------------------------------------------------------------------------------;
@game_ballToPlayerCollisionCheck_Section2:
	; Section 2: 4-7px
	lda tmp00
	cmp #7
	bcc @game_ballToPlayerCollisionCheck_DoSection2
	beq @game_ballToPlayerCollisionCheck_DoSection2
	jmp @game_ballToPlayerCollisionCheck_Section3

@game_ballToPlayerCollisionCheck_DoSection2:
	; medium angle {(up+left),(up+right)}
	lda tbl_PaddleDir_SectionTop,x
	sta ballDir

	; ballSpeed = (X) | SPEED_Y_ADD_PADDLE_TOPMID
	lda ballSpeed
	and #$F0
	ora #SPEED_Y_ADD_PADDLE_TOPMID
	sta ballSpeed

	jmp @game_ballToPlayerCollisionCheck_end

;------------------------------------------------------------------------------;
@game_ballToPlayerCollisionCheck_Section3:
	; Section 3: 8-11px
	lda tmp00
	cmp #11
	bcc @game_ballToPlayerCollisionCheck_DoSection3
	beq @game_ballToPlayerCollisionCheck_DoSection3
	jmp @game_ballToPlayerCollisionCheck_Section4

@game_ballToPlayerCollisionCheck_DoSection3:
	; low angle {(up+left),(up+right)}
	lda tbl_PaddleDir_SectionTop,x
	sta ballDir

	; ballSpeed = (X) | SPEED_Y_ADD_PADDLE_TOPMIN
	lda ballSpeed
	and #$F0
	ora #SPEED_Y_ADD_PADDLE_TOPMIN
	sta ballSpeed

	jmp @game_ballToPlayerCollisionCheck_end

;------------------------------------------------------------------------------;
@game_ballToPlayerCollisionCheck_Section4:
	; Section 4: 12-19px
	lda tmp00
	cmp #19
	bcc @game_ballToPlayerCollisionCheck_DoSection4
	beq @game_ballToPlayerCollisionCheck_DoSection4
	jmp @game_ballToPlayerCollisionCheck_Section5

@game_ballToPlayerCollisionCheck_DoSection4:
	; head-on {(left),(right)}
	lda tbl_PaddleDir_SectionMid,x
	sta ballDir

	jmp @game_ballToPlayerCollisionCheck_end

;------------------------------------------------------------------------------;
@game_ballToPlayerCollisionCheck_Section5:
	; Section 5: 20-23px
	lda tmp00
	cmp #23
	bcc @game_ballToPlayerCollisionCheck_DoSection5
	beq @game_ballToPlayerCollisionCheck_DoSection5
	jmp @game_ballToPlayerCollisionCheck_Section6

@game_ballToPlayerCollisionCheck_DoSection5:
	; low angle {(down+left),(down+right)}
	lda tbl_PaddleDir_SectionBot,x
	sta ballDir

	; ballSpeed = (X) | SPEED_Y_ADD_PADDLE_BOTMIN
	lda ballSpeed
	and #$F0
	ora #SPEED_Y_ADD_PADDLE_BOTMIN
	sta ballSpeed

	jmp @game_ballToPlayerCollisionCheck_end

;------------------------------------------------------------------------------;
@game_ballToPlayerCollisionCheck_Section6:
	; Section 6: 24-27px
	lda tmp00
	cmp #27
	bcc @game_ballToPlayerCollisionCheck_DoSection6
	beq @game_ballToPlayerCollisionCheck_DoSection6
	jmp @game_ballToPlayerCollisionCheck_Section7

@game_ballToPlayerCollisionCheck_DoSection6:
	; medium angle {(down+left),(down+right)}
	lda tbl_PaddleDir_SectionBot,x
	sta ballDir

	; ballSpeed = (X) | SPEED_Y_ADD_PADDLE_BOTMID
	lda ballSpeed
	and #$F0
	ora #SPEED_Y_ADD_PADDLE_BOTMID
	sta ballSpeed

	jmp @game_ballToPlayerCollisionCheck_end

;------------------------------------------------------------------------------;
@game_ballToPlayerCollisionCheck_Section7:
	; Section 7: 28-31px
	lda tmp00
	cmp #31
	bcc @game_ballToPlayerCollisionCheck_end
	beq @game_ballToPlayerCollisionCheck_end

	; high angle {(down+left),(down+right)}
	lda tbl_PaddleDir_SectionBot,x
	sta ballDir

	; ballSpeed = (X) | SPEED_Y_ADD_PADDLE_BOTMAX
	lda ballSpeed
	and #$F0
	ora #SPEED_Y_ADD_PADDLE_BOTMAX
	sta ballSpeed

;------------------------------------------------------------------------------;
@game_ballToPlayerCollisionCheck_end:
	; speed regulation

	rts

;==============================================================================;
; game_updatePaddles
; Update paddle variables and renders the paddles.

game_updatePaddles:
	; set player hitbox based on current Y position

	;-- player 1 hitbox --;
	lda player1Y
	sta p1HitboxMinY
	clc
	adc #32
	sta p1HitboxMaxY

	;-- player 2 hitbox --;
	lda player2Y
	sta p2HitboxMinY
	clc
	adc #32
	sta p2HitboxMaxY

	; render paddle sprites
	ldx #0
	jsr RENDER_PADDLE
	ldx #1
	jmp RENDER_PADDLE

;==============================================================================;
; game_newServe
; Serves the ball to a player.
; (called after the timer expires upon scoring a point.)

game_newServe:
	; reset ball position to the middle
	ldx #BALL_DEFAULT_X
	ldy #BALL_DEFAULT_Y
	stx ballX
	sty ballY

	.ifdef __PCE__
	lda #0
	sta ballX_Hi
	sta ballY_Hi
	.endif

	; after a score, service goes to the player scored upon.
	lda curServe
	beq @game_newServe_P1

	; pick a random direction based on curServe
@game_newServe_P2:
	; serve to player 2
	jsr randNum
	and #3
	bne @game_newServe_SetP2

@game_newServe_FixP2:
	; in case our random number gives us a 0 after we've ANDed it...
	adc #1

@game_newServe_SetP2:
	sta ballDir
	jmp @game_newServe_SetSpeed

@game_newServe_P1:
	; serve to player 1
	jsr randNum
	and #3
	clc
	adc #3
	sta ballDir

@game_newServe_SetSpeed:
	; reset ballSpeed to default start
	lda #$11
	sta ballSpeed

	rts ; and away we go!

;==============================================================================;
; platform specific code and defines
	.ifdef __NES__
		.include "game_nes.asm"
	.else
		.ifdef __PCE__
		.include "game_pce.asm"
		.endif
	.endif
