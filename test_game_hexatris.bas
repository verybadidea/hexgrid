#include "inc/hex.bas"

#define rnd_int_rng(a, b) int(rnd * (((b) - (a)) + 1)) + (a)

#include "fbgfx.bi"
const SW = 800, SH = 600
screenres SW, SH, 32
width SW \ 8, SH \ 16
dim as hex_layout layout1 = _
	type(layout_flat, type<pt_dbl>(18, 18), type<pt_dbl>(SW \ 2, SH \ 2))
dim as hex_axial ha = type(0, 0)
dim as ubyte rd, gn, bl
dim as integer mx, my
dim as hex_cube hc
dim as integer map_radius = 9
dim as ulong map(-map_radius to +map_radius, -map_radius to +map_radius)

const piece_size = 4

type piece_type
	dim as hex_axial tile(piece_size - 1) '0 to 3
	dim as hex_axial rot_tile 'tile to rotate around --> NOT NEEDED?
	dim as ulong c_fill
end type

const num_pieces = 9
dim as piece_type piece(num_pieces-1) = {_ '(q, r)
	type({(0, -1), (0, 0), (0, 1), (0, 2)}, (0, 0), &hff007070),_
	type({(0, -1), (0, 0), (0, 1), (1, 1)}, (0, 0), &hff700070),_
	type({(0, -1), (0, 0), (0, 1), (-1, 0)}, (0, 0), &hff707000),_
	type({(0, -1), (0, 0), (0, 1), (1, -1)}, (0, 0), &hff700000),_
	type({(0, -1), (0, 0), (0, 1), (-1, 2)}, (0, 0), &hff007000),_
	type({(0, -1), (1, -1), (1, 0), (0, 1)}, (0, 0), &hff000070),_
	type({(0, -1), (1, -1), (1, 0), (0, 1)}, (0, 0), &hff704040),_
	type({(0, -1), (0, 0), (1, 0), (1, 1)}, (0, 0), &hff404070),_
	type({(0, -1), (0, 0), (-1, 1), (-1, 2)}, (0, 0), &hff407040)}

dim as integer iPiece = 1
dim as piece_type current_piece = piece(iPiece)

while not multikey(FB.SC_ESCAPE)
	screenlock
	'clear screen
	line(0, 0)-(SW-1, SH-1), 0, bf
	'draw grid
	for q as integer = -map_radius to +map_radius
		ha.q = q
		for r as integer = -map_radius to +map_radius
			ha.r = r
			hc = hex_axial_to_cube(ha)
			if abs(hc.x) <= map_radius and abs(hc.y) <= map_radius and abs(hc.z) <= map_radius then
				'if map(q, r) <> 0 then hex_draw_f(layout1, ha, &hffa00000)
				hex_draw_o(layout1, ha, &hff404040)
			end if
		next
	next
	'draw piece
	'iPiece = int(rnd() * num_pieces)
	dim as hex_axial offset
	'~ do
		'~ offset = type(rnd_int_rng(-4, +4), rnd_int_rng(-4, +4))
	'~ loop while hex_axial_distance(offset, type(0, 0)) > 4
	for iTile as integer = 0 to piece_size - 1
		dim as ulong c_fill = current_piece.c_fill
		dim as ulong c_border = &hff000000 or (c_fill shl 1) 'double intensity
		dim as hex_axial ha = current_piece.tile(iTile)
		hex_draw_filled_border(layout1, hex_axial_add(ha, offset), c_fill, c_border)
	next
	'highlight tile at cursor
	if getmouse(mx, my) = 0 then
		hc = pixel_to_hex_int(layout1, type(mx, my))
		if abs(hc.x) <= map_radius and abs(hc.y) <= map_radius and abs(hc.z) <= map_radius then
			ha = hex_cube_to_axial(hc)
			hex_draw_o(layout1, ha, rgb(255, 255, 255))
			'draw string(10, 10), "click cells to toggle color"
			'draw string(10, 30), "hex axial coordinates: " & ha
			draw string(10, 10), "ha current_piece.tile(iTile): " & current_piece.tile(0)
			draw string(10, 30), "hc current_piece.tile(iTile): " & hex_axial_to_cube(current_piece.tile(0))
		end if
	else
		draw string(10, 10), "Mouse not in window"
	end if
	screenunlock

	'update piece
	for iTile as integer = 0 to piece_size - 1
		'current_piece.tile(iTile).r += 1
		current_piece.tile(iTile) = hex_cube_to_axial(hex_rotate_right(hex_axial_to_cube(current_piece.tile(iTile))))
		'current_piece.tile(iTile) = hex_cube_to_axial(hex_rotate_left(hex_axial_to_cube(current_piece.tile(iTile))))
	next

	sleep 500
wend

getkey()

