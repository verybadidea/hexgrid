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

const brd_rh = 10 'board height radius
const brd_rw = 7 'board width radius
const brd_psr = -9 'piece start row
dim as ulong board(-brd_rh to +brd_rh, -brd_rh to +brd_rh)

const piece_size = 4
type piece_type
	dim as hex_axial abs_pos
	dim as hex_axial tile_pos(piece_size - 1) '0 to 3
	'dim as hex_axial tile_rot 'tile to rotate around --> NOT NEEDED?
	dim as ulong c_fill
end type

const num_pieces = 9
dim as piece_type piece(num_pieces-1) = {_ '(q, r)
	type((0, 0), {(0, -1), (0, 0), (0, 1), (0, 2)},   &hff007070),_
	type((0, 0), {(0, -1), (0, 0), (0, 1), (1, 1)},   &hff700070),_
	type((0, 0), {(0, -1), (0, 0), (0, 1), (-1, 0)},  &hff707000),_
	type((0, 0), {(0, -1), (0, 0), (0, 1), (1, -1)},  &hff700000),_
	type((0, 0), {(0, -1), (0, 0), (0, 1), (-1, 2)},  &hff007000),_
	type((0, 0), {(0, -1), (1, -1), (1, 0), (0, 1)},  &hff400070),_
	type((0, 0), {(0, -1), (1, -1), (1, 0), (0, 1)},  &hff704000),_
	type((0, 0), {(0, -1), (0, 0), (1, 0), (1, 1)},   &hff004070),_
	type((0, 0), {(0, -1), (0, 0), (-1, 1), (-1, 2)}, &hff507000)}

function get_tile_pos(piece as piece_type, tile_idx as integer) as hex_axial
	return hex_axial_add(piece.abs_pos, piece.tile_pos(tile_idx))
end function

'valid board tile index?
function valid_tile_pos(ha as hex_axial) as boolean
	dim as hex_cube hc = hex_axial_to_cube(ha)
	return (abs(hc.x) <= brd_rw) and (abs(hc.y) <= brd_rh) and (abs(hc.z) <= brd_rh)
end function

'all tiles valid board index & not occupied?
function free_piece_pos(piece as piece_type, board() as ulong) as boolean
	for iTile as integer = 0 to piece_size - 1
		dim as hex_axial ha = get_tile_pos(piece, iTile)
		if not valid_tile_pos(ha) then return false
		if board(ha.q, ha.r) <> 0 then return false
	next
	return true
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

sub draw_board(board() as ulong, layout as hex_layout)
	dim as hex_axial ha
	for q as integer = -(brd_rh-2) to +(brd_rh-2)
		ha.q = q
		for r as integer = -(brd_rh+5) to +(brd_rh+5)
			ha.r = r
			if pos_off_screen(layout, ha) = false then
				if valid_tile_pos(ha) then
					if board(q, r) <> 0 then
						'piece tile, with bright edge
						hex_draw_fb(layout, ha, board(q, r), board(q, r) shl 1)
					else
						'no piece tile on board
						hex_draw_o(layout, ha, &hff404040)
					end if
				else
					'outside board
					hex_draw_fb(layout, ha, &hff505050, &hff909090)
				end if
			end if
		next
	next
end sub

sub draw_piece(piece as piece_type, layout as hex_layout, outline_only as integer)
	for iTile as integer = 0 to piece_size - 1
		dim as ulong c_fill = piece.c_fill
		dim as ulong c_border = &hff000000 or (c_fill shl 1) 'double intensity
		'dim as hex_axial ha = hex_axial_add(current_piece.tile_pos(iTile), current_piece.abs_pos)
		dim as hex_axial ha = get_tile_pos(piece, iTile)
		if outline_only = 1 then
			hex_draw_o(layout, ha, c_border) 'for ghost piece
		else
			hex_draw_filled_border(layout, ha, c_fill, c_border) 'play piece
		end if
	next
end sub

sub rotate_piece(byref piece as piece_type, direction as integer)
	dim pRotFunc as sub (byref ha as hex_axial) 'subroutine pointer
	pRotFunc = iif(direction > 0, @hex_axial_rotate_right, @hex_axial_rotate_left)
	for iTile as integer = 0 to piece_size - 1
		pRotFunc(piece.tile_pos(iTile))
	next
end sub

sub move_piece(byref piece as piece_type, direction as integer)
	piece.abs_pos = hex_axial_neighbor(piece.abs_pos, direction)
