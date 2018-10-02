local safeStage is import("sys/safeStage").
local execute is import("mnv/execute").
local RT is bundleDir("rt").
local VSL is import("vessel").
local isFacing is import("util/isFacing").
local TRN is bundle(List("trn/transferMun","trn/capture")).

local mission is import("missionRunner")(
	List(
		preflight@,
		transferToMun@,	coast@, exec@,
		waitForMunSoi@,
		captureAtPe@, coast@, exec@
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
		execute().
		enablePowerSaving().
		mission["next"]().
	}
}
function transferToMun {
	local res is TRN["transferMun"](25000).
	if res = "wait" {
		print "waiting for new transfer".
		wait 10.
		clearscreen.
		return.
	}
	else if res = "missed" {
		print "we missed".
		mission["end"]().
	}
	else {
		set burn to res.
		mission["next"]().
	}
}
function waitForMunSoi {
	if BODY = Mun {
		wait 30.
		mission["next"]().
	}
}
function captureAtPe {
	set burn to TRN["capture"](PERIAPSIS).
	mission["next"]().
}