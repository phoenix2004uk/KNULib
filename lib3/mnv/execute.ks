{
	local maneuverTime is import("mnv/maneuverTime").

	export({
		parameter thrustFactor is 1.

		local mnv is NEXTNODE.
		local dv0 is mnv:deltaV.

		lock STEERING to dv0.
		wait until VANG(dv0, SHIP:facing:vector) < 0.25.

		local preburn is maneuverTime(dv0:mag / 2, thrustFactor).
		wait until mnv:eta <= preburn.

		local lock max_acceleration to thrustFactor * SHIP:availableThrust / SHIP:mass.
		lock THROTTLE to MIN(thrustFactor, mnv:deltaV:mag / max_acceleration).

		local done is 0.
		until done {
			// check if node vector starts drifting from original vector - burn complete
			if VDOT(dv0, mnv:deltaV) < 0 {
				lock THROTTLE to 0.
				break.
			}

			if mnv:deltaV:mag < 0.1 {
				wait until VDOT(dv0, mnv:deltaV) < 0.5.
				lock THROTTLE to 0.
				set done to 1.
			}
		}
		unlock STEERING.
		wait 1.
		REMOVE mnv.
		return done.
	}).
}