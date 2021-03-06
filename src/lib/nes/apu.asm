; NES APU related code
;==============================================================================;
tbl_DefaultAPUValues:
	.byte $30,$08,$00,$00 ; Pulse 1
	.byte $30,$08,$00,$00 ; Pulse 2
	.byte $80,$00,$00,$00 ; Triangle
	.byte $30,$00,$00,$00 ; DPCM

;------------------------------------------------------------------------------;
; apu_Init
; Put the APU channels into a known state.

.proc apu_Init
	ldx #0

@apu_Init_WriteLoop:
	lda tbl_DefaultAPUValues,x
	sta nes_pulse1_data,x ; write to local APU register copy
	sta APU_PULSE1_MAIN,x ; write to APU hardware
	inx
	cpx #16
	bne @apu_Init_WriteLoop

	; enable the main audio channels (no DPCM)
	lda #$0F
	sta APU_STATUS

	rts
.endproc

;==============================================================================;
