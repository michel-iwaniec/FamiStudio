;======================================================================================================================
; FAMISTUDIO SOUND ENGINE (4.1.0)
; Copyright (c) 2019-2023 Mathieu Gauthier
;
; Copying and distribution of this file, with or without
; modification, are permitted in any medium without royalty provided
; the copyright notice and this notice are preserved in all source
; code copies. This file is offered as-is, without any warranty.
;======================================================================================================================

;======================================================================================================================
; This is the FamiStudio sound engine. It is used by the NSF and ROM exporter of FamiStudio and can be used to make 
; games. It supports every feature from FamiStudio, some of them are toggeable to save CPU/memory.
;
; This is essentially a heavily modified version of FamiTone2 by Shiru. A lot of his code and comments are still
; present here, so massive thanks to him!! I am not trying to steal his work or anything, i renamed a lot of functions
; and variables because at some point it was becoming a mess of coding standards and getting hard to maintain.
;
; Moderately advanced users can probably figure out how to use the sound engine simply by reading these comments.
; For more in-depth documentation, please go to:
;
;    https://famistudio.org/doc/soundengine/
;======================================================================================================================

;======================================================================================================================
; INTERFACE
;
; The interface is pretty much the same as FamiTone2, with a slightly different naming convention. The subroutines you
; can call from your game are: 
;
;   - famistudio_init            : Initialize the engine with some music data.
;   - famistudio_music_play      : Start music playback with a specific song.
;   - famistudio_music_pause     : Pause/unpause music playback.
;   - famistudio_music_stop      : Stops music playback.
;   - famistudio_sfx_init        : Initialize SFX engine with SFX data.
;   - famistudio_sfx_play        : Play a SFX.
;   - famistudio_sfx_sample_play : Play a DPCM SFX.
;   - famistudio_update          : Updates the music/SFX engine, call once per frame, ideally from NMI.
;
; You can check the demo ROM to see how they are used or check out the online documentation for more info.
;======================================================================================================================

;======================================================================================================================
; CONFIGURATION
;
; There are 2 main ways of configuring the engine. 
;
;   1) The simplest way is right here, in the section below. Simply comment/uncomment these defines, and move on 
;      with your life.
;
;   2) The second way is "externally", using definitions coming from elsewhere in your app or the command line. If you
;      wish do so, simply define FAMISTUDIO_CFG_EXTERNAL=1 and this whole section will be ignored. You are then 
;      responsible for providing all configuration. This is useful if you have multiple projects that needs 
;      different configurations, while pointing to the same code file. This is how the provided demos and FamiStudio
;      uses it.
;
; Note that unless specified, the engine uses "if" and not "ifdef" for all boolean values so you need to define these
; to non-zero values. Undefined values will be assumed to be zero.
;
; There are 4 main things to configure, each of them will be detailed below.
;
;   1) Segments (ZP/RAM/PRG)
;   2) Audio expansion
;   3) Global engine parameters
;   4) Supported features
;======================================================================================================================

    .ifndef FAMISTUDIO_CFG_EXTERNAL 
FAMISTUDIO_CFG_EXTERNAL = 0
    .endif

; Set this to configure the sound engine from outside (in your app, or from the command line)
    ;.ifne !FAMISTUDIO_CFG_EXTERNAL
    .ifeq FAMISTUDIO_CFG_EXTERNAL

;======================================================================================================================
; 1) SEGMENT CONFIGURATION
;
; You need to tell where you want to allocate the zeropage, RAM and code. This section will be slightly different for
; each assembler.
;
; For NESASM, you can specify the .rsset location for zeroage and RAM/BSS as well as the .bank/.org for the engine 
; code. The .zp/.bss/.code section directives can also be emitted.  ALl these values are optional and will be tested
; as .ifdef. 
;======================================================================================================================

; Define this to emit the ".zp" directive before the zeropage variables.
; FAMISTUDIO_NESASM_ZP_SECTION   = 1

; Address where to allocate the zeropage variables that the engine use. 
;FAMISTUDIO_NESASM_ZP_RSSET     = 0x00a0

; Define this to emit the ".bss" directive before the RAM/BSS variables.
; FAMISTUDIO_NESASM_BSS_SECTION  = 1

; Address where to allocate the RAN/BSS variables that the engine use. 
; FAMISTUDIO_NESASM_BSS_RSSET    = 0x0400

; Define this to emit the ".code" directive before the code section.
; FAMISTUDIO_NESASM_CODE_SECTION = 1

; Define this to emit the ".bank" directive before the code section.
; FAMISTUDIO_NESASM_CODE_BANK    = 0

; Address where to place the engine code.
;FAMISTUDIO_NESASM_CODE_ORG     = 0x8000

;======================================================================================================================
; 2) AUDIO EXPANSION CONFIGURATION
;
; You can enable up to one audio expansion (FAMISTUDIO_EXP_XXX). Enabling more than one expansion will lead to
; undefined behavior. Memory usage goes up as more complex expansions are used. The audio expansion you choose
; **MUST MATCH** with the data you will load in the engine. Loading a FDS song while enabling VRC6 will lead to
; undefined behavior.
;======================================================================================================================

; Konami VRC6 (2 extra square + saw)
; FAMISTUDIO_EXP_VRC6          = 1 

; Konami VRC7 (6 FM channels)
; FAMISTUDIO_EXP_VRC7          = 1 

; Nintendo MMC5 (2 extra squares, extra DPCM not supported)
; FAMISTUDIO_EXP_MMC5          = 1 

; Sunsoft S5B (2 extra squares, advanced features not supported.)
; FAMISTUDIO_EXP_S5B           = 1 

; Famicom Disk System (extra wavetable channel)
; FAMISTUDIO_EXP_FDS           = 1 

; Namco 163 (between 1 and 8 extra wavetable channels) + number of channels.
; FAMISTUDIO_EXP_N163          = 1 
; FAMISTUDIO_EXP_N163_CHN_CNT  = 4

; EPSM (Expansion Port Sound Module)
; FAMISTUDIO_EXP_EPSM          = 1

;======================================================================================================================
; 3) GLOBAL ENGINE CONFIGURATION
;
; These are parameters that configures the engine, but are independent of the data you will be importing, such as
; which platform (PAL/NTSC) you want to support playback for, whether SFX are enabled or not, etc. They all have the
; form FAMISTUDIO_CFG_XXX.
;======================================================================================================================

; One of these MUST be defined (PAL or NTSC playback). Note that only NTSC support is supported when using any of the audio expansions.
; FAMISTUDIO_CFG_PAL_SUPPORT   = 1
FAMISTUDIO_CFG_NTSC_SUPPORT  = 1

; Support for sound effects playback + number of SFX that can play at once.
; FAMISTUDIO_CFG_SFX_SUPPORT   = 1 
; FAMISTUDIO_CFG_SFX_STREAMS   = 2

; Blaarg's smooth vibrato technique. Eliminates phase resets ("pops") on square channels. 
; FAMISTUDIO_CFG_SMOOTH_VIBRATO = 1 

; Enables DPCM playback support.
FAMISTUDIO_CFG_DPCM_SUPPORT   = 1

; Must be enabled if you are calling sound effects from a different thread than the sound engine update.
; FAMISTUDIO_CFG_THREAD         = 1     

;======================================================================================================================
; 4) SUPPORTED FEATURES CONFIGURATION
;
; Every feature supported in FamiStudio is supported by this sound engine. If you know for sure that you are not using
; specific features in your music, you can disable them to save memory/processing time. Using a feature in your song
; and failing to enable it will likely lead to crashes (BRK), or undefined behavior. They all have the form
; FAMISTUDIO_USE_XXX.
;======================================================================================================================

; Must be enabled if the songs you will be importing have been created using FamiTracker tempo mode. If you are using
; FamiStudio tempo mode, this must be undefined. You cannot mix and match tempo modes, the engine can only run in one
; mode or the other. 
; More information at: https://famistudio.org/doc/song/#tempo-modes
; FAMISTUDIO_USE_FAMITRACKER_TEMPO = 1

; Must be enabled if the songs uses delayed notes or delayed cuts. This is obviously only available when using
; FamiTracker tempo mode as FamiStudio tempo mode does not need this.
; FAMISTUDIO_USE_FAMITRACKER_DELAYED_NOTES_OR_CUTS = 1

; Must be enabled if the songs uses release notes. 
; More information at: https://famistudio.org/doc/pianoroll/#release-point
FAMISTUDIO_USE_RELEASE_NOTES = 1

; Must be enabled if any song uses the volume track. The volume track allows manipulating the volume at the track level
; independently from instruments.
; More information at: https://famistudio.org/doc/pianoroll/#editing-volume-tracks-effects
FAMISTUDIO_USE_VOLUME_TRACK      = 1

; Must be enabled if any song uses slides on the volume track. Volume track must be enabled too.
; More information at: https://famistudio.org/doc/pianoroll/#editing-volume-tracks-effects
; FAMISTUDIO_USE_VOLUME_SLIDES     = 1

; Must be enabled if any song uses the pitch track. The pitch track allows manipulating the pitch at the track level
; independently from instruments.
; More information at: https://famistudio.org/doc/pianoroll/#pitch
FAMISTUDIO_USE_PITCH_TRACK       = 1

; Must be enabled if any song uses slide notes. Slide notes allows portamento and slide effects.
; More information at: https://famistudio.org/doc/pianoroll/#slide-notes
FAMISTUDIO_USE_SLIDE_NOTES       = 1

; Must be enabled if any song uses slide notes on the noise channel too. 
; More information at: https://famistudio.org/doc/pianoroll/#slide-notes
; FAMISTUDIO_USE_NOISE_SLIDE_NOTES = 1

; Must be enabled if any song uses the vibrato speed/depth effect track. 
; More information at: https://famistudio.org/doc/pianoroll/#vibrato-depth-speed
FAMISTUDIO_USE_VIBRATO           = 1

; Must be enabled if any song uses arpeggios (not to be confused with instrument arpeggio envelopes, those are always
; supported).
; More information at: (TODO)
FAMISTUDIO_USE_ARPEGGIO          = 1

; Must be enabled if any song uses the "Duty Cycle" effect (equivalent of FamiTracker Vxx, also called "Timbre").  
; FAMISTUDIO_USE_DUTYCYCLE_EFFECT  = 1

; Must be enabled if any song uses the DPCM delta counter. Only makes sense if DPCM samples
; are enabled (FAMISTUDIO_CFG_DPCM_SUPPORT).
; More information at: (TODO)
; FAMISTUDIO_USE_DELTA_COUNTER     = 1

; Must be enabled if your project uses more than 1 bank of DPCM samples.
; When using this, you must implement the "famistudio_dpcm_bank_callback" callback 
; and switch to the correct bank every time a sample is played.
; FAMISTUDIO_USE_DPCM_BANKSWITCHING = 1

; Must be enabled if your project uses more than 63 unique DPCM mappings (a mapping is DPCM sample
; assigned to a note, with a specific pitch/loop, etc.). Implied when using FAMISTUDIO_USE_DPCM_BANKSWITCHING.
; FAMISTUDIO_USE_DPCM_EXTENDED_RANGE = 1

; Must be enabled if your project uses the "Phase Reset" effect.
; FAMISTUDIO_USE_PHASE_RESET = 1

.endif

; Memory location of the DPCM samples. Must be between 0xc000 and 0xffc0, and a multiple of 64.
.ifndef FAMISTUDIO_DPCM_OFF
    FAMISTUDIO_DPCM_OFF = 0xc000
.endif

;======================================================================================================================
; END OF CONFIGURATION
;
; Ideally, you should not have to change anything below this line.
;======================================================================================================================

;======================================================================================================================
; INTERNAL DEFINES (Do not touch)
;======================================================================================================================

    .ifndef FAMISTUDIO_EXP_VRC6
FAMISTUDIO_EXP_VRC6 = 0
    .endif

    .ifndef FAMISTUDIO_EXP_VRC7
FAMISTUDIO_EXP_VRC7 = 0
    .endif

    .ifndef FAMISTUDIO_EXP_EPSM
FAMISTUDIO_EXP_EPSM = 0
    .endif

    .ifndef FAMISTUDIO_EXP_MMC5
FAMISTUDIO_EXP_MMC5 = 0
    .endif

    .ifndef FAMISTUDIO_EXP_S5B
FAMISTUDIO_EXP_S5B = 0
    .endif

    .ifndef FAMISTUDIO_EXP_FDS
FAMISTUDIO_EXP_FDS = 0
    .endif

    .ifndef FAMISTUDIO_EXP_N163
FAMISTUDIO_EXP_N163 = 0
    .endif

    .ifndef FAMISTUDIO_EXP_N163_CHN_CNT
FAMISTUDIO_EXP_N163_CHN_CNT = 1
    .endif

    .ifndef FAMISTUDIO_CFG_PAL_SUPPORT
FAMISTUDIO_CFG_PAL_SUPPORT = 0
    .endif

    .ifndef FAMISTUDIO_CFG_NTSC_SUPPORT
        .if FAMISTUDIO_CFG_PAL_SUPPORT
FAMISTUDIO_CFG_NTSC_SUPPORT = 0
        .else
FAMISTUDIO_CFG_NTSC_SUPPORT = 1
        .endif
    .endif

    ;.if (FAMISTUDIO_CFG_NTSC_SUPPORT != 0) & (FAMISTUDIO_CFG_PAL_SUPPORT != 0)
    .if FAMISTUDIO_CFG_NTSC_SUPPORT & FAMISTUDIO_CFG_PAL_SUPPORT
FAMISTUDIO_DUAL_SUPPORT = 1
    .else
FAMISTUDIO_DUAL_SUPPORT = 0
    .endif

    .ifndef FAMISTUDIO_CFG_SFX_SUPPORT
FAMISTUDIO_CFG_SFX_SUPPORT = 0
FAMISTUDIO_CFG_SFX_STREAMS = 0
    .endif

    .ifndef FAMISTUDIO_CFG_SFX_STREAMS
FAMISTUDIO_CFG_SFX_STREAMS = 1
    .endif

    .ifndef FAMISTUDIO_CFG_SMOOTH_VIBRATO
FAMISTUDIO_CFG_SMOOTH_VIBRATO = 0
    .endif

    .ifndef FAMISTUDIO_CFG_DPCM_SUPPORT
FAMISTUDIO_CFG_DPCM_SUPPORT = 0
    .endif

    .ifndef FAMISTUDIO_CFG_EQUALIZER
FAMISTUDIO_CFG_EQUALIZER = 0
    .endif

    .ifndef FAMISTUDIO_USE_FAMITRACKER_TEMPO
FAMISTUDIO_USE_FAMITRACKER_TEMPO = 0
    .endif

    .ifndef FAMISTUDIO_USE_FAMITRACKER_DELAYED_NOTES_OR_CUTS
FAMISTUDIO_USE_FAMITRACKER_DELAYED_NOTES_OR_CUTS = 0
    .endif

    .ifndef FAMISTUDIO_USE_VOLUME_TRACK
FAMISTUDIO_USE_VOLUME_TRACK = 0
    .endif

    .ifndef FAMISTUDIO_USE_VOLUME_SLIDES
FAMISTUDIO_USE_VOLUME_SLIDES = 0
    .endif

    .ifndef FAMISTUDIO_USE_PITCH_TRACK
FAMISTUDIO_USE_PITCH_TRACK = 0
    .endif

    .ifndef FAMISTUDIO_USE_SLIDE_NOTES
FAMISTUDIO_USE_SLIDE_NOTES = 0
    .endif

    .ifndef FAMISTUDIO_USE_NOISE_SLIDE_NOTES
FAMISTUDIO_USE_NOISE_SLIDE_NOTES = 0
    .endif

    .ifndef FAMISTUDIO_USE_VIBRATO
FAMISTUDIO_USE_VIBRATO = 0
    .endif

    .ifndef FAMISTUDIO_USE_ARPEGGIO
FAMISTUDIO_USE_ARPEGGIO = 0
    .endif

    .ifndef FAMISTUDIO_USE_DUTYCYCLE_EFFECT
FAMISTUDIO_USE_DUTYCYCLE_EFFECT = 0
    .endif

    .ifndef FAMISTUDIO_USE_DELTA_COUNTER
FAMISTUDIO_USE_DELTA_COUNTER = 0
    .endif
    
    .ifndef FAMISTUDIO_USE_PHASE_RESET
FAMISTUDIO_USE_PHASE_RESET = 0
    .endif

    .ifndef FAMISTUDIO_USE_RELEASE_NOTES
FAMISTUDIO_USE_RELEASE_NOTES = 0    
    .endif
    
    .ifndef FAMISTUDIO_USE_DPCM_EXTENDED_RANGE
FAMISTUDIO_USE_DPCM_EXTENDED_RANGE = 0
    .endif

    .ifndef FAMISTUDIO_USE_DPCM_BANKSWITCHING
FAMISTUDIO_USE_DPCM_BANKSWITCHING = 0
    .endif

    .ifndef FAMISTUDIO_CFG_THREAD
FAMISTUDIO_CFG_THREAD = 0
    .endif

    .ifeq (FAMISTUDIO_EXP_VRC6 + FAMISTUDIO_EXP_VRC7 + FAMISTUDIO_EXP_EPSM + FAMISTUDIO_EXP_MMC5 + FAMISTUDIO_EXP_S5B + FAMISTUDIO_EXP_FDS + FAMISTUDIO_EXP_N163)
FAMISTUDIO_EXP_NONE = 1
    .else
FAMISTUDIO_EXP_NONE = 0
    .endif

    .if FAMISTUDIO_EXP_VRC7 + FAMISTUDIO_EXP_EPSM + FAMISTUDIO_EXP_N163 + FAMISTUDIO_EXP_FDS + FAMISTUDIO_EXP_S5B
FAMISTUDIO_EXP_NOTE_START = 5
    .endif
    .if FAMISTUDIO_EXP_VRC6
FAMISTUDIO_EXP_NOTE_START = 7
    .endif

    ;.if (FAMISTUDIO_USE_NOISE_SLIDE_NOTES != 0) & (FAMISTUDIO_USE_SLIDE_NOTES = 0)
    .if FAMISTUDIO_USE_NOISE_SLIDE_NOTES & ~FAMISTUDIO_USE_SLIDE_NOTES
    .error "Noise slide notes can only be used when regular slide notes are enabled too."
    .endif

    ;.if (FAMISTUDIO_USE_VOLUME_SLIDES != 0) & (FAMISTUDIO_USE_VOLUME_TRACK = 0)
    .if FAMISTUDIO_USE_VOLUME_SLIDES & ~FAMISTUDIO_USE_VOLUME_TRACK
    .error "Volume slides can only be used when the volume track is enabled too."
    .endif

    ;.if (FAMISTUDIO_USE_FAMITRACKER_DELAYED_NOTES_OR_CUTS != 0) & (FAMISTUDIO_USE_FAMITRACKER_TEMPO = 0)
    .if FAMISTUDIO_USE_FAMITRACKER_DELAYED_NOTES_OR_CUTS & ~FAMISTUDIO_USE_FAMITRACKER_TEMPO
    .error "Delayed notes or cuts only make sense when using FamiTracker tempo."
    .endif

    ;.if (FAMISTUDIO_EXP_VRC6 + FAMISTUDIO_EXP_VRC7 + FAMISTUDIO_EXP_EPSM + FAMISTUDIO_EXP_MMC5 + FAMISTUDIO_EXP_S5B + FAMISTUDIO_EXP_FDS + FAMISTUDIO_EXP_N163) > 1
    .if (FAMISTUDIO_EXP_VRC6 + FAMISTUDIO_EXP_VRC7 + FAMISTUDIO_EXP_EPSM + FAMISTUDIO_EXP_MMC5 + FAMISTUDIO_EXP_S5B + FAMISTUDIO_EXP_FDS + FAMISTUDIO_EXP_N163)
    .error "Only one audio expansion can be enabled."
    .endif

    ;.if (FAMISTUDIO_EXP_N163 != 0) & ((FAMISTUDIO_EXP_N163_CHN_CNT < 1) | (FAMISTUDIO_EXP_N163_CHN_CNT > 8))
;    .if FAMISTUDIO_EXP_N163 & ~FAMISTUDIO_EXP_N163_CHN_CNT | (FAMISTUDIO_EXP_N163_CHN_CNT > 8))
;    .error "N163 only supports between 1 and 8 channels."
;    .endif

    .if FAMISTUDIO_USE_DELTA_COUNTER & ~FAMISTUDIO_CFG_DPCM_SUPPORT
    .error "Delta counter only makes sense if DPCM samples are enabled."
    .endif

    .if FAMISTUDIO_USE_DPCM_BANKSWITCHING & ~FAMISTUDIO_CFG_DPCM_SUPPORT
    .error "DPCM bankswitching only makes sense if DPCM samples are enabled."
    .endif


.define FAMISTUDIO_DPCM_PTR "(FAMISTUDIO_DPCM_OFF & 0x3fff) >> 6"


;.define FAMISTUDIO_NUM_ENVELOPES "3+3+2+3"
    .ifdef FAMISTUDIO_EXP_NONE
FAMISTUDIO_NUM_ENVELOPES        = 3+3+2+3
;.define FAMISTUDIO_NUM_ENVELOPES "3+3+2+3"
FAMISTUDIO_NUM_PITCH_ENVELOPES  = 3
FAMISTUDIO_NUM_CHANNELS         = 5
FAMISTUDIO_NUM_DUTY_CYCLES      = 3   
    .endif
    .if FAMISTUDIO_EXP_VRC6
FAMISTUDIO_NUM_ENVELOPES        = 3+3+2+3+3+3+3
FAMISTUDIO_NUM_PITCH_ENVELOPES  = 6
FAMISTUDIO_NUM_CHANNELS         = 8
FAMISTUDIO_NUM_DUTY_CYCLES      = 6
    .endif
    .if FAMISTUDIO_EXP_VRC7
FAMISTUDIO_NUM_ENVELOPES        = 3+3+2+3+2+2+2+2+2+2
FAMISTUDIO_NUM_PITCH_ENVELOPES  = 9
FAMISTUDIO_NUM_CHANNELS         = 11
FAMISTUDIO_NUM_DUTY_CYCLES      = 3
    .endif
    .if FAMISTUDIO_EXP_EPSM
FAMISTUDIO_EXP_EPSM_CHANNELS    = 15
FAMISTUDIO_NUM_ENVELOPES        = 3+3+2+3+(FAMISTUDIO_EXP_EPSM_CHANNELS*2)+2+2+2
FAMISTUDIO_NUM_PITCH_ENVELOPES  = 18
FAMISTUDIO_NUM_CHANNELS         = 20
FAMISTUDIO_NUM_DUTY_CYCLES      = 3
    .endif
    .if FAMISTUDIO_EXP_FDS
FAMISTUDIO_NUM_ENVELOPES        = 3+3+2+3+2
FAMISTUDIO_NUM_PITCH_ENVELOPES  = 4
FAMISTUDIO_NUM_CHANNELS         = 6
FAMISTUDIO_NUM_DUTY_CYCLES      = 3   
    .endif
    .if FAMISTUDIO_EXP_MMC5
FAMISTUDIO_NUM_ENVELOPES        = 3+3+2+3+3+3
FAMISTUDIO_NUM_PITCH_ENVELOPES  = 5
FAMISTUDIO_NUM_CHANNELS         = 7
FAMISTUDIO_NUM_DUTY_CYCLES      = 5   
    .endif
    .if FAMISTUDIO_EXP_N163
FAMISTUDIO_NUM_ENVELOPES        = 3+3+2+3+(FAMISTUDIO_EXP_N163_CHN_CNT*3)
FAMISTUDIO_NUM_PITCH_ENVELOPES  = 3+FAMISTUDIO_EXP_N163_CHN_CNT
FAMISTUDIO_NUM_CHANNELS         = 5+FAMISTUDIO_EXP_N163_CHN_CNT
FAMISTUDIO_NUM_DUTY_CYCLES      = 3   
    .endif
    .if FAMISTUDIO_EXP_S5B
FAMISTUDIO_NUM_ENVELOPES        = 3+3+2+3+4+4+4
FAMISTUDIO_NUM_PITCH_ENVELOPES  = 6
FAMISTUDIO_NUM_CHANNELS         = 8
FAMISTUDIO_NUM_DUTY_CYCLES      = 3
    .endif

    .if FAMISTUDIO_EXP_NONE
FAMISTUDIO_NUM_VOLUME_SLIDES = 4
    .else
;FAMISTUDIO_NUM_VOLUME_SLIDES = FAMISTUDIO_NUM_CHANNELS ; DPCM volume is unused.
.define FAMISTUDIO_NUM_VOLUME_SLIDES "FAMISTUDIO_NUM_CHANNELS"
    .endif

    .if FAMISTUDIO_USE_NOISE_SLIDE_NOTES
FAMISTUDIO_NUM_SLIDES = FAMISTUDIO_NUM_PITCH_ENVELOPES + 1
    .else
;FAMISTUDIO_NUM_SLIDES = FAMISTUDIO_NUM_PITCH_ENVELOPES
.define FAMISTUDIO_NUM_SLIDES "FAMISTUDIO_NUM_PITCH_ENVELOPES"
    .endif

; Keep the noise slide at the end so the pitch envelopes/slides are in sync.
;FAMISTUDIO_NOISE_SLIDE_INDEX = FAMISTUDIO_NUM_SLIDES - 1

.define FAMISTUDIO_NOISE_SLIDE_INDEX "FAMISTUDIO_NUM_SLIDES - 1"

    .if FAMISTUDIO_EXP_VRC6
FAMISTUDIO_VRC6_CH0_PITCH_ENV_IDX = 3
FAMISTUDIO_VRC6_CH1_PITCH_ENV_IDX = 4
FAMISTUDIO_VRC6_CH2_PITCH_ENV_IDX = 5
    .endif
    .if FAMISTUDIO_EXP_VRC7
FAMISTUDIO_VRC7_CH0_PITCH_ENV_IDX = 3
FAMISTUDIO_VRC7_CH1_PITCH_ENV_IDX = 4
FAMISTUDIO_VRC7_CH2_PITCH_ENV_IDX = 5
FAMISTUDIO_VRC7_CH3_PITCH_ENV_IDX = 6
FAMISTUDIO_VRC7_CH4_PITCH_ENV_IDX = 7
FAMISTUDIO_VRC7_CH5_PITCH_ENV_IDX = 8
    .endif
    .if FAMISTUDIO_EXP_FDS
FAMISTUDIO_FDS_CH0_PITCH_ENV_IDX  = 3
    .endif
    .if FAMISTUDIO_EXP_MMC5
FAMISTUDIO_MMC5_CH0_PITCH_ENV_IDX = 3
FAMISTUDIO_MMC5_CH1_PITCH_ENV_IDX = 4  
    .endif
    .if FAMISTUDIO_EXP_N163
FAMISTUDIO_N163_CH0_PITCH_ENV_IDX = 3
FAMISTUDIO_N163_CH1_PITCH_ENV_IDX = 4
FAMISTUDIO_N163_CH2_PITCH_ENV_IDX = 5
FAMISTUDIO_N163_CH3_PITCH_ENV_IDX = 6
FAMISTUDIO_N163_CH4_PITCH_ENV_IDX = 7
FAMISTUDIO_N163_CH5_PITCH_ENV_IDX = 8
FAMISTUDIO_N163_CH6_PITCH_ENV_IDX = 9
FAMISTUDIO_N163_CH7_PITCH_ENV_IDX = 10
    .endif
    .if FAMISTUDIO_EXP_S5B
FAMISTUDIO_S5B_CH0_PITCH_ENV_IDX  = 3
FAMISTUDIO_S5B_CH1_PITCH_ENV_IDX  = 4
FAMISTUDIO_S5B_CH2_PITCH_ENV_IDX  = 5
    .endif
    .if FAMISTUDIO_EXP_EPSM
FAMISTUDIO_EPSM_CH0_PITCH_ENV_IDX = 3
FAMISTUDIO_EPSM_CH1_PITCH_ENV_IDX = 4
FAMISTUDIO_EPSM_CH2_PITCH_ENV_IDX = 5
FAMISTUDIO_EPSM_CH3_PITCH_ENV_IDX = 6
FAMISTUDIO_EPSM_CH4_PITCH_ENV_IDX = 7
FAMISTUDIO_EPSM_CH5_PITCH_ENV_IDX = 8
FAMISTUDIO_EPSM_CH6_PITCH_ENV_IDX = 9
FAMISTUDIO_EPSM_CH7_PITCH_ENV_IDX = 10
FAMISTUDIO_EPSM_CH8_PITCH_ENV_IDX = 11
FAMISTUDIO_EPSM_CH9_PITCH_ENV_IDX = 12
FAMISTUDIO_EPSM_CH10_PITCH_ENV_IDX = 13
FAMISTUDIO_EPSM_CH11_PITCH_ENV_IDX = 14
FAMISTUDIO_EPSM_CH12_PITCH_ENV_IDX = 15
FAMISTUDIO_EPSM_CH13_PITCH_ENV_IDX = 16
FAMISTUDIO_EPSM_CH14_PITCH_ENV_IDX = 17
    .endif

; TODO: Investigate reshuffling the envelopes to keep them contiguously 
; by type (all volumes envelopes, all arp envelopes, etc.) instead of 
; by channel. This *may* simplify a lot of places where we need a lookup
; table (famistudio_channel_to_volume_env, etc.)
FAMISTUDIO_CH0_ENVS = 0
FAMISTUDIO_CH1_ENVS = 3
FAMISTUDIO_CH2_ENVS = 6
FAMISTUDIO_CH3_ENVS = 8

    .if FAMISTUDIO_EXP_VRC6
FAMISTUDIO_VRC6_CH0_ENVS = 11
FAMISTUDIO_VRC6_CH1_ENVS = 14
FAMISTUDIO_VRC6_CH2_ENVS = 17
    .endif
    .if FAMISTUDIO_EXP_VRC7
FAMISTUDIO_VRC7_CH0_ENVS = 11
FAMISTUDIO_VRC7_CH1_ENVS = 13
FAMISTUDIO_VRC7_CH2_ENVS = 15
FAMISTUDIO_VRC7_CH3_ENVS = 17
FAMISTUDIO_VRC7_CH4_ENVS = 19
FAMISTUDIO_VRC7_CH5_ENVS = 21
    .endif
    .if FAMISTUDIO_EXP_FDS
FAMISTUDIO_FDS_CH0_ENVS = 11
    .endif
    .if FAMISTUDIO_EXP_MMC5
FAMISTUDIO_MMC5_CH0_ENVS = 11
FAMISTUDIO_MMC5_CH1_ENVS = 14
    .endif
    .if FAMISTUDIO_EXP_N163
FAMISTUDIO_N163_CH0_ENVS = 11
FAMISTUDIO_N163_CH1_ENVS = 14
FAMISTUDIO_N163_CH2_ENVS = 17
FAMISTUDIO_N163_CH3_ENVS = 20
FAMISTUDIO_N163_CH4_ENVS = 23
FAMISTUDIO_N163_CH5_ENVS = 26
FAMISTUDIO_N163_CH6_ENVS = 29
FAMISTUDIO_N163_CH7_ENVS = 32
    .endif
    .if FAMISTUDIO_EXP_S5B
FAMISTUDIO_S5B_CH0_ENVS = 11
FAMISTUDIO_S5B_CH1_ENVS = 15
FAMISTUDIO_S5B_CH2_ENVS = 19
    .endif
    .if FAMISTUDIO_EXP_EPSM
FAMISTUDIO_EPSM_CH0_ENVS = 11
FAMISTUDIO_EPSM_CH1_ENVS = 15
FAMISTUDIO_EPSM_CH2_ENVS = 19
FAMISTUDIO_EPSM_CH3_ENVS = 23
FAMISTUDIO_EPSM_CH4_ENVS = 25
FAMISTUDIO_EPSM_CH5_ENVS = 27
FAMISTUDIO_EPSM_CH6_ENVS = 29
FAMISTUDIO_EPSM_CH7_ENVS = 31
FAMISTUDIO_EPSM_CH8_ENVS = 33
FAMISTUDIO_EPSM_CH9_ENVS = 35
FAMISTUDIO_EPSM_CH10_ENVS = 37
FAMISTUDIO_EPSM_CH11_ENVS = 39
FAMISTUDIO_EPSM_CH12_ENVS = 41
FAMISTUDIO_EPSM_CH13_ENVS = 43
FAMISTUDIO_EPSM_CH14_ENVS = 45
    .endif

FAMISTUDIO_ENV_VOLUME_OFF        = 0
FAMISTUDIO_ENV_NOTE_OFF          = 1
FAMISTUDIO_ENV_DUTY_OFF          = 2
FAMISTUDIO_ENV_N163_WAVE_IDX_OFF = 2
FAMISTUDIO_ENV_MIXER_IDX_OFF     = 2
FAMISTUDIO_ENV_NOISE_IDX_OFF     = 3

    .if FAMISTUDIO_EXP_VRC6
FAMISTUDIO_VRC6_CH0_DUTY_IDX = 3
FAMISTUDIO_VRC6_CH1_DUTY_IDX = 4
FAMISTUDIO_VRC6_CH2_DUTY_IDX = 5
    .endif
    .if FAMISTUDIO_EXP_MMC5
FAMISTUDIO_MMC5_CH0_DUTY_IDX = 3
FAMISTUDIO_MMC5_CH1_DUTY_IDX = 4
    .endif

    .if FAMISTUDIO_EXP_VRC6
FAMISTUDIO_VRC6_CH0_IDX = 5
FAMISTUDIO_VRC6_CH1_IDX = 6
FAMISTUDIO_VRC6_CH2_IDX = 7
    .else
FAMISTUDIO_VRC6_CH0_IDX = -1
FAMISTUDIO_VRC6_CH1_IDX = -1
FAMISTUDIO_VRC6_CH2_IDX = -1
    .endif
    .if FAMISTUDIO_EXP_VRC7
FAMISTUDIO_VRC7_CH0_IDX = 5
FAMISTUDIO_VRC7_CH1_IDX = 6
FAMISTUDIO_VRC7_CH2_IDX = 7
FAMISTUDIO_VRC7_CH3_IDX = 8
FAMISTUDIO_VRC7_CH4_IDX = 9
FAMISTUDIO_VRC7_CH5_IDX = 10
    .endif
    .if FAMISTUDIO_EXP_FDS
FAMISTUDIO_FDS_CH0_IDX  = 5
    .endif
    .if FAMISTUDIO_EXP_MMC5
FAMISTUDIO_MMC5_CH0_IDX = 5
FAMISTUDIO_MMC5_CH1_IDX = 6
    .else
FAMISTUDIO_MMC5_CH0_IDX = -1
FAMISTUDIO_MMC5_CH1_IDX = -1
    .endif
    .if FAMISTUDIO_EXP_N163
FAMISTUDIO_N163_CH0_IDX = 5
FAMISTUDIO_N163_CH1_IDX = 6
FAMISTUDIO_N163_CH2_IDX = 7
FAMISTUDIO_N163_CH3_IDX = 8
FAMISTUDIO_N163_CH4_IDX = 9
FAMISTUDIO_N163_CH5_IDX = 10
FAMISTUDIO_N163_CH6_IDX = 11
FAMISTUDIO_N163_CH7_IDX = 12
    .endif
    .if FAMISTUDIO_EXP_S5B
FAMISTUDIO_S5B_CH0_IDX  = 5
FAMISTUDIO_S5B_CH1_IDX  = 6
FAMISTUDIO_S5B_CH2_IDX  = 7
    .endif
    .if FAMISTUDIO_EXP_EPSM
FAMISTUDIO_EPSM_CH0_IDX = 5
FAMISTUDIO_EPSM_CH1_IDX = 6
FAMISTUDIO_EPSM_CH2_IDX = 7
FAMISTUDIO_EPSM_CHAN_FM_START = 8
FAMISTUDIO_EPSM_CH3_IDX = 8
FAMISTUDIO_EPSM_CH4_IDX = 9
FAMISTUDIO_EPSM_CH5_IDX = 10
FAMISTUDIO_EPSM_CH6_IDX = 11
FAMISTUDIO_EPSM_CH7_IDX = 12
FAMISTUDIO_EPSM_CH8_IDX = 13
FAMISTUDIO_EPSM_CHAN_RHYTHM_START = 14
FAMISTUDIO_EPSM_CH9_IDX = 14
FAMISTUDIO_EPSM_CH10_IDX = 15
FAMISTUDIO_EPSM_CH11_IDX = 16
FAMISTUDIO_EPSM_CH12_IDX = 17
FAMISTUDIO_EPSM_CH13_IDX = 18
FAMISTUDIO_EPSM_CH14_IDX = 19
    .endif

FAMISTUDIO_VRC7_PITCH_SHIFT = 3
FAMISTUDIO_EPSM_PITCH_SHIFT = 3

    ;.if (FAMISTUDIO_EXP_N163_CHN_CNT > 4)
    .ifgt (FAMISTUDIO_EXP_N163_CHN_CNT - 4)
FAMISTUDIO_N163_PITCH_SHIFT = 5
    .endif
;    .if (FAMISTUDIO_EXP_N163_CHN_CNT > 2) & (FAMISTUDIO_EXP_N163_CHN_CNT <= 4)
;FAMISTUDIO_N163_PITCH_SHIFT = 4
;    .endif
;    .if (FAMISTUDIO_EXP_N163_CHN_CNT > 1) & (FAMISTUDIO_EXP_N163_CHN_CNT <= 2)
;FAMISTUDIO_N163_PITCH_SHIFT = 3
;    .endif
;    .if (FAMISTUDIO_EXP_N163_CHN_CNT = 1)
;FAMISTUDIO_N163_PITCH_SHIFT = 2
;    .endif 

    .if FAMISTUDIO_EXP_VRC7
