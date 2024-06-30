*-----------------------------------------------------------
* Title      : update_objects
* Written by : Manas Malla
* Date       : 06/06/2024
* Description: This file includes subroutines for updating the game objects.
*-----------------------------------------------------------

update_ball:
    move.l  DeltaTime, d1
    
    ; update velocity
    addq.l  #1, FrameCounter
    cmp.l   #10, FrameCounter
    bne     update_position ; only increase speed every 10 frames
    
    move.l  BallYAcc, d2
    muls.w  d1, d2

    ; check velocity sign and add or subtract the acceleration accordingly
    tst.l   BallYVel
    bge     positive_y_vel
    neg.l   d2

    positive_y_vel:
        add.l   d2, BallYVel
        
    clr.l   FrameCounter

    clamp_velocity:
        ; clamp at a max speed of 4.5<<FRAC_BITS (1152)
        cmp.l   #-MAX_BALL_VEL, BallYVel
        ble     clamp_neg_vel
        cmp.l   #MAX_BALL_VEL, BallYVel
        bge     clamp_pos_vel
        bra     update_position
        
    clamp_neg_vel:
        move.l  #-MAX_BALL_VEL, BallYVel
        bra     update_position
        
    clamp_pos_vel:
        move.l  #MAX_BALL_VEL, BallYVel
    
update_position:
    ; update position
    move.l  BallXPos, d2
    move.l  BallXVel, d3
    muls.w  d1, d3
    add.l   d3, d2
    move.l  d2, BallXPos
    
    move.l  BallYPos, d2
    move.l  BallYVel, d3
    muls.w  d1, d3
    add.l   d3, d2
    move.l  d2, BallYPos
    
    rts

update_paddle_left:
    move.l  PaddleLeft, d0
    move.l  d0, OldPaddleLeft
    move.l  PaddleRight, d0
    move.l  d0, OldPaddleRight

    move.l  DeltaTime, d1
    move.l  #PADDLE_VEL, d2
    mulu.w  d1, d2
    sub.l   d2, PaddleXPos
    bra     end_move
    
update_paddle_right:
    move.l  PaddleLeft, d0
    move.l  d0, OldPaddleLeft
    move.l  PaddleRight, d0
    move.l  d0, OldPaddleRight
    
    move.l  DeltaTime, d1
    move.l  #PADDLE_VEL, d2
    mulu.w  d1, d2
    add.l   d2, PaddleXPos
    bra     end_move

* variables and constants
FrameCounter    dc.l    0 ; necessary for more gradual acceleration
OldPaddleLeft   dc.l    (SCREEN_WIDTH/2-40)<<FRAC_BITS
OldPaddleRight  dc.l    (SCREEN_WIDTH/2+40)<<FRAC_BITS



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
