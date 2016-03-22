; bank setup for each platform
;==============================================================================;
	.segment "BANK01" ; $8000-$9FFF

; put graphics here.

;------------------------------------------------------------------------------;
	.ifdef __NES__

nes_tilesBG:  .incbin "gfx/nes/bg.chr"
nes_tilesSPR: .incbin "gfx/nes/spr.chr"

	.endif

;------------------------------------------------------------------------------;
	.ifdef __PCE__

pce_tilesBG:  .incbin "gfx/pce/bg.pce"
pce_tilesSPR: .incbin "gfx/pce/spr.pce"

	.endif

;==============================================================================;
	.segment "BANK02" ; $A000-$BFFF

;==============================================================================;
	.segment "BANK03" ; $C000-$DFFF