FAMISTUDIO_PITCH_SHIFT = FAMISTUDIO_VRC7_PITCH_SHIFT
    .else
    .if FAMISTUDIO_EXP_EPSM
FAMISTUDIO_PITCH_SHIFT = FAMISTUDIO_EPSM_PITCH_SHIFT
    .else
    .if FAMISTUDIO_EXP_N163
FAMISTUDIO_PITCH_SHIFT = FAMISTUDIO_N163_PITCH_SHIFT
    .else
FAMISTUDIO_PITCH_SHIFT = 0
    .endif    
    .endif    
    .endif

    .if FAMISTUDIO_EXP_N163
FAMISTUDIO_N163_CHN_MASK = (FAMISTUDIO_EXP_N163_CHN_CNT - 1) << 4
    .endif

    .if FAMISTUDIO_CFG_SFX_SUPPORT
FAMISTUDIO_SFX_STRUCT_SIZE = 15

FAMISTUDIO_SFX_CH0 = FAMISTUDIO_SFX_STRUCT_SIZE * 0
FAMISTUDIO_SFX_CH1 = FAMISTUDIO_SFX_STRUCT_SIZE * 1
FAMISTUDIO_SFX_CH2 = FAMISTUDIO_SFX_STRUCT_SIZE * 2
FAMISTUDIO_SFX_CH3 = FAMISTUDIO_SFX_STRUCT_SIZE * 3
    .endif

FAMISTUDIO_FIRST_EXP_INST_CHANNEL = 5

    .if FAMISTUDIO_EXP_EPSM
FAMISTUDIO_FIRST_POSITIVE_SLIDE_CHANNEL = 6
    .else
FAMISTUDIO_FIRST_POSITIVE_SLIDE_CHANNEL = 3
    .endif

;======================================================================================================================
; RAM VARIABLES (You should not have to play with these)
;======================================================================================================================

;    .ifdef FAMISTUDIO_NESASM_BSS_SECTION
;    .bss
;    .endif
;    .ifdef FAMISTUDIO_NESASM_BSS_RSSET
;    .rsset FAMISTUDIO_NESASM_BSS_RSSET 
;    .endif

.area _BSS

famistudio_env_value:             .ds FAMISTUDIO_NUM_ENVELOPES
famistudio_env_repeat:            .ds FAMISTUDIO_NUM_ENVELOPES
famistudio_env_addr_lo:           .ds FAMISTUDIO_NUM_ENVELOPES
famistudio_env_addr_hi:           .ds FAMISTUDIO_NUM_ENVELOPES
famistudio_env_ptr:               .ds FAMISTUDIO_NUM_ENVELOPES

famistudio_pitch_env_value_lo:    .ds FAMISTUDIO_NUM_PITCH_ENVELOPES
famistudio_pitch_env_value_hi:    .ds FAMISTUDIO_NUM_PITCH_ENVELOPES
famistudio_pitch_env_repeat:      .ds FAMISTUDIO_NUM_PITCH_ENVELOPES
famistudio_pitch_env_addr_lo:     .ds FAMISTUDIO_NUM_PITCH_ENVELOPES
famistudio_pitch_env_addr_hi:     .ds FAMISTUDIO_NUM_PITCH_ENVELOPES
famistudio_pitch_env_ptr:         .ds FAMISTUDIO_NUM_PITCH_ENVELOPES
    .if FAMISTUDIO_USE_PITCH_TRACK
famistudio_pitch_env_fine_value:  .ds FAMISTUDIO_NUM_PITCH_ENVELOPES
    .endif

    .if FAMISTUDIO_USE_SLIDE_NOTES
famistudio_slide_step:            .ds FAMISTUDIO_NUM_SLIDES
famistudio_slide_pitch_lo:        .ds FAMISTUDIO_NUM_SLIDES
famistudio_slide_pitch_hi:        .ds FAMISTUDIO_NUM_SLIDES
    .endif

famistudio_chn_ptr_lo:            .ds FAMISTUDIO_NUM_CHANNELS
famistudio_chn_ptr_hi:            .ds FAMISTUDIO_NUM_CHANNELS
famistudio_chn_note:              .ds FAMISTUDIO_NUM_CHANNELS
famistudio_chn_instrument:        .ds FAMISTUDIO_NUM_CHANNELS
famistudio_chn_repeat:            .ds FAMISTUDIO_NUM_CHANNELS
famistudio_chn_return_lo:         .ds FAMISTUDIO_NUM_CHANNELS
famistudio_chn_return_hi:         .ds FAMISTUDIO_NUM_CHANNELS
famistudio_chn_ref_len:           .ds FAMISTUDIO_NUM_CHANNELS
    .if FAMISTUDIO_USE_VOLUME_TRACK
famistudio_chn_volume_track:      .ds FAMISTUDIO_NUM_CHANNELS
    .if FAMISTUDIO_USE_VOLUME_SLIDES
famistudio_chn_volume_slide_step:   .ds FAMISTUDIO_NUM_VOLUME_SLIDES
famistudio_chn_volume_slide_target: .ds FAMISTUDIO_NUM_VOLUME_SLIDES
    .endif
    .endif
    .if FAMISTUDIO_USE_VIBRATO | FAMISTUDIO_USE_ARPEGGIO
famistudio_chn_env_override:      .ds FAMISTUDIO_NUM_CHANNELS ; bit 7 = pitch, bit 0 = arpeggio.
    .endif
    .if FAMISTUDIO_USE_FAMITRACKER_DELAYED_NOTES_OR_CUTS
famistudio_chn_note_delay:        .ds FAMISTUDIO_NUM_CHANNELS
famistudio_chn_cut_delay:         .ds FAMISTUDIO_NUM_CHANNELS
    .endif
    .if FAMISTUDIO_EXP_N163 | FAMISTUDIO_EXP_VRC7 | FAMISTUDIO_EXP_FDS | FAMISTUDIO_EXP_EPSM
famistudio_chn_inst_changed:      .ds FAMISTUDIO_NUM_CHANNELS - FAMISTUDIO_FIRST_EXP_INST_CHANNEL
    .endif
    .if FAMISTUDIO_CFG_EQUALIZER
famistudio_chn_note_counter:      .ds FAMISTUDIO_NUM_CHANNELS
    .endif
    .if FAMISTUDIO_USE_PHASE_RESET
famistudio_phase_reset:           .ds 1 ; bit 0/1 = 2a03, bit 2/3/4 = vrc6, 5/6 = mmc5, bit 7 = fds
    .if FAMISTUDIO_EXP_N163
famistudio_phase_reset_n163:      .ds 1 ; bit 0...7 = n163
    .endif
    .endif
    .if FAMISTUDIO_USE_DELTA_COUNTER
famistudio_dmc_delta_counter:     .ds 1
    .endif
    .if FAMISTUDIO_EXP_VRC6
famistudio_vrc6_saw_volume:       .ds 1 ; -1 = 1/4, 0 = 1/2, 1 = Full
    .endif
    .if FAMISTUDIO_EXP_VRC7
famistudio_chn_vrc7_prev_hi:      .ds 6
famistudio_chn_vrc7_patch:        .ds 6
famistudio_chn_vrc7_trigger:      .ds 6 ; bit 0 = new note triggered, bit 7 = note released.
    .endif
    .if FAMISTUDIO_EXP_EPSM
famistudio_chn_epsm_trigger:      .ds 6 ; bit 0 = new note triggered, bit 7 = note released.
famistudio_chn_epsm_rhythm_key:   .ds 6
famistudio_chn_epsm_rhythm_stereo: .ds 6
famistudio_chn_epsm_fm_stereo:    .ds 6
famistudio_chn_epsm_alg:          .ds 6
famistudio_chn_epsm_vol_op1:      .ds 6
famistudio_chn_epsm_vol_op2:      .ds 6
famistudio_chn_epsm_vol_op3:      .ds 6
famistudio_chn_epsm_vol_op4:      .ds 6
    .endif
    .if FAMISTUDIO_EXP_N163
famistudio_chn_n163_wave_index:   .ds FAMISTUDIO_EXP_N163_CHN_CNT
famistudio_chn_n163_wave_len:     .ds FAMISTUDIO_EXP_N163_CHN_CNT
    .endif
    .if FAMISTUDIO_USE_DUTYCYCLE_EFFECT
famistudio_duty_cycle:            .ds FAMISTUDIO_NUM_DUTY_CYCLES
    .endif

    .if FAMISTUDIO_USE_FAMITRACKER_TEMPO
famistudio_tempo_step_lo:         .ds 1
famistudio_tempo_step_hi:         .ds 1
famistudio_tempo_acc_lo:          .ds 1
famistudio_tempo_acc_hi:          .ds 1
    .if FAMISTUDIO_USE_FAMITRACKER_DELAYED_NOTES_OR_CUTS
famistudio_tempo_advance_row:     .ds 1
    .endif
    .else
famistudio_tempo_env_ptr_lo:      .ds 1
famistudio_tempo_env_ptr_hi:      .ds 1
famistudio_tempo_env_counter:     .ds 1
famistudio_tempo_env_idx:         .ds 1
famistudio_tempo_frame_num:       .ds 1
famistudio_tempo_frame_cnt:       .ds 1
    .endif

famistudio_pal_adjust:            .ds 1
famistudio_song_list_lo:          .ds 1
famistudio_song_list_hi:          .ds 1
famistudio_instrument_lo:         .ds 1
famistudio_instrument_hi:         .ds 1
famistudio_dpcm_list_lo:          .ds 1 ; TODO: Not needed if DPCM support is disabled.
famistudio_dpcm_list_hi:          .ds 1 ; TODO: Not needed if DPCM support is disabled.
famistudio_dpcm_effect:           .ds 1 ; TODO: Not needed if DPCM support is disabled.
famistudio_pulse1_prev:           .ds 1
famistudio_pulse2_prev:           .ds 1
famistudio_song_speed             = famistudio_chn_instrument+4

    .if FAMISTUDIO_EXP_MMC5
famistudio_mmc5_pulse1_prev:      .ds 1
famistudio_mmc5_pulse2_prev:      .ds 1
.endif

    .if FAMISTUDIO_EXP_FDS
famistudio_fds_mod_speed:         .ds 2
famistudio_fds_mod_depth:         .ds 1
famistudio_fds_mod_delay:         .ds 1
famistudio_fds_override_flags:    .ds 1 ; Bit 7 = mod speed overriden, bit 6 mod depth overriden
    .endif

    .if FAMISTUDIO_EXP_VRC7
famistudio_vrc7_dummy:            .ds 1 ; TODO: Find a dummy address i can simply write to without side effects.
    .endif

; FDS, N163 and VRC7 have very different instrument layout and are 16-bytes, so we keep them seperate.
    .if FAMISTUDIO_EXP_FDS | FAMISTUDIO_EXP_N163 | FAMISTUDIO_EXP_VRC7 | FAMISTUDIO_EXP_EPSM | FAMISTUDIO_EXP_S5B
famistudio_exp_instrument_lo:     .ds 1
famistudio_exp_instrument_hi:     .ds 1
    .endif

    .if FAMISTUDIO_CFG_SFX_SUPPORT

famistudio_output_buf:     .ds 11
famistudio_sfx_addr_lo:    .ds 1
famistudio_sfx_addr_hi:    .ds 1
famistudio_sfx_base_addr:  .ds (FAMISTUDIO_CFG_SFX_STREAMS * FAMISTUDIO_SFX_STRUCT_SIZE)

; TODO: Refactor SFX memory layout. These uses a AoS approach, not fan. 
famistudio_sfx_repeat = famistudio_sfx_base_addr + 0
famistudio_sfx_ptr_lo = famistudio_sfx_base_addr + 1
famistudio_sfx_ptr_hi = famistudio_sfx_base_addr + 2
famistudio_sfx_offset = famistudio_sfx_base_addr + 3
famistudio_sfx_buffer = famistudio_sfx_base_addr + 4

    .endif 

;======================================================================================================================
; ZEROPAGE VARIABLES
;
; These are only used as temporary variable during the famistudio_xxx calls.
; Feel free to alias those with other ZP values in your programs to save a few bytes.
;======================================================================================================================

;    .ifdef FAMISTUDIO_NESASM_ZP_SECTION
;    .zp
;    .endif
;    .ifdef FAMISTUDIO_NESASM_ZP_RSSET
;    .rsset FAMISTUDIO_NESASM_ZP_RSSET 
;    .endif

.area _ZP (PAG)

famistudio_r0:   .rs 1
famistudio_r1:   .rs 1
famistudio_r2:   .rs 1

famistudio_ptr0: .rs 2
famistudio_ptr1: .rs 2

famistudio_ptr0_lo = famistudio_ptr0+0
famistudio_ptr0_hi = famistudio_ptr0+1
famistudio_ptr1_lo = famistudio_ptr1+0
famistudio_ptr1_hi = famistudio_ptr1+1

;======================================================================================================================
; CODE
;======================================================================================================================

;    .ifdef FAMISTUDIO_NESASM_CODE_SECTION
;    .code
;    .endif
;    .ifdef FAMISTUDIO_NESASM_CODE_BANK
;    .bank FAMISTUDIO_NESASM_CODE_BANK 
;    .endif
;    .ifdef FAMISTUDIO_NESASM_CODE_ORG
;    .org FAMISTUDIO_NESASM_CODE_ORG 
;    .endif

.area _CODE

FAMISTUDIO_APU_PL1_VOL    = 0x4000
FAMISTUDIO_APU_PL1_SWEEP  = 0x4001
FAMISTUDIO_APU_PL1_LO     = 0x4002
FAMISTUDIO_APU_PL1_HI     = 0x4003
FAMISTUDIO_APU_PL2_VOL    = 0x4004
FAMISTUDIO_APU_PL2_SWEEP  = 0x4005
FAMISTUDIO_APU_PL2_LO     = 0x4006
FAMISTUDIO_APU_PL2_HI     = 0x4007
FAMISTUDIO_APU_TRI_LINEAR = 0x4008
FAMISTUDIO_APU_TRI_LO     = 0x400a
FAMISTUDIO_APU_TRI_HI     = 0x400b
FAMISTUDIO_APU_NOISE_VOL  = 0x400c
FAMISTUDIO_APU_NOISE_LO   = 0x400e
FAMISTUDIO_APU_NOISE_HI   = 0x400f
FAMISTUDIO_APU_DMC_FREQ   = 0x4010
FAMISTUDIO_APU_DMC_RAW    = 0x4011
FAMISTUDIO_APU_DMC_START  = 0x4012
FAMISTUDIO_APU_DMC_LEN    = 0x4013
FAMISTUDIO_APU_SND_CHN    = 0x4015
FAMISTUDIO_APU_FRAME_CNT  = 0x4017

    .if FAMISTUDIO_EXP_VRC6
FAMISTUDIO_VRC6_PL1_VOL   = 0x9000
FAMISTUDIO_VRC6_PL1_LO    = 0x9001
FAMISTUDIO_VRC6_PL1_HI    = 0x9002
FAMISTUDIO_VRC6_PL2_VOL   = 0xa000
FAMISTUDIO_VRC6_PL2_LO    = 0xa001
FAMISTUDIO_VRC6_PL2_HI    = 0xa002
FAMISTUDIO_VRC6_SAW_VOL   = 0xb000
FAMISTUDIO_VRC6_SAW_LO    = 0xb001
FAMISTUDIO_VRC6_SAW_HI    = 0xb002
    .endif

    .if FAMISTUDIO_EXP_VRC7
FAMISTUDIO_VRC7_SILENCE   = 0xe000
FAMISTUDIO_VRC7_REG_SEL   = 0x9010
FAMISTUDIO_VRC7_REG_WRITE = 0x9030
FAMISTUDIO_VRC7_REG_LO_1  = 0x10
FAMISTUDIO_VRC7_REG_LO_2  = 0x11
FAMISTUDIO_VRC7_REG_LO_3  = 0x12
FAMISTUDIO_VRC7_REG_LO_4  = 0x13
FAMISTUDIO_VRC7_REG_LO_5  = 0x14
FAMISTUDIO_VRC7_REG_LO_6  = 0x15
FAMISTUDIO_VRC7_REG_HI_1  = 0x20
FAMISTUDIO_VRC7_REG_HI_2  = 0x21
FAMISTUDIO_VRC7_REG_HI_3  = 0x22
FAMISTUDIO_VRC7_REG_HI_4  = 0x23
FAMISTUDIO_VRC7_REG_HI_5  = 0x24
FAMISTUDIO_VRC7_REG_HI_6  = 0x25
FAMISTUDIO_VRC7_REG_VOL_1 = 0x30
FAMISTUDIO_VRC7_REG_VOL_2 = 0x31
FAMISTUDIO_VRC7_REG_VOL_3 = 0x32
FAMISTUDIO_VRC7_REG_VOL_4 = 0x33
FAMISTUDIO_VRC7_REG_VOL_5 = 0x34
FAMISTUDIO_VRC7_REG_VOL_6 = 0x35 
    .endif

    .if FAMISTUDIO_EXP_EPSM
FAMISTUDIO_EPSM_REG_SEL0   = 0x401c
FAMISTUDIO_EPSM_REG_WRITE0 = 0x401d
FAMISTUDIO_EPSM_REG_SEL1   = 0x401e
FAMISTUDIO_EPSM_REG_WRITE1 = 0x401f
FAMISTUDIO_EPSM_REG_KEY    = 0x28
FAMISTUDIO_EPSM_REG_DT_MUL = 0x30
FAMISTUDIO_EPSM_REG_TL     = 0x40
FAMISTUDIO_EPSM_REG_KS_AR  = 0x50
FAMISTUDIO_EPSM_REG_AMO_DR = 0x60
FAMISTUDIO_EPSM_REG_SR     = 0x70
FAMISTUDIO_EPSM_REG_SL_RR  = 0x80
FAMISTUDIO_EPSM_REG_SSG    = 0x90
FAMISTUDIO_EPSM_REG_FN_LO  = 0xA0
FAMISTUDIO_EPSM_REG_FN_LO2 = 0xA1
FAMISTUDIO_EPSM_REG_FN_LO3 = 0xA2
FAMISTUDIO_EPSM_REG_FN_HI  = 0xA4
FAMISTUDIO_EPSM_REG_FN_HI2 = 0xA5
FAMISTUDIO_EPSM_REG_FN_HI3 = 0xA6
FAMISTUDIO_EPSM_REG_FB     = 0xB0
FAMISTUDIO_EPSM_REG_AM_PM  = 0xB4
FAMISTUDIO_EPSM_REG_LFO    = 0x22
FAMISTUDIO_EPSM_REG_RHY_KY = 0x10
FAMISTUDIO_EPSM_REG_RHY_BD = 0x18
FAMISTUDIO_EPSM_REG_RHY_SD = 0x19
FAMISTUDIO_EPSM_REG_RHY_TC = 0x1a
FAMISTUDIO_EPSM_REG_RHY_HH = 0x1b
FAMISTUDIO_EPSM_REG_RHY_TOM = 0x1c
FAMISTUDIO_EPSM_REG_RHY_RIM = 0x1d
FAMISTUDIO_EPSM_REG_LO_1  = 0x10
FAMISTUDIO_EPSM_REG_LO_2  = 0x11
FAMISTUDIO_EPSM_REG_LO_3  = 0x12
FAMISTUDIO_EPSM_REG_LO_4  = 0x13
FAMISTUDIO_EPSM_REG_LO_5  = 0x14
FAMISTUDIO_EPSM_REG_LO_6  = 0x15
FAMISTUDIO_EPSM_REG_HI_1  = 0x20
FAMISTUDIO_EPSM_REG_HI_2  = 0x21
FAMISTUDIO_EPSM_REG_HI_3  = 0x22
FAMISTUDIO_EPSM_REG_HI_4  = 0x23
FAMISTUDIO_EPSM_REG_HI_5  = 0x24
FAMISTUDIO_EPSM_REG_HI_6  = 0x25
FAMISTUDIO_EPSM_REG_VOL_1 = 0x30
FAMISTUDIO_EPSM_REG_VOL_2 = 0x31
FAMISTUDIO_EPSM_REG_VOL_3 = 0x32
FAMISTUDIO_EPSM_REG_VOL_4 = 0x33
FAMISTUDIO_EPSM_REG_VOL_5 = 0x34
FAMISTUDIO_EPSM_REG_VOL_6 = 0x35 
FAMISTUDIO_EPSM_ADDR       = 0x401c
FAMISTUDIO_EPSM_DATA       = 0x401d
FAMISTUDIO_EPSM_REG_LO_A   = 0x00
FAMISTUDIO_EPSM_REG_HI_A   = 0x01
FAMISTUDIO_EPSM_REG_LO_B   = 0x02
FAMISTUDIO_EPSM_REG_HI_B   = 0x03
FAMISTUDIO_EPSM_REG_LO_C   = 0x04
FAMISTUDIO_EPSM_REG_HI_C   = 0x05
FAMISTUDIO_EPSM_REG_NOISE  = 0x06
FAMISTUDIO_EPSM_REG_TONE   = 0x07
FAMISTUDIO_EPSM_REG_VOL_A  = 0x08
FAMISTUDIO_EPSM_REG_VOL_B  = 0x09
FAMISTUDIO_EPSM_REG_VOL_C  = 0x0a
FAMISTUDIO_EPSM_REG_ENV_LO = 0x0b
FAMISTUDIO_EPSM_REG_ENV_HI = 0x0c
FAMISTUDIO_EPSM_REG_SHAPE  = 0x0d
FAMISTUDIO_EPSM_REG_IO_A   = 0x0e
FAMISTUDIO_EPSM_REG_IO_B   = 0x0f
    .endif

    .if FAMISTUDIO_EXP_MMC5
FAMISTUDIO_MMC5_PL1_VOL   = 0x5000
FAMISTUDIO_MMC5_PL1_SWEEP = 0x5001
FAMISTUDIO_MMC5_PL1_LO    = 0x5002
FAMISTUDIO_MMC5_PL1_HI    = 0x5003
FAMISTUDIO_MMC5_PL2_VOL   = 0x5004
FAMISTUDIO_MMC5_PL2_SWEEP = 0x5005
FAMISTUDIO_MMC5_PL2_LO    = 0x5006
FAMISTUDIO_MMC5_PL2_HI    = 0x5007
FAMISTUDIO_MMC5_PCM_MODE  = 0x5010
FAMISTUDIO_MMC5_SND_CHN   = 0x5015
    .endif

    .if FAMISTUDIO_EXP_N163
FAMISTUDIO_N163_SILENCE       = 0xe000
FAMISTUDIO_N163_ADDR          = 0xf800
FAMISTUDIO_N163_DATA          = 0x4800 
FAMISTUDIO_N163_REG_FREQ_LO   = 0x78
FAMISTUDIO_N163_REG_PHASE_LO  = 0x79
FAMISTUDIO_N163_REG_FREQ_MID  = 0x7a
FAMISTUDIO_N163_REG_PHASE_MID = 0x7b
FAMISTUDIO_N163_REG_FREQ_HI   = 0x7c
FAMISTUDIO_N163_REG_PHASE_HI  = 0x7d
FAMISTUDIO_N163_REG_WAVE      = 0x7e
FAMISTUDIO_N163_REG_VOLUME    = 0x7f
    .endif

    .if FAMISTUDIO_EXP_S5B
FAMISTUDIO_S5B_ADDR       = 0xc000
FAMISTUDIO_S5B_DATA       = 0xe000
FAMISTUDIO_S5B_REG_LO_A   = 0x00
FAMISTUDIO_S5B_REG_HI_A   = 0x01
FAMISTUDIO_S5B_REG_LO_B   = 0x02
FAMISTUDIO_S5B_REG_HI_B   = 0x03
FAMISTUDIO_S5B_REG_LO_C   = 0x04
FAMISTUDIO_S5B_REG_HI_C   = 0x05
FAMISTUDIO_S5B_REG_NOISE  = 0x06
FAMISTUDIO_S5B_REG_TONE   = 0x07
FAMISTUDIO_S5B_REG_VOL_A  = 0x08
FAMISTUDIO_S5B_REG_VOL_B  = 0x09
FAMISTUDIO_S5B_REG_VOL_C  = 0x0a
FAMISTUDIO_S5B_REG_ENV_LO = 0x0b
FAMISTUDIO_S5B_REG_ENV_HI = 0x0c
FAMISTUDIO_S5B_REG_SHAPE  = 0x0d
FAMISTUDIO_S5B_REG_IO_A   = 0x0e
FAMISTUDIO_S5B_REG_IO_B   = 0x0f
    .endif

    .if FAMISTUDIO_EXP_FDS
FAMISTUDIO_FDS_WAV_START  = 0x4040
FAMISTUDIO_FDS_VOL_ENV    = 0x4080
FAMISTUDIO_FDS_FREQ_LO    = 0x4082
FAMISTUDIO_FDS_FREQ_HI    = 0x4083
FAMISTUDIO_FDS_SWEEP_ENV  = 0x4084
FAMISTUDIO_FDS_SWEEP_BIAS = 0x4085
FAMISTUDIO_FDS_MOD_LO     = 0x4086
FAMISTUDIO_FDS_MOD_HI     = 0x4087
FAMISTUDIO_FDS_MOD_TABLE  = 0x4088
FAMISTUDIO_FDS_VOL        = 0x4089
FAMISTUDIO_FDS_ENV_SPEED  = 0x408A
    .endif

    ;.if !FAMISTUDIO_CFG_SFX_SUPPORT
    .ifeq FAMISTUDIO_CFG_SFX_SUPPORT
; Output directly to APU
FAMISTUDIO_ALIAS_PL1_VOL    = FAMISTUDIO_APU_PL1_VOL
FAMISTUDIO_ALIAS_PL1_LO     = FAMISTUDIO_APU_PL1_LO
FAMISTUDIO_ALIAS_PL1_HI     = FAMISTUDIO_APU_PL1_HI
FAMISTUDIO_ALIAS_PL2_VOL    = FAMISTUDIO_APU_PL2_VOL
FAMISTUDIO_ALIAS_PL2_LO     = FAMISTUDIO_APU_PL2_LO
FAMISTUDIO_ALIAS_PL2_HI     = FAMISTUDIO_APU_PL2_HI
FAMISTUDIO_ALIAS_TRI_LINEAR = FAMISTUDIO_APU_TRI_LINEAR
FAMISTUDIO_ALIAS_TRI_LO     = FAMISTUDIO_APU_TRI_LO
FAMISTUDIO_ALIAS_TRI_HI     = FAMISTUDIO_APU_TRI_HI
FAMISTUDIO_ALIAS_NOISE_VOL  = FAMISTUDIO_APU_NOISE_VOL
FAMISTUDIO_ALIAS_NOISE_LO   = FAMISTUDIO_APU_NOISE_LO
    .else 
; Otherwise write to the output buffer
FAMISTUDIO_ALIAS_PL1_VOL    = famistudio_output_buf + 0
FAMISTUDIO_ALIAS_PL1_LO     = famistudio_output_buf + 1
FAMISTUDIO_ALIAS_PL1_HI     = famistudio_output_buf + 2
FAMISTUDIO_ALIAS_PL2_VOL    = famistudio_output_buf + 3
FAMISTUDIO_ALIAS_PL2_LO     = famistudio_output_buf + 4
FAMISTUDIO_ALIAS_PL2_HI     = famistudio_output_buf + 5
FAMISTUDIO_ALIAS_TRI_LINEAR = famistudio_output_buf + 6
FAMISTUDIO_ALIAS_TRI_LO     = famistudio_output_buf + 7
FAMISTUDIO_ALIAS_TRI_HI     = famistudio_output_buf + 8
FAMISTUDIO_ALIAS_NOISE_VOL  = famistudio_output_buf + 9
FAMISTUDIO_ALIAS_NOISE_LO   = famistudio_output_buf + 10
    .endif

;======================================================================================================================
; FAMISTUDIO_INIT (public)
;
; Reset APU, initialize the sound engine with some music data.
; 
; [in] a : Playback platform, zero for PAL, non-zero for NTSC.
; [in] x : Pointer to music data (lo)
; [in] y : Pointer to music data (hi)
;======================================================================================================================

_famistudio_init:
    
.define .music_data_ptr "famistudio_ptr0"

    stx famistudio_song_list_lo
    sty famistudio_song_list_hi
    stx *.music_data_ptr+0
    sty *.music_data_ptr+1

    .if FAMISTUDIO_DUAL_SUPPORT
    tax
    beq .pal
    lda #97
.pal:
    .else
        .if FAMISTUDIO_CFG_PAL_SUPPORT
        lda #0
        .endif
        .if FAMISTUDIO_CFG_NTSC_SUPPORT
        lda #97
        .endif
    .endif
    sta famistudio_pal_adjust

    jsr _famistudio_music_stop

    ; Instrument address
    ldy #1
    lda [*.music_data_ptr],y
    sta famistudio_instrument_lo
    iny
    lda [*.music_data_ptr],y
    sta famistudio_instrument_hi
    iny

    ; Expansions instrument address
    .if FAMISTUDIO_EXP_FDS | FAMISTUDIO_EXP_N163 | FAMISTUDIO_EXP_VRC7 | FAMISTUDIO_EXP_EPSM | FAMISTUDIO_EXP_S5B
        lda [*.music_data_ptr],y
        sta famistudio_exp_instrument_lo
        iny
        lda [*.music_data_ptr],y
        sta famistudio_exp_instrument_hi
        iny
    .endif

    ; Sample list address
    lda [*.music_data_ptr],y
    sta famistudio_dpcm_list_lo
    iny
    lda [*.music_data_ptr],y
    sta famistudio_dpcm_list_hi

    lda #0x80 ; Previous pulse period MSB, to not write it when not changed
    sta famistudio_pulse1_prev
    sta famistudio_pulse2_prev

    lda #0x0f ; Enable channels, stop DMC
    sta FAMISTUDIO_APU_SND_CHN
    lda #0x80 ; Disable triangle length counter
    sta FAMISTUDIO_APU_TRI_LINEAR
    lda #0x00 ; Load noise length
    sta FAMISTUDIO_APU_NOISE_HI

    lda #0x30 ; Volumes to 0
    sta FAMISTUDIO_APU_PL1_VOL
    sta FAMISTUDIO_APU_PL2_VOL
    sta FAMISTUDIO_APU_NOISE_VOL
    lda #0x08 ; No sweep
    sta FAMISTUDIO_APU_PL1_SWEEP
    sta FAMISTUDIO_APU_PL2_SWEEP

    .if FAMISTUDIO_EXP_VRC7
.init_vrc7:
    lda #0
    sta FAMISTUDIO_VRC7_SILENCE ; Enable VRC7 audio.
    .endif

.init_epsm:
    .if FAMISTUDIO_EXP_EPSM
    lda #FAMISTUDIO_EPSM_REG_TONE
    sta FAMISTUDIO_EPSM_ADDR
    lda #0x38 ; No noise, just 3 tones for now.
    sta FAMISTUDIO_EPSM_DATA
    lda #0x29
    sta FAMISTUDIO_EPSM_ADDR
    lda #0x80 
    sta FAMISTUDIO_EPSM_DATA
    lda #0x27
    sta FAMISTUDIO_EPSM_ADDR
    lda #0x00 
    sta FAMISTUDIO_EPSM_DATA
    lda #0x11
    sta FAMISTUDIO_EPSM_ADDR
    lda #0x37 
    sta FAMISTUDIO_EPSM_DATA
.endif
    .if FAMISTUDIO_EXP_MMC5
.init_mmc5:
    lda #0x00
    sta FAMISTUDIO_MMC5_PCM_MODE
    lda #0x03
    sta FAMISTUDIO_MMC5_SND_CHN
    lda #0x80 ; Previous pulse period MSB, to not write it when not changed
    sta famistudio_mmc5_pulse1_prev
    sta famistudio_mmc5_pulse2_prev    
.endif

    .if FAMISTUDIO_EXP_S5B
.init_s5b:
    lda #FAMISTUDIO_S5B_REG_TONE
    sta FAMISTUDIO_S5B_ADDR
    lda #0x38 ; No noise, just 3 tones for now.
    sta FAMISTUDIO_S5B_DATA
    .endif

    jmp _famistudio_music_stop

;======================================================================================================================
; FAMISTUDIO_MUSIC_STOP (public)
;
; Stops any music currently playing, if any. Note that this will not update the APU, so sound might linger. Calling
; famistudio_update after this will update the APU.
; 
; [in] no input params.
;======================================================================================================================

_famistudio_music_stop::

    lda #0
    sta famistudio_song_speed
    sta famistudio_dpcm_effect

    ldx #0

.famistudio_music_stop_set_channels:

    sta famistudio_chn_repeat,x
    sta famistudio_chn_instrument,x
    sta famistudio_chn_note,x
    sta famistudio_chn_ref_len,x
    .if FAMISTUDIO_USE_VOLUME_TRACK
        sta famistudio_chn_volume_track,x
    .endif    
    .if FAMISTUDIO_USE_VIBRATO | FAMISTUDIO_USE_ARPEGGIO
        sta famistudio_chn_env_override,x
    .endif
    .if FAMISTUDIO_CFG_EQUALIZER
        sta famistudio_chn_note_counter,x
    .endif    
    .if FAMISTUDIO_USE_FAMITRACKER_DELAYED_NOTES_OR_CUTS
        lda #0xff
        sta famistudio_chn_note_delay,x
        sta famistudio_chn_cut_delay,x
        lda #0
    .endif
    inx
    cpx #FAMISTUDIO_NUM_CHANNELS
    bne .famistudio_music_stop_set_channels

    .if FAMISTUDIO_USE_DUTYCYCLE_EFFECT
    ldx #0
.set_duty_cycles:
    sta famistudio_duty_cycle,x
    inx
    cpx #FAMISTUDIO_NUM_DUTY_CYCLES
    bne .set_duty_cycles
    .endif

    .if FAMISTUDIO_USE_SLIDE_NOTES
    ldx #0
.set_slides:

    sta famistudio_slide_step, x
    inx
    cpx #FAMISTUDIO_NUM_SLIDES
    bne .set_slides
    .endif

    .if FAMISTUDIO_USE_VOLUME_SLIDES
    ldx #0
.set_volume_slides:
    sta famistudio_chn_volume_slide_step, x
    sta famistudio_chn_volume_slide_target, x
    inx
    cpx #FAMISTUDIO_NUM_VOLUME_SLIDES
    bne .set_volume_slides
    .endif

    ldx #0

.set_envelopes:

    lda #<(famistudio_dummy_envelope)
    sta famistudio_env_addr_lo,x
    lda #>(famistudio_dummy_envelope)
    sta famistudio_env_addr_hi,x
    lda #0
    sta famistudio_env_repeat,x
    sta famistudio_env_value,x
    sta famistudio_env_ptr,x
    inx
    cpx #FAMISTUDIO_NUM_ENVELOPES
    bne .set_envelopes

    ldx #0
.set_pitch_envelopes:

    lda #<(famistudio_dummy_pitch_envelope)
    sta famistudio_pitch_env_addr_lo,x
    lda #>(famistudio_dummy_pitch_envelope)
    sta famistudio_pitch_env_addr_hi,x
    lda #0
    sta famistudio_pitch_env_repeat,x
    sta famistudio_pitch_env_value_lo,x
    sta famistudio_pitch_env_value_hi,x
    .if FAMISTUDIO_USE_PITCH_TRACK
        sta famistudio_pitch_env_fine_value,x
    .endif
    lda #1
    sta famistudio_pitch_env_ptr,x
    inx
    cpx #FAMISTUDIO_NUM_PITCH_ENVELOPES
    bne .set_pitch_envelopes

    jmp famistudio_sample_stop

;======================================================================================================================
; FAMISTUDIO_MUSIC_PLAY (public)
;
; Plays a song from the loaded music data (from a previous call to famistudio_init).
; 
; [in] a : Song index.
;======================================================================================================================

_famistudio_music_play::

.tmp = famistudio_r0
.song_list_ptr = famistudio_ptr0
.temp_env_ptr  = famistudio_ptr1

    ldx famistudio_song_list_lo
    stx *.song_list_ptr+0
    ldx famistudio_song_list_hi
    stx *.song_list_ptr+1

    ldy #0
    cmp [*.song_list_ptr],y
    bcc .valid_song
    rts ; Invalid song index.

.valid_song:
    .ifeq FAMISTUDIO_NUM_CHANNELS - 5
    ; Here we basically assume we have 17 songs or less (17 songs * 14 bytes per song + 5 bytes header < 256).
    asl a
    sta *.tmp
    asl a
    tax
    asl a
    adc *.tmp
    stx *.tmp
    adc *.tmp
    adc #5 ; Song count + instrument ptr + sample ptr
    tay
    .else
    ; This supports a larger number of songs as it increments the pointer itself, not Y.
    ; As the number of channel becomes huge, this become necessary to support a decent
    ; number of songs.
    tax
    lda *.song_list_ptr+0
    .song_mult_loop:
        dex
        bmi .song_mult_loop_done
        adc #(FAMISTUDIO_NUM_CHANNELS * 2 + 4)
        bcc .song_mult_loop
        inc *.song_list_ptr+1
        bcs .song_mult_loop

    .song_mult_loop_done:
        sta *.song_list_ptr+0

    .if FAMISTUDIO_EXP_FDS | FAMISTUDIO_EXP_VRC7 | FAMISTUDIO_EXP_EPSM | FAMISTUDIO_EXP_N163 | FAMISTUDIO_EXP_S5B
        ldy #7 ; Song count + instrument ptr + exp instrument ptr + sample ptr
    .else
        ldy #5 ; Song count + instrument ptr + sample ptr
    .endif
    .endif

    jsr _famistudio_music_stop

    ldx #0

