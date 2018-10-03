{
	local hoverThrust is import("sys/hoverThrust").
	local killTranslate is import("rcs/killTranslate").
	local translateOff is import("rcs/translateOff").

	export({
		lock STEERING to UP.
		GEAR ON.
		lock THROTTLE to hoverThrust(-MIN(10,MAX(1,ALT:RADAR/10))).

		//wait until ALT:RADAR < 10 and abs(VERTICALSPEED) < 0.1 and GROUNDSPEED < 0.1.
		until ALT:RADAR < 10 and abs(VERTICALSPEED) < 0.1 {
			if GROUNDSPEED > 0.5 killTranslate().
			else translateOff().
		}


		lock THROTTLE to 0.
		unlock STEERING.
		//TODO: lock STEERING to LOOKDIRUP(getSlopeAtOffset(0,0),SUN:position)
	}).
}