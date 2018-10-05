export({
	local w is OBT:argumentOfPeriapsis.
	if OBT:inclination < 0 set w to w+180.
	return mod(360 - w,360).
}).