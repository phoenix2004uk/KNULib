local RT is bundleDir("rt").
local VSL is import("vessel").
local kerbinLaunch is import("asc/kerbinLaunch").
local isFacing is import("util/isFacing").

local mission is import("missionRunner")(
	List(
"preflight",	preflight@,
				launch@,
				inOrbit@,
				idle@
	),
	List(
		"orientCraft", orientCraft@
	),TRUE
).
mission["disable"]("orientCraft").
mission["run"]().

function orientCraft {
	if not isFacing(VSL["orient"]()) lock STEERING to VSL["orient"]().
}

function preflight {
	if not (SHIP=KUNIVERSE:activeVessel and SHIP:unpacked) return.

	print "press any key to launch...".
	TERMINAL:input:getChar().

	// because we don't have a comm network
	RT["activateAll"]().
	RT["setTarget"]("Mission Control","RTShortDish2").

	mission["next"]().
}
function launch {
	kerbinLaunch(100000, 90).
	mission["next"]().
}
function inOrbit {
	RT["activateAll"]().
	RT["setTarget"]("Mission Control","RTShortDish2").
	mission["enable"]("orientCraft").

	mission["next"]().
}
function idle {
	if not isFacing(VSL["orient"]()) lock STEERING to VSL["orient"]().
	wait 10.
	unlock STEERING.
	SAS ON.
	wait 10.
	mission["next"]().
}