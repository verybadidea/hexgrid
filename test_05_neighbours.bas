#include "inc/hex.bas"

#define rnd_range(a, b) (rnd * (b - a) + a)
#define rnd_color() (&hff000000 or int(rnd * &h00ffffff))

#include "fbgfx.bi"
const SW = 800, SH = 600
screenres SW, SH, 32
width SW \ 8, SH \ 16
dim as hex_layout layout = _
	type(layout_pointy, type<pt_dbl>(10, 10), type<pt_dbl>(SW * 0.5, SH * 0.5))
dim as hex_axial ha
dim as hex_cube hc
dim as integer map_radius = 18
dim as hex_axial walker1_pos_new, walker1_pos_old 'walker using axial coordinates
dim as hex_cube walker2_pos_new, walker2_pos_old 'walker using cube coordinates

'draw grid
for q as integer = -map_radius to +map_radius
	ha.q = q
	for r as integer = -map_radius to +map_radius
		ha.r = r
		hc = hex_axial_to_cube(ha)
		if abs(hc.x) <= map_radius and abs(hc.y) <= map_radius and abs(hc.z) <= map_radius then
			hex_draw_outline(layout, ha, &hff505050) 'drak grey
		end if
	next
next

while not multikey(FB.SC_ESCAPE)
	screenlock
	'walker1: random move, but within grid
	walker1_pos_old = walker1_pos_new
	do
		dim as integer walk_dir = int(rnd() * 6)
		walker1_pos_new = hex_axial_neighbor(walker1_pos_old, walk_dir)
	loop while hex_axial_distance(walker1_pos_new, type(0, 0)) > map_radius
	'walker1: random move, but within grid
	walker2_pos_old = walker2_pos_new
	do
		dim as integer walk_dir = int(rnd() * 6)
		walker2_pos_new = hex_neighbor(walker2_pos_old, walk_dir)
	loop while hex_distance(walker2_pos_new, type(0, 0, 0)) > map_radius
	'draw positions
	hex_draw_outline(layout, walker1_pos_old, &hffa050a0) 'darker pink
	hex_draw_outline(layout, walker1_pos_new, &hfff060f0) 'pink
	hex_draw_outline(layout, hex_cube_to_axial(walker2_pos_old), &hff50a0a0) 'darker cyan
	hex_draw_outline(layout, hex_cube_to_axial(walker2_pos_new), &hff60f0f0) 'cyan
	screenunlock
	sleep 100
wend

getkey()
