
InitGameObjects:
    clr.w       ActorCount(a5)


    lea         GameMap(a5),a0
    moveq       #0,d1                                       ; x
    moveq       #0,d2                                       ; y
.nextcell
    moveq       #0,d0
    move.b      (a0)+,d0
    move.w      d0,d3
    bsr         InitObject
    addq.w      #1,d1                                       ; x
    cmp.w       #WALL_PAPER_WIDTH,d1
    bne         .nextcell
    moveq       #0,d1                                       ; reset x
    addq.w      #1,d2                                       ; next y
    cmp.w       #WALL_PAPER_HEIGHT,d2
    bne         .nextcell
    rts

; d0 - type
; d1 - x
; d2 - y
; d3 = type again

InitObject:
    JMPINDEX    d0
.i
    dc.w        InitDummy-.i                                ;BLOCK_EMPTY       = 0
    dc.w        InitDummy-.i                                ;BLOCK_LADDER      = 1
    dc.w        InitEnemyFall-.i                            ;BLOCK_ENEMYFALL   = 2
    dc.w        InitPushBlock-.i                            ;BLOCK_PUSH        = 3
    dc.w        InitDirt-.i                                 ;BLOCK_DIRT        = 4
    dc.w        InitDummy-.i                                ;BLOCK_SOLID       = 5
    dc.w        InitEnemyFloat-.i                           ;BLOCK_ENEMYFLOAT  = 6
    dc.w        InitMillie-.i                               ;BLOCK_MILLIESTART = 7
    dc.w        InitMolly-.i                                ;BLOCK_MOLLYSTART  = 8

InitDummy:
    rts

InitDirt:
    bsr         GetActorSlot
    moveq       #0,d0
    cmp.b       #BLOCK_DIRT,(a0)
    bne         .notright
    bset        #0,d0
.notright
    cmp.b       #BLOCK_DIRT,-2(a0)
    bne         .notleft
    bset        #1,d0
.notleft
    move.b      .add(pc,d0.w),d0
    add.w       #TILE_DIRTA,d0
    move.w      d0,Actor_SpriteOffset(a3)
    move.w      #1,Actor_Static(a3)
    rts

.add
    dc.b        0,1,3,2

InitEnemyFloat:
    bsr         GetActorSlot
    move.w      #TILE_ENEMYFLOATA,Actor_SpriteOffset(a3)
    rts

InitEnemyFall:
    bsr         GetActorSlot
    move.w      #TILE_ENEMYFALLA,Actor_SpriteOffset(a3)
    move.w      #1,Actor_CanFall(a3)
    rts

InitPushBlock:
    bsr         GetActorSlot
    move.w      #TILE_PUSH,Actor_SpriteOffset(a3)
    move.w      #1,Actor_CanFall(a3)
    move.w      #1,Actor_Static(a3)
    rts

InitMillie:
    lea         Millie(a5),a4
    move.w      #48,Player_SpriteOffset(a4)
    move.w      #97,Player_LadderFreezeId(a4)
    move.b      #BLOCK_MILLIESTART,Player_BlockId(a4)
    move.b      #BLOCK_MILLIELADDER,Player_LadderId(a4)
    bsr         InitPlayer
    rts

InitMolly:
    lea         Molly(a5),a4
    move.w      #0,Player_SpriteOffset(a4)
    move.w      #96,Player_LadderFreezeId(a4)
    move.b      #BLOCK_MOLLYSTART,Player_BlockId(a4)
    move.b      #BLOCK_MOLLYLADDER,Player_LadderId(a4)
    bsr         InitPlayer
    rts

InitPlayer:
    addq.w      #1,PlayerCount(a5)
    clr.w       Player_OnLadder(a4)
    move.w      d1,Player_X(a4)
    move.w      d2,Player_Y(a4)
    move.w      #1,Player_Status(a4)
    move.w      #1,Player_DirectionX(a4)
    
    ;cmp.w       #2,PlayerCount(a5)
    ;bne         .noother
    ;PUSHMOST
    ;bsr         DrawPlayerFrozen
    ;POPMOST
.noother
    rts


; actor returned in a3 or death

GetActorSlot:
    move.w      ActorCount(a5),d5
    cmp.w       #MAX_ACTORS,d5
    bcc         FUCK
    addq.w      #1,ActorCount(a5)
    lea         Actors(a5),a3
    mulu        #Actor_Sizeof,d5
    add.l       d5,a3
    move.w      d1,Actor_X(a3)
    move.w      d2,Actor_Y(a3)
    move.w      d3,Actor_Type(a3)
    move.w      #1,Actor_Status(a3)
    clr.w       Actor_CanFall(a3)
    rts


FUCK:
    move.w      d0,$dff180
    subq.w      #1,d0
    bra         FUCK


DrawStaticActors:
    move.w      ActorCount(a5),d7
    bne         .go
    rts

.go
    lea         Actors(a5),a3
    subq.w      #1,d7
.loop
    tst.w       Actor_Status(a3)
    beq         .notactive

    move.w      Actor_X(a3),d0
    move.w      Actor_Y(a3),d1
    mulu        #24,d0
    mulu        #24,d1
    moveq       #0,d2
    move.w      Actor_SpriteOffset(a3),d2
    lea         ScreenStatic,a1
    bsr         PasteTile

.notactive
    add.w       #Actor_Sizeof,a3
    dbra        d7,.loop
    rts

ActorsSavePos:
    move.w      ActorCount(a5),d7
    bne         .go
    rts
.go
    subq.w      #1,d7
    lea         Actors(a5),a3
.loop
    move.w      Actor_X(a3),Actor_PrevX(a3)
    move.w      Actor_Y(a3),Actor_PrevY(a3)
    clr.w       Actor_HasMoved(a3)
    add.w       #Actor_Sizeof,a3
    dbra        d7,.loop
    rts


ClearFrozenPlayer:
    PUSH        a4
    move.l      PlayerPtrs+4(a5),a4
    tst.w       Player_Fallen(a4)
    beq         .nofall

    move.w      Player_PrevX(a4),d0
    move.w      Player_PrevY(a4),d1
    bsr         ClearStaticBlock

.nofall
    POP         a4
    rts

ClearMovedActors:
    move.w      ActorCount(a5),d7
    bne         .go
    rts
.go
    subq.w      #1,d7
    lea         Actors(a5),a3
.loop
    tst.w       Actor_Status(a3)
    beq         .next
    tst.w       Actor_HasMoved(a3)
    beq         .next

    move.w      Actor_PrevX(a3),d0
    move.w      Actor_PrevY(a3),d1
    bsr         ClearStaticBlock

.next
    add.w       #Actor_Sizeof,a3
    dbra        d7,.loop
    rts

DrawMovedActors:
    move.w      ActorCount(a5),d7
    bne         .go
    rts
.go
    subq.w      #1,d7
    lea         Actors(a5),a3
.loop
    tst.w       Actor_HasMoved(a3)
    beq         .next

    bsr         ActorDrawStatic
    clr.w       Actor_HasMoved(a3)

.next
    add.w       #Actor_Sizeof,a3
    dbra        d7,.loop
    rts


DrawMovedPlayer:
    PUSH        a4
    move.l      PlayerPtrs+4(a5),a4
    tst.w       Player_Fallen(a4)
    beq         .nofall

    bsr         DrawPlayerFrozen
    clr.w       Player_Fallen(a4)

.nofall
    POP         a4
    rts