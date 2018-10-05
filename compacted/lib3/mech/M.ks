export({
	parameter eccentric_anomaly_deg.
	return eccentric_anomaly_deg - OBT:eccentricity*SIN(eccentric_anomaly_deg)*CONSTANT:RadToDeg.
}).