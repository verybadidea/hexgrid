#include "inc/hex.bas"

TODO

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
				if map(q, r) <> 0 then hex_draw_filled(layout1, ha, &hffa00000)
				'dim as integer i = hex_dis
				hex_draw_outline(layout1, ha, &hff404040)
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

'~ Obstacles#
'~ If there are obstacles, the simplest thing to do is a distance-limited flood
'~ fill (breadth first search). In this diagram, the limit is set to moves. In
'~ the code, fringes[k] is an array of all hexes that can be reached in k steps.
'~ Each time through the main loop, we expand level k-1 into level k. This works
'~ equally well with any of the hex coordinate systems (cube, axial, offset, doubled).

'~ function hex_reachable(start, movement):
    '~ var visited = set() # set of hexes
    '~ add start to visited
    '~ var fringes = [] # array of arrays of hexes
    '~ fringes.append([start])

    '~ for each 1 < k ≤ movement:
        '~ fringes.append([])
        '~ for each hex in fringes[k-1]:
            '~ for each 0 ≤ dir < 6:
                '~ var neighbor = hex_neighbor(hex, dir)
                '~ if neighbor not in visited and not blocked:
                    '~ add neighbor to visited
                    '~ fringes[k].append(neighbor)

    '~ return visited
