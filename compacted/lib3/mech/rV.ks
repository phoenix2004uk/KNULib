export({
	parameter anomaly_deg.
	local X is OBT:eccentricity.
	return (OBT:semiMajorAxis*(1-X^2))/(1+X*COS(anomaly_deg)).
}).