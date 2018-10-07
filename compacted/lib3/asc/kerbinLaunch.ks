{
	local VSL is import("vessel").
	local constantTWR is import("sys/constantTWR").
	local burnout is import("sys/burnout").
	local autoStage is import("sys/autoStage").
	local safeStage is import("sys/safeStage").
	local changePe is import("sys/changePe").
	local circularize is import("sys/circularize").
	local execute is import("sys/execute").
	local setAlarm is import("util/setAlarm").
	local profileString is "launchProfile".
	local vslStagesString is "stages".
	function ascentThrottle {
		local pitch is 90 - VANG(UP:vector, SHIP:facing:vector).
		if pitch > 30 return constantTWR(1.7) / SIN(pitch).
		else return 1.
	}
	function headingTarget {
		parameter launchProfile, launchHeading is 90.
		local currentAltitude is ALTITUDE.
		if ALTITUDE > launchProfile["a1"] set currentAltitude to (ALTITUDE + APOAPSIS) / 2.
		local kB is BODY:ATM:height.
		if currentAltitude <= launchProfile["a0"] return launchProfile["p0"].
		if currentAltitude >= launchProfile["aN"] return launchProfile["pN"].
		local pitch is MIN(launchProfile["p0"], MAX(launchProfile["pN"], 85 * (LN(kB) - LN(currentAltitude)) / (LN(kB) - LN(launchProfile["a0"])) + 5)).
		if ALTITUDE > launchProfile["a0"] set pitch to min(pitch, 90 - VANG(UP:vector, srfPrograde:vector)).
		return HEADING(launchHeading, pitch) + R(0,0,-90 + MIN(90,MAX(0,90*(ALTITUDE-launchProfile["r0"])/launchProfile["rN"]))).
	}
	export({
		parameter targetAltitude is 100000, launchHeading is 90.
		if STATUS = "PRELAUNCH" {
			local launchProfile is Lex(
				"a0", 1000,
				"p0", 87.5,
				"aN", 60000,
				"pN", 0,
				"a1", 40000,
				"r0", 5000,
				"rN", 5000
			).
			if VSL:hasKey(profileString) for key in VSL[profileString]:keys set launchProfile[key] to VSL[profileString][key].
			lock STEERING to headingTarget(launchProfile, launchHeading).
			lock THROTTLE to ascentThrottle().
			until AVAILABLETHRUST > 0 safeStage().
			if STAGE:solidFuel > 0 {
				until burnout() set launchProfile["a0"] to ALTITUDE.
				safeStage().
			}
			until APOAPSIS >= targetAltitude if autoStage(VSL[vslStagesString]["lastAscent"]) lock THROTTLE to ascentThrottle().
			lock THROTTLE to 0.
		}
		until STAGE:number = VSL[vslStagesString]["insertion"] SafeStage().
		if PERIAPSIS < 10000 {
			wait until ALTITUDE > BODY:ATM:height.
			lock STEERING to VSL["orient"]().
			PANELS ON.
			LIGHTS ON.
			local burn is changePe(15000).
			set burn["node"]:eta to ETA:apoapsis - (burn["fullburn"] + 5).
			DeleteAlarm(burn["alarm"]:ID).
			setAlarm(TIME:seconds+burn["node"]:eta, "insertion", 0).
			execute().
		}
		until STAGE:number = VSL[vslStagesString]["orbital"] SafeStage().
		if PERIAPSIS < BODY:ATM:height {
			if ETA:apoapsis > ETA:periapsis {
				lock STEERING to PROGRADE.
				wait until VANG(SHIP:facing:vector, PROGRADE:vector) < 1.
				lock THROTTLE to 1.
				wait until PERIAPSIS > BODY:ATM:height.
				lock THROTTLE to 0.
				lock STEERING to VSL["orient"]().
			}
			circularize("Ap").
			execute().
		}
	}).
}