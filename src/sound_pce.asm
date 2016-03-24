; sound driver code (PCE-specific)
;==============================================================================;
; Target is the PSG chip found in the PC Engine/TurboGrafx 16.
; Direct D/A and Frequency Modulation are not handled.

; 6 sound channels are available:
;  1) Waveform or Frequency Modulation
;  2) Waveform (muted when using Frequency Modulation)
;  3) Waveform
;  4) Waveform
;  5) Waveform or Noise
;  6) Waveform or Noise
;==============================================================================;
; PCE sound defines
	sound_StopAll = sound_StopAll_pce

;==============================================================================;
; PCE-specific signature
	.align 16
	.byte "+---- fgse ----+"
	.byte "| PCE PSG code |"
	.byte "+--------------+"

;==============================================================================;
; sound_StopAll_pce
; Stop sound on all PCE audio channels.

; Clobbers: X, A

.proc sound_StopAll_pce
	ldx #5 ; (6-1)
@sound_StopAll_Loop_pce:
	stx PSG_CHANSELECT

	; get current control value for this channel
	lda pce_soundControl,x
	and #$1F ; keep volume
	ora PSG_CHSTATE_RESET
	sta pce_soundControl,x ; update internal copy
	sta PSG_CHANCTRL ; write to PSG hardware

	; loop logic
	dex
	bpl @sound_StopAll_Loop_pce ; (from 5 to 0)

	rts
.endproc

;==============================================================================;

