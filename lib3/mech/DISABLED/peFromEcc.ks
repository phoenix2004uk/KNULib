export({
	parameter ecc, Ap is ALT:apoapsis.
	return (Ap + BODY:radius) * (1 - ecc) / (1 + ecc) - BODY:radius.
}).