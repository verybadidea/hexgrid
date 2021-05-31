#include "inc/hex.bas"

#define rnd_int_rng(a, b) int(rnd * (((b) - (a)) + 1)) + (a)

const as string KEY_UP = chr(255, 72)
const as string KEY_DN = chr(255, 80)
const as string KEY_LE = chr(255, 75)
const as string KEY_RI = chr(255, 77)
const as string KEY_ESC = chr(27)
const as string KEY_SPC = chr(32)

#include "fbgfx.bi"
const SW = 400, SH = 600
screenres SW, SH, 32
width SW \ 8, SH \ 16
dim as hex_layout layout1 = _
	type(layout_flat, type<pt_dbl>(17, 16.2), type<pt_dbl>(SW \ 2, SH \ 2))

const map_rh = 10 'map height radius
const map_rw = 7 'map width radius
dim as ulong map(-map_rh to +map_rh, -map_rh to +map_rh)

const piece_size = 4
type piece_type
	dim as hex_axial abs_pos
	dim as hex_axial tile_pos(piece_size - 1) '0 to 3
	'dim as hex_axial tile_rot 'tile to rotate around --> NOT NEEDED?
	dim as ulong c_fill
end type

const num_pieces = 9
dim as piece_type piece(num_pieces-1) = {_ '(q, r)
	type((0, 0), {(0, -1), (0, 0), (0, 1), (0, 2)}, &hff007070),_
	type((0, 0), {(0, -1), (0, 0), (0, 1), (1, 1)}, &hff700070),_
	type((0, 0), {(0, -1), (0, 0), (0, 1), (-1, 0)}, &hff707000),_
	type((0, 0), {(0, -1), (0, 0), (0, 1), (1, -1)}, &hff700000),_
	type((0, 0), {(0, -1), (0, 0), (0, 1), (-1, 2)}, &hff007000),_
	type((0, 0), {(0, -1), (1, -1), (1, 0), (0, 1)}, &hff000070),_
	type((0, 0), {(0, -1), (1, -1), (1, 0), (0, 1)}, &hff704040),_
	type((0, 0), {(0, -1), (0, 0), (1, 0), (1, 1)}, &hff404070),_
	type((0, 0), {(0, -1), (0, 0), (-1, 1), (-1, 2)}, &hff407040)}

function get_tile_pos(piece as piece_type, tile_idx as integer) as hex_axial
	return hex_axial_add(piece.abs_pos, piece.tile_pos(tile_idx))
end function

function valid_pos(ha as hex_axial) as boolean
	dim as hex_cube hc = hex_axial_to_cube(ha)
	return (abs(hc.x) <= map_rw) and (abs(hc.y) <= map_rh) and (abs(hc.z) <= map_rh)
end function

'function is correct for all cases!
function pos_off_screen(layout as hex_layout, ha as hex_axial) as boolean
	dim as pt_dbl pt = hex_to_pixel(layout, ha)
	if pt.x + layout.size.x < 0 then return true 'left of screen
	if pt.x - layout.size.x > SW then return true 'right of screen
	if pt.y + layout.size.y < 0 then return true 'above screen
	if pt.y - layout.size.y > SH then return true 'below screen
	return false
end function

sub draw_board(layout as hex_layout)
	dim as hex_axial ha
	for q as integer = -(map_rh-2) to +(map_rh-2)
		ha.q = q
		for r as integer = -(map_rh+5) to +(map_rh+5)
			ha.r = r
			if pos_off_screen(layout, ha) = false then
				if valid_pos(ha) then
					'if map(q, r) <> 0 then hex_draw_f(layout1, ha, &hffa00000)
					hex_draw_o(layout, ha, &hff404040)
				else
					hex_draw_fb(layout, ha, &hff606060, &hff808080)
				end if
			end if
		next
	next
end sub

sub draw_piece(piece as piece_type, layout as hex_layout)
	for iTile as integer = 0 to piece_size - 1
		dim as ulong c_fill = piece.c_fill
		dim as ulong c_border = &hff000000 or (c_fill shl 1) 'double intensity
		'dim as hex_axial ha = hex_axial_add(current_piece.tile_pos(iTile), current_piece.abs_pos)
		dim as hex_axial ha = get_tile_pos(piece, iTile)
		hex_draw_filled_border(layout, ha, c_fill, c_border)
	next
end sub

sub rotate_piece(byref piece as piece_type, direction as integer)
	dim pRotFunc as sub (byref ha as hex_axial) 'subroutine pointer
	pRotFunc = iif(direction > 0, @hex_axial_rotate_right, @hex_axial_rotate_left)
	for iTile as integer = 0 to piece_size - 1
		pRotFunc(piece.tile_pos(iTile))
	next
end sub

dim as integer mx, my
dim as integer iPiece = 1
dim as piece_type current_piece = piece(iPiece)

while not multikey(FB.SC_ESCAPE)
	screenlock
	line(0, 0)-(SW-1, SH-1), 0, bf 'clear screen
	draw_board(layout1)
	'iPiece = int(rnd() * num_pieces)
	draw_piece(current_piece, layout1)
	'highlight tile at cursor
	'~ if getmouse(mx, my) = 0 then
		'~ dim as hex_cube hc = pixel_to_hex_int(layout1, type(mx, my))
		'~ if abs(hc.x) <= map_radius and abs(hc.y) <= map_radius and abs(hc.z) <= map_radius then
			'~ dim as hex_axial ha = hex_cube_to_axial(hc)
			'~ hex_draw_o(layout1, ha, rgb(255, 255, 255))
			'~ draw string(10, 10), "ha current_piece.tile(iTile): " & current_piece.tile_pos(0)
			'~ draw string(10, 30), "hc current_piece.tile(iTile): " & hex_axial_to_cube(current_piece.tile_pos(0))
		'~ end if
	'~ else
		'~ draw string(10, 10), "Mouse not in window"
	'~ end if
	screenunlock

	dim as string key = inkey
	select case key
	case KEY_LE
		current_piece.abs_pos.q -= 1
		current_piece.abs_pos.r += 1
	case KEY_RI
		current_piece.abs_pos.q += 1
	case KEY_UP
		rotate_piece(current_piece, +1)
	case KEY_DN
		rotate_piece(current_piece, -1)
	end select
	'~ 'update piece
	'~ current_piece.abs_pos.r += 1

	sleep 1
wend

getkey()

'steps:
'game loop: move down with interval
'game loop: keys: left, right
'game loop: keys: up, down for rotation
'game loop: keys: space for drop
'check valid pos (no collision, in map)
'check game over
'points / scoring
'copy to board
'check line drop down/left and/or down right
'make 3 piece version also