.famistudio_music_play_set_channels:

    ; Channel data address
    lda [*.song_list_ptr],y
    sta famistudio_chn_ptr_lo,x
    iny
    lda [*.song_list_ptr],y
    sta famistudio_chn_ptr_hi,x
    iny

    lda #0
    sta famistudio_chn_repeat,x
    sta famistudio_chn_instrument,x
    sta famistudio_chn_note,x
    sta famistudio_chn_ref_len,x
    .if FAMISTUDIO_USE_VOLUME_TRACK
        lda #0xf0
        sta famistudio_chn_volume_track,x
    .endif
    .if FAMISTUDIO_USE_FAMITRACKER_DELAYED_NOTES_OR_CUTS
        lda #0xff
        sta famistudio_chn_note_delay,x
        sta famistudio_chn_cut_delay,x
    .endif    

.nextchannel:
    inx
    cpx #FAMISTUDIO_NUM_CHANNELS
    bne .famistudio_music_play_set_channels

    .if FAMISTUDIO_USE_FAMITRACKER_TEMPO
    lda famistudio_pal_adjust
    beq .pal
    iny
    iny
.pal:

    ; Tempo increment.
    lda [*.song_list_ptr],y
    sta famistudio_tempo_step_lo
    iny
    lda [*.song_list_ptr],y
    sta famistudio_tempo_step_hi

    lda #0 ; Reset tempo accumulator
    sta famistudio_tempo_acc_lo
    lda #6 ; Default speed
    sta famistudio_tempo_acc_hi
    sta famistudio_song_speed ; Apply default speed, this also enables music
    .else
    lda [*.song_list_ptr],y
    sta famistudio_tempo_env_ptr_lo
    sta *.temp_env_ptr+0
    iny
    lda [*.song_list_ptr],y
    sta famistudio_tempo_env_ptr_hi
    sta *.temp_env_ptr+1
    iny
    lda [*.song_list_ptr],y
    .if FAMISTUDIO_DUAL_SUPPORT ; Dual mode
    ldx famistudio_pal_adjust
    bne .ntsc_target
    ora #1
    .ntsc_target:
    .else
    .if FAMISTUDIO_CFG_PAL_SUPPORT ; PAL only
    ora #1
    .endif
    .endif
    tax
    lda famistudio_tempo_frame_lookup, x ; Lookup contains the number of frames to run (0,1,2) to maintain tempo
    sta famistudio_tempo_frame_num
    ldy #0
    sty famistudio_tempo_env_idx
    lda [*.temp_env_ptr],y
    clc 
    adc #1
    sta famistudio_tempo_env_counter
    lda #6
    sta famistudio_song_speed ; Non-zero simply so the song isnt considered paused.
    .endif

    .if FAMISTUDIO_EXP_VRC7
    lda #0
    ldx #5
    .clear_vrc7_loop:
        sta famistudio_chn_vrc7_prev_hi, x
        sta famistudio_chn_vrc7_patch, x
        sta famistudio_chn_vrc7_trigger,x
        dex
        bpl .clear_vrc7_loop 
    .endif

    .if FAMISTUDIO_EXP_EPSM
    lda #0
    ldx #5
    .clear_epsm_loop:
        sta famistudio_chn_epsm_trigger,x
        dex
        bpl .clear_epsm_loop 
    .endif

    .if FAMISTUDIO_EXP_VRC6
    lda #0
    sta famistudio_vrc6_saw_volume
    .endif

    .if FAMISTUDIO_USE_PHASE_RESET
    lda #0
    sta famistudio_phase_reset
    .if FAMISTUDIO_EXP_N163
        sta famistudio_phase_reset_n163
    .endif
    .endif

    .if FAMISTUDIO_USE_DELTA_COUNTER
    lda #0xff
    sta famistudio_dmc_delta_counter
    .endif

    .if FAMISTUDIO_EXP_FDS
    lda #0
    sta famistudio_fds_mod_speed+0
    sta famistudio_fds_mod_speed+1
    sta famistudio_fds_mod_depth
    sta famistudio_fds_mod_delay
    sta famistudio_fds_override_flags
    .endif

    .if FAMISTUDIO_EXP_N163 | FAMISTUDIO_EXP_VRC7 | FAMISTUDIO_EXP_FDS | FAMISTUDIO_EXP_EPSM
    lda #0
    ldx #(FAMISTUDIO_NUM_CHANNELS - FAMISTUDIO_FIRST_EXP_INST_CHANNEL - 1)
    .clear_inst_changed_loop:
        sta famistudio_chn_inst_changed, x
        dex
        bpl .clear_inst_changed_loop 
    .endif

    .if FAMISTUDIO_EXP_N163
    lda #0
    ldx #(FAMISTUDIO_EXP_N163_CHN_CNT - 1)
    .clear_n163_loop:
        sta famistudio_chn_n163_wave_index, x
        sta famistudio_chn_n163_wave_len, x
        dex
        bpl .clear_n163_loop 
    .endif

.skip:
    rts

;======================================================================================================================
; FAMISTUDIO_MUSIC_PAUSE (public)
;
; Pause/unpause the currently playing song. Note that this will not update the APU, so sound might linger. Calling
; famistudio_update after this will update the APU.
; 
; [in] a : zero to play, non-zero to pause.
;======================================================================================================================

_famistudio_music_pause::

    tax
    beq .unpause
    
.famistudio_music_pause_pause:

    jsr famistudio_sample_stop
    
    lda #0
    sta famistudio_env_value+FAMISTUDIO_CH0_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
    sta famistudio_env_value+FAMISTUDIO_CH1_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
    sta famistudio_env_value+FAMISTUDIO_CH2_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
    sta famistudio_env_value+FAMISTUDIO_CH3_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
    .if FAMISTUDIO_EXP_VRC6
    sta famistudio_env_value+FAMISTUDIO_VRC6_CH0_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
    sta famistudio_env_value+FAMISTUDIO_VRC6_CH1_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
    sta famistudio_env_value+FAMISTUDIO_VRC6_CH2_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
    .endif
    .if FAMISTUDIO_EXP_VRC7
    sta famistudio_env_value+FAMISTUDIO_VRC7_CH0_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
    sta famistudio_env_value+FAMISTUDIO_VRC7_CH1_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
    sta famistudio_env_value+FAMISTUDIO_VRC7_CH2_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
    sta famistudio_env_value+FAMISTUDIO_VRC7_CH3_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
    sta famistudio_env_value+FAMISTUDIO_VRC7_CH4_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
    sta famistudio_env_value+FAMISTUDIO_VRC7_CH5_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
    .endif
    .if FAMISTUDIO_EXP_FDS
    sta famistudio_env_value+FAMISTUDIO_FDS_CH0_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
    .endif
    .if FAMISTUDIO_EXP_MMC5
    sta famistudio_env_value+FAMISTUDIO_MMC5_CH0_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
    sta famistudio_env_value+FAMISTUDIO_MMC5_CH1_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
    .endif
    .if FAMISTUDIO_EXP_N163
    sta famistudio_env_value+FAMISTUDIO_N163_CH0_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
    sta famistudio_env_value+FAMISTUDIO_N163_CH1_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
    sta famistudio_env_value+FAMISTUDIO_N163_CH2_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
    sta famistudio_env_value+FAMISTUDIO_N163_CH3_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
    sta famistudio_env_value+FAMISTUDIO_N163_CH4_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
    sta famistudio_env_value+FAMISTUDIO_N163_CH5_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
    sta famistudio_env_value+FAMISTUDIO_N163_CH6_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
    sta famistudio_env_value+FAMISTUDIO_N163_CH7_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
    .endif
    .if FAMISTUDIO_EXP_S5B
    sta famistudio_env_value+FAMISTUDIO_S5B_CH0_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
    sta famistudio_env_value+FAMISTUDIO_S5B_CH1_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
    sta famistudio_env_value+FAMISTUDIO_S5B_CH2_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
    .endif
    .if FAMISTUDIO_EXP_EPSM
    sta famistudio_env_value+FAMISTUDIO_EPSM_CH0_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
    sta famistudio_env_value+FAMISTUDIO_EPSM_CH1_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
    sta famistudio_env_value+FAMISTUDIO_EPSM_CH2_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
    sta famistudio_env_value+FAMISTUDIO_EPSM_CH3_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
    sta famistudio_env_value+FAMISTUDIO_EPSM_CH4_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
    sta famistudio_env_value+FAMISTUDIO_EPSM_CH5_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
    sta famistudio_env_value+FAMISTUDIO_EPSM_CH6_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
    sta famistudio_env_value+FAMISTUDIO_EPSM_CH7_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
    sta famistudio_env_value+FAMISTUDIO_EPSM_CH8_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
    sta famistudio_env_value+FAMISTUDIO_EPSM_CH9_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
    sta famistudio_env_value+FAMISTUDIO_EPSM_CH10_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
    sta famistudio_env_value+FAMISTUDIO_EPSM_CH11_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
    sta famistudio_env_value+FAMISTUDIO_EPSM_CH12_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
    sta famistudio_env_value+FAMISTUDIO_EPSM_CH13_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
    sta famistudio_env_value+FAMISTUDIO_EPSM_CH14_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
    .endif
    lda famistudio_song_speed ; <= 0 pauses the music
    ora #0x80
    bne .famistudio_music_pause_done
.unpause:
    lda famistudio_song_speed ; > 0 unpause music
    and #0x7f
.famistudio_music_pause_done:
    sta famistudio_song_speed

    rts

;======================================================================================================================
; FAMISTUDIO_GET_NOTE_PITCH_MACRO (internal)
;
; Uber-macro used to compute the final pitch of a note, taking into account the current note, arpeggios, instrument
; pitch envelopes, slide notes and fine pitch tracks.
; 
; [in] x : note index.
; [in] y : slide/pitch envelope index.
; [out] famistudio_ptr1 : Final note pitch.
;======================================================================================================================

;famistudio_get_note_pitch_macro .macro ; pitch_env_offset, pitch_shift, note_table_lsb, note_table_msb
.macro famistudio_get_note_pitch_macro pitch_env_offset, pitch_shift, note_table_lsb, note_table_msb, ?.pos, ?.no_slide


.pitch   = famistudio_ptr1
.tmp_ror = famistudio_r0

    .if FAMISTUDIO_USE_PITCH_TRACK

    ; Pitch envelope + fine pitch (sign extended)
    clc
    lda famistudio_pitch_env_fine_value+pitch_env_offset, y 
    adc famistudio_pitch_env_value_lo+pitch_env_offset, y 
    sta *.pitch+0
    lda famistudio_pitch_env_fine_value+pitch_env_offset, y 
    and #0x80
    beq .pos
    lda #0xff
.pos:
    adc famistudio_pitch_env_value_hi+pitch_env_offset, y 
    sta *.pitch+1

    .else

    ; Pitch envelope only
    lda famistudio_pitch_env_value_lo+pitch_env_offset, y 
    sta *.pitch+0
    lda famistudio_pitch_env_value_hi+pitch_env_offset, y 
    sta *.pitch+1

    .endif

    .if FAMISTUDIO_USE_SLIDE_NOTES
    ; Check if there is an active slide.
    lda famistudio_slide_step+pitch_env_offset, y 
    beq .no_slide

    ; Add slide
    .ifge (pitch_shift - 1) ;.if pitch_shift >= 1
    ; These channels dont have fractional part for slides and have the same shift for slides + pitch.
    clc
    lda famistudio_slide_pitch_lo+pitch_env_offset, y 
    adc *.pitch+0
    sta *.pitch+0
    lda famistudio_slide_pitch_hi+pitch_env_offset, y 
    adc *.pitch+1
    sta *.pitch+1     
    .else
    ; Most channels have 1 bit of fraction for slides.
    lda famistudio_slide_pitch_hi+pitch_env_offset, y 
    cmp #0x80 ; Sign extend upcoming right shift.
    ror a ; We have 1 bit of fraction for slides, shift right hi byte.
    sta *.tmp_ror
    lda famistudio_slide_pitch_lo+pitch_env_offset, y 
    ror a ; Shift right low byte.
    clc
    adc *.pitch+0
    sta *.pitch+0
    lda *.tmp_ror
    adc *.pitch+1 
    sta *.pitch+1 
    .endif
    .endif

.no_slide:

    .ifge (pitch_shift - 1) ;.if pitch_shift >= 1
        asl *.pitch+0
        rol *.pitch+1
    .ifge (pitch_shift - 2) ;.if pitch_shift >= 2
        asl *.pitch+0
        rol *.pitch+1
    .ifge (pitch_shift - 3) ;.if pitch_shift >= 3
        asl *.pitch+0
        rol *.pitch+1
    .ifge (pitch_shift - 4) ;.if pitch_shift >= 4
        asl *.pitch+0
        rol *.pitch+1
    .ifge (pitch_shift - 5) ;.if pitch_shift >= 5
        asl *.pitch+0
        rol *.pitch+1
    .endif 
    .endif
    .endif
    .endif
    .endif

    ; Finally, add note pitch.
    clc
    lda note_table_lsb,x
    adc *.pitch+0
    sta *.pitch+0
    lda note_table_msb,x
    adc *.pitch+1
    sta *.pitch+1

.endm

famistudio_get_note_pitch:
    famistudio_get_note_pitch_macro 0, 0, famistudio_note_table_lsb, famistudio_note_table_msb
    rts

    .if FAMISTUDIO_EXP_VRC6
famistudio_get_note_pitch_vrc6_saw:
    famistudio_get_note_pitch_macro 0, 0, famistudio_saw_note_table_lsb, famistudio_saw_note_table_msb
    rts
    .endif

;======================================================================================================================
; FAMISTUDIO_SMOOTH_VIBRATO (internal)
;
; Implementation of Blaarg's smooth vibrato to eliminate pops on square channels. Called either from regular channel
; updates or from SFX code.
;
; [in] a : new hi period.
;======================================================================================================================

.macro famistudio_smooth_vibrato pulse_lo, pulse_prev, reg_hi, reg_lo, reg_sweep, pulse_lo_is_zp, ?.hi_delta_too_big, ?.done
    ; Blaarg's smooth vibrato technique, only used if high period delta is 1 or -1.
    and #7 ; Clamp hi-period to sane range, breaks smooth vibrato otherwise.
    tax ; X = new hi-period
    sec
    sbc pulse_prev ; A = signed hi-period delta.
    beq .done
    stx pulse_prev
    tay 
    iny ; We only care about -1 (0xff) and 1. Adding one means we only check of 0 or 2, we already checked for zero (so < 3).
    cpy #0x03
    bcs .hi_delta_too_big
    ldx #0x40
    stx FAMISTUDIO_APU_FRAME_CNT ; Reset frame counter in case it was about to clock
    lda famistudio_smooth_vibrato_period_lo_lookup, y ; Be sure low 8 bits of timer period are 0xff (for positive delta), or 0x00 (for negative delta)
    sta reg_lo
    lda famistudio_smooth_vibrato_sweep_lookup, y ; Sweep enabled, shift = 7, set negative flag or delta is negative..
    sta reg_sweep
    lda #0xc0
    sta FAMISTUDIO_APU_FRAME_CNT ; Clock sweep immediately
    lda #0x08
    sta reg_sweep ; Disable sweep
    ; HACK : In SDAS, macro parameters cant sometimes be ZP and sometimes not...
    .if pulse_lo_is_zp
        lda *pulse_lo
    .else
        lda pulse_lo
    .endif
    sta reg_lo ; Restore lo-period.
    jmp .done
.hi_delta_too_big:
    stx reg_hi
.done:
.endm

;======================================================================================================================
; FAMISTUDIO_UPDATE_CHANNEL_SOUND (internal)
;
; Uber-macro used to update the APU registers for a given 2A03/VRC6/MMC5 channel. This macro is an absolute mess, but
; it is still more maintainable than having many different functions.
;
; [in] no input params.
;======================================================================================================================

;famistudio_update_channel_sound .macro ; idx, env_offset, pulse_prev, reg_hi, reg_lo, reg_vol, reg_sweep, phase_reset_mask
.macro famistudio_update_channel_sound idx, env_offset, pulse_prev, reg_hi, reg_lo, reg_vol, reg_sweep, phase_reset_mask, ?.nocut, ?.set_volume, ?.phase_reset_done, ?.compute_volume, ?.no_noise_slide

.define .tmp "famistudio_r0"
.define .pitch "famistudio_ptr1"
;
    lda famistudio_chn_note+idx
    bne .nocut
;    .if (idx\@ >= FAMISTUDIO_VRC6_CH0_IDX) & (idx\@ <= FAMISTUDIO_VRC6_CH2_IDX) & (FAMISTUDIO_USE_PHASE_RESET != 0) & (phase_reset_mask\@ != 0)
;    lda #0
;    sta <.pitch\@+1
;    .endif
    jmp .set_volume
;
.nocut:
    clc
    adc famistudio_env_value+env_offset+FAMISTUDIO_ENV_NOTE_OFF

    .ifeq (idx - 3) ; Noise channel is a bit special    

    .if FAMISTUDIO_USE_NOISE_SLIDE_NOTES

    ; Check if there is an active slide on the noise channel.
    ldy famistudio_slide_step+FAMISTUDIO_NOISE_SLIDE_INDEX
    beq .no_noise_slide

        ; We have 4 bits of fraction for noise slides.
        sta *.tmp
        lda famistudio_slide_pitch_lo+FAMISTUDIO_NOISE_SLIDE_INDEX
        sta *.pitch+0
        lda famistudio_slide_pitch_hi+FAMISTUDIO_NOISE_SLIDE_INDEX
        cmp #0x80
        ror a
        ror *.pitch+0
        cmp #0x80
        ror a
        ror *.pitch+0
        cmp #0x80
        ror a
        ror *.pitch+0
        cmp #0x80
        ror a
        lda *.pitch+0
        ror a

        clc 
        adc *.tmp

    .endif

.no_noise_slide:
    and #0x0f
    eor #0x0f
    sta *.tmp
    ldx famistudio_env_value+env_offset+FAMISTUDIO_ENV_DUTY_OFF
    lda famistudio_duty_lookup, x
    asl a
    and #0x80
    ora *.tmp

    .else

    .if FAMISTUDIO_DUAL_SUPPORT
        clc
        adc famistudio_pal_adjust
    .endif
    tax

    ; This basically does same as "famistudio_channel_to_pitch_env"
    .iflt (idx - 3) ; idx < 3
        ldy #idx
    .else
        ldy #(idx - 2)
    .endif

    .if FAMISTUDIO_EXP_VRC6
        .ifeq (idx - FAMISTUDIO_VRC6_CH2_IDX)
            jsr famistudio_get_note_pitch_vrc6_saw
        .else
	    jsr famistudio_get_note_pitch
	.endif
    .else
        jsr famistudio_get_note_pitch
    .endif

    lda *.pitch+0
    sta reg_lo
    lda *.pitch+1

    .ifnb pulse_prev
        .ifeq FAMISTUDIO_CFG_SFX_SUPPORT
            .ifnb reg_sweep
                .if FAMISTUDIO_CFG_SMOOTH_VIBRATO
                    famistudio_smooth_vibrato .pitch, pulse_prev, reg_hi, reg_lo, reg_sweep, 1
                .endif
            .else
                cmp pulse_prev
                beq .compute_volume
                sta pulse_prev
            .endif
        .else
            .ifb reg_sweep
                cmp pulse_prev
                beq .compute_volume
                sta pulse_prev
            .endif
        .endif
    .endif

;    ; HACK : VRC6 only. We are out of macro param for NESASM.
;    .if (idx\@ >= FAMISTUDIO_VRC6_CH0_IDX) & (idx\@ <= FAMISTUDIO_VRC6_CH2_IDX)
;        ora #0x80
;    .endif
;
    .endif ; idx = 3
;
;    .if (pulse_prev\@ = 0) | (reg_sweep\@ = 0) | (FAMISTUDIO_CFG_SFX_SUPPORT != 0) | (FAMISTUDIO_CFG_SMOOTH_VIBRATO = 0)
    .ifb pulse_prev
        sta reg_hi
    .else
        .ifb reg_sweep
            sta reg_hi
        .else
            .if FAMISTUDIO_CFG_SFX_SUPPORT
                sta reg_hi
            .else
                 .ifeq FAMISTUDIO_CFG_SMOOTH_VIBRATO
                     sta reg_hi
                 .endif
            .endif
        .endif
    .endif

.compute_volume:

    .if FAMISTUDIO_USE_VOLUME_TRACK    
        lda famistudio_chn_volume_track+idx
        .if FAMISTUDIO_USE_VOLUME_SLIDES
            ; During a slide, the lower 4 bits are fraction.
            and #0xf0
        .endif
        ora famistudio_env_value+env_offset+FAMISTUDIO_ENV_VOLUME_OFF
        tax
        lda famistudio_volume_table, x 
    .else
        lda famistudio_env_value+env_offset+FAMISTUDIO_ENV_VOLUME_OFF
    .endif

;    .if (FAMISTUDIO_EXP_VRC6 != 0) & (idx\@ = FAMISTUDIO_VRC6_CH2_IDX)
;    ; VRC6 saw has 6-bits
;    ldx famistudio_vrc6_saw_volume
;    bmi .set_volume\@ 
;    asl a
;    ldx famistudio_vrc6_saw_volume
;    beq .set_volume\@
;    asl a
;    .endif

.set_volume:
;
;    .if (idx\@ = 0) | (idx\@ = 1) | (idx\@ = 3) | ((FAMISTUDIO_EXP_MMC5 != 0) & ((idx\@ = FAMISTUDIO_MMC5_CH0_IDX) | (idx\@ = FAMISTUDIO_MMC5_CH1_IDX)))
    .ifne idx - 2
    ldx famistudio_env_value+env_offset+FAMISTUDIO_ENV_DUTY_OFF
    ora famistudio_duty_lookup, x
;    .else
;    .if ((FAMISTUDIO_EXP_VRC6 != 0) & ((idx\@ = FAMISTUDIO_VRC6_CH0_IDX) | (idx\@ = FAMISTUDIO_VRC6_CH1_IDX)))
;    ldx famistudio_env_value+env_offset\@+FAMISTUDIO_ENV_DUTY_OFF
;    ora famistudio_vrc6_duty_lookup, x
;    .endif
    .endif
;
;    ; HACK : We are out of macro param for NESASM.
    .ifeq (idx - 2)
    ora #0x80
    .else
        .ifeq (idx - 3)
            ora #0xf0
        .endif
    .endif

    sta reg_vol

    .if FAMISTUDIO_USE_PHASE_RESET & phase_reset_mask
    lda famistudio_phase_reset
    and phase_reset_mask
    beq .phase_reset_done
;    .if idx\@ < 2 | ((FAMISTUDIO_EXP_MMC5 != 0) & (idx\@ >= FAMISTUDIO_MMC5_CH0_IDX) & (idx\@ <= FAMISTUDIO_MMC5_CH1_IDX))
    .iflt idx - 2 ; TODO: Rest of conditions
        lda pulse_prev
        sta reg_hi
    .else
;    .if (FAMISTUDIO_EXP_VRC6 != 0) & (idx >= FAMISTUDIO_VRC6_CH0_IDX) & (idx <= FAMISTUDIO_VRC6_CH2_IDX)
;        lda *.pitch+1
;        sta reg_hi
;        ora #0x80
;        sta reg_hi
;    .endif
    .endif    
    .phase_reset_done:
   .endif

.endm

    .if FAMISTUDIO_EXP_FDS

;======================================================================================================================
; FAMISTUDIO_UPDATE_FDS_CHANNEL_SOUND (internal)
;
; Updates the FDS audio registers.
;
; [in] no input params.
;======================================================================================================================

famistudio_update_fds_channel_sound:

.pitch = famistudio_ptr1

    lda famistudio_chn_note+FAMISTUDIO_FDS_CH0_IDX
    bne .nocut
   .if FAMISTUDIO_USE_PHASE_RESET
    lda #0
    sta *.pitch+1
    .endif    
    jmp .set_volume

.nocut:
    clc
    adc famistudio_env_value+FAMISTUDIO_FDS_CH0_ENVS+FAMISTUDIO_ENV_NOTE_OFF
    tax

    ldy #0
    famistudio_get_note_pitch_macro FAMISTUDIO_FDS_CH0_PITCH_ENV_IDX, 0, famistudio_fds_note_table_lsb, famistudio_fds_note_table_msb

    lda *.pitch+0
    sta FAMISTUDIO_FDS_FREQ_LO
    lda *.pitch+1
    sta FAMISTUDIO_FDS_FREQ_HI

.check_mod_delay:
    lda famistudio_fds_mod_delay
    beq .zero_delay
    dec famistudio_fds_mod_delay
    lda #0x80
    sta FAMISTUDIO_FDS_MOD_HI
    bne .compute_volume

.zero_delay:
    lda famistudio_fds_mod_speed+1
    sta FAMISTUDIO_FDS_MOD_HI
    lda famistudio_fds_mod_speed+0
    sta FAMISTUDIO_FDS_MOD_LO
    lda famistudio_fds_mod_depth
    ora #0x80
    sta FAMISTUDIO_FDS_SWEEP_ENV

.compute_volume:
    .if FAMISTUDIO_USE_VOLUME_TRACK
        lda famistudio_chn_volume_track+FAMISTUDIO_FDS_CH0_IDX 
        .if FAMISTUDIO_USE_VOLUME_SLIDES
            ; During a slide, the lower 4 bits are fraction.
            and #0xf0
        .endif        
        ora famistudio_env_value+FAMISTUDIO_FDS_CH0_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
        tax
        lda famistudio_volume_table, x 
    .else
        lda famistudio_env_value+FAMISTUDIO_FDS_CH0_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
    .endif
    asl a ; FDS volume is 6-bits, but clamped to 32. Just double it.

.set_volume:
    ora #0x80
    sta FAMISTUDIO_FDS_VOL_ENV
    lda #0
    sta famistudio_fds_override_flags

    .if FAMISTUDIO_USE_PHASE_RESET
.reset_phase:
    lda famistudio_phase_reset ; Bit 7 is for FDS.
    bpl .done
    lda *.pitch+1
    ora #0x80
    sta FAMISTUDIO_FDS_FREQ_HI
    and #0x0f
    sta FAMISTUDIO_FDS_FREQ_HI
    .endif
.done:

    rts 

    .endif

    .if FAMISTUDIO_EXP_VRC7

famistudio_vrc7_reg_table_lo:
    .byte FAMISTUDIO_VRC7_REG_LO_1, FAMISTUDIO_VRC7_REG_LO_2, FAMISTUDIO_VRC7_REG_LO_3, FAMISTUDIO_VRC7_REG_LO_4, FAMISTUDIO_VRC7_REG_LO_5, FAMISTUDIO_VRC7_REG_LO_6
famistudio_vrc7_reg_table_hi:
    .byte FAMISTUDIO_VRC7_REG_HI_1, FAMISTUDIO_VRC7_REG_HI_2, FAMISTUDIO_VRC7_REG_HI_3, FAMISTUDIO_VRC7_REG_HI_4, FAMISTUDIO_VRC7_REG_HI_5, FAMISTUDIO_VRC7_REG_HI_6
famistudio_vrc7_vol_table:
    .byte FAMISTUDIO_VRC7_REG_VOL_1, FAMISTUDIO_VRC7_REG_VOL_2, FAMISTUDIO_VRC7_REG_VOL_3, FAMISTUDIO_VRC7_REG_VOL_4, FAMISTUDIO_VRC7_REG_VOL_5, FAMISTUDIO_VRC7_REG_VOL_6
famistudio_vrc7_env_table:
    .byte FAMISTUDIO_VRC7_CH0_ENVS, FAMISTUDIO_VRC7_CH1_ENVS, FAMISTUDIO_VRC7_CH2_ENVS, FAMISTUDIO_VRC7_CH3_ENVS, FAMISTUDIO_VRC7_CH4_ENVS, FAMISTUDIO_VRC7_CH5_ENVS 
famistudio_vrc7_invert_vol_table:
    .byte 0x0f, 0x0e, 0x0d, 0x0c, 0x0b, 0x0a, 0x09, 0x08, 0x07, 0x06, 0x05, 0x04, 0x03, 0x02, 0x01, 0x00

; From nesdev wiki.
famistudio_vrc7_wait_reg_write:
    stx famistudio_vrc7_dummy
    ldx #0x08
    .wait_loop:
        dex
        bne .wait_loop
        ldx famistudio_vrc7_dummy
    rts

; From nesdev wiki.
famistudio_vrc7_wait_reg_select:
    rts

;======================================================================================================================
; FAMISTUDIO_UPDATE_VRC7_CHANNEL_SOUND (internal)
;
; Updates the VRC7 audio registers for a given channel.
;
; [in] y: VRC7 channel idx (0,1,2,3,4,5)
;======================================================================================================================

famistudio_update_vrc7_channel_sound:

.tmp   = famistudio_r0
.pitch = famistudio_ptr1

    lda #0
    sta famistudio_chn_inst_changed-FAMISTUDIO_FIRST_EXP_INST_CHANNEL+FAMISTUDIO_VRC7_CH0_IDX,y

.check_cut:
    lda famistudio_chn_note+FAMISTUDIO_VRC7_CH0_IDX,y
    bne .check_release

.cut:  
    ; Untrigger note.  
    lda famistudio_vrc7_reg_table_hi,y
    sta FAMISTUDIO_VRC7_REG_SEL
    jsr famistudio_vrc7_wait_reg_select

    lda famistudio_chn_vrc7_prev_hi, y
    and #0xcf ; Remove trigger + sustain
    sta famistudio_chn_vrc7_prev_hi, y
    sta FAMISTUDIO_VRC7_REG_WRITE
    jsr famistudio_vrc7_wait_reg_write

    rts

.check_release:

    lda famistudio_chn_vrc7_trigger,y
    bpl .check_attack

    .release:
       
        lda famistudio_chn_vrc7_prev_hi, y
        and #0xef ; remove trigger
        sta famistudio_chn_vrc7_prev_hi, y
        jmp .musical_note

.check_attack:

    lda famistudio_chn_vrc7_trigger,y
    and #1
    beq .musical_note

    .attack:

        lda famistudio_chn_vrc7_prev_hi, y
        and #0x10
        beq .prev_note_had_release

        ; Two attacks in a row, need to insert a dummy release.
        .prev_note_had_attack:

            lda famistudio_vrc7_reg_table_hi,y
            sta FAMISTUDIO_VRC7_REG_SEL
            jsr famistudio_vrc7_wait_reg_select
            lda #0
            sta FAMISTUDIO_VRC7_REG_WRITE
            jsr famistudio_vrc7_wait_reg_write
            jmp .musical_note

        .prev_note_had_release:
            lda famistudio_chn_vrc7_prev_hi, y
            ora #0x10
            sta famistudio_chn_vrc7_prev_hi, y

.musical_note:

    ; Read/multiply volume
    ldx famistudio_vrc7_env_table,y
    .if FAMISTUDIO_USE_VOLUME_TRACK
        lda famistudio_chn_volume_track+FAMISTUDIO_VRC7_CH0_IDX, y
        .if FAMISTUDIO_USE_VOLUME_SLIDES
            ; During a slide, the lower 4 bits are fraction.
            and #0xf0
        .endif
        ora famistudio_env_value+FAMISTUDIO_ENV_VOLUME_OFF,x
    .else
        lda famistudio_env_value+FAMISTUDIO_ENV_VOLUME_OFF,x
    .endif
    tax

    ; Write volume
    lda famistudio_vrc7_vol_table,y
    sta FAMISTUDIO_VRC7_REG_SEL
    jsr famistudio_vrc7_wait_reg_select
    .if FAMISTUDIO_USE_VOLUME_TRACK
        lda famistudio_volume_table,x
        tax
    .endif
    lda famistudio_vrc7_invert_vol_table,x
    ora famistudio_chn_vrc7_patch,y
    sta FAMISTUDIO_VRC7_REG_WRITE
    jsr famistudio_vrc7_wait_reg_write

    ; Read note, apply arpeggio 
    ldx famistudio_vrc7_env_table,y    
    lda famistudio_chn_note+FAMISTUDIO_VRC7_CH0_IDX,y
    clc
    adc famistudio_env_value+FAMISTUDIO_ENV_NOTE_OFF,x
    tax

    ; Apply pitch envelope, fine pitch & slides
    famistudio_get_note_pitch_macro FAMISTUDIO_VRC7_CH0_PITCH_ENV_IDX, FAMISTUDIO_VRC7_PITCH_SHIFT, famistudio_vrc7_note_table_lsb, famistudio_vrc7_note_table_msb

    ; Compute octave by dividing by 2 until we are <= 512 (0x100).
    ldx #0
    .compute_octave_loop:
        lda *.pitch+1
        cmp #2
        bcc .octave_done
        lsr a
        sta *.pitch+1
        ror *.pitch+0
        inx
        jmp .compute_octave_loop

    .octave_done:

    ; Write pitch (lo)
    lda famistudio_vrc7_reg_table_lo,y
    sta FAMISTUDIO_VRC7_REG_SEL
    jsr famistudio_vrc7_wait_reg_select

    lda *.pitch+0
    sta FAMISTUDIO_VRC7_REG_WRITE
    jsr famistudio_vrc7_wait_reg_write

    ; Write pitch (hi)
    lda famistudio_chn_vrc7_prev_hi, y
    and #0x10
    sta *.tmp

    lda famistudio_vrc7_reg_table_hi,y
    sta FAMISTUDIO_VRC7_REG_SEL
    jsr famistudio_vrc7_wait_reg_select

    txa
    asl a
    ora #0x20
    ora *.pitch+1
    ora *.tmp
    sta famistudio_chn_vrc7_prev_hi, y
    sta FAMISTUDIO_VRC7_REG_WRITE
    jsr famistudio_vrc7_wait_reg_write

    lda #0
    sta famistudio_chn_vrc7_trigger,y

    rts

    .endif

    .if FAMISTUDIO_EXP_EPSM
famistudio_epsm_vol_table_op1:
    .byte FAMISTUDIO_EPSM_REG_TL, FAMISTUDIO_EPSM_REG_TL+1, FAMISTUDIO_EPSM_REG_TL+2,FAMISTUDIO_EPSM_REG_TL, FAMISTUDIO_EPSM_REG_TL+1, FAMISTUDIO_EPSM_REG_TL+2
famistudio_epsm_vol_table_op2:
    .byte FAMISTUDIO_EPSM_REG_TL+8, FAMISTUDIO_EPSM_REG_TL+1+8, FAMISTUDIO_EPSM_REG_TL+2+8,FAMISTUDIO_EPSM_REG_TL+8, FAMISTUDIO_EPSM_REG_TL+1+8, FAMISTUDIO_EPSM_REG_TL+2+8
famistudio_epsm_vol_table_op3:
    .byte FAMISTUDIO_EPSM_REG_TL+4, FAMISTUDIO_EPSM_REG_TL+1+4, FAMISTUDIO_EPSM_REG_TL+2+4,FAMISTUDIO_EPSM_REG_TL+4, FAMISTUDIO_EPSM_REG_TL+1+4, FAMISTUDIO_EPSM_REG_TL+2+4
famistudio_epsm_vol_table_op4:
    .byte FAMISTUDIO_EPSM_REG_TL+12, FAMISTUDIO_EPSM_REG_TL+1+12, FAMISTUDIO_EPSM_REG_TL+2+12,FAMISTUDIO_EPSM_REG_TL+12, FAMISTUDIO_EPSM_REG_TL+1+12, FAMISTUDIO_EPSM_REG_TL+2+12
famistudio_epsm_fm_vol_table:
    .byte 0x7e, 0x65, 0x50, 0x3f, 0x32, 0x27, 0x1e, 0x17, 0x12, 0x0d, 0x09, 0x06, 0x04, 0x02, 0x01, 0x00
famistudio_epsm_fm_stereo_reg_table:
    .byte 0xb4,0xb5,0xb6,0xb4,0xb5,0xb6
famistudio_channel_epsm_chan_table:
    .byte 0x00, 0x01, 0x02, 0x00, 0x01, 0x02
famistudio_epsm_rhythm_key_table:
    .byte 0x01,0x02,0x04,0x08,0x10,0x20
famistudio_epsm_rhythm_env_table:
    .byte FAMISTUDIO_EPSM_CH9_ENVS, FAMISTUDIO_EPSM_CH10_ENVS, FAMISTUDIO_EPSM_CH11_ENVS, FAMISTUDIO_EPSM_CH12_ENVS, FAMISTUDIO_EPSM_CH13_ENVS, FAMISTUDIO_EPSM_CH14_ENVS
famistudio_epsm_rhythm_reg_table:
    .byte FAMISTUDIO_EPSM_REG_RHY_BD, FAMISTUDIO_EPSM_REG_RHY_SD, FAMISTUDIO_EPSM_REG_RHY_TC, FAMISTUDIO_EPSM_REG_RHY_HH, FAMISTUDIO_EPSM_REG_RHY_TOM, FAMISTUDIO_EPSM_REG_RHY_RIM
famistudio_epsm_reg_table_lo:
    .byte FAMISTUDIO_EPSM_REG_FN_LO, FAMISTUDIO_EPSM_REG_FN_LO2, FAMISTUDIO_EPSM_REG_FN_LO3, FAMISTUDIO_EPSM_REG_FN_LO, FAMISTUDIO_EPSM_REG_FN_LO2, FAMISTUDIO_EPSM_REG_FN_LO3
famistudio_epsm_reg_table_hi:
    .byte FAMISTUDIO_EPSM_REG_FN_HI, FAMISTUDIO_EPSM_REG_FN_HI2, FAMISTUDIO_EPSM_REG_FN_HI3, FAMISTUDIO_EPSM_REG_FN_HI, FAMISTUDIO_EPSM_REG_FN_HI2, FAMISTUDIO_EPSM_REG_FN_HI3
