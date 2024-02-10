; This file is for the FamiStudio Sound Engine and was generated by FamiStudio

.if FAMISTUDIO_CFG_C_BINDINGS

.endif

_music_data_shatterhand:
	.db 1
	.dw song_shatterhand_sdcc_instruments
	.dw song_shatterhand_sdcc_samples-4
	.dw song_shatterhand_sdcc_song0ch0,song_shatterhand_sdcc_song0ch1,song_shatterhand_sdcc_song0ch2,song_shatterhand_sdcc_song0ch3,song_shatterhand_sdcc_song0ch4 ; 00 : Final Area
	.db <(song_shatterhand_sdcc_tempo_env_1_mid), >(song_shatterhand_sdcc_tempo_env_1_mid), 0, 0




song_shatterhand_sdcc_instruments:
	.dw song_shatterhand_sdcc_env3,song_shatterhand_sdcc_env6,song_shatterhand_sdcc_env9,song_shatterhand_sdcc_env0 ; 00 : Bass
	.dw song_shatterhand_sdcc_env5,song_shatterhand_sdcc_env1,song_shatterhand_sdcc_env9,song_shatterhand_sdcc_env0 ; 01 : BassDrum
	.dw song_shatterhand_sdcc_env10,song_shatterhand_sdcc_env8,song_shatterhand_sdcc_env9,song_shatterhand_sdcc_env0 ; 02 : CymbalHigh
	.dw song_shatterhand_sdcc_env14,song_shatterhand_sdcc_env7,song_shatterhand_sdcc_env9,song_shatterhand_sdcc_env0 ; 03 : CymbalLow
	.dw song_shatterhand_sdcc_env2,song_shatterhand_sdcc_env6,song_shatterhand_sdcc_env9,song_shatterhand_sdcc_env4 ; 04 : Lead-Duty0
	.dw song_shatterhand_sdcc_env2,song_shatterhand_sdcc_env6,song_shatterhand_sdcc_env12,song_shatterhand_sdcc_env4 ; 05 : Lead-Duty1
	.dw song_shatterhand_sdcc_env2,song_shatterhand_sdcc_env6,song_shatterhand_sdcc_env11,song_shatterhand_sdcc_env4 ; 06 : Lead-Duty2
	.dw song_shatterhand_sdcc_env13,song_shatterhand_sdcc_env8,song_shatterhand_sdcc_env9,song_shatterhand_sdcc_env0 ; 07 : Snare

song_shatterhand_sdcc_env0:
	.db 0x00,0xc0,0x7f,0x00,0x02
song_shatterhand_sdcc_env1:
	.db 0xc0,0xbf,0xc1,0x00,0x02
song_shatterhand_sdcc_env2:
	.db 0x06,0xc8,0xc9,0xc5,0x00,0x03,0xc4,0xc4,0xc2,0x00,0x08
song_shatterhand_sdcc_env3:
	.db 0x00,0xcf,0x7f,0x00,0x02
song_shatterhand_sdcc_env4:
	.db 0x00,0xc0,0x08,0xc0,0x04,0xbd,0x03,0xbd,0x00,0x03
song_shatterhand_sdcc_env5:
	.db 0x00,0xcf,0xca,0xc3,0xc2,0xc0,0x00,0x05
song_shatterhand_sdcc_env6:
	.db 0xc0,0x7f,0x00,0x01
song_shatterhand_sdcc_env7:
	.db 0xc0,0xc2,0xc5,0x00,0x02
song_shatterhand_sdcc_env8:
	.db 0xc0,0xc1,0xc2,0x00,0x02
song_shatterhand_sdcc_env9:
	.db 0x7f,0x00,0x00
song_shatterhand_sdcc_env10:
	.db 0x00,0xcb,0xca,0x09,0xc9,0x00,0x04
song_shatterhand_sdcc_env11:
	.db 0xc2,0x7f,0x00,0x00
song_shatterhand_sdcc_env12:
	.db 0xc1,0x7f,0x00,0x00
song_shatterhand_sdcc_env13:
	.db 0x00,0xca,0xc6,0xc3,0xc0,0x00,0x04
song_shatterhand_sdcc_env14:
	.db 0x00,0xcb,0xcb,0xc5,0x03,0xc4,0x03,0xc3,0x03,0xc2,0x00,0x09

song_shatterhand_sdcc_samples:

song_shatterhand_sdcc_tempo_env_1_mid:
	.db 0x03,0x05,0x80

song_shatterhand_sdcc_song0ch0:
song_shatterhand_sdcc_song0ch0loop:
	.db 0x46, <(song_shatterhand_sdcc_tempo_env_1_mid), >(song_shatterhand_sdcc_tempo_env_1_mid), 0x7e, 0x88
song_shatterhand_sdcc_song0ref7:
	.db 0x16, 0x9b, 0x44, 0x83, 0x19, 0x89, 0x44, 0x81, 0x43, 0x16, 0x16, 0x9b, 0x44, 0x83, 0x1b, 0x89, 0x44, 0x81, 0x43, 0x16, 0x16, 0x9b, 0x44, 0x83
	.db 0x1e, 0x89, 0x44, 0x81, 0x43, 0x16, 0x16, 0x9b, 0x44, 0x83, 0x1d, 0x9b, 0x44, 0x83, 0x1b, 0x89, 0x44, 0x81, 0x43, 0x1d
song_shatterhand_sdcc_song0ref51:
	.db 0x19, 0x89, 0x44, 0x81, 0x43, 0x1b, 0x14, 0x89, 0x44, 0x81, 0x43, 0x19, 0x47
	.db 0x41, 0x32
	.dw song_shatterhand_sdcc_song0ref7
	.db 0x47, 0x00, 0x43, 0x19, 0x8d, 0x27, 0x89, 0x44, 0x81, 0x43, 0x14
song_shatterhand_sdcc_song0ref78:
	.db 0x25, 0x89, 0x44, 0x81, 0x43, 0x27, 0x20, 0x89, 0x44, 0x81, 0x43, 0x25, 0x27, 0x89, 0x44, 0x81, 0x43, 0x20
	.db 0x41, 0x0a
	.dw song_shatterhand_sdcc_song0ref78
	.db 0x1b, 0x89, 0x44, 0x81, 0x43, 0x20
	.db 0x41, 0x0a
	.dw song_shatterhand_sdcc_song0ref51
	.db 0x1d, 0x89, 0x44, 0x81, 0x43, 0x14, 0x19, 0x89, 0x44, 0x81, 0x43, 0x1d, 0x14, 0x89, 0x44, 0x81, 0x43, 0x19, 0x11, 0x89, 0x44, 0x81, 0x43, 0x14
song_shatterhand_sdcc_song0ref132:
	.db 0x14, 0x89, 0x44, 0x81, 0x43, 0x11, 0x16, 0x89, 0x44, 0x81, 0x43, 0x14, 0x47, 0x27, 0x89, 0x44, 0x81, 0x43, 0x16, 0x00, 0x43, 0x16, 0x8d, 0x1e
	.db 0x89, 0x44, 0x81, 0x43, 0x27, 0x00, 0x43, 0x27
