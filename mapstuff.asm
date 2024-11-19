;-----------------------------------------------
; MAIN
;-----------------------------------------------

DrawMap:
    clr.w         PlayerCount(a5)
    clr.w         LevelComplete(a5)
    clr.w         ActionStatus(a5)
    
    bsr           LevelInit
    bsr           DrawWalls
    bsr           DrawButtons
    bsr           DrawLadders
    bsr           DrawShadows
    ; base restore screen created
    bsr           CopySaveToStatic
    ;bsr           DrawPlayers
    bsr           DrawStaticActors
    bsr           CopyStaticToBuffers

    ;cmp.w         #2,PlayerCount(a5)
    ;bne           .notboth

    ;move.l        PlayerPtrs+4(a5),a4
    ;bsr           DrawPlayerFrozen
    ;bsr           PlayerSwitch
    ;bsr           PlayerSwitch
.notboth
    rts


DrawButtons:
    move.w        #304-8-3,d0
    move.w        #14,d1
    moveq         #0,d2

    lea           LevelCountRaw,a0
    bsr           DrawLevelCounter
    add.w         #43,d1

    move.w        #304,d0
    lea           Button0Raw,a0
    bsr           DrawButton

    lea           Button1Raw,a0
    add.w         #43,d1
    bsr           DrawButton

    lea           Button2Raw,a0
    add.w         #43,d1
    bsr           DrawButton

    lea           Button3Raw,a0
    add.w         #43,d1
    bsr           DrawButton

    rts



CopyStaticToBuffers:
    lea           ScreenStatic,a0
    lea           Screen1,a1
    lea           Screen1,a2
    move.w        #(SCREEN_SIZE/4)-1,d7
.copy
    move.l        (a0)+,d0
    move.l        d0,(a1)+
    move.l        d0,(a2)+
    dbra          d7,.copy
    rts


CopySaveToStatic:
    lea           ScreenSave,a0
    lea           ScreenStatic,a1
    move.w        #(SCREEN_SIZE/4)-1,d7
.copy
    move.l        (a0)+,(a1)+
    dbra          d7,.copy
    rts

LevelInit:
    lea           ScreenSave,a0
    move.l        #SCREEN_SIZE,d7
    bsr           TurboClear

    lea           Millie(a5),a0
    clr.w         Player_Status(a0)
    move.l        a0,PlayerPtrs(a5)

    lea           Molly(a5),a0
    clr.w         Player_Status(a0)
    move.l        a0,PlayerPtrs+4(a5)

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
    bsr           InitGameObjects
    rts



SetLevelAssets:
    moveq         #0,d0
    move.w        LevelId(a5),d0
    lea           LevelAssetSet,a0
    move.b        (a0,d0.w),d0
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

    add.w         d4,d4
    add.w         d4,d4
    lea           TileAssets,a0
    move.l        (a0,d4.w),a0                         ; source packed
    lea           TileSet,a1
    move.l        a1,TilesetPtr(a5)
    bsr           zx0_decompress
    
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

    move.l        LevelPtr(a5),a0
    lea           GameMap+1(a5),a1
    moveq         #MAP_HEIGHT-1,d7
.line2
    moveq         #MAP_WIDTH-1,d6
.copy2
    move.b        (a0)+,(a1)+
    dbra          d6,.copy2
    addq.w        #3,a1
    dbra          d7,.line2
    lea           GameMap(a5),a0
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
    moveq         #0,d3                                ; bit flags
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
    dc.w          -1                                   ; left
    dc.w          -(WALL_PAPER_WIDTH+1)                ; top left
    dc.w          -WALL_PAPER_WIDTH                    ; top
    dc.w          -WALL_PAPER_WIDTH-1                  ; top right


WallpaperMakeLadders:
    move.l        LevelPtr(a5),a3
    lea           WallpaperLadders+1(a5),a4
    moveq         #MAP_WIDTH-1,d7

.colloop
    move.l        a3,a0
    move.l        a4,a1
    moveq         #MAP_HEIGHT-1,d6
    moveq         #0,d0                                ; tile count
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
    bne           .skipptr                             ; first ladder block
    moveq         #1,d4
    cmp.l         a0,a3
    beq           .topline
    cmp.b         #BLOCK_SOLID,-MAP_WIDTH(a0)
    beq           .topline
    moveq         #0,d4
.topline
    move.l        a1,a2                                ; ladder start

.skipptr
    addq.w        #1,d0                                ; tile count
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
    move.b        d3,(a2)                              ; single cell ladder
    moveq         #0,d0
    add.w         #WALL_PAPER_WIDTH,a2
    rts