famistudio_epsm_vol_table:
    .byte FAMISTUDIO_EPSM_REG_VOL_1, FAMISTUDIO_EPSM_REG_VOL_2, FAMISTUDIO_EPSM_REG_VOL_3, FAMISTUDIO_EPSM_REG_VOL_4, FAMISTUDIO_EPSM_REG_VOL_5, FAMISTUDIO_EPSM_REG_VOL_6
famistudio_epsm_fm_env_table:
    .byte FAMISTUDIO_EPSM_CH3_ENVS, FAMISTUDIO_EPSM_CH4_ENVS, FAMISTUDIO_EPSM_CH5_ENVS, FAMISTUDIO_EPSM_CH6_ENVS, FAMISTUDIO_EPSM_CH7_ENVS, FAMISTUDIO_EPSM_CH8_ENVS 
famistudio_epsm_register_order:
    .byte 0xB0, 0xB4, 0x30, 0x40, 0x50, 0x60, 0x70, 0x80, 0x90, 0x38, 0x48, 0x58, 0x68, 0x78, 0x88, 0x98, 0x34, 0x44, 0x54, 0x64, 0x74, 0x84, 0x94, 0x3c, 0x4c, 0x5c, 0x6c, 0x7c, 0x8c, 0x9c, 0x22 ;40,48,44,4c replaced for not sending data there during instrument updates
famistudio_epsm_channel_key_table:
    .byte 0xf0, 0xf1, 0xf2, 0xf4, 0xf5, 0xf6
famistudio_epsm_sqr_reg_table_lo:
    .byte FAMISTUDIO_EPSM_REG_LO_A, FAMISTUDIO_EPSM_REG_LO_B, FAMISTUDIO_EPSM_REG_LO_C
famistudio_epsm_sqr_reg_table_hi:
    .byte FAMISTUDIO_EPSM_REG_HI_A, FAMISTUDIO_EPSM_REG_HI_B, FAMISTUDIO_EPSM_REG_HI_C
famistudio_epsm_square_vol_table:
    .byte FAMISTUDIO_EPSM_REG_VOL_A, FAMISTUDIO_EPSM_REG_VOL_B, FAMISTUDIO_EPSM_REG_VOL_C
famistudio_epsm_square_env_table:
    .byte FAMISTUDIO_EPSM_CH0_ENVS, FAMISTUDIO_EPSM_CH1_ENVS, FAMISTUDIO_EPSM_CH2_ENVS
    
;======================================================================================================================
; FAMISTUDIO_UPDATE_EPSM_SQUARE_CHANNEL_SOUND (internal)
;
; Updates the EPSM audio registers for a given channel.
;
; [in] y: EPSM channel idx (0,1,2)
;======================================================================================================================

famistudio_update_epsm_square_channel_sound:
    
.pitch = famistudio_ptr1

    lda famistudio_chn_note+FAMISTUDIO_EPSM_CH0_IDX,y
    bne .nocut
    ldx #0 ; This will fetch volume 0.
    beq .update_volume_jmp
    jmp .nocut
.update_volume_jmp:
	jmp .update_volume

.nocut:
    
    lda #0x07
    sta FAMISTUDIO_EPSM_ADDR
    lda famistudio_env_value+FAMISTUDIO_EPSM_CH2_ENVS+FAMISTUDIO_ENV_MIXER_IDX_OFF ;load mixer envelope
    asl a
    ora famistudio_env_value+FAMISTUDIO_EPSM_CH1_ENVS+FAMISTUDIO_ENV_MIXER_IDX_OFF ;load mixer envelope
    asl a
    ora famistudio_env_value+FAMISTUDIO_EPSM_CH0_ENVS+FAMISTUDIO_ENV_MIXER_IDX_OFF ;load mixer envelope
    sta FAMISTUDIO_EPSM_DATA



    ldx famistudio_epsm_square_env_table,y
    lda famistudio_env_value+FAMISTUDIO_ENV_NOISE_IDX_OFF,x
    beq .nonoise
    lda #0x06
    sta FAMISTUDIO_EPSM_ADDR
    ldx famistudio_epsm_square_env_table,y
    lda famistudio_env_value+FAMISTUDIO_ENV_NOISE_IDX_OFF,x
    sta FAMISTUDIO_EPSM_DATA
.nonoise:

    lda famistudio_chn_note+FAMISTUDIO_EPSM_CH0_IDX,y
    ; Read note, apply arpeggio 
    clc
    ldx famistudio_epsm_square_env_table,y
    adc famistudio_env_value+FAMISTUDIO_ENV_NOTE_OFF,x
    tax

    ; Apply pitch envelope, fine pitch & slides
    famistudio_get_note_pitch_macro FAMISTUDIO_EPSM_CH0_PITCH_ENV_IDX, 0, famistudio_epsm_s_note_table_lsb, famistudio_epsm_s_note_table_msb

    ; Write pitch
    lda famistudio_epsm_sqr_reg_table_lo,y
    sta FAMISTUDIO_EPSM_ADDR
    lda *.pitch+0
    sta FAMISTUDIO_EPSM_DATA
    lda famistudio_epsm_sqr_reg_table_hi,y
    sta FAMISTUDIO_EPSM_ADDR
    lda *.pitch+1
    sta FAMISTUDIO_EPSM_DATA

    ; Read/multiply volume
    ldx famistudio_epsm_square_env_table,y
    .if FAMISTUDIO_USE_VOLUME_TRACK
        lda famistudio_chn_volume_track+FAMISTUDIO_EPSM_CH0_IDX, y
        .if FAMISTUDIO_USE_VOLUME_SLIDES
            ; During a slide, the lower 4 bits are fraction.
            and #0xf0
        .endif        
        ora famistudio_env_value+FAMISTUDIO_ENV_VOLUME_OFF,x
    .else
        lda famistudio_env_value+FAMISTUDIO_ENV_VOLUME_OFF,x
    .endif
    tax

.update_volume:
    ; Write volume
    lda famistudio_epsm_square_vol_table,y
    sta FAMISTUDIO_EPSM_ADDR
    .if FAMISTUDIO_USE_VOLUME_TRACK    
        lda famistudio_volume_table,x 
        sta FAMISTUDIO_EPSM_DATA
    .else
        stx FAMISTUDIO_EPSM_DATA
    .endif
    rts


;======================================================================================================================
; FAMISTUDIO_UPDATE_EPSM_CHANNEL_SOUND (internal)
;
; Updates the EPSM audio registers for a given channel.
;
; [in] y: EPSM channel idx (0,1,2,3,4,5)
;======================================================================================================================

famistudio_update_epsm_fm_channel_sound:

.pitch      = famistudio_ptr1
.reg_offset = famistudio_r1
.vol_offset = famistudio_r0

    lda #0
    sta famistudio_chn_inst_changed-FAMISTUDIO_FIRST_EXP_INST_CHANNEL+FAMISTUDIO_EPSM_CHAN_FM_START,y

    ; If the writes are done to channels 0-2, use FAMISTUDIO_EPSM_REG_SEL0 if 3-5 use FAMISTUDIO_EPSM_REG_SEL1
    ; This reg_offset stores the difference so we can later load it into x and do sta FAMISTUDIO_EPSM_REG_SEL0, x
    ; to account for the difference
    lda #0
    cpy #3
    bcc .fm_0_2
        lda #2
    .fm_0_2:
    sta *.reg_offset

.check_cut:

    lda famistudio_chn_note+FAMISTUDIO_EPSM_CHAN_FM_START,y
    bne .nocut

.cut:  
    ; Untrigger note.  
    lda #FAMISTUDIO_EPSM_REG_KEY
    sta FAMISTUDIO_EPSM_REG_SEL0
    
    lda famistudio_epsm_channel_key_table, y
    and #0x0f ; remove trigger
    sta FAMISTUDIO_EPSM_REG_WRITE0
    
    ;Mute channel
    ldx *.reg_offset
    lda famistudio_epsm_fm_stereo_reg_table,y
    sta FAMISTUDIO_EPSM_REG_SEL0,x
    lda #0x00
    sta FAMISTUDIO_EPSM_REG_WRITE0,x
    rts

.nocut:

    ldx *.reg_offset
    lda famistudio_epsm_fm_stereo_reg_table,y
    sta FAMISTUDIO_EPSM_REG_SEL0,x
    lda famistudio_chn_epsm_fm_stereo,y
    sta FAMISTUDIO_EPSM_REG_WRITE0,x
    lda famistudio_chn_note+FAMISTUDIO_EPSM_CHAN_FM_START,y
    ; Read note, apply arpeggio
    clc
    ldx famistudio_epsm_fm_env_table,y    
    adc famistudio_env_value+FAMISTUDIO_ENV_NOTE_OFF,x
    tax

    ; Apply pitch envelope, fine pitch & slides
    famistudio_get_note_pitch_macro FAMISTUDIO_EPSM_CH3_PITCH_ENV_IDX, FAMISTUDIO_EPSM_PITCH_SHIFT, famistudio_epsm_note_table_lsb, famistudio_epsm_note_table_msb

    ; Compute octave by dividing by 2 until we are <= 512 (0x100).
    ldx #0

    lda *.pitch+1
    cmp #0x02 ; check if shifted the pitch to a 9 bit number yet.
    bcc .octave_done
    .compute_octave_loop:
        inx
        lsr a
        ror *.pitch+0
        cmp #0x02
        bcc .octave_done
        bcs .compute_octave_loop ;unconditional
    .octave_done:
    sta *.pitch+1

    ; 9 bit pitch * 4 to get the pitch back to an 11 bit number
    ; the final 16 bit pitch will look like 00ooohhh llllllll where o = octave, h = pitch bits 8-11, l = pitch bits 0-8
    lda *.pitch+0
    asl a
    rol <.pitch+1
    asl a
    rol *.pitch+1
    sta *.pitch+0

    txa ; x holds the 3 bit octave information. octave = log2(pitch_hi)
    asl a
    asl a
    asl a
    ora *.pitch+1
    sta *.pitch+1
    
    ; Check if the channel needs to stop the note

    ; Un-trigger previous note if needed.
    lda famistudio_chn_epsm_trigger,y
    beq .write_hi_period
    .untrigger_prev_note:
        ; Untrigger note.  
        lda #FAMISTUDIO_EPSM_REG_KEY
        sta FAMISTUDIO_EPSM_REG_SEL0

        lda famistudio_epsm_channel_key_table, y
        and #0x0f ; remove trigger
        sta FAMISTUDIO_EPSM_REG_WRITE0
        nop
        nop
        nop
        nop
        nop
        nop
;        rts

    .write_hi_period:


    ; Write pitch (hi)
    ldx *.reg_offset
    lda famistudio_epsm_reg_table_hi,y
    sta FAMISTUDIO_EPSM_REG_SEL0,x
    lda *.pitch+1
    sta FAMISTUDIO_EPSM_REG_WRITE0,x

    ; Write pitch (lo)
    lda famistudio_epsm_reg_table_lo,y
    sta FAMISTUDIO_EPSM_REG_SEL0,x
    lda *.pitch+0
    sta FAMISTUDIO_EPSM_REG_WRITE0,x

    ; Read/multiply volume
    ldx famistudio_epsm_fm_env_table,y
    .if FAMISTUDIO_USE_VOLUME_TRACK
        lda famistudio_chn_volume_track+FAMISTUDIO_EPSM_CHAN_FM_START, y
        .if FAMISTUDIO_USE_VOLUME_SLIDES
            ; During a slide, the lower 4 bits are fraction.
            and #0xf0
        .endif
        ora famistudio_env_value+FAMISTUDIO_ENV_VOLUME_OFF,x
    .else
        lda famistudio_env_value+FAMISTUDIO_ENV_VOLUME_OFF,x
    .endif
    
    .if FAMISTUDIO_USE_VOLUME_TRACK
        tax
        lda famistudio_volume_table,x
    .endif    
        sta *.vol_offset

    .update_volume:
    
    lda famistudio_chn_epsm_alg,y
    cmp #7
    bpl .op_1_2_3_4
    cmp #5
    bpl .op_2_3_4
    cmp #4
    bpl .op_2_4
    jmp .op_4
    
    ; todo
    .op_1_2_3_4:
        lda famistudio_epsm_vol_table_op1,y
        ldx *.reg_offset
        sta FAMISTUDIO_EPSM_REG_SEL0,x
        ldx *.vol_offset
        lda famistudio_chn_epsm_vol_op1,y
        clc
        adc famistudio_epsm_fm_vol_table,x
        cmp #127
        bmi .save_op1
        lda #127
    .save_op1:
        ldx *.reg_offset
        sta FAMISTUDIO_EPSM_REG_WRITE0,x
    .op_2_3_4:
        lda famistudio_epsm_vol_table_op3,y
        ldx *.reg_offset
        sta FAMISTUDIO_EPSM_REG_SEL0,x
        ldx *.vol_offset
        lda famistudio_chn_epsm_vol_op3,y
        clc
        adc famistudio_epsm_fm_vol_table,x
        cmp #127
        bmi .save_op3
        lda #127
    .save_op3:
        ldx *.reg_offset
        sta FAMISTUDIO_EPSM_REG_WRITE0,x
    .op_2_4:
        lda famistudio_epsm_vol_table_op2,y
        ldx *.reg_offset
        sta FAMISTUDIO_EPSM_REG_SEL0,x
        ldx *.vol_offset
        lda famistudio_chn_epsm_vol_op2,y
        clc
        adc famistudio_epsm_fm_vol_table,x
        cmp #127
        bmi .save_op2
        lda #127
    .save_op2:
        ldx *.reg_offset
        sta FAMISTUDIO_EPSM_REG_WRITE0,x
    .op_4:
        ; Write volume
        lda famistudio_epsm_vol_table_op4,y
        ldx *.reg_offset
        sta FAMISTUDIO_EPSM_REG_SEL0,x
        ldx *.vol_offset
        lda famistudio_chn_epsm_vol_op4,y
        clc
        adc famistudio_epsm_fm_vol_table,x
        cmp #127
        bmi .save_op4
        lda #127
    .save_op4:
        ldx *.reg_offset
        sta FAMISTUDIO_EPSM_REG_WRITE0,x
        
        nop
        clc
        lda famistudio_chn_epsm_trigger,y
        bpl .no_release

.release:
        ; Untrigger note.  
        lda #FAMISTUDIO_EPSM_REG_KEY
        sta FAMISTUDIO_EPSM_REG_SEL0

        lda famistudio_epsm_channel_key_table, y
        and #0x0f ; remove trigger
        sta FAMISTUDIO_EPSM_REG_WRITE0

        rts
.no_release
        lda #0
        sta famistudio_chn_epsm_trigger,y
        lda #FAMISTUDIO_EPSM_REG_KEY
        sta FAMISTUDIO_EPSM_REG_SEL0
        lda famistudio_epsm_channel_key_table, y
        sta FAMISTUDIO_EPSM_REG_WRITE0

    rts

;======================================================================================================================
; FAMISTUDIO_UPDATE_EPSM_RHYTHM_CHANNEL_SOUND (internal)
;
; Updates the EPSM audio registers for a given channel.
;
; [in] y: EPSM channel idx (0,1,2,3,4,5)
;======================================================================================================================

famistudio_update_epsm_rhythm_channel_sound:
    
.pitch = famistudio_ptr1

    lda famistudio_chn_note+FAMISTUDIO_EPSM_CH9_IDX,y
    ;bne .note
    bne .nocut
    sta famistudio_chn_epsm_rhythm_key,y
    ldx #0 ; This will fetch volume 0.
    beq .noupdate
.nocut:
    ; Read note, apply arpeggio 
    ;clc
    ;ldx famistudio_epsm_square_env_table,y
    ;adc famistudio_env_value+FAMISTUDIO_ENV_NOTE_OFF,x
    ;tax

    lda famistudio_chn_epsm_rhythm_key,y
    cmp #0x10
    beq .noupdate
    ; Write pitch

    ;lda famistudio_chn_note+FAMISTUDIO_EPSM_CH9_IDX,y
    ; Read/multiply volume
    ldx famistudio_epsm_rhythm_env_table,y
    .if FAMISTUDIO_USE_VOLUME_TRACK
        lda famistudio_chn_volume_track+FAMISTUDIO_EPSM_CH9_IDX, y
        .if FAMISTUDIO_USE_VOLUME_SLIDES
            ; During a slide, the lower 4 bits are fraction.
            and #0xf0
        .endif        
        ora famistudio_env_value+FAMISTUDIO_ENV_VOLUME_OFF,x
    .else
        lda famistudio_env_value+FAMISTUDIO_ENV_VOLUME_OFF,x
    .endif
    tax

.update_volume:
    ; Write volume
    lda famistudio_epsm_rhythm_reg_table,y
    sta FAMISTUDIO_EPSM_ADDR
    .if FAMISTUDIO_USE_VOLUME_TRACK    
        lda famistudio_volume_table,x 
    .else
        txa
    .endif
        rol a
        adc famistudio_chn_epsm_rhythm_stereo,y
        sta FAMISTUDIO_EPSM_DATA

    lda #0x10 ;FAMISTUDIO_EPSM_REG_RHY_KY
    sta famistudio_chn_epsm_rhythm_key,y
    sta FAMISTUDIO_EPSM_ADDR
    nop ;Some delay needed before writing the rythm key
    nop
    lda famistudio_epsm_rhythm_key_table,y
    sta FAMISTUDIO_EPSM_DATA

.noupdate:
    rts

.endif

    .if FAMISTUDIO_EXP_N163

; This is getting out of hand. Maybe we should compute those on the fly.
famistudio_n163_freq_table_lo:
    .byte FAMISTUDIO_N163_REG_FREQ_LO - 0x00
    .byte FAMISTUDIO_N163_REG_FREQ_LO - 0x08
    .byte FAMISTUDIO_N163_REG_FREQ_LO - 0x10
    .byte FAMISTUDIO_N163_REG_FREQ_LO - 0x18
    .byte FAMISTUDIO_N163_REG_FREQ_LO - 0x20
    .byte FAMISTUDIO_N163_REG_FREQ_LO - 0x28
    .byte FAMISTUDIO_N163_REG_FREQ_LO - 0x30
    .byte FAMISTUDIO_N163_REG_FREQ_LO - 0x38
famistudio_n163_freq_table_mid:
    .byte FAMISTUDIO_N163_REG_FREQ_MID - 0x00
    .byte FAMISTUDIO_N163_REG_FREQ_MID - 0x08
    .byte FAMISTUDIO_N163_REG_FREQ_MID - 0x10
    .byte FAMISTUDIO_N163_REG_FREQ_MID - 0x18
    .byte FAMISTUDIO_N163_REG_FREQ_MID - 0x20
    .byte FAMISTUDIO_N163_REG_FREQ_MID - 0x28
    .byte FAMISTUDIO_N163_REG_FREQ_MID - 0x30
    .byte FAMISTUDIO_N163_REG_FREQ_MID - 0x38
famistudio_n163_freq_table_hi:
    .byte FAMISTUDIO_N163_REG_FREQ_HI - 0x00
    .byte FAMISTUDIO_N163_REG_FREQ_HI - 0x08
    .byte FAMISTUDIO_N163_REG_FREQ_HI - 0x10
    .byte FAMISTUDIO_N163_REG_FREQ_HI - 0x18
    .byte FAMISTUDIO_N163_REG_FREQ_HI - 0x20
    .byte FAMISTUDIO_N163_REG_FREQ_HI - 0x28
    .byte FAMISTUDIO_N163_REG_FREQ_HI - 0x30
    .byte FAMISTUDIO_N163_REG_FREQ_HI - 0x38
famistudio_n163_vol_table:
    .byte FAMISTUDIO_N163_REG_VOLUME - 0x00
    .byte FAMISTUDIO_N163_REG_VOLUME - 0x08
    .byte FAMISTUDIO_N163_REG_VOLUME - 0x10
    .byte FAMISTUDIO_N163_REG_VOLUME - 0x18
    .byte FAMISTUDIO_N163_REG_VOLUME - 0x20
    .byte FAMISTUDIO_N163_REG_VOLUME - 0x28
    .byte FAMISTUDIO_N163_REG_VOLUME - 0x30
    .byte FAMISTUDIO_N163_REG_VOLUME - 0x38    
famistudio_n163_env_table:
    .byte FAMISTUDIO_N163_CH0_ENVS
    .byte FAMISTUDIO_N163_CH1_ENVS
    .byte FAMISTUDIO_N163_CH2_ENVS
    .byte FAMISTUDIO_N163_CH3_ENVS
    .byte FAMISTUDIO_N163_CH4_ENVS
    .byte FAMISTUDIO_N163_CH5_ENVS
    .byte FAMISTUDIO_N163_CH6_ENVS
    .byte FAMISTUDIO_N163_CH7_ENVS
    .if FAMISTUDIO_USE_PHASE_RESET
famistudio_n163_phase_table_lo:
    .byte FAMISTUDIO_N163_REG_PHASE_LO - 0x00
    .byte FAMISTUDIO_N163_REG_PHASE_LO - 0x08
    .byte FAMISTUDIO_N163_REG_PHASE_LO - 0x10
    .byte FAMISTUDIO_N163_REG_PHASE_LO - 0x18
    .byte FAMISTUDIO_N163_REG_PHASE_LO - 0x20
    .byte FAMISTUDIO_N163_REG_PHASE_LO - 0x28
    .byte FAMISTUDIO_N163_REG_PHASE_LO - 0x30
    .byte FAMISTUDIO_N163_REG_PHASE_LO - 0x38
famistudio_n163_phase_table_mid:
    .byte FAMISTUDIO_N163_REG_PHASE_MID - 0x00
    .byte FAMISTUDIO_N163_REG_PHASE_MID - 0x08
    .byte FAMISTUDIO_N163_REG_PHASE_MID - 0x10
    .byte FAMISTUDIO_N163_REG_PHASE_MID - 0x18
    .byte FAMISTUDIO_N163_REG_PHASE_MID - 0x20
    .byte FAMISTUDIO_N163_REG_PHASE_MID - 0x28
    .byte FAMISTUDIO_N163_REG_PHASE_MID - 0x30
    .byte FAMISTUDIO_N163_REG_PHASE_MID - 0x38
famistudio_n163_phase_table_hi:
    .byte FAMISTUDIO_N163_REG_PHASE_HI - 0x00
    .byte FAMISTUDIO_N163_REG_PHASE_HI - 0x08
    .byte FAMISTUDIO_N163_REG_PHASE_HI - 0x10
    .byte FAMISTUDIO_N163_REG_PHASE_HI - 0x18
    .byte FAMISTUDIO_N163_REG_PHASE_HI - 0x20
    .byte FAMISTUDIO_N163_REG_PHASE_HI - 0x28
    .byte FAMISTUDIO_N163_REG_PHASE_HI - 0x30
    .byte FAMISTUDIO_N163_REG_PHASE_HI - 0x38
    .endif

;======================================================================================================================
; FAMISTUDIO_UPDATE_N163_CHANNEL_SOUND (internal)
;
; Updates the N163 audio registers for a given channel.
;
; [in] y: N163 channel idx (0,1,2,3,4,5,6,7)
;======================================================================================================================

famistudio_update_n163_channel_sound:

.pitch    = famistudio_ptr1
.pitch_hi = famistudio_r2

    lda famistudio_chn_note+FAMISTUDIO_N163_CH0_IDX,y
    bne .nocut
    ldx #0 ; This will fetch volume 0.
    jmp .update_volume

.nocut:

    jsr famistudio_update_n163_wave

    ; Read note, apply arpeggio 
    lda famistudio_chn_note+FAMISTUDIO_N163_CH0_IDX,y 
    clc
    ldx famistudio_n163_env_table,y
    adc famistudio_env_value+FAMISTUDIO_ENV_NOTE_OFF,x
    tax

    ; Apply pitch envelope, fine pitch & slides
    famistudio_get_note_pitch_macro FAMISTUDIO_N163_CH0_PITCH_ENV_IDX, FAMISTUDIO_N163_PITCH_SHIFT, famistudio_n163_note_table_lsb, famistudio_n163_note_table_msb

    ; Convert 16-bit -> 18-bit.
    asl *.pitch+0
    rol *.pitch+1
    lda #0
    adc #0
    sta *.pitch_hi
    asl *.pitch+0
    rol *.pitch+1
    rol *.pitch_hi 

    ; Write pitch
    lda famistudio_n163_freq_table_lo,y
    sta FAMISTUDIO_N163_ADDR
    lda *.pitch+0
    sta FAMISTUDIO_N163_DATA
    lda famistudio_n163_freq_table_mid,y
    sta FAMISTUDIO_N163_ADDR
    lda *.pitch+1
    sta FAMISTUDIO_N163_DATA
    lda famistudio_n163_freq_table_hi,y
    sta FAMISTUDIO_N163_ADDR
    lda famistudio_chn_n163_wave_len,y
    ora *.pitch_hi
    sta FAMISTUDIO_N163_DATA

    ; Read/multiply volume
    ldx famistudio_n163_env_table,y
    .if FAMISTUDIO_USE_VOLUME_TRACK
        lda famistudio_chn_volume_track+FAMISTUDIO_N163_CH0_IDX, y
        .if FAMISTUDIO_USE_VOLUME_SLIDES
            ; During a slide, the lower 4 bits are fraction.
            and #0xf0
        .endif        
        ora famistudio_env_value+FAMISTUDIO_ENV_VOLUME_OFF,x
    .else
        lda famistudio_env_value+FAMISTUDIO_ENV_VOLUME_OFF,x
    .endif
    tax

.update_volume:
    ; Write volume
    lda famistudio_n163_vol_table,y
    sta FAMISTUDIO_N163_ADDR
    .if FAMISTUDIO_USE_VOLUME_TRACK
        lda famistudio_volume_table,x 
    .else
        txa
    .endif
    ora #FAMISTUDIO_N163_CHN_MASK
    sta FAMISTUDIO_N163_DATA
    
    lda #0
    sta famistudio_chn_inst_changed-FAMISTUDIO_FIRST_EXP_INST_CHANNEL+FAMISTUDIO_N163_CH0_IDX,y

    .if FAMISTUDIO_USE_PHASE_RESET
.reset_phase:
    lda famistudio_channel_to_phase_reset_mask+FAMISTUDIO_N163_CH0_IDX, y
    and famistudio_phase_reset_n163
    beq .done
    ldx #0
    lda famistudio_n163_phase_table_lo,y
    sta FAMISTUDIO_N163_ADDR
    stx FAMISTUDIO_N163_DATA
    lda famistudio_n163_phase_table_mid,y
    sta FAMISTUDIO_N163_ADDR
    stx FAMISTUDIO_N163_DATA
    lda famistudio_n163_phase_table_hi,y
    sta FAMISTUDIO_N163_ADDR
    stx FAMISTUDIO_N163_DATA
    .endif

.done:
    rts

    .endif

    .if FAMISTUDIO_EXP_S5B

famistudio_s5b_reg_table_lo:
    .byte FAMISTUDIO_S5B_REG_LO_A, FAMISTUDIO_S5B_REG_LO_B, FAMISTUDIO_S5B_REG_LO_C
famistudio_s5b_reg_table_hi:
    .byte FAMISTUDIO_S5B_REG_HI_A, FAMISTUDIO_S5B_REG_HI_B, FAMISTUDIO_S5B_REG_HI_C
famistudio_s5b_vol_table:
    .byte FAMISTUDIO_S5B_REG_VOL_A, FAMISTUDIO_S5B_REG_VOL_B, FAMISTUDIO_S5B_REG_VOL_C
famistudio_s5b_env_table:
    .byte FAMISTUDIO_S5B_CH0_ENVS, FAMISTUDIO_S5B_CH1_ENVS, FAMISTUDIO_S5B_CH2_ENVS

;======================================================================================================================
; FAMISTUDIO_UPDATE_S5B_CHANNEL_SOUND (internal)
;
; Updates the S5B audio registers for a given channel.
;
; [in] y: S5B channel idx (0,1,2)
;======================================================================================================================

famistudio_update_s5b_channel_sound:
    
.pitch = famistudio_ptr1

    lda famistudio_chn_note+FAMISTUDIO_S5B_CH0_IDX,y
    bne .nocut
    ldx #0 ; This will fetch volume 0.
    beq .update_volume_jmp
    jmp .nocut
.update_volume_jmp:
	jmp .update_volume
.nocut:
    
    lda #0x07
    sta FAMISTUDIO_S5B_ADDR
    lda famistudio_env_value+FAMISTUDIO_S5B_CH2_ENVS+FAMISTUDIO_ENV_MIXER_IDX_OFF ;load mixer envelope
    asl a
    ora famistudio_env_value+FAMISTUDIO_S5B_CH1_ENVS+FAMISTUDIO_ENV_MIXER_IDX_OFF ;load mixer envelope
    asl a
    ora famistudio_env_value+FAMISTUDIO_S5B_CH0_ENVS+FAMISTUDIO_ENV_MIXER_IDX_OFF ;load mixer envelope
    sta FAMISTUDIO_S5B_DATA



    ldx famistudio_s5b_env_table,y
    lda famistudio_env_value+FAMISTUDIO_ENV_NOISE_IDX_OFF,x
    beq .nonoise
    lda #0x06
    sta FAMISTUDIO_S5B_ADDR
    ldx famistudio_s5b_env_table,y
    lda famistudio_env_value+FAMISTUDIO_ENV_NOISE_IDX_OFF,x
    sta FAMISTUDIO_S5B_DATA
.nonoise:

    lda famistudio_chn_note+FAMISTUDIO_S5B_CH0_IDX,y
    ; Read note, apply arpeggio 
    clc
    ldx famistudio_s5b_env_table,y
    adc famistudio_env_value+FAMISTUDIO_ENV_NOTE_OFF,x
    tax

    ; Apply pitch envelope, fine pitch & slides
    famistudio_get_note_pitch_macro FAMISTUDIO_S5B_CH0_PITCH_ENV_IDX, 0, famistudio_note_table_lsb, famistudio_note_table_msb

    ; Write pitch
    lda famistudio_s5b_reg_table_lo,y
    sta FAMISTUDIO_S5B_ADDR
    lda *.pitch+0
    sta FAMISTUDIO_S5B_DATA
    lda famistudio_s5b_reg_table_hi,y
    sta FAMISTUDIO_S5B_ADDR
    lda *.pitch+1
    sta FAMISTUDIO_S5B_DATA

    ; Read/multiply volume
    ldx famistudio_s5b_env_table,y
    .if FAMISTUDIO_USE_VOLUME_TRACK
        lda famistudio_chn_volume_track+FAMISTUDIO_S5B_CH0_IDX, y
        .if FAMISTUDIO_USE_VOLUME_SLIDES
            ; During a slide, the lower 4 bits are fraction.
            and #0xf0
        .endif        
        ora famistudio_env_value+FAMISTUDIO_ENV_VOLUME_OFF,x
    .else
        lda famistudio_env_value+FAMISTUDIO_ENV_VOLUME_OFF,x
    .endif
    tax

.update_volume:
    ; Write volume
    lda famistudio_s5b_vol_table,y
    sta FAMISTUDIO_S5B_ADDR
    .if FAMISTUDIO_USE_VOLUME_TRACK    
        lda famistudio_volume_table,x 
        sta FAMISTUDIO_S5B_DATA
    .else
        stx FAMISTUDIO_S5B_DATA
    .endif
    rts

    .endif

;======================================================================================================================
; FAMISTUDIO_UPDATE_ROW (internal)
;
; Advance the song for a given channel. Will read any new note or effect (if any) and load any new 
;
; [in] x: channel index (also true when leaving the function)
;======================================================================================================================

famistudio_update_row:

    .ifeq FAMISTUDIO_CFG_DPCM_SUPPORT
    cpx #4
    beq .no_new_note
    .endif

    jsr famistudio_update_channel
    beq .no_new_note

    ; TODO : See if we keep the instrument in X instead of Y, this is a mess.
    txa
    tay
    ldx famistudio_channel_env,y
    lda famistudio_chn_instrument,y

    cpy #4 ; TODO: If samples are disabled, there is no point in doing this test most of the time.
    .if FAMISTUDIO_EXP_VRC6 | FAMISTUDIO_EXP_MMC5
    bne .base_instrument
    .else
    bcc .base_instrument
    .endif
    .if FAMISTUDIO_EXP_FDS | FAMISTUDIO_EXP_VRC7 | FAMISTUDIO_EXP_N163 | FAMISTUDIO_EXP_EPSM | FAMISTUDIO_EXP_S5B
    beq .dpcm
    .if FAMISTUDIO_EXP_FDS
    .fds_instrument:
        jsr famistudio_set_fds_instrument
        jmp .new_note
    .endif
    .if FAMISTUDIO_EXP_VRC7
    .vrc7_instrument:
        jsr famistudio_set_vrc7_instrument
        jmp .new_note
    .endif
    .if FAMISTUDIO_EXP_N163
    .n163_instrument:
        jsr famistudio_set_n163_instrument
        jmp .new_note
    .endif
    .if FAMISTUDIO_EXP_S5B
    .s5b_instrument:
        jsr famistudio_set_s5b_instrument
        jmp .new_note
    .endif
    .if FAMISTUDIO_EXP_EPSM
    .epsm_instrument:
        jsr famistudio_set_epsm_instrument
        jmp .new_note
    .endif
    .endif

    .dpcm:
    .if FAMISTUDIO_CFG_DPCM_SUPPORT        
        lda famistudio_chn_note+4
        bne .play_sample
        jsr famistudio_sample_stop
        ldx #4
        bne .no_new_note
        .play_sample:
            sbc #12 ; Carry already set. HACK : Our "notes" for DPCM start at SingleByteNoteMin (12). Need to undo that here. See C# code.
            jsr famistudio_music_sample_play
            ldx #4
            jmp .new_note
    .endif

    .base_instrument:
        jsr famistudio_set_instrument

    .new_note:
    .if FAMISTUDIO_CFG_EQUALIZER 
        lda #9
        sta famistudio_chn_note_counter, x
    .endif
    .no_new_note:
    rts

    .if FAMISTUDIO_USE_FAMITRACKER_DELAYED_NOTES_OR_CUTS

;======================================================================================================================
; FAMISTUDIO_UPDATE_ROW_WITH_DELAYS (internal)
;
; Advance the song for a given channel, but while managing notes/cuts delays. 
;
; [in] x: channel index (also true when leaving the function)
;======================================================================================================================

famistudio_update_row_with_delays:

    ; Is the tempo telling us to advance by 1 row?
    lda famistudio_tempo_advance_row
    beq .check_delayed_note

    ; Tempo says we need to advance, was there a delayed note wairing?
    lda famistudio_chn_note_delay,x
    bmi .advance

    ; Need to clear any pending delayed note before advancing (will be inaudible).
    .clear_delayed_note:
    lda #0xff
    sta famistudio_chn_note_delay,x
    jsr famistudio_update_row ; This is the update for the de delayed note.
    jmp .advance

    ; Tempo said we didnt need to advance, see if there is delayed note with a counter that reached zero.
    .check_delayed_note:
    lda famistudio_chn_note_delay,x
    bmi .check_delayed_cut
    sec
    sbc #1
    sta famistudio_chn_note_delay,x
    bpl .check_delayed_cut ; When wrapping from 0 -> 0xff, we play the note.

    ; Finally, advance by 1 row.
    .advance:
    jsr famistudio_update_row

    ; Handle delayed cuts.
    .check_delayed_cut:
    lda famistudio_chn_cut_delay,x
    bmi .done
    sec
    sbc #1
    sta famistudio_chn_cut_delay,x
    bpl .done ; When wrapping from 0 -> 0xff, we play the note.

    ; Write a stop note.
    lda #0
    sta famistudio_chn_note,x

    .done:
    rts

    .endif

;======================================================================================================================
; FAMISTUDIO_UPDATE (public)
;
; Main update function, should be called once per frame, ideally at the end of NMI. Will update the tempo, advance
; the song if needed, update instrument and apply any change to the APU registers.
;
; [in] no input params.
;======================================================================================================================

_famistudio_update::

.pitch_env_type = famistudio_r0
.temp_pitch     = famistudio_r1
.tempo_env_ptr  = famistudio_ptr0
.env_ptr        = famistudio_ptr0
.pitch_env_ptr  = famistudio_ptr0

    .if FAMISTUDIO_CFG_THREAD
    lda *famistudio_ptr0_lo
    pha
    lda *famistudio_ptr0_hi
    pha
    .endif

    lda famistudio_song_speed ; Speed 0 means that no music is playing currently
    bmi .pause ; Bit 7 set is the pause flag
    bne .update
.pause:
    .ifeq FAMISTUDIO_USE_FAMITRACKER_TEMPO
    lda #1
    sta famistudio_tempo_frame_cnt
    .endif
    jmp .update_sound

;----------------------------------------------------------------------------------------------------------------------
.update:

    .if FAMISTUDIO_USE_FAMITRACKER_TEMPO

    lda famistudio_tempo_acc_hi
    cmp famistudio_song_speed
    .if FAMISTUDIO_USE_FAMITRACKER_DELAYED_NOTES_OR_CUTS
        ldx #0
        stx famistudio_tempo_advance_row    
        bcc .update_row
    .else
        bcc .update_envelopes
    .endif
    sbc famistudio_song_speed ; Carry is set.
    sta famistudio_tempo_acc_hi    
    .if FAMISTUDIO_USE_FAMITRACKER_DELAYED_NOTES_OR_CUTS
        ldx #1
        stx famistudio_tempo_advance_row
    .endif

    .else ; FamiStudio tempo

    ; Decrement envelope counter, see if we need to advance.
    dec famistudio_tempo_env_counter
    beq .advance_tempo_envelope
    lda #1
    jmp .store_frame_count

