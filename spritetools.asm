
;-----------------------------------------------
; Sprite
;-----------------------------------------------

;a4 = player structure

ShowSprite:
    tst.w     Player_Status(a4)
    bne       .go
    bsr       ClearSprites
    rts
.go
    moveq     #0,d1
    moveq     #0,d2
    move.w    Player_X(a4),d1
    move.w    Player_Y(a4),d2
    mulu      #24,d1
    mulu      #24,d2

    move.w    Player_SpriteOffset(a4),d0
    add.w     Player_AnimFrame(a4),d0

    mulu      #SPRITE_SIZE*4,d0
    lea       RealSprites,a0
    add.l     d0,a0

    move.w    #$80,d5
    swap      d5
    move.w    #TILE_HEIGHT,d5               ; height

    move.l    a0,SpritePtrs(a5)                      

    bsr       SpriteCoord

    add.w     #16,d1

    add.w     #SPRITE_SIZE,a0
    move.l    a0,SpritePtrs+8(a5)    

    move.w    #$80,d5
    swap      d5
    move.w    #TILE_HEIGHT,d5               ; height

    bsr       SpriteCoord

    sub.w     #16,d1
    add.w     #SPRITE_SIZE,a0


    move.w    #$80,d5
    swap      d5
    move.w    #TILE_HEIGHT,d5               ; height

    move.l    a0,SpritePtrs+4(a5)               

    bsr       SpriteCoord

    add.w     #SPRITE_SIZE,a0
    add.w     #16,d1
    move.l    a0,SpritePtrs+12(a5)    

    move.w    #$80,d5
    swap      d5
    move.w    #TILE_HEIGHT,d5               ; height
    bsr       SpriteCoord



    lea       cpSprites,a0
    move.l    #NullSprite,d0
    lea       SpritePtrs(a5),a1
    moveq     #4-1,d7
.loop
    move.l    (a1)+,d0
    move.w    d0,6(a0)
    swap      d0
    move.w    d0,2(a0)
    swap      d0
    add.l     #8,a0
    dbra      d7,.loop


    rts


;----------------------------------------------------------------------------
;
; sprite coord
;
; d1 = x
; d2 = y
; a0 = sprite strucutre
;
; d5 = $80 attach bit
;
;----------------------------------------------------------------------------


SpriteCoord:
    PUSHM     d1/d2

    add.w     #WINDOW_X_START-1,d1
    moveq     #0,d4
    ;move.b        ScreenStart(a5),d4
    move.w    #WINDOW_Y_START,d4
    add.w     d4,d2

    move.l    d1,d4
    swap      d4
    lsr.l     #1,d4
    rol.w     #1,d4                         ; H START

    move.l    d2,d3
    lsl.l     #8,d3
    swap      d3
    lsl.w     #2,d3
    or.l      d3,d4                         ; V START ( lower bits )

    move.l    d2,d3
    ;add.w         #18,d3                                                     ; Height
    add.w     d5,d3                         ; height
    rol.w     #8,d3
    lsl.b     #1,d3
    or.l      d3,d4                         ; V STOP ( lower bits )

    swap      d5
    or.b      d5,d4                         ; attach bit
    
    move.l    d4,(a0)
    POPM      d1/d2

    rts