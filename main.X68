*-----------------------------------------------------------
* Title      : main
* Written by : Manas Malla
* Date       : 05/30/2024
* Description: The main game loop of the brick breaker game.
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

    ; display the title screen first, outside of the gameloop. it has its own loop (in separate file)
    ; enables double buffer, sets screen size, loading screens, and first level
    jsr     initialization
    
    * ------- for skipping the title screen -------
    ; double buffer
    ;move.l  #DRAWING_MODE_TRAP, d0
    ;move.l  #DOUBLE_BUFFER, d1
    ;trap    #15
    
    ; set screen size
    ;move.l  #SCREEN_SIZE_TRAP, d0
    ;move.l  #SCREEN_WIDTH<<16+SCREEN_HEIGHT, d1
    ;trap    #15
    
    ;jsr     initial_level

    * ---------------------------------------------

game_loop:
    ; calculate delta time
    jsr     time_calculations

    ; check for input
    jsr     check_inputs
    
    ; inval ball/paddle
    jsr     inval_paddle
    jsr     inval_ball
    
    ; check for collisions (ball/wall, ball/paddle, ball/bricks)
    jsr check_collisions
    
    ; update game physics (velocity and acceleration)
    jsr     update_ball
    
    ; render paddle and ball, and fix paddle rail
    jsr     draw_paddle
    jsr     inval_paddle_rail
    jsr     draw_ball
    
    ; check game state - level complete
    move.l  BricksHit, d0
    move.l  BrickCount, d1
    sub.l   #0, d1 ; this is for level testing.
    cmp.l   d0, d1
    beq     next_level

    move.l  #COPY_BUFFER_TRAP, d0
    trap    #15

    ; loop to handle next frame
    bra     game_loop
    
time_calculations:
    move.l  #TIME_MIDNIGHT_TRAP, d0
    trap    #15
    
    move.l  d1, d7 ; d7 is current time
    sub.l   LastTime, d7 ; d7 is delta time (current - last)
    move.l  d1, LastTime
    move.l  d7, DeltaTime
    
    rts
    
    
end:

    SIMHALT             ; halt simulator

* Put variables and constants here
DeltaTime  dc.l    0
LastTime   dc.l    0

    include 'random.X68'
    include 'sound_manager.X68'
    include 'draw_bricks.X68'
    include 'game_state.X68'
    include 'seven_segment_display.X68'
    include 'physics_collisions.X68'
    include 'input.X68'
    include 'draw_objects.X68'
    include 'update_objects.X68'
    include 'bitmap_draw.X68'
    include 'initial_screens.X68'

    END    START        ; last line of source

















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