song_shatterhand_sdcc_song0ref164:
	.db 0x8d, 0x43, 0x1e, 0x8f, 0x20, 0x89, 0x44, 0x81, 0x43, 0x1e, 0x00, 0x43, 0x1e, 0x8d, 0x43, 0x20, 0x8f, 0x1d, 0x89, 0x44, 0x81, 0x43, 0x20, 0x00
	.db 0x43, 0x20, 0x8d, 0x43, 0x1d, 0x8f, 0x1e, 0x89, 0x44, 0x81, 0x43, 0x1d, 0x00, 0x43, 0x1d, 0x8d, 0x1b, 0xad, 0x44, 0x83, 0x47, 0x1d, 0x89, 0x44
	.db 0x81, 0x43, 0x1b, 0x00, 0x43, 0x1b, 0x8d, 0x19, 0x89, 0x44, 0x81, 0x43, 0x1d, 0x1b, 0xd1, 0x44, 0x83, 0x00, 0x43, 0x1b, 0x8d, 0x11, 0x89, 0x44
	.db 0x81, 0x43, 0x1b
	.db 0x41, 0x0a
	.dw song_shatterhand_sdcc_song0ref132
	.db 0x1b, 0x89, 0x44, 0x81, 0x43, 0x16
	.db 0x41, 0x0a
	.dw song_shatterhand_sdcc_song0ref51
song_shatterhand_sdcc_song0ref251:
	.db 0x16, 0x89, 0x44, 0x81, 0x43, 0x14, 0x47, 0x00, 0x43, 0x14, 0x8d, 0x43, 0x16, 0x8f, 0x1e, 0x89, 0x44, 0x81, 0x43, 0x16, 0x00, 0x43, 0x16
	.db 0x41, 0x3c
	.dw song_shatterhand_sdcc_song0ref164
	.db 0x41, 0x0a
	.dw song_shatterhand_sdcc_song0ref132
	.db 0x1b, 0x89, 0x44, 0x81, 0x43, 0x16
	.db 0x41, 0x0a
	.dw song_shatterhand_sdcc_song0ref51
	.db 0x41, 0x0a
	.dw song_shatterhand_sdcc_song0ref251
	.db 0x8a
song_shatterhand_sdcc_song0ref293:
	.db 0x23, 0xad, 0x44, 0x83, 0x25, 0x89, 0x44, 0x81, 0x43, 0x23
song_shatterhand_sdcc_song0ref303:
	.db 0x27, 0x89, 0x44, 0x81, 0x43, 0x25, 0x29, 0x89, 0x44, 0x81, 0x43, 0x27, 0x2a, 0x9b, 0x44, 0x83
song_shatterhand_sdcc_song0ref319:
	.db 0x2c, 0x89, 0x44, 0x81, 0x43, 0x2a, 0x2a, 0x89, 0x44, 0x81, 0x43, 0x2c, 0x00, 0x43, 0x2c, 0x8d, 0x26, 0xad, 0x44, 0x83, 0x47, 0x23, 0xbf, 0x44
	.db 0x83, 0x29, 0x8f, 0x44, 0x81, 0x43, 0x23, 0x27, 0x8f, 0x44, 0x81, 0x43, 0x29, 0x26, 0x8f, 0x44, 0x81, 0x43, 0x27, 0x27, 0x9b, 0x44, 0x83, 0x22
	.db 0x89, 0x44, 0x81, 0x43, 0x27, 0x2a, 0x9b, 0x44, 0x83
song_shatterhand_sdcc_song0ref376:
	.db 0x29, 0x89
song_shatterhand_sdcc_song0ref378:
	.db 0x44, 0x81, 0x43, 0x2a, 0x27, 0x89, 0x44, 0x81, 0x43, 0x29, 0x25, 0x89, 0x44, 0x81, 0x43, 0x27, 0x47, 0x00, 0x43, 0x27, 0x8d, 0x43, 0x25, 0x8f
	.db 0x41, 0x13
	.dw song_shatterhand_sdcc_song0ref293
	.db 0x25, 0x9b, 0x44, 0x83
	.db 0x41, 0x0a
	.dw song_shatterhand_sdcc_song0ref303
	.db 0x00, 0x43, 0x27, 0x8d, 0x2a, 0xad, 0x44, 0x83, 0x47, 0x2c, 0xbf
song_shatterhand_sdcc_song0ref423:
	.db 0x44, 0x83, 0x2c, 0x89, 0x44, 0x83, 0x2e, 0x89, 0x44, 0x81, 0x43, 0x2c, 0x31, 0x89, 0x44, 0x81, 0x43, 0x2e, 0x2c, 0x89, 0x44, 0x81, 0x43, 0x31
	.db 0x00, 0x43, 0x31, 0x8d, 0x88, 0x1e, 0x89, 0x44, 0x81, 0x43, 0x2c
song_shatterhand_sdcc_song0ref458:
	.db 0x1d, 0x89, 0x44, 0x81, 0x43, 0x1e, 0x19, 0x89, 0x44, 0x81, 0x43, 0x1d, 0x12, 0x89, 0x44, 0x81, 0x43, 0x19, 0x11, 0x89, 0x44, 0x81, 0x43, 0x12
	.db 0x41, 0x55
	.dw song_shatterhand_sdcc_song0ref132
	.db 0x41, 0x0a
	.dw song_shatterhand_sdcc_song0ref132
	.db 0x1b, 0x89, 0x44, 0x81, 0x43, 0x16
	.db 0x41, 0x0a
	.dw song_shatterhand_sdcc_song0ref51
	.db 0x41, 0x11
	.dw song_shatterhand_sdcc_song0ref251
	.db 0x41, 0x3c
	.dw song_shatterhand_sdcc_song0ref164
	.db 0x41, 0x0a
	.dw song_shatterhand_sdcc_song0ref132
	.db 0x1b, 0x89, 0x44, 0x81, 0x43, 0x16
	.db 0x41, 0x0a
	.dw song_shatterhand_sdcc_song0ref51
	.db 0x41, 0x0a
	.dw song_shatterhand_sdcc_song0ref251
	.db 0x25, 0x9b, 0x44, 0x83, 0x25, 0x89, 0x44, 0x83
	.db 0x41, 0x0a
	.dw song_shatterhand_sdcc_song0ref303
	.db 0x29, 0xad, 0x44, 0x83, 0x29, 0x89, 0x44, 0x83, 0x27, 0x89, 0x44, 0x81, 0x43, 0x29, 0x00, 0x43, 0x29, 0x8d, 0x26, 0xad, 0x44, 0x83, 0x47, 0x27
	.db 0xbf, 0x44, 0x83, 0x27, 0x89
song_shatterhand_sdcc_song0ref558:
	.db 0x44, 0x83, 0x29, 0x89, 0x44, 0x81, 0x43, 0x27, 0x2a, 0x89, 0x44, 0x81, 0x43, 0x29, 0x2c, 0xad, 0x44, 0x83, 0x2a, 0x89, 0x44, 0x81, 0x43, 0x2c
	.db 0x29, 0x89, 0x44, 0x81, 0x43, 0x2a, 0x00, 0x43, 0x2a, 0x8d, 0x27, 0xad, 0x44, 0x83, 0x47, 0x00, 0x43, 0x27, 0x9f
