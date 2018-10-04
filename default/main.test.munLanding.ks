local safeStage is import("sys/safeStage").
local RT is bundleDir("rt").
local VSL is import("vessel").
local isFacing is import("util/isFacing").
local MNV is bundle(List("mnv/execute","dsc/deorbitAtLng","dsc/suicideBurn","dsc/land","mnv/changePe","mnv/circularize")).
local seekFlat is import("util/seekFlat").
local geoOffsetFromShip is import("util/geoOffsetFromShip").
local posTranslate is import("rcs/posTranslate").

local mission is import("missionRunner")(
	List(
		preflight@,
		lowerOrbit@, exec@,
		circularizeOrbit@, exec@,
		deorbit@, exec@,
		suicideBurn@, exec@,
		seekFlatLandingSlope@,
		descend@
	),
	List(
		"orientCraft", orientCraft@,
		"powerMonitor", powerMonitor@
	),TRUE
).
mission["disable"]("powerMonitor").
mission["disable"]("orientCraft").
mission["run"]().

function orientCraft {
	if not isFacing(VSL["orient"]()) lock STEERING to VSL["orient"]().
}
function powerMonitor {
	if SHIP:ElectricCharge > VSL["EC_POWERSAVE"][1] {
		RT["activateAll"]().
	}
	else if SHIP:ElectricCharge < VSL["EC_POWERSAVE"][0] {
		RT["deactivateAll"]().
		if SHIP:ElectricCharge < VSL["EC_CRITICAL"] {
			clearFlightpath().
			wait until SHIP:ElectricCharge > VSL["EC_CRITICAL"].
		}
	}
}

function clearFlightpath {
	until not HASNODE {
		Remove NEXTNODE.
		wait 1.
	}
}

function preflight {
	if STATUS <> "ORBITING" return.
	if BODY <> Mun return.
	if not (SHIP=KUNIVERSE:activeVessel and SHIP:unpacked) return.

	until STAGE:number = VSL["stages"]["orbital"] safeStage().

	print "press any key to begin...".
	TERMINAL:input:getChar().

	mission["enable"]("powerMonitor").
	mission["enable"]("orientCraft").
	RT["activateAll"]().
	RT["setTarget"]("Mission Control","RelayAntenna50").

	mission["next"]().
}
function lowerOrbit {
	MNV["changePe"](10000).
	mission["next"]().
}
function circularizeOrbit {
	MNV["circularize"]("Pe").
	mission["next"]().
}
function exec {
	if not (DEFINED burn and HASNODE) {
		clearFlightpath().
		mission["prev"]().
	}
	else if burn["node"]:eta - 60 <= burn["preburn"] {
		RT["activateAll"]().
		MNV["execute"](burn["throttle"]).
		mission["next"]().
	}
}
function deorbit {
	local targetLongitude is 0.
	MNV["deorbitAtLng"](targetLongitude).
}
function suicideBurn {
	local altitudeMargin is 100.	// default = 100
	MNV["suicideBurn"](altitudeMargin).
}
function seekFlatLandingSlope {
	local maxSlope is 5.	// default = 5
	local stepSize is 5.	// default = 5
	// TODO: need a way to ABORT back into orbit if this process takes too long
	// should maybe refactor seekFlat to be called repeatedly instead of internally using an until loop
	// seekFlat should return List(x,y,slopeAngle), then we can say - if offsetSlope < maxSlope
	// just need to store the x,y values somewhere during each call of this mission step - means using globals :(
	local offset is seekFlat(maxSlope, stepSize).
	posTranslate(geoOffsetFromShip(offset[0], offset[1])).
	mission["next"]().
}
function descend {
	MNV["land"]().
	mission["next"]().
}