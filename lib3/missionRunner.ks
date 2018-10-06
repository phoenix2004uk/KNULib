//	run()			// runs the mission
//	enable(name)	// enable the event "name"
//	disable(name)	// disable the event "name"
//	next()			// proceed to next step in the sequence
//	prev()			// jumps to the previous step
//	jump(label)		// jump the mission to the named step "label"
//	end()			// ends the mission (regardless of current step in the sequence)
//  tag(name)		// sets the name of the mission, can only be called before run() is called
//					//   this will be the tag that is used for the persistent state file stored in /etc/
//					//   if not specified, the default will be "main"

// export() should return the mission object, which is also passed as an argument to each step and event
//   this allows events to be enabled/disabled before running the mission
// calling "run" on the mission object, will start the sequence

// the mission sequence is a list of string labels and function delegates
// if a string is encountered, it is set as the label for the following delegate in the sequence
//   if a delegate does not have a string label, then it's index in the sequence (ignoring labels) is it's "label"

// calling jump(label) with an invalid label, will end() the mission after displaying a message
//   this allows a the knu os process to continue and download new instructions

// calling enable(name) / disable(name) with an invalid event "name", will do nothing and the mission will continue as normal
//   an error message should be printed or displayed on screen

// steps and events should not be able to call the run() command on the mission object
//   we should maybe remove the run() entry from the mission object once the sequence has started

// every mission "tick" we should check if the runmode has changed, or if any events have been enabled/disabled
//   if so we need to update the persistent state of the mission in /etc/tag.run
{

	local indexOf is import("util/indexOf").
	local RUNMODE_BASE_PATH is "1:/etc/run.".

	function runEvents {
		parameter runner, noarg, mission.
		for key in runner["evt"]:keys if runner["irq"]:contains(key) {
			local event is runner["evt"][key].
			if noarg event(). else event(mission).
		}
	}

	function missionRunner_run {
		parameter runner, noarg.

		// to prevent events that are disabled before run, from over-writing a saved state
		set runner["running"] to TRUE.

		missionRunner_loadState(runner).
		missionRunner_saveState(runner).

		local mission is Lex(
			"enable",	missionRunner_enable@:bind(runner),
			"disable",	missionRunner_disable@:bind(runner),
			"next",		missionRunner_next@:bind(runner),
			"prev",		missionRunner_previous@:bind(runner),
			"jump",		missionRunner_jump@:bind(runner),
			"end",		missionRunner_end@:bind(runner)
		).

		// if resuming from a saved state, run the events before resuming the mission sequence
		if runner["step"] <> 0 runEvents(runner, noarg, mission).

		until runner["step"] = runner["seq"]:length {
			// print runner["step"] + " / " + runner["seq"]:length at (0,0).
			local step is runner["seq"][runner["step"]].
			if noarg step(). else step(mission).
			wait 0.

			runEvents(runner, noarg, mission).
			wait 0.
		}

		missionRunner_cleanup(runner).
	}
	function missionRunner_cleanup {
		parameter runner.
		DeletePath(RUNMODE_BASE_PATH + runner["tag"]).
	}

	function encode_state {
		parameter runner.
		return runner["step"]+","+runner["irq"]:join(",").
	}
	function decode_state {
		parameter state, runner.
		local data is state:split(",").
		set runner["step"] to data[0]:toNumber(0).
		set runner["irq"] to List().
		if not state:endsWith(",") {
			for irq in data:subList(1,data:length) {
				runner["irq"]:add(irq).
			}
		}
	}

	function missionRunner_loadState {
		parameter runner.
		if Exists(RUNMODE_BASE_PATH + runner["tag"]) {
			decode_state(Open(RUNMODE_BASE_PATH + runner["tag"]):readAll:string, runner).
		}
	}
	function missionRunner_saveState {
		parameter runner.
		if runner["running"] {
			DeletePath(RUNMODE_BASE_PATH + runner["tag"]).
			Create(RUNMODE_BASE_PATH + runner["tag"]):write(encode_state(runner)).
		}
	}

	function missionRunner_enable {
		parameter runner, name.
		if runner["evt"]:hasKey(name) and not runner["irq"]:contains(name) {
			runner["irq"]:add(name).
			missionRunner_saveState(runner).
		}
	}

	function missionRunner_disable {
		parameter runner, name.
		local index is indexOf(runner["irq"], name).
		if index > -1 {
			runner["irq"]:remove(index).
			missionRunner_saveState(runner).
		}
	}
	function missionRunner_previous {
		parameter runner.
		set runner["step"] to Max(0,runner["step"] - 1).
		missionRunner_saveState(runner).
	}
	function missionRunner_next {
		parameter runner.
		set runner["step"] to runner["step"] + 1.
		missionRunner_saveState(runner).
	}
	function missionRunner_jump {
		parameter runner, label.
		if runner["lbl"]:hasKey(label) {
			set runner["step"] to runner["lbl"][label].
			missionRunner_saveState(runner).
		}
		else missionRunner_end(runner).
	}
	function missionRunner_end {
		parameter runner.
		set runner["step"] to runner["seq"]:length.
	}
	function missionRunner_tag {
		parameter runner, name.
		set runner["tag"] to name.
	}

	function missionRunner {
		parameter sequenceList, eventList is List(), noarg is FALSE.

		local runner is Lex(
			"step", 0,
			"tag", "main",
			"seq", List(),
			"lbl", Lex(),
			"evt", Lex(),
			"irq", List(),
			"running", FALSE
		).

		local index is 0.
		until index = eventList:length {
			runner["evt"]:add(eventList[index], eventList[index+1]).
			runner["irq"]:add(eventList[index]).
			set index to index + 2.
		}

		set index to 0.
		until index = sequenceList:length {
			if sequenceList[index]:typename = "string" {
				runner["lbl"]:add(sequenceList[index], runner["seq"]:length).
				set index to index + 1.
			}
			runner["seq"]:add(sequenceList[index]).
			set index to index + 1.
		}

		local init is Lex(
			"run",		missionRunner_run@:bind(runner,noarg),
			"tag",		missionRunner_tag@:bind(runner),
			"enable",	missionRunner_enable@:bind(runner),
			"disable",	missionRunner_disable@:bind(runner),
			"next",		missionRunner_next@:bind(runner),
			"prev",		missionRunner_previous@:bind(runner),
			"jump",		missionRunner_jump@:bind(runner),
			"end",		missionRunner_end@:bind(runner)
		).

		return init.
	}

	export(missionRunner@).
}