song_shatterhand_sdcc_song0ref601:
	.db 0x29, 0x9b, 0x44, 0x83, 0x29, 0x89, 0x44, 0x83, 0x2a, 0x89, 0x44, 0x81, 0x43, 0x29, 0x2c, 0x89, 0x44, 0x81, 0x43, 0x2a, 0x2e, 0xad, 0x44, 0x83
	.db 0x2c, 0x89, 0x44, 0x81, 0x43, 0x2e, 0x2a, 0x89, 0x44, 0x81, 0x43, 0x2c, 0x00, 0x43, 0x2c, 0x8d
	.db 0x41, 0x0a
	.dw song_shatterhand_sdcc_song0ref319
	.db 0x29, 0x89, 0x44, 0x81, 0x43, 0x2a, 0x47, 0x26, 0xbf, 0x44, 0x83, 0x27, 0xbf, 0x44, 0x83, 0x29, 0x89, 0x44, 0x81, 0x43, 0x27, 0x29, 0x8b, 0x44
	.db 0x81, 0x00, 0x43, 0x29, 0x8d, 0x29, 0xd1, 0x44, 0x83, 0x47, 0x2e, 0x89, 0x44, 0x81, 0x43, 0x29
song_shatterhand_sdcc_song0ref684:
	.db 0x27, 0x89, 0x44, 0x81, 0x43, 0x2e, 0x22, 0x89, 0x44, 0x81, 0x43, 0x27, 0x2c, 0x89, 0x44, 0x81, 0x43, 0x22, 0x25, 0x89, 0x44, 0x81, 0x43, 0x2c
	.db 0x20, 0x89, 0x44, 0x81, 0x43, 0x25, 0x1e, 0x9b, 0x44, 0x83, 0x00, 0x43, 0x1e, 0x8d, 0x1e, 0x89, 0x44, 0x83
	.db 0x41, 0x0a
	.dw song_shatterhand_sdcc_song0ref458
	.db 0x1e, 0x89, 0x44, 0x81, 0x43, 0x19
	.db 0x41, 0x0a
	.dw song_shatterhand_sdcc_song0ref458
song_shatterhand_sdcc_song0ref738:
	.db 0x1b, 0x89, 0x44, 0x81, 0x43, 0x19, 0x47, 0x1e, 0x89, 0x44, 0x81, 0x43, 0x1b, 0x1e, 0x89, 0x44, 0x83, 0x00, 0x43, 0x1e, 0x8d, 0x20, 0x89, 0x44
	.db 0x81, 0x43, 0x1e, 0x20, 0x89, 0x44, 0x83, 0x00, 0x43, 0x20, 0x8d, 0x1e, 0x89, 0x44, 0x81, 0x43, 0x20, 0x1e, 0x89, 0x44, 0x83, 0x00, 0x43, 0x1e
	.db 0x8d, 0x20, 0x89, 0x20, 0x81, 0x43, 0x1e, 0x20, 0x89, 0x44, 0x83, 0x00, 0x43, 0x20, 0x8d, 0x27, 0x89, 0x44, 0x81, 0x43, 0x20, 0x25, 0x89, 0x44
	.db 0x81, 0x43, 0x27, 0x23, 0x89, 0x44, 0x81, 0x43, 0x25, 0x22, 0x89, 0x44, 0x81, 0x43, 0x23, 0x47, 0x2e, 0x89, 0x44, 0x81, 0x43, 0x22
	.db 0x41, 0x24
	.dw song_shatterhand_sdcc_song0ref684
	.db 0x41, 0x0a
	.dw song_shatterhand_sdcc_song0ref458
	.db 0x1e, 0x89, 0x44, 0x81, 0x43, 0x19
	.db 0x41, 0x0a
	.dw song_shatterhand_sdcc_song0ref458
	.db 0x41, 0x49
	.dw song_shatterhand_sdcc_song0ref738
	.db 0x47, 0x17, 0x9b, 0x44, 0x83, 0x1e, 0x89, 0x44, 0x81, 0x43, 0x17, 0x19, 0x9b, 0x44, 0x83, 0x20, 0x9b, 0x44, 0x83, 0x1b, 0x9b, 0x44, 0x83, 0x22
	.db 0x9b, 0x44, 0x83, 0x29, 0x89, 0x44, 0x81, 0x43, 0x22, 0x2a, 0x89, 0x44, 0x81, 0x29, 0x8b
	.db 0x41, 0x0d
	.dw song_shatterhand_sdcc_song0ref378
	.db 0x47, 0x2a, 0x89, 0x44, 0x81, 0x43, 0x25, 0x2a, 0x89, 0x44, 0x83, 0x00, 0x43, 0x2a, 0x8d, 0x29, 0x89, 0x44, 0x81, 0x43, 0x2a
song_shatterhand_sdcc_song0ref913:
	.db 0x29, 0x89, 0x44, 0x83, 0x00, 0x43, 0x29, 0x8d, 0x2a, 0x89, 0x44, 0x81, 0x43, 0x29, 0x2a, 0x89, 0x44, 0x83, 0x00, 0x43, 0x2a, 0x8d, 0x11, 0x89
	.db 0x44, 0x81, 0x43, 0x2a, 0x16, 0x89, 0x44, 0x81, 0x43, 0x11, 0x1d, 0x89, 0x44, 0x81, 0x43, 0x16, 0x25, 0x89, 0x44, 0x81, 0x43, 0x1d, 0x29, 0xad
	.db 0x44, 0x83, 0x42
	.dw song_shatterhand_sdcc_song0ch0loop
song_shatterhand_sdcc_song0ch1:
song_shatterhand_sdcc_song0ch1loop:
	.db 0x8a
song_shatterhand_sdcc_song0ref968:
	.db 0x1b, 0x9b, 0x44, 0x83, 0x1e, 0x89, 0x44, 0x81, 0x43, 0x1b, 0x1b, 0x9b, 0x44, 0x83, 0x20, 0x89, 0x44, 0x81, 0x43, 0x1b, 0x1b, 0x9b, 0x44, 0x83
	.db 0x22, 0x89, 0x44, 0x81, 0x43, 0x1b, 0x1b, 0x9b, 0x44, 0x83, 0x20, 0x9b, 0x44, 0x83, 0x1e, 0x89, 0x44, 0x81, 0x43, 0x20
	.db 0x41, 0x0a
	.dw song_shatterhand_sdcc_song0ref458
	.db 0x41, 0x28
	.dw song_shatterhand_sdcc_song0ref968
	.db 0x41, 0x0a
	.dw song_shatterhand_sdcc_song0ref458
	.db 0x00, 0x43, 0x1d, 0x8d, 0x2a, 0x89, 0x44, 0x81, 0x43, 0x19
