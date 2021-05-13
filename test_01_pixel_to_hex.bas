#include "inc/hex.bas"

#include "fbgfx.bi"
const SW = 800, SH = 600
screenres SW, SH, 32
width SW \ 8, SH \ 16
dim as hex_layout layout = _
	type(layout_flat, type<pt_dbl>(30, 30), type<pt_dbl>(SW \ 2, SH \ 2))
dim as hex_axial ha = type(0, 0)
dim as ubyte rd, gn, bl
dim as integer mx, my
dim as hex_cube hc
dim as integer map_radius = 5

while not multikey(FB.SC_ESCAPE)
	screenlock
	line(0, 0)-(SW-1, SH-1), 0, bf
	'draw grid
	for q as integer = -map_radius to +map_radius
		ha.q = q
		for r as integer = -map_radius to +map_radius
			ha.r = r
			hc = hex_axial_to_cube(ha)
			rd = limit(r * 25 + 127, 0, 255)
			gn = limit(q * 25 + 127, 0, 255)
			bl = 127
			if abs(hc.x) <= map_radius and abs(hc.y) <= map_radius and abs(hc.z) <= map_radius then
				hex_draw_outline(layout, ha, rgb(rd, gn, bl))
			end if
		next
	next
	'highlight tile at cursor
	if getmouse(mx, my) = 0 then
		hc = pixel_to_hex_int(layout, type(mx, my))
		if abs(hc.x) <= map_radius and abs(hc.y) <= map_radius and abs(hc.z) <= map_radius then
			ha = hex_cube_to_axial(hc)
			hex_draw_outline(layout, ha, rgb(255, 255, 255))
			draw string(10, 10), "hex cube coordinates: " & hc
			draw string(10, 30), "hex axial coordinates: " & ha
		else
			draw string(10, 10), "Mouse move inside grid"
		end if
	else
		draw string(10, 10), "Mouse move inside window"
	end if
	
	screenunlock
	sleep 1
wend

getkey()
