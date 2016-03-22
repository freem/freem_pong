; library-specific ram defines
;==============================================================================;
; zero page
	.zeropage
	; $00-$0F: temporary variables
	tmp00:  .res 1
	tmp01:  .res 1
	tmp02:  .res 1
	tmp03:  .res 1
	tmp04:  .res 1
	tmp05:  .res 1
	tmp06:  .res 1
	tmp07:  .res 1
	tmp08:  .res 1
	tmp09:  .res 1
	tmp0A:  .res 1
	tmp0B:  .res 1
	tmp0C:  .res 1
	tmp0D:  .res 1
	tmp0E:  .res 1
	tmp0F:  .res 1

;------------------------------------------------------------------------------;
; shared zero-page variables
	vblanked: .res 1 ; is vblank finished?

;------------------------------------------------------------------------------;
; system-specific zero-page variables

	.ifdef __NES__
		int_ppuCtrl: .res 1 ; internal PPU_CTRL/$2000
		int_ppuMask: .res 1 ; internal PPU_MASK/$2001
		int_scrollX: .res 1 ; internal X scroll/PPU_SCROLL write 1
		int_scrollY: .res 1 ; internal Y scroll/PPU_SCROLL write 2

		nes_ntUpdate: .res 1 ; is a nametable update waiting?

		; joypad values
		nes_padState:   .res 2 ; joypad inputs (state)
		nes_padTrigger: .res 2 ; joypad inputs (trigger)
	.endif

	.ifdef __PCE__
		int_vdcStatus: .res 1 ; internal VDC_STATUS/$0000 copy
		int_vdcCtrl:   .res 2 ; internal VDCREG_CR copy
		int_vdcMWR:    .res 1 ; internal VDCREG_MWR copy
		int_vdcDMA:    .res 1 ; internal VDCREG_DCR copy
		int_scrollX:   .res 2 ; internal X scroll
		int_scrollY:   .res 2 ; internal Y scroll

		; VDC values
		pce_screenX: .res 2 ; screen X size (0-512)
		pce_screenY: .res 1 ; screen Y size (0-240)
		pce_batW:    .res 1 ; BAT width  (tiles)
		pce_batH:    .res 1 ; BAT height (tiles)

		; joypad values
		pce_padState:   .res 5 ; joypad inputs (state)
		pce_padTrigger: .res 5 ; joypad inputs (trigger)

		; todo: 6-button pad support
		;pce_padState6B:   .res 5 ; 6-button joypad inputs (state)
		;pce_padTrigger6B: .res 5 ; 6-button joypad inputs (trigger)

		; carve a chunk of ZP RAM out for self-modifying transfer code
		pce_quickTIA: .res 8 ; self-modifying transfer code
		; pce_quickTIA     | TIA opcode = $E3
		; pce_quickTIA+1,2 | source address (2 bytes)
		; pce_quickTIA+3,4 | destination address (2 bytes)
		; pce_quickTIA+5,6 | length (2 bytes)
		; pce_quickTIA+7   | rts = $60
	.endif

;==============================================================================;
; regular ram
	.bss

;------------------------------------------------------------------------------;
; NES-specific variables
	.ifdef __NES__
	nes_vramBuf: .res 128 ; VRAM update buffer
	; $00,$01 - destination nametable address
	; $02     - length and flags
	; $03...  - data

	; if length == 0, end of buffer reached

	.endif

;------------------------------------------------------------------------------;
; PCE-specific variables
	.ifdef __PCE__
	pce_satbBuf: .res 512 ; satb buffer
	.endif
