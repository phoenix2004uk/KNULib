// returns a List(launchTime, launchHeading) to launch into the plane of a target orbitable
// ascent_time_mins: how long (in mins) to get into orbit - used to offset the launchTime
export({
	parameter target_orbitable, ascent_time_mins is 3.

	local deltaLng is 0.
	local launchHeading is 90.
	local currentLng is BODY:rotationAngle + SHIP:geoPosition:LNG.
	local targetAN is target_orbitable:OBT:LAN.
	local targetDN is targetAN + 180.

	// make sure AN/DN are ahead of us
	if targetAN < currentLng set targetAN to targetAN + 360.
	if targetDN < currentLng set targetDN to targetDN + 360.

	// use whichever node is closer
	if targetAN < targetDN {
		set deltaLng to targetAN - currentLng.
		set launchHeading to 90-target_orbitable:OBT:inclination.
	}
	else {
		set deltaLng to targetDN - currentLng.
		set launchHeading to 90+target_orbitable:OBT:inclination.
	}

	// take into account launch body rotation during ascent
	local launchBodyRotationRate is 360 / BODY:rotationPeriod.
	set deltaLng to deltaLng - ascent_time_mins/2 * launchBodyRotationRate.

	// how long till the launch window
	local waitTime is deltaLng / launchBodyRotationRate.

	return List(waitTime + TIME:seconds, launchHeading).
}).