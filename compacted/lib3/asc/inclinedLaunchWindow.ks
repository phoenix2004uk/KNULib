export({
	parameter target_orbitable, ascent_time_mins is 3.
	local deltaLng is 0.
	local launchHeading is 90.
	local currentLng is BODY:rotationAngle + SHIP:geoPosition:LNG.
	local targetAN is target_orbitable:OBT:LAN.
	local targetDN is targetAN + 180.
	if targetAN < currentLng set targetAN to targetAN + 360.
	if targetDN < currentLng set targetDN to targetDN + 360.
	if targetAN < targetDN {
		set deltaLng to targetAN - currentLng.
		set launchHeading to 90-target_orbitable:OBT:inclination.
	}
	else {
		set deltaLng to targetDN - currentLng.
		set launchHeading to 90+target_orbitable:OBT:inclination.
	}
	local launchBodyRotationRate is 360 / BODY:rotationPeriod.
	return List((deltaLng - ascent_time_mins/2 * launchBodyRotationRate) / launchBodyRotationRate + TIME:seconds, launchHeading).
}).