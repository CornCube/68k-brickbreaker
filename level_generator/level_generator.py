# Title: level_generator.py
# Author: Manas Malla
# Description: generates the level.bin file used by draw_bricks.X68

from PIL import Image

def get_pixel_color(image_path, x, y):
    # open the image
    with Image.open(image_path) as img:
        # get the pixel color
        pixel = img.getpixel((x, y))

        # check if the pixel is pink (FF00FF)
        if pixel == (255, 0, 255):
            return None

        # convert to 32-bit word in 00BBGGRR format
        # pixel format is (R, G, B)
        r, g, b = pixel
        color_32bit = (b << 16) | (g << 8) | r
        return color_32bit

import struct

def write_brick(file, x1, y1, x2, y2, color, hits):
    file.write(struct.pack('>IIIIII', x1, y1, x2, y2, color, hits))

def write_end_of_level(file):
    file.write(struct.pack('>I', 0xFFFFFFFF))

def write_end_of_file(file):
    file.write(struct.pack('>I', 0xEEEEEEEE))

# one row
def level_one(file):
    left_bound = 30
    top_bound = 100
    brick_width = 55
    brick_height = 30
    bricks_per_row = 11
    rows = 2
    colors = [0x00B474FC, 0x0010D080]
    hits_required = [2, 1]

    total_bricks = bricks_per_row * rows
    file.write(struct.pack('>I', total_bricks))

    for row in range(rows):
        for brick in range(bricks_per_row):
            x1 = left_bound + brick * brick_width
            y1 = top_bound + row * brick_height
            x2 = x1 + brick_width
            y2 = y1 + brick_height
            color = colors[row % len(colors)]
            hits = hits_required[row % len(hits_required)]
            write_brick(file, x1, y1, x2, y2, color, hits)

    write_end_of_level(file)

# 3 x 6 block
def level_two(file):
    left_bound = 30
    top_bound = 100
    brick_width = 55
    brick_height = 30
    rows = 6
    middle_start = 4  # index for the start of the middle three bricks
    middle_end = 7  # index for the end of the middle three bricks
    colors = [0x00BCBCBC, 0x000028D8, 0x00EC7000, 0x006074FC, 0x00B474FC, 0x0010D080]
    hits_required = [3, 1, 1, 1, 1, 1]

    total_bricks = 3 * rows
    file.write(struct.pack('>I', total_bricks))

    for row in range(rows):
        for brick in range(middle_start, middle_end):
            x1 = left_bound + brick * brick_width
            y1 = top_bound + row * brick_height
            x2 = x1 + brick_width
            y2 = y1 + brick_height
            color = colors[row % len(colors)]
            hits = hits_required[row % len(hits_required)]
            write_brick(file, x1, y1, x2, y2, color, hits)

    write_end_of_level(file)

# 2x2 holes
def level_three(file):
    left_bound = 30
    top_bound = 100
    brick_width = 55
    brick_height = 30
    bricks_per_row = 11
    rows = 6
    hole_width = 2
    hole_start_left = 2  # index for the start of the left hole
    hole_start_right = bricks_per_row - hole_start_left - hole_width  # index for the start of the right hole
    colors = [0x00BCBCBC, 0x000028D8, 0x00EC7000, 0x006074FC, 0x00B474FC, 0x0010D080]
    hits_required = [3, 1, 1, 1, 1, 1]

    total_bricks = (bricks_per_row * 4) + (bricks_per_row - 4) * 2  # 4 full rows, 2 rows with holes
    file.write(struct.pack('>I', total_bricks))

    for row in range(rows):
        for brick in range(bricks_per_row):
            if (row == 2 or row == 3) and ((hole_start_left <= brick < hole_start_left + hole_width) or (hole_start_right <= brick < hole_start_right + hole_width)):
                continue  # skip the bricks that are part of the holes
            x1 = left_bound + brick * brick_width
            y1 = top_bound + row * brick_height
            x2 = x1 + brick_width
            y2 = y1 + brick_height
            color = colors[row % len(colors)]
            hits = hits_required[row % len(hits_required)]
            write_brick(file, x1, y1, x2, y2, color, hits)

    write_end_of_level(file)

# full grid
def level_four(file):
    left_bound = 30
    top_bound = 100
    brick_width = 55
    brick_height = 30
    bricks_per_row = 11
    rows = 6
    colors = [0x00BCBCBC, 0x000028D8, 0x00EC7000, 0x006074FC, 0x00B474FC, 0x0010D080]
    hits_required = [3, 1, 1, 1, 1, 1]

    total_bricks = bricks_per_row * rows
    file.write(struct.pack('>I', total_bricks))

    for row in range(rows):
        for brick in range(bricks_per_row):
            x1 = left_bound + brick * brick_width
            y1 = top_bound + row * brick_height
            x2 = x1 + brick_width
            y2 = y1 + brick_height
            color = colors[row % len(colors)]
            hits = hits_required[row % len(hits_required)]
            write_brick(file, x1, y1, x2, y2, color, hits)

    write_end_of_level(file)

# flappy
def level_five(file):
    left_bound = 125
    top_bound = 30
    brick_width = 25
    brick_height = 25
    rows = 12
    colors = [0x00463852, 0x0043b6f7, 0x00fafafa, 0x001c3af9]
    hits_required = [2, 1, 1, 1]
    total_bricks = 150
    file.write(struct.pack('>I', total_bricks))

    image_path = 'flappybird.bmp'
    width = 17
    height = 12
    for c in range(width):
        for r in range(height):
            color = get_pixel_color(image_path, c, r)
            if color is not None:
                x1 = left_bound + c * brick_width
                y1 = top_bound + r * brick_height
                x2 = x1 + brick_width
                y2 = y1 + brick_height
                hits = 2 if color == 0x00463852 else 1
                write_brick(file, x1, y1, x2, y2, color, hits)

    write_end_of_level(file)

def generate_levels(filename):
    with open(filename, 'wb') as file:
        level_one(file)
        level_two(file)
        level_three(file)
        level_four(file)
        level_five(file)
        write_end_of_file(file)

if __name__ == "__main__":
    print("Generating levels...")
    generate_levels("level.bin")
