export({
	LIST ENGINES in enList.
	local T is 0.
	local m is 0.
	for en in enList if en:ignition and not en:flameout {
		local f is en:availableThrust * 1000.
		set T to T + f.
		set m to m + f / en:isp.
	}
	if m=0 return 0.
	return T / m.
}).