.advance_tempo_envelope:
    ; Advance the envelope by one step.
    lda famistudio_tempo_env_ptr_lo
    sta *.tempo_env_ptr+0
    lda famistudio_tempo_env_ptr_hi
    sta *.tempo_env_ptr+1

    inc famistudio_tempo_env_idx
    ldy famistudio_tempo_env_idx
    lda [*.tempo_env_ptr],y
    bpl .store_counter ; Negative value means we loop back to to index 1.

.tempo_envelope_end:
    ldy #1
    sty famistudio_tempo_env_idx
    lda [*.tempo_env_ptr],y

.store_counter:
    ; Reset the counter
    sta famistudio_tempo_env_counter
    lda famistudio_tempo_frame_num
    bne .store_frame_count
    jmp .skip_frame

.store_frame_count:
    sta famistudio_tempo_frame_cnt

    .endif

;----------------------------------------------------------------------------------------------------------------------
.update_row:
    ldx #0
    .channel_loop:
        .if FAMISTUDIO_USE_FAMITRACKER_DELAYED_NOTES_OR_CUTS
            jsr famistudio_update_row_with_delays
        .else
            jsr famistudio_update_row
        .endif
        inx
        cpx #FAMISTUDIO_NUM_CHANNELS
        bne .channel_loop

;----------------------------------------------------------------------------------------------------------------------
.update_envelopes:
    ldx #0

.env_process:
    lda famistudio_env_repeat,x
    beq .env_read  
    dec famistudio_env_repeat,x
    bne .env_next

.env_read:
    lda famistudio_env_addr_lo,x
    sta *.env_ptr+0
    lda famistudio_env_addr_hi,x
    sta *.env_ptr+1
    ldy famistudio_env_ptr,x

.env_read_value:
    lda [*.env_ptr],y
    bpl .env_special ; Values below 128 used as a special code, loop or repeat
    clc              ; Values above 128 are output value+192 (output values are signed -63..64)
    adc #256-192
    sta famistudio_env_value,x
    iny
    bne .env_next_store_ptr

.env_special:
    bne .env_set_repeat  ; Zero is the loop point, non-zero values used for the repeat counter
    iny
    lda [*.env_ptr],y     ; Read loop position
    tay
    jmp .env_read_value

.env_set_repeat:
    iny
    sta famistudio_env_repeat,x ; Store the repeat counter value

.env_next_store_ptr:
    tya
    sta famistudio_env_ptr,x

.env_next:
    inx

    cpx #FAMISTUDIO_NUM_ENVELOPES
    bne .env_process

;----------------------------------------------------------------------------------------------------------------------
.update_pitch_envelopes:
    ldx #0
    jmp .pitch_env_process

.pitch_env_process:
    lda famistudio_pitch_env_repeat,x
    beq .pitch_env_read
    dec famistudio_pitch_env_repeat,x
    bne .pitch_env_next

.pitch_env_read:
    lda famistudio_pitch_env_addr_lo,x 
    sta *.pitch_env_ptr+0
    lda famistudio_pitch_env_addr_hi,x
    sta *.pitch_env_ptr+1
    ldy #0
    lda [*.pitch_env_ptr],y
    sta *.pitch_env_type ; First value is 0 for absolute envelope, 0x80 for relative.
    ldy famistudio_pitch_env_ptr,x

.pitch_env_read_value:
    lda [*.pitch_env_ptr],y
    bpl .pitch_env_special 
    clc  
    adc #256-192
    bit *.pitch_env_type
    bmi .pitch_relative

.pitch_absolute:
    sta famistudio_pitch_env_value_lo,x
    ora #0
    bmi .pitch_absolute_neg  
    lda #0
    jmp .pitch_absolute_set_value_hi
.pitch_absolute_neg:
    lda #0xff
.pitch_absolute_set_value_hi:
    sta famistudio_pitch_env_value_hi,x
    iny 
    jmp .pitch_env_next_store_ptr

.pitch_relative:
    sta *.temp_pitch
    clc
    adc famistudio_pitch_env_value_lo,x
    sta famistudio_pitch_env_value_lo,x
    lda *.temp_pitch
    and #0x80
    bpl .pitch_relative_pos  
    lda #0xff
.pitch_relative_pos:
    adc famistudio_pitch_env_value_hi,x
    sta famistudio_pitch_env_value_hi,x
    iny 
    jmp .pitch_env_next_store_ptr

.pitch_env_special:
    bne .pitch_env_set_repeat
    iny 
    lda [*.pitch_env_ptr],y 
    tay
    jmp .pitch_env_read_value 

.pitch_env_set_repeat:
    iny
    ora *.pitch_env_type ; This is going to set the relative flag in the hi-bit.
    sta famistudio_pitch_env_repeat,x

.pitch_env_next_store_ptr:
    tya 
    sta famistudio_pitch_env_ptr,x

.pitch_env_next:
    inx 

    cpx #FAMISTUDIO_NUM_PITCH_ENVELOPES
    bne .pitch_env_process

    .if FAMISTUDIO_USE_SLIDE_NOTES
;----------------------------------------------------------------------------------------------------------------------
.update_slides:
    ldx #0

.slide_process:
    lda famistudio_slide_step,x ; Zero repeat means no active slide.
    beq .slide_next
    clc ; Add step to slide pitch (16bit + 8bit signed).
    lda famistudio_slide_step,x
    adc famistudio_slide_pitch_lo,x
    sta famistudio_slide_pitch_lo,x
    lda famistudio_slide_step,x
    and #0x80
    beq .positive_slide

.negative_slide:
    lda #0xff
    adc famistudio_slide_pitch_hi,x
    sta famistudio_slide_pitch_hi,x
    bpl .slide_next
    jmp .clear_slide

.positive_slide:
    adc famistudio_slide_pitch_hi,x
    sta famistudio_slide_pitch_hi,x
    bmi .slide_next

.clear_slide:
    lda #0
    sta famistudio_slide_step,x

.slide_next:
    inx 
    cpx #FAMISTUDIO_NUM_SLIDES
    bne .slide_process
    .endif

    .if FAMISTUDIO_USE_VOLUME_SLIDES

; FIXME : This seem wayyyy more complicated than it should.
; - The track volume has 4 bits of fraction : VVVVFFFF
; - The slide step is signed : SVVVFFFF
; - The slide target (end volume) is simply : VVVV0000
;
; foreach slides
;     if step != 0
;         volume += step
;         if step > 0 && volume >= target || step < 0 && volume <= target
;             volume = target
;             step = 0

.update_volume_slides:
    ldx #0

.volume_side_process:
    lda famistudio_chn_volume_slide_step,x
    beq .volume_slide_next
    clc 
    bmi .negative_volume_slide
    
.positive_volume_slide:
    ; If the slide goes up, stop if we hit the target or go over it, over 15 (carry will be set)
    adc famistudio_chn_volume_track,x
    bcs .clear_volume_slide
    sta famistudio_chn_volume_track,x
    cmp famistudio_chn_volume_slide_target,x
    bcc .volume_slide_next
    bcs .clear_volume_slide

.negative_volume_slide:
    ; If the slide goes do, stop if we hit the target or go below it, or below zero.
    ; This is a bit trickier since we cant rely on the carry or any flag to 
    ; tell us if we wrapped around. 
    adc famistudio_chn_volume_track,x
    ldy famistudio_chn_volume_track,x
    bmi .slide_upper_half

.slide_lower_half:
    sta famistudio_chn_volume_track,x
    cmp famistudio_chn_volume_slide_target,x
    beq .clear_volume_slide
    bmi .clear_volume_slide
    bpl .volume_slide_next

.slide_upper_half:
    sta famistudio_chn_volume_track,x
    cmp famistudio_chn_volume_slide_target,x
    beq .clear_volume_slide
    bcs .volume_slide_next

.clear_volume_slide:    
    lda famistudio_chn_volume_slide_target,x
    sta famistudio_chn_volume_track,x
    lda #0
    sta famistudio_chn_volume_slide_step,x

.volume_slide_next:
    inx 
    cpx #FAMISTUDIO_NUM_VOLUME_SLIDES
    bne .volume_side_process
    .endif

    .if FAMISTUDIO_CFG_EQUALIZER
.update_equalizer:
    ldx #0
    .eq_channel_loop:
        lda famistudio_chn_note_counter, x
        beq .no_note
            dec famistudio_chn_note_counter, x
        .no_note:
        inx
        cpx #FAMISTUDIO_NUM_CHANNELS
        bne .eq_channel_loop
    .endif

;----------------------------------------------------------------------------------------------------------------------
.update_sound:

    famistudio_update_channel_sound 0, FAMISTUDIO_CH0_ENVS, famistudio_pulse1_prev, FAMISTUDIO_ALIAS_PL1_HI, FAMISTUDIO_ALIAS_PL1_LO, FAMISTUDIO_ALIAS_PL1_VOL, FAMISTUDIO_APU_PL1_SWEEP, #0x01
    famistudio_update_channel_sound 1, FAMISTUDIO_CH1_ENVS, famistudio_pulse2_prev, FAMISTUDIO_ALIAS_PL2_HI, FAMISTUDIO_ALIAS_PL2_LO, FAMISTUDIO_ALIAS_PL2_VOL, FAMISTUDIO_APU_PL2_SWEEP, #0x02
    famistudio_update_channel_sound 2, FAMISTUDIO_CH2_ENVS, , FAMISTUDIO_ALIAS_TRI_HI, FAMISTUDIO_ALIAS_TRI_LO, FAMISTUDIO_ALIAS_TRI_LINEAR, , 0
    famistudio_update_channel_sound 3, FAMISTUDIO_CH3_ENVS, , FAMISTUDIO_ALIAS_NOISE_LO, , FAMISTUDIO_ALIAS_NOISE_VOL, , 0

    .if FAMISTUDIO_EXP_VRC6
.update_vrc6_sound:
    famistudio_update_channel_sound FAMISTUDIO_VRC6_CH0_IDX, FAMISTUDIO_VRC6_CH0_ENVS, 0, FAMISTUDIO_VRC6_PL1_HI, FAMISTUDIO_VRC6_PL1_LO, FAMISTUDIO_VRC6_PL1_VOL, 0, #0x04
    famistudio_update_channel_sound FAMISTUDIO_VRC6_CH1_IDX, FAMISTUDIO_VRC6_CH1_ENVS, 0, FAMISTUDIO_VRC6_PL2_HI, FAMISTUDIO_VRC6_PL2_LO, FAMISTUDIO_VRC6_PL2_VOL, 0, #0x08
    famistudio_update_channel_sound FAMISTUDIO_VRC6_CH2_IDX, FAMISTUDIO_VRC6_CH2_ENVS, 0, FAMISTUDIO_VRC6_SAW_HI, FAMISTUDIO_VRC6_SAW_LO, FAMISTUDIO_VRC6_SAW_VOL, 0, #0x10
    .endif

    .if FAMISTUDIO_EXP_MMC5
.update_mmc5_sound:
    famistudio_update_channel_sound FAMISTUDIO_MMC5_CH0_IDX, FAMISTUDIO_MMC5_CH0_ENVS, famistudio_mmc5_pulse1_prev, FAMISTUDIO_MMC5_PL1_HI, FAMISTUDIO_MMC5_PL1_LO, FAMISTUDIO_MMC5_PL1_VOL, 0, #0x20
    famistudio_update_channel_sound FAMISTUDIO_MMC5_CH1_IDX, FAMISTUDIO_MMC5_CH1_ENVS, famistudio_mmc5_pulse2_prev, FAMISTUDIO_MMC5_PL2_HI, FAMISTUDIO_MMC5_PL2_LO, FAMISTUDIO_MMC5_PL2_VOL, 0, #0x40
    .endif

    .if FAMISTUDIO_EXP_FDS
.update_fds_sound:
    jsr famistudio_update_fds_channel_sound
    .endif

    .if FAMISTUDIO_EXP_VRC7
.update_vrc7_sound:
    ldy #0
    .vrc7_channel_loop:
        jsr famistudio_update_vrc7_channel_sound
        iny
        cpy #6
        bne .vrc7_channel_loop
    .endif

    .if FAMISTUDIO_EXP_N163
.update_n163_sound:
    ldy #0
    .n163_channel_loop:
        jsr famistudio_update_n163_channel_sound
        iny
        cpy #FAMISTUDIO_EXP_N163_CHN_CNT
        bne .n163_channel_loop
    .endif

    .if FAMISTUDIO_EXP_S5B
.update_s5b_sound:
    ldy #0
    .s5b_channel_loop:
        jsr famistudio_update_s5b_channel_sound
        iny
        cpy #3
        bne .s5b_channel_loop
    .endif

    .if FAMISTUDIO_EXP_EPSM
.update_epsm_sound:
    ldy #2
    .epsm_square_channel_loop:
        jsr famistudio_update_epsm_square_channel_sound
        dey
        bpl .epsm_square_channel_loop
    ldy #5
    .epsm_fm_channel_loop:
        jsr famistudio_update_epsm_fm_channel_sound
        dey
        bpl .epsm_fm_channel_loop
    ldy #5
    .epsm_rhythm_channel_loop:
        jsr famistudio_update_epsm_rhythm_channel_sound
        dey
        bpl .epsm_rhythm_channel_loop
    .endif

    .if FAMISTUDIO_USE_PHASE_RESET
.clear_phase_reset_flags:
    lda #0
    sta famistudio_phase_reset
    .if FAMISTUDIO_EXP_N163
        sta famistudio_phase_reset_n163
    .endif
    .endif

.update_sound_done:
    .if FAMISTUDIO_USE_FAMITRACKER_TEMPO
    lda famistudio_song_speed
    bmi .skip_famitracker_tempo_update ; bit 7 = paused
        clc  ; Update frame counter that considers speed, tempo, and PAL/NTSC
        lda famistudio_tempo_acc_lo
        adc famistudio_tempo_step_lo
        sta famistudio_tempo_acc_lo
        lda famistudio_tempo_acc_hi
        adc famistudio_tempo_step_hi
        sta famistudio_tempo_acc_hi
    .skip_famitracker_tempo_update:
    .else
    ; See if we need to run a double frame (playing NTSC song on PAL)
    dec famistudio_tempo_frame_cnt
    beq .skip_frame
    jmp .update_row
    .endif

.skip_frame:

;----------------------------------------------------------------------------------------------------------------------
    .if FAMISTUDIO_CFG_SFX_SUPPORT

    ; Process all sound effect streams
    ;.if FAMISTUDIO_CFG_SFX_STREAMS > 0
    .ifgt FAMISTUDIO_CFG_SFX_STREAMS
    ldx #FAMISTUDIO_SFX_CH0
    jsr famistudio_sfx_update
    .endif
    ;.if FAMISTUDIO_CFG_SFX_STREAMS > 1
    .ifgt FAMISTUDIO_CFG_SFX_STREAMS - 1
    ldx #FAMISTUDIO_SFX_CH1
    jsr famistudio_sfx_update
    .endif
    ;.if FAMISTUDIO_CFG_SFX_STREAMS > 2
    .ifgt FAMISTUDIO_CFG_SFX_STREAMS - 2
    ldx #FAMISTUDIO_SFX_CH2
    jsr famistudio_sfx_update
    .endif
    ;.if FAMISTUDIO_CFG_SFX_STREAMS > 3
    .ifgt FAMISTUDIO_CFG_SFX_STREAMS - 3
    ldx #FAMISTUDIO_SFX_CH3
    jsr famistudio_sfx_update
    .endif

    ; Send data from the output buffer to the APU

    lda famistudio_output_buf      ; Pulse 1 volume
    sta FAMISTUDIO_APU_PL1_VOL
    lda famistudio_output_buf+1    ; Pulse 1 period LSB
    sta FAMISTUDIO_APU_PL1_LO
    lda famistudio_output_buf+2    ; Pulse 1 period MSB, only applied when changed

    .if FAMISTUDIO_CFG_SMOOTH_VIBRATO
        famistudio_smooth_vibrato famistudio_output_buf+1, famistudio_pulse1_prev, FAMISTUDIO_APU_PL1_HI, FAMISTUDIO_APU_PL1_LO, FAMISTUDIO_APU_PL1_SWEEP, 0
    .else
        cmp famistudio_pulse1_prev
        beq .no_pulse1_upd
        sta famistudio_pulse1_prev
        sta FAMISTUDIO_APU_PL1_HI
    .endif        

.no_pulse1_upd:
    lda famistudio_output_buf+3    ; Pulse 2 volume
    sta FAMISTUDIO_APU_PL2_VOL
    lda famistudio_output_buf+4    ; Pulse 2 period LSB
    sta FAMISTUDIO_APU_PL2_LO
    lda famistudio_output_buf+5    ; Pulse 2 period MSB, only applied when changed

    .if FAMISTUDIO_CFG_SMOOTH_VIBRATO
        famistudio_smooth_vibrato famistudio_output_buf+4, famistudio_pulse2_prev, FAMISTUDIO_APU_PL2_HI, FAMISTUDIO_APU_PL2_LO, FAMISTUDIO_APU_PL2_SWEEP, 0
    .else
        cmp famistudio_pulse2_prev
        beq .no_pulse2_upd
        sta famistudio_pulse2_prev
        sta FAMISTUDIO_APU_PL2_HI
    .endif

.no_pulse2_upd:
    lda famistudio_output_buf+6    ; Triangle volume (plays or not)
    sta FAMISTUDIO_APU_TRI_LINEAR
    lda famistudio_output_buf+7    ; Triangle period LSB
    sta FAMISTUDIO_APU_TRI_LO
    lda famistudio_output_buf+8    ; Triangle period MSB
    sta FAMISTUDIO_APU_TRI_HI

    lda famistudio_output_buf+9    ; Noise volume
    sta FAMISTUDIO_APU_NOISE_VOL
    lda famistudio_output_buf+10   ; Noise period
    sta FAMISTUDIO_APU_NOISE_LO

    .endif

    .if FAMISTUDIO_CFG_THREAD
    pla
    sta *famistudio_ptr0_hi
    pla
    sta *famistudio_ptr0_lo
    .endif

    rts

;======================================================================================================================
; FAMISTUDIO_SET_INSTRUMENT (internal)
;
; Internal function to set an instrument for a given channel. Will initialize all instrument envelopes.
;
; [in] x: first envelope index for this channel.
; [in] y: channel index
; [in] a: instrument index.
;======================================================================================================================

famistudio_set_instrument:

.intrument_ptr = famistudio_ptr0
.chan_idx      = famistudio_r1
.tmp_x         = famistudio_r2

    sty *.chan_idx
    asl a ; Instrument number is pre multiplied by 4
    tay
    lda famistudio_instrument_hi
    adc #0 ; Use carry to extend range for 64 instruments
    sta *.intrument_ptr+1
    lda famistudio_instrument_lo
    sta *.intrument_ptr+0

    ; Volume envelope
    lda [*.intrument_ptr],y
    sta famistudio_env_addr_lo,x
    iny
    lda [*.intrument_ptr],y
    iny
    sta famistudio_env_addr_hi,x
    inx

    ; Arpeggio envelope
    .if FAMISTUDIO_USE_ARPEGGIO
    stx *.tmp_x
    ldx *.chan_idx
    lda famistudio_chn_env_override,x ; Check if its overriden by arpeggio.
    lsr a
    ldx *.tmp_x
    bcc .read_arpeggio_ptr 
    iny ; Instrument arpeggio is overriden by arpeggio, dont touch!
    jmp .init_envelopes
    .endif

.read_arpeggio_ptr:    
    lda [*.intrument_ptr],y
    sta famistudio_env_addr_lo,x
    iny
    lda [*.intrument_ptr],y
    sta famistudio_env_addr_hi,x

.init_envelopes:
    ; Initialize volume + arpeggio envelopes.
    lda #1
    sta famistudio_env_ptr-1,x ; Reset volume envelope pointer to 1 (volume have releases point in index 0)
    lda #0
    sta famistudio_env_repeat-1,x
    sta famistudio_env_repeat,x
    sta famistudio_env_ptr,x

    ; Duty cycle envelope
    lda *.chan_idx
    cmp #2 ; Triangle has no duty.
    bne .duty
    .no_duty:
        iny
        iny
        bne .pitch_env
    .duty:
        inx
        iny
        lda [*.intrument_ptr],y
        sta famistudio_env_addr_lo,x
        iny
        lda [*.intrument_ptr],y
        sta famistudio_env_addr_hi,x
        lda #0
        sta famistudio_env_repeat,x
        sta famistudio_env_ptr,x
        .if FAMISTUDIO_USE_DUTYCYCLE_EFFECT
            stx *.tmp_x
            ldx *.chan_idx
            lda famistudio_channel_to_dutycycle,x 
            tax
            lda famistudio_duty_cycle,x
            ldx *.tmp_x
        .endif
        sta famistudio_env_value,x
    .pitch_env:
    ; Pitch envelopes.
    ldx *.chan_idx
    .if FAMISTUDIO_USE_VIBRATO 
    lda famistudio_chn_env_override,x 
    asl a ; Bit-7 tells us if the pitch env is overriden, temporarely store in carry.
    .endif    
    lda famistudio_channel_to_pitch_env, x
    bmi .no_pitch
    tax
    .if FAMISTUDIO_USE_VIBRATO 
    ror a ; Bring back our bit-7 from above.
    bmi .reset_pitch_env ; Instrument pitch is overriden by vibrato, dont touch!
    .endif    
    lda #0
    sta famistudio_pitch_env_value_lo,x
    sta famistudio_pitch_env_value_hi,x
    iny
    lda [*.intrument_ptr],y
    sta famistudio_pitch_env_addr_lo,x
    iny
    lda [*.intrument_ptr],y
    sta famistudio_pitch_env_addr_hi,x
    .reset_pitch_env:
    lda #0
    sta famistudio_pitch_env_repeat,x
    lda #1
    sta famistudio_pitch_env_ptr,x     ; Reset pitch envelope pointert to 1 (pitch envelope have relative/absolute flag in the first byte)
    .no_pitch:
    ldx *.chan_idx
    rts

    .if FAMISTUDIO_EXP_FDS | FAMISTUDIO_EXP_N163 | FAMISTUDIO_EXP_VRC7 | FAMISTUDIO_EXP_EPSM | FAMISTUDIO_EXP_S5B

;======================================================================================================================
; FAMISTUDIO_GET_EXP_INST_PTR (internal)
;
; Internal macro to retrive the instrument pointer for a given index.
;
; [in]  a: instrument index.
; [out] r0: the instrument pointer
; [out] y:  index in the instrument array.
;======================================================================================================================

;famistudio_get_exp_inst_ptr .macro
.macro famistudio_get_exp_inst_ptr
    .define .ptr "famistudio_ptr0"
    asl a ; Instrument number is pre multiplied by 4
    asl a
    tay
    lda famistudio_exp_instrument_hi
    adc #0  ; Use carry to extend range for 32 expansion instruments
    sta *.ptr+1
    lda famistudio_exp_instrument_lo
    sta *.ptr+0
.endm

;======================================================================================================================
; FAMISTUDIO_SET_EXP_INSTRUMENT_BASE (internal)
;
; Internal macro to set an expansion instrument for a given channel. Will initialize all instrument envelopes.
;
; [in] x: first envelope index for this channel.
; [in] y: channel index
; [in] a: instrument index.
;======================================================================================================================

.macro famistudio_set_exp_instrument ?.read_arpeggio_ptr, ?.init_envelopes, ?.pitch_env, ?.pitch_overriden
.define .chan_idx "famistudio_r1"
.define .tmp_x    "famistudio_r2"
.define .ptr      "famistudio_ptr0"

    sty *.chan_idx

    famistudio_get_exp_inst_ptr

    ; Volume envelope
    lda [*.ptr],y
    sta famistudio_env_addr_lo,x
    iny
    lda [*.ptr],y
    iny
    sta famistudio_env_addr_hi,x
    inx

    ; Arpeggio envelope
    .if FAMISTUDIO_USE_ARPEGGIO
    stx *.tmp_x
    ldx *.chan_idx
    lda famistudio_chn_env_override,x ; Check if its overriden by arpeggio.
    lsr a
    ldx *.tmp_x
    bcc .read_arpeggio_ptr 
    iny ; Instrument arpeggio is overriden by arpeggio, dont touch!
    jmp .init_envelopes
    .endif

.read_arpeggio_ptr:
    lda [*.ptr],y
    sta famistudio_env_addr_lo,x
    iny
    lda [*.ptr],y
    sta famistudio_env_addr_hi,x
    jmp .init_envelopes

.init_envelopes:
    iny
    ; Initialize volume + arpeggio envelopes.
    lda #1
    sta famistudio_env_ptr-1,x ; Reset volume envelope pointer to 1 (volume have releases point in index 0)
    lda #0
    sta famistudio_env_repeat-1,x
    sta famistudio_env_repeat,x
    sta famistudio_env_ptr,x

    ; Pitch envelopes.
    ldx *.chan_idx
    .if FAMISTUDIO_USE_VIBRATO
    lda famistudio_chn_env_override,x ; Instrument pitch is overriden by vibrato, dont touch!
    bpl .pitch_env
    iny
    iny
    bne .pitch_overriden
    .endif

.pitch_env:
    dex
    dex ; Noise + DPCM dont have pitch envelopes             
    lda #1
    sta famistudio_pitch_env_ptr,x ; Reset pitch envelope pointert to 1 (pitch envelope have relative/absolute flag in the first byte)
    lda #0
    sta famistudio_pitch_env_repeat,x
    sta famistudio_pitch_env_value_lo,x
    sta famistudio_pitch_env_value_hi,x
    lda [*.ptr],y
    sta famistudio_pitch_env_addr_lo,x
    iny
    lda [*.ptr],y
    sta famistudio_pitch_env_addr_hi,x
    iny

.pitch_overriden:
    ldx *.chan_idx
.endm

    .endif

    .if FAMISTUDIO_EXP_VRC7

;======================================================================================================================
; FAMISTUDIO_SET_VRC7_INSTRUMENT (internal)
;
; Internal function to set a VRC7 instrument for a given channel. Will load custom patch if needed.
;
; [in] x: first envelope index for this channel.
; [in] y: channel index
; [in] a: instrument index.
;======================================================================================================================

famistudio_set_vrc7_instrument:

.ptr      = famistudio_ptr0
.chan_idx = famistudio_r1

    famistudio_set_exp_instrument

    lda famistudio_chn_inst_changed-FAMISTUDIO_FIRST_EXP_INST_CHANNEL,x
    beq .done

    lda [*.ptr],y
    sta famistudio_chn_vrc7_patch-FAMISTUDIO_VRC7_CH0_IDX, x
    bne .done

    .read_custom_patch:
    ldx #0
    iny
    iny
    .read_patch_loop:
        stx FAMISTUDIO_VRC7_REG_SEL
        jsr famistudio_vrc7_wait_reg_select
        lda [*.ptr],y
        iny
        sta FAMISTUDIO_VRC7_REG_WRITE
        jsr famistudio_vrc7_wait_reg_write
        inx
        cpx #8
        bne .read_patch_loop

    .done:
    ldx *.chan_idx
    rts
    .endif

    .if FAMISTUDIO_EXP_S5B
;======================================================================================================================
; FAMISTUDIO_SET_S5B_INSTRUMENT (internal)
;
; Internal function to set a S5B instrument. 
;
; [in] x: first envelope index for this channel.
; [in] y: channel index
; [in] a: instrument index.
;======================================================================================================================
famistudio_set_s5b_instrument:
.ptr        = famistudio_ptr0
.chan_idx   = famistudio_r1
    famistudio_set_exp_instrument

    lda famistudio_channel_env,x
    tax

    .mixer:
    sec

    .loop:
        lda [*.ptr],y
        sta famistudio_env_addr_lo+FAMISTUDIO_ENV_MIXER_IDX_OFF,x
        iny
        lda [*.ptr],y
        sta famistudio_env_addr_hi+FAMISTUDIO_ENV_MIXER_IDX_OFF,x
        lda #0
        sta famistudio_env_repeat+FAMISTUDIO_ENV_MIXER_IDX_OFF,x
        sta famistudio_env_ptr+FAMISTUDIO_ENV_MIXER_IDX_OFF,x
        sta famistudio_env_value+FAMISTUDIO_ENV_MIXER_IDX_OFF,x
        bcc .done
        clc
        inx
        iny
        bcc .loop

    .done:

    ldx *.chan_idx
    rts
    .endif
    .if (FAMISTUDIO_EXP_EPSM)

;======================================================================================================================
; FAMISTUDIO_SET_EPSM_INSTRUMENT (internal)
;
; Internal function to set a EPSM instrument for a given channel
;
; [in] x: first envelope index for this channel.
; [in] y: channel index
; [in] a: instrument index.
;======================================================================================================================
.macro famistudio_epsm_write_patch_reg select, write, ?.loop_main_patch, ?.loop_extra_patch
    ldx #0
.loop_main_patch:
        lda famistudio_epsm_register_order,x
        clc
        adc *.reg_offset
        sta select
        lda [*.ptr],y
        sta write
        iny
        inx
        ; we have 4 bytes in the instrument_exp instead of padding. The rest is in ex_patch
        cpx #4
        bne .loop_main_patch
    ; load bytes 4-30 from the extra patch data pointer
    ldy #0
.loop_extra_patch:
        lda famistudio_epsm_register_order,x
        clc
        adc *.reg_offset
        sta select
        lda [*.ex_patch],y
        sta write
        iny
        inx
        cpx #30
        bne .loop_extra_patch
.endm

;======================================================================================================================
; FAMISTUDIO_SET_EPSM_INSTRUMENT (internal)
;
; Internal function to set a EPSM instrument. 
;
; [in] x: first envelope index for this channel.
; [in] y: channel index
; [in] a: instrument index.
;======================================================================================================================

famistudio_set_epsm_instrument:

.ptr        = famistudio_ptr0
.ex_patch   = famistudio_ptr1
.reg_offset = famistudio_r0
.chan_idx   = famistudio_r1

    famistudio_set_exp_instrument

    ; after the volume pitch and arp env pointers, we have a pointer to the rest of the patch data.
	; increase y and go past noise and mixer envelope indexes
	iny
	iny
	iny
	iny
    lda [*.ptr],y
    sta *.ex_patch
    iny
    lda [*.ptr],y
    sta *.ex_patch+1
    iny

    ; channels 0-2 [square] do not need any further handling since they do not support patches
    lda *.chan_idx
    cmp #FAMISTUDIO_EPSM_CHAN_FM_START
    bcs .not_square_channel
        dey
        dey
        dey
        dey
        dey
        dey
        lda famistudio_channel_env,x
        tax

        .noise:
        sec

        .loop:
        lda [*.ptr],y
        sta famistudio_env_addr_lo+FAMISTUDIO_ENV_MIXER_IDX_OFF,x
        iny
        lda [*.ptr],y
        sta famistudio_env_addr_hi+FAMISTUDIO_ENV_MIXER_IDX_OFF,x
        lda #0
        sta famistudio_env_repeat+FAMISTUDIO_ENV_MIXER_IDX_OFF,x
        sta famistudio_env_ptr+FAMISTUDIO_ENV_MIXER_IDX_OFF,x
        sta famistudio_env_value+FAMISTUDIO_ENV_MIXER_IDX_OFF,x
        bcc .noisedone
        clc
        inx
        iny
        bcc .loop

        .noisedone:

        ldx <.chan_idx
        rts
    .not_square_channel:

    ; Now we are dealing with either a FM or Rhythm instrument. a = channel index
    ; if we are an FM instrument then there is a offset we need to apply to the register select
    cmp #FAMISTUDIO_EPSM_CHAN_RHYTHM_START
    bmi .fm_channel
        lda *.chan_idx
        sbc #FAMISTUDIO_EPSM_CHAN_RHYTHM_START
        tax
        iny
        lda [*.ptr],y
        and #0xc0
        sta famistudio_chn_epsm_rhythm_stereo,x

        ldx *.chan_idx    
        rts
    .fm_channel:
    
    lda famistudio_chn_inst_changed-FAMISTUDIO_FIRST_EXP_INST_CHANNEL,x
    bne .continue
        ldx *.chan_idx
        rts
    
.continue:
    lda *.chan_idx
    ; FM channel 1-6, we need to look up the register select offset from the table
    sec
    sbc #FAMISTUDIO_EPSM_CHAN_FM_START
    tax
    lda famistudio_channel_epsm_chan_table,x
    sta *.reg_offset
    
        lda #FAMISTUDIO_EPSM_REG_KEY
        sta FAMISTUDIO_EPSM_REG_SEL0
        lda famistudio_epsm_channel_key_table, x
        and #0x0f ; remove trigger
        sta FAMISTUDIO_EPSM_REG_WRITE0
    
    ; Now we need to store the algorithm and 1st operator volume for later use
        lda [*.ptr],y
        and #0x07
        sta famistudio_chn_epsm_alg,x ;store algorithm
        iny
        lda [*.ptr],y
        sta famistudio_chn_epsm_fm_stereo ,x
        iny
        iny
        lda [*.ptr],y
        sta famistudio_chn_epsm_vol_op1,x
        dey
        dey
        dey
    ; Now if we are channels 1-3 then we use .reg_set_0, otherwise for 4-6 its reg set 1
    lda *.chan_idx
    cmp #FAMISTUDIO_EPSM_CH6_IDX
    bpl .reg_set_1

    .reg_set_0:
        famistudio_epsm_write_patch_reg FAMISTUDIO_EPSM_REG_SEL0, FAMISTUDIO_EPSM_REG_WRITE0
    jmp .last_reg

    .reg_set_1:
        famistudio_epsm_write_patch_reg FAMISTUDIO_EPSM_REG_SEL1, FAMISTUDIO_EPSM_REG_WRITE1
    
    .last_reg:
        lda famistudio_epsm_register_order,x
        clc
        adc *.reg_offset
        sta FAMISTUDIO_EPSM_REG_SEL0
        lda [*.ex_patch],y
        sta FAMISTUDIO_EPSM_REG_WRITE0
        
        lda *.chan_idx
        sbc #(FAMISTUDIO_EPSM_CHAN_FM_START - 1) ; Carry is not set, so - 1.
        tax
        ldy #6
        lda [*.ex_patch],y
        sta famistudio_chn_epsm_vol_op2,x
        ldy #13
        lda [*.ex_patch],y
        sta famistudio_chn_epsm_vol_op3,x
        ldy #20 
        lda [*.ex_patch],y
        sta famistudio_chn_epsm_vol_op4,x
    .done:        
    ldx *.chan_idx
    rts
    
    .endif

    .if FAMISTUDIO_EXP_FDS

;======================================================================================================================
; FAMISTUDIO_SET_FDS_INSTRUMENT (internal)
;
; Internal function to set a FDS instrument. Will upload the wave and modulation envelope if needed.
;
; [in] x: first envelope index for this channel.
; [in] y: channel index
; [in] a: instrument index.
;======================================================================================================================

famistudio_set_fds_instrument:

.ptr        = famistudio_ptr0
.wave_ptr   = famistudio_ptr1
.master_vol = famistudio_r1
.tmp_y      = famistudio_r2

    famistudio_set_exp_instrument

    lda #0
    sta FAMISTUDIO_FDS_SWEEP_BIAS

    lda famistudio_chn_inst_changed-FAMISTUDIO_FIRST_EXP_INST_CHANNEL+FAMISTUDIO_FDS_CH0_IDX
    bne .write_fds_wave

    iny ; Skip master volume + wave + mod envelope.
    iny
    iny
    iny
    iny

    jmp .load_mod_param

    .write_fds_wave:

        lda [*.ptr],y
        sta *.master_vol
        iny

        ora #0x80
        sta FAMISTUDIO_FDS_VOL ; Enable wave RAM write

        ; FDS Waveform
        lda [*.ptr],y
        sta *.wave_ptr+0
        iny
        lda [*.ptr],y
        sta *.wave_ptr+1
        iny
        sty *.tmp_y

        ldy #0
        .wave_loop:
            lda [*.wave_ptr],y
            sta FAMISTUDIO_FDS_WAV_START,y
            iny
            cpy #64
            bne .wave_loop

        lda #0x80
        sta FAMISTUDIO_FDS_MOD_HI ; Need to disable modulation before writing.
        lda *.master_vol
        sta FAMISTUDIO_FDS_VOL ; Disable RAM write.
        lda #0
        sta FAMISTUDIO_FDS_SWEEP_BIAS

        ; FDS Modulation
        ldy *.tmp_y
        lda [*.ptr],y
        sta *.wave_ptr+0
        iny
        lda [*.ptr],y
        sta *.wave_ptr+1
        iny
        sty *.tmp_y

        ldy #0
        .mod_loop:
            lda [*.wave_ptr],y
            sta FAMISTUDIO_FDS_MOD_TABLE
            iny
            cpy #32
            bne .mod_loop

        lda #0
        sta famistudio_chn_inst_changed-FAMISTUDIO_FIRST_EXP_INST_CHANNEL+FAMISTUDIO_FDS_CH0_IDX

        ldy *.tmp_y

    .load_mod_param:

        .check_mod_speed:
            bit famistudio_fds_override_flags
            bmi .mod_speed_overriden

            .load_mod_speed:
                lda [*.ptr],y
                sta famistudio_fds_mod_speed+0
                iny
                lda [*.ptr],y
                sta famistudio_fds_mod_speed+1
                jmp .check_mod_depth

            .mod_speed_overriden:
                iny

        .check_mod_depth:
            iny
            bit famistudio_fds_override_flags
            bvs .mod_depth_overriden

            .load_mod_depth:
                lda [*.ptr],y
                sta famistudio_fds_mod_depth

            .mod_depth_overriden:
                iny
                lda [*.ptr],y
                sta famistudio_fds_mod_delay

    ldx #FAMISTUDIO_FDS_CH0_IDX
    rts
    .endif

    .if FAMISTUDIO_EXP_N163

