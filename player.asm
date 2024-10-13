;----------------------------------------------
;  player logic
;
; a4 = player structure
;
;----------------------------------------------

PlayerLogic:
    clr.w       PlayerMoved(a5)
    bsr         PlayerCheckControls
    tst.w       PlayerMoved(a5)
    beq         .exit
    bsr         PlayerMoveLogic
    bsr         PlayerFallLogic

    bsr         CheckLevelDone
    tst.w       d3
    bne         .notdone
    move.w      #1,LevelComplete(a5)
.notdone
.exit
    rts


CheckLevelDone:
    lea         GameMap(a5),a0
    moveq       #WALL_PAPER_SIZE-1,d7
    moveq       #0,d3                            ; enemy count
.loop
    move.b      (a0)+,d0
    cmp.b       #BLOCK_ENEMYFALL,d0
    beq         .notdone
    cmp.b       #BLOCK_ENEMYFLOAT,d0
    bne         .next
.notdone
    moveq       #1,d3
    rts
.next
    dbra        d7,.loop
    rts



PlayerMoveLogic:
    tst.w       PlayerMoved(a5)
    beq         .nomove

    lea         GameMap(a5),a0

    move.w      Player_Y(a4),d0
    mulu        #WALL_PAPER_WIDTH,d0
    add.w       Player_X(a4),d0

    move.w      Player_NextY(a4),d1
    mulu        #WALL_PAPER_WIDTH,d1
    add.w       Player_NextX(a4),d1

    move.b      (a0,d0.w),d2                     ; current
    move.b      (a0,d1.w),d3                     ; next

    move.b      Player_BlockId(a4),d4            ; next block??
    cmp.b       #BLOCK_LADDER,d3 
    bne         .notladdernext
    move.b      Player_LadderId(a4),d4
.notladdernext
    move.b      d4,(a0,d1.w)

    move.b      #BLOCK_EMPTY,d4
    cmp.b       Player_LadderId(a4),d2
    bne         .notladderlast
    move.b      #BLOCK_LADDER,d4
.notladderlast
    move.b      d4,(a0,d0.w)

    move.w      Player_NextX(a4),Player_X(a4)
    move.w      Player_NextY(a4),Player_Y(a4)
.nomove
    rts


PlayerFallLogic:
    tst.w       PlayerMoved(a5)
    beq         .exit

    lea         GameMap(a5),a0

    move.w      Player_Y(a4),d0
    mulu        #WALL_PAPER_WIDTH,d0
    add.w       Player_X(a4),d0

    move.b      Player_LadderId(a4),d1
    cmp.b       (a0,d0.w),d1
    beq         .exit

    moveq       #-1,d3                           ; fall count

.findfloor
    addq.w      #1,d3
    add.w       #WALL_PAPER_WIDTH,d0
    tst.b       (a0,d0.w)
    bne         .found
    bra         .findfloor

.found
    add.w       d3,Player_Y(a4)

.exit
    rts



PlayerCheckControls:
    move.w      Player_Status(a4),d0
    JMPINDEX    d0

.i
    dc.w        PlayerInactive-.i
    dc.w        PlayerIdle-.i

PlayerInactive:
    rts

PlayerIdle:
    bsr         PlayerShowIdleAnim
    move.b      ControlsTrigger(a5),d0

    move.w      #1,Player_DirectionX(a4)
    btst        #CONTROLB_RIGHT,d0
    bne         .move

    move.w      #-1,Player_DirectionX(a4)
    btst        #CONTROLB_LEFT,d0
    bne         .move

    clr.w       Player_DirectionX(a4)

    move.w      #1,Player_DirectionY(a4)
    btst        #CONTROLB_DOWN,d0
    bne         .move

    move.w      #-1,Player_DirectionY(a4)
    btst        #CONTROLB_UP,d0
    beq         .nomove

    move.w      Player_Y(a4),d1
    mulu        #WALL_PAPER_WIDTH,d1
    add.w       Player_X(a4),d1

    lea         GameMap(a5),a0
    move.b      (a0,d1.w),d1
    cmp.b       Player_LadderId(a4),d1
    beq         .move
