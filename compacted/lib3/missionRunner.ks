{
	local indexOf is import("util/indexOf").
	local RUNMODE_BASE_PATH is "1:/etc/run.".
	local RUNNER_STEP is 0.
	local RUNNER_TAG is 1.
	local RUNNER_SEQ is 2.
	local RUNNER_LBL is 3.
	local RUNNER_EVT is 4.
	local RUNNER_IRQ is 5.
	local RUNNER_RUNNING is 6.
	export({
		parameter sequenceList, eventList is List(), noarg is 0.
		local runner is List(
			0,
			"main",
			List(),
			Lex(),
			Lex(),
			List(),
			0
		).
		local index is 0.
		until index = eventList:length {
			runner[RUNNER_EVT]:add(eventList[index], eventList[index+1]).
			runner[RUNNER_IRQ]:add(eventList[index]).
			set index to index + 2.
		}
		set index to 0.
		until index = sequenceList:length {
			if sequenceList[index]:isType("string") {
				runner[RUNNER_LBL]:add(sequenceList[index], runner[RUNNER_SEQ]:length).
				set index to index + 1.
			}
			runner[RUNNER_SEQ]:add(sequenceList[index]).
			set index to index + 1.
		}
		local missionRunner_saveState is {
			if not runner[RUNNER_RUNNING] return.
			DeletePath(RUNMODE_BASE_PATH+runner[RUNNER_TAG]).
			Create(RUNMODE_BASE_PATH+runner[RUNNER_TAG]):write(runner[RUNNER_STEP]+","+runner[RUNNER_IRQ]:join(",")).
		}.
		local missionRunner_end is {
			set runner[RUNNER_STEP] to runner[RUNNER_SEQ]:length.
		}.
		local mission is Lex(
			"enable", {
				parameter name.
				if runner[RUNNER_EVT]:hasKey(name) and not runner[RUNNER_IRQ]:contains(name) {
					runner[RUNNER_IRQ]:add(name).
					missionRunner_saveState().
				}
			},
			"disable", {
				parameter name.
				local irqIndex is indexOf(runner[RUNNER_IRQ], name).
				if irqIndex > -1 {
					runner[RUNNER_IRQ]:remove(irqIndex).
					missionRunner_saveState().
				}
			},
			"next", {
				set runner[RUNNER_STEP] to runner[RUNNER_STEP] + 1.
				missionRunner_saveState().
			},
			"prev", {
				set runner[RUNNER_STEP] to Max(0,runner[RUNNER_STEP] - 1).
				missionRunner_saveState().
			},
			"jump", {
				parameter label.
				if runner[RUNNER_LBL]:hasKey(label) {
					set runner[RUNNER_STEP] to runner[RUNNER_LBL][label].
					missionRunner_saveState().
				}
				else missionRunner_end().
			},
			"end", missionRunner_end
		).
		local init is mission:copy.
		local runEvents is {
			for key in runner[RUNNER_EVT]:keys if runner[RUNNER_IRQ]:contains(key) {
				local event is runner[RUNNER_EVT][key].
				if noarg event(). else event(mission).
			}
		}.
		init:Add("run", {
			set runner[RUNNER_RUNNING] to 1.
			if Exists(RUNMODE_BASE_PATH+runner[RUNNER_TAG]) {
				local state is Open(RUNMODE_BASE_PATH+runner[RUNNER_TAG]):readAll:string.
				local data is state:split(",").
				set runner[RUNNER_STEP] to data[0]:toNumber(0).
				set runner[RUNNER_IRQ] to List().
				if state:endsWith(",") return.
				for irq in data:subList(1,data:length) runner[RUNNER_IRQ]:add(irq).
			}
			missionRunner_saveState().
			if runner[RUNNER_STEP] <> 0 runEvents(runner, noarg, mission).
			until runner[RUNNER_STEP] = runner[RUNNER_SEQ]:length {
				local step is runner[RUNNER_SEQ][runner[RUNNER_STEP]].
				if noarg step(). else step(mission).
				wait 0.
				runEvents(runner, noarg, mission).
				wait 0.
			}
			DeletePath(RUNMODE_BASE_PATH+runner[RUNNER_TAG]).
		}).
		init:Add("tag", {set runner[RUNNER_TAG] to name.}).
		return init.
	}).
}