{
	local ORD is import("ord").
	export(Lex(

		// TODO: don't want to use this
		"launchProfile", "default",		// [required] local launchProfile is ASC["defaultProfile"].

		"stages", Lex(					// [required] information about staging, used during launch and landing
			"insertion", 4,				// [required] last stage that can be used during launch

			// TODO: orbital shouldn't be required - just stage until thrust is available after insertion stage is dropped
			"orbital", 3,				// [required] stage to be in user after launch and orbital insertion

			// TODO: should this really be necessary? we can just fire patachutes via part module event
			"chutes", 1					// [optional] stage to fire parachutes when landing using normal landing procedure
		),

		"EC_POWERSAVE", List(3900,4100),

		"orient", ORD["sun"],

		"useCallsign", TRUE,			// [optional] useCallsign adds " 'callsign'" to the vessel name
		"setName", "PRB - 'newname'"	// [optional] setName sets the ship name to setName, unless useCallsign is true
	)).
}