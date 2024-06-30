*-----------------------------------------------------------
* Title      : sound_manager
* Written by : Manas Malla
* Date       : 06/13/2024
* Description: This file loads in the various sound effects and contains
*              subroutines that can be called to play them.
*-----------------------------------------------------------

LOAD_SOUND_TRAP     equ     74
PLAY_SOUND_TRAP     equ     75

load_sounds:
    movem.l a1, -(sp)

    move.l  #LOAD_SOUND_TRAP, d0
    lea     GameOverSound, a1
    move.l  #1, d1
    trap    #15
    
    move.l  #LOAD_SOUND_TRAP, d0
    lea     BrickBreakSound, a1
    move.l  #2, d1
    trap    #15
    
    move.l  #LOAD_SOUND_TRAP, d0
    lea     NextLevelSound, a1
    move.l  #3, d1
    trap    #15
    
    move.l  #LOAD_SOUND_TRAP, d0
    lea     WinSound, a1
    move.l  #4, d1
    trap    #15
    
    move.l  #LOAD_SOUND_TRAP, d0
    lea     LoseLifeSound, a1
    move.l  #5, d1
    trap    #15
    
    move.l  #LOAD_SOUND_TRAP, d0
    lea     CollisionSound, a1
    move.l  #6, d1
    trap    #15
    
    movem.l (sp)+, a1
    
    rts
    
play_game_over_sound:
    movem.l ALL_REG, -(sp)
    move.l  #PLAY_SOUND_TRAP, d0
    move.l  #1, d1
    trap    #15
    movem.l (sp)+, ALL_REG
    
    rts

play_brick_break_sound:
    movem.l ALL_REG, -(sp)
    move.l  #PLAY_SOUND_TRAP, d0
    move.l  #2, d1
    trap    #15
    movem.l (sp)+, ALL_REG
    
    rts

play_next_level_sound:
    movem.l ALL_REG, -(sp)
    move.l  #PLAY_SOUND_TRAP, d0
    move.l  #3, d1
    trap    #15
    movem.l (sp)+, ALL_REG
    
    rts

play_win_sound:
    movem.l ALL_REG, -(sp)
    move.l  #PLAY_SOUND_TRAP, d0
    move.l  #4, d1
    trap    #15
    movem.l (sp)+, ALL_REG
    
    rts
    
play_lose_life_sound:
    movem.l ALL_REG, -(sp)
    move.l  #PLAY_SOUND_TRAP, d0
    move.l  #5, d1
    trap    #15
    movem.l (sp)+, ALL_REG
    
    rts
    
play_collision_sound:
    movem.l ALL_REG, -(sp)
    move.l  #PLAY_SOUND_TRAP, d0
    move.l  #6, d1
    trap    #15
    movem.l (sp)+, ALL_REG
    
    rts

GameOverSound       dc.b    'assets/gameoverhe.wav', 0
BrickBreakSound     dc.b    'assets/brickbreak.wav', 0
NextLevelSound      dc.b    'assets/levelup.wav', 0
WinSound            dc.b    'assets/victory.wav', 0
LoseLifeSound       dc.b    'assets/loselife.wav', 0
CollisionSound      dc.b    'assets/collision.wav', 0
PaddingLong         dc.l    0



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
