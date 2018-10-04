{
	local ORD is import("ord").
	export(Lex(

		// TODO: don't want to use this
		// launchProfile, Lex()			// [optional]

		"stages", Lex(					// [required] information about staging, used during launch and landing
			"lastAscent", 2,			// [required] last stage that can be used during launch
			"insertion", 2,				// [required] stage used for orbital insertion, this can be the same as lastAscent
			"orbital", 1,				// [required] stage to be in user after launch and orbital insertion, this can be the same as insertion

			// TODO: should this really be necessary? we can just fire patachutes via part module event
			"chutes", 0					// [optional] stage to fire parachutes when landing using normal landing procedure
		),

		"EC_POWERSAVE", List(200,500),
		"EC_CRITICAL", 10,

		"orient", ORD["pro"],

		"useCallsign", TRUE,			// [optional] useCallsign adds " 'callsign'" to the vessel name
		"setName", "PRB - 'newname'"	// [optional] setName sets the ship name to setName, unless useCallsign is true
	)).
}