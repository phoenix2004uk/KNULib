export({
	parameter x, y.
	return BODY:geoPositionOf(x*NORTH:vector + y*VCRS(NORTH:vector, UP:vector)).
}).