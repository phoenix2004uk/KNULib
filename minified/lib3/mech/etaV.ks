{local Z is import("mech/E").local X is import("mech/M").export({parameter A.local B is OBT:period*(X(Z(A))-X(Z(OBT:trueAnomaly)))/360.if B<0 return B+OBT:period. return B.}).}