export({
	PARAMETER altitudeMargin.
	LOCAL g0 IS BODY:MU / (BODY:RADIUS+ALTITUDE)^2.
	RETURN (SQRT(VERTICALSPEED^2 + 2*g0*Max(0,ALT:RADAR - altitudeMargin)) + VERTICALSPEED) / g0.
}).