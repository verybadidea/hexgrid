#include "inc/hex.bas"

#define rnd_range(a, b) (rnd * (b - a) + a)
#define rnd_color() (&hff000000 or int(rnd * &h00ffffff))

#include "fbgfx.bi"
const SW = 800, SH = 600
screenres SW, SH, 32
width SW \ 8, SH \ 16
dim as hex_layout layout = _
	type(layout_pointy, type<pt_dbl>(8, 8), type<pt_dbl>(SW * 0.6, SH * 0.5))
dim as hex_axial ha = type(0, 0)
dim as hex_cube hc
dim as integer map_radius = 20
dim as hex_axial h0 = type(0, 0), h1, h2
dim as hex_list hl

'draw grid
for q as integer = -map_radius to +map_radius
	ha.q = q
	for r as integer = -map_radius to +map_radius
		ha.r = r
		hc = hex_axial_to_cube(ha)
		if abs(hc.x) <= map_radius and abs(hc.y) <= map_radius and abs(hc.z) <= map_radius then
			hex_draw_outline(layout, ha, &hff606060) 'drak grey
		end if
	next
next

while not multikey(FB.SC_ESCAPE)
	screenlock
	'clear left part of screen
	line(0, 0)-(SW * 0.2, SH - 1), 0, bf
	'Create a random start- and endpoint, that are within the map
	do
		h1.r = cint(rnd_range(-map_radius, +map_radius))
		h1.q = cint(rnd_range(-map_radius, +map_radius))
	loop while hex_axial_distance(h1, h0) > map_radius
	do
		h2.r = cint(rnd_range(-map_radius, +map_radius))
		h2.q = cint(rnd_range(-map_radius, +map_radius))
	loop while hex_axial_distance(h2, h0) > map_radius
	hl = hex_line_list(hex_axial_to_cube(h1), hex_axial_to_cube(h2))
	dim as ulong colour = rnd_color()
	for i as integer = 0 to hl.last_index()
		hc = hl.pop()
		ha = hex_cube_to_axial(hc)
		'hex_draw_outline(layout, ha, &hfff0f060) 'yellow
		hex_draw_filled(layout, ha, colour)
		hex_draw_outline(layout, ha, &hff606060) 'drak grey
		draw string (10, 10 + i * 16), str(i) & ". " & ha
	next
	screenunlock
	sleep 500
wend

getkey()