WallPaperWalls:
    lea           WallpaperWork(a5),a0
    moveq         #WALL_PAPER_HEIGHT-1,d7

.lineloop
    move.l        a0,a1

    moveq         #WALL_PAPER_WIDTH-1,d6
    moveq         #0,d0                                ; tile count
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
    addq.w        #1,d0                                ; tile count
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
    move.b        #TILE_WALLLEFT,(a1)+
    move.b        #TILE_WALLRIGHT,(a1)+
    moveq         #0,d0
    rts
.long
    subq.w        #2,d0
    move.b        #TILE_WALLLEFT,(a1)+
.fill
    PUSH          d0
    RANDOMWORD
    moveq         #0,d2
    move.w        d0,d2
    POP           d0 
    divu          #6,d2
    swap          d2
    add.w         #TILE_WALLA,d2

    move.b        d2,(a1)+                             ; random chars
    subq.w        #1,d0
    bne           .fill
    move.b        #TILE_WALLRIGHT,(a1)+
    rts
.isone
    move.b        #TILE_WALLSINGLE,(a1)+
    moveq         #0,d0
    rts
.zero
    move.b        #TILE_BACK,(a1)+
    rts

.fullrandom
    PUSH          d0
    RANDOMWORD
    moveq         #0,d2
    move.w        d0,d2
    POP           d0 
    divu          #9,d2
    swap          d2

    move.b        d2,(a1)+                             ; random chars
    subq.w        #1,d0
    bne           .fullrandom
    rts



WallPaperLoadBase:
    lea           WallpaperBaseTop,a0
    lea           GameMapCeiling(a5),a1
    move.w        #GAME_MAP_SIZE-1,d7
.game
    move.b        (a0)+,(a1)+
    dbra          d7,.game

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
    move.b        #TILE_BACK,(a0)+
    dbra          d7,.cheat
    rts


;-----------------------------------------------
; draw sprite
;-----------------------------------------------


DrawSprite:
    PUSHM         d0-d2

    lea           Sprites,a0
    lea           SpriteMask,a2
    lea           ScreenStatic,a1

    mulu          #TILE_SIZE,d2
    add.l         d2,a0                                ; tile graphic
    add.l         d2,a2                                ; tile graphic

    mulu          #SCREEN_STRIDE,d1
    move.w        d0,d2
    asr.w         #3,d2
    add.w         d2,d1    
    add.l         d1,a1                                ; screen position

    and.w         #$f,d0                               ; shift
    ror.w         #4,d0 
    move.w        d0,d1
    or.w          #$fca,d0                             ; minterm
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
    rts


SHADOW_BLT_MOD         = SCREEN_STRIDE-4
SHADOW_BLT_SIZE        = ((24)<<6)+2

TILE_BLT_MOD           = SCREEN_WIDTH_BYTE-4
TILE_BLT_SIZE          = ((24*SCREEN_DEPTH)<<6)+2

DrawWalls:
    lea           WallpaperWork(a5),a4
    moveq         #28,d2                               ; tile id

    moveq         #0,d1                                ; y
.yloop
    move          #0,d0
.xloop    
    moveq         #0,d2
    move.b        (a4)+,d2                             ; tile id

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
    moveq         #0,d1                                ; y
.yloop
    move          #0,d0
.xloop    
    moveq         #0,d2
    move.b        (a4)+,d2                             ; tile id
    beq           .skip
    lea           ScreenSave,a1
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
    moveq         #0,d1                                ; y
.yloop
    move          #0,d0
.xloop    
    moveq         #0,d2
    move.b        (a4)+,d2                             ; tile id
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

    lea           ScreenSave,a1

    mulu          #SCREEN_STRIDE,d1
    move.w        d0,d2
    asr.w         #3,d2
    add.w         d2,d1    
    add.l         d1,a1                                ; screen position

    and.w         #$f,d0                               ; shift
    ror.w         #4,d0 
    move.w        d0,d1
    or.w          #$d0c,d0                             ; minterm

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
    dc.w          -1                                   ; 0
    dc.w          -1                                   ; 1 
    dc.w          0                                    ; 2
    dc.w          -1                                   ; 3
    dc.w          -1                                   ; 4
    dc.w          5                                    ; 5
    dc.w          -1                                   ; 6
    dc.w          1                                    ; 7
    dc.w          2                                    ; 8
    dc.w          -1                                   ; 9
    dc.w          4                                    ; a
    dc.w          -1                                   ; b
    dc.w          -1                                   ; c
    dc.w          3                                    ; d
    dc.w          -1                                   ; e
    dc.w          4                                    ; f 


