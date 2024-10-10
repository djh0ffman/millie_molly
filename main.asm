
;-----------------------------------------------
; Millie and Molly Amiga Port
;-----------------------------------------------

    INCDIR        "include"
    INCLUDE       "hw.i"
    INCLUDE       "funcdef.i"
    include       "macros.asm"
    include       "variables.asm"
    include       "intbits.i"
    include       "dmabits.i"
    include       "const.asm"

;-----------------------------------------------
; MAIN
;-----------------------------------------------

    section       main,code
Main:
    lea           .trap(pc),a0
    move.l        a0,$80
    trap          #0
.trap

Restart:
    ;lea        AllChip,a0
    ;move.l     #AllChipEnd-AllChip,d7
    ;bsr        TurboClear

    ;lea        AllFast,a0
    ;move.l     #AllFastEnd-AllFast,d7
    ;bsr        TurboClear

    lea           CUSTOM,a6
    lea           Variables,a5
    move.w        #$7fff,DMACON(a6)
    move.w        #$7fff,ADKCON(a6)
    move.w        #$7fff,INTENA(a6)
    move.w        #$7fff,INTREQ(a6)

    bsr           Init

    bsr           WallPaperInit
    bsr           WallPaperInit
    bsr           FillScreen
    bsr           DrawLadders
    bsr           DrawShadows


.forever
    lea           Keys,a0
    tst.b         KEY_F1(a0)
    beq           .nof1
    clr.b         KEY_F1(a0)
    tst.w         LevelId(a5)
    beq           .nof1
    subq.w        #1,LevelId(a5)
    bra           .draw
.nof1
    tst.b         KEY_F2(a0)
    beq           .nof2
    clr.b         KEY_F2(a0)
    cmp.w         #99,LevelId(a5)
    beq           .nof2
    addq.w        #1,LevelId(a5)
.draw
    bsr           WallPaperInit
    bsr           FillScreen
    bsr           DrawLadders
    bsr           DrawShadows

    move.w        #15,d0
    move.w        #0,d1
    move.w        LevelId(a5),d2
    move.w        d2,d0
    bsr           DrawSprite
.nof2
    bra           .forever


    
Init:
    bsr           KeyboardInit
    bsr           CopperInit
    bsr           GenSpriteMask
    move.l        #cpTest,COP1LC(a6)
    move.w        #0,COPJMP1(a6)

    move.w        #BASE_DMA,DMACON(a6)

    move.w        #START_LEVEL,LevelId(a5)

    rts


GenSpriteMask:
    lea           Sprites,a0
    lea           SpriteMask,a1
    move.w        #SPRITESET_COUNT*TILE_HEIGHT-1,d7
.nexttile
    move.l        (a0)+,d0
    or.l          (a0)+,d0
    or.l          (a0)+,d0
    or.l          (a0)+,d0
    or.l          (a0)+,d0
    move.l        d0,(a1)+
    move.l        d0,(a1)+
    move.l        d0,(a1)+
    move.l        d0,(a1)+
    move.l        d0,(a1)+
    dbra          d7,.nexttile
    lea           ScreenMem,a2
    rts


GenTileMask:
    move.l        TilesetPtr(a5),a0
    lea           TileMask,a1
    move.w        #TILESET_COUNT*TILE_HEIGHT-1,d7
.nexttile
    move.l        (a0)+,d0
    or.l          (a0)+,d0
    or.l          (a0)+,d0
    or.l          (a0)+,d0
    or.l          (a0)+,d0
    move.l        d0,(a1)+
    move.l        d0,(a1)+
    move.l        d0,(a1)+
    move.l        d0,(a1)+
    move.l        d0,(a1)+
    dbra          d7,.nexttile
    lea           SpriteMask,a0
    rts


SHADOW_BLT_MOD  = SCREEN_STRIDE-4
SHADOW_BLT_SIZE = ((24)<<6)+2

TILE_BLT_MOD    = SCREEN_WIDTH_BYTE-4
TILE_BLT_SIZE   = ((24*SCREEN_DEPTH)<<6)+2

