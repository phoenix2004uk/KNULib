export({
	parameter true_anomaly_deg.
	local eccentric_anomaly_deg is ARCCOS( (OBT:eccentricity+COS(true_anomaly_deg)) / (1 + OBT:eccentricity*COS(true_anomaly_deg)) ).
	if true_anomaly_deg > 180 set eccentric_anomaly_deg to 360 - eccentric_anomaly_deg.
	return eccentric_anomaly_deg.
}).