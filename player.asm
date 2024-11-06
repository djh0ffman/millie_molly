;----------------------------------------------
;  player logic
;
; a4 = player structure
;
;----------------------------------------------

PlayerLogic:
    move.w      ActionStatus(a5),d0
    JMPINDEX    d0

.i
    dc.w        ActionIdle-.i
    dc.w        ActionMove-.i
    dc.w        ActionPlayerFall-.i


;----------------------------------------------
;  action fall
;----------------------------------------------


ActionPlayerFall:
    move.w      Player_Y(a4),d0
    move.w      Player_NextY(a4),d1
    mulu        #24,d0
    mulu        #24,d1
    sub.w       d0,d1                                      ; total pixels

    move.w      Player_ActionFrame(a4),d2
    lea         Quadratic,a0
    add.w       d2,d2
    move.w      (a0,d2.w),d2
    divu        d1,d2
    
    cmp.w       d1,d2
    bcs         .inrange
    move.w      d1,d2
.inrange    
    move.w      d2,Player_YDec(a4) 

    addq.w      #1,Player_ActionFrame(a4)

    cmp.w       d1,d2
    bne         .show


;    addq.w      #1,Player_YDec(a4)                         ; 24
;    cmp.w       #24,Player_YDec(a4)
;    bne         .show
;    clr         Player_YDec(a4)
;    move.w      Player_Y(a4),d0
;    addq.w      #1,d0
;    move.w      d0,Player_Y(a4)
;    cmp.w       Player_NextY(a4),d0
;    bne         .show

    ; exit the fall
    clr.w       ActionStatus(a5)
    clr.w       Player_YDec(a4)
    move.w      Player_NextY(a4),Player_Y(a4)

.show
    move.w      Player_AnimFrame(a4),d0
    add.w       #PLAYER_SPRITE_FALL_OFFSET,d0
    bsr         ShowSprite
    rts

;----------------------------------------------
;  action move
;----------------------------------------------

ActionMove:
    move.w      Player_XDec(a4),d0
    add.w       Player_DirectionX(a4),d0
    move.w      d0,Player_XDec(a4)

    move.w      Player_YDec(a4),d0
    add.w       Player_DirectionY(a4),d0
    move.w      d0,Player_YDec(a4)

    bsr         PlayerShowWalkAnim

    subq.w      #1,Player_ActionCount(a4)
    bne         .exit

    clr.w       ActionStatus(a5)
    clr.w       Player_XDec(a4)
    clr.w       Player_YDec(a4)

    bsr         PlayerMoveLogic
    bsr         PlayerFallLogic
    
    ;move.w      Player_DirectionX(a4),d0
    ;add.w       d0,Player_X(a4)
.exit
    rts


ActionIdle:
    btst        #CONTROLB_FIRE,ControlsTrigger(a5)
    bne         PlayerSwitch

    clr.w       PlayerMoved(a5)
    bsr         ActorsSavePos

    bsr         PlayerCheckControls
    tst.w       ActionStatus(a5)
    bne         .exit

    bsr         PlayerMoveLogic
    bsr         PlayerFallLogic

    bsr         ActorFallAll
    bsr         PlayerFallLogicFrozen

    bsr         ClearMovedActors
    bsr         ClearFrozenPlayer
    bsr         DrawMovedActors
    bsr         DrawMovedPlayer

    bsr         CheckLevelDone
    tst.w       d3
    bne         .notdone
    move.w      #1,LevelComplete(a5)
.notdone
.exit
    rts


PlayerSwitch:
    move.l      PlayerPtrs+4(a5),a0
    tst.w       Player_Status(a0)
    beq         .noswitch

    bsr         DrawPlayerFrozen
    move.w      #2,Player_Status(a4)

    move.l      PlayerPtrs+4(a5),a4
    move.l      PlayerPtrs(a5),PlayerPtrs+4(a5)
    move.l      a4,PlayerPtrs(a5)
    move.w      #1,Player_Status(a4)
    bsr         ClearPlayer
.noswitch
    rts


DrawPlayerFrozen:
    move.w      Player_X(a4),d0
    move.w      Player_Y(a4),d1
    mulu        #24,d0
    mulu        #24,d1

    moveq       #0,d2
    move.w      Player_LadderFreezeId(a4),d2
    tst.w       Player_OnLadder(a4)
    bne         .isright

    move.w      Player_SpriteOffset(a4),d2
    add.w       #46,d2
    tst.w       Player_Facing(a4)
    bpl         .isright
    addq.w      #1,d2
.isright
    bsr         DrawSprite
    rts

