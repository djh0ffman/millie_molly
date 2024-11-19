
; a0 = location
; d7 byte count
TurboClear:
    PUSHALL
    add.l      d7,a0

    divu       #52,d7
    subq.w     #1,d7
    bmi        .remain

    sub.l      a1,a1
    sub.l      a2,a2
    sub.l      a3,a3
    sub.l      a4,a4
    sub.l      a5,a5
    sub.l      a6,a6
    moveq      #0,d0
    moveq      #0,d1
    moveq      #0,d2
    moveq      #0,d3
    moveq      #0,d4
    moveq      #0,d5
    moveq      #0,d6
.loop1
    movem.l    a1-a6/d0-d6,-(a0)
    dbra       d7,.loop1

.remain
    ; remainder
    clr.w      d7
    swap       d7
    subq.w     #1,d7
    bcs        .done
.loop2
    clr.b      -(a0)
    dbra       d7,.loop2
.done
    POPALL
    rts
