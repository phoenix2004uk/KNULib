{
	local L is bundle(List("sys/burnout","sys/safeStage")).
	export({
		parameter stageLimit is 0.
		until not L["burnout"]() or STAGE:number = stageLimit {
			L["safeStage"]().
		}
	}).
}