FillScreen:
    lea           WallpaperWork(a5),a4
    moveq         #28,d2                                                     ; tile id

    moveq         #0,d1                                                      ; y
.yloop
    move          #0,d0
.xloop    
    moveq         #0,d2
    move.b        (a4)+,d2                                                   ; tile id

    bsr           DrawTile
    add.w         #TILE_WIDTH,d0
    cmp.w         #SCREEN_WIDTH,d0
    bcs           .xloop

    add.w         #TILE_HEIGHT,d1
    cmp.w         #SCREEN_HEIGHT,d1
    bcs           .yloop
    rts

DrawLadders:
    lea           WallpaperLadders(a5),a4
    moveq         #0,d1                                                      ; y
.yloop
    move          #0,d0
.xloop    
    moveq         #0,d2
    move.b        (a4)+,d2                                                   ; tile id
    beq           .skip
    bsr           PasteTile
.skip
    add.w         #TILE_WIDTH,d0
    cmp.w         #SCREEN_WIDTH,d0
    bcs           .xloop

    add.w         #TILE_HEIGHT,d1
    cmp.w         #SCREEN_HEIGHT,d1
    bcs           .yloop
    rts


DrawShadows:
    lea           WallpaperShadows(a5),a4
    moveq         #0,d1                                                      ; y
.yloop
    move          #0,d0
.xloop    
    moveq         #0,d2
    move.b        (a4)+,d2                                                   ; tile id
    beq           .skip
    bsr           ShadowTile
.skip
    add.w         #TILE_WIDTH,d0
    cmp.w         #SCREEN_WIDTH,d0
    bcs           .xloop

    add.w         #TILE_HEIGHT,d1
    cmp.w         #SCREEN_HEIGHT,d1
    bcs           .yloop
    rts


; d0 = x
; d1 = y
; d2 = tile id

ShadowTile:
    PUSHM         d0-d2

    lea           .shadowlist,a0
    add.w         d2,d2
    move.w        (a0,d2.w),d2
    bmi           .skip

    mulu          #SHADOW_SIZE,d2
    lea           Shadows,a0
    add.w         d2,a0

    lea           ScreenMem,a1

    mulu          #SCREEN_STRIDE,d1
    move.w        d0,d2
    asr.w         #3,d2
    add.w         d2,d1    
    add.l         d1,a1                                                      ; screen position

    and.w         #$f,d0                                                     ; shift
    ror.w         #4,d0 
    move.w        d0,d1
    or.w          #$d0c,d0                                                   ; minterm

    ; test tile blit
    moveq         #SCREEN_DEPTH-1,d4
.plane
    WAITBLIT
    move.w        d0,BLTCON0(a6)
    move.w        #0,BLTCON1(a6)
    move.l        #-1,BLTAFWM(a6)
    move.l        a0,BLTAPT(a6)
    move.l        a1,BLTBPT(a6)
    move.l        a1,BLTDPT(a6)
    move.w        #0,BLTAMOD(a6)
    move.w        #SHADOW_BLT_MOD,BLTBMOD(a6)
    move.w        #SHADOW_BLT_MOD,BLTDMOD(a6)
    move.w        #SHADOW_BLT_SIZE,BLTSIZE(a6)

    add.w         #SCREEN_WIDTH_BYTE,a1
    dbra          d4,.plane
.skip
    POPM          d0-d2
    rts

.shadowlist
    dc.w          -1                                                         ; 0
    dc.w          -1                                                         ; 1 
    dc.w          0                                                          ; 2
    dc.w          -1                                                         ; 3
    dc.w          -1                                                         ; 4
    dc.w          5                                                          ; 5
    dc.w          -1                                                         ; 6
    dc.w          1                                                          ; 7
    dc.w          2                                                          ; 8
    dc.w          -1                                                         ; 9
    dc.w          4                                                          ; a
    dc.w          -1                                                         ; b
    dc.w          -1                                                         ; c
    dc.w          3                                                          ; d
    dc.w          -1                                                         ; e
    dc.w          4                                                          ; f 


; d0 = x
; d1 = y
; d2 = tile id

