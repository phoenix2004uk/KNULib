{
	local maneuverTime is import("mnv/maneuverTime").
	local setAlarm is import("util/setAlarm").

	export({
		parameter nodeTime, dvRad, dvNrm, dvPro, thrustFactor is 1, margin is 60.
		local mnv is Node(nodeTime, dvRad, dvNrm, dvPro).
		Add mnv.
		local dv is mnv:deltaV:mag.

		local halfBurnDuration is maneuverTime(dv / 2, thrustFactor).
		local fullBurnDuration is maneuverTime(dv, thrustFactor).
		local alarm is setAlarm(nodeTime - halfBurnDuration, "custom " + round(newAp/1000,3), margin).

		return Lex("node",mnv,"preburn",halfBurnDuration,"fullburn",fullBurnDuration,"alarm",alarm).
	}).
}