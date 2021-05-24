'---------------------------- hex cube coordinates -----------------------------

type hex_cube
	dim as integer x 'pointing right/up
	dim as integer y 'pointing left/up
	dim as integer z 'pointing down
	declare operator cast () as string
end type

operator hex_cube.cast() as string
	return "(x: " & x & ", y: " & y & ", z: " & z & ")"
end operator

function hex_equal(a as hex_cube, b as hex_cube) as boolean
	if a.x <> b.x then return false
	if a.y <> b.y then return false
	if a.z <> b.z then return false
	return true
end function

function hex_add(a as hex_cube, b as hex_cube) as hex_cube
	return type(a.x + b.x, a.y + b.y, a.z + b.z)
end function

function hex_substract(a as hex_cube, b as hex_cube) as hex_cube
	return type(a.x - b.x, a.y - b.y, a.z - b.z)
end function

dim shared as const hex_cube hex_cube_direction(0 to 5) = {_
	type(+1, -1, 0), type(+1, 0, -1), type(0, +1, -1), _
	type(-1, +1, 0), type(-1, 0, +1), type(0, -1, +1) }

function hex_neighbor(hc as hex_cube, direction as integer) as hex_cube
	return hex_add(hc, cast(hex_cube, hex_cube_direction(direction)))
end function

dim shared as const hex_cube hex_cube_diagonal(0 to 5) = {_
	type(+2, -1, -1), type(+1, +1, -2), type(-1, +2, -1), _
	type(-2, +1, +1), type(-1, -1, +2), type(+1, -2, +1) }

function hex_neighbor_diagonal(hc as hex_cube, direction as integer) as hex_cube
	return hex_add(hc, cast(hex_cube, hex_cube_diagonal(direction)))
end function

function hex_distance(a as hex_cube, b as hex_cube) as integer
	return (abs(a.x - b.x) + abs(a.y - b.y) + abs(a.z - b.z)) \ 2
end function
'Note: cube_distance also possible with max(dx, dy, dx)

'60° rotation
function hex_rotate_left(a as hex_cube) as hex_cube
	'return type(-a.z, -a.x, -a.y)
	return type(-a.y, -a.z, -a.x)
end function

function hex_rotate_right(a as hex_cube) as hex_cube
	'return type(-a.y, -a.z, -a.x)
	return type(-a.z, -a.x, -a.y)
end function

'For 60° rotation around other hex: translate, rotate, translate back: TODO
'Use add and substract for translation

'Reflection
function hex_reflect_x(h as hex_cube) as hex_cube
	return type(h.x, h.z, h.y)
end function

function hex_reflect_y(h as hex_cube) as hex_cube
	return type(h.z, h.y, h.x)
end function

function hex_reflect_z(h as hex_cube) as hex_cube
	return type(h.y, h.x, h.z)
end function
