{
	local positionOffsetFromShip is import("util/positionOffsetFromShip").
	export({
		parameter x, y.
		local j is positionOffsetFromShip(x+5,y).
		return VCRS(positionOffsetFromShip(x-3,y-4) - j, positionOffsetFromShip(x-3,y+4) - j).
	}).
}