.nomove
    clr.w       Player_DirectionY(a4)
    rts

.move
    bsr         PlayerTryMove

.exit
    rts


PlayerShowIdleAnim:
    move.w      TickCounter(a5),d0
    divu        #5,d0
    swap        d0
    tst.w       d0
    beq         .anim
    rts
.anim
    move.w      Player_AnimFrame(a4),d0
    addq.w      #1,d0
    and.w       #3,d0
    move.w      d0,Player_AnimFrame(a4)
    bsr         ShowSprite
    rts


;----------------------------------------------
;  player try move
;
;  based on the direction see what action the 
; player can do.
;
;----------------------------------------------

PlayerTryMove:
    move.w      Player_DirectionX(a4),d1
    bsr         PlayerGetNextBlock

    JMPINDEX    d2
.i
    dc.w        PlayerDoMove-.i                  ;BLOCK_EMPTY       = 0
    dc.w        PlayerDoMove-.i                  ;BLOCK_LADDER      = 1
    dc.w        PlayerKillEnemy-.i               ;BLOCK_ENEMYFALL   = 2
    dc.w        PlayerNotMove-.i                 ;BLOCK_PUSH        = 3
    dc.w        PlayerNotMove-.i                 ;BLOCK_DIRT        = 4
    dc.w        PlayerNotMove-.i                 ;BLOCK_SOLID       = 5
    dc.w        PlayerKillEnemy-.i               ;BLOCK_ENEMYFLOAT  = 6
    dc.w        PlayerNotMove-.i                 ;BLOCK_MILLIESTART = 7
    dc.w        PlayerNotMove-.i                 ;BLOCK_MOLLYSTART  = 8
    dc.w        PlayerMoveLadder-.i              ;BLOCK_LADDERSTART = 7
    dc.w        PlayerMoveLadder-.i              ;BLOCK_MOLLYSTART  = 8
    rts

PlayerNotMove:
    rts

PlayerMoveLadder:
    bsr         PlayerDoMove
    rts


PlayerKillEnemy:
    bsr         PlayerDoMove
    bsr         PlayerKillActor
    rts


PlayerDoMove:
    move.w      #1,PlayerMoved(a5)

    move.w      Player_DirectionX(a4),d0
    add.w       Player_X(a4),d0
    move.w      Player_DirectionY(a4),d1
    add.w       Player_Y(a4),d1

    move.w      d0,Player_NextX(a4)
    move.w      d1,Player_NextY(a4)

    rts


PlayerKillActor:
    move.w      ActorCount(a5),d7
    beq         .exit
    subq.w      #1,d7

    move.w      Player_NextX(a4),d0
    move.w      Player_NextY(a4),d1

    lea         Actors(a5),a3
.loop
    cmp.w       Actor_X(a3),d0
    bne         .next
    cmp.w       Actor_Y(a3),d1
    bne         .next

    ; kill
    clr.w       Actor_Status(a3)
    mulu        #WALL_PAPER_WIDTH,d1
    add.w       d1,d0
    lea         GameMap(a5),a0
    clr.b       (a0,d0.w)
    bra         .exit                            ; killed something we are done

.next
    add.w       #Actor_Sizeof,a3
    dbra        d7,.loop    
.exit
    rts


; a4 = player struct
; d1 = map offset

; returns 
; d2 = block!

PlayerGetNextBlock:
    move.w      Player_Y(a4),d0
    add.w       Player_DirectionY(a4),d0
    mulu        #WALL_PAPER_WIDTH,d0
    add.w       Player_X(a4),d0                  ; offset in map
    add.w       Player_DirectionX(a4),d0

    lea         GameMap(a5),a0
    moveq       #0,d2
    move.b      (a0,d0.w),d2
    rts