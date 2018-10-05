export({
	parameter orientation.
	if orientation:isType("Direction") set orientation to orientation:vector.
	return VANG(FACING:vector,orientation) < 1.
}).