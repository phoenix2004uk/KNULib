{
	local VisViva is import("mech/VisViva").
	local maneuverTime is import("mnv/maneuverTime").
	local setAlarm is import("util/setAlarm").
	local exec is import("mnv/execute").

	function calculateBurnAtPeVector {
		parameter newAp.

		local newSMA is (newAp + ALT:periapsis)/2 + BODY:radius.
		local Uap_start is VisViva(SHIP:OBT:semiMajorAxis, ALT:periapsis).
		local Uap_end is VisViva(newSMA, ALT:periapsis).
		local dv is Uap_end - Uap_start.

		return V(0,0,dv).
	}

	// TODO: optimize - need to calculate the burn for x seconds in the future
	function calculateBurnNowVector {
		parameter newAp.

		local nrm is VCRS(VELOCITY:orbit, -BODY:position).
		local rad is VCRS(nrm, VELOCITY:orbit).
		// vector that would be prograde if we were circular
		local fwd is VCRS(-BODY:position, nrm).

		// if ALTITUDE > newAP then circularize at current altitude
		local Uend is VisViva((ALTITUDE+MAX(ALTITUDE,newAp)/2) + BODY:radius, ALTITUDE).
		local newVel is Uend * fwd:normalized.
		local deltaV is newVel - VELOCITY:orbit.

		local dvPro is VDOT(deltaV, VELOCITY:orbit:normalized).
		local dvNrm is 0. //VDOT(deltaV, nrm:normalized).
		local dvRad is VDOT(deltaV, rad:normalized).

		return V(dvRad, dvNrm, dvPro).
	}

	export({
		parameter newAp, thrustFactor is 1, margin is 60.
		local nodeV is 0.
		local nodeTime is TIME:seconds.

		if ETA:periapsis < 0 {
			set nodeV to calculateBurnNowVector(newAp).
		}
		else {
			set nodeV to calculateBurnAtPeVector(newAp).
			set nodeTime to nodeTime + ETA:periapsis.
		}

		local halfBurnDuration is maneuverTime(nodeV:mag / 2, thrustFactor).
		local fullBurnDuration is maneuverTime(nodeV:mag, thrustFactor).
		local alarm is setAlarm(nodeTime - halfBurnDuration, "capture", margin).
		local mnv is NODE(nodeTime, nodeV:x, nodeV:y, nodeV:z).
		ADD mnv.

		return Lex("node",mnv,"preburn",halfBurnDuration,"fullburn",fullBurnDuration,"alarm",alarm,"throttle",thrustFactor).
	}).
}