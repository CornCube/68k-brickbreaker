*-----------------------------------------------------------
* Title      : physics_collisions
* Written by : Manas Malla
* Date       : 06/03/2024
* Description: This file handles physics/collisions for the ball and paddle.
*-----------------------------------------------------------

FRAC_BITS           equ     8
PADDLE_SEGMENT_SIZE equ     4
PADDLE_OFFSET       equ     4<<FRAC_BITS
PADDLE_VEL          equ     4<<FRAC_BITS
MAX_BALL_VEL        equ     1152
VEL_CONSTANT        equ     60
    
check_collisions:
ball_wall:
    ; check if ball is colliding with a wall
    check_left_wall:
        move.l  BallXPos, d0
        sub.l   #START_SCREEN, d0
        cmp.l   #BALL_SIZE, d0
        bge     check_right_wall
        neg.l   BallXVel
        move.l  #BALL_SIZE+START_SCREEN, BallXPos
        jsr     play_collision_sound
        
    check_right_wall:
        move.l  BallXPos, d0
        move.l  #(screen_width<<FRAC_BITS)-BALL_SIZE, d1
        sub.l   #END_SCREEN, d1
        cmp.l   d1, d0
        ble     check_top_wall
        neg.l   BallXVel
        move.l  d1, BallXPos
        jsr     play_collision_sound

    check_top_wall:
        move.l  BallYPos, d0
        sub.l   #START_SCREEN, d0
        cmp.l   #BALL_SIZE, d0
        bge     check_bottom_wall
        neg.l   BallYVel
        move.l  #BALL_SIZE+START_SCREEN, BallYPos
        jsr     play_collision_sound

    check_bottom_wall:
        move.l  BallYPos, d0
        cmp.l   #(SCREEN_HEIGHT<<FRAC_BITS)-BALL_SIZE, d0
        ble     end_ball_wall
        neg.l   BallYVel
        move.l  #(SCREEN_HEIGHT<<FRAC_BITS)-BALL_SIZE, BallYPos
        
        jsr     handle_life_lost
        bra     game_loop
        
    end_ball_wall:
        
ball_paddle:
    ; check if ball is colliding with the paddle (accounting for position)
    ; check for collision
    move.l  BallRight, d0
    cmp.l   PaddleLeft, d0
    blt     no_collision
    
    move.l  BallLeft, d0
    cmp.l   PaddleRight, d0
    bgt     no_collision
    
    move.l  BallBottom, d0
    cmp.l   PaddleTop, d0
    blt     no_collision
    
    move.l  BallTop, d0
    cmp.l   PaddleBottom, d0
    bgt     no_collision
    
    ; ball is colliding with the paddle if we get here
    jsr     play_collision_sound
    
    ; set ball outside of paddle (prevents getting stuck inside the paddle)
    move.l  PaddleTop, d0
    sub.l   #PADDLE_HEIGHT, d0
    move.l  d0, BallYPos
    
    ; ballx - paddlex
    move.l  BallXPos, d0
    asr.l   #FRAC_BITS, d0
    move.l  PaddleLeft, d1
    asr.l   #FRAC_BITS, d1
    sub.l   d1, d0
    
    ; calculate segment index
    divu.w  #PADDLE_SEGMENT_SIZE, d0
    clr.l   d1
    move.w  d0, d1
    
    ; ensure segment index is within bounds
    cmp.w   #0, d1
    blt     adjust_to_min_segment
    cmp.l   #20, d1
    bge     adjust_to_max_segment
    bra     proceed_with_vel
    
    adjust_to_min_segment:
        move.w  #0, d1
        bra     proceed_with_vel
        
    adjust_to_max_segment:
        move.w  #19, d1
        
    proceed_with_vel:
        lea     VelocityTable, a5
        asl.l   #2, d1
        move.l  (a5, d1), d0
        move.l  d0, BallXVel
            
        neg.l   BallYVel
        
    
    no_collision:

ball_bricks:
    ; check if ball is colliding with the bricks
    ; when a ball hits left side of a brick, negate y vel, and decrease x vel by a constant. 
    ; when a ball hits right side of a brick, negate y vel and increase x vel by a constant. 
    ; when a ball hits middle of a brick, negate y vel.
    
    ; d0 is the extra register
    ; d1 is left x
    ; d2 is upper y
    ; d3 is right x
    ; d4 is lower y
    ; d5 is color
    ; d6 is num hits
    ; d7 is extra
    
    ; using current level, go to the proper address
    move.l  StartLevelAddr, a4
    addq.l  #4, a4 ; skip the num bricks
    clr.l   CurrentBrick
    clr.l   d7
    
    check_next_brick:
        move.l  BrickCount, d1
        move.l  CurrentBrick, d2
        cmp.l   d1, d2
        beq     end_brick_collision
        
        move.l  (a4)+, d1 ; left x
        move.l  (a4)+, d2 ; upper y
        move.l  (a4)+, d3 ; right x
        move.l  (a4)+, d4 ; lower y
        move.l  (a4)+, d5 ; color
        move.l  (a4)+, d6 ; num hits
        
        ; check if the current brick has been hit or not
        tst.l   d6 ; hit status
        beq     skip_current_brick
        
        ; check if ball is colliding with brick
        move.l  BallRight, d0
        lsl.l   #FRAC_BITS, d1
        cmp.l   d1, d0
        blt     skip_current_brick
    
        move.l  BallLeft, d0
        lsl.l   #FRAC_BITS, d3
        cmp.l   d3, d0
        bgt     skip_current_brick
    
        move.l  BallBottom, d0
        lsl.l   #FRAC_BITS, d2
        cmp.l   d2, d0
        blt     skip_current_brick
    
        move.l  BallTop, d0
        lsl.l   #FRAC_BITS, d4
        cmp.l   d4, d0
        bgt     skip_current_brick
        
        ; play brick collision sound
        jsr     play_brick_break_sound
        
        ; check which side of the brick that the ball is touching
        ; calculate distances from each side
        move.l  BallBottom, d0
        sub.l   d2, d0
        move.l  d0, DistanceTop
        
        move.l  d4, d0
        move.l  BallTop, d7
        sub.l   d7, d0
        move.l  d0, DistanceBottom
        
        move.l  BallRight, d0
        sub.l   d1, d0
        move.l  d0, DistanceLeft
        
        move.l  d3, d0
        move.l  BallLeft, d7
        sub.l   d7, d0
        move.l  d0, DistanceRight
        
        ; compare distances to find the smallest one
        ; check if top is the smallest
        move.l  DistanceTop, d0
        move.l  DistanceBottom, d7
        cmp.l   d7, d0
        bgt     check_bottom ; bottom < top
        
        ; here we know top < bottom
        move.l  DistanceLeft, d7
        cmp.l   d7, d0
        bgt     check_left ; left < top
        
        ; here we know top < left
        move.l  DistanceRight, d7
        cmp.l   d7, d0
        bgt     right_collision ; top > right
        bra     top_collision ; top is smallest
        
        check_bottom:
            ; check if bottom is the smallest
            ; d7 is bottom, we already know bottom < top
            move.l  DistanceLeft, d0
            cmp.l   d0, d7
            bgt     check_left ; left < bottom
            
            move.l  DistanceRight, d0
            cmp.l   d0, d7
            bgt     right_collision ; right < bottom
            bra     bottom_collision ; bottom is smallest
            
        check_left:
            ; check if left is smallest
            move.l  DistanceRight, d0
            move.l  DistanceLeft, d7
            cmp.l   d0, d7
            bgt     right_collision ; right < left
            bra     left_collision
               
        top_collision:
            neg.l   BallYVel
            move.l  d2, BallYPos
            sub.l   #BALL_SIZE, BallYPos
            sub.l   #PADDLE_OFFSET, BallYPos
            bra     continue
                
        bottom_collision:
            neg.l   BallYVel
            move.l  d4, BallYPos
            add.l   #BALL_SIZE, BallYPos
            add.l   #PADDLE_OFFSET, BallYPos
            bra     continue
            
        left_collision:
            neg.l   BallXVel
            sub.l   #VEL_CONSTANT, BallXVel
            move.l  d1, BallXPos
            sub.l   #BALL_SIZE, BallXPos
            sub.l   #PADDLE_OFFSET, BallXPos
            bra     continue
            
        right_collision:
            neg.l   BallXVel
            add.l   #VEL_CONSTANT, BallXVel
            move.l  d3, BallXPos
            add.l   #BALL_SIZE, BallXPos
            add.l   #PADDLE_OFFSET, BallXPos
        
    continue:
        ; decrement the hit counter for that brick
        subq.l  #4, a4
        subq.l  #1, d6
        move.l  d6, (a4)
        addq.l  #4, a4
    
        ; inval the brick
        jsr     inval_brick
        
        bra     end_brick_collision
                        
    skip_current_brick:
        addq.l  #1, CurrentBrick
        bra     check_next_brick
        
    end_brick_collision:
        rts
        

* variables and constants
BallXPos        dc.l    (screen_width/2)<<FRAC_BITS
BallYPos        dc.l    (SCREEN_HEIGHT/2+80)<<FRAC_BITS
BallXVel        dc.l    0<<FRAC_BITS
BallYVel        dc.l    2<<FRAC_BITS
BallYAcc        dc.l    1
BallLeft        dc.l    (screen_width/2)<<FRAC_BITS
BallRight       dc.l    (screen_width/2)<<FRAC_BITS
BallTop         dc.l    (screen_width/2)<<FRAC_BITS
BallBottom      dc.l    (screen_width/2)<<FRAC_BITS

PaddleXPos      dc.l    (screen_width/2)<<FRAC_BITS
PaddleYPos      dc.l    (SCREEN_HEIGHT-50)<<FRAC_BITS
PaddleLeft      dc.l    0
PaddleRight     dc.l    0
PaddleTop       dc.l    0
PaddleBottom    dc.l    0

DistanceLeft    dc.l    0
DistanceRight   dc.l    0
DistanceTop     dc.l    0
DistanceBottom  dc.l    0

VelocityTable   dc.l    -512, -456, -392, -328, -264, -200, -144, -120
                dc.l    -96, -56, 56, 96, 120, 144, 200, 264
                dc.l    328, 392, 456, 512









*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