famistudio_n163_wave_table:
    .byte FAMISTUDIO_N163_REG_WAVE - 0x00
    .byte FAMISTUDIO_N163_REG_WAVE - 0x08
    .byte FAMISTUDIO_N163_REG_WAVE - 0x10
    .byte FAMISTUDIO_N163_REG_WAVE - 0x18
    .byte FAMISTUDIO_N163_REG_WAVE - 0x20
    .byte FAMISTUDIO_N163_REG_WAVE - 0x28
    .byte FAMISTUDIO_N163_REG_WAVE - 0x30
    .byte FAMISTUDIO_N163_REG_WAVE - 0x38

;======================================================================================================================
; FAMISTUDIO_UPDATE_N163_WAVE (internal)
;
; Internal function to upload the waveform (if needed) of an N163 instrument. 
;
; [in] y: N163 channel idx (0,1,2,3,4,5,6,7)
;======================================================================================================================

famistudio_update_n163_wave:
    
.ptr           = famistudio_ptr0
.wave_ptr      = famistudio_ptr1
.n163_chan_idx = famistudio_r0 
.wave_pos      = famistudio_r1
.wave_len      = famistudio_r2

    lda famistudio_n163_env_table, y
    tax 

    ; See if the wave index has changed.
    lda famistudio_env_value+FAMISTUDIO_ENV_N163_WAVE_IDX_OFF,x
    cmp famistudio_chn_n163_wave_index,y
    beq .done

    ; Retrieve the instrument pointer.
    sta famistudio_chn_n163_wave_index,y
    tya
    tax
    lda famistudio_chn_instrument+FAMISTUDIO_N163_CH0_IDX,y
    famistudio_get_exp_inst_ptr

    lda famistudio_n163_wave_table, x
    sta FAMISTUDIO_N163_ADDR

    ; Wave position
    tya
    adc #8 ; Carry is clear here.
    tay
    lda [*.ptr],y
    sta *.wave_pos
    sta FAMISTUDIO_N163_DATA
    iny

    ; Wave length
    lda [*.ptr],y
    lsr a
    sta *.wave_len
    lda #0x80 ; (128 - wave length / 2) * 2 == 256 - wave length
    sec
    sbc *.wave_len
    asl a
    sta famistudio_chn_n163_wave_len, x
    iny

    ; Load the wave table pointer.
    lda [*.ptr],y
    sta *.wave_ptr+0
    iny
    lda [*.ptr],y
    sta *.wave_ptr+1

    ; Load the pointer for the current wave in the table.
    lda famistudio_chn_n163_wave_index,x
    asl a
    tay
    lda [*.wave_ptr],y
    sta *.ptr+0
    iny
    lda [*.wave_ptr],y
    sta *.ptr+1

    ; Upload to N163
    ldy #0
    lda *.wave_pos
    lsr a
    ora #0x80
    sta FAMISTUDIO_N163_ADDR
    ldy #0
    .wave_loop:
        lda [*.ptr],y
        sta FAMISTUDIO_N163_DATA
        iny
        cpy *.wave_len
        bne .wave_loop

    txa
    tay

    .done:
    rts

;======================================================================================================================
; FAMISTUDIO_SET_N163_INSTRUMENT (internal)
;
; Internal function to set a N163 instrument.
;
; [in] x: first envelope index for this channel.
; [in] y: channel index
; [in] a: instrument index.
;======================================================================================================================

famistudio_set_n163_instrument:

.ptr      = famistudio_ptr0
.chan_idx = famistudio_r1

    famistudio_set_exp_instrument

    ; Load the wave index envelope, x contains the channel index.
    lda famistudio_channel_env,x
    tax
    lda [*.ptr],y
    sta famistudio_env_addr_lo+FAMISTUDIO_ENV_N163_WAVE_IDX_OFF,x
    iny
    lda [*.ptr],y
    sta famistudio_env_addr_hi+FAMISTUDIO_ENV_N163_WAVE_IDX_OFF,x
    iny
    lda #0
    sta famistudio_env_repeat+FAMISTUDIO_ENV_N163_WAVE_IDX_OFF,x
    lda #1 ; Index 0 is release point, so envelope starts at 1.
    sta famistudio_env_ptr+FAMISTUDIO_ENV_N163_WAVE_IDX_OFF,x

    ; Clear wave index to -1 to force reload.
    lda #0xff
    ldx *.chan_idx
    sta famistudio_chn_n163_wave_index-FAMISTUDIO_N163_CH0_IDX, x
    rts

    .endif

;======================================================================================================================
; FAMISTUDIO_UPDATE_CHANNEL (internal)
;
; Advances the song by one frame for a given channel. If a new note or effect(s) are found, they will be processed.
;
; [in]  x: channel index
; [out] z: non-zero if we triggered a new note.
;======================================================================================================================

famistudio_update_channel:

.chan_idx         = famistudio_r0
.tmp_slide_from   = famistudio_r1
.tmp_slide_idx    = famistudio_r1
.tmp_duty_cycle   = famistudio_r1
.tmp_ptr_lo       = famistudio_r1
.tmp_y1           = famistudio_r1
.update_flags     = famistudio_r2 ; bit 7 = no attack, bit 6 = has set delayed cut. Non-zero at end if new note.
.slide_delta_lo   = famistudio_ptr1_hi
.tmp_y2           = famistudio_ptr1_lo
.channel_data_ptr = famistudio_ptr0
.opcode_jmp_ptr   = famistudio_ptr1
.tempo_env_ptr    = famistudio_ptr1
.env_ptr          = famistudio_ptr1

    lda famistudio_chn_repeat,x
    beq .famistudio_update_channel_no_repeat
    dec famistudio_chn_repeat,x
    lda #0
    rts

.famistudio_update_channel_no_repeat:
    lda famistudio_chn_ptr_lo,x
    sta *.channel_data_ptr+0
    lda famistudio_chn_ptr_hi,x
    sta *.channel_data_ptr+1
    ldy #0
    sty *.update_flags
    stx *.chan_idx    

.famistudio_update_channel_read_byte:
    lda [*.channel_data_ptr],y
    iny

; 0x80 to 0xff = sequence of empty notes (up to 64) or instrument changes (up to 64)
.check_negative: 
    ora #0
    bmi .empty_notes_or_instrument_change

; 0x00 to 0x3f = notes from C1 to D6 (most common notes, same as FT2 range)
; 0x40 to 0x6f = opcodes for various things.
.check_regular_note:
    cmp #0x40
    bcc .common_note

    .if FAMISTUDIO_USE_VOLUME_TRACK
; 0x70 to 0x7f = volume change 
.check_volume_track:
    cmp #0x70
    bcc .jmp_to_opcode

.volume_track:    
    and #0x0f
    asl a
    asl a
    asl a
    asl a
    sta famistudio_chn_volume_track,x
    bcc .famistudio_update_channel_read_byte
    .endif

.jmp_to_opcode:
    and #0x3f
    tax
    lda .famistudio_opcode_jmp_lo,x
    sta *.opcode_jmp_ptr+0
    lda .famistudio_opcode_jmp_hi,x
    sta *.opcode_jmp_ptr+1
    ldx *.chan_idx
    jmp [*.opcode_jmp_ptr]

.empty_notes_or_instrument_change:
    and #0x7f
    lsr a
    bcs .set_repeat
    asl a
    asl a
    sta famistudio_chn_instrument,x ; Store instrument number*4

    .if FAMISTUDIO_EXP_N163 | FAMISTUDIO_EXP_VRC7 | FAMISTUDIO_EXP_FDS | FAMISTUDIO_EXP_EPSM
    cpx #FAMISTUDIO_FIRST_EXP_INST_CHANNEL
    bcc .famistudio_update_channel_read_byte
    lda #1
    sta famistudio_chn_inst_changed-FAMISTUDIO_FIRST_EXP_INST_CHANNEL, x
    .endif
    jmp .famistudio_update_channel_read_byte 

.set_repeat:
    sta famistudio_chn_repeat,x ; Set up repeat counter
    bcs .done 

.common_note:
    cmp #0
    beq .play_note
        adc #11 ; Carry is set here.

.play_note:    
    sta famistudio_chn_note,x ; Store note code

    .if FAMISTUDIO_USE_SLIDE_NOTES
.clear_previous_slide:
    lda famistudio_channel_to_slide,x ; Clear any previous slide on new note.
    bmi .cancel_delayed_cut
    tax
    lda #0
    sta famistudio_slide_step,x
    ldx *.chan_idx
    .endif

.cancel_delayed_cut:
    .if FAMISTUDIO_USE_FAMITRACKER_DELAYED_NOTES_OR_CUTS
    ; Any note with an attack clears any pending delayed cut, unless it was set during this update (flags bit 6).
    bit *.update_flags
    bvs .check_stop_note 
    lda #0xff
    sta famistudio_chn_cut_delay,x
    .endif

.check_stop_note:
    lda famistudio_chn_note,x
    beq .check_dpcm_channel
.check_no_attack:
    bit *.update_flags
    bpl .set_final_update_flags
    lda #0
    beq .set_final_update_flags
.check_dpcm_channel:    
    .if FAMISTUDIO_CFG_DPCM_SUPPORT
    cpx #4 ; DPCM always has attack, even on stop notes.
    bne .set_final_update_flags
    txa 
    .endif
.set_final_update_flags:
    sta *.update_flags

    .if FAMISTUDIO_EXP_VRC7 | FAMISTUDIO_EXP_EPSM
.set_vrc7_triggers:
    cmp #0
    beq .done
    .if FAMISTUDIO_EXP_VRC7
    cpx #FAMISTUDIO_VRC7_CH0_IDX
    bcc .done
    lda #1
    sta famistudio_chn_vrc7_trigger-FAMISTUDIO_VRC7_CH0_IDX,x ; Set trigger flag for VRC7
    .endif
.set_epsm_trigger:
    .if FAMISTUDIO_EXP_EPSM
    cpx #FAMISTUDIO_EPSM_CHAN_FM_START
    bcc .done
    lda #1
    sta famistudio_chn_epsm_trigger-FAMISTUDIO_EPSM_CHAN_FM_START,x ; Set trigger flag for EPSM
    .endif
    .endif

.done:
    lda famistudio_chn_ref_len,x ; Check reference row counter
    beq .flush_y                  ; If it is zero, there is no reference
    dec famistudio_chn_ref_len,x ; Decrease row counter
    bne .flush_y

    lda famistudio_chn_return_lo,x ; End of a reference, return to previous pointer
    sta famistudio_chn_ptr_lo,x
    lda famistudio_chn_return_hi,x
    sta famistudio_chn_ptr_hi,x
    lda *.update_flags ; Reload to get correct flags.
    rts

.flush_y:

    clc
    tya
    adc *.channel_data_ptr+0
    sta famistudio_chn_ptr_lo,x
    lda #0
    adc *.channel_data_ptr+1
    sta famistudio_chn_ptr_hi,x
    lda *.update_flags ; Reload to get correct flags.
    rts

.opcode_extended_note:
    lda [*.channel_data_ptr],y
    iny
    jmp .play_note

.opcode_set_reference:
    clc ; Remember return address+3
    tya
    adc #3
    adc *.channel_data_ptr+0
    sta famistudio_chn_return_lo,x
    lda *.channel_data_ptr+1
    adc #0
    sta famistudio_chn_return_hi,x
    lda [*.channel_data_ptr],y ; Read length of the reference (how many rows)
    sta famistudio_chn_ref_len,x
    iny
    lda [*.channel_data_ptr],y ; Read 16-bit absolute address of the reference
    sta *.tmp_ptr_lo
    iny
    lda [*.channel_data_ptr],y
    sta *.channel_data_ptr+1
    lda *.tmp_ptr_lo
    sta *.channel_data_ptr+0
    ldy #0
    jmp .famistudio_update_channel_read_byte

.opcode_loop:
    lda [*.channel_data_ptr],y
    sta *.tmp_ptr_lo
    iny
    lda [*.channel_data_ptr],y
    sta *.channel_data_ptr+1
    lda *.tmp_ptr_lo
    sta *.channel_data_ptr+0
    ldy #0
    jmp .famistudio_update_channel_read_byte

.opcode_disable_attack:
    lda #0x80
    ora *.update_flags
    sta *.update_flags
    jmp .famistudio_update_channel_read_byte 

    .if FAMISTUDIO_USE_RELEASE_NOTES  
.jump_to_release_envelope:
    lda famistudio_env_addr_lo,x ; Load envelope data address into temp
    sta *.env_ptr+0
    lda famistudio_env_addr_hi,x
    sta *.env_ptr+1
    
    sty *.tmp_y1
    ldy #0
    lda [*.env_ptr],y ; Read first byte of the envelope data, this contains the release index.
    beq .env_has_no_release

    sta famistudio_env_ptr,x
    lda #0
    sta famistudio_env_repeat,x ; Need to reset envelope repeat to force update.

.env_has_no_release:
    ldx *.chan_idx
    ldy *.tmp_y1
    rts

    .if FAMISTUDIO_EXP_VRC7
.opcode_vrc7_release_note:
    lda #0x80
    sta famistudio_chn_vrc7_trigger-FAMISTUDIO_VRC7_CH0_IDX,x ; Set release flag for VRC7
.endif

    .if FAMISTUDIO_EXP_FDS
.opcode_fds_release_note:
    ldx #FAMISTUDIO_FDS_CH0_ENVS
    jsr .jump_to_release_envelope
    .endif

    .if FAMISTUDIO_EXP_N163
.opcode_n163_release_note:
    lda famistudio_channel_env,x 
    tax 
    inx ; +2 for FAMISTUDIO_ENV_N163_WAVE_IDX_OFF.
    inx
    jsr .jump_to_release_envelope
    .endif

    .if FAMISTUDIO_EXP_EPSM
.opcode_epsm_release_note:
    lda #0x80
    sta famistudio_chn_epsm_trigger-FAMISTUDIO_EPSM_CHAN_FM_START,x ; Set release flag for EPSM
    .endif

.opcode_release_note:
    lda famistudio_channel_to_volume_env,x ; DPCM(5) will never have releases.
    tax
    jsr .jump_to_release_envelope
    clc
    jmp .done
    .endif

    .if FAMISTUDIO_USE_FAMITRACKER_TEMPO
.opcode_famitracker_speed:
    lda [*.channel_data_ptr],y
    iny
    sta famistudio_song_speed
    jmp .famistudio_update_channel_read_byte 
    .endif

    .if FAMISTUDIO_EXP_FDS
.opcode_fds_mod_depth:    
    lda [*.channel_data_ptr],y
    iny
    sta famistudio_fds_mod_depth
    lda #0x40
    ora famistudio_fds_override_flags
    sta famistudio_fds_override_flags
    jmp .famistudio_update_channel_read_byte

.opcode_fds_mod_speed:
    lda [*.channel_data_ptr],y
    iny
    sta famistudio_fds_mod_speed+0
    lda [*.channel_data_ptr],y
    iny
    sta famistudio_fds_mod_speed+1
    lda #0x80
    ora famistudio_fds_override_flags
    sta famistudio_fds_override_flags
    jmp .famistudio_update_channel_read_byte
    .endif

    .if FAMISTUDIO_EXP_VRC6
.opcode_vrc6_saw_volume:
    lda [*.channel_data_ptr],y
    iny 
    sta famistudio_vrc6_saw_volume
    jmp .famistudio_update_channel_read_byte
    .endif

    .if FAMISTUDIO_USE_VOLUME_SLIDES
.opcode_volume_slide:
    lda [*.channel_data_ptr],y
    iny
    sta famistudio_chn_volume_slide_step, x
    lda [*.channel_data_ptr],y
    iny
    sta famistudio_chn_volume_slide_target, x
    jmp .famistudio_update_channel_read_byte
    .endif

    .if FAMISTUDIO_USE_DELTA_COUNTER
.opcode_dmc_counter:
    lda [*.channel_data_ptr],y
    bmi .set_immediately
.store_for_later:
    sta famistudio_dmc_delta_counter
    bpl .inc_and_return
.set_immediately:
    and #0x7f
    sta FAMISTUDIO_APU_DMC_RAW
.inc_and_return:
    iny
    jmp .famistudio_update_channel_read_byte 
    .endif

    .if FAMISTUDIO_USE_PHASE_RESET
.opcode_phase_reset:
    lda famistudio_channel_to_phase_reset_mask, x
    ora famistudio_phase_reset
    sta famistudio_phase_reset
    jmp .famistudio_update_channel_read_byte     

    .if FAMISTUDIO_EXP_N163
.opcode_n163_phase_reset:
    lda famistudio_channel_to_phase_reset_mask, x
    ora famistudio_phase_reset_n163
    sta famistudio_phase_reset_n163
    jmp .famistudio_update_channel_read_byte     
    .endif    
    .endif

    .if FAMISTUDIO_USE_PITCH_TRACK
.opcode_fine_pitch:
    lda famistudio_channel_to_pitch_env,x
    tax
    lda [*.channel_data_ptr],y
    iny
    sta famistudio_pitch_env_fine_value,x
    ldx *.chan_idx
    jmp .famistudio_update_channel_read_byte 
    .endif

    .if FAMISTUDIO_USE_VIBRATO
.opcode_clear_pitch_override_flag:
    lda #0x7f
    and famistudio_chn_env_override,x
    sta famistudio_chn_env_override,x
    jmp .famistudio_update_channel_read_byte

.opcode_override_pitch_envelope:
    lda #0x80
    ora famistudio_chn_env_override,x
    sta famistudio_chn_env_override,x
    lda famistudio_channel_to_pitch_env,x
    tax
    lda [*.channel_data_ptr],y
    iny
    sta famistudio_pitch_env_addr_lo,x
    lda [*.channel_data_ptr],y
    iny
    sta famistudio_pitch_env_addr_hi,x
    lda #0
    sta famistudio_pitch_env_repeat,x
    lda #1
    sta famistudio_pitch_env_ptr,x
    ldx *.chan_idx
    jmp .famistudio_update_channel_read_byte 
    .endif

    .if FAMISTUDIO_USE_ARPEGGIO
.opcode_clear_arpeggio_override_flag:
    lda #0xfe
    and famistudio_chn_env_override,x
    sta famistudio_chn_env_override,x
    jmp .famistudio_update_channel_read_byte

.opcode_override_arpeggio_envelope:
    lda #0x01
    ora famistudio_chn_env_override,x
    sta famistudio_chn_env_override,x
    lda famistudio_channel_to_arpeggio_env,x
    tax    
    lda [*.channel_data_ptr],y
    iny
    sta famistudio_env_addr_lo,x
    lda [*.channel_data_ptr],y
    iny
    sta famistudio_env_addr_hi,x
    lda #0
    sta famistudio_env_repeat,x ; Reset the envelope since this might be a no-attack note.
    sta famistudio_env_value,x
    sta famistudio_env_ptr,x
    ldx *.chan_idx
    jmp .famistudio_update_channel_read_byte

.opcode_reset_arpeggio:
    lda famistudio_channel_to_arpeggio_env,x
    tax
    lda #0
    sta famistudio_env_repeat,x
    sta famistudio_env_value,x
    sta famistudio_env_ptr,x
    ldx *.chan_idx
    jmp .famistudio_update_channel_read_byte
    .endif

    .if FAMISTUDIO_USE_DUTYCYCLE_EFFECT
.opcode_duty_cycle_effect:
    lda famistudio_channel_to_dutycycle,x
    tax 
    lda [*.channel_data_ptr],y
    iny
    sta famistudio_duty_cycle,x
    sta *.tmp_duty_cycle
    ldx *.chan_idx
    lda famistudio_channel_to_duty_env,x
    tax 
    lda *.tmp_duty_cycle
    sta famistudio_env_value,x
    ldx *.chan_idx
    jmp .famistudio_update_channel_read_byte
    .endif

    .if FAMISTUDIO_USE_FAMITRACKER_DELAYED_NOTES_OR_CUTS
.opcode_note_delay:
    lda [*.channel_data_ptr],y
    iny
    sta famistudio_chn_note_delay,x
    jmp .flush_y

.opcode_cut_delay:
    lda #0x40
    sta *.update_flags
    lda [*.channel_data_ptr],y
    iny
    sta famistudio_chn_cut_delay,x
    jmp .famistudio_update_channel_read_byte 
    .endif

    .ifeq FAMISTUDIO_USE_FAMITRACKER_TEMPO
.opcode_set_tempo_envelope:
    ; Load and reset the new tempo envelope.
    lda [*.channel_data_ptr],y
    iny
    sta famistudio_tempo_env_ptr_lo
    sta *.tempo_env_ptr+0
    lda [*.channel_data_ptr],y
    iny
    sta famistudio_tempo_env_ptr_hi
    sta *.tempo_env_ptr+1
    jmp .reset_tempo_env
.opcode_reset_tempo_envelope:
    lda famistudio_tempo_env_ptr_lo
    sta *.tempo_env_ptr+0 
    lda famistudio_tempo_env_ptr_hi
    sta *.tempo_env_ptr+1
.reset_tempo_env:    
    sty *.tmp_y1
    ldy #0
    sty famistudio_tempo_env_idx
    lda [*.tempo_env_ptr],y
    sta famistudio_tempo_env_counter
    ldy *.tmp_y1
    jmp .famistudio_update_channel_read_byte
    .endif

    .if FAMISTUDIO_USE_SLIDE_NOTES

    .if FAMISTUDIO_USE_NOISE_SLIDE_NOTES
.noise_slide:
    lda [*.channel_data_ptr],y ; Read slide step size
    iny
    sta famistudio_slide_step+FAMISTUDIO_NOISE_SLIDE_INDEX
    lda [*.channel_data_ptr],y ; Read slide note from
    iny
    sec
    sbc [*.channel_data_ptr],y ; Read slide note to
    sta famistudio_slide_pitch_lo+FAMISTUDIO_NOISE_SLIDE_INDEX
    bpl .positive_noise_slide
.negative_noise_slide:
    ; Sign extend.
    lda #0xff
    bmi .noise_shift
.positive_noise_slide:
    lda #0x00
.noise_shift:    
    ; Noise slides have 4-bits of fraction.
    asl famistudio_slide_pitch_lo+FAMISTUDIO_NOISE_SLIDE_INDEX
    rol a
    asl famistudio_slide_pitch_lo+FAMISTUDIO_NOISE_SLIDE_INDEX
    rol a
    asl famistudio_slide_pitch_lo+FAMISTUDIO_NOISE_SLIDE_INDEX
    rol a
    asl famistudio_slide_pitch_lo+FAMISTUDIO_NOISE_SLIDE_INDEX
    rol a
    sta famistudio_slide_pitch_hi+FAMISTUDIO_NOISE_SLIDE_INDEX
    jmp .slide_done_pos
    .endif

.opcode_slide:
    .if FAMISTUDIO_USE_NOISE_SLIDE_NOTES
    cpx #3
    beq .noise_slide
    .endif
    lda famistudio_channel_to_slide,x
    tax
    lda [*.channel_data_ptr],y ; Read slide step size
    iny
    sta famistudio_slide_step,x
    lda [*.channel_data_ptr],y ; Read slide note from
    iny 
    sty *.tmp_y2
    .if FAMISTUDIO_DUAL_SUPPORT
    clc
    adc famistudio_pal_adjust
    .endif
    sta *.tmp_slide_from
    lda [*.channel_data_ptr],y ; Read slide note to
    ldy *.tmp_slide_from       ; reload note from
    .if FAMISTUDIO_DUAL_SUPPORT
    adc famistudio_pal_adjust
    .endif
    stx *.tmp_slide_idx ; X contained the slide index.    
    tax
    .ifdef FAMISTUDIO_EXP_NOTE_START
    lda *.chan_idx
    .if FAMISTUDIO_EXP_EPSM
    cmp #FAMISTUDIO_EPSM_CHAN_FM_START
    bcs .note_table_epsm
    .endif    
    cmp #FAMISTUDIO_EXP_NOTE_START
    bcs .note_table_expansion
    .endif
    sec ; Subtract the pitch of both notes.
    lda famistudio_note_table_lsb,y
    sbc famistudio_note_table_lsb,x
    sta *.slide_delta_lo
    lda famistudio_note_table_msb,y
    sbc famistudio_note_table_msb,x
    .ifdef FAMISTUDIO_EXP_NOTE_START
    jmp .note_table_done
    .if FAMISTUDIO_EXP_EPSM
.note_table_epsm:
    lda famistudio_epsm_note_table_lsb,y
    sbc famistudio_epsm_note_table_lsb,x
    sta *.slide_delta_lo
    lda famistudio_epsm_note_table_msb,y
    sbc famistudio_epsm_note_table_msb,x
    jmp .note_table_done
    .endif
.note_table_expansion:
    lda famistudio_exp_note_table_lsb,y
    sbc famistudio_exp_note_table_lsb,x
    sta *.slide_delta_lo
    lda famistudio_exp_note_table_msb,y
    sbc famistudio_exp_note_table_msb,x
.note_table_done:
    .endif
    ldx *.tmp_slide_idx ; slide index.
    sta famistudio_slide_pitch_hi,x
    .if FAMISTUDIO_EXP_N163 | FAMISTUDIO_EXP_VRC7 | FAMISTUDIO_EXP_EPSM
        cpx #FAMISTUDIO_FIRST_POSITIVE_SLIDE_CHANNEL ; Slide #3 is the first of expansion slides.
        bcs .positive_shift
    .endif
    .negative_shift:
        lda *.slide_delta_lo
        asl a ; Shift-left, we have 1 bit of fractional slide.
        sta famistudio_slide_pitch_lo,x
        rol famistudio_slide_pitch_hi,x ; Shift-left, we have 1 bit of fractional slide.
    .if FAMISTUDIO_EXP_N163 | FAMISTUDIO_EXP_VRC7 | FAMISTUDIO_EXP_EPSM
        jmp .shift_done
    .positive_shift:
        lda *.slide_delta_lo
        sta famistudio_slide_pitch_lo,x
        ldy #FAMISTUDIO_PITCH_SHIFT
        .positive_shift_loop:
            lda famistudio_slide_pitch_hi,x
            cmp #0x80
            ror famistudio_slide_pitch_hi,x 
            ror famistudio_slide_pitch_lo,x
            dey 
            bne .positive_shift_loop
    .shift_done:
    .endif
    ldx *.chan_idx
    ldy *.tmp_y2

.slide_done_pos:
    lda [*.channel_data_ptr],y ; Re-read the target note (ugly...)
    sta famistudio_chn_note,x ; Store note code
    iny
    jmp .cancel_delayed_cut
    .endif

.opcode_invalid:

    ; If you hit this, this mean you either:
    ; - exported a song that uses FamiStudio tempo but have defined "FAMISTUDIO_USE_FAMITRACKER_TEMPO"
    ; - use delayed notes/cuts, but didnt enable "FAMISTUDIO_USE_FAMITRACKER_DELAYED_NOTES_OR_CUTS"
    ; - use vibrato effect, but didnt enable "FAMISTUDIO_USE_VIBRATO"
    ; - use arpeggiated chords, but didnt enable "FAMISTUDIO_USE_ARPEGGIO"
    ; - use fine pitches, but didnt enable "FAMISTUDIO_USE_PITCH_TRACK"
    ; - use a duty cycle effect, but didnt enable "FAMISTUDIO_USE_DUTYCYCLE_EFFECT"
    ; - use slide notes, but didnt enable "FAMISTUDIO_USE_SLIDE_NOTES"
    ; - use volume slides, but didnt enable "FAMISTUDIO_USE_VOLUME_SLIDES"
    ; - use DMC counter effect, but didnt enable "FAMISTUDIO_USE_DELTA_COUNTER"
    ; - use a Phase Reset efect, but didnt enable the "FAMISTUDIO_USE_PHASE_RESET"

    brk 

.famistudio_opcode_jmp_lo:
        .byte <(.opcode_extended_note)                ; 0x40
        .byte <(.opcode_set_reference)                ; 0x41
        .byte <(.opcode_loop)                         ; 0x42
        .byte <(.opcode_disable_attack)               ; 0x43
    .if FAMISTUDIO_USE_RELEASE_NOTES    
        .byte <(.opcode_release_note)                 ; 0x44
    .else
        .byte <(.opcode_invalid)                      ; 0x44
    .endif
    .if FAMISTUDIO_USE_FAMITRACKER_TEMPO    
        .byte <(.opcode_famitracker_speed)            ; 0x45
    .else
        .byte <(.opcode_invalid)                      ; 0x45
    .endif
    .if FAMISTUDIO_USE_FAMITRACKER_DELAYED_NOTES_OR_CUTS
        .byte <(.opcode_note_delay)                   ; 0x46
        .byte <(.opcode_cut_delay)                    ; 0x47
    .endif
    .ifeq FAMISTUDIO_USE_FAMITRACKER_TEMPO
        .byte <(.opcode_set_tempo_envelope)           ; 0x46
        .byte <(.opcode_reset_tempo_envelope)         ; 0x47
    .endif
    .if FAMISTUDIO_USE_FAMITRACKER_TEMPO & ~FAMISTUDIO_USE_FAMITRACKER_DELAYED_NOTES_OR_CUTS
        .byte <(.opcode_invalid)                      ; 0x46
        .byte <(.opcode_invalid)                      ; 0x47
    .endif
    .if FAMISTUDIO_USE_VIBRATO    
        .byte <(.opcode_override_pitch_envelope)      ; 0x48
        .byte <(.opcode_clear_pitch_override_flag)    ; 0x49
    .else
        .byte <(.opcode_invalid)                      ; 0x48
        .byte <(.opcode_invalid)                      ; 0x49
    .endif   
    .if FAMISTUDIO_USE_ARPEGGIO
        .byte <(.opcode_override_arpeggio_envelope)   ; 0x4a
        .byte <(.opcode_clear_arpeggio_override_flag) ; 0x4b
        .byte <(.opcode_reset_arpeggio)               ; 0x4c
    .else
        .byte <(.opcode_invalid)                      ; 0x4a
        .byte <(.opcode_invalid)                      ; 0x4b
        .byte <(.opcode_invalid)                      ; 0x4c
    .endif    
    .if FAMISTUDIO_USE_PITCH_TRACK
        .byte <(.opcode_fine_pitch)                   ; 0x4d
    .else
        .byte <(.opcode_invalid)                      ; 0x4d
    .endif    
    .if FAMISTUDIO_USE_DUTYCYCLE_EFFECT
        .byte <(.opcode_duty_cycle_effect)            ; 0x4e
    .else
        .byte <(.opcode_invalid)                      ; 0x4e
    .endif    
    .if FAMISTUDIO_USE_SLIDE_NOTES
        .byte <(.opcode_slide)                        ; 0x4f
    .else
        .byte <(.opcode_invalid)                      ; 0x4f
    .endif    
    .if FAMISTUDIO_USE_VOLUME_SLIDES
        .byte <(.opcode_volume_slide)                 ; 0x50
    .else
        .byte <(.opcode_invalid)                      ; 0x50
    .endif
    .if FAMISTUDIO_USE_DELTA_COUNTER
        .byte <(.opcode_dmc_counter)                  ; 0x51
    .else
        .byte <(.opcode_invalid)                      ; 0x51
    .endif
    .if FAMISTUDIO_USE_PHASE_RESET
        .byte <(.opcode_phase_reset)                  ; 0x52
    .else
        .byte <(.opcode_invalid)                      ; 0x52
    .endif
    .ifeq FAMISTUDIO_EXP_NONE                            ; Begin expansion-specific opcodes
    .if FAMISTUDIO_EXP_VRC6
        .byte <(.opcode_vrc6_saw_volume)              ; 0x53
    .else
        .byte <(.opcode_invalid)                      ; 0x53
    .endif
    .if FAMISTUDIO_EXP_VRC7 & FAMISTUDIO_USE_RELEASE_NOTES
        .byte <(.opcode_vrc7_release_note)            ; 0x54
    .else
        .byte <(.opcode_invalid)                      ; 0x54
    .endif
    .if FAMISTUDIO_EXP_FDS
        .byte <(.opcode_fds_mod_speed)                ; 0x55
        .byte <(.opcode_fds_mod_depth)                ; 0x56
    .else
        .byte <(.opcode_invalid)                      ; 0x55
        .byte <(.opcode_invalid)                      ; 0x56
    .endif
    .if FAMISTUDIO_EXP_FDS & FAMISTUDIO_USE_RELEASE_NOTES
        .byte <(.opcode_fds_release_note)             ; 0x57
    .else
        .byte <(.opcode_invalid)                      ; 0x57
    .endif
    .if FAMISTUDIO_EXP_N163 & FAMISTUDIO_USE_RELEASE_NOTES
        .byte <(.opcode_n163_release_note)            ; 0x58
    .else
        .byte <(.opcode_invalid)                      ; 0x58
    .endif
    .if FAMISTUDIO_EXP_N163 & FAMISTUDIO_USE_PHASE_RESET
        .byte <(.opcode_n163_phase_reset)             ; 0x59
    .else
        .byte <(.opcode_invalid)                      ; 0x59
    .endif
    .if FAMISTUDIO_EXP_EPSM & FAMISTUDIO_USE_RELEASE_NOTES
        .byte <(.opcode_epsm_release_note)            ; 0x5a
    .else
        .byte <(.opcode_invalid)                      ; 0x5a
    .endif
    .endif

.famistudio_opcode_jmp_hi:
        .byte >(.opcode_extended_note)                ; 0x40
        .byte >(.opcode_set_reference)                ; 0x41
        .byte >(.opcode_loop)                         ; 0x42
        .byte >(.opcode_disable_attack)               ; 0x43
    .if FAMISTUDIO_USE_RELEASE_NOTES    
        .byte >(.opcode_release_note)                 ; 0x44
    .else
        .byte >(.opcode_invalid)                      ; 0x44
    .endif
    .if FAMISTUDIO_USE_FAMITRACKER_TEMPO    
        .byte >(.opcode_famitracker_speed)            ; 0x45
    .else
        .byte >(.opcode_invalid)                      ; 0x45
    .endif
    .if FAMISTUDIO_USE_FAMITRACKER_DELAYED_NOTES_OR_CUTS
        .byte >(.opcode_note_delay)                   ; 0x46
        .byte >(.opcode_cut_delay)                    ; 0x47
    .endif
    .ifeq FAMISTUDIO_USE_FAMITRACKER_TEMPO
        .byte >(.opcode_set_tempo_envelope)           ; 0x46
        .byte >(.opcode_reset_tempo_envelope)         ; 0x47
    .endif
    .if FAMISTUDIO_USE_FAMITRACKER_TEMPO & ~FAMISTUDIO_USE_FAMITRACKER_DELAYED_NOTES_OR_CUTS
        .byte >(.opcode_invalid)                      ; 0x46
        .byte >(.opcode_invalid)                      ; 0x47
    .endif    
    .if FAMISTUDIO_USE_VIBRATO    
        .byte >(.opcode_override_pitch_envelope)      ; 0x48
        .byte >(.opcode_clear_pitch_override_flag)    ; 0x49
    .else
        .byte >(.opcode_invalid)                      ; 0x48
        .byte >(.opcode_invalid)                      ; 0x49
    .endif   
    .if FAMISTUDIO_USE_ARPEGGIO
        .byte >(.opcode_override_arpeggio_envelope)   ; 0x4a
        .byte >(.opcode_clear_arpeggio_override_flag) ; 0x4b
        .byte >(.opcode_reset_arpeggio)               ; 0x4c
    .else
        .byte >(.opcode_invalid)                      ; 0x4a
        .byte >(.opcode_invalid)                      ; 0x4b
        .byte >(.opcode_invalid)                      ; 0x4c
    .endif    
    .if FAMISTUDIO_USE_PITCH_TRACK
        .byte >(.opcode_fine_pitch)                   ; 0x4d
    .else
        .byte >(.opcode_invalid)                      ; 0x4d
    .endif    
    .if FAMISTUDIO_USE_DUTYCYCLE_EFFECT
        .byte >(.opcode_duty_cycle_effect)            ; 0x4e
    .else
        .byte >(.opcode_invalid)                      ; 0x4e
    .endif    
    .if FAMISTUDIO_USE_SLIDE_NOTES
        .byte >(.opcode_slide)                        ; 0x4f
    .else
        .byte >(.opcode_invalid)                      ; 0x4f
    .endif    
    .if FAMISTUDIO_USE_VOLUME_SLIDES
        .byte >(.opcode_volume_slide)                 ; 0x50
    .else
        .byte >(.opcode_invalid)                      ; 0x50
    .endif
    .if FAMISTUDIO_USE_DELTA_COUNTER
        .byte >(.opcode_dmc_counter)                  ; 0x51
    .else
        .byte >(.opcode_invalid)                      ; 0x51
    .endif
    .if FAMISTUDIO_USE_PHASE_RESET
        .byte >(.opcode_phase_reset)                  ; 0x52
    .else
        .byte >(.opcode_invalid)                      ; 0x52
    .endif
    .ifeq FAMISTUDIO_EXP_NONE                             ; Begin expansion-specific opcodes
    .if FAMISTUDIO_EXP_VRC6
        .byte >(.opcode_vrc6_saw_volume)              ; 0x53
    .else
        .byte >(.opcode_invalid)                      ; 0x53
    .endif
    .if FAMISTUDIO_EXP_VRC7 & FAMISTUDIO_USE_RELEASE_NOTES
        .byte >(.opcode_vrc7_release_note)            ; 0x54
    .else
        .byte >(.opcode_invalid)                      ; 0x54
    .endif
    .if FAMISTUDIO_EXP_FDS
        .byte >(.opcode_fds_mod_speed)                ; 0x55
        .byte >(.opcode_fds_mod_depth)                ; 0x56
    .else
        .byte >(.opcode_invalid)                      ; 0x55
        .byte >(.opcode_invalid)                      ; 0x56
    .endif
    .if FAMISTUDIO_EXP_FDS & FAMISTUDIO_USE_RELEASE_NOTES
        .byte >(.opcode_fds_release_note)             ; 0x57
    .else
        .byte >(.opcode_invalid)                      ; 0x57
    .endif
    .if FAMISTUDIO_EXP_N163 & FAMISTUDIO_USE_RELEASE_NOTES
        .byte >(.opcode_n163_release_note)            ; 0x58
    .else
        .byte >(.opcode_invalid)                      ; 0x58
    .endif
    .if FAMISTUDIO_EXP_N163 & FAMISTUDIO_USE_PHASE_RESET
        .byte >(.opcode_n163_phase_reset)             ; 0x59
    .else
        .byte >(.opcode_invalid)                      ; 0x59
    .endif
    .if FAMISTUDIO_EXP_EPSM & FAMISTUDIO_USE_RELEASE_NOTES
        .byte >(.opcode_epsm_release_note)            ; 0x5a
    .else
        .byte >(.opcode_invalid)                      ; 0x5a
    .endif
    .endif

