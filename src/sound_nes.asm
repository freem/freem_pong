; sound driver code (NES-specific)
;==============================================================================;
; Target is the sound portion of the 2A03/2A07.
; DPCM, PCM, and expansion sound are not handled.

; 4 sound channels are available:
;  1) Pulse/Square 1
;  2) Pulse/Square 2
;  3) Triangle
;  4) Noise
;==============================================================================;
; NES sound defines
	sound_StopAll = sound_StopAll_nes

;==============================================================================;
; NES-specific signature
	.align 16
	.byte "+---- fgse ----+"
	.byte "|2A03/2A07 code|"
	.byte "+--------------+"
	; xxx: should handle NTSC vs. PAL frequency tables.

;==============================================================================;
; sound_StopAll_nes
; Stop sound on all NES audio channels.

.proc sound_StopAll_nes
	rts
.endproc

;==============================================================================;
; tbl_PulseFreq_Lo, tbl_PulseFreq_Hi
; NES frequency table
