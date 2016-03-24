; Read Pads (NES)
;==============================================================================;
; nes_ReadPads_unsafe
; Reads P1 and P2 controllers (not DMC fortified; used by nes_ReadPads)

.proc nes_ReadPads_unsafe
	; strobe joypad
	lda #1
	sta JOYSTICK1
	lda #0
	sta JOYSTICK1

	ldx #8 ; read 8 buttons
@nes_ReadPads_unsafe_loop:
	lda JOYSTICK1
	and #$03 ; read P1 and Famicom P3 (which can be used as P1)
	cmp #$01
	rol tmp00

	lda JOYSTICK2
	and #$03 ; read P2 and Famicom P4 (which can be used as P2)
	cmp #$01
	rol tmp01

	dex
	bne @nes_ReadPads_unsafe_loop
	rts
.endproc

;==============================================================================;
; nes_ReadPads
; DMC-fortified P1 and P2 controller reading routine.

.proc nes_ReadPads
	; store previous keypress state
	lda nes_padState   ; player 1 from memory
	sta tmp04
	lda nes_padState+1 ; player 2 from memory
	sta tmp05

	; first pad read
	jsr nes_ReadPads_unsafe
	lda tmp00 ; save player 1 controls
	sta tmp02
	lda tmp01 ; save player 2 controls
	sta tmp03
	jsr nes_ReadPads_unsafe

	; compare pad reads
	ldx #1
@nes_ReadPads_FixKeys:
	lda tmp00,x ; second read
	cmp tmp02,x ; first read
	bne @nes_ReadPads_KeepLast
	sta nes_padState,x

@nes_ReadPads_KeepLast:
	lda tmp04,x ; load previous state
	eor #$FF    ; flip all bits
	and nes_padState,x ; mask with current keypress
	sta nes_padTrigger,x ; store in trigger
	dex
	bpl @nes_ReadPads_FixKeys

	rts
.endproc
