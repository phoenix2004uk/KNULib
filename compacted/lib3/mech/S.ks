{
	local degmod is import("util/degmod").
	export({
		parameter orbitable.
		return degmod( orbitable:OBT:LAN + orbitable:OBT:argumentOfPeriapsis + orbitable:OBT:trueAnomaly).
	}).
}