CheckLevelDone:
    lea         GameMap(a5),a0
    moveq       #WALL_PAPER_SIZE-1,d7
    moveq       #0,d3                                      ; enemy count
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

    move.b      (a0,d0.w),d2                               ; current
    move.b      (a0,d1.w),d3                               ; next

    move.b      Player_BlockId(a4),d4                      ; next block??
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




PlayerFallLogicFrozen:
    PUSH        a4
    move.l      PlayerPtrs+4(a5),a4
    cmp.w       #2,Player_Status(a4)
    bne         .exit

    move.w      Player_X(a4),Player_PrevX(a4)
    move.w      Player_Y(a4),Player_PrevY(a4)

    lea         GameMap(a5),a0

    move.w      Player_Y(a4),d0
    mulu        #WALL_PAPER_WIDTH,d0
    add.w       Player_X(a4),d0
    move.w      d0,d1

    move.b      Player_LadderId(a4),d2
    cmp.b       (a0,d1.w),d2
    beq         .exit

    moveq       #0,d3                                      ; fall count

.findfloor
    tst.b       WALL_PAPER_WIDTH(a0,d1.w)
    bne         .found
    addq.w      #1,d3
    add.w       #WALL_PAPER_WIDTH,d1
    bra         .findfloor

.found
    tst.w       d3
    beq         .exit
    add.w       d3,Player_Y(a4)
    clr.b       (a0,d0.w)
    move.b      Player_BlockId(a4),(a0,d1.w)
    move.w      #1,Player_Fallen(a4)

.exit
    POP         a4
    rts

PlayerFallLogic:
    tst.w       PlayerMoved(a5)
    beq         .exit

    lea         GameMap(a5),a0

    move.w      Player_Y(a4),d0
    mulu        #WALL_PAPER_WIDTH,d0
    add.w       Player_X(a4),d0
    move.w      d0,d1

    move.b      Player_LadderId(a4),d2
    cmp.b       (a0,d1.w),d2
    beq         .exit

    moveq       #0,d3                                      ; fall count

.findfloor
    tst.b       WALL_PAPER_WIDTH(a0,d1.w)
    bne         .found
    addq.w      #1,d3
    add.w       #WALL_PAPER_WIDTH,d1
    bra         .findfloor

.found
    tst.w       d3
    beq         .exit

    ; setup fall
    ; set player next position
    add.w       Player_Y(a4),d3
    move.w      d3,Player_NextY(a4)
    move.w      Player_X(a4),Player_NextX(a4)

    clr.b       (a0,d0.w)
    move.b      Player_BlockId(a4),(a0,d1.w)
    move.w      #ACTION_PLAYERFALL,ActionStatus(a5)
    clr.w       Player_AnimFrame(a4)

    clr.w       Player_ActionFrame(a4)

.exit
    rts



PlayerCheckControls:
    move.w      Player_Status(a4),d0
    JMPINDEX    d0

.i
    dc.w        PlayerInactive-.i
    dc.w        PlayerIdle-.i
    dc.w        PlayerFrozen-.i

PlayerFrozen:
    rts


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
    move.w      Player_DirectionX(a4),Player_Facing(a4)
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
    move.w      Player_Y(a4),d1
    mulu        #WALL_PAPER_WIDTH,d1
    add.w       Player_X(a4),d1

    moveq       #PLAYER_SPRITE_LADDER_IDLE,d0             

    moveq       #0,d2
    lea         GameMap(a5),a0
    move.b      (a0,d1.w),d1
    cmp.b       Player_LadderId(a4),d1
    bne         .noladder1
    moveq       #1,d2
.noladder1
    move.w      d2,Player_OnLadder(a4)
    bne         .isright

    move.w      Player_AnimFrame(a4),d0
    addq.w      #1,d0
    and.w       #3,d0
    move.w      d0,Player_AnimFrame(a4)

    tst.w       Player_OnLadder(a4)
    beq         .noladder
    add.w       #PLAYER_SPRITE_LADDER_OFFSET,d0
    bra         .isright

.noladder
    tst.w       Player_Facing(a4)
    bpl         .isright
    add.w       #PLAYER_SPRITE_LEFT_OFFSET,d0

.isright
    bsr         ShowSprite
    rts





PlayerShowWalkAnim:
    move.w      TickCounter(a5),d0
    and.w       #1,d0
    bne         .show
;    rts
;.anim
    move.w      Player_AnimFrame(a4),d0
    addq.w      #1,d0
    and.w       #7,d0
    move.w      d0,Player_AnimFrame(a4)
