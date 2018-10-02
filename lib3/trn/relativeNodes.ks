{
	local degmod is import("util/degmod").
	// finds the relative AN/DN between 2 orbitables
	// returns a Lexicon with keys "AN","DN","next","other"
	//  - AN/DN: the true anomaly of the AN/DN nodes
	//  - next: either "AN" or "DN" depending which is the next node
	//  - other: the opposite of next
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

		// line of nodes
		local v_nodes is VCRS(src_h, tgt_h).

		// vector normal of line of nodes and position vector
		local v_nodes_normal is VCRS(src_h, v_nodes).

		// angle between nodes normal and position tells us which half of the orbit we are in
		local ang_position is VANG(src_r, v_nodes_normal).

		// angle between current position and line of nodes is the AN
		local ang_to_an is VANG(v_nodes,src_r).
		local ang_to_dn is VANG(-v_nodes,src_r).

		local result is Lex().
		// since angle to AN/DN is relative, depending on which half of the orbit we are in
		// we need to add twice the angle difference of the next node to the other node
		// now we know which node is the next node
		if ang_position > 90 {
			set ang_to_dn to ang_to_dn + 2*ang_to_an.
			set result["next"] to "AN".
			set result["other"] to "DN".
		}
		else {
			set ang_to_an to ang_to_an + 2*ang_to_dn.
			set result["next"] to "DN".
			set result["other"] to "AN".
		}
		set result["AN"] to degmod(source_orbitable:OBT:trueAnomaly+ang_to_an).
		set result["DN"] to degmod(source_orbitable:OBT:trueAnomaly+ang_to_dn).

		return result.
	}).
}