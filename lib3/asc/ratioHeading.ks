{
	function pitchTarget {
		parameter launchProfile.
		local currentAltitude is ALTITUDE.
		local currentSpeed is VELOCITY:surface:mag.
		if ALTITUDE > launchProfile["a1"] {
			set currentAltitude to ALT:apoapsis.
			set currentSpeed to VELOCITY:orbit:mag.
		}
		if currentAltitude <= launchProfile["a0"] return launchProfile["p0"].
		if currentAltitude >= launchProfile["aN"] return launchProfile["pN"].

		local alt_ratio is (currentAltitude - launchProfile["a0"]) / launchProfile["aN"].
		local targetSpeed is SQRT(BODY:mu / (launchProfile["a1"]+BODY:radius)).
		local speed_ratio is currentSpeed / targetSpeed.
		local current_ratio is MIN(alt_ratio, speed_ratio).

		return MIN(launchProfile["p0"], MAX(launchProfile["pN"], 90 - current_ratio^launchProfile["f"] * 90)).
	}
	function rollTarget {
		parameter launchProfile.
		return -90 + MIN(90,MAX(0,90*(ALTITUDE-launchProfile["r0"])/launchProfile["rN"])).
	}
	export({
		parameter launchProfile, launchHeading is 90.
		return HEADING(launchHeading, pitchTarget(launchProfile)) + R(0,0,rollTarget(launchProfile)).
	}).
}