{
	local VisViva is import("mech/VisViva").
	local maneuverTime is import("mnv/maneuverTime").
	local setAlarm is import("util/setAlarm").
	local ORB is bundle(List("mech/rV","mech/etaV")).
	local TRN is bundle(List("trn/relativeInclination","trn/relativeNodes")).
	local ORD is import("ord").

	function calculateDeltaV {
		parameter targetOrbitable, whichNode is "highest", thrustFactor is 1, margin is 60.

		local useNextNode is whichNode = "next".
		local useHighestNode is whichNode = "highest".

		local nodes is TRN["relativeNodes"](targetOrbitable).
		local rAN is ORB["rV"](nodes["AN"]).
		local rDN is ORB["rV"](nodes["DN"]).

		if useHighestNode {
			if rAN > rDN set whichNode to "AN".
			else set whichNode to "DN".
		}
		else if useNextNode {
			set whichNode to nodes["next"].
		}
		// otherNode set so we can switch node if we have passed "next" node
		local otherNode is "AN".
		if whichNode = "AN" set otherNode to "DN".

		local theta is TRN["relativeInclination"](targetOrbitable).
		local nodeTime is TIME:seconds + ORB["etaV"](nodes[whichNode]).
		local shipVelAtNode is velocityAt(SHIP, nodeTime):orbit.
		local shipPosAtNode is positionAt(SHIP, nodeTime).
		local targetVelAtNode is velocityAt(targetOrbitable, nodeTime):orbit.
		local targetPosAtNode is positionAt(targetOrbitable, nodeTime) - positionAt(BODY, nodeTime).
		local shipNrmAtNode is VCRS(shipVelAtNode, shipPosAtNode).
		local shipRadAtNode is VCRS(shipNrmAtNode, shipVelAtNode).
		local lineOfNodes is VCRS( VCRS(-BODY:position, velocity:orbit), VCRS(targetOrbitable:position-BODY:position, targetOrbitable:OBT:velocity:orbit) ).
		local newVel is shipVelAtNode:mag * ( AngleAxis(theta,lineOfNodes) * shipVelAtNode):normalized.

		local deltaV is newVel - shipVelAtNode.

		local dvPro is VDOT(deltaV, shipVelAtNode:normalized).
		local dvNrm is VDOT(deltaV, shipNrmAtNode:normalized).
		local dvRad is VDOT(deltaV, shipRadAtNode:normalized).

		local halfBurnDuration is maneuverTime(deltaV:mag / 2, thrustFactor).
		local fullBurnDuration is maneuverTime(deltaV:mag, thrustFactor).
		if ORB["etaV"](nodes[whichNode]) < halfBurnDuration {
			if useNextNode {
				// recalculate using otherNode
				return calculateDeltaV(targetOrbitable, otherNode, thrustFactor, margin).
			}
			else {
				set nodeTime to nodeTime + SHIP:OBT:period.
			}
		}
		local alarm is setAlarm(nodeTime - halfBurnDuration, "matchInc " + targetOrbitable:name, margin).
		local mnv is NODE(nodeTime, dvRad, dvNrm, dvPro).
		ADD mnv.

		return Lex("node",mnv,"preburn",halfBurnDuration,"fullburn",fullBurnDuration,"alarm",alarm,"throttle",thrustFactor).
	}

	export({
		parameter targetOrbitable, whichNode is "highest", thrustFactor is 1, margin is 60.

		return calculateDeltaV(targetOrbitable, whichNode, thrustFactor, margin).
	}).
}