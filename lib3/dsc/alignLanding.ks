{
	local maneuverTime is import("mnv/maneuverTime").
	local setAlarm is import("util/setAlarm").
	local degmod is import("util/degmod").
	local VisViva is import("mech/VisViva").

	// TODO: Enhancement - re-calculate for non-circular orbits
	// TODO: TEST retrograde orbits (inc > 90)
	export({
		parameter geoCoords, margin is 60.

		local isRetrogradeOrbit is SHIP:OBT:inc > 90.

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

		if geoCoords:lat = 0 return "equatorial".

		local targetSurfaceLan is degmod(geoCoords:lng - 90).
		local deltaLng is targetSurfaceLan - currentLng.
		// if we are orbiting retrograde, modify our deltaLng as we are travelling backwards
		if isRetrogradeOrbit {
			set deltaLng to 360 - deltaLng.
		}
		local etaToLng is deltaLng / shipLngPerSec.
		local nodeTime is TIME:seconds + etaToLng.

		local rStart is (positionAt(SHIP, nodeTime) - BODY:position):mag.
		local Unode is VisViva(SHIP:OBT:semiMajorAxis, rStart - BODY:radius).
		local dvTotal is 2 * Unode * SIN(geoCoords:lat / 2).
		local dvNormal is Unode * SIN(geoCoords:lat).
		local dvPrograde is SQRT(dvTotal^2 - dvNormal^2).
		if geoCoords:lat < 0 set dvNormal to -dvNormal.

		local halfBurnDuration is maneuverTime(dvTotal / 2).
		local fullBurnDuration is maneuverTime(dvTotal).
		if etaToLng < halfBurnDuration {
			set nodeTime to nodeTime + 360 / shipLngPerSec.
		}
		local alarm is setAlarm(nodeTime - halfBurnDuration, "alignLanding " + round(geoCoords:lat,2), margin).
		local mnv is NODE(nodeTime, 0, dvNormal, -dvPrograde).
		ADD mnv.

		return Lex("node",mnv,"preburn",halfBurnDuration,"fullburn",fullBurnDuration,"alarm",alarm,"throttle",1).
	}).
}