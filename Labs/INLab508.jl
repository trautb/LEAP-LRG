[
	Activity( # nr 1
		"""
		This Chapter focuses on the Differential Adhesion Hypothesis.
        The agents define themeselfes by different levels of adhesion.
        again, they follow three simple steps, that make them form struktures/organize themeselfes.
        Look at the code and tell me those steps like this ["step1","step2","step2"]
		""",
		" adhere, repel, meander   (the order is important for the solution)",
		x -> x==["adhere","repel","meander"]
	),
    Activity( # nr 2
		"""
		Make sure you understand how the rules work. Run the simulation
		""",
		"no hint here",
		x -> true
	),
    Activity( # nr 3
		"""
		no go the model_step!() method (line 82) and put a # infront of one of the rules
        now study how it is important, that all 3 rules are present, so that organisation can emmerge
		""",
		" no hint here ",
		x -> true
	),
]