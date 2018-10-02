export({
	parameter alarmTime, alarmName, margin is 60.
	if margin > 0 {
		AddAlarm("Raw", alarmTime - margin, "margin", "").
	}
	return AddAlarm("Raw", alarmTime, alarmName, "").
}).