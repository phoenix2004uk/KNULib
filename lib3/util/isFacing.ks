export({
	parameter orientation.
	if orientation:isType("Direction") set orientation to orientation:vector.
	return VANG(SHIP:facing:vector,orientation) > 1.
}).