song_shatterhand_sdcc_song0ref1031:
	.db 0x29, 0x89, 0x44, 0x81, 0x43, 0x2a, 0x25, 0x89, 0x44, 0x81, 0x43, 0x29, 0x2a, 0x89, 0x44, 0x81, 0x43, 0x25
	.db 0x41, 0x0a
	.dw song_shatterhand_sdcc_song0ref1031
	.db 0x1e, 0x89, 0x44, 0x81, 0x43, 0x25
	.db 0x41, 0x0a
	.dw song_shatterhand_sdcc_song0ref458
	.db 0x20, 0x89, 0x44, 0x81, 0x43, 0x19, 0x1d, 0x89, 0x44, 0x81, 0x43, 0x20, 0x19, 0x89, 0x44, 0x81, 0x43, 0x1d, 0x16, 0x89, 0x44, 0x81, 0x43, 0x19
song_shatterhand_sdcc_song0ref1085:
	.db 0x19, 0x89, 0x44, 0x81, 0x43, 0x16
song_shatterhand_sdcc_song0ref1091:
	.db 0x1b, 0x89, 0x44, 0x81, 0x43, 0x19, 0x33, 0x89, 0x44, 0x81, 0x43, 0x1b, 0x00, 0x43, 0x1b, 0x8d, 0x22, 0x89, 0x44, 0x81, 0x43, 0x33, 0x00, 0x43
	.db 0x33
song_shatterhand_sdcc_song0ref1116:
	.db 0x8d, 0x43, 0x22, 0x8f, 0x23, 0x89, 0x44, 0x81, 0x43, 0x22, 0x00, 0x43, 0x22, 0x8d, 0x43, 0x23, 0x8f, 0x20, 0x89, 0x44, 0x81, 0x43, 0x23, 0x00
	.db 0x43, 0x23, 0x8d, 0x43, 0x20, 0x8f, 0x22, 0x89, 0x44, 0x81, 0x43, 0x20, 0x00, 0x43, 0x20, 0x8d, 0x1e, 0xad, 0x44, 0x83, 0x20, 0x89, 0x44, 0x81
	.db 0x43, 0x1e, 0x00, 0x43, 0x1e, 0x8d, 0x1d, 0x89, 0x44, 0x81, 0x43, 0x20, 0x1e, 0xd1, 0x44, 0x83, 0x00, 0x43, 0x1e, 0x8d, 0x16, 0x89, 0x44, 0x81
	.db 0x43, 0x1e
	.db 0x41, 0x0a
	.dw song_shatterhand_sdcc_song0ref1085
	.db 0x1e, 0x89, 0x44, 0x81, 0x43, 0x1b
	.db 0x41, 0x0a
	.dw song_shatterhand_sdcc_song0ref458
song_shatterhand_sdcc_song0ref1202:
	.db 0x1b, 0x89, 0x44, 0x81, 0x43, 0x19, 0x00, 0x43, 0x19, 0x8d, 0x43, 0x1b, 0x8f, 0x22, 0x89, 0x44, 0x81, 0x43, 0x1b, 0x00, 0x43, 0x1b
	.db 0x41, 0x3c
	.dw song_shatterhand_sdcc_song0ref1116
	.db 0x41, 0x0a
	.dw song_shatterhand_sdcc_song0ref1085
	.db 0x1e, 0x89, 0x44, 0x81, 0x43, 0x1b
	.db 0x41, 0x0a
	.dw song_shatterhand_sdcc_song0ref458
	.db 0x41, 0x0a
	.dw song_shatterhand_sdcc_song0ref1202
	.db 0x8c, 0x27, 0xad
	.db 0x41, 0x0d
	.dw song_shatterhand_sdcc_song0ref558
song_shatterhand_sdcc_song0ref1248:
	.db 0x89, 0x44, 0x81, 0x43, 0x2a, 0x2e, 0x9b, 0x44, 0x83
song_shatterhand_sdcc_song0ref1257:
	.db 0x2f, 0x89, 0x44, 0x81, 0x43, 0x2e, 0x2e, 0x89, 0x44, 0x81, 0x43, 0x2f, 0x00, 0x43, 0x2f, 0x8d, 0x29, 0xad, 0x44, 0x83, 0x2c, 0xbf, 0x44, 0x83
	.db 0x2c, 0x8f, 0x44, 0x83, 0x2a, 0x8f, 0x44, 0x81, 0x43, 0x2c, 0x29, 0x8f, 0x44, 0x81, 0x43, 0x2a, 0x2a, 0x9b, 0x44, 0x83, 0x27, 0x89, 0x44, 0x81
	.db 0x43, 0x2a, 0x2e, 0xd1, 0x44, 0x83, 0x00, 0x43, 0x2e, 0x9f, 0x27, 0xad
	.db 0x41, 0x0d
	.dw song_shatterhand_sdcc_song0ref558
	.db 0x41, 0x0d
	.dw song_shatterhand_sdcc_song0ref1248
	.db 0x31, 0x89, 0x44, 0x81, 0x43, 0x2f, 0x00, 0x43, 0x2f, 0x8d, 0x33, 0xad, 0x44, 0x83, 0x35, 0xbf, 0x44, 0x83, 0x35, 0x89, 0x44, 0x83, 0x36, 0x89
	.db 0x44, 0x81, 0x43, 0x35, 0x38, 0x89, 0x44, 0x81, 0x43, 0x36, 0x35, 0x89, 0x44, 0x81, 0x43, 0x38, 0x00, 0x43, 0x38, 0x8d, 0x8a, 0x2a, 0x89, 0x44
	.db 0x81, 0x43, 0x35
	.db 0x41, 0x0a
	.dw song_shatterhand_sdcc_song0ref1031
	.db 0x1e, 0x89, 0x44, 0x81, 0x43, 0x25
	.db 0x41, 0x0a
	.dw song_shatterhand_sdcc_song0ref458
	.db 0x41, 0x50
	.dw song_shatterhand_sdcc_song0ref1091
	.db 0x41, 0x0a
	.dw song_shatterhand_sdcc_song0ref1085
	.db 0x1e, 0x89, 0x44, 0x81, 0x43, 0x1b
	.db 0x41, 0x0a
	.dw song_shatterhand_sdcc_song0ref458
	.db 0x41, 0x11
	.dw song_shatterhand_sdcc_song0ref1202
	.db 0x41, 0x3c
	.dw song_shatterhand_sdcc_song0ref1116
	.db 0x41, 0x0a
	.dw song_shatterhand_sdcc_song0ref1085
	.db 0x1e, 0x89, 0x44, 0x81, 0x43, 0x1b
	.db 0x41, 0x0a
	.dw song_shatterhand_sdcc_song0ref458
	.db 0x41, 0x0a
	.dw song_shatterhand_sdcc_song0ref1202
	.db 0x41, 0x23
	.dw song_shatterhand_sdcc_song0ref601
	.db 0x29, 0xad, 0x44, 0x83, 0x2a, 0xbf, 0x44, 0x83, 0x2a, 0x8b, 0x44, 0x81, 0x2c, 0x89, 0x44, 0x81, 0x43, 0x2a, 0x2e, 0x89, 0x44, 0x81, 0x43, 0x2c
	.db 0x2f, 0xad, 0x44, 0x83, 0x2e, 0x89, 0x44, 0x81, 0x43, 0x2f, 0x2c, 0x89, 0x44, 0x81, 0x43, 0x2e, 0x00, 0x43, 0x2e, 0x8d, 0x2a, 0xad, 0x44, 0x83
	.db 0x00, 0x43, 0x2a, 0x9f, 0x2c, 0x9b
	.db 0x41, 0x0b
	.dw song_shatterhand_sdcc_song0ref423
	.db 0x2f, 0x89, 0x44, 0x81, 0x43, 0x2e, 0x31, 0xad, 0x44, 0x83, 0x2f, 0x89, 0x44, 0x81, 0x43, 0x31, 0x2e, 0x89, 0x44, 0x81, 0x43, 0x2f, 0x00, 0x43
	.db 0x2f, 0x8d
	.db 0x41, 0x0a
	.dw song_shatterhand_sdcc_song0ref1257
	.db 0x2c, 0x89, 0x44, 0x81, 0x43, 0x2e, 0x2e, 0xbf, 0x44, 0x83, 0x30, 0xbf, 0x44, 0x83, 0x31, 0x89, 0x44, 0x81, 0x43, 0x30, 0x31, 0x89, 0x44, 0x83
	.db 0x00, 0x43, 0x31, 0x8d, 0x32, 0xd1, 0x44, 0x83, 0x33, 0x89, 0x44, 0x81, 0x43, 0x32
