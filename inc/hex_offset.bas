'---------------------------- offset coordinates -------------------------------

type hex_offset
	dim as integer row_, col_
end type

'odd-r: for pointy tops, shoves odd row_s by +½ col_umn
function hex_cube_to_oddr(hc as hex_cube) as hex_offset
	return type(hc.x + (hc.z - (hc.z and 1)) \ 2, hc.z)
end function

function hex_oddr_to_cube(ho as hex_offset) as hex_cube
	dim as integer x = ho.col_ - (ho.row_ - (ho.row_ and 1)) \ 2
	dim as integer z = ho.row_
	dim as integer y = -(x + z)
	return type(x, y, z)
end function

'even-r: for pointy tops, shoves even row_s by +½ col_umn
function hex_cube_to_evenr(hc as hex_cube) as hex_offset
	return type(hc.x + (hc.z + (hc.z and 1)) \ 2, hc.z)
end function

function hex_evenr_to_cube(ho as hex_offset) as hex_cube
	dim as integer x = ho.col_ - (ho.row_ + (ho.row_ and 1)) \ 2
	dim as integer z = ho.row_
	dim as integer y = -(x + z)
	return type(x, y, z)
end function

'odd-q: for flat tops, shoves odd col_umns by +½ row_
function hex_cube_to_oddq(hc as hex_cube) as hex_offset
	return type(hc.x, hc.z + (hc.x - (hc.x and 1)) \ 2)
end function

function hex_oddq_to_cube(ho as hex_offset) as hex_cube
	dim as integer x = ho.col_
	dim as integer z = ho.row_ - (ho.col_ - (ho.col_ and 1)) \ 2
	dim as integer y = -(x + z)
	return type(x, y, z)
end function

'even-q: shoves even col_umns by +½ row_
function hex_cube_to_evenq(hc as hex_cube) as hex_offset
	return type(hc.x, hc.z + (hc.x + (hc.x and 1)) \ 2)
end function

function hex_evenq_to_cube(ho as hex_offset) as hex_cube
	dim as integer x = ho.col_
	dim as integer z = ho.row_ - (ho.col_ + (ho.col_ and 1)) \ 2
	dim as integer y = -(x + z)
	return type(x, y, z)
end function
