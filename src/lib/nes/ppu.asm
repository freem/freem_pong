; NES PPU related code
;==============================================================================;
; ppu_clearNT
; Clears the specified nametable using tile 0.

; Params:
; A				Nametable to clear (0-3)

; 0=$2000, 1=$2400, 2=$2800, 3=$2C00
ppu_ntIndex: .byte $20,$24,$28,$2C

.proc ppu_clearNT
	tay
	lda ppu_ntIndex,y
	sta PPU_ADDR
	ldy #0
	sty PPU_ADDR

	; clear tiles
	ldy #$C0
	ldx #4
	lda #0
@writeTiles:
	sta PPU_DATA
	dey
	bne @writeTiles
	dex
	bne @writeTiles

	; clear attrib
	ldy #$40
@writeAttrib:
	sta PPU_DATA
	dey
	bne @writeAttrib

	rts
.endproc

;------------------------------------------------------------------------------;
; ppu_ClearNT_All
; Clears all four nametables.
; Probably overkill except on four-screen games and on mappers w/dynamic
; nametable mirroring.

ppu_ClearNT_All:
	lda #0
	jsr ppu_clearNT
	lda #1
	jsr ppu_clearNT
	lda #2
	jsr ppu_clearNT
	lda #3
	jsr ppu_clearNT

	rts

;==============================================================================;
; ppu_TransferVRAMBuf
; Transfers the contents of nes_vramBuf to the PPU.

.proc ppu_TransferVRAMBuf
	ldy #0

@ppu_TransferVRAMBuf_loop:
	; get ppu address
	lda nes_vramBuf,y
	sta tmp00
	iny
	lda nes_vramBuf,y
	sta tmp01
	; get data length
	iny
	lda nes_vramBuf,y
	beq @ppu_TransferVRAMBuf_end
	sta tmp02

	; check for vertical write flag
	bmi @ppu_TransferVRAMBuf_Vertical
	lda int_ppuCtrl
	and #%11111011
	sta int_ppuCtrl
	sta PPU_CTRL
	jmp @ppu_TransferVRAMBuf_SetAddr

@ppu_TransferVRAMBuf_Vertical:
	lda int_ppuCtrl
	ora #%00000100
	sta int_ppuCtrl
	sta PPU_CTRL

@ppu_TransferVRAMBuf_SetAddr:
	; prepare write
	lda tmp00
	sta PPU_ADDR
	lda tmp01
	sta PPU_ADDR

	lda tmp02
	and #$7F
	tax
	iny
@ppu_TransferVRAMBuf_WriteLoop:
	lda nes_vramBuf,y
	sta PPU_DATA
	iny
	dex
	bne @ppu_TransferVRAMBuf_WriteLoop

	jmp @ppu_TransferVRAMBuf_loop

@ppu_TransferVRAMBuf_end:
	; restore horizontal writes
	lda int_ppuCtrl
	and #%11111011
	sta int_ppuCtrl

	rts
.endproc

;==============================================================================;
; ppu_ClearVRAMBuf
; Clears the contents of nes_vramBuf for the next frame.

.proc ppu_ClearVRAMBuf
	lda #0
	ldx #127 ; buffer length is hardcoded, oops
@loop:
	sta nes_vramBuf,x
	dex
	bpl @loop
	rts
.endproc
