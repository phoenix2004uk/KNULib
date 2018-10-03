export({
	parameter x, y.
	local east is VCRS(NORTH:vector, UP:vector).
	return BODY:geoPositionOf(SHIP:position + x*NORTH:vector + y*east).
}).