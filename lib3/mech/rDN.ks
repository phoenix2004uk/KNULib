// altitude (r) of DN
{
	local mech is bundle(List("mech/rV","mech/Vdn")).
	export({
		return mech["rV"](mech["Vdn"]()).
	}).
}