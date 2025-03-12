
GameStatusRun:
    move.w      GameStatus(a5),d0
    JMPINDEX    d0

.i
    dc.w        TitleSetup-.i
    dc.w        TitleRun-.i
    dc.w        GameRun-.i



GameRun:
    bsr         LevelTest
    ;bsr        DrawPlayers

    bsr         UpdateControls

    move.l      PlayerPtrs(a5),a4
    bsr         PlayerLogic
    rts


