// Mean Anomaly (M)
export({
	parameter eccentric_anomaly_deg.
	return eccentric_anomaly_deg - ship:obt:eccentricity*SIN(eccentric_anomaly_deg)*CONSTANT:RadToDeg.
}).