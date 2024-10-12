
;-----------------------------------------------
; copper lists mofo
;-----------------------------------------------

cpTest:
    dc.w    $01fc,$0000             ;Slow fetch mode, remove if AGA demo.

    dc.w    DIWSTRT,WINDOW_START    ; $2c81                                                  ;238h display window top, left
    dc.w    DIWSTOP,WINDOW_STOP     ;$2cc1                                                  ;and bottom, right.
    dc.w    DDFSTRT,FETCH_START     ;Standard bitplane dma fetch start
    dc.w    DDFSTOP,FETCH_STOP      ;and stop for standard screen.
    dc.w    BPLCON0,$5200           ; 5 plane display
    dc.w    BPLCON1,$0000
    dc.w    BPLCON2,$0024
    dc.w    BPL1MOD,SCREEN_MOD
    dc.w    BPL2MOD,SCREEN_MOD
cpPlanes:
    dc.w    BPL1PTH,0
    dc.w    BPL1PTL,0
    dc.w    BPL2PTH,0
    dc.w    BPL2PTL,0
    dc.w    BPL3PTH,0
    dc.w    BPL3PTL,0
    dc.w    BPL4PTH,0
    dc.w    BPL4PTL,0
    dc.w    BPL5PTH,0
    dc.w    BPL5PTL,0

cpSprites:
    dc.w    SPR0PTH,0
    dc.w    SPR0PTL,0
    dc.w    SPR1PTH,0
    dc.w    SPR1PTL,0
    dc.w    SPR2PTH,0
    dc.w    SPR2PTL,0
    dc.w    SPR3PTH,0
    dc.w    SPR3PTL,0
    dc.w    SPR4PTH,0
    dc.w    SPR4PTL,0
    dc.w    SPR5PTH,0
    dc.w    SPR5PTL,0
    dc.w    SPR6PTH,0
    dc.w    SPR6PTL,0
    dc.w    SPR7PTH,0
    dc.w    SPR7PTL,0

cpPal:
    dc.w    COLOR00,$00f
    dc.w    COLOR01,0
    dc.w    COLOR02,0
    dc.w    COLOR03,0
    dc.w    COLOR04,0
    dc.w    COLOR05,0
    dc.w    COLOR06,0
    dc.w    COLOR07,0
    dc.w    COLOR08,0
    dc.w    COLOR09,0
    dc.w    COLOR10,0
    dc.w    COLOR11,0
    dc.w    COLOR12,0
    dc.w    COLOR13,0
    dc.w    COLOR14,0
    dc.w    COLOR15,0
    dc.w    COLOR16,0
    dc.w    COLOR17,0
    dc.w    COLOR18,0
    dc.w    COLOR19,0
    dc.w    COLOR20,0
    dc.w    COLOR21,0
    dc.w    COLOR22,0
    dc.w    COLOR23,0
    dc.w    COLOR24,0
    dc.w    COLOR25,0
    dc.w    COLOR26,0
    dc.w    COLOR27,0
    dc.w    COLOR28,0
    dc.w    COLOR29,0
    dc.w    COLOR30,0
    dc.w    COLOR31,0

    dc.l    COPPER_HALT
    dc.l    COPPER_HALT