song_shatterhand_sdcc_song0ref1549:
	.db 0x2e, 0x89, 0x44, 0x81, 0x43, 0x33, 0x27, 0x89, 0x44, 0x81, 0x43, 0x2e, 0x31, 0x89, 0x44, 0x81, 0x43, 0x27, 0x2c, 0x89, 0x44, 0x81, 0x43, 0x31
	.db 0x25, 0x89, 0x44, 0x81, 0x43, 0x2c, 0x23, 0x9b, 0x44, 0x83, 0x00, 0x43, 0x23, 0x8d, 0x2a, 0x89, 0x44, 0x81, 0x43, 0x23
	.db 0x41, 0x0f
	.dw song_shatterhand_sdcc_song0ref1031
	.db 0x41, 0x0a
	.dw song_shatterhand_sdcc_song0ref1031
song_shatterhand_sdcc_song0ref1599:
	.db 0x27, 0x89, 0x44, 0x81, 0x43, 0x25, 0x23, 0x89, 0x44, 0x81, 0x43, 0x27, 0x23, 0x89, 0x44, 0x83, 0x00, 0x43, 0x23, 0x8d, 0x25, 0x89, 0x44, 0x81
	.db 0x43, 0x23, 0x25, 0x89, 0x44, 0x83, 0x00, 0x43, 0x25, 0x8d, 0x27, 0x89, 0x44, 0x81, 0x43, 0x25, 0x27, 0x89, 0x44, 0x83, 0x00, 0x43, 0x27, 0x8d
	.db 0x29, 0x89, 0x44, 0x81, 0x43, 0x27
	.db 0x41, 0x0c
	.dw song_shatterhand_sdcc_song0ref913
	.db 0x41, 0x0f
	.dw song_shatterhand_sdcc_song0ref376
	.db 0x33, 0x89, 0x44, 0x81, 0x43, 0x25
	.db 0x41, 0x25
	.dw song_shatterhand_sdcc_song0ref1549
	.db 0x41, 0x0f
	.dw song_shatterhand_sdcc_song0ref1031
	.db 0x41, 0x0a
	.dw song_shatterhand_sdcc_song0ref1031
	.db 0x41, 0x2e
	.dw song_shatterhand_sdcc_song0ref1599
	.db 0x41, 0x0c
	.dw song_shatterhand_sdcc_song0ref913
	.db 0x41, 0x0f
	.dw song_shatterhand_sdcc_song0ref376
	.db 0x23, 0x9b, 0x44, 0x83, 0x2a, 0x89, 0x44, 0x81, 0x43, 0x23, 0x25, 0x9b, 0x44, 0x83, 0x2c, 0x9b, 0x44, 0x83, 0x27, 0x9b, 0x44, 0x83, 0x2e, 0x9b
	.db 0x44, 0x83, 0x35, 0x89, 0x44, 0x81, 0x43, 0x2e, 0x36, 0x89, 0x44, 0x81, 0x43, 0x35, 0x35, 0x89, 0x44, 0x81, 0x43, 0x36, 0x33, 0x89, 0x44, 0x81
	.db 0x43, 0x35, 0x31, 0x89, 0x44, 0x81, 0x43, 0x33
song_shatterhand_sdcc_song0ref1739:
	.db 0x33, 0x89, 0x44, 0x81, 0x43, 0x31, 0x33, 0x89, 0x44, 0x83, 0x00, 0x43, 0x33, 0x8d, 0x31, 0x89, 0x44, 0x81, 0x43, 0x33, 0x31, 0x89, 0x44, 0x83
	.db 0x00, 0x43, 0x31, 0x8d
	.db 0x41, 0x0c
	.dw song_shatterhand_sdcc_song0ref1739
	.db 0x16, 0x89, 0x44, 0x81, 0x43, 0x33, 0x1d, 0x89, 0x44, 0x81, 0x43, 0x16, 0x22, 0x89, 0x44, 0x81, 0x43, 0x1d, 0x29, 0x89, 0x44, 0x81, 0x43, 0x22
	.db 0x2e, 0xad, 0x44, 0x83, 0x42
	.dw song_shatterhand_sdcc_song0ch1loop
song_shatterhand_sdcc_song0ch2:
song_shatterhand_sdcc_song0ch2loop:
	.db 0x80
song_shatterhand_sdcc_song0ref1803:
	.db 0x1b
song_shatterhand_sdcc_song0ref1804:
	.db 0x8b
song_shatterhand_sdcc_song0ref1805:
	.db 0x00, 0x81, 0x1b, 0x8b, 0x00, 0x81, 0x1b, 0x8b, 0x00, 0x81
	.db 0x41, 0x0c
	.dw song_shatterhand_sdcc_song0ref1803
	.db 0x41, 0x0c
	.dw song_shatterhand_sdcc_song0ref1803
	.db 0x1b, 0x8b, 0x00, 0x81, 0x1b, 0x8b, 0x00, 0x81
song_shatterhand_sdcc_song0ref1829:
	.db 0x19, 0x9d
song_shatterhand_sdcc_song0ref1831:
	.db 0x00, 0x81, 0x16, 0x8b, 0x00, 0x81, 0x19, 0x8b, 0x00, 0x81, 0x1d
	.db 0x41, 0x0b
	.dw song_shatterhand_sdcc_song0ref1804
	.db 0x41, 0x0c
	.dw song_shatterhand_sdcc_song0ref1803
	.db 0x41, 0x0c
	.dw song_shatterhand_sdcc_song0ref1803
	.db 0x41, 0x0c
	.dw song_shatterhand_sdcc_song0ref1803
	.db 0x41, 0x0d
	.dw song_shatterhand_sdcc_song0ref1829
	.db 0x8b, 0x00, 0x81, 0x19, 0xf7, 0x00, 0x81, 0x19, 0xd3, 0x00, 0x81, 0x19, 0x8b
	.db 0x41, 0x0a
	.dw song_shatterhand_sdcc_song0ref1831
	.db 0x41, 0x0c
	.dw song_shatterhand_sdcc_song0ref1803
	.db 0x41, 0x0c
	.dw song_shatterhand_sdcc_song0ref1803
	.db 0x41, 0x0c
	.dw song_shatterhand_sdcc_song0ref1803
	.db 0x41, 0x0c
	.dw song_shatterhand_sdcc_song0ref1803
	.db 0x41, 0x0c
	.dw song_shatterhand_sdcc_song0ref1803
	.db 0x41, 0x0c
	.dw song_shatterhand_sdcc_song0ref1803
	.db 0x41, 0x0c
	.dw song_shatterhand_sdcc_song0ref1803
	.db 0x41, 0x0c
	.dw song_shatterhand_sdcc_song0ref1803
	.db 0x1b, 0x8b, 0x00, 0x81, 0x1b, 0x8b
	.db 0x41, 0x0a
	.dw song_shatterhand_sdcc_song0ref1831
