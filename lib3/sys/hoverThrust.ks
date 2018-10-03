export({
	parameter relativeVelocity IS 0.
	IF SHIP:availableThrust = 0 return 0.
	local ga is BODY:MU / (BODY:RADIUS + ALTITUDE)^2.
	return MAX(0, MIN(1, SHIP:mass*(ga+relativeVelocity-SHIP:verticalSpeed)/(SHIP:availableThrust*COS(VANG(UP:vector,SHIP:facing:foreVector))))).
}).