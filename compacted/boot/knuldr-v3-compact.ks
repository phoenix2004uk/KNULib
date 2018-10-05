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
}
function bundle {
	parameter names, bnd is Lex().
	for name in names {
		set bnd[path(name):name] to import(name).
	}
	return bnd.
}
function bundleDir {
	parameter libDir, bnd is Lex().
	for file in Open("0:/lib3/" + libDir + "/"):list:values {
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
function download {
	parameter src, dst.
	//if enoughLocalSpace(src) CopyPath(src, dst).
	if Open(path(src)):size <= Volume(1):freeSpace CopyPath(src, dst).
	else panic("too big: " + src).
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
	function buildVesselFilename {
		parameter filename.
		if core:tag = "" set core:part:tag to core:part:uid.
		return "0:/KSC/" + core:tag + "/" + filename.
	}

	if STATUS = "PRELAUNCH" {
		if not HomeConnection:isConnected {
			panic("no connection").
		}

		// downloadVesselData()
		if Exists(buildVesselFilename("vessel")) {
			download(buildVesselFilename("vessel"), "1:/vessel").
		}
		else {
			download("0:/default/vessel", "1:/vessel").
		}

		// if startupFileAvailable()
		if Exists(buildVesselFilename("startup")) {
			// downloadStartupFile()
			download(buildVesselFilename("startup"), "1:/startup").
		}
	}

	// if startupFileExists() runStartupFile()
	if Exists("1:/startup") RunPath("1:/startup").

	//if not missionFileExists() {
	if not Exists("1:/main") {
		//if not newMissionAvailable() {
		waitForKSC().
		if not Exists(buildVesselFilename("main")) {
			wait 60.
			Reboot.
		}
		//downloadNewMission().
		local mainFile is buildVesselFilename("main").
		download(mainFile, "1:/main").
		DeletePath(mainFile).
	}

	// runMissionFile().
	RunPath("1:/main").
	//cleanupFiles().
	DeletePath("1:/main").
	Reboot.
}