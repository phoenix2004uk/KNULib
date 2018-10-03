{
	local VisViva is import("mech/VisViva").
	local maneuverTime is import("mnv/maneuverTime").
	local setAlarm is import("util/setAlarm").

	function calculateDV {
		parameter newAp.
		local newSMA is (newAp + ALT:periapsis)/2 + BODY:radius.
		local Uap_start is VisViva(SHIP:OBT:semiMajorAxis, ALT:periapsis).
		local Uap_end is VisViva(newSMA, ALT:periapsis).
		return Uap_end - Uap_start.
	}

	export({
		parameter newAp, thrustFactor is 1, margin is 60.
		local dv is calculateDV(newAp).
		local halfBurnDuration is maneuverTime(dv / 2, thrustFactor).
		local fullBurnDuration is maneuverTime(dv, thrustFactor).
		local nodeTime is TIME:seconds + ETA:periapsis.
		if ETA:periapsis < halfBurnDuration {
			set nodeTime to nodeTime + SHIP:OBT:period.
		}
		local alarm is setAlarm(nodeTime - halfBurnDuration, "changeAp " + round(newAp/1000,3), margin).
		local mnv is NODE(nodeTime, 0, 0, dv).
		ADD mnv.

		return Lex("node",mnv,"preburn",halfBurnDuration,"fullburn",fullBurnDuration,"alarm",alarm).
	}).
}