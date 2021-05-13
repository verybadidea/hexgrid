#include "inc/hex.bas"

#include "fbgfx.bi"
const SW = 800, SH = 600
screenres SW, SH, 32
width SW \ 8, SH \ 16
dim as hex_layout layout = _
	type(layout_pointy, type<pt_dbl>(15, 15), type<pt_dbl>(SW \ 2, SH \ 2))
dim as hex_axial ha = type(0, 0)
dim as integer mx, my
dim as hex_cube hc
dim as integer map_radius = 12

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
				hex_draw_outline(layout, ha, &hff606060) 'dark grey
			end if
		next
	next
	'highlight tile at cursor
	if getmouse(mx, my) = 0 then
		hc = pixel_to_hex_int(layout, type(mx, my))
		if abs(hc.x) <= map_radius and abs(hc.y) <= map_radius and abs(hc.z) <= map_radius then
			ha = hex_cube_to_axial(hc)
			hex_draw_outline(layout, ha, rgb(255, 255, 255))
			ha = hex_cube_to_axial(hex_reflect_x(hc))
			hex_draw_outline(layout, ha, rgb(255, 255, 0))
			ha = hex_cube_to_axial(hex_reflect_y(hc))
			hex_draw_outline(layout, ha, rgb(255, 0, 255))
			ha = hex_cube_to_axial(hex_reflect_z(hc))
			hex_draw_outline(layout, ha, rgb(0, 255, 255))
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
