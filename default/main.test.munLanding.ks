local safeStage is import("sys/safeStage").
local RT is bundleDir("rt").
local VSL is import("vessel").
local isFacing is import("util/isFacing").
local MNV is bundle(List("mnv/execute","dsc/alignLanding","dsc/deorbitAtLng","dsc/suicideBurn","dsc/land","mnv/changePe","mnv/circularize","mnv/changeInc")).
local seekFlat is import("util/seekFlat").
local geoOffsetFromShip is import("util/geoOffsetFromShip").
local posTranslate is import("rcs/posTranslate").
local killTranslate is import("rcs/killTranslate").
local autoStage is import("sys/autoStage").

local mission is import("missionRunner")(
	List(
		preflight@,
		lowerOrbit@, exec@,
		circularizeOrbit@, exec@,
		inclineToLandingLatitude@, exec@,
"deorbit", deorbit@, exec@:bind(TRUE),
		performSuicideBurn@,
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

function exec {
	parameter doAutoStage is FALSE, minStage is 0.
	if not (DEFINED burn and HASNODE) {
		clearFlightpath().
		mission["prev"]().
	}
	else if burn["node"]:eta - 60 <= burn["preburn"] {
		RT["activateAll"]().
		local res is MNV["execute"](burn["throttle"]).
		if res:istype("string") and res = "burnout" {
			if doAutoStage autoStage(minStage).
		}
		else {
			mission["next"]().
		}
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
	// 7100m should be safe at any inclination
	set burn to MNV["changePe"](7100).
	mission["next"]().
}
function circularizeOrbit {
	set burn to MNV["circularize"]("Pe").
	mission["next"]().
}
local landingSite is LatLng(20, -50).
function inclineToLandingLatitude {
	set burn to MNV["alignLanding"](landingSite).
	if burn:istype("string") and burn = "equatorial" {
		mission["jump"]("deorbit").
	}
	else {
		mission["next"]().
	}
}
function deorbit {
	set burn to MNV["deorbitAtLng"](landingSite:lng).
	mission["disable"]("orientCraft").
	mission["next"]().
}
function performSuicideBurn {
	// discard last stage
	until STAGE:number = 0 safeStage().
	wait 5.
	local altitudeMargin is 100.	// default = 100
	MNV["suicideBurn"](altitudeMargin).
	mission["next"]().
}
function seekFlatLandingSlope {
	// TODO: need seekFlat to be able to start from the specified location instead of only starting under the vessel
	killTranslate().
	local maxSlope is 5.	// default = 5
	// TODO: need a way to ABORT back into orbit if this process takes too long
	// should maybe refactor seekFlat to be called repeatedly instead of internally using an until loop
	// seekFlat should return List(x,y,slopeAngle), then we can say - if offsetSlope < maxSlope
	// just need to store the x,y values somewhere during each call of this mission step - means using globals :(
	local offset is seekFlat(maxSlope).
	posTranslate(geoOffsetFromShip(offset[0], offset[1])).
	mission["next"]().
}
function descend {
	MNV["land"]().
	mission["next"]().
}

mission["run"]().