; file: vce.inc
; VCE related macros and defines.
;==============================================================================;

; VCE/HuC6260 (physical page $FF, mapped into logical page $00)

; Constants: VCE registers
; Aliases for various VCE registers.
;
; VCE_CONTROL - ($0400) VCE control register
; VCE_ADDR_LO - ($0402) VCE address register (low byte)
; VCE_ADDR_HI - ($0403) VCE address register (high byte)
; VCE_DATA_LO - ($0404) VCE data register (low byte)
; VCE_DATA_HI - ($0405) VCE data register (high byte)

VCE_MAIN        = $0400
;---------------;---------------;----------------------------------------------;
VCE_CONTROL     = VCE_MAIN      ; VCE Control Register
VCE_ADDR_LO     = VCE_MAIN+2    ; Color Table Address Register
VCE_ADDR_HI     = VCE_MAIN+3    ; Color Table Address Register
VCE_DATA_LO     = VCE_MAIN+4    ; Color Table Read/Write Register
VCE_DATA_HI     = VCE_MAIN+5    ; Color Table Read/Write Register

;------------------------------------------------------------------------------;
; VCE control:
; 76543210
; ||__||||
; |  | |++- dot clock (see below)
; |  | +--- blur edges of sprites/bg chars
; |  +----- no effect
; +-------- monochrome (0=color; 1=monochrome)

; Constants: VCE Control Register constants
; Aliases for VCE Control Register settings.
;
; VCE_DOTCLOCK_5MHZ - 5MHz dot clock (mode 0)
; VCE_DOTCLOCK_7MHZ - 7MHz dot clock (mode 1)
; VCE_DOTCLOCK_10MHZ_B - 10MHz dot clock (mode 2; better)
; VCE_DOTCLOCK_10MHZ_W - 10MHz dot clock (mode 2; worse)
; VCE_BLUR_ON - edge blur on
; VCE_BLUR_OFF - edge blur off
; VCE_MODE_COLOR - Color mode
; VCE_MODE_MONO - Monochrome mode

VCE_DOTCLOCK_5MHZ    = %00 ; 00 - 5MHz
VCE_DOTCLOCK_7MHZ    = %01 ; 01 - 7MHz
VCE_DOTCLOCK_10MHZ_B = %10 ; 10 - 10MHz, less artifacts (B = "better")
VCE_DOTCLOCK_10MHZ_W = %11 ; 11 - 10MHz, more artifacts (W = "worse")

VCE_BLUR_ON  = 1<<2
VCE_BLUR_OFF = 0<<2

VCE_MODE_COLOR = $00 ; color mode
VCE_MODE_MONO  = $80 ; monochrome mode

;------------------------------------------------------------------------------;
; Constants: VCE palette related
; Aliases for VCE palette related things.
;
; VCE_BGPAL_START  - ($0000) Beginning of Background colors
; VCE_SPRPAL_START - ($0100) Beginning of Sprite colors
; VCE_PALSET_SIZE  - (16) Number of palettes per palette set

VCE_BGPAL_START  = $000 ; first 256 colors are BG
VCE_SPRPAL_START = $100 ; second 256 colors are SPR
VCE_PALSET_SIZE  = 16   ; 16 colors per palette set

;==============================================================================;

; macro: vce_PalDataRGB
; Converts a raw RGB value (0-7 per component) to the format expected by the VCE.
;
; Parameters:
; r - Red value (0-7)
; g - Green value (0-7)
; b - Blue value (0-7)

.macro vce_PalDataRGB r,g,b
	.word (b&7)|((r&7)<<3)|((g&7)<<6)
.endmacro
