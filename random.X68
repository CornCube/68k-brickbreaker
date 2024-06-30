ALL_REG                 REG     D0-D7/A0-A6

GET_TIME_COMMAND        equ     8

seed_random_number
        movem.l ALL_REG,-(sp)           ;; What does this do?
        clr.l   d6
        move.b  #GET_TIME_COMMAND,d0    ;; What if you used the same seed?
        TRAP    #15

        move.l  d1,RANDOMVAL
        movem.l (sp)+,ALL_REG
        rts
        
random_word_d6
        movem.l ALL_REG,-(sp)
        clr.l   d5
        
        jsr     random_byte_d6
        move.b  d6,d5
        jsr     random_byte_d6
        lsl.l   #8,d5
        move.b  d6,d5
        move.l  d5, TEMPRANDOMWORD
        
        move.w  #425, d0
        move.l  TEMPRANDOMWORD, d1
        divu    d0, d1 ; remainder in upper, quotient in lower word
        
        clr.w   d1
        swap    d1
        
        add.w   #135, d1
        move.w  d1, TEMPRANDOMWORD
        
        movem.l (sp)+,ALL_REG
        clr.l   d6
        move.w  TEMPRANDOMWORD, d6
        
        rts

random_byte_d6
        movem.l d0,-(sp)
        movem.l d1,-(sp)
        movem.l d2,-(sp)
        move.l  RANDOMVAL,d0
       	moveq	#$AF-$100,d1
       	moveq	#18,d2
Ninc0	
	add.l	d0,d0
	bcc	Ninc1
	eor.b	d1,d0
Ninc1
	dbf	d2,Ninc0
	
	move.l	d0,RANDOMVAL
	clr.l	d6
	move.b	d0,d6
	
        movem.l (sp)+,d2
        movem.l (sp)+,d1
        movem.l (sp)+,d0
        rts
        

random_long_d6
        movem.l ALL_REG,-(sp)
        jsr     random_byte_d6
        move.b  d6,d5
        jsr     random_byte_d6
        lsl.l   #8,d5
        move.b  d6,d5
        jsr     random_byte_d6
        lsl.l   #8,d5
        move.b  d6,d5
        jsr     random_byte_d6
        lsl.l   #8,d5
        move.b  d6,d5
        move.l  d5,TEMPRANDOMLONG
        
        movem.l (sp)+,ALL_REG
        move.l  TEMPRANDOMLONG,d6
        rts


RANDOMVAL       ds.l    1
TEMPRANDOMLONG  ds.l    1
TEMPRANDOMWORD  ds.w    1




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~8~