DrawTile:
    PUSHM         d0-d2

    move.l        TilesetPtr(a5),a0
    lea           ScreenMem,a1

    mulu          #TILE_SIZE,d2
    add.w         d2,a0                                                      ; tile graphic

    mulu          #SCREEN_STRIDE,d1
    move.w        d0,d2
    asr.w         #3,d2
    add.w         d2,d1    
    add.l         d1,a1                                                      ; screen position

    and.w         #$f,d0                                                     ; shift
    ror.w         #4,d0 
    or.w          #$dfc,d0                                                   ; minterm

    ; test tile blit
    WAITBLIT
    move.w        d0,BLTCON0(a6)
    move.w        #0,BLTCON1(a6)
    move.l        #-1,BLTAFWM(a6)
    move.l        a0,BLTAPT(a6)
    move.l        a1,BLTBPT(a6)
    move.l        a1,BLTDPT(a6)
    move.w        #0,BLTAMOD(a6)
    move.w        #TILE_BLT_MOD,BLTBMOD(a6)
    move.w        #TILE_BLT_MOD,BLTDMOD(a6)
    move.w        #TILE_BLT_SIZE,BLTSIZE(a6)

    POPM          d0-d2
    rts

; d0 = x
; d1 = y
; d2 = tile id

PasteTile:
    PUSHM         d0-d2

    move.l        TilesetPtr(a5),a0
    lea           TileMask,a2
    lea           ScreenMem,a1

    mulu          #TILE_SIZE,d2
    add.w         d2,a0                                                      ; tile graphic
    add.w         d2,a2                                                      ; tile graphic

    mulu          #SCREEN_STRIDE,d1
    move.w        d0,d2
    asr.w         #3,d2
    add.w         d2,d1    
    add.l         d1,a1                                                      ; screen position

    and.w         #$f,d0                                                     ; shift
    ror.w         #4,d0 
    move.w        d0,d1
    or.w          #$fca,d0                                                   ; minterm

    ; test tile blit
    WAITBLIT
    move.w        d0,BLTCON0(a6)
    move.w        d1,BLTCON1(a6)
    move.l        #-1,BLTAFWM(a6)
    move.l        a2,BLTAPT(a6)
    move.l        a0,BLTBPT(a6)
    move.l        a1,BLTCPT(a6)
    move.l        a1,BLTDPT(a6)
    move.w        #0,BLTAMOD(a6)
    move.w        #0,BLTBMOD(a6)
    move.w        #TILE_BLT_MOD,BLTCMOD(a6)
    move.w        #TILE_BLT_MOD,BLTDMOD(a6)
    move.w        #TILE_BLT_SIZE,BLTSIZE(a6)

    POPM          d0-d2
    rts


CopperInit:
    move.l        #ScreenMem,d0
    lea           cpPlanes,a0
    moveq         #SCREEN_DEPTH-1,d7
.ploop
    move.w        d0,6(a0)
    swap          d0
    move.w        d0,2(a0)
    swap          d0
    addq.l        #8,a0
    add.l         #SCREEN_WIDTH_BYTE,d0
    dbra          d7,.ploop

    lea           TilesPal0,a0
    lea           cpPal,a1
    moveq         #SCREEN_COLORS-1,d7
.cloop
    move.w        (a0)+,2(a1)    
    addq.l        #4,a1
    dbra          d7,.cloop

    rts

SetLevelAssets:
    moveq         #0,d0
    move.w        LevelId(a5),d0
    divu          #20,d0
    ext.l         d0
    move.w        d0,AssetSet(a5)
    move.w        d0,d4
    mulu          #SCREEN_COLORS*2,d0
    lea           TilesPal0,a0
    add.w         d0,a0
    lea           cpPal,a1
    moveq         #(SCREEN_COLORS/2)-1,d7
.cloop1
    move.w        (a0)+,2(a1)    
    addq.l        #4,a1
    dbra          d7,.cloop1

    lea           SpritePal,a0
    moveq         #(SCREEN_COLORS/2)-1,d7
.cloop2
    move.w        (a0)+,2(a1)    
    addq.l        #4,a1
    dbra          d7,.cloop2

    mulu          #TILESET_SIZE,d4
    add.l         #Tiles0,d4
    move.l        d4,TilesetPtr(a5)

    rts



