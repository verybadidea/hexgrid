'------------------------ a simple point <vextor> class ------------------------

type pt_dbl
	dim as double x, y
end type

type pt_list
	private:
	dim as pt_dbl pt(any)
	public:
	declare function push(pt_ as pt_dbl) as integer
	declare function pop() as pt_dbl
	declare sub del_()
	declare function size() as integer
	declare function last_index() as integer
end type

'add to end of list
function pt_list.push(pt_ as pt_dbl) as integer
	dim as integer ub = ubound(pt) + 1
	redim preserve pt(ub)
	pt(ub) = pt_
	return ub
end function

'remove from end of list
function pt_list.pop() as pt_dbl
	dim as pt_dbl pt_
	dim as integer ub = ubound(pt)
	if ub >= 0 then
		pt_ = pt(ub)
		if ub = 0 then
			erase pt
		else
			redim preserve pt(ub - 1)
		end if
	end if
	return pt_
end function

sub pt_list.del_()
	erase(pt)
end sub

function pt_list.size() as integer
	return ubound(pt) + 1
end function

function pt_list.last_index() as integer
	return ubound(pt)
end function