;======================================================================================================================
; FAMISTUDIO_SAMPLE_STOP (internal)
;
; Stop DPCM sample if it plays
;
; [in] no input params.
;======================================================================================================================

famistudio_sample_stop:

    lda #0b00001111
    sta FAMISTUDIO_APU_SND_CHN
    rts

        
    .if FAMISTUDIO_CFG_DPCM_SUPPORT

;======================================================================================================================
; FAMISTUDIO_SAMPLE_PLAY_SFX (public)
;
; Play DPCM sample with higher priority, for sound effects
;
; [in] a: Sample index, 1...63.
;======================================================================================================================

_famistudio_sfx_sample_play::

    ldx #1
    stx famistudio_dpcm_effect

sample_play:

.tmp = famistudio_r0
.sample_index = famistudio_r0
.sample_data_ptr = famistudio_ptr0

    .if FAMISTUDIO_USE_DPCM_BANKSWITCHING | FAMISTUDIO_USE_DPCM_EXTENDED_RANGE
    ; famistudio_dpcm_list + sample number * (4 or 5)
    sta *.sample_index
    ldy #0
    sty *.sample_data_ptr+1
    asl a
    rol *.sample_data_ptr+1
    asl a
    rol *.sample_data_ptr+1 ; Will clear carry
    .if FAMISTUDIO_USE_DPCM_BANKSWITCHING
    ; Multiply by 5 instead of 4.
    adc *.sample_index
    bcc .add_list_ptr
        inc *.sample_data_ptr+1 
        clc
    .add_list_ptr:
    .endif
        adc famistudio_dpcm_list_lo
        sta *.sample_data_ptr+0
        lda *.sample_data_ptr+1
        adc famistudio_dpcm_list_hi
        sta *.sample_data_ptr+1    
    .else
    asl a ; Sample number * 4, offset in the sample table
    asl a ; Carry should be clear now, we dont allow more than 63 sample mappings.
    adc famistudio_dpcm_list_lo
    sta *.sample_data_ptr+0
    lda #0
    adc famistudio_dpcm_list_hi
    sta *.sample_data_ptr+1
    .endif

.stop_dpcm:
    lda #0b00001111 ; Stop DPCM
    sta FAMISTUDIO_APU_SND_CHN

    ldy #0
    lda [*.sample_data_ptr],y ; Sample offset
    sta FAMISTUDIO_APU_DMC_START
    iny
    lda [*.sample_data_ptr],y ; Sample length
    sta FAMISTUDIO_APU_DMC_LEN
    iny
    lda [*.sample_data_ptr],y ; Pitch and loop
    sta FAMISTUDIO_APU_DMC_FREQ
    iny

    .if FAMISTUDIO_USE_DELTA_COUNTER
    lda famistudio_dmc_delta_counter
    bmi .read_dmc_initial_value
    sta FAMISTUDIO_APU_DMC_RAW
    lda #0xff
    sta famistudio_dmc_delta_counter
    bmi .start_dmc
.read_dmc_initial_value:
    .endif    

    lda [*.sample_data_ptr],y ; Initial DMC counter
    sta FAMISTUDIO_APU_DMC_RAW

.start_dmc:
    .if FAMISTUDIO_USE_DPCM_BANKSWITCHING
    iny
    lda [*.sample_data_ptr],y ; Bank number
    jsr famistudio_dpcm_bank_callback
    .endif

    lda #0b00011111 ; Start DMC
    sta FAMISTUDIO_APU_SND_CHN

    rts

;======================================================================================================================
; FAMISTUDIO_SAMPLE_PLAY_MUSIC (internal)
;
; Play DPCM sample, used by music player, could be used externally. Samples played for music have lower priority than
; samples played by SFX.
;
; [in] a: Sample index, 1...63.
;======================================================================================================================

famistudio_music_sample_play:

    ldx famistudio_dpcm_effect
    beq sample_play
    tax
    lda FAMISTUDIO_APU_SND_CHN
    and #16
    beq .not_busy
    rts

.not_busy:
    sta famistudio_dpcm_effect
    txa
    jmp sample_play

    .endif

    .if FAMISTUDIO_CFG_SFX_SUPPORT

;======================================================================================================================
; FAMISTUDIO_SFX_INIT (public)
;
; Initialize the sound effect player.
;
; [in] x: Sound effect data pointer (lo)
; [in] y: Sound effect data pointer (hi)
;======================================================================================================================

_famistudio_sfx_init::

.effect_list_ptr = famistudio_ptr0

    stx *.effect_list_ptr+0
    sty *.effect_list_ptr+1
    
    ldy #0
    
    .if FAMISTUDIO_DUAL_SUPPORT
    lda famistudio_pal_adjust ; Add 2 to the sound list pointer for PAL
    bne .ntsc
    iny
    iny
.ntsc:
    .endif
    
    lda [*.effect_list_ptr],y 
    sta famistudio_sfx_addr_lo
    iny
    lda [*.effect_list_ptr],y
    sta famistudio_sfx_addr_hi

    ldx #FAMISTUDIO_SFX_CH0 

.set_channels:
    jsr famistudio_sfx_clear_channel
    txa
    clc
    adc #FAMISTUDIO_SFX_STRUCT_SIZE
    tax
    cpx #FAMISTUDIO_SFX_STRUCT_SIZE*FAMISTUDIO_CFG_SFX_STREAMS
    bne .set_channels

    rts

;======================================================================================================================
; FAMISTUDIO_SFX_CLEAR_CHANNEL (internal)
;
; Clears output buffer of a sound effect.
;
; [in] x: Offset of the sound effect stream.
;======================================================================================================================

famistudio_sfx_clear_channel:

    lda #0
    sta famistudio_sfx_ptr_hi,x   ; This stops the effect
    sta famistudio_sfx_repeat,x
    sta famistudio_sfx_offset,x
    sta famistudio_sfx_buffer+6,x ; Mute triangle
    lda #0x30
    sta famistudio_sfx_buffer+0,x ; Mute pulse1
    sta famistudio_sfx_buffer+3,x ; Mute pulse2
    sta famistudio_sfx_buffer+9,x ; Mute noise
    rts

;======================================================================================================================
; FAMISTUDIO_SFX_PLAY (public)
;
; Plays a sound effect.
;
; [in] a: Sound effect index (0...127)
; [in] x: Offset of sound effect channel, should be FAMISTUDIO_SFX_CH0..FAMISTUDIO_SFX_CH3
;======================================================================================================================

_famistudio_sfx_play::

.effect_data_ptr = famistudio_ptr0

    asl a
    tay

    jsr famistudio_sfx_clear_channel ; Stops the effect if it plays

    lda famistudio_sfx_addr_lo
    sta *.effect_data_ptr+0
    lda famistudio_sfx_addr_hi
    sta *.effect_data_ptr+1

    lda [*.effect_data_ptr],y
    sta famistudio_sfx_ptr_lo,x
    iny
    lda [*.effect_data_ptr],y
    sta famistudio_sfx_ptr_hi,x ; This write enables the effect

    rts

;======================================================================================================================
; FAMISTUDIO_SFX_UPDATE (internal)
;
; Updates a single sound effect stream.
;
; [in] x: Offset of sound effect channel, should be FAMISTUDIO_SFX_CH0..FAMISTUDIO_SFX_CH3
;======================================================================================================================

famistudio_sfx_update:

.tmp = famistudio_r0
.tmpx = famistudio_r1
.effect_data_ptr = famistudio_ptr0

    lda famistudio_sfx_repeat,x ; Check if repeat counter is not zero
    beq .no_repeat
    dec famistudio_sfx_repeat,x ; Decrement and return
    bne .update_buf ; Just mix with output buffer

.no_repeat:
    lda famistudio_sfx_ptr_hi,x ; Check if MSB of the pointer is not zero
    bne .sfx_active
    rts ; Return otherwise, no active effect

.sfx_active:
    sta *.effect_data_ptr+1         ;load effect pointer into temp
    lda famistudio_sfx_ptr_lo,x
    sta *.effect_data_ptr+0
    ldy famistudio_sfx_offset,x
    clc

.read_byte:
    lda [*.effect_data_ptr],y ; Read byte of effect
    bmi .get_data ; If bit 7 is set, it is a register write
    beq .eof
    iny
    bne .store_repeat
    jsr .inc_sfx
.store_repeat:
    sta famistudio_sfx_repeat,x ; If bit 7 is reset, it is number of repeats
    tya
    sta famistudio_sfx_offset,x
    jmp .update_buf

.get_data:
    iny
    bne .get_data2
    jsr .inc_sfx
.get_data2:
    stx *.tmp ; It is a register write
    adc *.tmp ; Get offset in the effect output buffer
    tax
    lda [*.effect_data_ptr],y
    iny
    bne .write_buffer
    stx *.tmpx
    ldx *.tmp
    jsr .inc_sfx
    ldx *.tmpx
.write_buffer:
    sta famistudio_sfx_buffer-128,x
    ldx *.tmp
    jmp .read_byte 

.eof:
    sta famistudio_sfx_ptr_hi,x ; Mark channel as inactive

.update_buf:
    lda famistudio_output_buf ; Compare effect output buffer with main output buffer
    and #0x0f ; If volume of pulse 1 of effect is higher than that of the main buffer, overwrite the main buffer value with the new one
    sta *.tmp 
    lda famistudio_sfx_buffer+0,x
    and #0x0f
    cmp *.tmp
    bcc .no_pulse1
    lda famistudio_sfx_buffer+0,x
    sta famistudio_output_buf+0
    lda famistudio_sfx_buffer+1,x
    sta famistudio_output_buf+1
    lda famistudio_sfx_buffer+2,x
    sta famistudio_output_buf+2

.no_pulse1:
    lda famistudio_output_buf+3
    and #0x0f
    sta *.tmp
    lda famistudio_sfx_buffer+3,x
    and #0x0f
    cmp *.tmp
    bcc .no_pulse2
    lda famistudio_sfx_buffer+3,x
    sta famistudio_output_buf+3
    lda famistudio_sfx_buffer+4,x
    sta famistudio_output_buf+4
    lda famistudio_sfx_buffer+5,x
    sta famistudio_output_buf+5

.no_pulse2:
    lda famistudio_sfx_buffer+6,x ; Overwrite triangle of main output buffer if it is active
    beq .no_triangle
    sta famistudio_output_buf+6
    lda famistudio_sfx_buffer+7,x
    sta famistudio_output_buf+7
    lda famistudio_sfx_buffer+8,x
    sta famistudio_output_buf+8

.no_triangle:
    lda famistudio_output_buf+9
    and #0x0f
    sta *.tmp
    lda famistudio_sfx_buffer+9,x
    and #0x0f
    cmp *.tmp
    bcc .no_noise
    lda famistudio_sfx_buffer+9,x
    sta famistudio_output_buf+9
    lda famistudio_sfx_buffer+10,x
    sta famistudio_output_buf+10

.no_noise:
    rts

.inc_sfx:
    inc *.effect_data_ptr+1
    inc famistudio_sfx_ptr_hi,x
    rts

    .endif

; Dummy envelope used to initialize all channels with silence
famistudio_dummy_envelope:
    .byte 0xc0,0x7f,0x00,0x00

famistudio_dummy_pitch_envelope:
    .byte 0x00,0xc0,0x7f,0x00,0x01

; Note tables
    .if FAMISTUDIO_EXP_S5B
    famistudio_exp_note_table_lsb:
    famistudio_s5b_note_table_lsb:
.endif
famistudio_note_table_lsb:
    .if FAMISTUDIO_CFG_PAL_SUPPORT
        .byte 0x00
        .byte 0x68, 0xb6, 0x0e, 0x6f, 0xd9, 0x4b, 0xc6, 0x48, 0xd1, 0x60, 0xf6, 0x92 ; Octave 0
        .byte 0x34, 0xdb, 0x86, 0x37, 0xec, 0xa5, 0x62, 0x23, 0xe8, 0xb0, 0x7b, 0x49 ; Octave 1
        .byte 0x19, 0xed, 0xc3, 0x9b, 0x75, 0x52, 0x31, 0x11, 0xf3, 0xd7, 0xbd, 0xa4 ; Octave 2
        .byte 0x8c, 0x76, 0x61, 0x4d, 0x3a, 0x29, 0x18, 0x08, 0xf9, 0xeb, 0xde, 0xd1 ; Octave 3
        .byte 0xc6, 0xba, 0xb0, 0xa6, 0x9d, 0x94, 0x8b, 0x84, 0x7c, 0x75, 0x6e, 0x68 ; Octave 4
        .byte 0x62, 0x5d, 0x57, 0x52, 0x4e, 0x49, 0x45, 0x41, 0x3e, 0x3a, 0x37, 0x34 ; Octave 5
        .byte 0x31, 0x2e, 0x2b, 0x29, 0x26, 0x24, 0x22, 0x20, 0x1e, 0x1d, 0x1b, 0x19 ; Octave 6
        .byte 0x18, 0x16, 0x15, 0x14, 0x13, 0x12, 0x11, 0x10, 0x0f, 0x0e, 0x0d, 0x0c ; Octave 7
    .endif
    .if FAMISTUDIO_CFG_NTSC_SUPPORT
        .byte 0x00
        .byte 0x5b, 0x9c, 0xe6, 0x3b, 0x9a, 0x01, 0x72, 0xea, 0x6a, 0xf1, 0x7f, 0x13 ; Octave 0
        .byte 0xad, 0x4d, 0xf3, 0x9d, 0x4c, 0x00, 0xb8, 0x74, 0x34, 0xf8, 0xbf, 0x89 ; Octave 1
        .byte 0x56, 0x26, 0xf9, 0xce, 0xa6, 0x80, 0x5c, 0x3a, 0x1a, 0xfb, 0xdf, 0xc4 ; Octave 2
        .byte 0xab, 0x93, 0x7c, 0x67, 0x52, 0x3f, 0x2d, 0x1c, 0x0c, 0xfd, 0xef, 0xe1 ; Octave 3
        .byte 0xd5, 0xc9, 0xbd, 0xb3, 0xa9, 0x9f, 0x96, 0x8e, 0x86, 0x7e, 0x77, 0x70 ; Octave 4
        .byte 0x6a, 0x64, 0x5e, 0x59, 0x54, 0x4f, 0x4b, 0x46, 0x42, 0x3f, 0x3b, 0x38 ; Octave 5
        .byte 0x34, 0x31, 0x2f, 0x2c, 0x29, 0x27, 0x25, 0x23, 0x21, 0x1f, 0x1d, 0x1b ; Octave 6
        .byte 0x1a, 0x18, 0x17, 0x15, 0x14, 0x13, 0x12, 0x11, 0x10, 0x0f, 0x0e, 0x0d ; Octave 7
    .endif

    .if FAMISTUDIO_EXP_S5B
    famistudio_exp_note_table_msb:
    famistudio_s5b_note_table_msb:
    .endif
famistudio_note_table_msb:
    .if FAMISTUDIO_CFG_PAL_SUPPORT
        .byte 0x00
        .byte 0x0c, 0x0b, 0x0b, 0x0a, 0x09, 0x09, 0x08, 0x08, 0x07, 0x07, 0x06, 0x06 ; Octave 0
        .byte 0x06, 0x05, 0x05, 0x05, 0x04, 0x04, 0x04, 0x04, 0x03, 0x03, 0x03, 0x03 ; Octave 1
        .byte 0x03, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x01, 0x01, 0x01, 0x01 ; Octave 2
        .byte 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00 ; Octave 3
        .byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; Octave 4
        .byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; Octave 5
        .byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; Octave 6
        .byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; Octave 7
    .endif
    .if FAMISTUDIO_CFG_NTSC_SUPPORT
        .byte 0x00
        .byte 0x0d, 0x0c, 0x0b, 0x0b, 0x0a, 0x0a, 0x09, 0x08, 0x08, 0x07, 0x07, 0x07 ; Octave 0
        .byte 0x06, 0x06, 0x05, 0x05, 0x05, 0x05, 0x04, 0x04, 0x04, 0x03, 0x03, 0x03 ; Octave 1
        .byte 0x03, 0x03, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x01, 0x01, 0x01 ; Octave 2
        .byte 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00 ; Octave 3
        .byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; Octave 4
        .byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; Octave 5
        .byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; Octave 6
        .byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; Octave 7
    .endif

    .if FAMISTUDIO_EXP_VRC6
    famistudio_exp_note_table_lsb:
    famistudio_saw_note_table_lsb:
        .byte 0x00
        .byte 0x44, 0x69, 0x9a, 0xd6, 0x1e, 0x70, 0xcb, 0x30, 0x9e, 0x13, 0x91, 0x16 ; Octave 0
        .byte 0xa2, 0x34, 0xcc, 0x6b, 0x0e, 0xb7, 0x65, 0x18, 0xce, 0x89, 0x48, 0x0a ; Octave 1
        .byte 0xd0, 0x99, 0x66, 0x35, 0x07, 0xdb, 0xb2, 0x8b, 0x67, 0x44, 0x23, 0x05 ; Octave 2
        .byte 0xe8, 0xcc, 0xb2, 0x9a, 0x83, 0x6d, 0x59, 0x45, 0x33, 0x22, 0x11, 0x02 ; Octave 3
        .byte 0xf3, 0xe6, 0xd9, 0xcc, 0xc1, 0xb6, 0xac, 0xa2, 0x99, 0x90, 0x88, 0x80 ; Octave 4
        .byte 0x79, 0x72, 0x6c, 0x66, 0x60, 0x5b, 0x55, 0x51, 0x4c, 0x48, 0x44, 0x40 ; Octave 5
        .byte 0x3c, 0x39, 0x35, 0x32, 0x2f, 0x2d, 0x2a, 0x28, 0x25, 0x23, 0x21, 0x1f ; Octave 6
        .byte 0x1e, 0x1c, 0x1a, 0x19, 0x17, 0x16, 0x15, 0x13, 0x12, 0x11, 0x10, 0x0f ; Octave 7
    famistudio_exp_note_table_msb:
    famistudio_saw_note_table_msb:    
        .byte 0x00
        .byte 0x0f, 0x0e, 0x0d, 0x0c, 0x0c, 0x0b, 0x0a, 0x0a, 0x09, 0x09, 0x08, 0x08 ; Octave 0
        .byte 0x07, 0x07, 0x06, 0x06, 0x06, 0x05, 0x05, 0x05, 0x04, 0x04, 0x04, 0x04 ; Octave 1
        .byte 0x03, 0x03, 0x03, 0x03, 0x03, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02 ; Octave 2
        .byte 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01 ; Octave 3
        .byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; Octave 4
        .byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; Octave 5
        .byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; Octave 6
        .byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; Octave 7
    .endif

    .if FAMISTUDIO_EXP_VRC7
    famistudio_exp_note_table_lsb:
    famistudio_vrc7_note_table_lsb:
        .byte 0x00
        .byte 0xac, 0xb7, 0xc2, 0xcd, 0xd9, 0xe6, 0xf4, 0x02, 0x12, 0x22, 0x33, 0x46 ; Octave 0
        .byte 0x58, 0x6e, 0x84, 0x9a, 0xb2, 0xcc, 0xe8, 0x04, 0x24, 0x44, 0x66, 0x8c ; Octave 1
        .byte 0xb0, 0xdc, 0x08, 0x34, 0x64, 0x98, 0xd0, 0x08, 0x48, 0x88, 0xcc, 0x18 ; Octave 2
        .byte 0x60, 0xb8, 0x10, 0x68, 0xc8, 0x30, 0xa0, 0x10, 0x90, 0x10, 0x98, 0x30 ; Octave 3
        .byte 0xc0, 0x70, 0x20, 0xd0, 0x90, 0x60, 0x40, 0x20, 0x20, 0x20, 0x30, 0x60 ; Octave 4
        .byte 0x80, 0xe0, 0x40, 0xa0, 0x20, 0xc0, 0x80, 0x40, 0x40, 0x40, 0x60, 0xc0 ; Octave 5
        .byte 0x00, 0xc0, 0x80, 0x40, 0x40, 0x80, 0x00, 0x80, 0x80, 0x80, 0xc0, 0x80 ; Octave 6
        .byte 0x00, 0x80, 0x00, 0x80, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00 ; Octave 7
    famistudio_exp_note_table_msb:
    famistudio_vrc7_note_table_msb:
        .byte 0x00
        .byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01 ; Octave 0
        .byte 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x02, 0x02, 0x02, 0x02, 0x02 ; Octave 1
        .byte 0x02, 0x02, 0x03, 0x03, 0x03, 0x03, 0x03, 0x04, 0x04, 0x04, 0x04, 0x05 ; Octave 2
        .byte 0x05, 0x05, 0x06, 0x06, 0x06, 0x07, 0x07, 0x08, 0x08, 0x09, 0x09, 0x0a ; Octave 3
        .byte 0x0a, 0x0b, 0x0c, 0x0c, 0x0d, 0x0e, 0x0f, 0x10, 0x11, 0x12, 0x13, 0x14 ; Octave 4
        .byte 0x15, 0x16, 0x18, 0x19, 0x1b, 0x1c, 0x1e, 0x20, 0x22, 0x24, 0x26, 0x28 ; Octave 5
        .byte 0x2b, 0x2d, 0x30, 0x33, 0x36, 0x39, 0x3d, 0x40, 0x44, 0x48, 0x4c, 0x51 ; Octave 6
        .byte 0x56, 0x5b, 0x61, 0x66, 0x6c, 0x73, 0x7a, 0x81, 0x89, 0x91, 0x99, 0xa3 ; Octave 7    
    .endif

    .if FAMISTUDIO_EXP_EPSM
    famistudio_epsm_note_table_lsb:
        .byte 0x00
        .byte 0x9a, 0xa3, 0xad, 0xb7, 0xc2, 0xcd, 0xda, 0xe7, 0xf4, 0x03, 0x12, 0x23 ; Octave 0
        .byte 0x34, 0x46, 0x5a, 0x6e, 0x84, 0x9a, 0xb4, 0xce, 0xe8, 0x06, 0x24, 0x46 ; Octave 1
        .byte 0x68, 0x8c, 0xb4, 0xdc, 0x08, 0x34, 0x68, 0x9c, 0xd0, 0x0c, 0x48, 0x8c ; Octave 2
        .byte 0xd0, 0x18, 0x68, 0xb8, 0x10, 0x68, 0xd0, 0x38, 0xa0, 0x18, 0x90, 0x18 ; Octave 3
        .byte 0xa0, 0x30, 0xd0, 0x70, 0x20, 0xd0, 0xa0, 0x70, 0x40, 0x30, 0x20, 0x30 ; Octave 4
        .byte 0x40, 0x60, 0xa0, 0xe0, 0x40, 0xa0, 0x40, 0xe0, 0x80, 0x60, 0x40, 0x60 ; Octave 5
        .byte 0x80, 0xc0, 0x40, 0xc0, 0x80, 0x40, 0x80, 0xc0, 0x00, 0xc0, 0x80, 0xc0 ; Octave 6
        .byte 0x00, 0x80, 0x80, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80 ; Octave 7
    famistudio_epsm_note_table_msb:
        .byte 0x00
        .byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x01 ; Octave 0
        .byte 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x02, 0x02, 0x02 ; Octave 1
        .byte 0x02, 0x02, 0x02, 0x02, 0x03, 0x03, 0x03, 0x03, 0x03, 0x04, 0x04, 0x04 ; Octave 2
        .byte 0x04, 0x05, 0x05, 0x05, 0x06, 0x06, 0x06, 0x07, 0x07, 0x08, 0x08, 0x09 ; Octave 3
        .byte 0x09, 0x0a, 0x0a, 0x0b, 0x0c, 0x0c, 0x0d, 0x0e, 0x0f, 0x10, 0x11, 0x12 ; Octave 4
        .byte 0x13, 0x14, 0x15, 0x16, 0x18, 0x19, 0x1b, 0x1c, 0x1e, 0x20, 0x22, 0x24 ; Octave 5
        .byte 0x26, 0x28, 0x2b, 0x2d, 0x30, 0x33, 0x36, 0x39, 0x3d, 0x40, 0x44, 0x48 ; Octave 6
        .byte 0x4d, 0x51, 0x56, 0x5b, 0x61, 0x66, 0x6d, 0x73, 0x7a, 0x81, 0x89, 0x91 ; Octave 7  
    famistudio_exp_note_table_lsb:
    famistudio_epsm_s_note_table_lsb:
        .byte 0x00
        .byte 0xfa, 0x4b, 0xb5, 0x35, 0xcb, 0x75, 0x32, 0x02, 0xe2, 0xd3, 0xd2, 0xe1 ; Octave 0
        .byte 0xfd, 0x25, 0x5a, 0x9a, 0xe5, 0x3a, 0x99, 0x00, 0x71, 0xe9, 0x69, 0xf0 ; Octave 1
        .byte 0x7e, 0x12, 0xac, 0x4c, 0xf2, 0x9c, 0x4c, 0x00, 0xb8, 0x74, 0x34, 0xf7 ; Octave 2
        .byte 0xbe, 0x89, 0x56, 0x26, 0xf8, 0xce, 0xa5, 0x7f, 0x5b, 0x39, 0x19, 0xfb ; Octave 3
        .byte 0xdf, 0xc4, 0xaa, 0x92, 0x7c, 0x66, 0x52, 0x3f, 0x2d, 0x1c, 0x0c, 0xfd ; Octave 4
        .byte 0xef, 0xe1, 0xd5, 0xc9, 0xbd, 0xb3, 0xa9, 0x9f, 0x96, 0x8e, 0x86, 0x7e ; Octave 5
        .byte 0x77, 0x70, 0x6a, 0x64, 0x5e, 0x59, 0x54, 0x4f, 0x4b, 0x46, 0x42, 0x3f ; Octave 6
        .byte 0x3b, 0x38, 0x34, 0x31, 0x2f, 0x2c, 0x29, 0x27, 0x25, 0x23, 0x21, 0x1f ; Octave 7
    famistudio_exp_note_table_msb:
    famistudio_epsm_s_note_table_msb:
        .byte 0x00
        .byte 0x1d, 0x1c, 0x1a, 0x19, 0x17, 0x16, 0x15, 0x14, 0x12, 0x11, 0x10, 0x0f ; Octave 0
        .byte 0x0e, 0x0e, 0x0d, 0x0c, 0x0b, 0x0b, 0x0a, 0x0a, 0x09, 0x08, 0x08, 0x07 ; Octave 1
        .byte 0x07, 0x07, 0x06, 0x06, 0x05, 0x05, 0x05, 0x05, 0x04, 0x04, 0x04, 0x03 ; Octave 2
        .byte 0x03, 0x03, 0x03, 0x03, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x01 ; Octave 3
        .byte 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00 ; Octave 4
        .byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; Octave 5
        .byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; Octave 6
        .byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; Octave 7
    .endif

    .if FAMISTUDIO_EXP_FDS
    famistudio_exp_note_table_lsb:
    famistudio_fds_note_table_lsb:
        .byte 0x00
        .byte 0x13, 0x14, 0x16, 0x17, 0x18, 0x1a, 0x1b, 0x1d, 0x1e, 0x20, 0x22, 0x24 ; Octave 0
        .byte 0x26, 0x29, 0x2b, 0x2e, 0x30, 0x33, 0x36, 0x39, 0x3d, 0x40, 0x44, 0x48 ; Octave 1
        .byte 0x4d, 0x51, 0x56, 0x5b, 0x61, 0x66, 0x6c, 0x73, 0x7a, 0x81, 0x89, 0x91 ; Octave 2
        .byte 0x99, 0xa2, 0xac, 0xb6, 0xc1, 0xcd, 0xd9, 0xe6, 0xf3, 0x02, 0x11, 0x21 ; Octave 3
        .byte 0x33, 0x45, 0x58, 0x6d, 0x82, 0x99, 0xb2, 0xcb, 0xe7, 0x04, 0x22, 0x43 ; Octave 4
        .byte 0x65, 0x8a, 0xb0, 0xd9, 0x04, 0x32, 0x63, 0x97, 0xcd, 0x07, 0x44, 0x85 ; Octave 5
        .byte 0xca, 0x13, 0x60, 0xb2, 0x09, 0x65, 0xc6, 0x2d, 0x9b, 0x0e, 0x89, 0x0b ; Octave 6
        .byte 0x94, 0x26, 0xc1, 0x64, 0x12, 0xca, 0x8c, 0x5b, 0x35, 0x1d, 0x12, 0x16 ; Octave 7
    famistudio_exp_note_table_msb:
    famistudio_fds_note_table_msb:
        .byte 0x00
        .byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; Octave 0
        .byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; Octave 1
        .byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; Octave 2
        .byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x01 ; Octave 3
        .byte 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x02, 0x02, 0x02 ; Octave 4
        .byte 0x02, 0x02, 0x02, 0x02, 0x03, 0x03, 0x03, 0x03, 0x03, 0x04, 0x04, 0x04 ; Octave 5
        .byte 0x04, 0x05, 0x05, 0x05, 0x06, 0x06, 0x06, 0x07, 0x07, 0x08, 0x08, 0x09 ; Octave 6
        .byte 0x09, 0x0a, 0x0a, 0x0b, 0x0c, 0x0c, 0x0d, 0x0e, 0x0f, 0x10, 0x11, 0x12 ; Octave 7
    .endif

    .if FAMISTUDIO_EXP_N163
    .if FAMISTUDIO_EXP_N163_CHN_CNT = 1
    famistudio_exp_note_table_lsb:
    famistudio_n163_note_table_lsb:
        .byte 0x00
        .byte 0x47,0x4c,0x50,0x55,0x5a,0x5f,0x65,0x6b,0x72,0x78,0x80,0x87 ; Octave 0
        .byte 0x8f,0x98,0xa1,0xaa,0xb5,0xbf,0xcb,0xd7,0xe4,0xf1,0x00,0x0f ; Octave 1
        .byte 0x1f,0x30,0x42,0x55,0x6a,0x7f,0x96,0xae,0xc8,0xe3,0x00,0x1e ; Octave 2
        .byte 0x3e,0x60,0x85,0xab,0xd4,0xff,0x2c,0x5d,0x90,0xc6,0x00,0x3d ; Octave 3
        .byte 0x7d,0xc1,0x0a,0x57,0xa8,0xfe,0x59,0xba,0x20,0x8d,0x00,0x7a ; Octave 4
        .byte 0xfb,0x83,0x14,0xae,0x50,0xfd,0xb3,0x74,0x41,0x1a,0x00,0xf4 ; Octave 5
        .byte 0xf6,0x07,0x29,0x5c,0xa1,0xfa,0x67,0xe9,0x83,0x35,0x01,0xe8 ; Octave 6
        .byte 0xec,0x0f,0x52,0xb8,0x43,0xf4,0xce,0xd3,0x06,0x6a,0x02,0xd1 ; Octave 7
    famistudio_exp_note_table_msb:
    famistudio_n163_note_table_msb:
        .byte 0x00
        .byte 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00 ; Octave 0
        .byte 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x01,0x01 ; Octave 1
        .byte 0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x02,0x02 ; Octave 2
        .byte 0x02,0x02,0x02,0x02,0x02,0x02,0x03,0x03,0x03,0x03,0x04,0x04 ; Octave 3
        .byte 0x04,0x04,0x05,0x05,0x05,0x05,0x06,0x06,0x07,0x07,0x08,0x08 ; Octave 4
        .byte 0x08,0x09,0x0a,0x0a,0x0b,0x0b,0x0c,0x0d,0x0e,0x0f,0x10,0x10 ; Octave 5
        .byte 0x11,0x13,0x14,0x15,0x16,0x17,0x19,0x1a,0x1c,0x1e,0x20,0x21 ; Octave 6
        .byte 0x23,0x26,0x28,0x2a,0x2d,0x2f,0x32,0x35,0x39,0x3c,0x40,0x43 ; Octave 7
    .endif
    .if FAMISTUDIO_EXP_N163_CHN_CNT = 2
    famistudio_exp_note_table_lsb:
    famistudio_n163_note_table_lsb:
        .byte 0x00
        .byte 0x8f,0x98,0xa1,0xaa,0xb5,0xbf,0xcb,0xd7,0xe4,0xf1,0x00,0x0f ; Octave 0
        .byte 0x1f,0x30,0x42,0x55,0x6a,0x7f,0x96,0xae,0xc8,0xe3,0x00,0x1e ; Octave 1
        .byte 0x3e,0x60,0x85,0xab,0xd4,0xff,0x2c,0x5d,0x90,0xc6,0x00,0x3d ; Octave 2
        .byte 0x7d,0xc1,0x0a,0x57,0xa8,0xfe,0x59,0xba,0x20,0x8d,0x00,0x7a ; Octave 3
        .byte 0xfb,0x83,0x14,0xae,0x50,0xfd,0xb3,0x74,0x41,0x1a,0x00,0xf4 ; Octave 4
        .byte 0xf6,0x07,0x29,0x5c,0xa1,0xfa,0x67,0xe9,0x83,0x35,0x01,0xe8 ; Octave 5
        .byte 0xec,0x0f,0x52,0xb8,0x43,0xf4,0xce,0xd3,0x06,0x6a,0x02,0xd1 ; Octave 6
        .byte 0xd9,0x1f,0xa5,0x71,0x86,0xe8,0x9c,0xa7,0x0d,0xd5,0x05,0xa2 ; Octave 7
    famistudio_exp_note_table_msb:
    famistudio_n163_note_table_msb:
        .byte 0x00
        .byte 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x01,0x01 ; Octave 0
        .byte 0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x02,0x02 ; Octave 1
        .byte 0x02,0x02,0x02,0x02,0x02,0x02,0x03,0x03,0x03,0x03,0x04,0x04 ; Octave 2
        .byte 0x04,0x04,0x05,0x05,0x05,0x05,0x06,0x06,0x07,0x07,0x08,0x08 ; Octave 3
        .byte 0x08,0x09,0x0a,0x0a,0x0b,0x0b,0x0c,0x0d,0x0e,0x0f,0x10,0x10 ; Octave 4
        .byte 0x11,0x13,0x14,0x15,0x16,0x17,0x19,0x1a,0x1c,0x1e,0x20,0x21 ; Octave 5
        .byte 0x23,0x26,0x28,0x2a,0x2d,0x2f,0x32,0x35,0x39,0x3c,0x40,0x43 ; Octave 6
        .byte 0x47,0x4c,0x50,0x55,0x5a,0x5f,0x65,0x6b,0x72,0x78,0x80,0x87 ; Octave 7
    .endif
    .if FAMISTUDIO_EXP_N163_CHN_CNT = 3
    famistudio_exp_note_table_lsb:
    famistudio_n163_note_table_lsb:
        .byte 0x00
        .byte 0xd7,0xe4,0xf1,0x00,0x0f,0x1f,0x30,0x42,0x56,0x6a,0x80,0x96 ; Octave 0
        .byte 0xaf,0xc8,0xe3,0x00,0x1f,0x3f,0x61,0x85,0xac,0xd5,0x00,0x2d ; Octave 1
        .byte 0x5e,0x91,0xc7,0x01,0x3e,0x7e,0xc3,0x0b,0x58,0xaa,0x00,0x5b ; Octave 2
        .byte 0xbc,0x22,0x8f,0x02,0x7c,0xfd,0x86,0x17,0xb1,0x54,0x00,0xb7 ; Octave 3
        .byte 0x78,0x45,0x1f,0x05,0xf9,0xfb,0x0d,0x2f,0x62,0xa8,0x01,0x6e ; Octave 4
        .byte 0xf1,0x8b,0x3e,0x0a,0xf2,0xf7,0x1a,0x5e,0xc5,0x50,0x02,0xdc ; Octave 5
        .byte 0xe3,0x17,0x7c,0x15,0xe4,0xee,0x35,0xbd,0x8a,0xa0,0x04,0xb9 ; Octave 6
        .byte 0xc6,0x2e,0xf8,0x2a,0xc9,0xdc,0x6a,0x7a,0x14,0x40,0x08,0x73 ; Octave 7
    famistudio_exp_note_table_msb:
    famistudio_n163_note_table_msb:
        .byte 0x00
        .byte 0x00,0x00,0x00,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01 ; Octave 0
        .byte 0x01,0x01,0x01,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x03,0x03 ; Octave 1
        .byte 0x03,0x03,0x03,0x04,0x04,0x04,0x04,0x05,0x05,0x05,0x06,0x06 ; Octave 2
        .byte 0x06,0x07,0x07,0x08,0x08,0x08,0x09,0x0a,0x0a,0x0b,0x0c,0x0c ; Octave 3
        .byte 0x0d,0x0e,0x0f,0x10,0x10,0x11,0x13,0x14,0x15,0x16,0x18,0x19 ; Octave 4
        .byte 0x1a,0x1c,0x1e,0x20,0x21,0x23,0x26,0x28,0x2a,0x2d,0x30,0x32 ; Octave 5
        .byte 0x35,0x39,0x3c,0x40,0x43,0x47,0x4c,0x50,0x55,0x5a,0x60,0x65 ; Octave 6
        .byte 0x6b,0x72,0x78,0x80,0x87,0x8f,0x98,0xa1,0xab,0xb5,0xc0,0xcb ; Octave 7
    .endif
    .if FAMISTUDIO_EXP_N163_CHN_CNT = 4
    famistudio_exp_note_table_lsb:
    famistudio_n163_note_table_lsb:
        .byte 0x00
        .byte 0x1f,0x30,0x42,0x55,0x6a,0x7f,0x96,0xae,0xc8,0xe3,0x00,0x1e ; Octave 0
        .byte 0x3e,0x60,0x85,0xab,0xd4,0xff,0x2c,0x5d,0x90,0xc6,0x00,0x3d ; Octave 1
        .byte 0x7d,0xc1,0x0a,0x57,0xa8,0xfe,0x59,0xba,0x20,0x8d,0x00,0x7a ; Octave 2
        .byte 0xfb,0x83,0x14,0xae,0x50,0xfd,0xb3,0x74,0x41,0x1a,0x00,0xf4 ; Octave 3
        .byte 0xf6,0x07,0x29,0x5c,0xa1,0xfa,0x67,0xe9,0x83,0x35,0x01,0xe8 ; Octave 4
        .byte 0xec,0x0f,0x52,0xb8,0x43,0xf4,0xce,0xd3,0x06,0x6a,0x02,0xd1 ; Octave 5
        .byte 0xd9,0x1f,0xa5,0x71,0x86,0xe8,0x9c,0xa7,0x0d,0xd5,0x05,0xa2 ; Octave 6
        .byte 0xb2,0x3e,0x4b,0xe3,0x0c,0xd0,0x38,0x4e,0x1b,0xab,0xff,0xff ; Octave 7
    famistudio_exp_note_table_msb:
    famistudio_n163_note_table_msb:
        .byte 0x00
        .byte 0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x02,0x02 ; Octave 0
        .byte 0x02,0x02,0x02,0x02,0x02,0x02,0x03,0x03,0x03,0x03,0x04,0x04 ; Octave 1
        .byte 0x04,0x04,0x05,0x05,0x05,0x05,0x06,0x06,0x07,0x07,0x08,0x08 ; Octave 2
        .byte 0x08,0x09,0x0a,0x0a,0x0b,0x0b,0x0c,0x0d,0x0e,0x0f,0x10,0x10 ; Octave 3
        .byte 0x11,0x13,0x14,0x15,0x16,0x17,0x19,0x1a,0x1c,0x1e,0x20,0x21 ; Octave 4
        .byte 0x23,0x26,0x28,0x2a,0x2d,0x2f,0x32,0x35,0x39,0x3c,0x40,0x43 ; Octave 5
        .byte 0x47,0x4c,0x50,0x55,0x5a,0x5f,0x65,0x6b,0x72,0x78,0x80,0x87 ; Octave 6
        .byte 0x8f,0x98,0xa1,0xaa,0xb5,0xbf,0xcb,0xd7,0xe4,0xf1,0xff,0xff ; Octave 7
    .endif
    .if FAMISTUDIO_EXP_N163_CHN_CNT = 5
    famistudio_exp_note_table_lsb:
    famistudio_n163_note_table_lsb:
        .byte 0x00
        .byte 0x67,0x7c,0x93,0xab,0xc4,0xdf,0xfc,0x1a,0x3a,0x5c,0x80,0xa6 ; Octave 0
        .byte 0xce,0xf9,0x26,0x56,0x89,0xbf,0xf8,0x34,0x74,0xb8,0x00,0x4c ; Octave 1
        .byte 0x9c,0xf2,0x4c,0xac,0x12,0x7e,0xf0,0x69,0xe9,0x70,0x00,0x98 ; Octave 2
        .byte 0x39,0xe4,0x99,0x59,0x24,0xfc,0xe0,0xd2,0xd2,0xe1,0x00,0x31 ; Octave 3
        .byte 0x73,0xc9,0x33,0xb3,0x49,0xf8,0xc0,0xa4,0xa4,0xc2,0x01,0x62 ; Octave 4
        .byte 0xe7,0x93,0x67,0x67,0x93,0xf1,0x81,0x48,0x48,0x85,0x03,0xc5 ; Octave 5
        .byte 0xcf,0x26,0xcf,0xce,0x27,0xe2,0x03,0x90,0x91,0x0b,0x06,0x8a ; Octave 6
        .byte 0x9f,0x4d,0x9e,0x9c,0x4f,0xc4,0x06,0xff,0xff,0xff,0xff,0xff ; Octave 7
    famistudio_exp_note_table_msb:
    famistudio_n163_note_table_msb:
        .byte 0x00
        .byte 0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x02,0x02,0x02,0x02,0x02 ; Octave 0
        .byte 0x02,0x02,0x03,0x03,0x03,0x03,0x03,0x04,0x04,0x04,0x05,0x05 ; Octave 1
        .byte 0x05,0x05,0x06,0x06,0x07,0x07,0x07,0x08,0x08,0x09,0x0a,0x0a ; Octave 2
        .byte 0x0b,0x0b,0x0c,0x0d,0x0e,0x0e,0x0f,0x10,0x11,0x12,0x14,0x15 ; Octave 3
        .byte 0x16,0x17,0x19,0x1a,0x1c,0x1d,0x1f,0x21,0x23,0x25,0x28,0x2a ; Octave 4
        .byte 0x2c,0x2f,0x32,0x35,0x38,0x3b,0x3f,0x43,0x47,0x4b,0x50,0x54 ; Octave 5
        .byte 0x59,0x5f,0x64,0x6a,0x71,0x77,0x7f,0x86,0x8e,0x97,0xa0,0xa9 ; Octave 6
        .byte 0xb3,0xbe,0xc9,0xd5,0xe2,0xef,0xfe,0xff,0xff,0xff,0xff,0xff ; Octave 7
    .endif
    .if FAMISTUDIO_EXP_N163_CHN_CNT = 6
    famistudio_exp_note_table_lsb:
    famistudio_n163_note_table_lsb:
        .byte 0x00
        .byte 0xaf,0xc8,0xe3,0x00,0x1f,0x3f,0x61,0x85,0xac,0xd5,0x00,0x2d ; Octave 0
        .byte 0x5e,0x91,0xc7,0x01,0x3e,0x7e,0xc3,0x0b,0x58,0xaa,0x00,0x5b ; Octave 1
        .byte 0xbc,0x22,0x8f,0x02,0x7c,0xfd,0x86,0x17,0xb1,0x54,0x00,0xb7 ; Octave 2
        .byte 0x78,0x45,0x1f,0x05,0xf9,0xfb,0x0d,0x2f,0x62,0xa8,0x01,0x6e ; Octave 3
        .byte 0xf1,0x8b,0x3e,0x0a,0xf2,0xf7,0x1a,0x5e,0xc5,0x50,0x02,0xdc ; Octave 4
        .byte 0xe3,0x17,0x7c,0x15,0xe4,0xee,0x35,0xbd,0x8a,0xa0,0x04,0xb9 ; Octave 5
        .byte 0xc6,0x2e,0xf8,0x2a,0xc9,0xdc,0x6a,0x7a,0x14,0x40,0x08,0x73 ; Octave 6
        .byte 0x8c,0x5d,0xf1,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff ; Octave 7
    famistudio_exp_note_table_msb:
    famistudio_n163_note_table_msb:
        .byte 0x00
        .byte 0x01,0x01,0x01,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x03,0x03 ; Octave 0
        .byte 0x03,0x03,0x03,0x04,0x04,0x04,0x04,0x05,0x05,0x05,0x06,0x06 ; Octave 1
        .byte 0x06,0x07,0x07,0x08,0x08,0x08,0x09,0x0a,0x0a,0x0b,0x0c,0x0c ; Octave 2
        .byte 0x0d,0x0e,0x0f,0x10,0x10,0x11,0x13,0x14,0x15,0x16,0x18,0x19 ; Octave 3
        .byte 0x1a,0x1c,0x1e,0x20,0x21,0x23,0x26,0x28,0x2a,0x2d,0x30,0x32 ; Octave 4
        .byte 0x35,0x39,0x3c,0x40,0x43,0x47,0x4c,0x50,0x55,0x5a,0x60,0x65 ; Octave 5
        .byte 0x6b,0x72,0x78,0x80,0x87,0x8f,0x98,0xa1,0xab,0xb5,0xc0,0xcb ; Octave 6
        .byte 0xd7,0xe4,0xf1,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff ; Octave 7
    .endif
    .if FAMISTUDIO_EXP_N163_CHN_CNT = 7
    famistudio_exp_note_table_lsb:
    famistudio_n163_note_table_lsb:
        .byte 0x00
        .byte 0xf6,0x14,0x34,0x56,0x79,0x9f,0xc7,0xf1,0x1e,0x4d,0x80,0xb5 ; Octave 0
        .byte 0xed,0x29,0x69,0xac,0xf3,0x3e,0x8e,0xe3,0x3c,0x9b,0x00,0x6a ; Octave 1
        .byte 0xdb,0x53,0xd2,0x58,0xe6,0x7d,0x1d,0xc6,0x79,0x37,0x00,0xd5 ; Octave 2
        .byte 0xb7,0xa6,0xa4,0xb0,0xcd,0xfa,0x3a,0x8c,0xf3,0x6e,0x01,0xab ; Octave 3
        .byte 0x6f,0x4d,0x48,0x61,0x9a,0xf5,0x74,0x19,0xe6,0xdd,0x02,0x56 ; Octave 4
        .byte 0xde,0x9b,0x91,0xc3,0x35,0xeb,0xe8,0x32,0xcc,0xbb,0x04,0xad ; Octave 5
        .byte 0xbc,0x36,0x22,0x86,0x6b,0xd6,0xd1,0x64,0x98,0x76,0x09,0x5b ; Octave 6
        .byte 0x79,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff ; Octave 7
    famistudio_exp_note_table_msb:
    famistudio_n163_note_table_msb:
        .byte 0x00
        .byte 0x01,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x03,0x03,0x03,0x03 ; Octave 0
        .byte 0x03,0x04,0x04,0x04,0x04,0x05,0x05,0x05,0x06,0x06,0x07,0x07 ; Octave 1
        .byte 0x07,0x08,0x08,0x09,0x09,0x0a,0x0b,0x0b,0x0c,0x0d,0x0e,0x0e ; Octave 2
        .byte 0x0f,0x10,0x11,0x12,0x13,0x14,0x16,0x17,0x18,0x1a,0x1c,0x1d ; Octave 3
        .byte 0x1f,0x21,0x23,0x25,0x27,0x29,0x2c,0x2f,0x31,0x34,0x38,0x3b ; Octave 4
        .byte 0x3e,0x42,0x46,0x4a,0x4f,0x53,0x58,0x5e,0x63,0x69,0x70,0x76 ; Octave 5
        .byte 0x7d,0x85,0x8d,0x95,0x9e,0xa7,0xb1,0xbc,0xc7,0xd3,0xe0,0xed ; Octave 6
        .byte 0xfb,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff ; Octave 7
    .endif
    .if FAMISTUDIO_EXP_N163_CHN_CNT = 8
    famistudio_exp_note_table_lsb:
    famistudio_n163_note_table_lsb:
        .byte 0x00
        .byte 0x3e,0x60,0x85,0xab,0xd4,0xff,0x2c,0x5d,0x90,0xc6,0x00,0x3d ; Octave 0
        .byte 0x7d,0xc1,0x0a,0x57,0xa8,0xfe,0x59,0xba,0x20,0x8d,0x00,0x7a ; Octave 1
        .byte 0xfb,0x83,0x14,0xae,0x50,0xfd,0xb3,0x74,0x41,0x1a,0x00,0xf4 ; Octave 2
        .byte 0xf6,0x07,0x29,0x5c,0xa1,0xfa,0x67,0xe9,0x83,0x35,0x01,0xe8 ; Octave 3
        .byte 0xec,0x0f,0x52,0xb8,0x43,0xf4,0xce,0xd3,0x06,0x6a,0x02,0xd1 ; Octave 4
        .byte 0xd9,0x1f,0xa5,0x71,0x86,0xe8,0x9c,0xa7,0x0d,0xd5,0x05,0xa2 ; Octave 5
        .byte 0xb2,0x3e,0x4b,0xe3,0x0c,0xd0,0x38,0x4e,0x1b,0xab,0xff,0xff ; Octave 6
        .byte 0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff ; Octave 7
    famistudio_exp_note_table_msb:
    famistudio_n163_note_table_msb:
        .byte 0x00
        .byte 0x02,0x02,0x02,0x02,0x02,0x02,0x03,0x03,0x03,0x03,0x04,0x04 ; Octave 0
        .byte 0x04,0x04,0x05,0x05,0x05,0x05,0x06,0x06,0x07,0x07,0x08,0x08 ; Octave 1
        .byte 0x08,0x09,0x0a,0x0a,0x0b,0x0b,0x0c,0x0d,0x0e,0x0f,0x10,0x10 ; Octave 2
        .byte 0x11,0x13,0x14,0x15,0x16,0x17,0x19,0x1a,0x1c,0x1e,0x20,0x21 ; Octave 3
        .byte 0x23,0x26,0x28,0x2a,0x2d,0x2f,0x32,0x35,0x39,0x3c,0x40,0x43 ; Octave 4
        .byte 0x47,0x4c,0x50,0x55,0x5a,0x5f,0x65,0x6b,0x72,0x78,0x80,0x87 ; Octave 5
        .byte 0x8f,0x98,0xa1,0xaa,0xb5,0xbf,0xcb,0xd7,0xe4,0xf1,0xff,0xff ; Octave 6
        .byte 0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff ; Octave 7
    .endif
    .endif

