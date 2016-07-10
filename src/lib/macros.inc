; cross compatibility macros
;==============================================================================;
; mac_zero_w
; Stores a word length zero value at the desired destination.

; (Params)
; dest - Destination

; (Implementation Details)
; NES - set A to 0, store A in dest and des+1
; PCE - use dedicated stz opcode.

; (Notes)
; This is somewhat ineffective for setting multiple values on NES due to needless
; reloading of A. Sorry about that.

.macro mac_zero_w dest
	.ifdef __NES__
			lda #0
			sta dest
			sta dest+1
	.else
		.ifdef __PCE__
			stz dest
			stz dest+1
		.endif
	.endif
.endmacro

;==============================================================================;
; mac_alwaysjump
; Perform an "always jump" command (within -128/127 bytes).

; (Params)
; dest - Destination

; (Implementation Details)
; NES - uses jmp opcode (not actually limited to -128/127 bytes...)
; PCE - uses bra opcode

.macro mac_alwaysjump dest
	.ifdef __NES__
			jmp dest
	.else
		.ifdef __PCE__
			bra dest
		.endif
	.endif
.endmacro
