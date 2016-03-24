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
; sound_Disable
sound_Disable:
	lda #0
	sta soundEnable
	jmp sound_Disable_plat ; call platform-specific code; must end with rts

;------------------------------------------------------------------------------;
; sound_Enable

sound_Enable:
	lda #1
	sta soundEnable
	jmp sound_Enable_plat ; call platform-specific code; must end with rts

;==============================================================================;
; sound_PlayFrame
; Runs a step of the sound engine.

.proc sound_PlayFrame
	rts
.endproc

;==============================================================================;
; sound_StopAll
; Stops playback of all sound. (Defined in system-specific code)

;==============================================================================;
; sound_PlaySound
; Plays the specified sound.

; (Params)
; ? - Sound number to play.

.proc sound_PlaySound
	rts
.endproc
