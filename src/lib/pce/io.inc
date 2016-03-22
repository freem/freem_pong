; file: io.inc
; I/O related macros and defines.
;==============================================================================;

; Joypad (on HuC6280)
JOYPAD = $1000 ; Joypad I/O (yes, all through one port.)

; The joypad works by reading this port multiple times, as needed.
; The values are typically active low (0=toggle on; 1=toggle off)

; (typically these are for reads; d0 and d1 are for writes too)
; 76543210
; ||||||||
; |||||||+-- Joypad pin 2 (R)/6(W)
; ||||||+--- Joypad pin 3 (R)/7(W)
; |||||+---- Joypad pin 4 (R)
; ||||+----- Joypad pin 5 (R)
; ||++------ (both bits are always 1)
; |+-------- Country bit (0=TG16/Export; 1=PCE/Domestic)
; +--------- CD-ROM base sense bit (0=attached; 1=not attached)

; Pin 2 = D0
; Pin 3 = D1
; Pin 4 = D2
; Pin 5 = D3
; Pin 6 = SEL (select)
; Pin 7 = CLR (clear)

;------------------------------------------------------------------------------;
; two-button controller read process
;       | d3 d2 d1 d0
;-------+-------------
; SEL=1 | Lf Rt Dn Up
; SEL=0 | Rn Se II I
;-------+-------------

; What should be done:
; 1) read first four values
; 2) values << 4 (upper half)
; 3) read next four values
; 4) 2-button controller read complete

;------------------------------------------------------------------------------;
; six-button controller read process
;         | d3 d2 d1 d0
;---------+-------------
; 1 SEL=1 | Lf Rt Dn Up
; 1 SEL=0 | Rn Se II I
;---------+-------------
; 2 SEL=1 | -  -  -  -
; 2 SEL=0 |III IV  V VI
;---------+-------------

; The 6 button controller, when in 6 button mode, sends writes differently.

;------------------------------------------------------------------------------;
; mouse read process
; (this is awkward as hell, but...)
; Mouse data is read four times
;         | d3 d2 d1 d0
;---------+-------------
; 1 SEL=1 | ?? ?? ?? ??
; 1 SEL=0 | ?? ?? ?? ??
;---------+-------------
; 2 SEL=1 | ?? ?? ?? ??
; 2 SEL=0 | ?? ?? ?? ??
;---------+-------------

; values are deltas; reading mouse every vsync is normal
; vertical movement:   up +, down -
; horizontal movement: left +, right -
; 0x25 seems to be the maximum delta you can get within 1 vsync
; (todo)

;------------------------------------------------------------------------------;
; turboexpress/pce gt link stuff

; cable has tip and two rings. 1/8" jack
; "buy an eighth-inch TRS (stereo) cable"


;------------------------------------------------------------------------------;

; Constants: Button masks
; Button defines for the combined input variables.
;
; JOY_I     - ($01/bit 0) Mask for Button I
; JOY_II    - ($02/bit 1) Mask for Button II
; JOY_SEL   - ($04/bit 2) Mask for Select Button
; JOY_RUN   - ($08/bit 3) Mask for Run Button
; JOY_UP    - ($10/bit 4) Mask for Direction Up
; JOY_RIGHT - ($20/bit 5) Mask for Direction Right
; JOY_DOWN  - ($40/bit 6) Mask for Direction Down
; JOY_LEFT  - ($80/bit 7) Mask for Direction Left

;-- Read 1 --;
JOY_UP    = $10
JOY_RIGHT = $20
JOY_DOWN  = $40
JOY_LEFT  = $80
;-- Read 2 --;
JOY_I     = $01 ; I Button
JOY_II    = $02 ; II Button
JOY_SEL   = $04 ; Select Button
JOY_RUN   = $08 ; Run Button

; xxx: fix the below defines

.if 0
JOY_TYPE6       = $50 ; mask for 6-button joypads
JOY_III         = $01 ; III Button
JOY_IV          = $02 ; IV Button
JOY_V           = $04 ; V Button
JOY_VI          = $08 ; VI Button
.endif