.show
    move.w      Player_AnimFrame(a4),d0
    move.w      #PLAYER_SPRITE_LADDER_OFFSET,d1
    tst.w       Player_OnLadder(a4)
    bne         .isright

    move.w      #PLAYER_SPRITE_WALK_OFFSET,d1

    tst.w       Player_Facing(a4)
    bpl         .isright
    add.w       #PLAYER_SPRITE_LEFT_OFFSET,d0

.isright
    add.w       d1,d0
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
    dc.w        PlayerDoMove-.i                            ;BLOCK_EMPTY       = 0
    dc.w        PlayerDoMove-.i                            ;BLOCK_LADDER      = 1
    dc.w        PlayerKillEnemy-.i                         ;BLOCK_ENEMYFALL   = 2
    dc.w        PlayerPushBlock-.i                         ;BLOCK_PUSH        = 3
    dc.w        PlayerKillDirt-.i                          ;BLOCK_DIRT        = 4
    dc.w        PlayerNotMove-.i                           ;BLOCK_SOLID       = 5
    dc.w        PlayerKillEnemy-.i                         ;BLOCK_ENEMYFLOAT  = 6
    dc.w        PlayerNotMove-.i                           ;BLOCK_MILLIESTART = 7
    dc.w        PlayerNotMove-.i                           ;BLOCK_MOLLYSTART  = 8
    dc.w        PlayerMoveLadder-.i                        ;BLOCK_LADDERSTART = 7
    dc.w        PlayerMoveLadder-.i                        ;BLOCK_MOLLYSTART  = 8
    rts

PlayerPushBlock:
    add.w       Player_DirectionX(a4),d0
    tst.b       (a0,d0.w)
    beq         PlayerMoveActor
    rts

PlayerNotMove:
    rts

PlayerMoveLadder:
    bsr         PlayerDoMove
    rts

PlayerKillDirt:
    tst.w       Player_DirectionY(a4)
    bne         .nokill
    bsr         PlayerDoMove
    bsr         PlayerKillActor
.nokill
    rts

PlayerKillEnemy:
    tst.w       Player_DirectionY(a4)
    bne         .nokill
    bsr         PlayerDoMove
    bsr         PlayerKillActor
.nokill
    rts


PlayerDoMove:
    move.w      #1,PlayerMoved(a5)

    move.w      Player_DirectionX(a4),d0
    add.w       Player_X(a4),d0
    move.w      Player_DirectionY(a4),d1
    add.w       Player_Y(a4),d1

    move.w      d0,Player_NextX(a4)
    move.w      d1,Player_NextY(a4)


    move.w      #ACTION_MOVE,ActionStatus(a5)
    move.w      #24,Player_ActionCount(a4)

    clr.w       Player_XDec(a4)
    clr.w       Player_YDec(a4)
    rts


PlayerMoveActor:
    move.w      ActorCount(a5),d7
    beq         .exit
    subq.w      #1,d7

    move.w      Player_X(a4),d0
    move.w      Player_Y(a4),d1
    add.w       Player_DirectionX(a4),d0

    lea         Actors(a5),a3
.loop
    tst.w       Actor_Status(a3)
    beq         .next
    cmp.w       Actor_X(a3),d0
    bne         .next
    cmp.w       Actor_Y(a3),d1
    bne         .next

    ; move
    ;bsr         RemoveStaticActor

    move.w      Player_DirectionX(a4),d2
    add.w       d2,Actor_X(a3)


    mulu        #WALL_PAPER_WIDTH,d1
    add.w       d1,d0
    add.w       d0,d2
    lea         GameMap(a5),a0
    move.b      (a0,d0.w),(a0,d2.w)    
    clr.b       (a0,d0.w)

    move.w      #1,Actor_HasMoved(a3)
    ;bsr         ActorFall
    ;bsr         ActorDrawStatic
    bra         .exit                                      ; killed something we are done

.next
    add.w       #Actor_Sizeof,a3
    dbra        d7,.loop    
.exit
    rts 

ActorFallAll:
    moveq       #0,d5                                      ; fall count
    move.w      ActorCount(a5),d7
    bne         .go
    rts
.go
    subq.w      #1,d7
    lea         Actors(a5),a3
.loop
    tst.w       Actor_Status(a3)
    beq         .nofall
    tst.w       Actor_CanFall(a3)
    beq         .nofall
    bsr         ActorFall
    tst.w       d3
    beq         .nofall
    add.w       d3,d5

.nofall
    add.w       #Actor_Sizeof,a3
    dbra        d7,.loop
    tst.w       d5
    bne         ActorFallAll
    rts


ActorDrawStatic:
    move.w      Actor_X(a3),d0
    move.w      Actor_Y(a3),d1
    mulu        #24,d0
    mulu        #24,d1
    moveq       #0,d2
    move.w      Actor_SpriteOffset(a3),d2
    lea         ScreenStatic,a1
    bsr         PasteTile
    rts

