
;-----------------------------------------------
; Millie and Molly Amiga Port
;-----------------------------------------------

    INCDIR      "include"
    INCLUDE     "hw.i"
    INCLUDE     "funcdef.i"
    include     "macros.asm"
    include     "variables.asm"
    include     "intbits.i"
    include     "dmabits.i"
    include     "const.asm"

;-----------------------------------------------
; MAIN
;-----------------------------------------------

    section     main,code
Main:
    lea         .trap(pc),a0
    move.l      a0,$80
    trap        #0
.trap

Restart:
    ;lea        AllChip,a0
    ;move.l     #AllChipEnd-AllChip,d7
    ;bsr        TurboClear

    ;lea        AllFast,a0
    ;move.l     #AllFastEnd-AllFast,d7
    ;bsr        TurboClear

    lea         CUSTOM,a6
    lea         Variables,a5
    move.w      #$7fff,DMACON(a6)
    move.w      #$7fff,ADKCON(a6)
    move.w      #$7fff,INTENA(a6)
    move.w      #$7fff,INTREQ(a6)

    bsr         CopperInit

    move.l      #cpTest,COP1LC(a6)
    move.w      #0,COPJMP1(a6)

    move.w      #BASE_DMA,DMACON(a6)

    ; test tile blit
    WAITBLIT
    move.l      #$9f0<<16,BLTCON0(a6)
    move.l      #-1,BLTAFWM(a6)
    move.l      #TestTile,BLTAPT(a6)
    move.l      #ScreenMem,BLTDPT(a6)
    move.w      #0,BLTAMOD(a6)
    move.w      #TILE_BLT_MOD,BLTDMOD(a6)
    move.w      #TILE_BLT_SIZE,BLTSIZE(a6)

    ; exit!

.forever
    bra         .forever
    
TILE_BLT_MOD  = SCREEN_WIDTH_BYTE-4
TILE_BLT_SIZE = ((24*SCREEN_DEPTH)<<6)+2



CopperInit:
    move.l      #ScreenMem,d0
    lea         cpPlanes,a0
    moveq       #SCREEN_DEPTH-1,d7
.ploop
    move.w      d0,6(a0)
    swap        d0
    move.w      d0,2(a0)
    swap        d0
    addq.l      #8,a0
    add.l       #SCREEN_WIDTH_BYTE,d0
    dbra        d7,.ploop

    lea         TestPal,a0
    lea         cpPal,a1
    moveq       #SCREEN_COLORS-1,d7
.cloop
    move.w      (a0)+,2(a1)    
    addq.l      #4,a1
    dbra        d7,.cloop

    rts


;----------------------------------------------
;  includes!
;----------------------------------------------


    incdir      "data"


;----------------------------------------------
;  data fast
;----------------------------------------------

    section     data_fast,data

TestPal:
    incbin      "assets/pal.bin"


;----------------------------------------------
;  data chip
;----------------------------------------------

    section     data_chip,data_c

    include     "copperlists.asm"

TestTile:
    incbin      "assets/Tiles/tile_09.raw"

;----------------------------------------------
;   mem fast
;----------------------------------------------

    section     mem_fast,bss

AllFast:

Variables:
    ds.b        Variables_sizeof

    ds.b        200
	
AllFastEnd:



;----------------------------------------------
;   mem chip
;----------------------------------------------

    section     mem_chip,bss_c
AllChip:

ScreenMem
    ds.b        SCREEN_SIZE

    ds.b        200

AllChipEnd:
