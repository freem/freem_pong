; sound driver code (Main)
;==============================================================================;
; The sound driver for this game is meant to be as simple as possible.
;
; possible routines:
; * sound_StopAll
; * sound_PlaySound
;==============================================================================;
; signature for whatever reason.
	.byte "+---- fgse ----+"
	.byte "| freem generic|"
	.byte "| sound engine |"
	.byte "+--------------+"

;==============================================================================;
; sound_PlayFrame
; Runs a step of the sound engine.

.proc sound_PlayFrame
	rts
.endproc

;==============================================================================;
; sound_StopAll
; Stops playback of all sound.

;==============================================================================;
; sound_PlaySound
; Plays the specified sound.

; (Params)
; ? - Sound number to play.

.proc sound_PlaySound
	rts
.endproc
