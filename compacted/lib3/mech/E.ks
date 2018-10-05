export({
	parameter true_anomaly_deg.
	local ecc is OBT:eccentricity.
	local eccentric_anomaly_deg is ARCCOS( (ecc + COS(true_anomaly_deg)) / (1 + ecc * COS(true_anomaly_deg)) ).
	if true_anomaly_deg > 180 set eccentric_anomaly_deg to 360 - eccentric_anomaly_deg.
	return eccentric_anomaly_deg.
}).