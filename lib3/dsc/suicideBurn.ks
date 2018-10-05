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
		lock THROTTLE to 0.
		wait until SHIP:verticalSpeed < 0.

		// TODO: Enhancement - currently this causes the engine to splutter on and off during suicide burn, TTI needs adjusting slightly because of local gravity
		until ALT:RADAR <= altitudeMargin {
			if SHIP:verticalSpeed < 0 and TTI(altitudeMargin) <= maneuverTime(SHIP:velocity:surface:mag) lock THROTTLE to 1.
			else lock THROTTLE to 0.
		}

		lock STEERING to UP.
		lock THROTTLE to hoverThrust().
	}).
}