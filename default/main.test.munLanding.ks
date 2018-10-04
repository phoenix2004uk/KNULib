local safeStage is import("sys/safeStage").
local RT is bundleDir("rt").
local VSL is import("vessel").
local isFacing is import("util/isFacing").
local MNV is bundle(List("mnv/execute","dsc/deorbitAtLng","dsc/suicideBurn","dsc/land")).
local seekFlat is import("util/seekFlat").
local geoOffsetFromShip is import("util/geoOffsetFromShip").

local mission is import("missionRunner")(
	List(
		preflight@
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