song_shatterhand_sdcc_song0ref1906:
	.db 0x1b, 0x8b, 0x00, 0x81
song_shatterhand_sdcc_song0ref1910:
	.db 0x1e
song_shatterhand_sdcc_song0ref1911:
	.db 0x8b, 0x00, 0x81, 0x1d
song_shatterhand_sdcc_song0ref1915:
	.db 0x8b, 0x00, 0x81, 0x19, 0x8b, 0x00, 0x81, 0x1b
song_shatterhand_sdcc_song0ref1923:
	.db 0x8b, 0x00, 0x81, 0x17, 0x8b, 0x00, 0x81, 0x17, 0x8b, 0x00, 0x81, 0x17
	.db 0x41, 0x0c
	.dw song_shatterhand_sdcc_song0ref1923
	.db 0x41, 0x0c
	.dw song_shatterhand_sdcc_song0ref1923
	.db 0x41, 0x0c
	.dw song_shatterhand_sdcc_song0ref1923
	.db 0x41, 0x0c
	.dw song_shatterhand_sdcc_song0ref1923
	.db 0x41, 0x0c
	.dw song_shatterhand_sdcc_song0ref1923
	.db 0x41, 0x0c
	.dw song_shatterhand_sdcc_song0ref1923
	.db 0x41, 0x0c
	.dw song_shatterhand_sdcc_song0ref1923
	.db 0x8b, 0x00, 0x81, 0x17, 0x8b
	.db 0x41, 0x0a
	.dw song_shatterhand_sdcc_song0ref1831
	.db 0x41, 0x14
	.dw song_shatterhand_sdcc_song0ref1906
song_shatterhand_sdcc_song0ref1967:
	.db 0x14, 0x8b, 0x00, 0x81, 0x14, 0x8b, 0x00, 0x81, 0x1b, 0x8b, 0x00, 0x81, 0x1e, 0x8b, 0x00, 0x81
	.db 0x41, 0x10
	.dw song_shatterhand_sdcc_song0ref1967
song_shatterhand_sdcc_song0ref1986:
	.db 0x16
song_shatterhand_sdcc_song0ref1987:
	.db 0x8b, 0x00, 0x81, 0x16, 0x8b, 0x00, 0x81, 0x1d, 0x8b, 0x00, 0x81, 0x20, 0x8b, 0x00, 0x81
	.db 0x41, 0x10
	.dw song_shatterhand_sdcc_song0ref1986
	.db 0x41, 0x10
	.dw song_shatterhand_sdcc_song0ref1967
	.db 0x41, 0x10
	.dw song_shatterhand_sdcc_song0ref1986
song_shatterhand_sdcc_song0ref2011:
	.db 0x1b, 0x8b, 0x00, 0x81, 0x1b, 0x8b, 0x00, 0x81, 0x19, 0x8b, 0x00, 0x81, 0x19
	.db 0x41, 0x0b
	.dw song_shatterhand_sdcc_song0ref1923
	.db 0x16, 0x8b, 0x00, 0x81, 0x16, 0x8b, 0x00, 0x81
	.db 0x41, 0x10
	.dw song_shatterhand_sdcc_song0ref1967
	.db 0x41, 0x10
	.dw song_shatterhand_sdcc_song0ref1967
	.db 0x41, 0x10
	.dw song_shatterhand_sdcc_song0ref1986
	.db 0x41, 0x10
	.dw song_shatterhand_sdcc_song0ref1986
	.db 0x17
song_shatterhand_sdcc_song0ref2048:
	.db 0x8b, 0x00, 0x81, 0x17, 0x8b, 0x00, 0x81, 0x1e, 0x8b, 0x00, 0x81, 0x23
	.db 0x41, 0x0c
	.dw song_shatterhand_sdcc_song0ref2048
	.db 0x8b, 0x00, 0x81, 0x19, 0x8b, 0x00, 0x93, 0x19, 0x8b, 0x00, 0x81, 0x19, 0x9d, 0x00, 0x81, 0x19, 0x8b, 0x00, 0x81, 0x19, 0x9d
	.db 0x41, 0x0a
	.dw song_shatterhand_sdcc_song0ref1805
	.db 0x41, 0x0c
	.dw song_shatterhand_sdcc_song0ref1803
	.db 0x41, 0x0c
	.dw song_shatterhand_sdcc_song0ref1803
	.db 0x41, 0x0c
	.dw song_shatterhand_sdcc_song0ref1803
	.db 0x41, 0x0c
	.dw song_shatterhand_sdcc_song0ref1803
	.db 0x41, 0x0c
	.dw song_shatterhand_sdcc_song0ref1803
	.db 0x41, 0x0c
	.dw song_shatterhand_sdcc_song0ref1803
	.db 0x41, 0x0c
	.dw song_shatterhand_sdcc_song0ref1803
	.db 0x41, 0x0c
	.dw song_shatterhand_sdcc_song0ref1803
	.db 0x16
	.db 0x41, 0x0b
	.dw song_shatterhand_sdcc_song0ref1915
	.db 0x41, 0x19
	.dw song_shatterhand_sdcc_song0ref1910
	.db 0x41, 0x0c
	.dw song_shatterhand_sdcc_song0ref1923
	.db 0x41, 0x0c
	.dw song_shatterhand_sdcc_song0ref1923
	.db 0x41, 0x0c
	.dw song_shatterhand_sdcc_song0ref1923
	.db 0x41, 0x0c
	.dw song_shatterhand_sdcc_song0ref1923
	.db 0x41, 0x0c
	.dw song_shatterhand_sdcc_song0ref1923
	.db 0x41, 0x0c
	.dw song_shatterhand_sdcc_song0ref1923
	.db 0x41, 0x0c
	.dw song_shatterhand_sdcc_song0ref1923
	.db 0x8b, 0x00, 0x81, 0x17, 0x8b
	.db 0x41, 0x0a
	.dw song_shatterhand_sdcc_song0ref1831
	.db 0x41, 0x14
	.dw song_shatterhand_sdcc_song0ref1906
song_shatterhand_sdcc_song0ref2150:
	.db 0x19
song_shatterhand_sdcc_song0ref2151:
	.db 0x8b, 0x00, 0x81, 0x19, 0x8b, 0x00, 0x81, 0x19, 0x8b, 0x00, 0x81
	.db 0x41, 0x0c
	.dw song_shatterhand_sdcc_song0ref2150
	.db 0x19, 0x8b, 0x00, 0x81, 0x19
