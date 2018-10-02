{
	local VisViva is import("mech/VisViva").
	local maneuverTime is import("mnv/maneuverTime").
	local setAlarm is import("util/setAlarm").
	local exec is import("mnv/execute").
	local RDV is bundle(List("rdv/transferAnomalyCirc","rdv/transferEtaCirc","mech/S")).

	function calculateDV {
		parameter newAp.
		local newSMA is (newAp + ALT:periapsis)/2 + BODY:radius.
		local Uap_start is VisViva(SHIP:OBT:semiMajorAxis, ALT:periapsis).
		local Uap_end is VisViva(newSMA, ALT:periapsis).
		return Uap_end - Uap_start.
	}

// don't need to use this anymore, we can just check if Mun is the target body of our maneuver node instead
//	// if Mun is between -15 and +30 degress of Minmus, we will enter Mun soi
//	function munOccludesMinmusTransfers {
//		local U0_mun is RDV["S"](Mun).
//		local U0_minmus is RDV["S"](Minmus).
//		local U0_delta is U0_mun - U0_minmus.
//		return U0_delta >= -15 and U0_delta <= 30 .
//	}

	// returns string "wait" if we are too close to the transfer point to perform the burn
	// returns string "occluded" if Mun is in the way of Minmus
	// returns string "missed" if we do not get an encounter
	// otherwise returns the usual Lex of node,preburn,fullburn,alarm
	export({
		parameter targetPe, thrustFactor is 1, margin is 60.

		// TODO: Enhancement - correct relative inclination if possible
		// currently will be required to correct inclination first

		local dv is calculateDV(Minmus:altitude - Minmus:soiRadius).
		local dvMax is calculateDV(Minmus:altitude + Minmus:soiRadius).
		local halfBurnDuration is maneuverTime(dv / 2, thrustFactor).

		local Vtransfer is RDV["transferAnomalyCirc"](0, Minmus).
		local nodeEta is RDV["transferEtaCirc"](Vtransfer, Minmus).

		if nodeEta < halfBurnDuration {
			return "wait".
		}
		local nodeTime is TIME:seconds + nodeEta.
		local mnv is NODE(nodeTime, 0, 0, dv).

		// try and reduce periapsis to targetPe
		// if not, but we are in Minmus soi, get bestDv value found
		local minPe is Minmus:soiRadius.
		local bestDv is 0.
		until mnv:orbit:body = Minmus and mnv:orbit:periapsis <= targetPe {
			set mnv:prograde to mnv:prograde + 0.005.

			if mnv:orbit:body = Minmus {
				set bestDv to mnv:orbit:prograde.
				if mnv:orbit:periapsis <= minPe {
					set minPe to mnv:orbit:periapsis.
				} else {
					set mnv:prograde to mnv:prograde - 0.005.
					break.
				}
			}

			if mnv:prograde > dvMax {
				break.
			}
		}
		if mnv:orbit:body <> Minmus {
			if bestDv > 0 {
				set mnv:prograde to bestDv.
			}
			else if mnv:orbit:body = Mun {
				return "occluded".
			}
			else {
				return "missed".
			}
		}

		set halfBurnDuration to maneuverTime(mnv:prograde / 2, thrustFactor).
		local fullBurnDuration is maneuverTime(mnv:prograde, thrustFactor).
		local alarm is setAlarm(nodeTime - halfBurnDuration, "transferMun " + round(mnv:orbit:periapsis/1000,3), margin).

		ADD mnv.

		return Lex("node",mnv,"preburn",halfBurnDuration,"fullburn",fullBurnDuration,"alarm",alarm).
	}).
}