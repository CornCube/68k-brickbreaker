*-----------------------------------------------------------
* Title      : seven_segment_display
* Written by : Manas Malla
* Date       : 06/10/2024
* Description: This file contains the logic/rendering of a seven segment
*              display on the screen at a given location.
*-----------------------------------------------------------

; input parameters:
; number to display, x coordinate, y coordinate
NUM_TO_DISPLAY  equ     12
X_COORD         equ     8
Y_COORD         equ     4

NUM_SEGMENTS    equ     7

segment_display:
    ; this subroutine can be called provided the above 3 params are pushed
    ; on the stack
    move.l  NUM_TO_DISPLAY(sp), d0
    
    ; load bitmask for the number
    lea     SegmentTable, a0
    move.b  (a0, d0), d6
    
    ; load the coordinates and draw segments
    lea     SegmentPositions, a1
    
    moveq.l  #NUM_SEGMENTS-1, d5 ; 6 for segment A, 5 for segment B, etc
    
    move.l  #SET_FILL_TRAP, d0
    move.l  #WHITE, d1
    trap    #15
    
    move.l  #FILLED_RECT_TRAP, d0
        
render_loop:
    ; load segment position
    move.w  (a1)+, d1
    move.w  (a1)+, d2
    
    move.w  (a1)+, d3
    move.w  (a1)+, d4

    ; test segment bit and render if set
    btst    d5, d6
    beq     skip_segment
    
    ; x, y offset
    add.l   X_COORD(sp), d1
    add.l   Y_COORD(sp), d2
    
    add.l   X_COORD(sp), d3
    add.l   Y_COORD(sp), d4
    
    jsr     render_segment
    
skip_segment:
    dbra    d5, render_loop
    
    rts
    
render_segment:
    ; draw the segment
    trap    #15
    
    rts

SegmentTable        dc.b    $7E, $30, $6D, $79, $33, $5B, $5F, $70, $7F, $7B

SegmentPositions    dc.w    0, 0, 10, 0 ; A
                    dc.w    10, 0, 10, 10 ; B
                    dc.w    10, 10, 10, 20 ; C
                    dc.w    10, 20, 0, 20 ; D
                    dc.w    0, 20, 0, 10 ; E
                    dc.w    0, 10, 0, 0 ; F
                    dc.w    0, 10, 10, 10 ; G



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
