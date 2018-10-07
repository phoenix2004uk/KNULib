{local X is import("sys/constantTWR").local W is import("sys/burnout").local U is import("sys/autoStage").local T is import("sys/safeStage").local S is import("sys/changePe").local P is import("sys/circularize").local O is import("sys/execute").local N is import("util/setAlarm").local M is import("vessel").local L is "launchProfile".local K is M["stages"].function Z{local A is 90-VANG(UP:vector,SHIP:facing:vector).if A>30 return X(1.7)/SIN(A).else return 1.}function Y{parameter A,B is 90.local D is ALTITUDE. if ALTITUDE>A["a1"]set D to(ALTITUDE+APOAPSIS)/2.local F is BODY:ATM:height. if D<=A["a0"]return A["p0"].if D>=A["aN"]return A["pN"].local H is MIN(A["p0"],MAX(A["pN"],85*(LN(F)-LN(D))/(LN(F)-LN(A["a0"]))+5)).if ALTITUDE>A["a0"]set H to min(H,90-VANG(UP:vector,srfPrograde:vector)).return HEADING(B,H)+R(0,0,-90+MIN(90,MAX(0,90*(ALTITUDE-A["r0"])/A["rN"]))).}export({parameter A is 100000,B is 90.if STATUS="PRELAUNCH"{local D is Lex("a0",1000,"p0",87.5,"aN",60000,"pN",0,"a1",40000,"r0",5000,"rN",5000).if M:hasKey(L)for F in M[L]:keys set D[F]to M[L][F].lock STEERING to Y(D,B).lock THROTTLE to Z().until AVAILABLETHRUST>0 T().if STAGE:solidFuel>0{until W()set D["a0"]to ALTITUDE. T().}until APOAPSIS>=A if U(K["lastAscent"])lock THROTTLE to Z().lock THROTTLE to 0.}until STAGE:number=K["insertion"]T().if PERIAPSIS<10000{wait until ALTITUDE>BODY:ATM:height. lock STEERING to M["orient"]().PANELS ON.LIGHTS ON.local H is S(15000).set H["node"]:eta to ETA:apoapsis-(H["fullburn"]+5).DeleteAlarm(H["alarm"]:ID).N(TIME:seconds+H["node"]:eta,"insertion",0).O().}until STAGE:number=K["orbital"]T().if PERIAPSIS<BODY:ATM:height{if ETA:apoapsis>ETA:periapsis{lock STEERING to PROGRADE. wait until VANG(SHIP:facing:vector,PROGRADE:vector)<1.lock THROTTLE to 1.wait until PERIAPSIS>BODY:ATM:height. lock THROTTLE to 0.lock STEERING to M["orient"]().}P("Ap").O().}}).}