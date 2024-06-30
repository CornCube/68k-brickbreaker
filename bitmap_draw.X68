*-----------------------------------------------------------
* Title      : bitmap_draw
* Written by : Manas Malla
* Date       : 05/26/2024
* Description:

* In this exercise, you will create a subroutine that can display
*   a chunk of a .bmp file. The arguments required for your subroutine are:
*   - Pointer to .bmp file (NOT a pointer to the pixel data)
*   - Top, Left corner (x,y) of the bitmap chunk you want to display
*   - Width and Height of the bitmap chunk you want to display
*   - Top, Left corner (x,y) on the output screen to display your chunk
* You will need to handle 24-bit and 32-bit bitmaps
* See if you can pass in the arguments via the stack. Do not use your 
* heap memory to pass in arguments to this subroutine. 
*-----------------------------------------------------------

PEN_COLOR_TRAP  equ     80
DRAW_PIXEL_TRAP equ     82

; parameters
PTR_BITMAP_DATA equ     28
CHUNK_X         equ     24
CHUNK_Y         equ     20
CHUNK_WIDTH     equ     16
CHUNK_HEIGHT    equ     12
OUTPUT_X        equ     8
OUTPUT_Y        equ     4
    
    
; push 7 arguments onto the stack first.
; 1. pointer to bitmap data file
; 2. x coord left corner of bitmap
; 3. y coord top corner of bitmap
; 4. width on bitmap
; 5. height on bitmap
; 6. x coord left corner of output window
; 7. y coord top corner of output window
; after all args are on the stack, call the bitmap drawing subroutine
; comes to this after rts, fixes stack and then exits the program

bitmap_subroutine:
    ; load in bitmap file
    move.l  PTR_BITMAP_DATA(sp), a0
    
    ; first 2 bytes are signature
    move.w  (a0)+, d0
    move.w  bitmap_signature, d1
    cmp.w   d1, d0
    beq     file_header
    
    ; error out if the signature doesn't match the expected
    move.l  #13, d0
    lea     wrong_signature, a1
    trap    #15
    SIMHALT

file_header:
    clr.l   d0
    clr.l   d1
    
    ; starting address of the pixel data
    add.l   #8, a0
    move.l  (a0)+, d0
    ror.w   #8, d0 ; fast byte swap
    swap    d0
    ror.w   #8, d0
    move.l  d0, bitmap_start
    
image_header:
    add.l   #4, a0 ; skip size of header
    
    ; save the bitmap width
    move.l  (a0)+, d0
    ror.w   #8, d0 ; fast byte swap
    swap    d0
    ror.w   #8, d0
    move.l  d0, bitmap_width
    
    ; save the bitmap height
    move.l  (a0)+, d0
    ror.w   #8, d0 ; fast byte swap
    swap    d0
    ror.w   #8, d0
    move.l  d0, bitmap_height
    
    add.l   #2, a0 ; skip color planes
    
    ; determine color depth (bits per pixel)
    clr.l   d0
    move.w  (a0)+, d0
    ror.w   #8, d0 ; swap
    
    ; reset a0
    move.l  PTR_BITMAP_DATA(sp), a0
    add.l   bitmap_start, a0 ; start of the pixel array
    
    ; 24 bit color
    cmp.w   #24, d0
    beq     bit_24
    
    ; 32 bit color
    cmp.w   #32, d0
    beq     bit_32
    
    rts

; 1 pixel value per 3 bytes
; d3 is number of padding bytes
; (d4, d5) is (x, y) (start at bottom left)
; (d6, d7) is (width, height)
bit_24:
    ; x and y positions on the output window
    move.l  OUTPUT_X(sp), d4
    move.l  OUTPUT_Y(sp), d5
    add.l   CHUNK_HEIGHT(sp), d5
    sub.l   #1, d5
    
    ; calculate rowsize = floor((24 * bitmap_width + 31) / 32) * 4 (in bytes)
    move.l  bitmap_width, d3
    mulu.w  #24, d3
    add.l   #31, d3
    asr.l   #5, d3 ; divide by 32
    lsl.l   #2, d3
    
    ; calculating start position a0
    ; bottom row = bitmap_height - (CHUNK_Y + CHUNK_HEIGHT)
    move.l  CHUNK_Y(sp), d1
    move.l  CHUNK_HEIGHT(sp), d2
    add.l   d1, d2
    move.l  bitmap_height, d1
    sub.l   d2, d1 ; d1 has bottom_row index
    
    ; calculate offset
    ; offset = bottom_row * rowsize + (CHUNK_X * 3)
    mulu.w  d3, d1
    move.l  CHUNK_X(sp), d2
    mulu.w  #3, d2
    add.l   d1, d2
    add.l   d2, a0
    
    ; number of padding bytes = rowsize - (bitmap_width * 3)
    move.l  bitmap_width, d6
    mulu.w  #3, d6
    sub.l   d6, d3
    
    ; calculate number of pixels to skip at the end of each row
    ; (bitmap_width - CHUNK_WIDTH) * 3 + pad bytes
    move.l  bitmap_width, d2
    sub.l   CHUNK_WIDTH(sp), d2
    mulu.w  #3, d2
    add.l   d2, d3
    
    ; setting height counter (width is set below)
    move.l  CHUNK_HEIGHT(sp), d7
    sub.l   #1, d7
    