; For a given channel, returns the index of the volume envelope.
famistudio_channel_env:
famistudio_channel_to_volume_env:
    .byte FAMISTUDIO_CH0_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
    .byte FAMISTUDIO_CH1_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
    .byte FAMISTUDIO_CH2_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
    .byte FAMISTUDIO_CH3_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
    .byte 0xff
    .if FAMISTUDIO_EXP_VRC6
        .byte FAMISTUDIO_VRC6_CH0_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
        .byte FAMISTUDIO_VRC6_CH1_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
        .byte FAMISTUDIO_VRC6_CH2_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
    .endif
    .if FAMISTUDIO_EXP_VRC7
        .byte FAMISTUDIO_VRC7_CH0_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
        .byte FAMISTUDIO_VRC7_CH1_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
        .byte FAMISTUDIO_VRC7_CH2_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
        .byte FAMISTUDIO_VRC7_CH3_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
        .byte FAMISTUDIO_VRC7_CH4_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
        .byte FAMISTUDIO_VRC7_CH5_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
    .endif
    .if FAMISTUDIO_EXP_FDS
        .byte FAMISTUDIO_FDS_CH0_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
    .endif
    .if FAMISTUDIO_EXP_MMC5
        .byte FAMISTUDIO_MMC5_CH0_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
        .byte FAMISTUDIO_MMC5_CH1_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
    .endif
    .if FAMISTUDIO_EXP_N163
        .byte FAMISTUDIO_N163_CH0_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
        .byte FAMISTUDIO_N163_CH1_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
        .byte FAMISTUDIO_N163_CH2_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
        .byte FAMISTUDIO_N163_CH3_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
        .byte FAMISTUDIO_N163_CH4_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
        .byte FAMISTUDIO_N163_CH5_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
        .byte FAMISTUDIO_N163_CH6_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
        .byte FAMISTUDIO_N163_CH7_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
    .endif
    .if FAMISTUDIO_EXP_S5B
        .byte FAMISTUDIO_S5B_CH0_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
        .byte FAMISTUDIO_S5B_CH1_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
        .byte FAMISTUDIO_S5B_CH2_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
    .endif
    .if FAMISTUDIO_EXP_EPSM
    .byte FAMISTUDIO_EPSM_CH0_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
    .byte FAMISTUDIO_EPSM_CH1_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
    .byte FAMISTUDIO_EPSM_CH2_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
    .byte FAMISTUDIO_EPSM_CH3_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
    .byte FAMISTUDIO_EPSM_CH4_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
    .byte FAMISTUDIO_EPSM_CH5_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
    .byte FAMISTUDIO_EPSM_CH6_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
    .byte FAMISTUDIO_EPSM_CH7_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
    .byte FAMISTUDIO_EPSM_CH8_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
    .byte FAMISTUDIO_EPSM_CH9_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
    .byte FAMISTUDIO_EPSM_CH10_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
    .byte FAMISTUDIO_EPSM_CH11_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
    .byte FAMISTUDIO_EPSM_CH12_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
    .byte FAMISTUDIO_EPSM_CH13_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
    .byte FAMISTUDIO_EPSM_CH14_ENVS+FAMISTUDIO_ENV_VOLUME_OFF
    .endif

    .if FAMISTUDIO_USE_ARPEGGIO
; For a given channel, returns the index of the arpeggio envelope.
famistudio_channel_to_arpeggio_env:
    .byte FAMISTUDIO_CH0_ENVS+FAMISTUDIO_ENV_NOTE_OFF
    .byte FAMISTUDIO_CH1_ENVS+FAMISTUDIO_ENV_NOTE_OFF
    .byte FAMISTUDIO_CH2_ENVS+FAMISTUDIO_ENV_NOTE_OFF
    .byte FAMISTUDIO_CH3_ENVS+FAMISTUDIO_ENV_NOTE_OFF
    .byte 0xff
    .if FAMISTUDIO_EXP_VRC6
        .byte FAMISTUDIO_VRC6_CH0_ENVS+FAMISTUDIO_ENV_NOTE_OFF
        .byte FAMISTUDIO_VRC6_CH1_ENVS+FAMISTUDIO_ENV_NOTE_OFF
        .byte FAMISTUDIO_VRC6_CH2_ENVS+FAMISTUDIO_ENV_NOTE_OFF
    .endif
    .if FAMISTUDIO_EXP_VRC7
        .byte FAMISTUDIO_VRC7_CH0_ENVS+FAMISTUDIO_ENV_NOTE_OFF
        .byte FAMISTUDIO_VRC7_CH1_ENVS+FAMISTUDIO_ENV_NOTE_OFF
        .byte FAMISTUDIO_VRC7_CH2_ENVS+FAMISTUDIO_ENV_NOTE_OFF
        .byte FAMISTUDIO_VRC7_CH3_ENVS+FAMISTUDIO_ENV_NOTE_OFF
        .byte FAMISTUDIO_VRC7_CH4_ENVS+FAMISTUDIO_ENV_NOTE_OFF
        .byte FAMISTUDIO_VRC7_CH5_ENVS+FAMISTUDIO_ENV_NOTE_OFF
    .endif
    .if FAMISTUDIO_EXP_FDS
        .byte FAMISTUDIO_FDS_CH0_ENVS+FAMISTUDIO_ENV_NOTE_OFF
    .endif
    .if FAMISTUDIO_EXP_MMC5
        .byte FAMISTUDIO_MMC5_CH0_ENVS+FAMISTUDIO_ENV_NOTE_OFF
        .byte FAMISTUDIO_MMC5_CH1_ENVS+FAMISTUDIO_ENV_NOTE_OFF
    .endif
    .if FAMISTUDIO_EXP_N163
        .byte FAMISTUDIO_N163_CH0_ENVS+FAMISTUDIO_ENV_NOTE_OFF
        .byte FAMISTUDIO_N163_CH1_ENVS+FAMISTUDIO_ENV_NOTE_OFF
        .byte FAMISTUDIO_N163_CH2_ENVS+FAMISTUDIO_ENV_NOTE_OFF
        .byte FAMISTUDIO_N163_CH3_ENVS+FAMISTUDIO_ENV_NOTE_OFF
        .byte FAMISTUDIO_N163_CH4_ENVS+FAMISTUDIO_ENV_NOTE_OFF
        .byte FAMISTUDIO_N163_CH5_ENVS+FAMISTUDIO_ENV_NOTE_OFF
        .byte FAMISTUDIO_N163_CH6_ENVS+FAMISTUDIO_ENV_NOTE_OFF
        .byte FAMISTUDIO_N163_CH7_ENVS+FAMISTUDIO_ENV_NOTE_OFF
    .endif
    .if FAMISTUDIO_EXP_S5B
        .byte FAMISTUDIO_S5B_CH0_ENVS+FAMISTUDIO_ENV_NOTE_OFF
        .byte FAMISTUDIO_S5B_CH1_ENVS+FAMISTUDIO_ENV_NOTE_OFF
        .byte FAMISTUDIO_S5B_CH2_ENVS+FAMISTUDIO_ENV_NOTE_OFF
    .endif
    .if FAMISTUDIO_EXP_EPSM
    .byte FAMISTUDIO_EPSM_CH0_ENVS+FAMISTUDIO_ENV_NOTE_OFF
    .byte FAMISTUDIO_EPSM_CH1_ENVS+FAMISTUDIO_ENV_NOTE_OFF
    .byte FAMISTUDIO_EPSM_CH2_ENVS+FAMISTUDIO_ENV_NOTE_OFF
    .byte FAMISTUDIO_EPSM_CH3_ENVS+FAMISTUDIO_ENV_NOTE_OFF
    .byte FAMISTUDIO_EPSM_CH4_ENVS+FAMISTUDIO_ENV_NOTE_OFF
    .byte FAMISTUDIO_EPSM_CH5_ENVS+FAMISTUDIO_ENV_NOTE_OFF
    .byte FAMISTUDIO_EPSM_CH6_ENVS+FAMISTUDIO_ENV_NOTE_OFF
    .byte FAMISTUDIO_EPSM_CH7_ENVS+FAMISTUDIO_ENV_NOTE_OFF
    .byte FAMISTUDIO_EPSM_CH8_ENVS+FAMISTUDIO_ENV_NOTE_OFF
    .byte FAMISTUDIO_EPSM_CH9_ENVS+FAMISTUDIO_ENV_NOTE_OFF
    .byte FAMISTUDIO_EPSM_CH10_ENVS+FAMISTUDIO_ENV_NOTE_OFF
    .byte FAMISTUDIO_EPSM_CH11_ENVS+FAMISTUDIO_ENV_NOTE_OFF
    .byte FAMISTUDIO_EPSM_CH12_ENVS+FAMISTUDIO_ENV_NOTE_OFF
    .byte FAMISTUDIO_EPSM_CH13_ENVS+FAMISTUDIO_ENV_NOTE_OFF
    .byte FAMISTUDIO_EPSM_CH14_ENVS+FAMISTUDIO_ENV_NOTE_OFF
    .endif
    .endif

    .if FAMISTUDIO_USE_SLIDE_NOTES
famistudio_channel_to_slide:
; This table will only be defined if we use noise slides, otherwise identical to "famistudio_channel_to_pitch_env".
    .if FAMISTUDIO_USE_NOISE_SLIDE_NOTES    
    .byte 0x00
    .byte 0x01
    .byte 0x02
    .byte FAMISTUDIO_NOISE_SLIDE_INDEX ; Keep the noise slide at the end so the pitch envelopes/slides are in sync.
    .byte 0xff ; no slide for DPCM
    .if FAMISTUDIO_EXP_VRC6
        .byte FAMISTUDIO_VRC6_CH0_PITCH_ENV_IDX
        .byte FAMISTUDIO_VRC6_CH1_PITCH_ENV_IDX
        .byte FAMISTUDIO_VRC6_CH2_PITCH_ENV_IDX
    .endif
    .if FAMISTUDIO_EXP_VRC7
        .byte FAMISTUDIO_VRC7_CH0_PITCH_ENV_IDX
        .byte FAMISTUDIO_VRC7_CH1_PITCH_ENV_IDX
        .byte FAMISTUDIO_VRC7_CH2_PITCH_ENV_IDX
        .byte FAMISTUDIO_VRC7_CH3_PITCH_ENV_IDX
        .byte FAMISTUDIO_VRC7_CH4_PITCH_ENV_IDX
        .byte FAMISTUDIO_VRC7_CH5_PITCH_ENV_IDX
    .endif
    .if FAMISTUDIO_EXP_FDS
    .byte FAMISTUDIO_FDS_CH0_PITCH_ENV_IDX
    .endif
    .if FAMISTUDIO_EXP_MMC5    
    .byte FAMISTUDIO_MMC5_CH0_PITCH_ENV_IDX
    .byte FAMISTUDIO_MMC5_CH1_PITCH_ENV_IDX
    .endif
    .if FAMISTUDIO_EXP_N163    
    .byte FAMISTUDIO_N163_CH0_PITCH_ENV_IDX
    .byte FAMISTUDIO_N163_CH1_PITCH_ENV_IDX
    .byte FAMISTUDIO_N163_CH2_PITCH_ENV_IDX
    .byte FAMISTUDIO_N163_CH3_PITCH_ENV_IDX
    .byte FAMISTUDIO_N163_CH4_PITCH_ENV_IDX
    .byte FAMISTUDIO_N163_CH5_PITCH_ENV_IDX
    .byte FAMISTUDIO_N163_CH6_PITCH_ENV_IDX
    .byte FAMISTUDIO_N163_CH7_PITCH_ENV_IDX
    .endif
    .if FAMISTUDIO_EXP_S5B    
    .byte FAMISTUDIO_S5B_CH0_PITCH_ENV_IDX
    .byte FAMISTUDIO_S5B_CH1_PITCH_ENV_IDX
    .byte FAMISTUDIO_S5B_CH2_PITCH_ENV_IDX
    .endif
    .if FAMISTUDIO_EXP_EPSM
    .byte FAMISTUDIO_EPSM_CH0_PITCH_ENV_IDX
    .byte FAMISTUDIO_EPSM_CH1_PITCH_ENV_IDX
    .byte FAMISTUDIO_EPSM_CH2_PITCH_ENV_IDX
    .byte FAMISTUDIO_EPSM_CH3_PITCH_ENV_IDX
    .byte FAMISTUDIO_EPSM_CH4_PITCH_ENV_IDX
    .byte FAMISTUDIO_EPSM_CH5_PITCH_ENV_IDX
    .byte FAMISTUDIO_EPSM_CH6_PITCH_ENV_IDX
    .byte FAMISTUDIO_EPSM_CH7_PITCH_ENV_IDX
    .byte FAMISTUDIO_EPSM_CH8_PITCH_ENV_IDX
    .byte FAMISTUDIO_EPSM_CH9_PITCH_ENV_IDX
    .byte FAMISTUDIO_EPSM_CH10_PITCH_ENV_IDX
    .byte FAMISTUDIO_EPSM_CH11_PITCH_ENV_IDX
    .byte FAMISTUDIO_EPSM_CH12_PITCH_ENV_IDX
    .byte FAMISTUDIO_EPSM_CH13_PITCH_ENV_IDX
    .byte FAMISTUDIO_EPSM_CH14_PITCH_ENV_IDX
    .endif
    .endif

    .endif

; For a given channel, returns the index of the pitch envelope.
famistudio_channel_to_pitch_env:
    .byte 0x00
    .byte 0x01
    .byte 0x02
    .byte 0xff ; no pitch envelopes for noise
    .byte 0xff ; no pitch envelopes slide for DPCM
    .if FAMISTUDIO_EXP_VRC6
        .byte FAMISTUDIO_VRC6_CH0_PITCH_ENV_IDX
        .byte FAMISTUDIO_VRC6_CH1_PITCH_ENV_IDX
        .byte FAMISTUDIO_VRC6_CH2_PITCH_ENV_IDX
    .endif
    .if FAMISTUDIO_EXP_VRC7
        .byte FAMISTUDIO_VRC7_CH0_PITCH_ENV_IDX
        .byte FAMISTUDIO_VRC7_CH1_PITCH_ENV_IDX
        .byte FAMISTUDIO_VRC7_CH2_PITCH_ENV_IDX
        .byte FAMISTUDIO_VRC7_CH3_PITCH_ENV_IDX
        .byte FAMISTUDIO_VRC7_CH4_PITCH_ENV_IDX
        .byte FAMISTUDIO_VRC7_CH5_PITCH_ENV_IDX
    .endif
    .if FAMISTUDIO_EXP_FDS
        .byte FAMISTUDIO_FDS_CH0_PITCH_ENV_IDX
    .endif
    .if FAMISTUDIO_EXP_MMC5    
        .byte FAMISTUDIO_MMC5_CH0_PITCH_ENV_IDX
        .byte FAMISTUDIO_MMC5_CH1_PITCH_ENV_IDX
    .endif
    .if FAMISTUDIO_EXP_N163    
        .byte FAMISTUDIO_N163_CH0_PITCH_ENV_IDX
        .byte FAMISTUDIO_N163_CH1_PITCH_ENV_IDX
        .byte FAMISTUDIO_N163_CH2_PITCH_ENV_IDX
        .byte FAMISTUDIO_N163_CH3_PITCH_ENV_IDX
        .byte FAMISTUDIO_N163_CH4_PITCH_ENV_IDX
        .byte FAMISTUDIO_N163_CH5_PITCH_ENV_IDX
        .byte FAMISTUDIO_N163_CH6_PITCH_ENV_IDX
        .byte FAMISTUDIO_N163_CH7_PITCH_ENV_IDX
    .endif
    .if FAMISTUDIO_EXP_S5B    
        .byte FAMISTUDIO_S5B_CH0_PITCH_ENV_IDX
        .byte FAMISTUDIO_S5B_CH1_PITCH_ENV_IDX
        .byte FAMISTUDIO_S5B_CH2_PITCH_ENV_IDX
    .endif
    .if FAMISTUDIO_EXP_EPSM
    .byte FAMISTUDIO_EPSM_CH0_PITCH_ENV_IDX
    .byte FAMISTUDIO_EPSM_CH1_PITCH_ENV_IDX
    .byte FAMISTUDIO_EPSM_CH2_PITCH_ENV_IDX
    .byte FAMISTUDIO_EPSM_CH3_PITCH_ENV_IDX
    .byte FAMISTUDIO_EPSM_CH4_PITCH_ENV_IDX
    .byte FAMISTUDIO_EPSM_CH5_PITCH_ENV_IDX
    .byte FAMISTUDIO_EPSM_CH6_PITCH_ENV_IDX
    .byte FAMISTUDIO_EPSM_CH7_PITCH_ENV_IDX
    .byte FAMISTUDIO_EPSM_CH8_PITCH_ENV_IDX
    .byte FAMISTUDIO_EPSM_CH9_PITCH_ENV_IDX
    .byte FAMISTUDIO_EPSM_CH10_PITCH_ENV_IDX
    .byte FAMISTUDIO_EPSM_CH11_PITCH_ENV_IDX
    .byte FAMISTUDIO_EPSM_CH12_PITCH_ENV_IDX
    .byte FAMISTUDIO_EPSM_CH13_PITCH_ENV_IDX
    .byte FAMISTUDIO_EPSM_CH14_PITCH_ENV_IDX
    .endif

    .if FAMISTUDIO_USE_DUTYCYCLE_EFFECT
; For a given channel, returns the index of the duty cycle in the "famistudio_duty_cycle" array.
famistudio_channel_to_dutycycle:
    .byte 0x00
    .byte 0x01
    .byte 0xff
    .byte 0x02
    .byte 0xff
    .if FAMISTUDIO_EXP_VRC6
        .byte FAMISTUDIO_VRC6_CH0_DUTY_IDX
        .byte FAMISTUDIO_VRC6_CH1_DUTY_IDX
        .byte FAMISTUDIO_VRC6_CH2_DUTY_IDX
    .endif
    .if FAMISTUDIO_EXP_MMC5
        .byte FAMISTUDIO_MMC5_CH0_DUTY_IDX
        .byte FAMISTUDIO_MMC5_CH1_DUTY_IDX
    .endif

; For a given channel, returns the index of the duty cycle envelope.
famistudio_channel_to_duty_env:
    .byte FAMISTUDIO_CH0_ENVS+FAMISTUDIO_ENV_DUTY_OFF
    .byte FAMISTUDIO_CH1_ENVS+FAMISTUDIO_ENV_DUTY_OFF
    .byte 0xff
    .byte FAMISTUDIO_CH3_ENVS+FAMISTUDIO_ENV_DUTY_OFF
    .byte 0xff
    .if FAMISTUDIO_EXP_VRC6
        .byte FAMISTUDIO_VRC6_CH0_ENVS+FAMISTUDIO_ENV_DUTY_OFF
        .byte FAMISTUDIO_VRC6_CH1_ENVS+FAMISTUDIO_ENV_DUTY_OFF
        .byte FAMISTUDIO_VRC6_CH2_ENVS+FAMISTUDIO_ENV_DUTY_OFF
    .endif
    .if FAMISTUDIO_EXP_MMC5
        .byte FAMISTUDIO_MMC5_CH0_ENVS+FAMISTUDIO_ENV_DUTY_OFF
        .byte FAMISTUDIO_MMC5_CH1_ENVS+FAMISTUDIO_ENV_DUTY_OFF
    .endif
    .endif

; Duty lookup table.
famistudio_duty_lookup:
    .byte 0x30
    .byte 0x70
    .byte 0xb0
    .byte 0xf0

    .if FAMISTUDIO_EXP_VRC6
; Duty lookup table for VRC6.
famistudio_vrc6_duty_lookup:
    .byte 0x00
    .byte 0x10
    .byte 0x20
    .byte 0x30
    .byte 0x40
    .byte 0x50
    .byte 0x60
    .byte 0x70
    .endif

    .if FAMISTUDIO_USE_PHASE_RESET
; For a given channel, returns the bit mask to set in the phase reset byte
famistudio_channel_to_phase_reset_mask:
    .byte 0x01
    .byte 0x02
    .ifeq FAMISTUDIO_EXP_NONE
    .byte 0xff
    .byte 0xff
    .byte 0xff
    .if FAMISTUDIO_EXP_VRC6
    .byte 0x04
    .byte 0x08
    .byte 0x10
    .endif
    .if FAMISTUDIO_EXP_FDS
    .byte 0x80
    .endif
    .if FAMISTUDIO_EXP_MMC5    
    .byte 0x20
    .byte 0x40
    .endif
    .if FAMISTUDIO_EXP_N163    
    .byte 0x01
    .byte 0x02
    .byte 0x04
    .byte 0x08
    .byte 0x10
    .byte 0x20
    .byte 0x40
    .byte 0x80
    .endif
    .endif
    .endif

    .ifeq FAMISTUDIO_USE_FAMITRACKER_TEMPO
famistudio_tempo_frame_lookup:
    .byte 0x01, 0x02 ; NTSC -> NTSC, NTSC -> PAL
    .byte 0x00, 0x01 ; PAL  -> NTSC, PAL  -> PAL
    .endif

    .if FAMISTUDIO_CFG_SMOOTH_VIBRATO
; lookup table for the 2 registers we need to set for smooth vibrato.
; Index 0 decrement the hi-period, index 2 increments. Index 1 is unused. 
famistudio_smooth_vibrato_period_lo_lookup:
    .byte 0x00, 0x00, 0xff
famistudio_smooth_vibrato_sweep_lookup:
    .byte 0x8f, 0x00, 0x87
    .endif

    .if FAMISTUDIO_USE_VOLUME_TRACK

; Precomputed volume multiplication table (rounded but never to zero unless one of the value is zero).
; Load the 2 volumes in the lo/hi nibble and fetch.

famistudio_volume_table:
    .byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .byte 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01
    .byte 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x02, 0x02, 0x02, 0x02
    .byte 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x02, 0x02, 0x02, 0x02, 0x02, 0x03, 0x03, 0x03
    .byte 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x02, 0x02, 0x02, 0x02, 0x03, 0x03, 0x03, 0x03, 0x04, 0x04
    .byte 0x00, 0x01, 0x01, 0x01, 0x01, 0x02, 0x02, 0x02, 0x03, 0x03, 0x03, 0x04, 0x04, 0x04, 0x05, 0x05
    .byte 0x00, 0x01, 0x01, 0x01, 0x02, 0x02, 0x02, 0x03, 0x03, 0x04, 0x04, 0x04, 0x05, 0x05, 0x06, 0x06
    .byte 0x00, 0x01, 0x01, 0x01, 0x02, 0x02, 0x03, 0x03, 0x04, 0x04, 0x05, 0x05, 0x06, 0x06, 0x07, 0x07
    .byte 0x00, 0x01, 0x01, 0x02, 0x02, 0x03, 0x03, 0x04, 0x04, 0x05, 0x05, 0x06, 0x06, 0x07, 0x07, 0x08
    .byte 0x00, 0x01, 0x01, 0x02, 0x02, 0x03, 0x04, 0x04, 0x05, 0x05, 0x06, 0x07, 0x07, 0x08, 0x08, 0x09
    .byte 0x00, 0x01, 0x01, 0x02, 0x03, 0x03, 0x04, 0x05, 0x05, 0x06, 0x07, 0x07, 0x08, 0x09, 0x09, 0x0a
    .byte 0x00, 0x01, 0x01, 0x02, 0x03, 0x04, 0x04, 0x05, 0x06, 0x07, 0x07, 0x08, 0x09, 0x0a, 0x0a, 0x0b
    .byte 0x00, 0x01, 0x02, 0x02, 0x03, 0x04, 0x05, 0x06, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0a, 0x0b, 0x0c
    .byte 0x00, 0x01, 0x02, 0x03, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0a, 0x0b, 0x0c, 0x0d
    .byte 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e
    .byte 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f

    .endif
