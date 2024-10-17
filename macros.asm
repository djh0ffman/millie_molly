
** push and pops

PUSH               MACRO
                   move.l     \1,-(sp)
                   ENDM

POP                MACRO
                   move.l     (sp)+,\1
                   ENDM

PUSHM              MACRO
                   movem.l    \1,-(sp)
                   ENDM

POPM               MACRO
                   movem.l    (sp)+,\1
                   ENDM

PUSHMOST           MACRO
                   movem.l    d0-a4,-(sp)
                   ENDM

POPMOST            MACRO
                   movem.l    (sp)+,d0-a4
                   ENDM

PUSHALL            MACRO
                   movem.l    d0-a6,-(sp)
                   ENDM

POPALL             MACRO
                   movem.l    (sp)+,d0-a6
                   ENDM



** jump index
** 1 = index

JMPINDEX           MACRO
                   add.w      \1,\1
                   move.w     .\@jmplist(pc,\1.w),\1
                   jmp        .\@jmplist(pc,\1.w)
.\@jmplist
                   ENDM



RANDOMWORD         MACRO
                   move.l     d1,-(sp)
                   move.l     RandomSeed(a5),d0
                   move.l     d0,d1
                   swap.w     d0
                   mulu.w     #$9D3D,d1
                   add.l      d1,d0
                   move.l     d0,RandomSeed(a5)
                   clr.w      d0
                   swap.w     d0
                   move.l     (sp)+,d1
                   ENDM



** jump index
** 1 = index

JMPINDEX           MACRO
                   add.w      \1,\1
                   move.w     .\@jmplist(pc,\1.w),\1
                   jmp        .\@jmplist(pc,\1.w)
.\@jmplist
                   ENDM


** Loads planes to existing copper list

PLANE_TO_COPPER    MACRO
                   move.w     \1,6(\2)
                   swap       \1
                   move.w     \1,2(\2)
                   swap       \1
                   ENDM

BLITPRI_ENABLE  = $8400                                           ; enable blitter priority
BLITPRI_DISABLE = $0400                                           ; disable blitter priority

WAITBLIT           MACRO
                   move.w     #BLITPRI_ENABLE,DMACON(a6)
                   tst.b      $02(a6)
.\@                btst       #6,$02(a6)
                   bne.b      .\@
                   move.w     #BLITPRI_DISABLE,DMACON(a6)
                   ENDM
        

WAITBLITN          MACRO
                   move.w     #BLITPRI_ENABLE,DMACON(a6)
                   tst.b      $02(a6)
.\@                btst       #6,$02(a6)
                   bne.b      .\@
                   move.w     #BLITPRI_DISABLE,DMACON(a6)
                   ENDM


** pointer rotate long  
** 1 = address register
** 2 = count

ROTATE_LONG        MACRO 

                   ifeq       \2-7
                   move.l     (\2-1)*4(\1),d7
                   movem.l    (\1)+,d0/d1/d2/d3/d4/d5
                   addq.l     #4,\1
                   movem.l    d0/d1/d2/d3/d4/d5,-(\1)
                   move.l     d7,-(\1)
                   endif

                   ifeq       \2-6
                   move.l     (\2-1)*4(\1),d7
                   movem.l    (\1)+,d0/d1/d2/d3/d4
                   addq.l     #4,\1
                   movem.l    d0/d1/d2/d3/d4,-(\1)
                   move.l     d7,-(\1)
                   endif

                   ifeq       \2-5
                   move.l     (\2-1)*4(\1),d7
                   movem.l    (\1)+,d0/d1/d2/d3
                   addq.l     #4,\1
                   movem.l    d0/d1/d2/d3,-(\1)
                   move.l     d7,-(\1)
                   endif

                   ifeq       \2-4
                   move.l     (\2-1)*4(\1),d7
                   movem.l    (\1)+,d0/d1/d2
                   addq.l     #4,\1
                   movem.l    d0/d1/d2,-(\1)
                   move.l     d7,-(\1)
                   endif

                   ifeq       \2-3
                   move.l     (\2-1)*4(\1),d7
                   movem.l    (\1)+,d0/d1
                   addq.l     #4,\1
                   movem.l    d0/d1,-(\1)
                   move.l     d7,-(\1)
                   endif

                   ifeq       \2-2
                   movem.l    (\1)+,d0/d1
                   exg        d0,d1
                   movem.l    d0/d1,-(\1)
                   endif

                   ENDM

KeyTest            MACRO
                   tst.b      (\1,a0)
                   beq.b      .\@notpressed
                   bset       #\2,d0
.\@notpressed
                   ENDM

** convert to decimal
**
** \1 = source number
** \2 = digits
** \3 = result

TODECIMAL          MACRO
                   moveq      #\2,d7
                   moveq      #0,\3
.\@loop            divu       #10,\1
                   swap       \1
                   or.b       \1,\3
                   clr.w      \1
                   swap       \1
                   ror.w      #4,\3
                   dbra       d7,.\@loop
                   ENDM

DECIMAL2           MACRO
                   moveq      #0,\2
                   divu       #10,\1
                   swap       \1
                   move.w     \1,\2
                   swap       \2
                   clr.w      \1
                   swap       \1
                   divu       #10,\1
                   swap       \1
                   move.w     \1,\2
                   ENDM

LVLFNT             macro
                   move.b     LEVEL_COUNT_WIDTH_BYTE*\1(a0),d2
                   and.b      d5,d2
                   or.b       LEVEL_FONT_WIDTH_BYTE*\1(a2),d2
                   move.b     d2,LEVEL_COUNT_WIDTH_BYTE*\1(a0)
                   endm