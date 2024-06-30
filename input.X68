*-----------------------------------------------------------
* Title      : input
* Written by : Manas Malla
* Date       : 06/03/2024
* Description: This file checks for user input to move the paddle left
*              and right horizontally.
*-----------------------------------------------------------

START_SCREEN    equ     33<<FRAC_BITS
END_SCREEN      equ     165<<FRAC_BITS

check_inputs:
    move.l  #INPUT_TRAP, d0
    move.l  #LEFT<<8+RIGHT, d1
    trap    #15
    
    cmp.l   #$000000FF, d1
    beq     move_right

    cmp.l   #$0000FF00, d1
    beq     move_left
        
    rts
    
move_left:
    ; checks if the paddle can move left
    move.l  PaddleXPos, d0
    sub.l   #START_SCREEN, d0
    sub.l   #paddle_vel, d0
    cmp.l   #PADDLE_LENGTH, d0
    bge     update_paddle_left ; these functions are in the update_objects file
    bra     end_move
    
move_right:
    ; checks if the paddle can move right
    move.l  PaddleXPos, d0
    add.l   #paddle_vel, d0
    move.l  #(SCREEN_WIDTH<<FRAC_BITS)-PADDLE_LENGTH, d1
    sub.l   #END_SCREEN, d1
    cmp.l   d1, d0
    ble     update_paddle_right
    bra     end_move
    
end_move:
    rts












*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
