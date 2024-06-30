*-----------------------------------------------------------
* Title      : game_state
* Written by : Manas Malla
* Date       : 06/11/2024
* Description: This file dictates the drawing of the scores/lives left/game 
*              state. 
*-----------------------------------------------------------

draw_lives:
    move.l  Lives, d5
    lea     LifePositions, a1

    life_loop:
    ; draw a ball for each life remaining
    move.l  #SET_PEN_COLOR_TRAP, d0
    move.l  #WHITE, d1
    trap    #15
    
    move.l  #UNFILL_ELLIPSE_TRAP, d0
    move.w  (a1)+, d1
    move.w  (a1)+, d2
    move.w  (a1)+, d3
    move.w  (a1)+, d4
    trap    #15
    
    dbra    d5, life_loop
    
    rts
    
inval_life:
    lea     LifePositions, a1
    move.l  #SET_PEN_COLOR_TRAP, d0
    move.l  #BLACK, d1
    trap    #15
    
    move.l  #SET_FILL_TRAP, d0
    move.l  #BLACK, d1
    trap    #15
    
    move.l  Lives, d2
    lsl.l   #3, d2
    add.l   d2, a1
    
    move.l  #FILL_ELLIPSE_TRAP, d0
    move.w  (a1)+, d1
    move.w  (a1)+, d2
    subq.l  #2, d1
    subq.l  #2, d2
    move.w  d1, d3
    move.w  d2, d4
    add.l   #16, d3
    add.l   #16, d4
    trap    #15
    
    rts
    
draw_level_num:
    move.l  #SET_FILL_TRAP, d0
    move.l  #WHITE, d1
    trap    #15
    
    move.l  #SET_PEN_COLOR_TRAP, d0
    trap    #15
    
    move.l  #0, -(sp)
    move.l  #715, -(sp)
    move.l  #45, -(sp)
    jsr     segment_display
    add.l   #12, sp

    move.l  CurrentLevel, -(sp)
    move.l  #730, -(sp)
    move.l  #45, -(sp)
    jsr     segment_display
    add.l   #12, sp
    
    rts
    
inval_level_num:
    move.l  #SET_FILL_TRAP, d0
    move.l  #BLACK, d1
    trap    #15
    
    move.l  #FILLED_RECT_TRAP, d0
    move.l  #700, d1
    move.l  #40, d2
    move.l  #745, d3
    move.l  #75, d4
    trap    #15
    
    rts
    
draw_round:
    move.l  #SET_FILL_TRAP, d0
    move.l  #WHITE, d1
    trap    #15
    
    move.l  #SET_PEN_COLOR_TRAP, d0
    trap    #15

    move.l  #0, -(sp)
    move.l  #715, -(sp)
    move.l  #530, -(sp)
    jsr     segment_display
    add.l   #12, sp
    
    move.l  CurrentRound, -(sp)
    move.l  #730, -(sp)
    move.l  #530, -(sp)
    jsr     segment_display
    add.l   #12, sp
    
    move.l  #COPY_BUFFER_TRAP, d0
    trap    #15
    
    rts
    
inval_round:
    move.l  #SET_FILL_TRAP, d0
    move.l  #BLACK, d1
    trap    #15
    
    move.l  #SET_PEN_COLOR_TRAP, d0
    trap    #15
    
    move.l  #FILLED_RECT_TRAP, d0
    move.l  #700, d1
    move.l  #525, d2
    move.l  #745, d3
    move.l  #560, d4
    trap    #15
    
    rts

countdown_timer_display:
    ; displays a 3 second countdown below the ball
    move.l  #3, d7
    
    countdown_loop:
        ; inval the area for the countdown
        jsr     inval_countdown_timer
        
        ; display the 7 segment display under the ball
        move.l  #SET_FILL_TRAP, d0
        move.l  #WHITE, d1
        trap    #15
    
        move.l  #SET_PEN_COLOR_TRAP, d0
        trap    #15
        
        ; ball position calculations
        move.l  BallXPos, d0
        lsr.l   #FRAC_BITS, d0
        sub.l   #5, d0
        move.l  BallYPos, d1
        lsr.l   #FRAC_BITS, d1
        add.l   #25, d1
        
        move.l  d7, -(sp)
        move.l  d0, -(sp)
        move.l  d1, -(sp)
        jsr     segment_display
        add.l   #12, sp
        
        move.l  #COPY_BUFFER_TRAP, d0
        trap    #15
        
        ; wait for 1 second
        move.l  #DELAY_TRAP, d0
        move.l  #100, d1
        trap    #15
    
        dbra    d7, countdown_loop
        
        rts
    
