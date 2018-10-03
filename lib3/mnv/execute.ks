{
	local maneuverTime is import("mnv/maneuverTime").

	export({
		parameter thrustMax is 1.

		local mnv is NEXTNODE.
		local dv0 is mnv:deltaV.

		lock STEERING to dv0.
		wait until VANG(dv0, SHIP:facing:vector) < 0.25.

		local preburn is maneuverTime(dv0:mag / 2, thrustMax).
		wait until mnv:eta <= preburn.

		local lock max_acceleration to thrustMax * SHIP:availableThrust / SHIP:mass.
		local thrustFactor is dv0:mag / max_acceleration.
		lock THROTTLE to MIN(thrustMax, thrustFactor * mnv:deltaV:mag / max_acceleration).

		local done is 0.
		//until done {
		until 0 {
			if VDOT(dv0, mnv:deltaV) <= 0 or VANG(dv0, mnv:deltaV) > 80 {
				set done to mnv:deltaV:mag.
				lock THROTTLE to 0.
				break.
			}

			//if mnv:deltaV:mag < 0.1 {
			//if mnv:deltaV:mag < thrustMax/10 {
			//	wait until VDOT(dv0, mnv:deltaV) < 0.5.
			//	lock THROTTLE to 0.
			//	set done to 1.
			//}
		}
		unlock STEERING.
		wait 1.
		REMOVE mnv.
		return done.
	}).
}