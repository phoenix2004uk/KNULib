export({
	parameter twr.
	local F is SHIP:availableThrust * 1000.
	if F = 0 return 0.
	local g1 is BODY:mu / (BODY:radius+ALTITUDE)^2.
	local maxTWR is F / (SHIP:mass * 1000 * g1).
	return max(0,min(1,twr / maxTWR)).
}).