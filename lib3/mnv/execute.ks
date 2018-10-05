{
	local maneuverTime is import("mnv/maneuverTime").
	local burnout is import("sys/burnout").

	export({
		parameter thrustMax is 1.

		local mnv is NEXTNODE.
		local dv0 is mnv:deltaV.

		lock STEERING to mnv:deltaV.
		wait until VANG(mnv:deltaV, SHIP:facing:vector) < 0.25.

		set thrustMax to MIN(1, thrustMax).

		local preburn is maneuverTime(dv0:mag / 2, thrustMax).
		wait until mnv:eta <= preburn.

		// to stop max_acceleration being 0 and causing THROTTLE = Infinity, limit the value to 1e-9 because it's very small and almost 0
		local lock max_acceleration to MAX(1e-9,thrustMax * SHIP:availableThrust / SHIP:mass).
		lock THROTTLE to MAX(1e-4,MIN(thrustMax, mnv:deltaV:mag / max_acceleration)).

		local remaining is 0.
		until VDOT(dv0, mnv:deltaV) < 0 or VANG(dv0, SHIP:facing:vector) > 30 {
			if burnout() {
				lock THROTTLE to 0.
				unlock STEERING.
				return "burnout".
			}
		}
		set remaining to mnv:deltaV:mag.
		lock THROTTLE to 0.

		unlock STEERING.
		wait 1.
		REMOVE mnv.
		return remaining.
	}).
}