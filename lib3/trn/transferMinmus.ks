{
	local VisViva is import("mech/VisViva").
	local maneuverTime is import("mnv/maneuverTime").
	local setAlarm is import("util/setAlarm").
	local exec is import("mnv/execute").
	local TRN is bundle(List("trn/transferAnomalyCirc","trn/transferEtaCirc","mech/S")).

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
//		local U0_mun is TRN["S"](Mun).
//		local U0_minmus is TRN["S"](Minmus).
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

		local Vtransfer is TRN["transferAnomalyCirc"](0, Minmus).
		local nodeEta is TRN["transferEtaCirc"](Vtransfer, Minmus).

		if nodeEta < halfBurnDuration {
			return "wait".
		}
		local nodeTime is TIME:seconds + nodeEta.
		local mnv is NODE(nodeTime, 0, 0, dv).
		Add mnv.

		// try and reduce periapsis to targetPe
		// if not, but we are in Minmus soi, get bestDv value found
		local minPe is Minmus:soiRadius.
		local bestDv is 0.
		until mnv:orbit:hasNextPatch and mnv:orbit:nextPatch:body = Minmus and mnv:orbit:nextPatch:periapsis <= targetPe {
			set mnv:prograde to mnv:prograde + 0.001.

			if mnv:orbit:hasNextPatch and mnv:orbit:nextPatch:body = Minmus {
				set bestDv to mnv:prograde.
				if mnv:orbit:nextPatch:periapsis <= minPe {
					set minPe to mnv:orbit:nextPatch:periapsis.
				} else {
					set mnv:prograde to mnv:prograde - 0.001.
					break.
				}
			}

			if mnv:prograde > dvMax {
				break.
			}
		}
		if (not mnv:orbit:hasNextPatch) or mnv:orbit:nextPatch:body <> Minmus {
			if bestDv > 0 {
				set mnv:prograde to bestDv.
			}
			else {
				Remove mnv.
				if mnv:orbit:hasNextPatch and mnv:orbit:body = Mun {
					return "occluded".
				}
				else {
					return "missed".
				}
			}
		}

		set halfBurnDuration to maneuverTime(mnv:prograde / 2, thrustFactor).
		local fullBurnDuration is maneuverTime(mnv:prograde, thrustFactor).
		local alarm is setAlarm(nodeTime - halfBurnDuration, "transferMinmus " + round(mnv:orbit:nextPatch:periapsis/1000,3), margin).

		return Lex("node",mnv,"preburn",halfBurnDuration,"fullburn",fullBurnDuration,"alarm",alarm,"throttle",thrustFactor).
	}).
}