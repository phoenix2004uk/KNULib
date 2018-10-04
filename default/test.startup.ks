wait until KUNIVERSE:activeVessel=SHIP and SHIP:unpacked.
clearscreen.
import("vessel","1:/","1:/").
SAS OFF.
set SHIP:control:pilotMainThrottle to 0.

// set some action groups
ON AG1 {CORE:DoEvent("open terminal").PRESERVE.}
ON AG2 {REBOOT.}
ON AG3 {KUniverse:REVERTTOLAUNCH().}
ON ABORT {KUniverse:REVERTTO("VAB").}
TOGGLE AG1.