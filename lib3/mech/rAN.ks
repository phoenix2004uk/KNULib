// altitude (r) of AN
{
	local mech is bundle(List("mech/rV","mech/Van")).
	export({
		return mech["rV"](mech["Van"]()).
	}).
}