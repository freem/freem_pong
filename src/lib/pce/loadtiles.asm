; PCE VRAM tile loading routines
;==============================================================================;
; pce_LoadTilesBG
; Loads 4BPP BG tiles into the PCE VRAM.

; (Params)
; tmp00,tmp01 - tile source
; tmp02,tmp03 - vram destination
; tmp04 - number of tiles to copy

.proc pce_LoadTilesBG
	; set VRAM address for write
	st0 #VDCREG_MAWR
	lda tmp02
	sta a:VDC_DATA_LO
	lda tmp03
	sta a:VDC_DATA_HI

	; prepare write mode
	st0 #VDCREG_VRWD

	;-- prepare quickTIA --;
	; source address
	ldx tmp00
	ldy tmp01
	stx pce_quickTIA+1
	sty pce_quickTIA+2

	; destination address
	ldx #<VDC_DATA_LO
	ldy #>VDC_DATA_LO
	stx pce_quickTIA+3
	sty pce_quickTIA+4

	; length (one tile = 32 bytes, so numtiles << 5)
	stz tmp05 ; used for upper bits
	clc ; clear carry to prevent dirty bits
	.repeat 5
	rol tmp04
	rol tmp05
	.endrep
	ldx tmp04
	ldy tmp05
	stx pce_quickTIA+5
	sty pce_quickTIA+6
	; ugly hack to jump to real zero page location
	jmp pce_quickTIA+__PCE_ZP_START__
.endproc

;==============================================================================;
; pce_LoadTilesSPR
; Loads 4BPP Sprite tiles into the PCE VRAM.

; (Params)
; tmp00,tmp01 - tile source
; tmp02,tmp03 - vram destination
; tmp04 - number of tiles to copy

.proc pce_LoadTilesSPR
	; set VRAM address for write
	st0 #VDCREG_MAWR
	lda tmp02
	sta a:VDC_DATA_LO
	lda tmp03
	sta a:VDC_DATA_HI

	; prepare write mode
	st0 #VDCREG_VRWD

	;-- prepare quickTIA --;
	; source address
	ldx tmp00
	ldy tmp01
	stx pce_quickTIA+1
	sty pce_quickTIA+2

	; destination address
	ldx #<VDC_DATA_LO
	ldy #>VDC_DATA_LO
	stx pce_quickTIA+3
	sty pce_quickTIA+4

	; length (one tile = 128 bytes, so numtiles << 7)
	stz tmp05 ; used for upper bits
	clc ; clear carry to prevent dirty bits
	.repeat 7
	rol tmp04
	rol tmp05
	.endrep
	ldx tmp04
	ldy tmp05
	stx pce_quickTIA+5
	sty pce_quickTIA+6
	; ugly hack to jump to real zero page location
	jmp pce_quickTIA+__PCE_ZP_START__
.endproc
