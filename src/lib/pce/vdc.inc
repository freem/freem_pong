; file: vdc.inc
; VDC related macros and defines.
;==============================================================================;

; VDC/HuC6270 (physical page $FF, mapped into logical page $00)

; Constants: VDC registers
; Aliases for various VDC registers.
; MUST use absolute addressing (e.g. "sta a:VDC_STATUS")
;
; VDC_STATUS - ($0000) VDC Status register
; VDC_DATA_LO - ($0002) VDC Data register (low byte)
; VDC_DATA_HI - ($0003) VDC Data register (high byte)

;---------------;---------------;----------------------------------------------;
VDC_STATUS      = $0000         ; VDC Status Register
VDC_DATA_LO     = $0002         ; Data Low Byte
VDC_DATA_HI     = $0003         ; Data High Byte and Latch

; Constants: VDC_STATUS defines
; Aliases for VDC_STATUS register names.
;
; VDCREG_MAWR - ($00) Memory Address Write Register
; VDCREG_MARR - ($01) Memory Address Read Register
; VDCREG_VRWD - ($02) VRAM Data Read/Write Register
; VDCREG_CR   - ($05) VDC Control Register
; VDCREG_RCR  - ($06) Raster Counter Register
; VDCREG_BXR  - ($07) Background X Scroll Register
; VDCREG_BYR  - ($08) Background Y Scroll Register
; VDCREG_MWR  - ($09) Memory Width Register
; VDCREG_HSR  - ($0A) Horizontal Sync Register
; VDCREG_HDR  - ($0B) Horizontal Display Register
; VDCREG_VSR  - ($0C) Vertical Sync Register
; VDCREG_VDR  - ($0D) Vertical Display Register
; VDCREG_VCR  - ($0E) Vertical Display End Position Register
; VDCREG_DCR  - ($0F) DMA Control Register
; VDCREG_SOUR - ($10) DMA Source Address Register
; VDCREG_DESR - ($11) DMA Destination Address Register
; VDCREG_LENR - ($12) DMA Block Legth Register
; VDCREG_SATB - ($13) Sprite Attribute Table Address

;---------------;---------------;----------------------------------------------;
VDCREG_MAWR     = $00           ; Memory Address Write Register (VRAM Write Address)
VDCREG_MARR     = $01           ; Memory Address Read Register (VRAM Read Address)
VDCREG_VRWD     = $02           ; VRAM Data Read/Write Register
; (registers $03 and $04 are not used.)
VDCREG_CR       = $05           ; Control Register
VDCREG_RCR      = $06           ; Raster Counter Register
VDCREG_BXR      = $07           ; Background X Scroll Register
VDCREG_BYR      = $08           ; Background Y Scroll Register
VDCREG_MWR      = $09           ; Memory Width Register (BG map virtual size)
VDCREG_HSR      = $0A           ; Horizontal Synchronous Register (contains HDS, HSW)
VDCREG_HDR      = $0B           ; Horizontal Display Register (contains HDE, HDW)
VDCREG_VSR      = $0C           ; Vertical Synchronous Register (contains VDS, VSW)
VDCREG_VDR      = $0D           ; Vertical Display Register (a.k.a. VDW)
VDCREG_VCR      = $0E           ; Vertical Display Ending Postition Register
VDCREG_DCR      = $0F           ; DMA Control Register
VDCREG_SOUR     = $10           ; DMA Source Address Register
VDCREG_DESR     = $11           ; DMA Destination Address Register
VDCREG_LENR     = $12           ; DMA Block Length Register
VDCREG_SATB     = $13           ; Sprite Attribute Table Address

;------------------------------------------------------------------------------;
; Reading VDC_STATUS register:
; 76543210
; ||||||||
; |||||||+- Sprite 0 Collision interrupt (CR)
; ||||||+-- Sprite Overflow interrupt (OR)
; |||||+--- Raster compare interrupt (RR)
; ||||+---- VRAM -> SAT DMA complete interrupt (DS)
; |||+----- VRAM -> VRAM DMA complete interrupt (DV)
; ||+------ VBlank interrupt (VD)
; |+------- VDC waiting for CPU access (BSY)
; +-------- always zero

