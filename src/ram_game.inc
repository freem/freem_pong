; game-specific ram defines
;==============================================================================;
; zero page
	.zeropage

	player1Y:   .res 1 ; player 1 paddle Y position
	player2Y:   .res 1 ; player 2 paddle Y position

	ballStatus: .res 1 ; ball status (0:active, 1:passed a side)

	ballX:      .res 1 ; ball X location
	ballY:      .res 1 ; ball Y location

	; PCE-specific:
	; PCE sprite X and Y positions are 10 bits instead of 8.
	.ifdef __PCE__
	ballX_Hi:   .res 1 ; ball X location (high byte)
	ballY_Hi:   .res 1 ; ball Y location (high byte)
	.endif

	ballDir:    .res 1 ; ball direction
	; currently trying to determine the best way to handle this.
	; - the ball will never go straight up or down, so we can rule those out.
	; - a value of 0 means the ball stopped moving (e.g. it's passed a side).

	; ballDir diagram: (numbers go clockwise)
	; \---N---/
	; | 6 x 1 | Y-1
	; W 5 0 2 E ---
	; | 4 x 3 | Y+1
	; /---S---\
	; X-1 | X+1

	; the paddle is meant to have 8 sections..
	;---+
	;  1| high angle /
	;---+
	;  2| medium angle /
	;---+
	;  3| low angle /
	;---+
	;  4|
	;  4| head-on
	;  4| (do NOT apply directly to forehead)
	;---+
	;  5| low angle \
	;---+
	;  6| medium angle \
	;---+
	;  7| high angle \
	;---+

	ballSpeed:  .res 1 ; ball speed ($XY)

	p1HitboxMinY: .res 1 ; player 1 hitbox top point
	p2HitboxMinY: .res 1 ; player 2 hitbox top point

	p1HitboxMaxY: .res 1 ; player 1 hitbox bottom point
	p2HitboxMaxY: .res 1 ; player 2 hitbox bottom point

	runTimers:    .res 1 ; are timers active?
	timer1:       .res 1 ; general purpose 8-bit timer
	timer2:       .res 1 ; general purpose 8-bit timer

	randomSeed:   .res 1 ; 8-bit random seed

;==============================================================================;
; regular ram
	.bss

	inGame:     .res 1 ; currently in game? (0=no, 1=yes)
	maxScore:   .res 1 ; score to win
	scoreP1:    .res 1 ; player 1 score
	scoreP2:    .res 1 ; player 2 score
	curServe:   .res 1 ; who has current serve? (0=p1, 1=p2)

;------------------------------------------------------------------------------;
; Debug functionality behind an assemble-time flag
	.ifdef __DEBUGMODE__
	p1Debug:     .res 1 ; debugging feature
	lastBallDir: .res 1 ; last ball state
	.endif
