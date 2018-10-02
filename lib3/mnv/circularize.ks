{
	local changeAp is import("mnv/changeAp").
	local changePe is import("mnv/changePe").

	export({
		parameter whichApsis is "Ap", thrustFactor is 1, margin is 60.

		local mnv is 0.

		if whichApsis = "Pe" {
			set mnv to changeAp(ALT:periapsis).
		}
		else { // whichApsis = "Ap"
			set mnv to changePe(ALT:apoapsis).
		}

		set mnv["alarm"]:name to "circularize".

		return mnv.
	}).
}