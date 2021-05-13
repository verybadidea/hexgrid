#include "inc/hex.bas"

#include "fbgfx.bi"
const SW = 800, SH = 600
screenres SW, SH, 32
width SW \ 8, SH \ 16
dim as hex_layout layout = _
	type(layout_flat, type<pt_dbl>(15, 15), type<pt_dbl>(SW \ 2, SH \ 2))
dim as hex_axial ha = type(0, 0)
dim as integer mx, my
dim as hex_cube hc
dim as integer map_radius = 10
dim as pt_dbl center

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
	'highlight center
	ha = type(0, 0)
	hex_draw_outline(layout, ha, rgb(255, 255, 255))
	center = hex_to_pixel(layout, ha)
	draw string(center.x - 3, center.y - 7), "C", rgb(255, 255, 255)
	'highlight tile at cursor
	if getmouse(mx, my) = 0 then
		hc = pixel_to_hex_int(layout, type(mx, my))
		if abs(hc.x) <= map_radius and abs(hc.y) <= map_radius and abs(hc.z) <= map_radius then
			'tile at mouse position
			ha = hex_cube_to_axial(hc)
			hex_draw_outline(layout, ha, rgb(255, 255, 0))
			center = hex_to_pixel(layout, ha)
			draw string(center.x - 3, center.y - 7), "M", rgb(255, 255, 0)
			'tile at 60 degrees rotated left
			ha = hex_cube_to_axial(hex_rotate_left(hc))
			hex_draw_outline(layout, ha, rgb(0, 255, 0))
			center = hex_to_pixel(layout, ha)
			draw string(center.x - 3, center.y - 7), "L", rgb(0, 255, 0)
			'tile at 60 degrees rotated right
			ha = hex_cube_to_axial(hex_rotate_right(hc))
			hex_draw_outline(layout, ha, rgb(255, 0, 0))
			center = hex_to_pixel(layout, ha)
			draw string(center.x - 3, center.y - 7), "R", rgb(255, 0, 0)
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
