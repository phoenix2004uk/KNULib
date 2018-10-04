{
	local L is bundle(List("sys/burnout","sys/safeStage")).
	export({
		parameter stageLimit is 0.
		if not L["burnout"]() return FALSE.
		local throt is THROTTLE.
		lock THROTTLE to 0.
		wait 0.1.
		L["safeStage"]().
		until SHIP:availableThrust > 0 or STAGE:number = stageLimit {
			L["safeStage"]().
		}
		lock THROTTLE to throt.
		return TRUE.
	}).
}