export({parameter A.local F is AVAILABLETHRUST. if F=0 return 0.return max(0,min(1,A*MASS*BODY:mu/(F*(BODY:radius+ALTITUDE)^2))).}).