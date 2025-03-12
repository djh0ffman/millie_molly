;--------------------------------------------------------------
; setup and run the title screen shit

TITLE_WIDTH             = 208
TITLE_WIDTH_BYTE        = TITLE_WIDTH/8
TITLE_DEPTH             = 3
TITLE_HEIGHT            = 88

TITLE_SCREEN_WIDTH      = 336+32
TITLE_SCREEN_WIDTH_BYTE = TITLE_SCREEN_WIDTH/8
TITLE_SCREEN_DEPTH      = 5
TITLE_SCREEN_MOD        = TITLE_SCREEN_WIDTH_BYTE*(SCREEN_DEPTH-1)+4
TITLE_SCREEN_STRIDE     = TITLE_SCREEN_DEPTH*TITLE_SCREEN_WIDTH_BYTE
TITLE_SCREEN_HEIGHT     = SCREEN_HEIGHT+32

TITLE_LOGO_OFFSET       = ((336/2)-(TITLE_WIDTH/2))/8

TitleSetup:
    bsr         TitleCopperSetup
    move.l      #cpTitle,COP1LC(a6)
    move.w      #0,COPJMP1(a6)

    move.l      #-1,ScreenMemEnd
    move.w      #BASE_DMA,DMACON(a6)
    addq.w      #1,GameStatus(a5)

    lea         TitleStars,a0
    moveq       #TITLE_STAR_COUNT-1,d7
    moveq       #0,d0                                              ; x start
    moveq       #0,d1                                              ; y star
.starloop
    move.w      d0,(a0)+
    move.w      d1,(a0)+
    add.w       #(3*32)/2,d0
    add.w       #3*32,d1
    dbra        d7,.starloop

    lea         TitleRaw,a0
    lea         ScreenStatic+TITLE_LOGO_OFFSET,a1

    move.l      a1,a2

    move.w      #TITLE_HEIGHT-1,d7
.lineloop
    move.l      a2,a1
    moveq       #TITLE_DEPTH-1,d6
.depthloop
    move.w      #(TITLE_WIDTH_BYTE)-1,d5
.byteloop
    move.b      (a0)+,(a1)+
    dbra        d5,.byteloop
    lea         TITLE_SCREEN_WIDTH_BYTE-TITLE_WIDTH_BYTE(a1),a1
    dbra        d6,.depthloop
    lea         TITLE_SCREEN_STRIDE(a2),a2
    dbra        d7,.lineloop


;    add.w       #TITLE_SCREEN_DIFF,a1

;    lea         TITLE_SCREEN_WIDTH_BYTE*2(a1),a1
;    dbra        d7,.lineloop

    rts



;--------------------------------------------------------------
; blit a fuckin star 32 star plane 4
; d0 = x
; d1 = y
; left and right edge
; shift

; X = / 8 + SCREEN WIDTH*3
; SCREEN_STRIDE = blit mod - blit width

STAR_BLIT_SIZE          = (32<<6)|2
STAR_BLIT_DEST_MOD      = TITLE_SCREEN_STRIDE-4


BlitStar32:
    PUSHALL
    cmp.w       #TITLE_SCREEN_HEIGHT,d1
    bcc         .exit

    sub.w       #32,d1                                             ; HACK AF!

    cmp.w       #TITLE_SCREEN_WIDTH,d0
    bcc         .exit


    move.w      d0,d2
    lsr.w       #3,d2
    add.l       #(TITLE_SCREEN_WIDTH_BYTE*3)-4,d2                  ; x pos on plane
    
    move.w      d1,d3
    muls        #TITLE_SCREEN_STRIDE,d3
    add.l       d3,d2                                              ; screen offset

    add.l       #ScreenStatic,d2                                   ; where screen buffer

    move.w      d0,d3
    and.w       #$f,d3                                             ; mod 16 x
    beq         .blita

    ror.w       #4,d3
    or.w        #$9f0,d3                                           ; bltcon0
   
    WAITBLIT
    move.w      d3,BLTCON0(a6)
    move.w      #0,BLTCON1(a6)
    move.l      #Star32,BLTAPT(a6)
    move.l      d2,BLTDPT(a6)
    move.l      #$ffff0000,BLTAFWM(a6)
    move.w      #-2,BLTAMOD(a6)
    move.w      #STAR_BLIT_DEST_MOD-2,BLTDMOD(a6)
    move.w      #STAR_BLIT_SIZE+1,BLTSIZE(a6)
    WAITBLIT
    bra         .exit

.blita
    WAITBLIT
    move.w      #$9f0,BLTCON0(a6)
    move.w      #0,BLTCON1(a6)
    move.l      #Star32,BLTAPT(a6)
    move.l      d2,BLTDPT(a6)
    move.l      #-1,BLTAFWM(a6)
    move.w      #0,BLTAMOD(a6)
    move.w      #STAR_BLIT_DEST_MOD,BLTDMOD(a6)
    move.w      #STAR_BLIT_SIZE,BLTSIZE(a6)
    WAITBLIT
.exit
    POPALL
    rts




;--------------------------------------------------------------
; coppper

TitleCopperSetup:
    bsr         ClearSprites

    move.l      #ScreenStatic,d0
    lea         cpTitlePlanes,a0
    moveq       #SCREEN_DEPTH-1,d7
.ploop
    move.w      d0,6(a0)
    swap        d0
    move.w      d0,2(a0)
    swap        d0
    addq.l      #8,a0
    add.l       #TITLE_SCREEN_WIDTH_BYTE,d0
    dbra        d7,.ploop

    lea         TitlePal,a0
    lea         cpTitlePal,a1
    moveq       #32-1,d7
.cloop
    move.w      (a0)+,2(a1)    
    addq.l      #4,a1
    dbra        d7,.cloop

    rts


ClearTitleSprites:
    lea         cpTitleSprites,a0
    move.l      #NullSprite,d0
    moveq       #8-1,d7
.loop
    move.w      d0,6(a0)
    swap        d0
    move.w      d0,2(a0)
    swap        d0
    add.l       #8,a0
    dbra        d7,.loop
    rts


TitleRun:
    bsr         TitleStarDraw
    rts


TitleStarDraw:
    lea         TitleStars,a0
    moveq       #TITLE_STAR_COUNT-1,d7
.starloop
;    move.w      StarX,d0
;    move.w      StarY,d1
    move.w      (a0),d0
    move.w      2(a0),d1

    bsr         BlitStar32
    add.w       #3*32,d0
    bsr         BlitStar32
    add.w       #3*32,d0
    bsr         BlitStar32
    add.w       #3*32,d0
    bsr         BlitStar32

    move.w      TickCounter(a5),d5
    addq.w      #1,(a0)                                            ; add x
    and.w       #1,d5
    beq         .skipy
    addq.w      #1,2(a0)                                           ; add y 
.skipy
    cmp.w       #3*32,(a0)
    bcs         .nowrapx
    sub.w       #3*32,(a0)
.nowrapx
    cmp.w       #TITLE_STAR_COUNT*32*3,2(a0)
    bcs         .nowrapy
    sub.w       #TITLE_STAR_COUNT*32*3,2(a0)
.nowrapy
    addq.w      #4,a0
    dbra        d7,.starloop

    rts


StarX:
    dc.w        0
StarY:
    dc.w        0