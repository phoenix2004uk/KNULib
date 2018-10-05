export({
	parameter altitudeMargin.
	local g0 is BODY:MU / (BODY:RADIUS+ALTITUDE)^2.
	return (SQRT(VERTICALSPEED^2 + 2*g0*Max(0,ALT:RADAR - altitudeMargin)) + VERTICALSPEED) / g0.
}).