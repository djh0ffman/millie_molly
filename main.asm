
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

    ; exit!
    bsr         FillScreen

.forever
    bra         .forever
    
TILE_BLT_MOD  = SCREEN_WIDTH_BYTE-4
TILE_BLT_SIZE = ((24*SCREEN_DEPTH)<<6)+2

FillScreen:
    moveq       #28,d2                        ; tile id

    moveq       #0,d1                         ; y
.yloop
    move        #0,d0
.xloop    
    bsr         DrawTile
    add.w       #TILE_WIDTH,d0
    cmp.w       #SCREEN_WIDTH,d0
    bcs         .xloop

    add.w       #TILE_HEIGHT,d1
    cmp.w       #SCREEN_HEIGHT,d1
    bcs         .yloop
    rts

; d0 = x
; d1 = y
; d2 = tile id

DrawTile:
    PUSHM       d0-d2

    lea         Tileset,a0
    lea         ScreenMem,a1

    mulu        #TILE_SIZE,d2
    add.w       d2,a0                         ; tile graphic

    mulu        #SCREEN_STRIDE,d1
    move.w      d0,d2
    asr.w       #3,d2
    add.w       d2,d1    
    add.l       d1,a1                         ; screen position

    and.w       #$f,d0                        ; shift
    ror.w       #4,d0 
    or.w        #$dfc,d0                      ; minterm

    ; test tile blit
    WAITBLIT
    move.w      d0,BLTCON0(a6)
    move.w      #0,BLTCON1(a6)
    move.l      #-1,BLTAFWM(a6)
    move.l      a0,BLTAPT(a6)
    move.l      a1,BLTBPT(a6)
    move.l      a1,BLTDPT(a6)
    move.w      #0,BLTAMOD(a6)
    move.w      #TILE_BLT_MOD,BLTBMOD(a6)
    move.w      #TILE_BLT_MOD,BLTDMOD(a6)
    move.w      #TILE_BLT_SIZE,BLTSIZE(a6)

    POPM        d0-d2
    rts


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
;  LoadLevel
;
; d0 = level id
;----------------------------------------------

LoadLevel:
    lea         LevelData,a0
    mulu        #MAP_SIZE,d0
    add.w       d0,a0
    lea         GameMap(a5),a1
    moveq       #MAP_SIZE-1,d7
.copy
    move.b      (a0)+,(a1)+
    dbra        d7,.copy
    rts    


;----------------------------------------------
;  includes!
;----------------------------------------------



;----------------------------------------------
;  data fast
;----------------------------------------------

    section     data_fast,data

TestPal:
    incbin      "assets/pal.bin"
LevelData:
    incbin      "assets/Levels/levels.bin"

;----------------------------------------------
;  data chip
;----------------------------------------------

    section     data_chip,data_c

    include     "copperlists.asm"

TestTile:


Tileset:
    incbin      "assets/Tiles/tiles_0.bin"

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
