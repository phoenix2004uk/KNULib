// altitude (r) of True Anomaly (V)
export({
	parameter anomaly_deg.
	return (ship:obt:semiMajorAxis*(1-ship:obt:eccentricity^2))/(1+ship:obt:eccentricity*COS(anomaly_deg)).
}).