; Sunsoft FME-7 defines and macros
;==============================================================================;
; NES 2.0 mapper for FME-7 with CHR-RAM
	.segment "NES2_HEADER"
	.byte "NES",$1A
	.byte 2 ; PRG-ROM size (16K)
	.byte 0 ; CHR-ROM size (8K); using CHR-RAM
	.byte $51 ; Flags 6 (mapper lower 4 bits, vertical mirroring)
	.byte $48 ; Flags 7 (mapper upper 4 bits, NES 2.0 signature)
	.byte 0 ; mapper variant
	.byte 0 ; upper 4 bits for CHR and PRG rom size
	.byte 0 ; PRG-RAM status
	.byte $07 ; CHR-RAM status; 7 = 8192 bytes/8K
	.byte 0 ; NTSC
	.byte 0 ; Vs. system
	.byte 0 ; byte 14 (reserved)
	.byte 0 ; byte 15 (reserved)

;==============================================================================;
; Registers
FME7_CTRL = $8000 ; commands $0-$F
FME7_DATA = $A000 ; 8-bit data register

; Control values
FME7_CMD_CHR0 = 0  ; PPU $0000-$03FF
FME7_CMD_CHR1 = 1  ; PPU $0400-$07FF
FME7_CMD_CHR2 = 2  ; PPU $0800-$0BFF
FME7_CMD_CHR3 = 3  ; PPU $0C00-$0FFF
FME7_CMD_CHR4 = 4  ; PPU $1000-$13FF
FME7_CMD_CHR5 = 5  ; PPU $1400-$17FF
FME7_CMD_CHR6 = 6  ; PPU $1800-$1BFF
FME7_CMD_CHR7 = 7  ; PPU $1C00-$1FFF
;------------------;
FME7_CMD_PRG0 = 8  ; PRG Bank 0 (see below)
FME7_CMD_PRG1 = 9  ; PRG Bank 1 ($8000-$9FFF)
FME7_CMD_PRG2 = 10 ; PRG Bank 2 ($A000-$BFFF)
FME7_CMD_PRG3 = 11 ; PRG Bank 3 ($C000-$DFFF)
;------------------;
FME7_CMD_NTM  = 12 ; Nametable mirroring (00=vert.; 01=horiz.; 10=1scrA; 11=1scrB)
FME7_CMD_IRQC = 13 ; IRQ control (see below)
FME7_CMD_IRQLO = 14 ; IRQ counter value (low byte)
FME7_CMD_IRQHI = 15 ; IRQ counter value (high byte)

;------------------------------------------------------------------------------;
; PRG Bank 0 ($6000-$7FFF)

; 76543210
; ERbBBBBB
; |||____|
; ||   |
; ||   +--- bank number (FME-7 uses all bits)
; |+------- RAM/ROM select (0=PRG-ROM; 1=PRG-RAM)
; +-------- RAM enable bit (0=disabled; 1=enabled)

FME7_PRG0_ROM = %00000000 ; RAM disable + ROM select
FME7_PRG0_RAM = %11000000 ; RAM enable + RAM select

;------------------------------------------------------------------------------;
; FME7 Nametable mirroring constants

FME7_NTM_VERT = %00 ; Vertical Mirroring (Horizontal Scrolling)
FME7_NTM_HORI = %01 ; Horizontal Mirroring (Vertical Scrolling)
FME7_NTM_1SCA = %10 ; One-Screen A
FME7_NTM_1SCB = %11 ; One-Screen B

;------------------------------------------------------------------------------;
; IRQ Control

; 76543210
; CxxxxxxT
; |      |
; |      +-- IRQ Generation enable/disable
; +--------- IRQ Counter Decrement enable/disable

FME7_IRQ_ENABLE    = %00000001 ; Enable IRQ generation
FME7_IRQ_DISABLE   = %00000000 ; Disable IRQ generation
FME7_IRQ_COUNT_ON  = %10000000 ; Counter Decrement enabled
FME7_IRQ_COUNT_OFF = %00000000 ; Counter Decrement disabled

;==============================================================================;

; fme7_DoCommand
; Performs a FME-7 command. (Clobbers A.)

; (Params)
; cmd  - command number
; data - data to send

.macro fme7_DoCommand cmd,data
	lda #cmd
	sta FME7_CTRL
	lda #data
	sta FME7_DATA
.endmacro
