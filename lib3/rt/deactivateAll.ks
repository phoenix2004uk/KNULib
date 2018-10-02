export({
	for module in SHIP:modulesNamed("ModuleRTAntenna") {
		if module:hasAction("deactivate") module:doAction("deactivate", FALSE).
	}
}).