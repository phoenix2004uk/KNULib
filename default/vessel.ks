{
	local ORD is import("ord").
	export(Lex(

		// TODO: don't want to use this
		"launchProfile", "alt",			// [optional] specifies the launch profile, otherwise a default is used
		"launchTWR", 2.5,					// [optional] specifies the target TWR for ascent, otherwise a default is used

		"stages", Lex(					// [required] information about staging, used during launch and landing
			"lastAscent", 1,			// [required] last stage that can be used during launch
			"insertion", 1,				// [required] stage used for orbital insertion, this can be the same as lastAscent
			"orbital", 0,				// [required] stage to be in user after launch and orbital insertion, this can be the same as insertion

			// TODO: should this really be necessary? we can just fire patachutes via part module event
			"chutes", 0					// [optional] stage to fire parachutes when landing using normal landing procedure
		),

		"EC_POWERSAVE", List(3900,4100),

		"orient", ORD["sun"],

		"useCallsign", TRUE,			// [optional] useCallsign adds " 'callsign'" to the vessel name
		"setName", "PRB - 'newname'"	// [optional] setName sets the ship name to setName, unless useCallsign is true
	)).
}