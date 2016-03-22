; PCE-specific reset code, joined in progress
;==============================================================================;
; at this point:
; - sei (interrupts are disabled)
; - cld (decimal flag is cleared, in case a clone implements it)
; - ldx #$FF, txs (set stack index to $01FF)
;==============================================================================;
	;-- continue PCE initialization --;
	csh ; set high speed mode

	lda #$FF
	tam0 ; $FF - hardware I/O regs
	lda #$F8
	tam1 ; $F8 - RAM area

	; bank in the other parts of the game.
	; In order to give the NES and PCE versions similar memory maps, the data
	; starts at slot 4 ($8000). mpr2 and mpr3 usage is currently undetermined.
	lda #$01
	tam4 ; $01
	inc a
	tam5 ; $02
	inc a
	tam6 ; $03

	; clear zero page
	stz $2000
	tii $2000,$2001,$00FF
	; clear RAM area
	stz $2200
	tii $2200,$2201,$1DFF

	; perform system initialization
	jsr psg_Init
	jsr vdc_Init

	;jsr vce_Init
	lda #VCE_DOTCLOCK_5MHZ|VCE_BLUR_ON|VCE_MODE_COLOR
	sta VCE_CONTROL

;==============================================================================;
; execution continues at ProgramSetup.
