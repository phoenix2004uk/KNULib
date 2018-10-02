{

	local VSL is import("vessel").
	local SYS is bundle(List("sys/constantTWR","sys/burnout","sys/autoStage","sys/safeStage")).
	local MNV is bundle(List("mnv/changePe","mnv/circularize","mnv/execute")).

	export({
		parameter targetAltitude is 100000, launchHeading is 90, profileName is "".

		if profileName="" set profileName to VSL["launchProfile"].
		set launchProfile to import("asc/" + profileName + "Profile").
		set headingTarget to import("asc/" + profileName + "Heading").

		local twr is 9.
		if VSL:hasKey("launchTWR") set twr to VSL["launchTWR"].
		else if launchProfile:hasKey("twr") set twr to launchProfile["twr"].

		// launch
		lock STEERING to headingTarget(launchProfile, launchHeading).
		lock THROTTLE to SYS["constantTWR"](twr).
		until AVAILABLETHRUST > 0 SYS["safeStage"]().

		// ascent with boosters
		if STAGE:solidFuel > 0 {
			until SYS["burnout"]() {
				set launchProfile["a0"] to ALTITUDE.
			}
			SYS["safeStage"]().
		}

		// normal ascent
		until APOAPSIS >= targetAltitude {
			if SYS["autoStage"](VSL["stages"]["lastAscent"]).
				lock THROTTLE to SYS["constantTWR"](twr).
			wait 0.01.
		}
		lock THROTTLE to 0.

		// drop ascent stage (if any)
		until STAGE:number = VSL["stages"]["insertion"]
			SYS["SafeStage"]().

		// coast to edge of atmosphere
		wait until ALTITUDE > BODY:ATM:height.

		lock STEERING to VSL["orient"]().
		PANELS ON.
		LIGHTS ON.

		// perform insertion by raising periapsis to 15km
		local burn is MNV["changePe"](15000).
		// fudge the burn time so we end the burn before apoapsis with some extra spare time (5 seconds?)
		set burn["node"]:eta to ETA:apoapsis - (burn["fullburn"] + 5).
		DeleteAlarm(burn["alarm"]:ID).

		// execute insertion burn
		MNV["execute"]().

		// drop insertion stage (if any)
		until STAGE:number = VSL["stages"]["orbital"]
			SYS["SafeStage"]().

		// if we passed apoapsis, just raise Pe above atmosphere
		if ETA:apoapsis > ETA:periapsis {
			lock STEERING to PROGRADE.
			wait until VANG(SHIP:facing:vector, PROGRADE:vector) < 1.
			lock THROTTLE to 1.
			wait until PERIAPSIS > BODY:ATM:height.
			lock THROTTLE to 0.
			lock STEERING to VSL["orient"]().
		}

		// circularize at apoapsis
		MNV["circularize"]("Ap").
		MNV["execute"]().
	}).
}