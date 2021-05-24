#include "inc/hex.bas"

#include "fbgfx.bi"
const SW = 800, SH = 600
screenres SW, SH, 32
width SW \ 8, SH \ 16
dim as hex_layout layout1 = _
	type(layout_flat, type<pt_dbl>(40, 30), type<pt_dbl>(SW \ 2, SH \ 2))
dim as hex_axial ha = type(0, 0)
dim as ubyte rd, gn, bl
dim as integer mx, my, mw, mb, lmb, lmb_old
dim as hex_cube hc
dim as integer map_radius = 5
dim as ulong map(-map_radius to +map_radius, -map_radius to +map_radius)

while not multikey(FB.SC_ESCAPE)
	screenlock
	line(0, 0)-(SW-1, SH-1), 0, bf
	'draw grid
	for q as integer = -map_radius to +map_radius
		ha.q = q
		for r as integer = -map_radius to +map_radius
			ha.r = r
			hc = hex_axial_to_cube(ha)
			if abs(hc.x) <= map_radius and abs(hc.y) <= map_radius and abs(hc.z) <= map_radius then
				dim as integer i = 255 - hex_axial_distance(ha, type(0, 0)) * (200 \ map_radius)
				if map(q, r) <> 0 then hex_draw_filled(layout1, ha, rgb(i, 0, 0))
				hex_draw_outline(layout1, ha, rgb(i, i, i))
			end if
		next
	next
	'highlight tile at cursor
	if getmouse(mx, my, mw, mb) = 0 then
		lmb = mb and 1
		hc = pixel_to_hex_int(layout1, type(mx, my))
		if abs(hc.x) <= map_radius and abs(hc.y) <= map_radius and abs(hc.z) <= map_radius then
			ha = hex_cube_to_axial(hc)
			if lmb <> lmb_old then 'button change
				lmb_old = lmb
				if lmb = 1 then 'button pressed
					map(ha.q, ha.r) xor= 1
				end if
			end if
			hex_draw_outline(layout1, ha, rgb(255, 255, 255))
			draw string(10, 10), "click cells to toggle color"
			draw string(10, 30), "hex axial coordinates: " & ha
		end if
	else
		draw string(10, 10), "Mouse not in window"
	end if
	
	screenunlock
	sleep 1
wend

getkey()
