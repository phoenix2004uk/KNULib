{
	local DB is Lex().

	DB:add("stock", Lex(
		"Kerbol",	List(18e3,	600e3,	1e9),
		"Moho",		List(0,		0,		80e3),
		"Eve",		List(22e3,	90e3,	400e3),
		"Gilly",	List(0,		0,		6e3),
		"Kerbin",	List(18e3,	70e3,	250e3),
		"Mun",		List(0,		0,		60e3),
		"Minmus",	List(0,		0,		30e3),
		"Duna",		List(12e3,	50e3,	140e3),
		"Ike",		List(0,		0,		50e3),
		"Dres",		List(0,		0,		25e3),
		"Jool",		List(120e3,	200e3,	4e6),
		"Laythe",	List(10e3,	50e3,	200e3),
		"Vall",		List(0,		0,		90e3),
		"Tylo",		List(0,		0,		250e3),
		"Bop",		List(0,		0,		25e3),
		"Pol",		List(0,		0,		22e3),
		"Eeloo",	List(0,		0,		60e3)
	)).

// assume this is fine to detect OPM
if DEFINED Sarnus {
	DB:add("OPM", Lex(
		"Sarnus",	List(275e3,	580e3,	3.5e6),
		"Hale",		List(0,		0,		7500),
		"Ovok",		List(0,		0,		20e3),
		"Slate",	List(0,		0,		216e3),
		"Tekto",	List(20e3,	95e3,	208e3),

		"Urlum",	List(113e3,	325e3,	1.45e6),
		"Polta",	List(0,		0,		208e3),
		"Priax",	List(0,		0,		50e3),
		"Tal",		List(0,		0,		20e3),
		"Wal",		List(0,		0,		216e3),

		"Neidon",	List(100e3,	260e3,	1.5e6),
		"Nissee",	List(0,		0,		20e3),
		"Thatmo",	List(12e3,	35e3,	216e3),

		"Plock",	List(0,		0,		118e3),
		"Karen",	List(0,		0,		53100)
	)).
}

	export(DB).
}