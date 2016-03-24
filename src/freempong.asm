; freem Pong
; an attempt to implement a dual-compatible NES/Famicom and PC Engine/TG16 game
;==============================================================================;
; guide to things:
; __NES__ and __PCE__ are defines set by ca65; use them.

;==============================================================================;
; include system-specific defines
	.ifdef __NES__
		.include "lib/nes/nes.inc" ; NES hardware defines
		.include "nes_fme7.inc"    ; iNES header and FME-7 mapper defines
	.else
		.ifdef __PCE__
		.include "lib/pce/pce.inc" ; PCE hardware defines
		.import __PCE_ZP_START__   ; Real zero page address base (defined in linker config)
		.endif
	.endif

;==============================================================================;
; include shared defines
	.include "lib/ram_lib.inc"  ; library/system ram
	.include "ram_game.inc"     ; game ram
	.include "lib/macros.inc"   ; cross-compatibility macros

;==============================================================================;
	.code

; Reset

Reset:
	sei ; disable interrupts
	cld ; clear decimal flag
	; set up stack
	ldx #$FF
	txs

	; system-specific setup begins here
	.ifdef __NES__
		.include "lib/nes/reset.asm"
	.else
		.ifdef __PCE__
		.include "lib/pce/reset.asm"
		.endif
	.endif

	.include "setup.asm" ; program setup

	jsr randNum ; poke random number generator

	; hand execution over to the game code
	jmp game_setup

;==============================================================================;
; dummyInterrupt
; Stub interrupt used for things that don't need to be implemented.

dummyInterrupt:
	rti

;==============================================================================;
; dummyRTS
; Dummy RTS used whenever needed.

dummyRTS:
	jsr randNum ; poke random number generator
	rts

;==============================================================================;
; waitVBlank
; Waits for the "vblanked" variable to be set to 0, signifying the end of VBlank.

waitVBlank:
	; [NES] poke the PPU.
	.ifdef __NES__
		bit PPU_STATUS
	.endif

	lda #1
	sta vblanked
@wait:
	jsr randNum ; poke random number generator
	lda vblanked
	bne @wait
	rts

;==============================================================================;
; system specific code stuff

	.include "lib/interface.asm"     ; cross-compatibility helpers

	.ifdef __NES__
	.include "lib/nes/nmi.asm"       ; NES NMI
	;--------------------------------------------------------------------------;
	.include "lib/nes/apu.asm"       ; NES APU routines
	.include "lib/nes/ppu.asm"       ; NES PPU routines
	;--------------------------------------------------------------------------;
	.include "lib/nes/loadtiles.asm" ; NES CHR-RAM load routines
	.include "lib/nes/readpads.asm"  ; NES joypad reading
	.endif

	.ifdef __PCE__
	.include "lib/pce/timer.asm"     ; PCE Timer
	.include "lib/pce/irq1.asm"      ; PCE IRQ1
	;--------------------------------------------------------------------------;
	.include "lib/pce/psg.asm"       ; PCE PSG routines
	.include "lib/pce/vdc.asm"       ; PCE VDC routines
	;--------------------------------------------------------------------------;
	.include "lib/pce/loadtiles.asm" ; PCE VRAM load routines
	.include "lib/pce/readpads.asm"  ; PCE joypad reading
	.endif

;==============================================================================;
; White Flame's small, fast 8-bit PRNG
; from http://codebase64.org/doku.php?id=base:small_fast_8-bit_prng

randNum:
	lda randomSeed
	beq @randNum_xor
	asl
	beq @randNum_end
	bcc @randNum_end
@randNum_xor:
	eor #$63
@randNum_end:
	sta randomSeed
	rts

;==============================================================================;
;-- game code --;
	.include "game.asm"

;==============================================================================;
;-- game data --;

; Palette data

	.ifdef __NES__
tbl_paletteNES:
	.byte $0F,$30,$10,$00 ; BG  0 - Main
	.byte $0F,$30,$2C,$1C ; BG  1 - Scores
	.byte $0F,$39,$29,$19 ; BG  2 - Net
	.byte $0F,$0F,$0F,$0F ; BG  3 - unused
	;---------------------;
	.byte $0F,$26,$15,$05 ; SPR 0 - Paddle 1 (red)
	.byte $0F,$31,$21,$11 ; SPR 1 - Paddle 2 (blue)
	.byte $0F,$37,$27,$17 ; SPR 2 - Ball (orange)
	.byte $0F,$30,$10,$00 ; SPR 3 - Ball (silver); only used in debug mode
	.endif

	.ifdef __PCE__
tbl_palettePCE_BG1:
	.word $0000 ; background = black
	vce_PalDataRGB 7,7,7
	vce_PalDataRGB 5,5,5
	vce_PalDataRGB 3,3,3

	; scores
tbl_palettePCE_BG2:
	.word $0000
	vce_PalDataRGB 7,7,7
	vce_PalDataRGB 2,5,6
	vce_PalDataRGB 1,3,4

	; net (todo: needs update)
tbl_palettePCE_BG3:
	.word $0000
	vce_PalDataRGB 5,5,7
	vce_PalDataRGB 3,3,7
	vce_PalDataRGB 1,1,4

tbl_palettePCE_SPR:
	.word $0001 ; overscan = dark blue (temporary)

	; paddle 1 (red)
	vce_PalDataRGB 7,4,3
	vce_PalDataRGB 5,1,1
	vce_PalDataRGB 2,0,0

	; paddle 2 (blue)
	vce_PalDataRGB 5,6,7
	vce_PalDataRGB 2,4,7
	vce_PalDataRGB 0,2,6

	; ball (orange)
	vce_PalDataRGB 7,6,4
	vce_PalDataRGB 7,4,0
	vce_PalDataRGB 4,2,0

	; ball (silver); only used in debug mode (but not used yet)
	vce_PalDataRGB 7,7,7
	vce_PalDataRGB 4,4,4
	vce_PalDataRGB 2,2,2

	.endif

;==============================================================================;
; vector definitions
	.ifdef __NES__
	.segment "NES_VECTORS"
	.addr NMI ; NMI
	.addr Reset ; Reset
	.addr dummyInterrupt ; IRQ
	.endif

	.ifdef __PCE__
	.segment "PCE_VECTORS"
	.addr dummyInterrupt ; IRQ2
	.addr IRQ1 ; IRQ1
	.addr Timer ; Timer
	.addr dummyInterrupt ; NMI
	.addr Reset ; Reset
	.endif

;==============================================================================;
; data banks
	.include "banks.asm"
