local safeStage is import("sys/safeStage").
local MNV is bundleDir("mnv").
local RT is bundleDir("rt").
local VSL is import("vessel").
local kerbinLaunch is import("asc/kerbinLaunch").

local L is bundleDir("trn").
bundleDir("asc", L).
bundleDir("mech", L).
bundleDir("mnv", L).
bundleDir("rt", L).
bundleDir("sys", L).
bundleDir("tlm", L).
bundleDir("util", L).
bundle(List("missionRunner","ord","sci"), L).

local mission is import("missionRunner")(
	List(
"preflight",	preflight@,
				launch@,
				inOrbit@,
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
	print "orientCraft":padRight(TERMINAL:width) AT (0,1).
	local orient is VSL["orient"]().
	if orient:isType("Direction") set orient to orient:vector.
	if VANG(SHIP:facing:vector,orient) > 1 {
		print "re-orienting":padRight(TERMINAL:width) AT (0,2).
		lock STEERING to VSL["orient"]().
	}
	else {
		print "stable":padRight(TERMINAL:width) AT (0,2).
	}
}
function enablePowerSaving {
	print "enablePowerSaving":padRight(TERMINAL:width) AT (0,1).
	if SHIP:ElectricCharge < VSL["EC_POWERSAVE"][0] {
		RT["deactivateAll"]().
		mission["disable"]("enablePowerSaving").
		mission["enable"]("disablePowerSaving").
	}
}
function disablePowerSaving {
	print "disablePowerSaving":padRight(TERMINAL:width) AT (0,1).
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
	print "preflight":padRight(TERMINAL:width) AT (0,1).
	//if STATUS <> "ORBITING" return.
	if not (SHIP=KUNIVERSE:activeVessel and SHIP:unpacked) return.

	//lock STEERING to VSL["orient"]().

	clearFlightpath().

	//until STAGE:number = 0 safeStage().

	//mission["enable"]("enablePowerSaving").
	//mission["enable"]("orientCraft").

	print "press any key to launch...".
	TERMINAL:input:getChar().

	mission["next"]().
}
function launch {
	print "launch":padRight(TERMINAL:width) AT (0,1).

	kerbinLaunch(100000, 90).

	mission["next"]().
}
function inOrbit {
	print "inOrbit":padRight(TERMINAL:width) AT (0,1).
	mission["enable"]("enablePowerSaving").
	mission["enable"]("orientCraft").
	RT["activateAll"]().
	RT["setTarget"]("mission-control","RelayAntenna50").

	mission["next"]().
}
function coast {
	print "coast":padRight(TERMINAL:width) AT (0,1).
	if not (DEFINED burn) {
		clearFlightpath().
		mission["prev"]().
	}
	else if burn["node"]:eta - 60 <= burn["preburn"]
		mission["next"]().
}
function exec {
	print "exec":padRight(TERMINAL:width) AT (0,1).
	if not HASNODE mission["prev"]().
	else {
		MNV["execute"]().
		mission["next"]().
	}
}
function changeAp500 {
	print "changeAp500":padRight(TERMINAL:width) AT (0,1).
	set burn to MNV["changeAp"](500000).
	mission["next"]().
}
function changePe500 {
	print "changePe500":padRight(TERMINAL:width) AT (0,1).
	set burn to MNV["changePe"](500000).
	mission["next"]().
}
function checkApsides {
	print "checkApsides":padRight(TERMINAL:width) AT (0,1).
	if ALT:apoapsis > 501000 or ALT:periapsis < 499000
		mission["jump"]("changeAp500").
	else
		mission["next"]().
}
function changeInc10 {
	print "changeInc10":padRight(TERMINAL:width) AT (0,1).
	set burn to MNV["changeInc"](10,"next").
	mission["next"]().
}
function ellipticize08 {
	print "ellipticize08":padRight(TERMINAL:width) AT (0,1).
	set burn to MNV["ellipticize"](0.8, "Pe").
	mission["next"]().
}
function waitForTarget {
	print "waitForTarget":padRight(TERMINAL:width) AT (0,1).
	if HASTARGET {
		wait 10.
		mission["next"]().
	}
}
function matchInc {
	print "matchInc":padRight(TERMINAL:width) AT (0,1).
	set burn to MNV["matchInc"](TARGET).
	mission["next"]().
}
function circularize {
	print "circularize":padRight(TERMINAL:width) AT (0,1).
	set burn to MNV["circularize"]("Ap").
	mission["next"]().
}
function changeInc0 {
	print "changeInc0":padRight(TERMINAL:width) AT (0,1).
	set burn to MNV["changeInc"](0,"highest").
	mission["next"]().
}
function changePe25 {
	print "changePe25":padRight(TERMINAL:width) AT (0,1).
	set burn to MNV["changePe"](25000).
	mission["next"]().
}
function idleTillCrash {
	print "idleTillCrash":padRight(TERMINAL:width) AT (0,1).
	mission["disable"]("orientCraft").
	mission["disable"]("checkPowerSave").
	lock STEERING to srfRetrograde.
	until 0 wait 99.
}