; NES CHR-RAM tile loading routine
;==============================================================================;
; nes_LoadTiles
; Loads 2BPP NES tiles into the NES PPU.
; Destination PPU address should be set before calling this routine.

; (Params)
; tmp00,tmp01 - pointer to tile data
; tmp02       - number of tiles to load

.proc nes_LoadTiles
	ldy #0
@nes_LoadTiles_loop:
	; load one full tile at a time (16 bytes)
	lda (tmp00),y
	sta PPU_DATA
	iny
	cpy #16
	bne @nes_LoadTiles_loop

	; advance pointer by one tile
	clc
	lda tmp00
	adc #$10
	sta tmp00
	; check for high byte
	bcc @nes_LoadTiles_check
	inc tmp01

@nes_LoadTiles_check:
	ldy #0
	dec tmp02
	bne @nes_LoadTiles_loop

	rts
.endproc