;------------------------------------------------------------------------------;
; CR/Control register write:
; FEDCBA98 76543210
; |||||||| ||||||||
; |||||||| |||||||+- enable sprite 0 collision interrupt
; |||||||| ||||||+-- enable sprite overflow interrupt
; |||||||| |||||+--- enable raster compare interrupt
; |||||||| ||||+---- enable vblank interrupt/IRQ1
; |||||||| ||++----- external sync
; |||||||| |+------- sprite enable
; |||||||| +-------- background enable
; ||||||++---------- DISP terminal
; |||||+------------ DRAM refresh enable
; |||++------------- Increment value (00=+1; 01=+32; 10=+64; 11=+128)
; ||+--------------- ??????
; ++---------------- unused

; Constants: Control Register Defines
; Aliases for VDCREG_CR bits.

;                FEDCBA9876543210
VDC_CR_SP0COL = %0000000000000001
VDC_CR_SPROVR = %0000000000000010
VDC_CR_RCR    = %0000000000000100
VDC_CR_VBL    = %0000000000001000
VDC_CR_SPR    = %0000000001000000
VDC_CR_BG     = %0000000010000000
VDC_CR_DRAM   = %0000010000000000

;                 FEDCBA9876543210
VDC_CR_INC_1   = %0000000000000000
VDC_CR_INC_32  = %0000100000000000
VDC_CR_INC_64  = %0001000000000000
VDC_CR_INC_128 = %0001100000000000


;------------------------------------------------------------------------------;
; MWR/Memory Width register write:
; FEDCBA9876543210
; |______|||||||||
;     |   ||||||++- VRAM dot width; should use mode 0. (see pcetech.txt)
;     |   ||||++--- Sprite dot period
;     |   ||++----- Virtual screen width (00=32; 01=64; 10=128; 11=128)
;     |   |+------- Virtual screen height (0=32; 1=64)
;     |   +-------- "CG mode" (0=use bp0/1, zero bp2/3; 1=zero bp0/1, use bp2/3)
;     +------------ unused

; Constants: BAT Width defines
; Aliases for BAT Width bits of MWR register.
;
; BAT_WIDTH_32  - (%00<<4) 32 tiles wide
; BAT_WIDTH_64  - (%01<<4) 64 tiles wide
; BAT_WIDTH_128 - (%10<<4) 128 tiles wide

BAT_WIDTH_32  = %00<<4
BAT_WIDTH_64  = %01<<4
BAT_WIDTH_128 = %10<<4

; Constants: BAT Height defines
; Aliases for BAT Height bit of MWR register.
;
; BAT_HEIGHT_32 - (0<<6) 32 tiles high
; BAT_HEIGHT_64 - (1<<6) 64 tiles high

BAT_HEIGHT_32 = 0<<6
BAT_HEIGHT_64 = 1<<6

;------------------------------------------------------------------------------;
; DCR/DMA Control register write:
; FEDCBA9876543210
; |_________||||||
;       |    ||||+-- VRAM-SATB transfer complete interrupt enable
;       |    |||+--- VRAM-VRAM transfer complete interrupt enable
;       |    ||+---- Source address increment (0)/decrement (1)
;       |    |+----- Destination address increment (0)/decrement (1)
;       |    +------ "VRAM to SATB auto-transfer enable flag"
;       +----------- unused

VDC_DCR_IRQ_SATB  = %00000001
VDC_DCR_IRQ_VRAM  = %00000010
VDC_DCR_SRC_INCR  = %00000000
VDC_DCR_SRC_DECR  = %00000100
VDC_DCR_DST_INCR  = %00000000
VDC_DCR_DST_DECR  = %00001000
VDC_DCR_AUTO_SATB = %00010000

;------------------------------------------------------------------------------;
; video register names used in a lot of references typically go unexplained...
; the names actually come from a table in the Develo assembler book.

; the below table is an ascii representation of the data, slightly modified.
; (lowercase names are unofficial, since they were blank in the develo book)

