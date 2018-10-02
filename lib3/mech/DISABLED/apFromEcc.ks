export({
	parameter ecc, Pe is ALT:periapsis.
	return (Pe + BODY:radius) * (1 + ecc) / (1 - ecc) - BODY:radius.
}).