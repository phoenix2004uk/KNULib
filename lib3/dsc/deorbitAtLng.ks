{
	local maneuverTime is import("mnv/maneuverTime").
	local setAlarm is import("util/setAlarm").

	// TODO: Enhancement - re-calculate for non-circular orbits
	// TODO: handle retrograde orbits (inc > 90)
	export({
		parameter targetLng, margin is 60.

		local currentLng is SHIP:longitude.
		local deltaLng is targetLng - currentLng.

		local n is 360 / SHIP:OBT:period.
		local siderealRate is 360 / BODY:rotationPeriod.
		local lngPerSec is n - siderealRate.

		local etaToLng is deltaLng / lngPerSec.
		local nodeTime is TIME:seconds + etaToLng.

		local srfSpeed is 2*CONSTANT:PI*BODY:radius / siderealRate.
		local dv is srfSpeed - velocityAt(SHIP, nodeTime):mag.


		local halfBurnDuration is maneuverTime(dv / 2, thrustFactor).
		local fullBurnDuration is maneuverTime(dv, thrustFactor).
		if etaToLng < halfBurnDuration {
			set nodeTime to nodeTime + 360 / lngPerSec.
		}
		local alarm is setAlarm(nodeTime - halfBurnDuration, "begin descent " + round(targetLng,2), margin).
		local mnv is NODE(nodeTime, 0, 0, dv).
		ADD mnv.

		return Lex("node",mnv,"preburn",halfBurnDuration,"fullburn",fullBurnDuration,"alarm",alarm,"throttle",thrustFactor).
	}).
}