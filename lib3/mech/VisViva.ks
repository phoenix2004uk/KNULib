export({
	parameter sma, altN, oBody is BODY.

	local mu is oBody:mu.
	local rN is altN + oBody:radius.

	return SQRT(mu * ( (2/rN) - (1/sma) )).
}).