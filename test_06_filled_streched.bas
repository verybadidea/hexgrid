#include "inc/hex.bas"

#include "fbgfx.bi"
const SW = 800, SH = 600
screenres SW, SH, 32
width SW \ 8, SH \ 16
dim as hex_layout layout1 = _
	type(layout_pointy, type<pt_dbl>(15, 30), type<pt_dbl>(SW *.20, SH * 0.5))
dim as hex_layout layout2 = _
	type(layout_flat, type<pt_dbl>(25, 15), type<pt_dbl>(SW *.70, SH * 0.5))
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
			if abs(hc.x) <= map_radius and abs(hc.y) <= map_radius and abs(hc.z) <= map_radius then
				hex_draw_outline(layout1, ha, &hff404040)
				hex_draw_outline(layout2, ha, &hff404040)
			end if
		next
	next
	'highlight tile at cursor
	if getmouse(mx, my) = 0 then
		hc = pixel_to_hex_int(layout1, type(mx, my))
		if abs(hc.x) <= map_radius and abs(hc.y) <= map_radius and abs(hc.z) <= map_radius then
			ha = hex_cube_to_axial(hc)
			hex_draw_filled(layout1, ha, rgb(128, 255, 128))
		else
			draw string(10, 10), "Mouse not in grid 1"
		end if
		hc = pixel_to_hex_int(layout2, type(mx, my))
		if abs(hc.x) <= map_radius and abs(hc.y) <= map_radius and abs(hc.z) <= map_radius then
			ha = hex_cube_to_axial(hc)
			hex_draw_filled(layout2, ha, rgb(255, 128, 128))
		else
			draw string(SW * 0.5, 10), "Mouse not in grid 2"
		end if
	else
		draw string(SW * 0.4, SH - 26), "Mouse not in window"
	end if
	
	screenunlock
	sleep 1
wend

getkey()
