; Program Setup
;==============================================================================;
ProgramSetup:
	; lots of this will differ for PCE/NES.

;==============================================================================;
; NES-specific section
;==============================================================================;
	.ifdef __NES__

	;-- set palette --;
	ldx #>$3F00
	ldy #<$3F00
	stx PPU_ADDR
	sty PPU_ADDR
	; 32 values in tbl_paletteNES
	ldy #0
@Reset_nes_LoadPalette:
	lda tbl_paletteNES,y
	sta PPU_DATA
	iny
	cpy #32
	bne @Reset_nes_LoadPalette
	; reset PPU addresses
	ldx #$3F
	ldy #$00
	stx PPU_ADDR ; palette 1/2
	sty PPU_ADDR ; palette 2/2
	sty PPU_ADDR ; regular ppu 1/2
	sty PPU_ADDR ; regular ppu 2/2

	;-- clear nametables --;
	;jsr ppu_ClearNT_All

	;-- load CHR data --;
	; BG tiles
	ldx #<nes_tilesBG
	ldy #>nes_tilesBG
	stx tmp00
	sty tmp01
	lda #80 ; 80 2BPP NES tiles
	sta tmp02
	jsr nes_LoadTiles

	; sprite tiles
	ldx #>$1000
	ldy #<$0000
	stx PPU_ADDR
	sty PPU_ADDR
	ldx #<nes_tilesSPR
	ldy #>nes_tilesSPR
	stx tmp00
	sty tmp01
	lda #7 ; 7 8x8 sprite tiles
	sta tmp02
	jsr nes_LoadTiles

	; reset PPU address
	lda #0
	sta PPU_ADDR
	sta PPU_ADDR

	;-- reset scroll --;
	sta PPU_SCROLL
	sta PPU_SCROLL

	.endif

;==============================================================================;
; PCE-specific section
;==============================================================================;
	.ifdef __PCE__

	;-- set palette --;
	; first 16 background colors tbl_palettePCE_BG1
	ldx #<VCE_BGPAL_START
	ldy #>VCE_BGPAL_START
	stx VCE_ADDR_LO
	sty VCE_ADDR_HI
	tia tbl_palettePCE_BG1,VCE_DATA_LO,4*2

	; second 16 background colors tbl_palettePCE_BG2
	ldx #<VCE_BGPAL_START+(VCE_PALSET_SIZE*1)
	ldy #>VCE_BGPAL_START+(VCE_PALSET_SIZE*1)
	stx VCE_ADDR_LO
	sty VCE_ADDR_HI
	tia tbl_palettePCE_BG2,VCE_DATA_LO,4*2

	; third 16 background colors tbl_palettePCE_BG3
	ldx #<VCE_BGPAL_START+(VCE_PALSET_SIZE*2)
	ldy #>VCE_BGPAL_START+(VCE_PALSET_SIZE*2)
	stx VCE_ADDR_LO
	sty VCE_ADDR_HI
	tia tbl_palettePCE_BG3,VCE_DATA_LO,4*2

	; first 16 sprite colors tbl_palettePCE_SPR
	ldx #<VCE_SPRPAL_START
	ldy #>VCE_SPRPAL_START
	stx VCE_ADDR_LO
	sty VCE_ADDR_HI
	tia tbl_palettePCE_SPR,VCE_DATA_LO,10*2

	;-- set up self-modifying transfer code --;
	ldx #$E3 ; TIA opcode
	ldy #$60 ; RTS opcode
	stx pce_quickTIA
	sty pce_quickTIA+7

	;-- load BG tiles --;
	; BAT takes up first $0800 of VRAM, so put BG tiles at $1000
	ldx #<pce_tilesBG
	ldy #>pce_tilesBG
	stx tmp00
	sty tmp01
	ldx #<$1000
	ldy #>$1000
	stx tmp02
	sty tmp03
	lda #80 ; 80 4BPP BG tiles
	sta tmp04
	jsr pce_LoadTilesBG

	;-- load SPR tiles --;
	; put SPR tiles at $2000
	ldx #<pce_tilesSPR
	ldy #>pce_tilesSPR
	stx tmp00
	sty tmp01
	ldx #<$2000
	ldy #>$2000
	stx tmp02
	sty tmp03
	lda #5 ; 5 16x16 sprite tiles
	sta tmp04
	jsr pce_LoadTilesSPR

	;-- clear BAT --;
	; BG characters are loaded, fill the BAT with the first tile ($0100).
	ldx #<$0100
	ldy #>$0100
	stx tmp00
	sty tmp01
	jsr vdc_ClearBat

	.endif

;==============================================================================;
; execution is handed to the program
