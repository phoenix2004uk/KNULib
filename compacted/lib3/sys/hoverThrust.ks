export({
	parameter relativeVelocity IS 0.
	IF AVAILABLETHRUST = 0 return 0.
	return MAX(0, MIN(1, MASS * (BODY:MU / (BODY:RADIUS + ALTITUDE)^2 + relativeVelocity - VERTICALSPEED) / (AVAILABLETHRUST * COS(VANG(UP:vector,FACING:foreVector))))).
}).