inval_countdown_timer:
    ; inval the area that the countdown timer is in
    move.l  #SET_FILL_TRAP, d0
    move.l  #BLACK, d1
    trap    #15
    
    move.l  #SET_PEN_COLOR_TRAP, d0
    move.l  #BLACK, d1
    trap    #15
    
    move.l  #FILLED_RECT_TRAP, d0
    move.l  BallXPos, d1
    lsr.l   #FRAC_BITS, d1
    sub.l   #15, d1
    move.l  BallYPos, d2
    lsr.l   #FRAC_BITS, d2
    add.l   #20, d2
    move.l  d1, d3
    add.l   #30, d3
    move.l  d2, d4
    add.l   #30, d4
    trap    #15
    
    rts
    
reset_ball_paddle:
    ; reset paddle position
    move.l  #SCREEN_WIDTH/2, d0
    lsl.l   #FRAC_BITS, d0
    move.l  d0, PaddleXPos
    
    ; reset ball position, but with a random x position ; FIXME
    jsr     random_word_d6
    move.l  d6, d0
    lsl.l   #FRAC_BITS, d0
    move.l  d0, BallXPos
    move.l  #SCREEN_HEIGHT/2, d0
    add.l   #80, d0
    lsl.l   #FRAC_BITS, d0
    move.l  d0, BallYPos
    
    ; reset ball velocity and acceleration
    move.l  #0, d0
    asl.l   #FRAC_BITS, d0
    move.l  d0, BallXVel
    move.l  #2, d0
    asl.l   #FRAC_BITS, d0
    move.l  d0, BallYVel
    
    move.l  #1, d0
    move.l  d0, BallYAcc
    
    move.l  #SCREEN_WIDTH/2, d0
    sub.l   #40, d0
    lsl.l   #FRAC_BITS, d0
    move.l  d0, OldPaddleLeft
    
    move.l  #SCREEN_WIDTH/2, d0
    add.l   #40, d0
    lsl.l   #FRAC_BITS, d0
    move.l  d0, OldPaddleRight
    
    jsr     inval_paddle
    jsr     inval_ball
    
    jsr     draw_paddle
    jsr     draw_ball
    
    move.l  #COPY_BUFFER_TRAP, d0
    trap    #15
    
    rts
    
handle_life_lost:
    ; cmp lives with 0, end game if 0
    move.l  Lives, d0
    cmp.l   #-1, d0
    beq     handle_game_over

    jsr     inval_life
    subq.l  #1, Lives
    addq.l  #1, CurrentRound
    
    jsr     play_lose_life_sound
    
    jsr     draw_paddle_rail
    
    jsr     reset_ball_paddle
    
    ; inval the current round and draw new
    jsr     inval_round
    jsr     draw_round
    
    jsr     countdown_timer_display
    
    jsr     time_calculations
    
    rts
    
handle_game_over:
    jsr     play_game_over_sound
    
    ; inval screen
    move.l  #SET_FILL_TRAP, d0
    move.l  #BLACK, d1
    trap    #15
    
    move.l  #SET_PEN_COLOR_TRAP, d0
    move.l  #BLACK, d1
    trap    #15
    
    move.l  #FILLED_RECT_TRAP, d0
    move.l  #0, d1
    move.l  #0, d2
    move.l  #SCREEN_WIDTH, d3
    move.l  #SCREEN_HEIGHT, d4
    trap    #15
    
    move.l  #DRAW_STRING_TRAP, d0
    lea     GameOverText, a1
    move.l  #(SCREEN_WIDTH/2-50), d1
    move.l  #(SCREEN_HEIGHT/2), d2
    trap    #15
    
    ; display game over + stats
    move.l  BricksHit, d0
    add.l   d0, TotalBricksHit
    move.l  TotalBricksHit, d1
    
    move.l  #COPY_BUFFER_TRAP, d0
    trap    #15
    
    bra     end
    
win_state:
    jsr     play_win_sound
    
    ; inval screen
    move.l  #SET_FILL_TRAP, d0
    move.l  #BLACK, d1
    trap    #15
    
    move.l  #SET_PEN_COLOR_TRAP, d0
    move.l  #BLACK, d1
    trap    #15
    
    move.l  #FILLED_RECT_TRAP, d0
    move.l  #0, d1
    move.l  #0, d2
    move.l  #SCREEN_WIDTH, d3
    move.l  #SCREEN_HEIGHT, d4
    trap    #15
    
    move.l  #DRAW_STRING_TRAP, d0
    lea     WinText, a1
    move.l  #(SCREEN_WIDTH/2-50), d1
    move.l  #(SCREEN_HEIGHT/2), d2
    trap    #15
    
    move.l  #COPY_BUFFER_TRAP, d0
    trap    #15
    
    bra     end


GameOverText    dc.b    'Game Over', 0
StatsText       dc.b    'Total Bricks Hit: ', 0
WinText         dc.b    'You Win!', 0
    
Lives           dc.l    4
LifePositions   dc.w    697, 240, 709, 252
                dc.w    727, 240, 739, 252
                dc.w    757, 240, 769, 252
                dc.w    697, 280, 709, 292
                dc.w    727, 280, 739, 292

CurrentLevel    dc.l    1
CurrentRound    dc.l    1
BricksHit       dc.l    0

TotalBricksHit  dc.l    0















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
