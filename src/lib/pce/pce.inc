; file: pce.inc
; PC Engine/TG16 hardware defines/equates.
;
; Note: These mappings assume the $FF bank is in page $00 ($0000-$1FFF).
;==============================================================================;
	.include "vdc.inc"
	.include "vce.inc"
	.include "psg.inc"
	.include "io.inc"
;==============================================================================;
; Timer (on HuC6280)

TIMER_MAIN      = $0C00
;---------------;---------------;----------------------------------------------;
TIMER_COUNTER   = TIMER_MAIN    ; Timer Counter (read)/latch (write)
TIMER_CONTROL   = TIMER_MAIN+1  ; Timer Control

;==============================================================================;
; IRQ stuff

IRQ_DISABLE     = $1402 ; IRQ Disable toggle
IRQ_STATUS      = $1403 ; IRQ Status (Read); Acknowledge Timer interrupt (write)

; IRQ disable register write (1=inhibit/disable; 0=enable)
; 76543210
; |___||||
;   |  ||+- IRQ2/External
;   |  |+-- IRQ1/VDC
;   |  +--- Timer
;   +------ unused
; e.g. write $FC to enable IRQ1 and IRQ2; disable Timer IRQ

; IRQ status read (1=interrupt waiting)
; 76543210
; |___||||
;   |  ||+- IRQ2/External
;   |  |+-- IRQ1/VDC
;   |  +--- Timer
;   +------ unused

;==============================================================================;
; todo:
; * CDROM port at $1800 (also used for BRAM lock/unlock?)

;==============================================================================;
; Arcade Card (expansion card for CD games)

;---------------;---------------;----------------------------------------------;
ARCARD_PORT1    = $1A00         ; Arcade Card Port 1 ($1A00-$1A0A)
ARCARD_PORT2    = $1A10         ; Arcade Card Port 2 ($1A10-$1A1A)
ARCARD_PORT3    = $1A20         ; Arcade Card Port 3 ($1A20-$1A2A)
ARCARD_PORT4    = $1A30         ; Arcade Card Port 4 ($1A30-$1A3A)
;---------------;---------------;----------------------------------------------;
ARCARD_32BREG1  = $1AE0         ; 32-bit register part 1/4 (LSB)
ARCARD_32BREG2  = $1AE1         ; 32-bit register part 2/4
ARCARD_32BREG3  = $1AE2         ; 32-bit register part 3/4
ARCARD_32BREG4  = $1AE3         ; 32-bit register part 4/4 (MSB) + latch
ARCARD_SHIFT32  = $1AE4         ; Value to shift the 32-bit register by
ARCARD_ROTATE32 = $1AE5         ; Value to rotate the 32-bit register by
ARCARD_VERSION  = $1AEE         ; version of the Arcade Card
ARCARD_IDPORT   = $1AEF         ; Should always read as $51

;==============================================================================;
; Bank defines (incomplete)

BANK_REGISTERS  = $FF           ; hardware I/O etc.
BANK_RAM        = $F8           ; work ram, including zero page and stack
BANK_BRAM       = $F7           ; backup ram
