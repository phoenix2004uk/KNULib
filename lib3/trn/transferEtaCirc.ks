{
	local degmod is import("util/degmod").
	local solarAnomaly is import("mech/S").
	export({
		parameter transfer_anomaly, target_orbital is TARGET, source_orbital is SHIP.

		// target parameters
		local n_target is 360 / target_orbital:OBT:period.
		local s0_target is solarAnomaly(target_orbital).

		// source parameters
		local n_source is 360 / source_orbital:OBT:period.
		local s0_source is solarAnomaly(source_orbital).

		// eta parameters
		local theta_current is degmod( s0_target - s0_source).
		local dTheta is degmod( theta_current - transfer_anomaly).
		local n_diff is abs( n_target - n_source ).

		return dTheta / n_diff.
	}).
}