lcc -mmos6502:nes -Wm-yoA -Wl-j -debug -v -Wa-l -Wl-u -Wl-w -Wm-yS -c -o demo_sdcc.o demo_sdcc.c
lcc -Wb-min=0 -Wl-j -Wm-yoA -autobank -Wb-ext=.rel -Wl-j -Wl-w -Wm-yS -v -Wb-v -Wa-l -Wl-u -Wf-Iinclude -Wf-MMD -mmos6502:nes -c -o demo_sdcc_asminc.o demo_sdcc_asminc.s
lcc -mmos6502:nes -Wm-yoA -Wl-j -debug -v -Wa-l -Wl-u -Wl-w -Wm-yS -o demo_sdcc.nes demo_sdcc.o demo_sdcc_asminc.o

copy demo_sdcc.nes ..\
del demo_sdcc.nes *.o
