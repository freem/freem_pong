; Read Pads (PC-Engine)
;==============================================================================;
; pce_PadReadDelay
; "9 cycles delay before reading data after SEL line update."

.macro pce_PadReadDelay
	nop
	pha
	pla
	nop
.endmacro

;==============================================================================;
; pce_ReadPads
; PC-Engine 2 button pad reading routine.

.proc pce_ReadPads
	; strobe joypad
	lda #1
	sta JOYPAD
	lda #3
	sta JOYPAD
	pce_PadReadDelay

	; perform joypad reads
	clx
@pce_ReadPads_loop:
	; save previous controller read in a temporary variable
	lda pce_padState,x
	sta tmp00

	; read 1: directions
	lda #1
	sta JOYPAD
	pce_PadReadDelay

	; shift left 4x so directions are in the upper 4 bits
	lda JOYPAD
	asl
	asl
	asl
	asl
	sta pce_padState,x

	; read 2: buttons
	stz JOYPAD
	pce_PadReadDelay

	lda JOYPAD
	and #$0F ; mask for buttons
	ora pce_padState,x ; combine with directions
	eor #$FF ; change bits from active low to active high (e.g. pressed = 1)
	sta pce_padState,x ; store new state

	; trigger
	lda tmp00
	eor #$FF
	and pce_padState,x
	sta pce_padTrigger,x

	; loop logic
	inx
	cpx #5 ; multitap allows for 5 controllers maximum
	bcc @pce_ReadPads_loop

	rts
.endproc
