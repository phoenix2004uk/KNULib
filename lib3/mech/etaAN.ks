{
	local mech is bundle(List("mech/etaV","mech/Van")).
	export({
		return mech["etaV"](mech["Van"]()).
	}).
}