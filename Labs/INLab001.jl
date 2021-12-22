[
	Exercise(
		"""
		At the Julia prompt, enter the following code:
		city = "Ingolstadt"
		Then enter your answer as:
		reply(city)
		""",
		"Ingolstadt",
		x -> (x=="Ingolstadt")
	),
	Exercise(
		"What instrument does Niall play?",
		"Guitar",
		x -> (lowercase(x) == "guitar")
	)
]