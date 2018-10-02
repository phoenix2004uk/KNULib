{
	local L is bundle(List("sys/burnout","sys/safeStage")).
	export({
		parameter stageLimit is 0.
		if not L["burnout"]() return FALSE.
		local throt is THROTTLE.
		lock THROTTLE to 0.
		wait 0.1.
		until not L["burnout"]() or STAGE:number = stageLimit {
			L["safeStage"]().
			wait 0.1.
		}
		wait 0.5.
		lock THROTTLE to throt.
		return TRUE.
	}).
}