{
	local translateOff is import("rcs/translateOff").
	local vectorTranslate is import("rcs/vectorTranslate").

	export({
		local lock horizontalSpeed to SQRT(abs(GROUNDSPEED^2 - VERTICALSPEED^2)).
		until horizontalSpeed < 0.1 {
			vectorTranslate(srfRetrograde:vector, horizontalSpeed).
			wait 0.
		}
		translateOff().
	}).
}