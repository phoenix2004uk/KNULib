export({
	parameter partName, partIndex is 0.
	local antennae is SHIP:partsNamed(partName).
	if antennae:length > partIndex {
		local module is antennae[partIndex]:getModule("ModuleRTAntenna").
		if module:hasAction("deactivate") module:doAction("deactivate", FALSE).
	}
}).