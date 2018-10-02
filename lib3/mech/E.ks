// Eccentric Anomaly (E)
export({
	parameter true_anomaly_deg.
	local eccentric_anomaly_deg is ARCCOS( (ship:obt:eccentricity+COS(true_anomaly_deg)) / (1 + ship:obt:eccentricity*COS(true_anomaly_deg)) ).
	if true_anomaly_deg > 180 {
		set eccentric_anomaly_deg to 360 - eccentric_anomaly_deg.
	}
	return eccentric_anomaly_deg.
}).