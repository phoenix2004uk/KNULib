{
	local EXPERIMENT_WAIT_TIME is 10.
	local SQUAD_SCIENCE_MODULE is "ModuleScienceExperiment".
	local DMAGIC_SCIENCE_MODULE is "DMModuleScienceAnimate".
	local ER_SURFACE_ONLY is -1.
	local ER_NO_PART is -2.
	local ER_NO_CONNECTION is -3.
	local ER_INOPERABLE is -4.
	local ER_HAS_DATA is -5.
	local ER_TIMED_OUT is -6.
	local ER_NO_DATA is -7.
	function usingScienceModule {
		parameter partName, moduleName, partIndex, handler.
		local experiments is SHIP:partsNamed(partName).
		if experiments:length > partIndex return handler(experiments[partIndex]:getModule(moduleName)).
		return ER_NO_PART.
	}
	function runExperiment {
		parameter partName, moduleName, doToggle, surfaceOnly, doTransmit is 1, index is 0.
		if surfaceOnly and (AIRSPEED>0.1 or STATUS="SPLASHED") return ER_SURFACE_ONLY.
		return usingScienceModule(partName, moduleName, index, {
			parameter module.
			if module:hasData return ER_HAS_DATA.
			if module:inoperable return ER_INOPERABLE.
			module:deploy.
			local startTime is TIME:seconds.
			until module:hasData if TIME:seconds-startTime > EXPERIMENT_WAIT_TIME return ER_TIMED_OUT.
			if doToggle module:toggle.
			if doTransmit {
				if not HomeConnection:isConnected return ER_NO_CONNECTION.
				else {
					module:transmit.
					wait until not module:hasData.
				}
			}
			return 0.
		}).
	}
	function transmitExperiment {
		parameter partName, moduleName, index is 0.
		if not HomeConnection:isConnected return ER_NO_CONNECTION.
		return usingScienceModule(partName, moduleName, index, {
			parameter module.
			if not module:hasData return ER_NO_DATA.
			module:transmit.
			wait until not module:hasData.
			return 0.
		}).
	}
	function resetExperiment {
		parameter partName, moduleName, index is 0.
		return usingScienceModule(partName, moduleName, index, {
			parameter module.
			if module:inoperable return ER_INOPERABLE.
			if module:hasData module:RESET.
			wait 2.
			return 0.
		}).
	}
	local runExperiments is Lex().
	local resetExperiments is Lex().
	local transmitExperiments is Lex().
	local surfaceExperiments is List("sensorAccelerometer").
	for ex in List("sensorThermometer","sensorBarometer","sensorAccelerometer","sensorGravimeter","sensorAtmosphere","science.module","GooExperiment") {
		set runExperiments[ex] to runExperiment@:bind(ex, SQUAD_SCIENCE_MODULE, 0, surfaceExperiments:CONTAINS(ex)).
		set transmitExperiments[ex] to transmitExperiment@:bind(ex, SQUAD_SCIENCE_MODULE).
		set resetExperiments[ex] to resetExperiment@:bind(ex, SQUAD_SCIENCE_MODULE).
	}
	for ex in List("dmmagBoom","rpwsAnt") {
		set runExperiments[ex] to runExperiment@:bind(ex, DMAGIC_SCIENCE_MODULE, 1, surfaceExperiments:CONTAINS(ex)).
		set transmitExperiments[ex] to transmitExperiment@:bind(ex, DMAGIC_SCIENCE_MODULE).
		set resetExperiments[ex] to resetExperiment@:bind(ex, DMAGIC_SCIENCE_MODULE).
	}
	export(Lex(
		"run", runExperiments,
		"transmit", transmitExperiments,
		"reset", resetExperiments
	)).
}