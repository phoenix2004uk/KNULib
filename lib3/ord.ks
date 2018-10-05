{
	function normalVector { return VCRS(SHIP:VELOCITY:ORBIT,-BODY:POSITION). }
	function radialVector { return VXCL(PROGRADE:VECTOR, UP:VECTOR). }
	function relativeSunVector { parameter vec is V(0,1,0). return LOOKDIRUP(vec,SUN:position). }

	export(Lex(
		"nrm", NORMALVEC@,
		"rad", RADIALVEC@,
		"pro", { return PROGRADE + R(0,0,0). },
		"sun", relativeSunVector@
	)).
}