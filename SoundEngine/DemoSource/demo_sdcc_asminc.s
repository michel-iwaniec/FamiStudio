
FAMISTUDIO_CFG_C_BINDINGS = 1
FAMISTUDIO_CFG_SFX_SUPPORT = 1
;FAMISTUDIO_EXP_NONE = 1
;FAMISTUDIO_USE_PHASE_RESET = 1
;FAMISTUDIO_USE_FAMITRACKER_TEMPO = 1

; FamiStudio config.
FAMISTUDIO_CFG_EXTERNAL       = 1
FAMISTUDIO_CFG_DPCM_SUPPORT   = 1
FAMISTUDIO_CFG_SFX_SUPPORT    = 1 
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

.area _CODE

.globl _music_data_silver_surfer_c_stephen_ruddy
.globl _music_data_shatterhand
.globl _music_data_journey_to_silius
.globl _sounds

    ; SONG
song_silver_surfer::
    .include "song_silver_surfer_sdcc.s"
sfx_data:
    .include "sfx_sdcc.s"
song_journey_to_silius::
    .include "song_journey_to_silius_sdcc.s"
song_shatterhand::
    .include "song_shatterhand_sdcc.s"

;.area _DPCM (ABS)
;.org 0xE000
;.incbin "song_journey_to_silius_sdcc.dmc"
