
;.include "global.s"

;.title "DEMO_SDCC_ASMINC"
;.module AsmInc

FAMISTUDIO_CFG_C_BINDINGS = 1
;FAMISTUDIO_CFG_SFX_SUPPORT = 0 ;1
;FAMISTUDIO_EXP_NONE = 1
;FAMISTUDIO_USE_PHASE_RESET = 1
;FAMISTUDIO_USE_FAMITRACKER_TEMPO = 1

; FamiStudio config.
FAMISTUDIO_CFG_EXTERNAL       = 1
FAMISTUDIO_CFG_DPCM_SUPPORT   = 1
FAMISTUDIO_CFG_SFX_SUPPORT    = 0 ;1 
FAMISTUDIO_CFG_SFX_STREAMS    = 2
FAMISTUDIO_CFG_EQUALIZER      = 1
FAMISTUDIO_USE_VOLUME_TRACK   = 1
FAMISTUDIO_USE_PITCH_TRACK    = 1
FAMISTUDIO_USE_SLIDE_NOTES    = 1
FAMISTUDIO_USE_VIBRATO        = 1
FAMISTUDIO_USE_ARPEGGIO       = 1
FAMISTUDIO_CFG_SMOOTH_VIBRATO = 1
FAMISTUDIO_USE_RELEASE_NOTES  = 1
FAMISTUDIO_DPCM_OFF           = 0xe000

FAMISTUDIO_VERSION_MAJOR  = 4
FAMISTUDIO_VERSION_MINOR  = 1
FAMISTUDIO_VERSION_HOTFIX = 0



.include "..\famistudio_sdcc.s"

.area _HOME ;CODE_1

;.glbl song_silver_surfer
;.glbl sfx_data
;.glbl song_journey_to_silius
;.glbl song_shatterhand

.globl _music_data_silver_surfer_c_stephen_ruddy
.globl _music_data_shatterhand
.globl _music_data_journey_to_silius
.globl _sounds

    ; SONG
    ;.bank 1
    ;.org $a000
song_silver_surfer::
    .include "song_silver_surfer_sdcc.s"
sfx_data:
    .include "sfx_sdcc.s"
    ;.bank 2
    ;.org $c000
song_journey_to_silius::
    .include "song_journey_to_silius_sdcc.s"
    ;.org $d000
song_shatterhand::
    .include "song_shatterhand_sdcc.s"

;    ; DPCM
;    .bank 3
;    .org $e000
;    .incbin "song_journey_to_silius_nesasm.dmc"

;    ; VECTORS
;    .org $fffa
;    .dw nmi
;    .dw reset
;    .dw irq

;    ; CHARS
;    .bank 4
;    .org $0000
;    .incbin "demo.chr"
;    .incbin "demo.chr"
