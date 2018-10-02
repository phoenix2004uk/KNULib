// True Anomaly (V) of AN
export({
	local w is ship:obt:argumentOfPeriapsis.
	if ship:obt:inclination < 0 set w to w+180.
	return mod(360 - w,360).
}).