
;-----------------------------------------------
; Millie and Molly Amiga Port
;-----------------------------------------------

    INCDIR     "include"
    INCLUDE    "hw.i"
    INCLUDE    "funcdef.i"
    include    "macros.asm"
    include    "variables.asm"
    include    "intbits.i"
    include    "dmabits.i"
    include    "const.asm"
    include    "struct.asm"

;-----------------------------------------------
; MAIN
;-----------------------------------------------

    section    main,code
Main:
    lea        .trap(pc),a0
    move.l     a0,$80
    trap       #0
.trap

Restart:
    ;lea        AllChip,a0
    ;move.l     #AllChipEnd-AllChip,d7
    ;bsr        TurboClear

    ;lea        AllFast,a0
    ;move.l     #AllFastEnd-AllFast,d7
    ;bsr        TurboClear

    lea        CUSTOM,a6
    lea        Variables,a5
    move.w     #$7fff,DMACON(a6)
    move.w     #$7fff,ADKCON(a6)
    move.w     #$7fff,INTENA(a6)
    move.w     #$7fff,INTREQ(a6)

    bsr        Init

    bsr        DrawMap
    bsr        StartVBlank
.forever
    bra        .forever

LevelTest:
    tst.w      LevelComplete(a5)
    beq        .nope
    addq.w     #1,LevelId(a5)
    bra        .draw

.nope
    lea        Keys,a0
    tst.b      KEY_F1(a0)
    beq        .nof1
    clr.b      KEY_F1(a0)
    tst.w      LevelId(a5)
    beq        .nof1
    subq.w     #1,LevelId(a5)
    bra        .draw
.nof1
    tst.b      KEY_F2(a0)
    beq        .nof2
    clr.b      KEY_F2(a0)
    cmp.w      #99,LevelId(a5)
    beq        .nof2
    addq.w     #1,LevelId(a5)
.draw
    bsr        DrawMap
.nof2
    rts

DrawPlayers:
    lea        Millie(a5),a4
    ;bsr        DrawPlayer
    bsr        ShowSprite
    lea        Molly(a5),a4
    bsr        DrawPlayer
    rts

DrawPlayer:
    tst.w      Player_Status(a4)
    beq        .exit
    moveq      #0,d0
    moveq      #0,d1
    move.w     Player_X(a4),d0
    move.w     Player_Y(a4),d1
    mulu       #24,d0
    mulu       #24,d1
    moveq      #0,d2
    add.w      Player_SpriteOffset(a4),d2
    bsr        DrawSprite
.exit
    rts
    
Init:
    bsr        CreateClearMasks
    bsr        KeyboardInit
    bsr        CopperInit
    bsr        GenSpriteMask
    move.l     #cpTest,COP1LC(a6)
    move.w     #0,COPJMP1(a6)

    move.l     #-1,ScreenMemEnd
    move.w     #BASE_DMA,DMACON(a6)

    move.w     #START_LEVEL,LevelId(a5)

    rts



CreateClearMasks:
    moveq      #16-1,d7
    lea        ClearMasks(a5),a0
    move.l     #$ffffff00,d0
.loop
    move.l     d0,(a0)+
    lsr.l      #1,d0
    bcc        .under
    move.w     #$8000,d0
.under
    dbra       d7,.loop
    rts    


StartVBlank:
    move.l     #VBlankTick,$6c
    move.w     #INTF_SETCLR|INTF_VERTB|INTF_COPER,INTENA(a6)
    rts

VBlankTick:
    PUSHALL
    lea        CUSTOM,a6                   
    lea        Variables,a5

    move.w     INTREQR(a6),d0
    move.w     d0,d1
    and.w      #INTF_VERTB,d1
    beq        .novertb
    move.w     d1,INTREQ(a6)
    move.w     d1,INTREQ(a6)                                              ; twice to avoid a4k hw bug

    addq.w     #1,TickCounter(a5)

    bsr        LevelTest
    ;bsr        DrawPlayers

    bsr        UpdateControls

    move.l     PlayerPtrs(a5),a4
    bsr        PlayerLogic
    ;bra        .exit

