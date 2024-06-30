*-----------------------------------------------------------
* Title      : draw_objects
* Written by : Manas Malla
* Date       : 06/03/2024
* Description: This file contains subroutines for drawing the ball, paddle,
*              and bricks based on their position variables.
*-----------------------------------------------------------

draw_ball:
    ; draws the ball at a certain location, called every frame
    move.l  #SET_PEN_COLOR_TRAP, d0
    move.l  #WHITE, d1
    trap    #15

    move.l  BallXPos, d0
    sub.l   #BALL_SIZE, d0
    move.l  d0, BallLeft
    asr.l   #FRAC_BITS, d0
    move.l  d0, d1

    move.l  BallYPos, d0
    sub.l   #BALL_SIZE, d0
    move.l  d0, BallTop
    asr.l   #FRAC_BITS, d0
    move.l  d0, d2

    move.l  BallXPos, d0
    add.l   #BALL_SIZE, d0
    move.l  d0, BallRight
    asr.l   #FRAC_BITS, d0
    move.l  d0, d3

    move.l  BallYPos, d0
    add.l   #BALL_SIZE, d0
    move.l  d0, BallBottom
    asr.l   #FRAC_BITS, d0
    move.l  d0, d4
    
    move.l  #UNFILL_ELLIPSE_TRAP, d0
    trap    #15
    
    rts
    
draw_paddle:
    ; draws the paddle at a certain location, called every frame
    move.l  #SET_PEN_COLOR_TRAP, d0
    move.l  #WHITE, d1
    trap    #15

    move.l  PaddleXPos, d0
    sub.l   #PADDLE_LENGTH, d0
    move.l  d0, PaddleLeft
    asr.l   #FRAC_BITS, d0
    move.l  d0, d1
    
    move.l  PaddleYPos, d0
    sub.l   #PADDLE_HEIGHT, d0
    move.l  d0, PaddleTop
    asr.l   #FRAC_BITS, d0
    move.l  d0, d2

    move.l  PaddleXPos, d0
    add.l   #PADDLE_LENGTH, d0
    move.l  d0, PaddleRight
    asr.l   #FRAC_BITS, d0
    move.l  d0, d3

    move.l  PaddleYPos, d0
    add.l   #PADDLE_HEIGHT, d0
    move.l  d0, PaddleBottom
    asr.l   #FRAC_BITS, d0
    move.l  d0, d4
    
    move.l  #UNFILLED_RECT_TRAP, d0
    trap    #15

    rts

inval_ball:
    ; invals the ball at its current location with an offset, called every frame
    move.l  #SET_PEN_COLOR_TRAP, d0
    move.l  #BLACK, d1
    trap    #15
    
    move.l  #SET_FILL_TRAP, d0
    move.l  #BLACK, d1
    trap    #15
    
    move.l  BallXPos, d0
    sub.l   #BALL_SIZE, d0
    asr.l   #FRAC_BITS, d0
    move.l  d0, d1

    move.l  BallYPos, d0
    sub.l   #BALL_SIZE, d0
    asr.l   #FRAC_BITS, d0
    move.l  d0, d2

    move.l  BallXPos, d0
    add.l   #BALL_SIZE, d0
    asr.l   #FRAC_BITS, d0
    move.l  d0, d3

    move.l  BallYPos, d0
    add.l   #BALL_SIZE, d0
    asr.l   #FRAC_BITS, d0
    move.l  d0, d4
    
    move.l  #FILLED_RECT_TRAP, d0
    trap    #15
    
    rts
    