;Reg|Name| bits and stuff
;---+----+-F-+-E-+-D-+-C-+-B-+-A-+-9-+-8-+-7-+-6-+-5-+-4-+-3-+-2-+-1-+-0-+
;$00|MAWR| MAWR                                                          |
;---+----+-F-+-E-+-D-+-C-+-B-+-A-+-9-+-8-+-7-+-6-+-5-+-4-+-3-+-2-+-1-+-0-+
;$01|MARR| MARR                                                          |
;---+----+-F-+-E-+-D-+-C-+-B-+-A-+-9-+-8-+-7-+-6-+-5-+-4-+-3-+-2-+-1-+-0-+
;$02| VWR| VWR                                                           |
;---+----+-F-+-E-+-D-+-C-+-B-+-A-+-9-+-8-+-7-+-6-+-5-+-4-+-3-+-2-+-1-+-0-+
;$02| VRR| VRR                                                           |
;---+----+-F-+-E-+-D-+-C-+-B-+-A-+-9-+-8-+-7-+-6-+-5-+-4-+-3-+-2-+-1-+-0-+
;$05|  CR|xxxxxxxxxxx|   IW  | DR|   TE  | BB| SB|   EX  |      IE       |
;---+----+-F-+-E-+-D-+-C-+-B-+-A-+-9-+-8-+-7-+-6-+-5-+-4-+-3-+-2-+-1-+-0-+
;$06| RCR|xxxxxxxxxxxxxxxxxxxxxxx|RCR                                    |
;---+----+-F-+-E-+-D-+-C-+-B-+-A-+-9-+-8-+-7-+-6-+-5-+-4-+-3-+-2-+-1-+-0-+
;$07| BXR|xxxxxxxxxxxxxxxxxxxxxxx|BXR                                    |
;---+----+-F-+-E-+-D-+-C-+-B-+-A-+-9-+-8-+-7-+-6-+-5-+-4-+-3-+-2-+-1-+-0-+
;$08| BYR|xxxxxxxxxxxxxxxxxxxxxxxxxxx|BYR                                |
;---+----+-F-+-E-+-D-+-C-+-B-+-A-+-9-+-8-+-7-+-6-+-5-+-4-+-3-+-2-+-1-+-0-+
;$09| MWR|xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx| CM|   SCREEN  |spr dot|vramdot|
;---+----+-F-+-E-+-D-+-C-+-B-+-A-+-9-+-8-+-7-+-6-+-5-+-4-+-3-+-2-+-1-+-0-+
;$0A| HSR|xxx|HDS                        |xxxxxxxxxxx|HSW                |
;---+----+-F-+-E-+-D-+-C-+-B-+-A-+-9-+-8-+-7-+-6-+-5-+-4-+-3-+-2-+-1-+-0-+
;$0B| HDR|xxx|HDE                        |xxx|HDW                        |
;---+----+-F-+-E-+-D-+-C-+-B-+-A-+-9-+-8-+-7-+-6-+-5-+-4-+-3-+-2-+-1-+-0-+
;$0C| VPR|VDS                            |xxxxxxxxxxx|VSW                |
;---+----+-F-+-E-+-D-+-C-+-B-+-A-+-9-+-8-+-7-+-6-+-5-+-4-+-3-+-2-+-1-+-0-+
;$0D| VDW|xxxxxxxxxxxxxxxxxxxxxxxxxxx|VDW                                |
;---+----+-F-+-E-+-D-+-C-+-B-+-A-+-9-+-8-+-7-+-6-+-5-+-4-+-3-+-2-+-1-+-0-+
;$0E| VCR|xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx|VCR                            |
;---+----+-F-+-E-+-D-+-C-+-B-+-A-+-9-+-8-+-7-+-6-+-5-+-4-+-3-+-2-+-1-+-0-+
;$0F| DCR|xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx| DV| DS| RR| OC| CR|
;---+----+-F-+-E-+-D-+-C-+-B-+-A-+-9-+-8-+-7-+-6-+-5-+-4-+-3-+-2-+-1-+-0-+
;$10|SOUR| SOUR                                                          |
;---+----+-F-+-E-+-D-+-C-+-B-+-A-+-9-+-8-+-7-+-6-+-5-+-4-+-3-+-2-+-1-+-0-+
;$11|DESR| DESR                                                          |
;---+----+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
; $12 (DMA Length) and $13 (VRAM-SATB Source Addr.) don't show up in the
; develo asm book's table. they're word length like MAWR, MARR, etc.
