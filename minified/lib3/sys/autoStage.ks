{local Z is import("sys/burnout").local X is import("sys/safeStage").export({parameter A is 0.if not Z()return 0.local B is THROTTLE. lock THROTTLE to 0.wait 0.1.X().until AVAILABLETHRUST>0 or STAGE:number=A X().lock THROTTLE to B. return 1.}).}