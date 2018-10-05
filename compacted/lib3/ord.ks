export(Lex(
	"nrm", { return VCRS(SHIP:VELOCITY:ORBIT,-BODY:POSITION). },
	"rad", { return VXCL(PROGRADE:VECTOR, UP:VECTOR). },
	"pro", { return PROGRADE + R(0,0,0). },
	"sun", { parameter vec is V(0,1,0). return LOOKDIRUP(vec,SUN:position). }
)).