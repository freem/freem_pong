; PCE IRQ1 (VBlank, HBlank)
;==============================================================================;
IRQ1:
	pha
	phx
	phy

	; update VDC status
	lda a:VDC_STATUS
	sta int_vdcStatus

	;-- check for interrupt source --;
	bbr5 int_vdcStatus,IRQ1_CheckHBlank ; vblank = bit 5

IRQ1_VBlank:
	; perform SATB buffer -> VRAM transfer
	st0 #VDCREG_MAWR
	st1 #<$7F00
	st2 #>$7F00

	; data transfer length ok?
	st0 #VDCREG_VRWD
	tia pce_satbBuf,VDC_DATA_LO,8*3

	stz vblanked
	bra IRQ1_end

IRQ1_CheckHBlank:
	bbr2 int_vdcStatus,IRQ1_end ; hblank = bit 2

	; do hblank (probably ends up being nothing)

	; don't bother the with others in this small game
IRQ1_end:
	ply
	plx
	pla
	rti