bit_24_y:
    ; resetting the x and counter
    move.l  OUTPUT_X(sp), d4
    move.l  CHUNK_WIDTH(sp), d6
    sub.l   #1, d6
    
bit_24_x:
	; set pen color
	clr.l   d1
	move.l  #PEN_COLOR_TRAP, d0
	move.b  (a0)+, d1
	lsl.l   #8, d1
	move.b  (a0)+, d1
	lsl.l   #8, d1
	move.b  (a0)+, d1 ; all 3 bgr set in d1 ($00BBGGRR)
	trap    #15
	
	; draw the pixel
	move.l  #DRAW_PIXEL_TRAP, d0
	move.l  d4, d1
	move.l  d5, d2
	trap    #15
	
	add.l   #1, d4 ; increment x coord
	dbra    d6, bit_24_x ; decrement width counter and keep looping
	
	add.l   d3, a0 ; skip the padding bytes
	
	sub.l   #1, d5 ; decrement y coord
	dbra    d7, bit_24_y ; decrement height counter and keep looping
	
	rts

; 1 pixel value per 4 bytes
; d3 is number of padding bytes
; (d4, d5) is (x, y) (start at bottom left)
; (d6, d7) is (width, height)
bit_32:
    ; x and y positions on the output window
    move.l  OUTPUT_X(sp), d4
    move.l  OUTPUT_Y(sp), d5
    add.l   CHUNK_HEIGHT(sp), d5
    sub.l   #1, d5
    
    ; calculate rowsize = floor((32 * bitmap_width + 31) / 32) * 4 (in bytes)
    move.l  bitmap_width, d3
    lsl.l   #5, d3 ; multiply by 32
    add.l   #31, d3
    asr.l   #5, d3 ; divide by 32
    lsl.l   #2, d3
    
    ; calculating start position a0
    ; bottom row = bitmap_height - (CHUNK_Y + CHUNK_HEIGHT)
    move.l  CHUNK_Y(sp), d1
    move.l  CHUNK_HEIGHT(sp), d2
    add.l   d1, d2
    move.l  bitmap_height, d1
    sub.l   d2, d1 ; d1 has bottom_row index
    
    ; calculate offset (starting point taking into account chunk params)
    ; offset = bottom_row * rowsize + (CHUNK_X * 4)
    mulu.w  d3, d1
    move.l  CHUNK_X(sp), d2
    lsl.l   #2, d2
    add.l   d1, d2
    add.l   d2, a0
    
    ; number of padding bytes = rowsize - (bitmap_width * 4)
    move.l  bitmap_width, d6
    lsl.l   #2, d6
    sub.l   d6, d3
    
    ; calculate number of pixels to skip at the end of each row
    ; (bitmap_width - CHUNK_WIDTH) * 4 + pad bytes
    move.l  bitmap_width, d2
    sub.l   CHUNK_WIDTH(sp), d2
    lsl.l   #2, d2
    add.l   d2, d3
    
    ; setting height counter (width is set below)
    move.l  CHUNK_HEIGHT(sp), d7
    sub.l   #1, d7
    
bit_32_y:
    ; resetting the x and counter
    move.l  OUTPUT_X(sp), d4
    move.l  CHUNK_WIDTH(sp), d6 ; width counter
    sub.l   #1, d6
    
bit_32_x:
	; set pen color
	clr.l   d1
	move.l  #PEN_COLOR_TRAP, d0
	move.l  (a0)+, d1 ; moving the pixel color (BBGGRRAA format)
	lsr.l   #8, d1 ; shift to 00BBGGRR format
	
	trap    #15
	
	; draw the pixel
	move.l  #DRAW_PIXEL_TRAP, d0
	move.l  d4, d1
	move.l  d5, d2
	trap    #15
	
	add.l   #1, d4 ; increment x coord
	dbra    d6, bit_32_x ; decrement width counter and keep looping
	
	add.l   d3, a0 ; skip the padding bytes
	
	sub.l   #1, d5 ; decrement y coord
	dbra    d7, bit_32_y ; decrement height counter and keep looping
	
	rts

* Put variables and constants here
bitmap_signature:   dc.b    'BM'
wrong_signature:    dc.b    'Incorrect File Signature', 0
bitmap_start:       dc.l    0
bitmap_width:       dc.l    0
bitmap_height:      dc.l    0






*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
