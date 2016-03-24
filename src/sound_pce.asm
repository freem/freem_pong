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

;==============================================================================;
; PCE-specific signature
	.align 16
	.byte "+---- fgse ----+"
	.byte "| PCE PSG code |"
	.byte "+--------------+"

;==============================================================================;
; sound_StopAll_pce
; Stop sound on all PCE audio channels.

sound_StopAll_pce:
	rts

;==============================================================================;

