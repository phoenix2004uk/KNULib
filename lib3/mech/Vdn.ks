// True Anomaly (V) of DN
export({
	local w is ship:obt:argumentOfPeriapsis.
	if ship:obt:inclination < 0 set w to w+180.
	return mod(540 - w,360).
}).