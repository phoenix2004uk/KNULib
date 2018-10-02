// gets a true anomaly in the solar prime reference frame
// allows us to compare true anomaly across different orbitals
export({
	parameter orbitable.
	//return import("util/degmod")( orbitable:OBT:LAN + ARCTAN( COS(orbitable:OBT:inclination) * TAN( orbitable:OBT:trueAnomaly + orbitable:OBT:argumentOfPeriapsis ) ) ).
	return import("util/degmod")( orbitable:OBT:LAN + orbitable:OBT:argumentOfPeriapsis + orbitable:OBT:trueAnomaly).
}).