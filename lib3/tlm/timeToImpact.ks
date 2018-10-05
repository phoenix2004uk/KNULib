export({
	parameter altitudeMargin.

	// assume g is g0{body}
	local g0 is BODY:MU / (BODY:RADIUS+ALTITUDE)^2.
	local u is SHIP:VERTICALSPEED.
	local d is Max(0,ALT:RADAR - altitudeMargin).

	// d = u * t + 1/2*g*t^2
	// (g/2)t^2 + (u)t - d =0
	// ax^2 + bx +c = 0
	// x = (-b +- sqrt( b^2 - 4ac )) / 2a
	// t = (-u +- sqrt( u^2 - 4*g/2*-d )) / 2*g/2
	// t = (-u +- sqrt( u^2 + 2g*d)) / g
	// we only want positive time, so
	// t = (sqrt(u^2 + 2g*d) - u) / g

	// WHEN TTI <= MNV_TIME(SHIP:VERTICALSPEED) BURN AT FULL THROTTLE

	return (SQRT(u^2 + 2*g0*d) + u) / g0.
}).