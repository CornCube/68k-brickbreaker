*-----------------------------------------------------------
* Title      : draw_bricks
* Written by : Manas Malla
* Date       : 06/06/2024
* Description: This file declares the brick table for each level.
*-----------------------------------------------------------

END_LEVEL   equ     $FFFFFFFF
BRICK_SIZE  equ     24
LEVEL_INFO  equ     8

load_level_file:
    lea     LevelFile, a3
    add.l   LevelOffset, a3

draw_level_file:
    move.l  a3, StartLevelAddr
    move.l  (a3)+, d0 ; number of bricks
    
    ; check if end of file (0xEEEEEEEE)
    cmp.l   #$EEEEEEEE, d0
    beq     win_state
    
    move.l  d0, BrickCount
    clr.l   CurrentBrick
    
draw_next_brick:
    move.l  BrickCount, d1
    move.l  CurrentBrick, d2
    cmp.l   d1, d2
    beq     done_drawing_level
    
    ; obtain the parameter info
    move.l  (a3)+, d5 ; left x
    move.l  (a3)+, d2 ; upper y
    move.l  (a3)+, d3 ; right x
    move.l  (a3)+, d4 ; lower y
    move.l  (a3)+, d1 ; color
    move.l  (a3)+, d6 ; num hits
    
    ; draw the current brick
    move.l  #SET_FILL_TRAP, d0
    trap    #15
    
    move.l  #SET_PEN_COLOR_TRAP, d0
    move.l  #BLACK, d1
    trap    #15
    
    move.l  #FILLED_RECT_TRAP, d0
    move.l  d5, d1
    trap    #15
    
    addq.l  #1, CurrentBrick
    bra     draw_next_brick
    
done_drawing_level:
    rts
    
next_level:
    ; called whenever the level is complete, prepares the next level
    addq.l  #4, a3 ; skip past the FFFFFFFF indicating end
    addq.l  #1, CurrentLevel
    
    jsr     play_next_level_sound
    
    ; inval the field
    move.l  #SET_FILL_TRAP, d0
    move.l  #BLACK, d1
    trap    #15
    
    move.l  #SET_PEN_COLOR_TRAP, d0
    trap    #15
    
    move.l  #FILLED_RECT_TRAP, d0
    move.l  #25, d1
    move.l  #25, d2
    move.l  #640, d3
    move.l  #600, d4
    trap    #15
    
    ; inval the level number
    jsr     inval_level_num
    
    jsr     draw_level_file
   
    ; reset the hit brick count
    move.l  BricksHit, d0
    add.l   d0, TotalBricksHit
    move.l  #0, BricksHit
    
    ; draw the new level number
    jsr     draw_level_num
    
    jsr     draw_paddle_rail
    
    ; reset the ball and paddle position/velocity/acceleration
    jsr     reset_ball_paddle
    
    ; display the countdown timer, 3 seconds
    jsr     countdown_timer_display
    
    ; refresh the time calculation
    jsr     time_calculations
    
    bra     game_loop
    
inval_brick:
    ; d1 has left x in fixed point
    ; d2 has upper y in fixed point
    ; d3 has right x in fixed point
    ; d4 has lower y in fixed point
    move.l  d1, -(sp)
    move.l  #SET_PEN_COLOR_TRAP, d0
    move.l  #BLACK, d1
    trap    #15
    
    ; check if d6 is greater/e than 1. if it is, that means its a brick that
    ; takes multiple hits. simply subtract 50 from the color (d5).
    cmp.l   #1, d6
    bge     multi_hit_color
    
    move.l  #SET_FILL_TRAP, d0
    move.l  #BLACK, d1
    trap    #15
    
    ; increment total bricks hit
    addq.l  #1, BricksHit
    
    continue_inval_brick:
        move.l  #FILLED_RECT_TRAP, d0
        move.l  (sp)+, d1
        asr.l   #FRAC_BITS, d1
        asr.l   #FRAC_BITS, d2
        asr.l   #FRAC_BITS, d3
        asr.l   #FRAC_BITS, d4
        trap    #15
    
        rts
    
    multi_hit_color:
        ; set new color
        add.l   #100, d5
        move.l  #SET_FILL_TRAP, d0
        move.l  d5, d1
        trap    #15
        
        ; save the new color
        subq.l  #8, a4 
        move.l  d5, (a4)
        addq.l  #8, a4
        
        bra     continue_inval_brick
            

LevelFile       INCBIN  'level.bin'
BrickCount      dc.l    0
LevelOffset     dc.l    0 ; this is for testing certain levels based on the number of bytes it takes up
StartLevelAddr  dc.l    0
CurrentBrick    dc.l    0











*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
