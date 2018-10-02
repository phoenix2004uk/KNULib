export({
	parameter alarmTime, alarmName, margin is 30.
	if margin > 0 {
		AddAlarm("Raw", alarmTime - margin, alarmName + " margin", "").
	}
	AddAlarm("Raw", alarmTime, alarmName, "").
}).