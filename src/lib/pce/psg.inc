; file: psg.inc
; PSG related defines.
;==============================================================================;

; Constants: PSG registers
; Aliases for various PSG registers.
;
; PSG_CHANSELECT - ($0800) PSG channel select ($00-$05)
; PSG_GLOBALVOL  - ($0801) Global sound volume (top 4 bits: Left; bottom 4 bits: Right)
; PSG_FREQLO     - ($0802) Fine frequency adjust (bottom 8 bits)
; PSG_FREQHI     - ($0803) Coarse frequency adjust (top four bits)
; PSG_CHANCTRL   - ($0804) Channel on/off, DDA on/off, Channel volume
; PSG_CHANPAN    - ($0805) Channel sound balance/panning (Left/Right)
; PSG_CHANDATA   - ($0806) Channel sound data (5 bits)
; PSG_NOISE      - ($0807) Noise enable, Noise frequency
; PSG_LFOFREQ    - ($0808) LFO frequency
; PSG_LFOCONTROL - ($0809) LFO trigger, LFO control

PSG_MAIN        = $0800
;---------------;---------------;----------------------------------------------;
PSG_CHANSELECT  = PSG_MAIN+0    ; PSG Channel Select
PSG_GLOBALVOL   = PSG_MAIN+1    ; Global Sound Volume (top 4 bits: Left; bottom 4 bits: Right)
PSG_FREQLO      = PSG_MAIN+2    ; Fine Frequency Adjust (LSB)
PSG_FREQHI      = PSG_MAIN+3    ; Coarse Frequency Adjust (4 MSB)
PSG_CHANCTRL    = PSG_MAIN+4    ; Channel on/off, DDA on/off, Channel volume
PSG_CHANPAN     = PSG_MAIN+5    ; Channel Sound Balance (Left/Right)
PSG_CHANDATA    = PSG_MAIN+6    ; Channel sound data (5 bits)
PSG_NOISE       = PSG_MAIN+7    ; Noise enable, Noise frequency
PSG_LFOFREQ     = PSG_MAIN+8    ; LFO frequency
PSG_LFOCONTROL  = PSG_MAIN+9    ; LFO trigger, LFO control

;==============================================================================;
; Channel Control:
; 76543210
; ||||___|
; |||  |
; |||  +--- Channel Volume
; ||+------ unused
; |+------- DDA output (0=off; 1=on)
; +-------- Channel Enable (0=off; 1=on)

; Constants: Channel States
; Aliases for bits d6 and d7 of the channel control.
;
; PSG_CHSTATE_WRITE - (%00<<6) Writes to PSG_CHANDATA stores value in waveform buffer, increments waveform write index
; PSG_CHSTATE_RESET - (%01<<6) Reset waveform write index to 0
; PSG_CHSTATE_OUT   - (%10<<6) Enable waveform output
; PSG_CHSTATE_RAW   - (%11<<6) Direct D/A enabled; use raw writes to PSG_CHANDATA

PSG_CHSTATE_WRITE = %00<<6 ; 00 - write to PSG_CHANDATA/$0806 stores value in waveform buffer, advances waveform write index
PSG_CHSTATE_RESET = %01<<6 ; 01 - reset waveform write index to 0
PSG_CHSTATE_OUT   = %10<<6 ; 10 - waveform output enabled
PSG_CHSTATE_RAW   = %11<<6 ; 11 - direct d/a enabled, raw writes to PSG_CHANDATA/$0806

;==============================================================================;

; Constants: PSG channel panning defines
;
; PSG_PAN_CENTER    - ($FF) Both channels max volume.
; PSG_PAN_HARDLEFT  - ($F0) Hard Pan Left (Left=$F, Right=$0)
; PSG_PAN_HARDRIGHT - ($0F) Hard Pan Right (Left=$0, Right=$F)

PSG_PAN_CENTER    = $FF
PSG_PAN_HARDLEFT  = $F0
PSG_PAN_HARDRIGHT = $0F

;------------------------------------------------------------------------------;
; Topic: PSG frequency equations
;
; to get frequency (Hz) from n (a 12-bit value):
; >               3580000
; > frequency = -----------
; >               32 * n
;
; to get n (12 bit value) from a frequency (Hz):
; >       3580000
; > n = -----------
; >       32*freq

;==============================================================================;
; Noise control:
; 76543210
; ||||___|
; |||  |
; |||  +--- Noise frequency
; |++------ unused
; +-------- Noise Enable (0=off; 1=on)

; Topic: Noise frequency equations
; (^ in the below equations means "xor")
;
; to get frequency (Hz) from n (a 5-bit value):
; >               3580000
; > frequency = -----------
; >             64 * (n^31)
;
; to get n (5 bit value) from a frequency (Hz):
; >       3580000
; > n = ----------- ^ 31
; >       64*freq

;==============================================================================;
; LFO trigger, control:
; 76543210
; ||___|||
; |  |  ++- LFO control
; |  +----- unused
; +-------- LFO trigger (0=on; 1=off/reset)

; LFO control:
PSG_LFOTYPE_NONE  = %00 ; 00 - no frequency modulation
PSG_LFOTYPE_ADD   = %01 ; 01 - add FM data directly
PSG_LFOTYPE_ADDS4 = %10 ; 10 - FM data << 4, add to frequency
PSG_LFOTYPE_ADDS8 = %11 ; 11 - FM data << 8, add to frequency

; LFO trigger:
PSG_LFOTRIGGER_ON  = %00000000
PSG_LFOTRIGGER_OFF = %10000000

; todo: LFO frequency equation from psg.txt
