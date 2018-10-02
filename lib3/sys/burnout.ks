export({
	local engineList is List().
	LIST ENGINES in engineList.
	for en in engineList {
		if en:flameout and en:tag<>"sep" {
			return TRUE.
		}
	}
	return FALSE.
}).