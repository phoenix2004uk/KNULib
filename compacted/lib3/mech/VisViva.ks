export({
	parameter sma, altN, oBody is BODY.
	return SQRT(oBody:mu * ( (2/(altN + oBody:radius)) - (1/sma) )).
}).