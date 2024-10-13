

;----------------------------------------------
;  update controls
;----------------------------------------------

UpdateControls:
    bsr        ReadControls           ; Read controls (keyboard and joystick)

StoreControls1:
    lea        ControlsHold(a5),a3
StoreControls:
    move.b     (a3),d1
    move.b     d0,(a3)
    eor.b      d1,d0
    and.b      (a3),d0
    move.b     d0,-1(a3)   
    rts


;-------------------------------------------------------------
;
; Read controls
;
; Out:
;    A = Result
;    bit 4 = Fire / Space
;    bit 3 = Right
;    bit 2 = Left
;    bit 1 = Down
;    bit 0 = Up
;-------------------------------------------------------------

ReadControls:
    moveq      #0,d0
    lea        Keys,a0

    KeyTest    $4c,0
    KeyTest    $4d,1
    KeyTest    $4f,2
    KeyTest    $4e,3
    KeyTest    $40,4

    rts

