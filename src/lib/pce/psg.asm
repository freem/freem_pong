; file: psg.asm
; PSG related code.
;==============================================================================;

; routine: psg_Init
; Initializes the PSG hardware.
; - Silences global volume (PSG_GLOBALVOL)
; - Disables LFO control (PSG_LFOCONTROL)
; - Silences each channel (PSG_CHANCTRL and PSG_CHANPAN)
; - Disable noise on last two channels (PSG_NOISE)

.proc psg_Init
	stz PSG_GLOBALVOL
	stz PSG_LFOCONTROL

	; reset all channels
	lda #5 ; (6-1 channels)
@psg_Init_clearloop:
	sta PSG_CHANSELECT
	stz PSG_CHANCTRL
	stz PSG_CHANPAN
	dec a
	bpl @psg_Init_clearloop

	; disable noise on last two channels
	lda #4
	sta PSG_CHANSELECT
	stz PSG_NOISE
	inc a
	sta PSG_CHANSELECT
	stz PSG_NOISE

	rts
.endproc

;==============================================================================;

; macro: psg_SetMainVolume
; Sets the main PSG volume. (Only clobbers A if vol is nonzero.)
;
; Parameters:
; vol - new global volume ($00-$FF)
;
; todo:
; should this macro use Left/Right params instead of setting it wholesale?

.macro psg_SetMainVolume vol
	.if vol == 0
		stz pce_globalVolume ; write to local copy
		stz PSG_GLOBALVOL    ; write to PSG hardware
	.else
		lda #vol
		sta pce_globalVolume ; write to local copy
		sta PSG_GLOBALVOL    ; write to PSG hardware
	.endif
.endmacro

;==============================================================================;

; psg_SetChanVolume

;==============================================================================;

; macro: psg_SetChanPan
; Sets the pan for the specified channel.
;
; Parameters:
; chan - PSG channel to use
; pan  - new panning value ($00-$FF)
;
; todo:
; should this macro use Left/Right params instead of setting it wholesale?

.macro psg_SetChanPan chan,pan
	ldx #chan
	lda #pan
	stx PSG_CHANSELECT
	sta pce_soundBalance,x ; write to local copy
	sta PSG_CHANPAN        ; write to PSG hardware
.endmacro
