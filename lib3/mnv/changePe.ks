{
	local VisViva is import("mech/VisViva").
	local maneuverTime is import("mnv/maneuverTime").
	local setAlarm is import("util/setAlarm").
	local exec is import("mnv/execute").

	function calculateDV {
		parameter newPe.
		local newSMA is (ALT:apoapsis + newPe)/2 + BODY:radius.
		local Uap_start is VisViva(SHIP:OBT:semiMajorAxis, ALT:apoapsis).
		local Uap_end is VisViva(newSMA, ALT:apoapsis).
		return Uap_end - Uap_start.
	}

	export({
		parameter newPe, thrustFactor is 1, margin is 60.
		local dv is calculateDV(newPe).
		local halfBurnDuration is maneuverTime(dv / 2, thrustFactor).
		local fullBurnDuration is maneuverTime(dv, thrustFactor).
		local nodeTime is TIME:seconds + ETA:apoapsis.
		if ETA:apoapsis < halfBurnDuration {
			set nodeTime to nodeTime + SHIP:OBT:period.
		}
		local alarm is setAlarm(nodeTime-halfBurnDuration, "changePe " + round(newPe/1000,3), margin).
		local mnv is NODE(nodeTime, 0, 0, dv).
		ADD mnv.

		return Lex("node",mnv,"preburn",halfBurnDuration,"fullburn",fullBurnDuration,"alarm",alarm).
	}).
}