song_shatterhand_sdcc_song0ref2170:
	.db 0x8b, 0x00, 0x81, 0x1a, 0x8b, 0x00, 0x81, 0x1a, 0x8b, 0x00, 0x81, 0x1a
	.db 0x41, 0x0c
	.dw song_shatterhand_sdcc_song0ref2170
	.db 0x41, 0x0b
	.dw song_shatterhand_sdcc_song0ref2170
	.db 0x41, 0x0c
	.dw song_shatterhand_sdcc_song0ref1803
	.db 0x41, 0x0c
	.dw song_shatterhand_sdcc_song0ref1803
	.db 0x1b, 0x8b, 0x00, 0x81, 0x1b
song_shatterhand_sdcc_song0ref2199:
	.db 0x8b, 0x00, 0x81, 0x1c, 0x8b, 0x00, 0x81, 0x1c, 0x8b, 0x00, 0x81, 0x1c
	.db 0x41, 0x0c
	.dw song_shatterhand_sdcc_song0ref2199
	.db 0x41, 0x0b
	.dw song_shatterhand_sdcc_song0ref2199
song_shatterhand_sdcc_song0ref2217:
	.db 0x1d, 0x8b, 0x00, 0x81, 0x1d, 0x8b, 0x00, 0x81, 0x1d, 0x8b, 0x00, 0x81
	.db 0x41, 0x0c
	.dw song_shatterhand_sdcc_song0ref2217
	.db 0x1d
	.db 0x41, 0x0b
	.dw song_shatterhand_sdcc_song0ref1911
	.db 0x41, 0x0c
	.dw song_shatterhand_sdcc_song0ref2150
	.db 0x41, 0x0c
	.dw song_shatterhand_sdcc_song0ref2150
	.db 0x19
song_shatterhand_sdcc_song0ref2243:
	.db 0x8b, 0x00, 0x81, 0x16, 0x8b, 0x00, 0x81, 0x16, 0x8b, 0x00, 0x81, 0x16
	.db 0x41, 0x0c
	.dw song_shatterhand_sdcc_song0ref2243
	.db 0x41, 0x0c
	.dw song_shatterhand_sdcc_song0ref2243
	.db 0x41, 0x0b
	.dw song_shatterhand_sdcc_song0ref1987
	.db 0x22, 0x9d, 0x00, 0x81, 0x22, 0x8b, 0x00, 0x81, 0x1d, 0x8b, 0x00, 0x81, 0x16
	.db 0x41, 0x0b
	.dw song_shatterhand_sdcc_song0ref1804
	.db 0x1b
	.db 0x41, 0x0b
	.dw song_shatterhand_sdcc_song0ref2151
song_shatterhand_sdcc_song0ref2284:
	.db 0x19, 0x8b, 0x00, 0x81, 0x17, 0xaf, 0x00, 0x81, 0x17, 0x8b, 0x00, 0x81, 0x17, 0x9d, 0x00, 0x81, 0x17, 0x8b, 0x00, 0x81, 0x17, 0x9d, 0x00, 0x81
	.db 0x17
song_shatterhand_sdcc_song0ref2309:
	.db 0x8b, 0x00, 0x81, 0x14, 0x8b, 0x00, 0x81, 0x14, 0x8b, 0x00, 0x81, 0x14
	.db 0x41, 0x0c
	.dw song_shatterhand_sdcc_song0ref2243
	.db 0x41, 0x0c
	.dw song_shatterhand_sdcc_song0ref1923
	.db 0x41, 0x0b
	.dw song_shatterhand_sdcc_song0ref2151
	.db 0x19
	.db 0x41, 0x0b
	.dw song_shatterhand_sdcc_song0ref1923
	.db 0x19
	.db 0x41, 0x0b
	.dw song_shatterhand_sdcc_song0ref1915
	.db 0x41, 0x0d
	.dw song_shatterhand_sdcc_song0ref2011
	.db 0x8b, 0x00, 0x81
	.db 0x41, 0x25
	.dw song_shatterhand_sdcc_song0ref2284
	.db 0x41, 0x0c
	.dw song_shatterhand_sdcc_song0ref2243
	.db 0x41, 0x0c
	.dw song_shatterhand_sdcc_song0ref1923
	.db 0x41, 0x0b
	.dw song_shatterhand_sdcc_song0ref2151
	.db 0x19
	.db 0x41, 0x0b
	.dw song_shatterhand_sdcc_song0ref1923
	.db 0x19, 0x8b, 0x00, 0x81, 0x19
	.db 0x41, 0x0c
	.dw song_shatterhand_sdcc_song0ref2309
	.db 0x8b, 0x00, 0x81, 0x14
	.db 0x41, 0x0c
	.dw song_shatterhand_sdcc_song0ref2243
	.db 0x8b, 0x00, 0x81, 0x16
	.db 0x41, 0x0c
	.dw song_shatterhand_sdcc_song0ref1923
	.db 0x8b, 0x00, 0x81, 0x17
	.db 0x41, 0x0b
	.dw song_shatterhand_sdcc_song0ref2151
	.db 0x19
	.db 0x41, 0x0b
	.dw song_shatterhand_sdcc_song0ref1915
	.db 0x1b, 0x8b, 0x00, 0x93, 0x19, 0x8b, 0x00, 0x81, 0x19, 0x8b, 0x00, 0x93, 0x1b, 0x8b, 0x00, 0x81, 0x1b, 0x8b, 0x00, 0x93, 0x16
	.db 0x41, 0x0c
	.dw song_shatterhand_sdcc_song0ref2243
	.db 0x8b, 0x00, 0x81, 0x16, 0x8b, 0x00, 0x81, 0x18, 0x8b, 0x00, 0x81, 0x1a, 0x8b, 0x00, 0x81, 0x42
	.dw song_shatterhand_sdcc_song0ch2loop
song_shatterhand_sdcc_song0ch3:
song_shatterhand_sdcc_song0ch3loop:
song_shatterhand_sdcc_song0ref2436:
	.db 0x84, 0x21, 0xa1, 0x86
song_shatterhand_sdcc_song0ref2440:
	.db 0x1b, 0xa1, 0x84, 0x21, 0xa1, 0x86, 0x1b, 0xa1, 0x84, 0x21, 0xa1, 0x86, 0x1b, 0xa1
	.db 0x41, 0x0c
	.dw song_shatterhand_sdcc_song0ref2436
	.db 0x41, 0x0a
	.dw song_shatterhand_sdcc_song0ref2436
	.db 0x21, 0xa1, 0x21, 0xa1, 0x21, 0xa1, 0x21, 0xa1, 0x21, 0xa1, 0x86, 0x1b, 0x8f, 0x84, 0x21, 0x8f, 0x86, 0x1b, 0x81, 0x1b, 0x8b, 0x84
song_shatterhand_sdcc_song0ref2482:
	.db 0x21
song_shatterhand_sdcc_song0ref2483:
	.db 0x8f, 0x82, 0x15, 0x8f, 0x8e, 0x21, 0x8f, 0x86, 0x1b, 0x8f, 0x8e, 0x21, 0x8f, 0x82, 0x15, 0x8f, 0x15, 0x8f, 0x86, 0x1b, 0x8f, 0x8e
	.db 0x41, 0x10
	.dw song_shatterhand_sdcc_song0ref2482
	.db 0x8e
	.db 0x41, 0x10
	.dw song_shatterhand_sdcc_song0ref2482
