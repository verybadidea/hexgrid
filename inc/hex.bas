'https://www.redblobgames.com/grids/hexagons
'https://www.redblobgames.com/grids/hexagons/implementation.html

'-------------------------------------------------------------------------------

#define sqrt sqr
#define max(a, b) (iif((a) > (b), (a), (b)))
#define min(a, b) (iif((a) < (b), (a), (b)))
#define limit(v, v_min, v_max) (min(max((v), (v_min)), (v_max)))
#define lerp(a, b, t) ((a) + ((b) - (a)) * t) 'linearly interpolation
#define M_PI (atn(1) * 4)

#include "hex_cube.bas"
#include "hex_axial.bas"
#include "hex_list.bas"
#include "pt_dbl_list.bas"
#include "hex_offset.bas"

'--------------------------- coordinate conversion -----------------------------

function hex_cube_to_axial(hc as hex_cube) as hex_axial
	return type(hc.x, hc.z) 'ignore y
end function

function hex_axial_to_cube(ha as hex_axial) as hex_cube
	'return type(ha.q, ha.r, -(ha.q + ha.r))
	return type(ha.q, -(ha.q + ha.r), ha.r)
end function

'------------------------------- axial rotation --------------------------------

sub hex_axial_rotate_right(byref ha as hex_axial)
	ha = hex_cube_to_axial(hex_rotate_right(hex_axial_to_cube(ha)))
end sub

sub hex_axial_rotate_left(byref ha as hex_axial)
	ha = hex_cube_to_axial(hex_rotate_left(hex_axial_to_cube(ha)))
end sub

'--------------------------------- hex layout ----------------------------------

type hex_orientation
	dim as const double f0, f1, f2, f3
	dim as const double b0, b1, b2, b3
	dim as const double start_angle 'in multiples of 60°
end type

dim shared as const hex_orientation layout_pointy = type( _
	sqrt(3),   sqrt(3)/2, 0, 3/2, _
	sqrt(3)/3, -1/3,      0, 2/3, _
	0.5)

dim shared as const hex_orientation layout_flat = type( _
	3/2, 0, sqrt(3)/2, sqrt(3), _
	2/3, 0, -1/3,      sqrt(3)/3, _
	0.0)

type hex_layout
	dim as const hex_orientation orientation
	dim as const pt_dbl size 'distance from origin to a corner
	dim as const pt_dbl origin
end type

'Hex to Pixel
function hex_to_pixel(layout as hex_layout, h as hex_axial) as pt_dbl
	dim byref as const hex_orientation M = layout.orientation
	dim as double x = (M.f0 * h.q + M.f1 * h.r) * layout.size.x
	dim as double y = (M.f2 * h.q + M.f3 * h.r) * layout.size.y
	return type(x + layout.origin.x, y + layout.origin.y)
end function

type hex_cube_frac
    dim as double x, y, z
end type

'hex cube rounding
function hex_round(h as hex_cube_frac) as hex_cube
	dim as integer x = cint(h.x) 'is this right?
	dim as integer y = cint(h.y)
	dim as integer z = cint(h.z)
	dim as double x_diff = abs(x - h.x) 'q
	dim as double y_diff = abs(y - h.y) 'r
	dim as double z_diff = abs(z - h.z) 's
	if (x_diff > y_diff) and (x_diff > z_diff) then
		x = -(y + z)
	elseif (y_diff > z_diff) then
		y = -(x + z)
	else
		z = -(x + y)
	end if
	return type(x, y, z)
end function

'Pixel to Hex (integer cube coordinates)
function pixel_to_hex_int(layout as hex_layout, p as pt_dbl) as hex_cube
	dim byref as const hex_orientation M = layout.orientation
	dim as pt_dbl pt = type(_
		(p.x - layout.origin.x) / layout.size.x, _
		(p.y - layout.origin.y) / layout.size.y)
	dim as double q = M.b0 * pt.x + M.b1 * pt.y
	dim as double r = M.b2 * pt.x + M.b3 * pt.y
	return hex_round(type(q, -(q + r), r)) 'x,y,z
end function

function hex_lerp(a as hex_cube, b as hex_cube, t as double) as hex_cube_frac
	return type(lerp(a.x, b.x, t), lerp(a.y, b.y, t), lerp(a.z, b.z, t))
end function

'return list of hex (with cube coordinates)
function hex_line_list(a as hex_cube, b as hex_cube) as hex_list
	dim as integer N = hex_distance(a, b)
	dim as hex_list hexes
	dim as double dist_step = 1.0 / max(N, 1)
	for i as integer = 0 to N
		hexes.push(hex_round(hex_lerp(a, b, dist_step * i)))
	next
	return hexes
end function

'relative corner position from hexagon center
'note: for speed, the corner positions can be precalculated (after setting size)
function hex_corner_offset(layout as hex_layout, corner as integer) as pt_dbl
	dim as pt_dbl size = layout.size
	size.x *= 0.85
	size.y *= 0.85
	dim as double angle = 2.0 * M_PI * (layout.orientation.start_angle + corner) / 6
	return type(size.x * cos(angle), size.y * sin(angle))