WallPaperInit:
    lea           ScreenMem,a0
    move.l        #SCREEN_SIZE,d7
    bsr           TurboClear

    bsr           SetLevelAssets

    bsr           GenTileMask

    move.l        #$BABEFEED,d0
    move.b        LevelId+1(a5),d0
    move.l        d0,RandomSeed(a5)

    bsr           WallPaperLoadBase
    bsr           WallPaperLoadLevel
    bsr           WallPaperWalls
    bsr           WallpaperMakeLadders
    bsr           WallpaperMakeShadows
    rts



WallPaperLoadLevel:
    moveq         #0,d0
    move.w        LevelId(a5),d0
    lea           LevelData,a0
    mulu          #MAP_SIZE,d0
    add.w         d0,a0
    move.l        a0,LevelPtr(a5)
    lea           WallpaperWork+1(a5),a1
    moveq         #MAP_HEIGHT-1,d7
.line
    moveq         #MAP_WIDTH-1,d6
.copy
    move.b        (a0)+,(a1)+
    dbra          d6,.copy
    addq.w        #3,a1
    dbra          d7,.line
    rts    

WallpaperMakeShadows:
    lea           WallpaperWork(a5),a0
    lea           WallpaperShadows(a5),a1
    moveq         #WALL_PAPER_HEIGHT-1,d7
.lineloop
    moveq         #WALL_PAPER_WIDTH-1,d6
.nextblock
    cmp.b         #28,(a0)
    bne           .next

    lea           .offsets,a2
    moveq         #4-1,d5
    moveq         #0,d3                                                      ; bit flags
.bitloop
    lsl.w         #1,d3
    move.w        (a2)+,d2
    cmp.b         #28,(a0,d2.w)
    beq           .noblock
    addq.w        #1,d3
.noblock
    dbra          d5,.bitloop
    move.b        d3,(a1)


.next
    addq.w        #1,a0
    addq.w        #1,a1
    dbra          d6,.nextblock
    dbra          d7,.lineloop
    lea           WallpaperShadows(a5),a1
    rts

.offsets
    dc.w          -1                                                         ; left
    dc.w          -(WALL_PAPER_WIDTH+1)                                      ; top left
    dc.w          -WALL_PAPER_WIDTH                                          ; top
    dc.w          -WALL_PAPER_WIDTH-1                                        ; top right


WallpaperMakeLadders:
    move.l        LevelPtr(a5),a3
    lea           WallpaperLadders+1(a5),a4
    moveq         #MAP_WIDTH-1,d7

.colloop
    move.l        a3,a0
    move.l        a4,a1
    moveq         #MAP_HEIGHT-1,d6
    moveq         #0,d0                                                      ; tile count
.nexttile
    cmp.b         #BLOCK_LADDER,(a0)
    beq           .isladder

    tst.w         d0
    beq           .next
    beq           .next

    bsr           LadderDespatch
    bra           .next

.isladder
    tst.w         d0
    bne           .skipptr                                                   ; first ladder block
    moveq         #1,d4
    cmp.l         a0,a3
    beq           .topline
    cmp.b         #BLOCK_SOLID,-MAP_WIDTH(a0)
    beq           .topline
    moveq         #0,d4
.topline
    move.l        a1,a2                                                      ; ladder start

.skipptr
    addq.w        #1,d0                                                      ; tile count
    tst.w         d6
    bne           .next
    bsr           LadderDespatch

.next
    add.w         #MAP_WIDTH,a0
    add.w         #WALL_PAPER_WIDTH,a1
    dbra          d6,.nexttile

    addq.w        #1,a3
    addq.w        #1,a4
    dbra          d7,.colloop
    lea           WallpaperLadders(a5),a4
    rts

LadderDespatch:
    cmp.w         #1,d0
    beq           .isone

    moveq         #14,d3
    tst.w         d4
    beq           .walk2
    moveq         #11,d3
.walk2
    move.b        d3,(a2)
    add.w         #WALL_PAPER_WIDTH,a2
    subq.w        #2,d0
    beq           .last

