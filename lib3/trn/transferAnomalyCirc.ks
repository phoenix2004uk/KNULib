export({
	parameter final_separation, target_orbital is TARGET, source_orbital is SHIP, parentBody IS BODY.

	local a_source is source_orbital:OBT:semiMajorAxis.
	local a_target is target_orbital:OBT:semiMajorAxis.
	local n_target is 360 / target_orbital:OBT:period.

	local a_transfer is (a_source + a_target) / 2.
	local T_transfer is CONSTANT:PI*SQRT(a_transfer^3/parentBody:MU).

	local dTheta_of_target_during_transfer is n_target * T_transfer.

	// adding 180 since we start 180' from where we finish
	local anomaly_between_vessels_before_transfer is final_separation - dTheta_of_target_during_transfer + 180.

	return import("util/degmod")(anomaly_between_vessels_before_transfer).
}).