end sub

'choose random piece and position at top of board
function new_piece(piece() as piece_type) as piece_type
	dim as piece_type ret_piece = piece(int(rnd() * num_pieces))
	ret_piece.abs_pos.r = brd_psr
	return ret_piece
end function

const as double start_interval = 1.0 '1 tiles per second
const as double drop_interval = 0.05 '20 tiles per second

dim as piece_type current_piece, ghost_piece
dim as double t = timer, t_step = start_interval, t_next = t + t_step
dim as integer enable_control = true
dim as integer quit = 0, request_new = true
dim as integer mx, my 'mouse x,y

randomize timer
while quit = 0
	if request_new = true then
		current_piece = new_piece(piece())
		request_new = false
		if not free_piece_pos(current_piece, board()) then quit = 2 'game over
	end if
	'determine ghost piece location
	ghost_piece = current_piece
	while 1
		ghost_piece.abs_pos.r += 1
		if not free_piece_pos(ghost_piece, board()) then
			ghost_piece.abs_pos.r -= 1
			exit while
		end if
	wend

	screenlock
	line(0, 0)-(SW-1, SH-1), 0, bf 'clear screen
	draw_board(board(), layout1)
	if free_piece_pos(current_piece, board()) then
		draw_piece(current_piece, layout1, 0)
		if ghost_piece.abs_pos <> current_piece.abs_pos then
			draw_piece(ghost_piece, layout1, 1)
		end if
	end if
	draw string (5, 0), "keys: up, down, left, right, space, escape"
	'mouse pointer
	if getmouse(mx, my) = 0 then
		dim as hex_cube hc = pixel_to_hex_int(layout1, type(mx, my))
		dim as hex_axial ha = hex_cube_to_axial(hc)
		hex_draw_outline(layout1, ha, rgb(255, 255, 255))
		draw string(5, 30), "hex cube coordinates: " & hc
		draw string(5, 50), "hex axial coordinates: " & ha
	end if
	screenunlock

	dim as string key = inkey
	if enable_control = true then
		select case key
		case KEY_ESC
			quit = 1 'abort by user
		case KEY_LE
			move_piece(current_piece, HEX_AX_LE_DN)
			if not free_piece_pos(current_piece, board()) then
				move_piece(current_piece, HEX_AX_RI_UP) 'undo move
			end if
		case KEY_RI
			move_piece(current_piece, HEX_AX_RI_DN)
			if not free_piece_pos(current_piece, board()) then
				move_piece(current_piece, HEX_AX_LE_UP) 'undo move
			end if
		case KEY_UP
			rotate_piece(current_piece, +1)
			if not free_piece_pos(current_piece, board()) then
				rotate_piece(current_piece, -1) 'undo move
			end if
		case KEY_DN
			rotate_piece(current_piece, -1)
			if not free_piece_pos(current_piece, board()) then
				rotate_piece(current_piece, +1) 'undo move
			end if
		case KEY_SPC
			enable_control = false
			current_piece.abs_pos.r += 1
			t_step = drop_interval
			t_next = t + t_step
		end select
	end if
	'move piece down on time
	if t > t_next then
		current_piece.abs_pos.r += 1
		t_next = t + t_step
		if not free_piece_pos(current_piece, board()) then
			current_piece.abs_pos.r -= 1
			'copy to board
			for iTile as integer = 0 to piece_size - 1
				dim as hex_axial ha = get_tile_pos(current_piece, iTile)
				if valid_tile_pos(ha) then 'redundant check
					board(ha.q, ha.r) = current_piece.c_fill
				end if
			next
			request_new = true
			enable_control = true
			t_step = start_interval
			t_next = t + t_step
		end if
	end if
	sleep 1
	t = timer
wend
if quit = 2 then
	locate 13, 21: print "Game over!"
else
	locate 13, 13: print "End, press any key to exit"
end if

getkey()

'steps:
'implement 'wall-kick'
'points / scoring: make lines, shift/drop board
'check line drop down/left and/or down right
'next piece indicator

'~ 'show all pieces
'~ for iPiece as integer = 0 to num_pieces-1
	'~ current_piece = piece(iPiece)
	'~ rotate_piece(current_piece, 1)
	'~ current_piece.abs_pos.r = iPiece * 2 - 9
	'~ current_piece.abs_pos.q = ((iPiece+1) mod 2) * 6 - 3
	'~ draw_piece(current_piece, layout1)
'~ next
'~ getkey()
'~ end
