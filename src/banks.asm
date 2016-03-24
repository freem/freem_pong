; bank setup for each platform
;==============================================================================;
	.segment "BANK01" ; $8000-$9FFF

; put graphics and screen data here.
;------------------------------------------------------------------------------;
; note: Score tile definitions

;---+-----------+-----------+
; # | NES tiles | PCE tiles |
;---+-----------+-----------+
; 0 |  $36,$3D  | $100+vals |
; 1 |  $37,$3E  | $100+vals |
; 2 |  $38,$3F  | $100+vals |
; 3 |  $38,$40  | $100+vals |
; 4 |  $39,$41  | $100+vals |
; 5 |  $3A,$40  | $100+vals |
; 6 |  $3A,$42  | $100+vals |
; 7 |  $3B,$43  | $100+vals |
; 8 |  $3C,$42  | $100+vals |
; 9 |  $3C,$40  | $100+vals |
;---+-----------+-----------+

;------------------------------------------------------------------------------;
	.ifdef __NES__

; background and sprite tiles (NES 2BPP)
nes_tilesBG:  .incbin "gfx/nes/bg.chr"
nes_tilesSPR: .incbin "gfx/nes/spr.chr"

	; todo: logo data, various strings

	; in-game score tiles
tbl_scoreTiles_Top:
	.byte $36,$37,$38,$38,$39,$3A,$3A,$3B,$3C,$3C,$00,$00,$00,$00,$00,$00
tbl_scoreTiles_Bot:
	.byte $3D,$3E,$3F,$40,$41,$40,$42,$43,$42,$40,$00,$00,$00,$00,$00,$00

	.endif

;------------------------------------------------------------------------------;
	.ifdef __PCE__

; background tiles (PCE 4BPP BG)
pce_tilesBG:  .incbin "gfx/pce/bg.pce"
; sprite tiles (PCE 4BPP SPR)
pce_tilesSPR: .incbin "gfx/pce/spr.pce"

	; todo: logo data, various strings

	; in-game score tiles
tbl_scoreTiles_Top:
	.word $1136,$1137,$1138,$1138,$1139,$113A,$113A,$113B,$113C,$113C
	; xxx: zero out A-F
tbl_scoreTiles_Bot:
	.word $113D,$113E,$113F,$1140,$1141,$1140,$1142,$1143,$1142,$1140
	; xxx: zero out A-F

	.endif

;==============================================================================;
	.segment "BANK02" ; $A000-$BFFF

; put sound driver code here.
	.include "sound.asm"
;------------------------------------------------------------------------------;
	.ifdef __NES__
	.include "sound_nes.asm"
	.endif
;------------------------------------------------------------------------------;
	.ifdef __PCE__
	.include "sound_pce.asm"
	.endif

;==============================================================================;
	.segment "BANK03" ; $C000-$DFFF

