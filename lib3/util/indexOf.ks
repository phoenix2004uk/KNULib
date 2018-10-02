export({
	parameter array, value.
	local index is 0.
	until index = array:length {
		if array[index] = value return index.
		else set index to index + 1.
	}
	return -1.
}).