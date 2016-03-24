; NES-specific reset code, joined in progress
;==============================================================================;
; at this point:
; - sei (interrupts are disabled)
; - cld (decimal flag is cleared, in case a clone implements it)
; - ldx #$FF, txs (set stack index to $01FF)
;==============================================================================;
	;-- continue NES initialization --;
	lda #$40
	sta APU_FRAMECOUNT ; disable APU frame counter

	ldx #0
	stx PPU_CTRL ; disable NMIs
	stx PPU_MASK ; disable rendering
	stx APU_DMC_FREQ ; disable DMC IRQ

	bit PPU_STATUS ; kick the PPU

	; first vblank wait
@waitVBlank1:
	bit PPU_STATUS
	bpl @waitVBlank1

	; clear all RAM
	txa
@clearRAM:
	sta $000,x
	sta $100,x
	sta $300,x
	sta $400,x
	sta $500,x
	sta $600,x
	sta $700,x
	inx
	bne @clearRAM

	; clear sprite buffer
	lda #$F8
	ldx #0
@clearOAM:
	sta OAM_BUF,x
	inx
	bne @clearOAM

	jsr apu_Init ; initialize APU

	;-- FME-7 initialization --;
	; initialize CHR banks
	; coincidentally, the command numbers match the values we want to write.
	ldx #0
@fme7CHRLoop:
	stx FME7_CTRL
	stx FME7_DATA
	inx
	cpx #8
	bne @fme7CHRLoop

	; initialize PRG banks
	fme7_DoCommand FME7_CMD_PRG0,FME7_PRG0_RAM|3 ; $6000-$7FFF
	fme7_DoCommand FME7_CMD_PRG1,0 ; $8000-$9FFF
	fme7_DoCommand FME7_CMD_PRG2,1 ; $A000-$BFFF
	fme7_DoCommand FME7_CMD_PRG3,2 ; $C000-$DFFF
	; mirroring
	fme7_DoCommand FME7_CMD_NTM,FME7_NTM_VERT
	; IRQ
	fme7_DoCommand FME7_CMD_IRQC,(FME7_IRQ_DISABLE|FME7_IRQ_COUNT_OFF)
	fme7_DoCommand FME7_CMD_IRQLO,$FF
	fme7_DoCommand FME7_CMD_IRQHI,$FF

	; second vblank wait
@waitVBlank2:
	bit PPU_STATUS
	bpl @waitVBlank2

;==============================================================================;
; execution continues at ProgramSetup.
