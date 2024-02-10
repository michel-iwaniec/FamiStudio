;
; Adapter code for SDCC
;
; As SDCC doesn't support the AXY register calling convention, this extra
; code is needed for C code to move register contents around.
;

.area _CODE

_famistudio_init_ntsc::
    pha
    txa
    tay
    pla
    tax
    lda #0
    jmp _famistudio_init
    
_famistudio_init_pal::
    pha
    txa
    tay
    pla
    tax
    lda #1
    jmp _famistudio_init
