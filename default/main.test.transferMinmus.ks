local safeStage is import("sys/safeStage").
local RT is bundleDir("rt").
local VSL is import("vessel").
local isFacing is import("util/isFacing").
local MNV is bundle(List("trn/transferMinmus","trn/capture", "mnv/custom", "mnv/matchInc", "mnv/changeInc", "mnv/execute")).

local minmusCaptureAltitude is 50000.

local mission is import("missionRunner")(
	List(
		preflight@,
		matchMinmusInclination@, coast@, exec@,
		transferToMinmus@,	coast@, exec@,
		correctEncounter@, coast@, exec@,
"waitSoi",waitForMinmusSoi@,
		captureAtPe@, coast@, exec@,
		burnEquatorial@, coast@, exec@
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
function matchMinmusInclination {
	set burn to MNV["matchInc"](Minmus).
	mission["next"]().
}
function transferToMinmus {
	local res is MNV["transferMinmus"](minmusCaptureAltitude).
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
function correctEncounter {
	// make sure we are in a prograde orbit
	if SHIP:OBT:nextPatch:inclination < 90 and SHIP:OBT:nextPatch:periapsis > minmusCaptureAltitude+1e3 and SHIP:OBT:nextPatch:periapsis < minmusCaptureAltitude-1e3 {
		mission["jump"]("waitSoi").
	}
	else {
		local tmp is Node(TIME:seconds + 30, 0, 0, 0).
		Add tmp.
		local lock incMinmus to tmp:OBT:nextPatch:inclination.
		local lock peMinmus to tmp:OBT:nextPatch:periapsis.
		if incMinmus > 90 or peMinmus < minmusCaptureAltitude-1e3 {
			until incMinmus < 90 and peMinmus > minmusCaptureAltitude-1e3 set tmp:prograde to tmp:prograde - 0.001.
		}
		else if peMinmus > minmusCaptureAltitude+1e3 {
			until peMinmus < minmusCaptureAltitude+1e3 set tmp:prograde to tmp:prograde + 0.001.
		}
		Remove tmp.
		set burn to MNV["custom"](TIME:seconds + 30, 0, 0, tmp:prograde, 0.001).
		mission["next"]().
	}
}
function waitForMinmusSoi {
	// set an alarm
	if BODY = Minmus {
		wait 30.
		mission["next"]().
	}
}
function captureAtPe {
	set burn to MNV["capture"](PERIAPSIS).
	mission["next"]().
}
function burnEquatorial {
	set burn to MNV["changeInc"](0,"next").
	mission["next"]().
}