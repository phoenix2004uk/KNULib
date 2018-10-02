{
	local importing is Stack().
	local cache is Lex().
	global function import {
		parameter name, src is "0:/lib3/", dst is "1:/lib/".
		if not cache:hasKey(name) {
			waitForKSC().
			local filename is src + name.
			if Exists(filename + "-min")
				download(filename + "-min", dst + name).
			else if Exists(filename)
				download(filename, dst + name).
			else panic("no lib: " + name).

			RunPath(dst + name).
			cache:Add(name, importing:pop).
		}
		return cache[name].
	}
	global function export {
		parameter data.
		importing:push(data).
	}
	function enoughLocalSpace {
		parameter src.
		return Open(path(src)):size <= Volume(1):freeSpace.
	}
	global function download {
		parameter src, dst.
		if enoughLocalSpace(src) CopyPath(src, dst).
		else panic("too big: " + src).
	}
}
function bundle {
	parameter names, bnd is Lex().
	for name in names {
		local key is path(name):name.
		set bnd[key] to import(name).
	}
	return bnd.
}
function bundleDir {
	parameter libDir, bnd is Lex().
	local dir is Open("0:/lib3/" + libDir + "/").
	for file in dir:list:values {
		local lib is path(file):name:replace(".ks","").
		if file:isFile {
			set bnd[lib] to import(libDir + "/" + lib).
		}
	}
	return bnd.
}
function waitForKSC {
	wait until HomeConnection:isConnected.
}
function panic {
	parameter message.
	HudText(message,5,2,30,RED,TRUE).
	wait 60.
	Reboot.
}
function notify {
	parameter message, echo is FALSE.
	HudText(message, 5, 4, 20, CYAN, echo).
}
{
	function setVesselCallsign {
		set core:part:tag to core:part:uid.
	}
	function getVesselCallsign {
		if core:tag = "" setVesselCallsign().
		return core:tag.
	}
	function buildVesselFilename {
		parameter filename.
		return "0:/KSC/" + getVesselCallsign + "/" + filename.
	}
	function downloadVesselData {
		if Exists(buildVesselFilename("vessel")) {
			download(buildVesselFilename("vessel"), "1:/vessel").
		}
		else {
			download("0:/default/vessel", "1:/vessel").
		}
	}

	function startupFileAvailable {
		return Exists(buildVesselFilename("startup")).
	}
	function downloadStartupFile {
		download(buildVesselFilename("startup"), "1:/startup").
	}
	function startupFileExists {
		return Exists("1:/startup").
	}
	function runStartupFile {
		RunPath("1:/startup").
	}

	function missionFileExists {
		return Exists("1:/main").
	}
	function newMissionAvailable {
		waitForKSC().
		return Exists(buildVesselFilename("main")).
	}
	function downloadNewMission {
		local mainFile is buildVesselFilename("main").
		download(mainFile, "1:/main").
		DeletePath(mainFile).
	}
	function runMissionFile {
		RunPath("1:/main").
	}

	function cleanupFiles {
		DeletePath("1:/main").
	}

	set SHIP:control:pilotMainThrottle to 0.
	if STATUS = "PRELAUNCH" {
		if not HomeConnection:isConnected {
			panic("no connection").
		}
		downloadVesselData().
		if startupFileAvailable() {
			downloadStartupFile().
		}
	}

	if startupFileExists() runStartupFile().

	if not missionFileExists() {
		if not newMissionAvailable() {
			wait 60.
			Reboot.
		}
		downloadNewMission().
	}


	runMissionFile().
	cleanupFiles().
	Reboot.
}