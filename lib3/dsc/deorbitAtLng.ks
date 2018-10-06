{
	local maneuverTime is import("mnv/maneuverTime").
	local setAlarm is import("util/setAlarm").

	// TODO: Enhancement - re-calculate for non-circular orbits
	// TODO: TEST retrograde orbits (inc > 90)
	export({
		parameter targetLng, margin is 60.

		local isRetrogradeOrbit is SHIP:OBT:inclination > 90.

		local currentLng is SHIP:longitude.
		local n is 360 / SHIP:OBT:period.
		local siderealRate is 360 / BODY:rotationPeriod.
		local shipLngPerSec is n * cos(SHIP:OBT:inclination).
		// if we are orbiting retrograde, siderealRate works in our favour
		if isRetrogradeOrbit {
			set shipLngPerSec to shipLngPerSec + siderealRate.
		}
		// otherwise it works against us
		else set shipLngPerSec to shipLngPerSec - siderealRate.

		local deltaLng is targetLng - currentLng.
		// if we are orbiting retrograde, modify our deltaLng as we are travelling backwards
		if isRetrogradeOrbit {
			set deltaLng to 360 - deltaLng.
		}
		local etaToLng is deltaLng / shipLngPerSec.
		local nodeTime is TIME:seconds + etaToLng.

		//local srfSpeed is 2*CONSTANT:PI*BODY:radius / siderealRate.
		local dv is velocityAt(SHIP, nodeTime):surface:mag.

		local halfBurnDuration is maneuverTime(dv / 2).
		local fullBurnDuration is maneuverTime(dv).
		if etaToLng < halfBurnDuration {
			set nodeTime to nodeTime + 360 / shipLngPerSec.
		}
		local alarm is setAlarm(nodeTime - halfBurnDuration, "begin descent " + round(targetLng,2), margin).
		local mnv is NODE(nodeTime, 0, 0, -dv).
		ADD mnv.

		return Lex("node",mnv,"preburn",halfBurnDuration,"fullburn",fullBurnDuration,"alarm",alarm,"throttle",1).
	}).
}