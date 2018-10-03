local safeStage is import("sys/safeStage").
local MNV is bundleDir("mnv").
local RT is bundleDir("rt").
local VSL is import("vessel").
local isFacing is import("util/isFacing").

local mission is import("missionRunner")(
	List(
"preflight",	preflight@,
"changeAp500",	changeAp500@,	coast@, exec@,
				changePe500@,	coast@, exec@,
				checkApsides@,
				changeInc10@,	coast@, exec@,
				ellipticize08@,	coast@, exec@,
"wait",			waitForTarget@,
				matchInc@,		coast@, exec@,
				circularize@,	coast@, exec@,
				changeInc0@,	coast@, exec@,
				changePe25@,	coast@, exec@,
"idle",			idleTillCrash@
	),
	List(
		"orientCraft", orientCraft@,
		"enablePowerSaving", enablePowerSaving@,
		"disablePowerSaving", disablePowerSaving@
	),TRUE
).
mission["disable"]("enablePowerSaving").
mission["disable"]("disablePowerSaving").
mission["disable"]("orientCraft").
mission["run"]().

function orientCraft {
	if not isFacing(VSL["orient"]()) lock STEERING to VSL["orient"]().
}
function enablePowerSaving {
	if SHIP:ElectricCharge < VSL["EC_POWERSAVE"][0] {
		RT["deactivateAll"]().
		mission["disable"]("enablePowerSaving").
		mission["enable"]("disablePowerSaving").
	}
}
function disablePowerSaving {
	if SHIP:ElectricCharge > VSL["EC_POWERSAVE"][1] {
		RT["activateAll"]().
		mission["enable"]("enablePowerSaving").
		mission["disable"]("disablePowerSaving").
	}
}

function clearFlightpath {
	until not HASNODE {
		Remove NEXTNODE.
		wait 1.
	}
	clearAlarms().
}
function clearAlarms {
	for alarm in ListAlarms("All") {
		DeleteAlarm(alarm:id).
	}
}

function preflight {
	if STATUS <> "ORBITING" return.
	if not (SHIP=KUNIVERSE:activeVessel and SHIP:unpacked) return.

	until STAGE:number = VSL["stages"]["orbital"] safeStage().

	mission["enable"]("enablePowerSaving").
	mission["enable"]("orientCraft").
	RT["activateAll"]().
	RT["setTarget"]("Mission Control","RelayAntenna50").

	print "press any key to begin...".
	TERMINAL:input:getChar().

	mission["next"]().
}
function coast {
	if not (DEFINED burn) {
		clearFlightpath().
		mission["prev"]().
	}
	else if burn["node"]:eta - 60 <= burn["preburn"]
		mission["next"]().
}
function exec {
	if not HASNODE mission["prev"]().
	else {
		RT["activateAll"]().
		MNV["execute"](burn["throttle"]).
		enablePowerSaving().
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
	set burn to MNV["changeInc"](0,"highest").
	mission["next"]().
}
function changePe25 {
	set burn to MNV["changePe"](25000).
	mission["next"]().
}
function idleTillCrash {
	mission["disable"]("orientCraft").
	mission["disable"]("checkPowerSave").
}