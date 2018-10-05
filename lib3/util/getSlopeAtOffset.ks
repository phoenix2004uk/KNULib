{
	local positionOffsetFromShip is import("util/positionOffsetFromShip").
	export({
		parameter x, y.
		local j is positionOffsetFromShip(x+5,y).
		local k is positionOffsetFromShip(x-3,y+4).
		local l is positionOffsetFromShip(x-3,y-4).
		return VCRS(l - j, k - j).
	}).
}