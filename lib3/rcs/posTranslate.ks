{

	local killTranslate is import("rcs/killTranslate").
	local translateOff is import("rcs/translateOff").
	local vectorTranslate is import("rcs/vectorTranslate").
	local hoverThrust is import("sys/hoverThrust").

	// TODO: Optimize - change altPos to constant height above terrain
	export({
		parameter geoPos, howClose is 5.

		lock STEERING to UP.
		local vertHover is 0.
		lock THROTTLE to hoverThrust(vertHover).

		local altitudeTarget is 25.

		// position over landing site at current ship altitude
		local lock altPos to geoPos:altitudePosition(ALTITUDE).
		// horizontal distance to landing site
		local lock distance to altPos:mag.
		local prevDistance is -1.
		// rcs throttle scales down as we get close to target (fine control)
		local lock rcsThrottle to MAX(0.1,MIN(1,1 - howClose/MAX(howClose,distance))).
		// max horizontal speed scales down as we get close to target
		local lock maxTranslateSpeed to MIN(10,distance/10).
		// current horizontal speed
		local lock horizontalSpeed to SQRT(abs(GROUNDSPEED^2 - VERTICALSPEED^2)).
		// current horizontal velocity
		local lock currentVector to VXCL(UP:vector,VELOCITY:surface).
		// vector to correct currentVector to point towards target position - we use altPos so that RCS isn't used for vertical translation - let hoverThrust handle that
		local lock bearingVector to maxTranslateSpeed*altPos:normalized - currentVector.

		clearscreen.
		CLEARVECDRAWS().
		local drawGeoVec is VECDRAW(V(0,0,0), geoPos:position, GREEN, "pos", 1, TRUE, 0.05).
		local drawCurrentVector is VECDRAW(V(0,0,0), currentVector, RED, "srf", 1, TRUE, 0.05).
		local drawBearingVector is VECDRAW(V(0,0,0), bearingVector, CYAN, "bearing", 1, TRUE, 0.05).

		until 0 {
			print "distance    : " + round(distance,2) AT (0,0).
			print "vdot        : " + round(VDOT(currentVector,bearingVector),2) AT (0,1).
			print "mag         : " + round(bearingVector:mag,2) AT (0,2).
			set drawGeoVec:vec to geoPos:position.
			set drawCurrentVector:vec to currentVector.
			set drawBearingVector:vec to bearingVector.

			// if we are hovering over landing site we are done
			if distance < howClose and horizontalSpeed < 0.2 {
				translateOff().
				break.
			}

			// translate towards bearing if current or new speed < max speed
			//   or bearing is "opposite" current direction and not insignificant
			if min(horizontalSpeed,(currentVector+bearingVector):mag) < maxTranslateSpeed
			or (VDOT(currentVector,bearingVector)<0 and bearingVector:mag > maxTranslateSpeed/10)
				vectorTranslate(bearingVector, rcsThrottle).
			else translateOff().

			// if we are translating and move with range of landing site, or start moving away - kill all translation
			if horizontalSpeed > 0.2 and (distance > prevDistance or distance < howClose) {
				killTranslate().
			}

			// allow vessel to descend at 5m/s while translating
			if ALT:RADAR > altitudeTarget set vertHover to -5.
			else set vertHover to 0.

			set prevDistance to distance.
		}
		clearscreen.
		CLEARVECDRAWS().
	}).
}