; a3 = actor

ActorFall:
    lea         GameMap(a5),a0

    move.w      Actor_Y(a3),d0
    mulu        #WALL_PAPER_WIDTH,d0
    add.w       Actor_X(a3),d0
    move.w      d0,d1

    moveq       #0,d3                                      ; fall count

.findfloor
    tst.b       WALL_PAPER_WIDTH(a0,d1.w)
    bne         .found
    addq.w      #1,d3
    add.w       #WALL_PAPER_WIDTH,d1
    bra         .findfloor

.found
    tst.w       d3
    beq         .exit
    add.w       d3,Actor_Y(a3)
    move.w      #1,Actor_HasMoved(a3)
    move.b      (a0,d0.w),(a0,d1.w)
    clr.b       (a0,d0.w)
.exit
    rts

PlayerKillActor:
    move.w      ActorCount(a5),d7
    beq         .exit
    subq.w      #1,d7

    move.w      Player_NextX(a4),d0
    move.w      Player_NextY(a4),d1

    lea         Actors(a5),a3
.loop
    tst.w       Actor_Status(a3)
    beq         .next
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
    move.w      Actor_X(a3),d0
    move.w      Actor_Y(a3),d1
    bra         ClearStaticBlock
    bra         .exit                                      ; killed something we are done

.next
    add.w       #Actor_Sizeof,a3
    dbra        d7,.loop    
.exit
    rts

ClearPlayer:
    PUSHALL
    lea         ScreenSave,a0
    lea         ScreenStatic,a1

    move.w      Player_X(a4),d0
    move.w      Player_Y(a4),d1
    mulu        #24,d0
    mulu        #24,d1

    mulu        #SCREEN_STRIDE,d1
    move.w      d0,d2
    asr.w       #3,d2
    add.w       d2,d1    
    add.l       d1,a0                                      ; screen position
    add.l       d1,a1                                      ; screen position

    move.l      #$ffffff00,d1
    and.w       #$f,d0
    beq         .left
    move.l      #$00ffffff,d1
.left

    WAITBLIT
    move.l      #$7ca<<16,BLTCON0(a6)
    move.l      d1,BLTAFWM(a6)
    move.w      #-1,BLTADAT(a6)
    move.l      a0,BLTBPT(a6)
    move.l      a1,BLTCPT(a6)
    move.l      a1,BLTDPT(a6)
    move.w      #0,BLTAMOD(a6)
    move.w      #TILE_BLT_MOD,BLTBMOD(a6)
    move.w      #TILE_BLT_MOD,BLTCMOD(a6)
    move.w      #TILE_BLT_MOD,BLTDMOD(a6)
    move.w      #TILE_BLT_SIZE,BLTSIZE(a6)
    POPALL
    rts

;    move.w      Actor_PrevX(a3),d0
;    move.w      Actor_PrevY(a3),d1

ClearStaticBlock:
    PUSHALL
    lea         ScreenSave,a0
    lea         ScreenStatic,a1

    mulu        #24,d0
    mulu        #24,d1

    mulu        #SCREEN_STRIDE,d1
    move.w      d0,d2
    asr.w       #3,d2
    add.w       d2,d1    
    add.l       d1,a0                                      ; screen position
    add.l       d1,a1                                      ; screen position

    move.l      #$ffffff00,d1
    and.w       #$f,d0
    beq         .left
    move.l      #$00ffffff,d1
.left

    WAITBLIT
    move.l      #$7ca<<16,BLTCON0(a6)
    move.l      d1,BLTAFWM(a6)
    move.w      #-1,BLTADAT(a6)
    move.l      a0,BLTBPT(a6)
    move.l      a1,BLTCPT(a6)
    move.l      a1,BLTDPT(a6)
    move.w      #0,BLTAMOD(a6)
    move.w      #TILE_BLT_MOD,BLTBMOD(a6)
    move.w      #TILE_BLT_MOD,BLTCMOD(a6)
    move.w      #TILE_BLT_MOD,BLTDMOD(a6)
    move.w      #TILE_BLT_SIZE,BLTSIZE(a6)
    POPALL
    rts


; a4 = player struct
; d1 = map offset

; returns 
; d2 = block!

PlayerGetNextBlock:
    move.w      Player_Y(a4),d0
    add.w       Player_DirectionY(a4),d0
    mulu        #WALL_PAPER_WIDTH,d0
    add.w       Player_X(a4),d0                            ; offset in map
    add.w       Player_DirectionX(a4),d0

    lea         GameMap(a5),a0
    moveq       #0,d2
    move.b      (a0,d0.w),d2
    rts