{
	local VisViva is import("mech/VisViva").
	local maneuverTime is import("mnv/maneuverTime").
	local setAlarm is import("util/setAlarm").
	local exec is import("mnv/execute").
	local TRN is bundle(List("trn/transferAnomalyCirc","trn/transferEtaCirc")).

	function calculateDV {
		parameter newAp.
		local newSMA is (newAp + ALT:periapsis)/2 + BODY:radius.
		local Uap_start is VisViva(SHIP:OBT:semiMajorAxis, ALT:periapsis).
		local Uap_end is VisViva(newSMA, ALT:periapsis).
		return Uap_end - Uap_start.
	}

	// returns string "wait" if we are too close to the transfer point to perform the burn
	// returns string "missed" if we do not get an encounter
	// otherwise returns the usual Lex of node,preburn,fullburn,alarm
	export({
		parameter targetPe, thrustFactor is 1, margin is 60.

		local dv is calculateDV(Mun:altitude - Mun:soiRadius).
		local dvMax is calculateDV(Mun:altitude + Mun:soiRadius).
		local halfBurnDuration is maneuverTime(dv / 2, thrustFactor).

		print "initial deltaV calculations ["+round(dv,2)+" - "+round(dvMax,2)+"]".

		local Vtransfer is TRN["transferAnomalyCirc"](0, Mun).
		local nodeEta is TRN["transferEtaCirc"](Vtransfer, Mun).

		print "transfer @"+round(Vtransfer,2)+" in "+round(nodeEta,2).

		if nodeEta < halfBurnDuration {
			return "wait".
		}
		local nodeTime is TIME:seconds + nodeEta.
		local mnv is NODE(nodeTime, 0, 0, dv).
		Add mnv.

		// try and reduce periapsis to targetPe
		// if not, but we are in Mun soi, get bestDv value found
		local minPe is Mun:soiRadius.
		local bestDv is 0.
		until mnv:orbit:hasNextPatch and mnv:orbit:nextPatch:body = Mun and mnv:orbit:nextPatch:periapsis <= targetPe {
			set mnv:prograde to mnv:prograde + 0.01.

			if mnv:orbit:hasNextPatch and mnv:orbit:nextPatch:body = Mun {
				set bestDv to mnv:prograde.
				if mnv:orbit:nextPatch:periapsis <= minPe {
					set minPe to mnv:orbit:nextPatch:periapsis.
				} else {
					set mnv:prograde to mnv:prograde - 0.01.
					break.
				}
			}

			if mnv:prograde > dvMax {
				break.
			}
		}
		if mnv:orbit:hasNextPatch and mnv:orbit:nextPatch:body <> Mun {
			if bestDv > 0 {
				set mnv:prograde to bestDv.
			}
			else {
				Remove mnv.
				return "missed".
			}
		}

		print "found transfer of " + mnv:prograde + "m/s".

		set halfBurnDuration to maneuverTime(mnv:prograde / 2, thrustFactor).
		local fullBurnDuration is maneuverTime(mnv:prograde, thrustFactor).
		local alarm is setAlarm(nodeTime - halfBurnDuration, "transferMun " + round(mnv:orbit:nextPatch:periapsis/1000,3), margin).

		return Lex("node",mnv,"preburn",halfBurnDuration,"fullburn",fullBurnDuration,"alarm",alarm).
	}).
}