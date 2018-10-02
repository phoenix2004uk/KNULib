export({
	parameter target_orbitable is TARGET, source_orbitable is SHIP.

	local src_r is source_orbitable:position - BODY:position.
	local src_v is source_orbitable:velocity:orbit.

	local tgt_r is target_orbitable:position - BODY:position.
	local tgt_v is target_orbitable:velocity:orbit.

	// angular momentum
	// h = r x v
	local src_h is VCRS(src_r,src_v).
	local tgt_h is VCRS(tgt_r,tgt_v).

	return VANG(src_h, tgt_h).
}).