local safeStage is import("sys/safeStage").
local RT is bundleDir("rt").
local VSL is import("vessel").
local isFacing is import("util/isFacing").
local MNV is bundle(List("trn/transferMinmus","trn/capture", "mnv/custom", "mnv/matchInc", "mnv/changeInc", "mnv/execute")).

local minmusCaptureAltitude is 50000.

local mission is import("missionRunner")(
	List(
		preflight@,
		matchMinmusInclination@, exec@,
		transferToMinmus@, exec@,
		correctEncounter@, exec@,
"waitSoi",waitForMinmusSoi@,
		captureAtPe@, exec@,
		burnEquatorial@, exec@
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
function matchMinmusInclination {
	set burn to MNV["matchInc"](Minmus).
	mission["next"]().
}
function transferToMinmus {
	local res is MNV["transferMinmus"](minmusCaptureAltitude).
	if res:isType("string") {
		if res = "wait" {
			print "waiting for new transfer".
		}
		else if res = "occluded" {
			print "Minmus transfer occluded by Mun".
		}
		else if res = "missed" {
			print "we missed".
			mission["end"]().
		}
		wait 10.
		clearscreen.
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