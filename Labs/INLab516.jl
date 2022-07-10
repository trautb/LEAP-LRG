[
	Activity( # nr 1
		"""
        In this model the agents follow only 2 simple rules. 
        They sniff, to find the highest concentration of chemoattractant arround them, and turn to face that direction.
        Once found, they move in that direction and drop chemoattractants, 
        for other agents to be found. after that, the chemoattractants diffuse and evaporate.
        look at the code and check wether they go through each stage individually or together.
		""",
		"no hint here",
		x -> true
	),
    Activity( # nr 2
		"""
		play around with the sniff and wiggle radius. See how it is very important to finetune those radii for spontanious patterns to form?
        can you find other configurations, where the agents will form patterns?
		""",
		"for exampe [wiggle: 89/45, sensor:90], [wiggle: 30, sensor:44], [wiggle: 44, sensor:44] but there are more",
		x -> true
	),
    Activity( # nr 3
		"""
		Try to manipulate the sensor range, and see how the patterns become smaller or bigger.
        Jones recomends to use ranges from 6 to 12, but feel free to experiment for yourself.
		""",
		"no hint here",
		x -> true
	),
    Activity( # nr 4
		"""
		you can activate a food source, for our agents to be found. 
        Can you find te right configuration to make the agents connect those sources through the shortest path?
        Honestly i coundn't, but maybe you are smarter
		""",
		"no hint here",
		x -> true
	),
]