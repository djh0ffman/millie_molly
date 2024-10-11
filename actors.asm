
InitGameObjects:
    lea         GameMap+WALL_PAPER_WIDTH(a5),a0
    moveq       #0,d1                              ; x
    moveq       #0,d2                              ; y
.nextcell
    moveq       #0,d0
    move.b      (a0)+,d0
    bsr         InitObject
    addq.w      #1,d1                              ; x
    cmp.w       #WALL_PAPER_WIDTH,d1
    bne         .nextcell
    moveq       #0,d1                              ; reset x
    addq.w      #1,d2                              ; next y
    cmp.w       #WALL_PAPER_HEIGHT,d2
    bne         .nextcell
    rts


InitObject:
    JMPINDEX    d0
.i
    dc.w        InitDummy-.i                       ;BLOCK_EMPTY       = 0
    dc.w        InitDummy-.i                       ;BLOCK_LADDER      = 1
    dc.w        InitDummy-.i                       ;BLOCK_ENEMYFALL   = 2
    dc.w        InitDummy-.i                       ;BLOCK_PUSH        = 3
    dc.w        InitDummy-.i                       ;BLOCK_DIRT        = 4
    dc.w        InitDummy-.i                       ;BLOCK_SOLID       = 5
    dc.w        InitDummy-.i                       ;BLOCK_ENEMYFLOAT  = 6
    dc.w        InitMillie-.i                      ;BLOCK_MILLIESTART = 7
    dc.w        InitMolly-.i                       ;BLOCK_MOLLYSTART  = 8

InitDummy:
    rts

InitMillie:
    lea         Millie(a5),a4
    bsr         InitPlayer
    rts

InitMolly:
    lea         Molly(a5),a4
    bsr         InitPlayer
    rts

InitPlayer:
    move.w      d1,Player_X(a4)
    move.w      d2,Player_Y(a4)
    rts