; d0 = x
; d1 = y
; d2 = tile id

DrawTile:
    PUSHM         d0-d2

    move.l        TilesetPtr(a5),a0
    lea           ScreenSave,a1

    mulu          #TILE_SIZE,d2
    add.w         d2,a0                                ; tile graphic

    mulu          #SCREEN_STRIDE,d1
    move.w        d0,d2
    asr.w         #3,d2
    add.w         d2,d1    
    add.l         d1,a1                                ; screen position

    and.w         #$f,d0                               ; shift
    ror.w         #4,d0 
    or.w          #$dfc,d0                             ; minterm

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



BUTTON_BLT_MOD         = SCREEN_WIDTH_BYTE-4
BUTTON_BLT_SIZE        = ((19*SCREEN_DEPTH)<<6)+2

BUTTON2_BLT_MOD        = SCREEN_WIDTH_BYTE-6
BUTTON2_BLT_SIZE       = ((19*SCREEN_DEPTH)<<6)+3


LEVEL_COUNT_STRIDE     = LEVEL_COUNT_WIDTH_BYTE*SCREEN_DEPTH
LEVEL_COUNT_START      = (LEVEL_COUNT_STRIDE*5)+3
LEVEL_COUNT_WIDTH_BYTE = 6

LEVEL_FONT_WIDTH_BYTE  = 10
LEVEL_FONT_STRIDE      = 10*SCREEN_DEPTH

; d0 = x
; d1 = y
; a0 = button graphic
DrawLevelCounter:
    PUSHM         d0-d2

    ; make a copy
    lea           LevelCountRaw,a0
    lea           LevelCountTemp,a2
    move.w        #(570/4)-1,d7
.copy
    move.l        (a0)+,(a2)+
    dbra          d7,.copy


    move.w        LevelId(a5),d2
    addq.w        #1,d2
    TODECIMAL     d2,3,d3


    lea           LevelCountTemp,a0
    add.w         #LEVEL_COUNT_START,a0

    moveq         #3-1,d6

.digit
    move.w        d3,d4
    lsr.w         #4,d3
    and.w         #$f,d4
    lea           LevelFont,a2
    add.w         d4,a2                                ; font pos    
    
    moveq         #8-1,d7
    PUSH          a0
.line   
    move.b        (a2),d5
    or.b          LEVEL_FONT_WIDTH_BYTE*1(a2),d5
    or.b          LEVEL_FONT_WIDTH_BYTE*2(a2),d5
    or.b          LEVEL_FONT_WIDTH_BYTE*3(a2),d5
    or.b          LEVEL_FONT_WIDTH_BYTE*4(a2),d5       ; mask
    not.b         d5
    LVLFNT        0
    LVLFNT        1
    LVLFNT        2
    LVLFNT        3
    LVLFNT        4
    add.w         #LEVEL_COUNT_STRIDE,a0
    add.w         #LEVEL_FONT_STRIDE,a2

    dbra          d7,.line

    POP           a0

    subq.l        #1,a0
    dbra          d6,.digit

    ; generate the mask
    lea           LevelCountTemp,a0
    move.l        a0,a2
    lea           ButtonMaskTemp,a3
    move.w        #19-1,d7
.nextline
    move.l        (a2)+,d5
    move.w        (a2)+,d6
    or.l          (a2)+,d5
    or.w          (a2)+,d6
    or.l          (a2)+,d5
    or.w          (a2)+,d6
    or.l          (a2)+,d5
    or.w          (a2)+,d6
    or.l          (a2)+,d5
    or.w          (a2)+,d6
    move.l        d5,(a3)+
    move.w        d6,(a3)+
    move.l        d5,(a3)+
    move.w        d6,(a3)+
    move.l        d5,(a3)+
    move.w        d6,(a3)+
    move.l        d5,(a3)+
    move.w        d6,(a3)+
    move.l        d5,(a3)+
    move.w        d6,(a3)+
    dbra          d7,.nextline

    lea           ButtonMaskTemp,a2
    lea           ScreenSave,a1

    lea           ButtonMaskTemp,a2

    mulu          #SCREEN_STRIDE,d1
    move.w        d0,d2
    asr.w         #3,d2
    add.w         d2,d1    
    add.l         d1,a1                                ; screen position

    and.w         #$f,d0                               ; shift
    ror.w         #4,d0 
    move.w        d0,d1
    or.w          #$fca,d0                             ; minterm

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
    move.w        #BUTTON2_BLT_MOD,BLTCMOD(a6)
    move.w        #BUTTON2_BLT_MOD,BLTDMOD(a6)
    move.w        #BUTTON2_BLT_SIZE,BLTSIZE(a6)

    POPM          d0-d2
    rts