.loop
    move.b        #12,(a2)
    add.w         #WALL_PAPER_WIDTH,a2
    subq.w        #1,d0
    bne           .loop
.last
    move.b        #13,(a2)
    add.w         #WALL_PAPER_WIDTH,a2

    rts

.isone
    moveq         #15,d3
    tst.w         d4
    beq           .topone
    moveq         #10,d3
.topone
    move.b        d3,(a2)                                                    ; single cell ladder
    moveq         #0,d0
    add.w         #WALL_PAPER_WIDTH,a2
    rts

WallPaperWalls:
    lea           WallpaperWork(a5),a0
    moveq         #WALL_PAPER_HEIGHT-1,d7

.lineloop
    move.l        a0,a1

    moveq         #WALL_PAPER_WIDTH-1,d6
    moveq         #0,d0                                                      ; tile count
.nexttile
    cmp.b         #BLOCK_SOLID,(a0)+
    beq           .iswall

    bsr           WallDespatch
    bra           .next

.iswall
    tst.w         d0
    bne           .skipptr
    move.b        #28,(a1)+
    move.l        a0,a1
    subq.l        #1,a1
.skipptr
    addq.w        #1,d0                                                      ; tile count
    tst.w         d6
    bne           .next
    bsr           WallDespatch
.next
    dbra          d6,.nexttile
    dbra          d7,.lineloop
    rts


; d0 = wall tile count
; a1 = start pointer

WallDespatch:
    tst.w         d0
    beq           .zero

    tst.w         AssetSet(a5)
    bne           .fullrandom

    cmp.w         #1,d0
    beq           .isone

    cmp.w         #2,d0
    bne           .long
    move.b        #1,(a1)+
    move.b        #8,(a1)+
    moveq         #0,d0
    rts
.long
    subq.w        #2,d0
    move.b        #1,(a1)+
.fill
    PUSH          d0
    RANDOMWORD
    moveq         #0,d2
    move.w        d0,d2
    POP           d0 
    divu          #6,d2
    swap          d2
    add.w         #2,d2

    move.b        d2,(a1)+                                                   ; random chars
    subq.w        #1,d0
    bne           .fill
    move.b        #8,(a1)+
    rts
.isone
    move.b        #0,(a1)+
    moveq         #0,d0
    rts
.zero
    move.b        #28,(a1)+
    rts

.fullrandom
    PUSH          d0
    RANDOMWORD
    moveq         #0,d2
    move.w        d0,d2
    POP           d0 
    divu          #9,d2
    swap          d2

    move.b        d2,(a1)+                                                   ; random chars
    subq.w        #1,d0
    bne           .fullrandom
    rts



WallPaperLoadBase:
    lea           WallpaperBase,a0
    lea           WallpaperWork(a5),a1
    move.w        #WALL_PAPER_SIZE-1,d7
.loop
    move.b        (a0)+,(a1)+
    dbra          d7,.loop

    lea           WallpaperLadders(a5),a0
    lea           WallpaperShadows(a5),a1
    move.w        #WALL_PAPER_SIZE-1,d7
.clr
    clr.b         (a0)+
    clr.b         (a1)+
    dbra          d7,.clr

    lea           WallpaperCheat(a5),a0
    moveq         #WALL_PAPER_WIDTH-1,d7
.cheat
    move.b        #28,(a0)+
    dbra          d7,.cheat
    rts

;----------------------------------------------
;  LoadLevel
;
; d0 = level id
;----------------------------------------------

LoadLevel:
    lea           LevelData,a0
    mulu          #MAP_SIZE,d0
    add.w         d0,a0
    lea           GameMap(a5),a1
    moveq         #MAP_SIZE-1,d7
.copy
    move.b        (a0)+,(a1)+
    dbra          d7,.copy
    rts    



