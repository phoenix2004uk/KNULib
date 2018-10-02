// because kos MOD handles negatives differently
export({
	parameter value.
	//if value > 360 return mod(value, 360).
	if value < 0 until value >= 0 set value to value + 360.
	return mod(value, 360).
}).