{
	local currentISP is import("tlm/currentISP").
	export({
		parameter dV, thrustFactor is 1.

		// Δv = ∫a dt [0->tN]
		// a  = F/(M0 - ΔM*t)
		// Δv = ∫F/(M0 - ΔM*t) dt [0->tN]
		// ΔM = F / Isp*g0
		// Δv = ∫F/(M0 - (F / Isp*g0)*t) dt [0->tN]
		// tN = g0 * M0 * Isp * (1 - e^(-Δv/(g0*Isp)))/F

		local F is SHIP:availableThrust * 1000.	// available thrust in Kgm/s
		local M0 is SHIP:mass * 1000.			// current mass in Kg
		local e is CONSTANT:E.
		local Isp is currentISP().
		local g0 is 9.80665.					//9.81. Kerbin:MU / Kerbin:RADIUS^2.
		if Isp=0 return 2^64.
		return g0 * M0 * Isp * (1 - e^(-ABS(dV) / (g0 * Isp) ) ) / (F * thrustFactor).
	}).
}