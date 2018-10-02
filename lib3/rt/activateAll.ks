export({
	for module in SHIP:modulesNamed("ModuleRTAntenna") {
		if module:hasEvent("activate") module:doEvent("activate").
	}
}).