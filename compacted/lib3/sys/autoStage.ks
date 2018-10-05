{
	local burnout is import("sys/burnout").
	local safeStage is import("sys/safeStage").
	export({
		parameter stageLimit is 0.
		if not burnout() return 0.
		local throt is THROTTLE.
		lock THROTTLE to 0.
		wait 0.1.
		safeStage().
		until AVAILABLETHRUST > 0 or STAGE:number = stageLimit safeStage().
		lock THROTTLE to throt.
		return 1.
	}).
}