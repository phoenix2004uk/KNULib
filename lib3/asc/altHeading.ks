{
	function pitchTarget {
		parameter launchProfile.
		local currentAltitude is ALTITUDE.
		if ALTITUDE > launchProfile["a1"] set currentAltitude to (ALTITUDE + ALT:apoapsis) / 2.
		local kA is 85.
		local kB is BODY:ATM:height.
		local kC is 5.
		if currentAltitude <= launchProfile["a0"] return launchProfile["p0"].
		if currentAltitude >= launchProfile["aN"] return launchProfile["pN"].
		return MIN(launchProfile["p0"], MAX(launchProfile["pN"], kA * (LN(kB) - LN(currentAltitude)) / (LN(kB) - LN(launchProfile["a0"])) + kC)).
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