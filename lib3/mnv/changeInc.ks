{
	local VisViva is import("mech/VisViva").
	local maneuverTime is import("mnv/maneuverTime").
	local setAlarm is import("util/setAlarm").
	local ORB is bundle(List("mech/rAN","mech/rDN","mech/etaAN","mech/etaDN")).

	// TODO: handle eta < halfBurnDuration for whichNode = next
	export({
		parameter newInc, whichNode is "highest", thrustFactor is 1, margin is 60.

		if whichNode = "next" {
			if ORB["etaAN"]() < ORB["etaDN"]() set whichNode to "AN".
			else set whichNode to "DN".
		}
		else if whichNode = "highest" {
			if ORB["rAN"]() > ORB["rDN"]() set whichNode to "AN".
			else set whichNode to "DN".
		}

		local theta is newInc - SHIP:OBT:inclination.

		local Unode is VisViva(SHIP:OBT:semiMajorAxis, ORB["r"+whichNode]() - BODY:radius).
		local dvTotal is 2 * Unode * SIN(theta / 2).
		local dvNormal is Unode * SIN(theta).
		local dvPrograde is SQRT(dvTotal^2 - dvNormal^2).
		if whichNode = "DN" set dvNormal to -dvNormal.

		local halfBurnDuration is maneuverTime(dvTotal / 2, thrustFactor).
		local fullBurnDuration is maneuverTime(dv, thrustFactor).
		local nodeTime is TIME:seconds + ORB["eta" + whichNode]().
		if ORB["eta" + whichNode]() < halfBurnDuration {
			set nodeTime to nodeTime + SHIP:OBT:period.
		}
		local alarm is setAlarm(nodeTime - halfBurnDuration, "changeInc " + round(theta,1), margin).
		local mnv is NODE(nodeTime, 0, dvNormal, -dvPrograde).
		ADD mnv.

		return Lex("node",mnv,"preburn",halfBurnDuration,"fullburn",fullBurnDuration,"alarm",alarm).
	}).
}