.novertb
    ;move.w     d0,d1
    ;and.w      #INTF_COPER,d1
    ;beq        .exit    
    ;move.w     d1,INTREQ(a6)
    ;move.w     d1,INTREQ(a6)                                    ; twice to avoid a4k hw bug

    ; copper, nothing here!
.exit
    POPALL
    rte



CopperInit:
    move.l     #Screen1,ScreenPtrs(a5)
    move.l     #Screen2,ScreenPtrs+4(a5)

    bsr        ClearSprites

    move.l     #ScreenStatic,d0
    lea        cpPlanes,a0
    moveq      #SCREEN_DEPTH-1,d7
.ploop
    move.w     d0,6(a0)
    swap       d0
    move.w     d0,2(a0)
    swap       d0
    addq.l     #8,a0
    add.l      #SCREEN_WIDTH_BYTE,d0
    dbra       d7,.ploop

    lea        TilesPal0,a0
    lea        cpPal,a1
    moveq      #SCREEN_COLORS-1,d7
.cloop
    move.w     (a0)+,2(a1)    
    addq.l     #4,a1
    dbra       d7,.cloop

    rts

ClearSprites:
    lea        cpSprites,a0
    move.l     #NullSprite,d0
    moveq      #8-1,d7
.loop
    move.w     d0,6(a0)
    swap       d0
    move.w     d0,2(a0)
    swap       d0
    add.l      #8,a0
    dbra       d7,.loop
    rts



;----------------------------------------------
;  includes!
;----------------------------------------------

    include    "keyboard.asm"
    include    "tools.asm"
    include    "mapstuff.asm"
    include    "actors.asm"
    include    "zx0_faster.asm"
    include    "spritetools.asm"
    include    "player.asm"
    include    "controls.asm"

;----------------------------------------------
;  data fast
;----------------------------------------------

    section    data_fast,data


Quartic:    
    incbin     "assets/quartic.bin"
Quadratic:    
    incbin     "assets/quadratic.bin"
Sinus:    
    incbin     "assets/sin.bin"
SinusEnd:


    include    "assets.asm"

SpritePal:
    incbin     "assets/sprites.pal"

TilesPal0:
    incbin     "assets/Tiles/tiles_0.pal"
TilesPal1:
    incbin     "assets/Tiles/tiles_1.pal"
TilesPal2:
    incbin     "assets/Tiles/tiles_2.pal"
TilesPal3:
    incbin     "assets/Tiles/tiles_3.pal"
TilesPal4:
    incbin     "assets/Tiles/tiles_4.pal"

LevelData:
    incbin     "assets/Levels/levels.bin"
WallpaperBaseTop:
    dc.b       $05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05
WallpaperBase:
    REPT       WALL_PAPER_HEIGHT-1
    dc.b       $05,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$05,$05
    ENDR
    dc.b       $05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05
    
LevelCountRaw:
    incbin     "assets/ui_4.bin"
LevelCountRawEnd:

;----------------------------------------------
;  data chip
;----------------------------------------------

    section    data_chip,data_c

    include    "copperlists.asm"

RealSprites:
    incbin     "assets/realsprites.bin"

Sprites:
    incbin     "assets/sprites.bin"
Shadows:
    incbin     "assets/shadows.bin"

LevelFont:
    incbin     "assets/levelfont.bin"

    include    "uigfx.asm"


;----------------------------------------------
;   mem fast
;----------------------------------------------

    section    mem_fast,bss

AllFast:

Variables:
    ds.b       Variables_sizeof


Keys:
    ds.b       256
    ds.b       200
	
AllFastEnd:



;----------------------------------------------
;   mem chip
;----------------------------------------------

    section    mem_chip,bss_c
AllChip:

NullSprite:    
    ds.l       0,0

ButtonMaskTemp:
    ds.b       570
LevelCountTemp:
    ds.b       570


TileSet:
    ds.b       TILESET_SIZE
TileMask:
    ds.b       TILESET_SIZE
SpriteMask:
    ds.b       SPRITESET_SIZE

Screen1:
    ds.b       SCREEN_SIZE
Screen2:
    ds.b       SCREEN_SIZE

ScreenStatic:
    ds.b       SCREEN_SIZE

ScreenSave:
    ds.b       SCREEN_SIZE

ScreenMemEnd:
    ds.b       200

AllChipEnd:
