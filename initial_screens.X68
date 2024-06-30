*-----------------------------------------------------------
* Title      : initial_screens
* Written by : Manas Malla
* Date       : 05/31/2024
* Description: Enables double buffering, displays title and loading screens, 
*              sets screen size, returns into the first level initialization.
*-----------------------------------------------------------

; magic numbers
SCREEN_WIDTH        equ     800
SCREEN_HEIGHT       equ     600
BALL_SIZE           equ     7<<FRAC_BITS
PADDLE_LENGTH       equ     40<<FRAC_BITS
PADDLE_HEIGHT       equ     10<<FRAC_BITS
TOP_PADDLE_RAIL     equ     548

; trap codes
TIME_MIDNIGHT_TRAP  equ     8
SCREEN_SIZE_TRAP    equ     33
DRAWING_MODE_TRAP   equ     92
INPUT_TRAP          equ     19
COPY_BUFFER_TRAP    equ     94
CLEAR_SCREEN_TRAP   equ     11
DRAW_STRING_TRAP    equ     95
SET_FILL_TRAP       equ     81
FILLED_RECT_TRAP    equ     87
UNFILLED_RECT_TRAP  equ     90
FILL_ELLIPSE_TRAP   equ     88
UNFILL_ELLIPSE_TRAP equ     91
SET_PEN_COLOR_TRAP  equ     80
SET_FONT_TRAP       equ     21
DELAY_TRAP          equ     23

DOUBLE_BUFFER       equ     17

; input keycodes
LEFT                equ     $25
RIGHT               equ     $27

; colors
BLACK               equ     $00000000
WHITE               equ     $00FFFFFF
RED                 equ     $000028D8

initialization:
    ; seed random number
    jsr     seed_random_number

    ; double buffer
    move.l  #DRAWING_MODE_TRAP, d0
    move.l  #DOUBLE_BUFFER, d1
    trap    #15
    
    ; set screen size
    move.l  #SCREEN_SIZE_TRAP, d0
    move.l  #SCREEN_WIDTH<<16+SCREEN_HEIGHT, d1
    trap    #15
            
    ; display loading screen (allowing for title to fully draw)
    move.l  #DRAW_STRING_TRAP, d0
    lea     LoadingText, a1
    move.l  #SCREEN_WIDTH/2-30, d1
    move.l  #SCREEN_HEIGHT/2-30, d2
    trap    #15
    
    move.l  #COPY_BUFFER_TRAP, d0
    trap    #15
                
    ; load title
    lea     Title, a0
    move.l  a0, -(sp) ; address of title
    move.l  #0, -(sp)
    move.l  #0, -(sp) ; top left on bitmap
    move.l  #SCREEN_WIDTH, -(sp) ; width of image
    move.l  #SCREEN_HEIGHT, -(sp) ; height of image
    move.l  #0, -(sp)
    move.l  #0, -(sp) ; top left on output
    jsr     bitmap_subroutine
    add.l   #28, sp
        
    move.l  #COPY_BUFFER_TRAP, d0
    trap    #15
    
initial_input:
    ; check for input (left or right)
    move.l  #INPUT_TRAP, d0
    move.l  #LEFT<<8+RIGHT, d1
    trap    #15
    
    tst.l   d1
    beq     initial_input
    
    move.l  #SET_FILL_TRAP, d0
    move.l  #BLACK, d1
    trap    #15
    
    ; invals the title
    move.l  #FILLED_RECT_TRAP, d0
    move.l  #0, d1
    move.l  #0, d2
    move.l  #SCREEN_WIDTH, d3
    move.l  #SCREEN_HEIGHT, d4
    trap    #15
    
    move.l  #COPY_BUFFER_TRAP, d0
    trap    #15
    
initial_level:
    ; loading text
    move.l  #DRAW_STRING_TRAP, d0
    lea     LoadingText, a1
    move.l  #SCREEN_WIDTH/2-30, d1
    move.l  #SCREEN_HEIGHT/2-30, d2
    trap    #15
    
    move.l  #COPY_BUFFER_TRAP, d0
    trap    #15
    
    ; inval the loading text
    move.l  #SET_PEN_COLOR_TRAP, d0
    move.l  #BLACK, d1
    trap    #15
    
    move.l  #SET_FILL_TRAP, d0
    move.l  #BLACK, d1
    trap    #15
    
    move.l  #FILLED_RECT_TRAP, d0
    move.l  #0, d1
    move.l  #0, d2
    move.l  SCREEN_WIDTH, d1
    move.l  SCREEN_HEIGHT, d2
    trap    #15

    ; load level
    jsr     load_level_file
    
    ; load sounds
    jsr     load_sounds
    
    ; draw rail
    jsr     draw_paddle_rail
    
    ; load frame
    jsr     game_frame
    
    ; draw side info
    jsr     draw_info
    
    ; draw the lives and numbers
    jsr     draw_lives
    jsr     draw_level_num
    jsr     draw_round
    
    ; draw the objects
    jsr     draw_paddle
    jsr     draw_ball
    
    jsr     countdown_timer_display

    ; set last time
    move.l  #TIME_MIDNIGHT_TRAP, d0
    trap    #15
    move.l  d1, LastTime
    
    move.l  #COPY_BUFFER_TRAP, d0
    trap    #15
    
    rts
    
game_frame:
    ; draws a frame around the play window
    ; left side
    lea     FrameSide, a0
    move.l  a0, -(sp) ; address of title
    move.l  #0, -(sp)
    move.l  #0, -(sp) ; top left on bitmap
    move.l  #26, -(sp) ; width of image
    move.l  #600, -(sp) ; height of image
    move.l  #3, -(sp)
    move.l  #0, -(sp) ; top left on output
    jsr     bitmap_subroutine
    add.l   #28, sp
    
    ; right side
    lea     FrameSide, a0
    move.l  a0, -(sp) ; address of title
    move.l  #0, -(sp)
    move.l  #0, -(sp) ; top left on bitmap
    move.l  #25, -(sp) ; width of image
    move.l  #600, -(sp) ; height of image
    move.l  #642, -(sp)
    move.l  #0, -(sp) ; top left on output
    jsr     bitmap_subroutine
    add.l   #28, sp
    
    ; top
    lea     FrameTop, a0
    move.l  a0, -(sp) ; address of title
    move.l  #0, -(sp)
    move.l  #0, -(sp) ; top left on bitmap
    move.l  #668, -(sp) ; width of image
    move.l  #25, -(sp) ; height of image
    move.l  #0, -(sp)
    move.l  #0, -(sp) ; top left on output
    jsr     bitmap_subroutine
    add.l   #28, sp

    rts
    
draw_info:
    ; draws the score and round number
    ; set font properties
    move.l  #SET_FONT_TRAP, d0
    move.l  #RED, d1
    move.l  #$01180000, d2
    trap    #15
    
    move.l  #SET_FILL_TRAP, d0
    move.l  #BLACK, d1
    trap    #15

    move.l  #DRAW_STRING_TRAP, d0
    lea     LevelText, a1
    move.l  #SCREEN_WIDTH-110, d1
    move.l  #10, d2
    trap    #15
    
    move.l  #DRAW_STRING_TRAP, d0
    lea     RoundText, a1
    move.l  #SCREEN_WIDTH-110, d1
    move.l  #495, d2
    trap    #15

    rts
   
    
* Put variables and constants here
LoadingText     dc.b    'Loading...', 0
LevelText       dc.b    'Level', 0
RoundText       dc.b    'Round', 0

Padding         dc.b    0
Title           INCBIN  "assets/title.bmp"
FrameTop        INCBIN  "assets/frame_top.bmp"
FrameSide       INCBIN  "assets/frame_side.bmp"
PaddleRail      INCBIN  "assets/paddle_rail.bmp"













*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