inval_paddle:
    ; invals the paddle at its current location with an offset, called every frame
    move.l  #SET_PEN_COLOR_TRAP, d0
    move.l  #BLACK, d1
    trap    #15
    
    move.l  #SET_FILL_TRAP, d0
    move.l  #BLACK, d1
    trap    #15
    
    move.l  PaddleXPos, d0
    sub.l   #PADDLE_LENGTH, d0
    asr.l   #FRAC_BITS, d0
    sub.l   #6, d0
    move.l  d0, d1
    
    move.l  PaddleYPos, d0
    sub.l   #PADDLE_HEIGHT, d0
    asr.l   #FRAC_BITS, d0
    sub.l   #5, d0
    move.l  d0, d2

    move.l  PaddleXPos, d0
    add.l   #PADDLE_LENGTH, d0
    asr.l   #FRAC_BITS, d0
    add.l   #6, d0
    move.l  d0, d3

    move.l  PaddleYPos, d0
    add.l   #PADDLE_HEIGHT, d0
    asr.l   #FRAC_BITS, d0
    add.l   #5, d0
    move.l  d0, d4
    
    move.l  #FILLED_RECT_TRAP, d0
    trap    #15
    
    rts

draw_paddle_rail:
    ; draws the entire paddle rail
    lea     PaddleRail, a0
    move.l  a0, -(sp) ; address of title
    move.l  #45, -(sp)
    move.l  #0, -(sp) ; top left on bitmap
    move.l  #585, -(sp) ; width of image
    move.l  #5, -(sp) ; height of image
    move.l  #45, -(sp)
    move.l  #TOP_PADDLE_RAIL, -(sp) ; top left on output
    jsr     bitmap_subroutine
    add.l   #28, sp
    
    rts

; clamps the width of the image d0 to prevent crashing
clamp_width:
    cmp.l   #610, d0
    ble     no_clamp_needed
    move.l  #585, d0
no_clamp_needed:
    rts
    
; clamps the left x coordinate d1 to ensure it is within the bitmap boundaries
clamp_x:
    cmp.l   #0, d1
    bge     clamp_x_max_check
    move.l  #0, d1

clamp_x_max_check:
    cmp.l   #600, d1
    ble     x_clamp_done
    move.l  #610, d1
x_clamp_done:
    rts

inval_paddle_rail:
; redraws the paddle rail whenever the paddle moves
redraw_paddle_rail_left:
    ; paddle moved left
    ; calculate width in d0
    move.l  OldPaddleRight, d0
    asr.l   #FRAC_BITS, d0
    move.l  PaddleRight, d1
    asr.l   #FRAC_BITS, d1
    sub.l   d1, d0
    beq     no_movement
    
    add.l   #10, d0
    
    ; ensure that d0 and d1 are never greater than the bitmap width/
    jsr     clamp_width
    jsr     clamp_x

    lea     PaddleRail, a0
    move.l  a0, -(sp) ; address of title
    move.l  d1, -(sp) ; left x
    move.l  #0, -(sp) ; top y
    move.l  d0, -(sp) ; width of image
    move.l  #5, -(sp) ; height of image
    move.l  d1, -(sp) ; left x (output)
    move.l  #TOP_PADDLE_RAIL, -(sp) ; top y (output)
    jsr     bitmap_subroutine
    add.l   #28, sp
        
redraw_paddle_rail_right:
    ; paddle moved right
    ; calculate width in d0
    move.l  PaddleLeft, d0
    asr.l   #FRAC_BITS, d0
    move.l  OldPaddleLeft, d1
    asr.l   #FRAC_BITS, d1
    sub.l   d1, d0
    beq     no_movement
    
    sub.l   #10, d1
    add.l   #10, d0
    
    jsr     clamp_width
    jsr     clamp_x

    lea     PaddleRail, a0
    move.l  a0, -(sp) ; address of title
    move.l  d1, -(sp) ; left x
    move.l  #0, -(sp) ; top y
    move.l  d0, -(sp) ; width of image
    move.l  #5, -(sp) ; height of image
    move.l  d1, -(sp) ; left x (output)
    move.l  #TOP_PADDLE_RAIL, -(sp) ; top y (output)
    jsr     bitmap_subroutine
    add.l   #28, sp

    no_movement:
        rts



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
