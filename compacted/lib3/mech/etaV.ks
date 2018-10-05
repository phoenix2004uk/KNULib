{
	local mE is import("mech/E").
	local mM is import("mech/M").
	export({
		parameter anomaly_deg.
		local t is OBT:period * (mM(mE(anomaly_deg)) - mM(mE(OBT:trueAnomaly))) / 360.
		if t < 0 set t to t + OBT:period.
		return t.
	}).
}