DrawSprite:
    PUSHM         d0-d2

    lea           Sprites,a0
    lea           SpriteMask,a2
    lea           ScreenMem,a1

    mulu          #TILE_SIZE,d2
    add.l         d2,a0                                                      ; tile graphic
    add.l         d2,a2                                                      ; tile graphic

    mulu          #SCREEN_STRIDE,d1
    move.w        d0,d2
    asr.w         #3,d2
    add.w         d2,d1    
    add.l         d1,a1                                                      ; screen position

    and.w         #$f,d0                                                     ; shift
    ror.w         #4,d0 
    move.w        d0,d1
    or.w          #$fca,d0                                                   ; minterm
    cmp.w         #$8000,d1
    bcs           .twowords

    ; test tile blit
    WAITBLIT
    move.w        d0,BLTCON0(a6)
    move.w        d1,BLTCON1(a6)
    move.l        #$ffff0000,BLTAFWM(a6)
    move.l        a2,BLTAPT(a6)
    move.l        a0,BLTBPT(a6)
    move.l        a1,BLTCPT(a6)
    move.l        a1,BLTDPT(a6)
    move.w        #-2,BLTAMOD(a6)
    move.w        #-2,BLTBMOD(a6)
    move.w        #TILE_BLT_MOD-2,BLTCMOD(a6)
    move.w        #TILE_BLT_MOD-2,BLTDMOD(a6)
    move.w        #TILE_BLT_SIZE+1,BLTSIZE(a6)
    bra           .done
.twowords
    ; test tile blit
    WAITBLIT
    move.w        d0,BLTCON0(a6)
    move.w        d1,BLTCON1(a6)
    move.l        #-1,BLTAFWM(a6)
    move.l        a2,BLTAPT(a6)
    move.l        a0,BLTBPT(a6)
    move.l        a1,BLTCPT(a6)
    move.l        a1,BLTDPT(a6)
    move.w        #0,BLTAMOD(a6)
    move.w        #0,BLTBMOD(a6)
    move.w        #TILE_BLT_MOD,BLTCMOD(a6)
    move.w        #TILE_BLT_MOD,BLTDMOD(a6)
    move.w        #TILE_BLT_SIZE,BLTSIZE(a6)
.done
    POPM          d0-d2
    rts

;----------------------------------------------
;  includes!
;----------------------------------------------

    include       "keyboard.asm"
    include       "tools.asm"

;----------------------------------------------
;  data fast
;----------------------------------------------

    section       data_fast,data

SpritePal:
    incbin        "assets/sprites.pal"

TilesPal0:
    incbin        "assets/Tiles/tiles_0.pal"
TilesPal1:
    incbin        "assets/Tiles/tiles_1.pal"
TilesPal2:
    incbin        "assets/Tiles/tiles_2.pal"
TilesPal3:
    incbin        "assets/Tiles/tiles_3.pal"
TilesPal4:
    incbin        "assets/Tiles/tiles_4.pal"

LevelData:
    incbin        "assets/Levels/levels.bin"
WallpaperBase:
    REPT          WALL_PAPER_HEIGHT-1
    dc.b          $05,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$05,$05
    ENDR
    dc.b          $05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05
    

;----------------------------------------------
;  data chip
;----------------------------------------------

    section       data_chip,data_c

    include       "copperlists.asm"

Sprites:
    incbin        "assets/sprites.bin"
Shadows:
    incbin        "assets/shadows.bin"


Tiles0:
    incbin        "assets/Tiles/tiles_0.bin"
Tiles1:
    incbin        "assets/Tiles/tiles_1.bin"
Tiles2:
    incbin        "assets/Tiles/tiles_2.bin"
Tiles3:
    incbin        "assets/Tiles/tiles_3.bin"
Tiles4:
    incbin        "assets/Tiles/tiles_4.bin"


;----------------------------------------------
;   mem fast
;----------------------------------------------

    section       mem_fast,bss

AllFast:

Variables:
    ds.b          Variables_sizeof


Keys:
    ds.b          256
    ds.b          200
	
AllFastEnd:



;----------------------------------------------
;   mem chip
;----------------------------------------------

    section       mem_chip,bss_c
AllChip:

TileMask:
    ds.b          TILESET_SIZE
SpriteMask:
    ds.b          SPRITESET_SIZE

ScreenMem
    ds.b          SCREEN_SIZE

    ds.b          200

AllChipEnd:
