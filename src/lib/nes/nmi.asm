; NES NMI (typically VBlank)
;==============================================================================;
NMI:
	pha
	txa
	pha
	tya
	pha

	; transfer sprites ASAP so the game will work on PAL consoles
	lda #0
	sta OAM_ADDR
	lda #>OAM_BUF
	sta OAM_DMA

	; perform other vblank-y updates
	lda nes_ntUpdate
	beq @NMI_scroll

	; transfer nes_vramBuf
	jsr ppu_TransferVRAMBuf
	lda #0
	sta nes_ntUpdate

@NMI_scroll:
	lda #0
	sta PPU_SCROLL
	sta PPU_SCROLL

	; write PPU_CTRL and PPU_MASK
	lda int_ppuCtrl
	sta PPU_CTRL
	lda int_ppuMask
	sta PPU_MASK

NMI_end:
	lda #0
	sta vblanked

	pla
	tay
	pla
	tax
	pla
	rti
