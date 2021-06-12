'--------------------------- hex axial coordinates -----------------------------

type hex_axial
	dim as integer q 'pointing right/up
	dim as integer r 'pointing down
	declare operator cast () as string
end type

operator hex_axial.cast() as string
	return "(q: " & q & ", r: " & r & ")"
end operator

operator = (a as hex_axial, b as hex_axial) as boolean
	if a.q <> b.q then return false
	if a.r <> b.r then return false
	return true
end operator

operator <> (a as hex_axial, b as hex_axial) as boolean
	if a.q = b.q and a.r = b.r then return false
	return true
end operator

function hex_axial_add(a as hex_axial, b as hex_axial) as hex_axial
	return type(a.q + b.q, a.r + b.r)
end function

function hex_axial_substract(a as hex_axial, b as hex_axial) as hex_axial
	return type(a.q - b.q, a.r - b.r)
end function

const HEX_AX_RI_DN = 0
const HEX_AX_RI_UP = 1
const HEX_AX_UP = 2
const HEX_AX_LE_UP = 3
const HEX_AX_LE_DN = 4
const HEX_AX_DN = 5

dim shared as const hex_axial hex_axial_direction(0 to 5) = {_
	type(+1, 0), type(+1, -1), type(0, -1), _
	type(-1, 0), type(-1, +1), type(0, +1) }

function hex_axial_neighbor(ha as hex_axial, direction as integer) as hex_axial
	return hex_axial_add(ha, cast(hex_axial, hex_axial_direction(direction)))
end function

function hex_axial_distance(a as hex_axial, b as hex_axial) as integer
    return (abs(a.q - b.q) + abs(a.q + a.r - b.q - b.r) + abs(a.r - b.r)) \ 2
end function
'Note: Or convert to hex_cube first
