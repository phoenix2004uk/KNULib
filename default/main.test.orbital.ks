local safeStage is import("sys/safeStage").
local MNV is bundleDir("mnv").
local RT is bundleDir("rt").
local VSL is import("vessel").
local isFacing is import("util/isFacing").

function clearFlightpath {
	until not HASNODE {
		Remove NEXTNODE.
		wait 1.
	}
}

local mission is import("missionRunner")(
	List(
"preflight",	preflight@,
"changeAp500",	changeAp500@, exec@,
				changePe500@, exec@,
				checkApsides@,
				changeInc10@, exec@,
				ellipticize08@, exec@,
"wait",			waitForTarget@,
				matchInc@, exec@,
				circularize@, exec@,
				changeInc0@, exec@,
				tinyCustomBurnT1@, exec@,
				tinyCustomBurnT1em4@, exec@,
				changePe25@, exec@,
"idle",			idleTillCrash@
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

function preflight {
	if STATUS <> "ORBITING" return.
	if not (SHIP=KUNIVERSE:activeVessel and SHIP:unpacked) return.

	until STAGE:number = VSL["stages"]["orbital"] safeStage().

	print "press any key to begin...".
	TERMINAL:input:getChar().

	RT["activateAll"]().
	RT["setTarget"]("Mission Control","RelayAntenna50").

	mission["enable"]("powerMonitor").
	mission["enable"]("orientCraft").

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
function changeAp500 {
	set burn to MNV["changeAp"](500000).
	mission["next"]().
}
function changePe500 {
	set burn to MNV["changePe"](500000).
	mission["next"]().
}
function checkApsides {
	if ALT:apoapsis > 501000 or ALT:periapsis < 499000
		mission["jump"]("changeAp500").
	else
		mission["next"]().
}
function changeInc10 {
	set burn to MNV["changeInc"](10,"next").
	mission["next"]().
}
function ellipticize08 {
	set burn to MNV["ellipticize"](0.8, "Pe").
	mission["next"]().
}
function waitForTarget {
	if HASTARGET {
		wait 10.
		mission["next"]().
	}
}
function matchInc {
	set burn to MNV["matchInc"](TARGET).
	mission["next"]().
}
function circularize {
	set burn to MNV["circularize"]("Ap").
	mission["next"]().
}
function changeInc0 {
	if BODY <> Kerbin return.
	set burn to MNV["changeInc"](0,"highest").
	mission["next"]().
}
function tinyCustomBurnT1 {
	if BODY <> Kerbin return.
	set burn to MNV["custom"](TIME:seconds + 30, 0, 0, 1).
	mission["next"]().
}
function tinyCustomBurnT1em4 {
	if BODY <> Kerbin return.
	set burn to MNV["custom"](TIME:seconds + 30, 0, 0, 1, 1e-3).
	mission["next"]().
}
function changePe25 {
	if BODY <> Kerbin return.
	set burn to MNV["changePe"](25000).
	mission["next"]().
}
function idleTillCrash {
	mission["disable"]("orientCraft").
	mission["disable"]("powerMonitor").
}