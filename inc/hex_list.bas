'------------------------- a simple hex <vextor> class -------------------------

type hex_list
	private:
	dim as hex_cube h(any)
	public:
	declare function push(h as hex_cube) as integer
	declare function pop() as hex_cube
	declare function get_(index as integer) as hex_cube
	declare sub del_()
	declare function size() as integer
	declare function last_index() as integer
end type

'add to end of list
function hex_list.push(h_ as hex_cube) as integer
	dim as integer ub = ubound(h) + 1
	redim preserve h(ub)
	h(ub) = h_
	return ub
end function

'remove from end of list
function hex_list.pop() as hex_cube
	dim as hex_cube h_
	dim as integer ub = ubound(h)
	if ub >= 0 then
		h_ = h(ub)
		if ub = 0 then
			erase h
		else
			redim preserve h(ub - 1)
		end if
	end if
	return h_
end function

function hex_list.get_(index as integer) as hex_cube
	return h(index)
end function

sub hex_list.del_()
	erase(h)
end sub

function hex_list.size() as integer
	return ubound(h) + 1
end function

function hex_list.last_index() as integer
	return ubound(h)
end function

'-------------------------------- test hex_list --------------------------------

'~ dim as hex_cube h = type(1,2,3)
'~ dim as hex_list hl
'~ print hl.size()
'~ hl.push(h)
'~ hl.push(h)
'~ h = type(5,6,7)
'~ hl.push(h)
'~ h = type(0,0,0)
'~ print hl.size()
'~ print hl.last_index()
'~ for i as integer = 0 to hl.last_index()
	'~ h = hl.pop()
	'~ print h.x, h.y, h.z
'~ next
'~ print hl.size()
'~ print hl.last_index()

'~ 'Test hex_line
'~ dim as hex_cube a = type(1,4,6)
'~ dim as hex_cube b = type(-3,6,-2)
'~ dim as hex_cube c
'~ dim as hex_list list = hex_line(a, b)
'~ for i as integer = 0 to list.last_index()
	'~ c = list.pop()
	'~ print c.x, c.y, c.z
'~ next

