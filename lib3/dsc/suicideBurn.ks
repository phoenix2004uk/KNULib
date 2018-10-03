{

	local TTI is import("tlm/timeToImpact").
	local maneuverTime is import("mnv/maneuverTime").
	local hoverThrust is import("sys/hoverThrust").

	function descentVector {
		if SHIP:verticalSpeed >= 0 or SHIP:groundSpeed < 1 return UP.
		else return SRFRETROGRADE.
	}

	export({
		parameter altitudeMargin is 100.

		lock STEERING to descentVector().
		wait until SHIP:verticalSpeed < 0.

		until ALT:RADAR <= altitudeMargin {
			if SHIP:verticalSpeed < 0 and TTI(altitudeMargin) <= maneuverTime(SHIP:velocity:surface:mag) lock THROTTLE to 1.
			else lock THROTTLE to 0.
		}
		lock THROTTLE to hoverThrust().

	}).
}