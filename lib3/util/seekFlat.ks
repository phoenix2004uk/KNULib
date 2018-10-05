{
	local getSlopeAtOffset is import("util/getSlopeAtOffset").

	export({
		parameter maxSlope is 5.

		local x is 0.
		local y is 0.
		local slopeAngle is 90.
		local east is VCRS(NORTH:vector, UP:vector).
		until 0 {
			local groundNormal is getSlopeAtOffset(x,y).
			set slopeAngle to VANG(groundNormal, UP:vector).
			if slopeAngle < maxSlope break.
			set step to max(1,min(20, slopeAngle - maxSlope)).

			local downhill is VXCL(UP:vector, groundNormal).
			set x to x + step * COS(VANG(downhill, NORTH:vector)).
			set y to y + step * COS(VANG(downhill, east)).
		}
		return List(x, y).
	}).
}