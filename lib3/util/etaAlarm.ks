export({
	parameter alarmName.
	for alarm in ListAlarms("All") {
		if alarm:name = alarmName {
			return alarm:remaining.
		}
	}
	return -1.
}).