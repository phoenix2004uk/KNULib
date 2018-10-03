export({
	parameter directionVector, rcsThrottle is 1.

	local headingVector is max(0.01,min(1,rcsThrottle)) * VXCL(UP:vector,directionVector):normalized.

	set SHIP:control:starboard	to headingVector * SHIP:facing:starVector.
	set SHIP:control:top		to headingVector * SHIP:facing:topVector.
	set SHIP:control:fore		to headingVector * SHIP:facing:foreVector.
	RCS ON.
}).