; d0 = x
; d1 = y
; a0 = button graphic
DrawButton:
    PUSHM         d0-d2

    move.l        a0,a2
    lea           ButtonMaskTemp,a3
    move.w        #19-1,d7
.nextline
    move.l        (a2)+,d5
    or.l          (a2)+,d5
    or.l          (a2)+,d5
    or.l          (a2)+,d5
    or.l          (a2)+,d5
    move.l        d5,(a3)+
    move.l        d5,(a3)+
    move.l        d5,(a3)+
    move.l        d5,(a3)+
    move.l        d5,(a3)+
    dbra          d7,.nextline

    lea           ButtonMaskTemp,a2
    lea           ScreenSave,a1

    lea           ButtonMaskTemp,a2

    mulu          #SCREEN_STRIDE,d1
    move.w        d0,d2
    asr.w         #3,d2
    add.w         d2,d1    
    add.l         d1,a1                                ; screen position

    and.w         #$f,d0                               ; shift
    ror.w         #4,d0 
    move.w        d0,d1
    or.w          #$fca,d0                             ; minterm

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
    move.w        #BUTTON_BLT_MOD,BLTCMOD(a6)
    move.w        #BUTTON_BLT_MOD,BLTDMOD(a6)
    move.w        #BUTTON_BLT_SIZE,BLTSIZE(a6)

    POPM          d0-d2
    rts



; d0 = x
; d1 = y
; d2 = tile id
; a1 screen buffer!

; a3 = actors pointer
DrawActor:
    PUSHMOST

    move.w        Actor_PrevX(a3),d0
    mulu          #24,d0
    add.w         Actor_XDec(a3),d0

    move.w        Actor_PrevY(a3),d1
    mulu          #24,d1
    add.w         Actor_YDec(a3),d1

    lea           ScreenStatic,a1
    move.w        Actor_SpriteOffset(a3),d2
    
    move.l        TilesetPtr(a5),a0
    lea           TileMask,a2


    mulu          #TILE_SIZE,d2
    add.w         d2,a0                                ; tile graphic
    add.w         d2,a2                                ; tile graphic

    mulu          #SCREEN_STRIDE,d1
    move.w        d0,d2
    asr.w         #3,d2
    add.w         d2,d1    
    add.l         d1,a1                                ; screen position

    and.w         #$f,d0                               ; shift
    cmp.w         #8,d0
    bcs           .thin

    ; fat blit
    ror.w         #4,d0 
    move.w        d0,d1
    or.w          #$fca,d0                             ; minterm

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

    POPMOST
    rts



.thin
    ror.w         #4,d0 
    move.w        d0,d1
    or.w          #$fca,d0                             ; minterm

    ; test tile blit
    WAITBLIT
    move.w        d0,BLTCON0(a6)
    move.w        d1,BLTCON1(a6)
    move.l        #$ffffffff,BLTAFWM(a6)
    move.l        a2,BLTAPT(a6)
    move.l        a0,BLTBPT(a6)
    move.l        a1,BLTCPT(a6)
    move.l        a1,BLTDPT(a6)
    move.w        #0,BLTAMOD(a6)
    move.w        #0,BLTBMOD(a6)
    move.w        #TILE_BLT_MOD,BLTCMOD(a6)
    move.w        #TILE_BLT_MOD,BLTDMOD(a6)
    move.w        #TILE_BLT_SIZE,BLTSIZE(a6)

    POPMOST       
    rts



; d0 = x
; d1 = y
; d2 = tile id
; a1 screen buffer!
PasteTile:
    PUSHM         d0-d2
    move.l        TilesetPtr(a5),a0
    lea           TileMask,a2


    mulu          #TILE_SIZE,d2
    add.w         d2,a0                                ; tile graphic
    add.w         d2,a2                                ; tile graphic

    mulu          #SCREEN_STRIDE,d1
    move.w        d0,d2
    asr.w         #3,d2
    add.w         d2,d1    
    add.l         d1,a1                                ; screen position

    and.w         #$f,d0                               ; shift
    ror.w         #4,d0 
    move.w        d0,d1
    or.w          #$fca,d0                             ; minterm

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
