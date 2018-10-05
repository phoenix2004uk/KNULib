{
	local mech is bundle(List("mech/etaV","mech/Vdn")).
	export({ return mech["etaV"](mech["Vdn"]()). }).
}