; file: vdc.asm
; VDC related code.
;==============================================================================;

; the table from magickit library.asm:

; reg low  hi
; $05,$00,$00    ; CR
; $06,$00,$00    ; RCR
; $07,$00,$00    ; BXR
; $08,$00,$00    ; BYR
; $09,$10,$00    ; MWR
; $0A,"hsr xres" ; HSR
; $0B,"hdr xres" ; HDR
; $0C,$02,$17    ; VPR/VSR
; $0D,$DF,$00    ; VDW/VDR
; $0E,$0C,$00    ; VCR
; $0F,$10,$00    ; DCR
; $13,$00,$7F    ; SATB

; described as:
; "initialize the video controller
;  - 256x224 screen mode
;  - 64x32 virtual bgmap size
;  - display and sprites off
;  - interrupts disabled
;  - SATB at $7F00
;  - VRAM cleared"
; (some other things happen in magickit vdc_init)

;==============================================================================;
; default settings

DEFAULT_SATB_LOCATION = $7F00

DEFAULT_SCREEN_WIDTH  = 256
DEFAULT_SCREEN_HEIGHT = 240

DEFAULT_BAT_WIDTH  = 32
DEFAULT_BAT_HEIGHT = 32

;==============================================================================;

; routine: vdc_Init
; Performs VDC initialization.
;
; At present, this sets up a 256x240 screen with a 32x32 BAT.

.proc vdc_Init
	;-- set values for screenX, screenY, batX, batY --;
	ldx #<DEFAULT_SCREEN_WIDTH
	ldy #>DEFAULT_SCREEN_WIDTH
	lda #DEFAULT_SCREEN_HEIGHT
	stx pce_screenX
	sty pce_screenX+1
	sta pce_screenY

	; bat is 32x32 tiles by default
	ldx #DEFAULT_BAT_WIDTH
	ldy #DEFAULT_BAT_HEIGHT
	stx pce_batW
	sty pce_batH

	; initialize CR (display off, disable all interrupts)
	st0 #VDCREG_CR
	st1 #0
	st2 #0

	; clear RCR
	st0 #VDCREG_RCR
	st1 #0
	st2 #0

	; reset BG X scroll
	st0 #VDCREG_BXR
	st1 #0
	st2 #0

	; reset BG Y scroll
	st0 #VDCREG_BYR
	st1 #0
	st2 #0

	;-- set up a 256x240 screen --;

	; VDC for 256x
	; HDS $02 \ _ HSR/$0A
	; HSW $02 /
	; HDE $04 \ _ HDR/$0B
	; HDW $1F /
	; CLK 0

	; set MWR/memory width register
	st0 #VDCREG_MWR
	; the value we want... (primarily dot width/clock 0)
	; FEDCBA9876543210
	; 0000000000000000
	; with a 32x32 BAT
	; xxxxxxxxxxHWWxxx
	; W=00, H=0
	st1 #0
	st2 #0

	; HSR
	st0 #VDCREG_HSR
	; HSR contains HDS and HSW
	; FEDCBA9876543210
	; 0|_____|000|___|
	;     |        |
	;     |        +--- HSW: %00010
	;     +------------ HDS: %0000010
	; $0202
	st1 #<$0202
	st2 #>$0202

	; HDR/HDR
	st0 #VDCREG_HDR
	; HDR contains HDE and HDW
	; FEDCBA9876543210
	; 0|_____|0|_____|
	;     |       |
	;     |       +---- HDW: %0011111
	;     +------------ HDE: %0000111
	; $041F
	st1 #<$041F
	st2 #>$041F

	;VDC for 240y
	; VSW $02 \
	; VDS $0C /
	; VDW $00EF
	; VCR $04

	; VSR
	st0 #VDCREG_VSR
	; VSR contains VDS and VSW
	; FEDCBA9876543210
	; |______|0|_____|
	;     |       |
	;     |       +---- VSW: %00000010
	;     +------------ VDS: %00001100
	; $0C02
	st1 #<$0C02
	st2 #>$0C02

	; VDR
	st0 #VDCREG_VDR
	st1 #<$00EF
	st2 #>$00EF

	; VCR
	st0 #VDCREG_VCR
	st1 #<$0004
	st2 #>$0004

	; DCR
	st0 #VDCREG_DCR
	st1 #<VDC_DCR_AUTO_SATB
	st2 #>VDC_DCR_AUTO_SATB

	; SATB at $7F00
	st0 #VDCREG_SATB
	st1 #<DEFAULT_SATB_LOCATION
	st2 #>DEFAULT_SATB_LOCATION

	rts
.endproc

;==============================================================================;
; routine: vdc_ClearBat
; Clears the BAT using the specified tile.

; (Params)
; tmp00,tmp01 - tile/palette value to write.

.proc vdc_ClearBat
	; start at beginning of BAT
	st0 #VDCREG_MAWR
	stz a:VDC_DATA_LO
	stz a:VDC_DATA_HI

	; begin bat write
	st0 #VDCREG_VRWD
	; todo: the H/W order is subject to change because aaaa I don't know
	ldx pce_batH
@vdc_ClearBat_Row:
	ldy pce_batW
@vdc_ClearBat_Col:
	lda tmp00
	sta a:VDC_DATA_LO
	lda tmp01
	sta a:VDC_DATA_HI
	dey
	bne @vdc_ClearBat_Col
	dex
	bne @vdc_ClearBat_Row

	rts
.endproc
