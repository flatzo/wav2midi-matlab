function note = note(freq)
	note = 12 * log2( freq / 440 ) / log2(2);
end