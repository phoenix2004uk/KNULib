{
	local translateOff is import("rcs/translateOff").
	local vectorTranslate is import("rcs/vectorTranslate").

	export({
		until GROUNDSPEED < 0.05 {
			vectorTranslate(srfRetrograde:vector, GROUNDSPEED).
			wait 0.
		}
		translateOff().
	}).
}