song_shatterhand_sdcc_song0ref2512:
	.db 0x8e, 0x21, 0x8f, 0x82, 0x15, 0x8f, 0x86, 0x1b, 0x8f, 0x1b, 0x8f, 0x82, 0x15, 0x8f, 0x86, 0x1b, 0x8f, 0x1b, 0x8f, 0x82, 0x15, 0x8f, 0x86, 0x1b
	.db 0x41, 0x0f
	.dw song_shatterhand_sdcc_song0ref2483
	.db 0x8e
	.db 0x41, 0x10
	.dw song_shatterhand_sdcc_song0ref2482
	.db 0x8e
	.db 0x41, 0x10
	.dw song_shatterhand_sdcc_song0ref2482
	.db 0x41, 0x11
	.dw song_shatterhand_sdcc_song0ref2512
	.db 0x41, 0x0f
	.dw song_shatterhand_sdcc_song0ref2483
	.db 0x8e
	.db 0x41, 0x10
	.dw song_shatterhand_sdcc_song0ref2482
	.db 0x8e
	.db 0x41, 0x10
	.dw song_shatterhand_sdcc_song0ref2482
	.db 0x8e
	.db 0x41, 0x10
	.dw song_shatterhand_sdcc_song0ref2482
	.db 0x8e
	.db 0x41, 0x10
	.dw song_shatterhand_sdcc_song0ref2482
	.db 0x8e
	.db 0x41, 0x10
	.dw song_shatterhand_sdcc_song0ref2482
	.db 0x8e
	.db 0x41, 0x10
	.dw song_shatterhand_sdcc_song0ref2482
	.db 0x8e, 0x21, 0x8f, 0x86, 0x1b, 0x8f, 0x82, 0x15, 0x8f
song_shatterhand_sdcc_song0ref2586:
	.db 0x15, 0x8f, 0x86, 0x1b, 0x8f, 0x82, 0x15, 0x8f, 0x86, 0x1b, 0x8f, 0x1b, 0x8f, 0x1b
	.db 0x41, 0x0f
	.dw song_shatterhand_sdcc_song0ref2483
	.db 0x8e
	.db 0x41, 0x10
	.dw song_shatterhand_sdcc_song0ref2482
	.db 0x8e
	.db 0x41, 0x10
	.dw song_shatterhand_sdcc_song0ref2482
	.db 0x41, 0x11
	.dw song_shatterhand_sdcc_song0ref2512
	.db 0x41, 0x0f
	.dw song_shatterhand_sdcc_song0ref2483
	.db 0x8e
	.db 0x41, 0x10
	.dw song_shatterhand_sdcc_song0ref2482
	.db 0x8e
	.db 0x41, 0x10
	.dw song_shatterhand_sdcc_song0ref2482
	.db 0x41, 0x11
	.dw song_shatterhand_sdcc_song0ref2512
	.db 0x41, 0x0f
	.dw song_shatterhand_sdcc_song0ref2483
	.db 0x8e
	.db 0x41, 0x10
	.dw song_shatterhand_sdcc_song0ref2482
	.db 0x8e
	.db 0x41, 0x10
	.dw song_shatterhand_sdcc_song0ref2482
	.db 0x8e
	.db 0x41, 0x10
	.dw song_shatterhand_sdcc_song0ref2482
	.db 0x8e
	.db 0x41, 0x10
	.dw song_shatterhand_sdcc_song0ref2482
	.db 0x8e
	.db 0x41, 0x10
	.dw song_shatterhand_sdcc_song0ref2482
	.db 0x8e
	.db 0x41, 0x10
	.dw song_shatterhand_sdcc_song0ref2482
	.db 0x8e, 0x21, 0x8f, 0x86, 0x1b, 0x8f, 0x1b, 0x8f, 0x82
	.db 0x41, 0x0b
	.dw song_shatterhand_sdcc_song0ref2586
	.db 0x8f, 0x1b, 0x8f
song_shatterhand_sdcc_song0ref2670:
	.db 0x1b, 0xa1, 0x1b, 0x8f, 0x1b, 0xa1, 0x1b, 0x8f, 0x1b, 0xa1, 0x82, 0x15, 0x8f, 0x86, 0x1b, 0x8f, 0x82
	.db 0x41, 0x0a
	.dw song_shatterhand_sdcc_song0ref2586
song_shatterhand_sdcc_song0ref2690:
	.db 0x82, 0x15, 0x8f, 0x15, 0x8f, 0x84, 0x21, 0x8f, 0x82, 0x15, 0x8f, 0x15, 0x8f, 0x84, 0x21, 0x8f
	.db 0x41, 0x0c
	.dw song_shatterhand_sdcc_song0ref2690
	.db 0x86, 0x1b, 0xa1
	.db 0x41, 0x0a
	.dw song_shatterhand_sdcc_song0ref2670
	.db 0x1b, 0x8f, 0x1b, 0xa1, 0x82, 0x15, 0x8f, 0x86, 0x1b, 0x8f, 0x82
	.db 0x41, 0x0a
	.dw song_shatterhand_sdcc_song0ref2586
	.db 0x41, 0x0c
	.dw song_shatterhand_sdcc_song0ref2690
	.db 0x41, 0x0c
	.dw song_shatterhand_sdcc_song0ref2690
	.db 0x86, 0x1b, 0xa1
	.db 0x41, 0x0a
	.dw song_shatterhand_sdcc_song0ref2440
	.db 0x84, 0x21, 0xa1, 0x86, 0x1b, 0xa1, 0x84, 0x21, 0xa1, 0x86
	.db 0x41, 0x0a
	.dw song_shatterhand_sdcc_song0ref2670
	.db 0x1b, 0x8f, 0x1b, 0xa1, 0x1b, 0x8f, 0x1b, 0x8f, 0x1b, 0x8f, 0x1b, 0x8f, 0x1b, 0x8f, 0x82, 0x15, 0x8f, 0x15, 0x8f, 0x42
	.dw song_shatterhand_sdcc_song0ch3loop
song_shatterhand_sdcc_song0ch4:
song_shatterhand_sdcc_song0ch4loop:
song_shatterhand_sdcc_song0ref2777:
	.db 0xff, 0xff, 0x9f, 0xff, 0xff, 0x9f, 0xff, 0xff, 0x9f, 0xff, 0xff, 0x9f
	.db 0x41, 0x0c
	.dw song_shatterhand_sdcc_song0ref2777
	.db 0x41, 0x0c
	.dw song_shatterhand_sdcc_song0ref2777
	.db 0x41, 0x0c
	.dw song_shatterhand_sdcc_song0ref2777
	.db 0x41, 0x0c
	.dw song_shatterhand_sdcc_song0ref2777
	.db 0x41, 0x0c
	.dw song_shatterhand_sdcc_song0ref2777
	.db 0xff, 0xff, 0x9f, 0x42
	.dw song_shatterhand_sdcc_song0ch4loop
