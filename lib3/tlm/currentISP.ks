export({
	// Isp = ΣT / Σm
	// m   = T / Isp
	// Isp = ΣT / Σ(T/Isp)

	LIST ENGINES in enList.
	local T is 0.
	local m is 0.
	for en in enList {
		if en:ignition and not en:flameout {
			set T to T + en:availableThrust * 1000.
			set m to m + en:availableThrust * 1000 / en:isp.
		}
	}
	if m=0 return 0.
	return T / m.
}).