end function

'a bit complex way to make an array of 6 points
function hex_corner_list(layout as hex_layout, h as hex_axial) as pt_list
	dim as pt_list corners
	dim as pt_dbl center = hex_to_pixel(layout, h)
	for i as integer = 0 to 5 'loop 6 corners (clockwise)
		dim as pt_dbl offset = hex_corner_offset(layout, i)
		corners.push(type(center.x + offset.x, center.y + offset.y))
	next
	return corners
end function

sub hex_draw_outline(layout as hex_layout, h as hex_axial, c as ulong)
	dim as pt_list corners = hex_corner_list(layout, h)
	dim as pt_dbl first = corners.pop() 'save for last loop
	dim as pt_dbl b = first
	for i as integer = 0 to 5
		dim as pt_dbl a = b
		b = iif(i = 5, first, corners.pop())
		line(a.x, a.y)-(b.x, b.y), c
	next
end sub

sub draw_triangle_filled(pt1 as pt_dbl, pt2 as pt_dbl, pt3 as pt_dbl, c as ulong)
	dim as integer x, y, xmid
	dim as double x1, x2
	dim as double dx12, dx13, dx23
	'order top to bottom
	if (pt1.y > pt2.y) then swap pt1, pt2
	if (pt1.y > pt3.y) then swap pt1, pt3
	if (pt2.y > pt3.y) then swap pt2, pt3
	'calculate line slopes
	dx12 = (pt2.x - pt1.x) / (pt2.y - pt1.y)
	dx13 = (pt3.x - pt1.x) / (pt3.y - pt1.y)
	dx23 = (pt3.x - pt2.x) / (pt3.y - pt2.y)
	'Upper half triangle
	x1 = pt1.x
	x2 = pt1.x
	for y = pt1.y to pt2.y - 1
		line (x1, y)-(x2, y), c
		x1 += dx12
		x2 += dx13
	next
	'lower half triangle
	x1 = pt2.x' + dx23 / 2
	for y = pt2.y to pt3.y
		line (x1, y)-(x2, y), c
		x1 += dx23
		x2 += dx13
	next
	'make edges nice (optional)
	'line (pt1.x, pt1.y)-(pt2.x, pt2.y), c
	'line (pt2.x, pt2.y)-(pt3.x, pt3.y), c
	'line (pt3.x, pt3.y)-(pt1.x, pt1.y), c
end sub 

sub hex_draw_filled(layout as hex_layout, h as hex_axial, c_fill as ulong) 
	dim as pt_dbl center = hex_to_pixel(layout, h)
	'create + fill array with 6 conners positions
	dim as pt_dbl corner(0 to 5)
	for i as integer = 0 to 5 'loop 6 corners (clockwise)
		dim as pt_dbl offset = hex_corner_offset(layout, i)
		corner(i) = type(center.x + offset.x, center.y + offset.y)
	next
	select case layout.orientation.start_angle
	case 0.0 'flat top
		line(corner(4).x, corner(4).y)-(corner(1).x, corner(1).y), c_fill, bf
		draw_triangle_filled(corner(0), corner(1), corner(5), c_fill)
		draw_triangle_filled(corner(2), corner(3), corner(4), c_fill)
	case 0.5 'pointy top
		line(corner(3).x, corner(3).y)-(corner(0).x, corner(0).y), c_fill, bf
		draw_triangle_filled(corner(0), corner(1), corner(2), c_fill)
		draw_triangle_filled(corner(3), corner(4), corner(5), c_fill)
	end select
end sub

sub hex_draw_filled_border(layout as hex_layout, h as hex_axial, c_fill as ulong, c_border as ulong)
	dim as pt_dbl center = hex_to_pixel(layout, h)
	'create + fill array with 6 conners positions
	dim as pt_dbl corner(0 to 5)
	for i as integer = 0 to 5 'loop 6 corners (clockwise)
		dim as pt_dbl offset = hex_corner_offset(layout, i)
		corner(i) = type(center.x + offset.x, center.y + offset.y)
	next
	select case layout.orientation.start_angle
	case 0.0 'flat top
		line(corner(4).x, corner(4).y)-(corner(1).x, corner(1).y), c_fill, bf
		draw_triangle_filled(corner(0), corner(1), corner(5), c_fill)
		draw_triangle_filled(corner(2), corner(3), corner(4), c_fill)
	case 0.5 'pointy top
		line(corner(3).x, corner(3).y)-(corner(0).x, corner(0).y), c_fill, bf
		draw_triangle_filled(corner(0), corner(1), corner(2), c_fill)
		draw_triangle_filled(corner(3), corner(4), corner(5), c_fill)
	end select
	hex_draw_outline(layout, h, c_border)
end sub

#define hex_draw_o	hex_draw_outline
#define hex_draw_f	hex_draw_filled
#define hex_draw_fb	hex_draw_filled_border
