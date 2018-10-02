{
	local changeAp is import("mnv/changeAp").
	local changePe is import("mnv/changePe").

	export({
		parameter minEcc, whichApsis is "Ap", thrustFactor is 1, margin is 60.

		local mnv is 0.

		if whichApsis = "Pe" {
			local newAp is (ALT:periapsis + BODY:radius) * (1 + minEcc) / (1 - minEcc) - BODY:radius.
			set mnv to changeAp(newAp).
		}
		else { // whichApsis = "Ap"
			local newPe is (ALT:apoapsis + BODY:radius) * (1 - minEcc) / (1 + minEcc) - BODY:radius.
			set mnv to changePe(newPe).
		}

		set mnv["alarm"]:name to "ellipticize " + round(minEcc,4).

		return mnv.
	}).
}