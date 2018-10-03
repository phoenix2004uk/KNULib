{

	local killTranslate is import("rcs/killTranslate").
	local translateOff is import("rcs/translateOff").
	local vectorTranslate is import("rcs/vectorTranslate").

	// TODO: Optimize - change altPos to constant height above terrain
	export({
		parameter geoPos, howClose is 5.

		local altPos is geoPos:altitudePosition(ALTITUDE).
		local lock distance is altPos:mag.
		local prevDistance is -1.

		until 0 {
			if distance < howClose and GROUNDSPEED < 0.05 {
				translateOff().
				break.
			}
			if distance > prevDistance or distance < howClose {
				killTranslate().
			}
			else if GROUNDSPEED < 10*MIN(1 - howClose/distance,1) {
				vectorTranslate(altPos, 1 - howClose/distance).
			}
			else {
				translateOff().
			}

			set prevDistance to distance.
		}
	}).
}