{
	local VSL is import("vessel").
	local SYS is bundle(List("sys/constantTWR","sys/burnout","sys/autoStage","sys/safeStage")).
	local MNV is bundle(List("mnv/changePe","mnv/circularize","mnv/execute")).
	local setAlarm is import("util/setAlarm").

//	function ratioPitchTarget {
//		parameter launchProfile.
//		local currentAltitude is ALTITUDE.
//		local currentSpeed is VELOCITY:surface:mag.
//		if ALTITUDE > launchProfile["a1"] {
//			set currentAltitude to ALT:apoapsis.
//			set currentSpeed to VELOCITY:orbit:mag.
//		}
//		if currentAltitude <= launchProfile["a0"] return launchProfile["p0"].
//		if currentAltitude >= launchProfile["aN"] return launchProfile["pN"].
//
//		local alt_ratio is (currentAltitude - launchProfile["a0"]) / launchProfile["aN"].
//		local targetSpeed is SQRT(BODY:mu / (launchProfile["a1"]+BODY:radius)).
//		local speed_ratio is currentSpeed / targetSpeed.
//		local current_ratio is MIN(alt_ratio, speed_ratio).
//
//		local profileFactor is 0.35.
//
//		return MIN(launchProfile["p0"], MAX(launchProfile["pN"], 90 - current_ratio^profileFactor * 90)).
//	}

	function ascentThrottle {
		local twr is 1.7.
		local pitch is 90 - VANG(UP:vector, SHIP:facing:vector).
		if pitch > 30
			return SYS["constantTWR"](twr) / SIN(pitch).
		else return 1.
	}
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
	function headingTarget {
		parameter launchProfile, launchHeading is 90.

		local pitch is pitchTarget(launchProfile).
		if ALTITUDE > launchProfile["a0"] {
			local srfProgradeAngle is VANG(UP:vector, srfPrograde:vector).
			set pitch to min(pitch, 90 - srfProgradeAngle).
		}
		local roll is rollTarget(launchProfile).

		return HEADING(launchHeading, pitch) + R(0,0,roll).
	}
	local defaultProfile is Lex(
		"a0", 1000,
		"p0", 87.5,
		"aN", 60000,
		"pN", 0,
		"a1", 40000,
		"r0", 5000,
		"rN", 5000
	).

	export({
		parameter targetAltitude is 100000, launchHeading is 90.

		if STATUS = "PRELAUNCH" {
			local launchProfile is defaultProfile:copy.
			if VSL:hasKey("launchProfile") {
				for key in VSL["launchProfile"]:keys {
					set launchProfile[key] to VSL["launchProfile"][key].
				}
			}

			// launch
			lock STEERING to headingTarget(launchProfile, launchHeading).
			lock THROTTLE to ascentThrottle(). // SYS["constantTWR"](twr).
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
					lock THROTTLE to ascentThrottle(). // SYS["constantTWR"](twr).
			}
			lock THROTTLE to 0.

			// drop ascent stage (if any)
			until STAGE:number = VSL["stages"]["insertion"]
				SYS["SafeStage"]().

			// coast to edge of atmosphere
			wait until ALTITUDE > BODY:ATM:height.
		}

		if PERIAPSIS < 10000 {
			lock STEERING to VSL["orient"]().
			PANELS ON.
			LIGHTS ON.

			// perform insertion by raising periapsis to 15km
			local burn is MNV["changePe"](15000).
			// fudge the burn time so we end the burn before apoapsis with some extra spare time (5 seconds?)
			set burn["node"]:eta to ETA:apoapsis - (burn["fullburn"] + 5).
			DeleteAlarm(burn["alarm"]:ID).
			setAlarm(TIME:seconds+burn["node"]:eta, "insertion", 0).

			// execute insertion burn
			MNV["execute"]().
		}

		// drop insertion stage (if any)
		until STAGE:number = VSL["stages"]["orbital"]
			SYS["SafeStage"]().

		if PERIAPSIS < BODY:ATM:height {
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
		}
	}).
}