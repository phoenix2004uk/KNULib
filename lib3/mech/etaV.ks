// eta to True Anomaly (V)
{
	local mech is bundle(List("mech/E","mech/M")).
	export({
		parameter anomaly_deg.

		local n is 360 / ship:obt:period.

		local V0 is ship:obt:trueAnomaly.
		local E0 is mech["E"](V0).
		local M0 is mech["M"](E0).

		local V1 is anomaly_deg.
		local E1 is mech["E"](V1).
		local M1 is mech["M"](E1).

		local t is (M1 - M0) / n.
		if t < 0 set t to t + ship:obt:period.
		return t.
	}).
}