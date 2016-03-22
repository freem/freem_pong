; library interface code and defines
;==============================================================================;
; this is the crap that handles NES vs. PCE calls of the "same" routine.
;==============================================================================;
; Joypad buttons.
; On standard controllers, B/II are on the left and A/I are on the right.

	.ifdef __NES__
		INPUT_UP     = PAD_UP     ; %00001000
		INPUT_DOWN   = PAD_DOWN   ; %00000100
		INPUT_LEFT   = PAD_LEFT   ; %00000010
		INPUT_RIGHT  = PAD_RIGHT  ; %00000001
		INPUT_A      = PAD_A      ; %10000000
		INPUT_B      = PAD_B      ; %01000000
		INPUT_SELECT = PAD_SELECT ; %00100000
		INPUT_START  = PAD_START  ; %00010000
	.else
		.ifdef __PCE__
		INPUT_UP     = JOY_UP     ; %00010000
		INPUT_DOWN   = JOY_DOWN   ; %01000000
		INPUT_LEFT   = JOY_LEFT   ; %10000000
		INPUT_RIGHT  = JOY_RIGHT  ; %00100000
		INPUT_A      = JOY_I      ; %00000001
		INPUT_B      = JOY_II     ; %00000010
		INPUT_SELECT = JOY_SEL    ; %00000100
		INPUT_START  = JOY_RUN    ; %00001000
		.endif
	.endif

;==============================================================================;
; ReadPads - Joypad reading routine.

	.ifdef __NES__
		ReadPads = nes_ReadPads
	.else
		.ifdef __PCE__
		ReadPads = pce_ReadPads
		.endif
	.endif
