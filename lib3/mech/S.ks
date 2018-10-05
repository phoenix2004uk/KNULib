// gets a true anomaly in the solar prime reference frame
// allows us to compare true anomaly across different orbitals
{
	local degmod is import("util/degmod").
	export({
		parameter orbitable.
		//return degmod( orbitable:OBT:LAN + ARCTAN( COS(orbitable:OBT:inclination) * TAN( orbitable:OBT:trueAnomaly + orbitable:OBT:argumentOfPeriapsis ) ) ).
		return degmod( orbitable:OBT:LAN + orbitable:OBT:argumentOfPeriapsis + orbitable:OBT:trueAnomaly).
	}).
}