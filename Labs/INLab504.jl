"""
Lab504 is part of the Boids chapter

Author: Nial Pallfreyman, Emilio Borrelli
"""


[
	Activity( # nr 1
		"""
		This Chapter focuses on Behaviour, that is both emergent and collective.
        Each agent follows 3 simple , wich results in all agents moving in the same direction.
        Look at the code and tell me what rules that are give me the reply like this:
        ["rule1", "rule2", "rule3"]
		""",
		" match, cohere, seperate ",
		x -> x==["match", "cohere", "seperate"]
	),
    Activity( # nr 2
		"""
		Now run the simulation. I equiped it with sliders, that let you manipulate those rules.
        try unbalancing or completely turning those rules off and see how it influences the agent's behaviour
		""",
		"no hint here",
		x -> true
	),
    Activity( # nr 3
		"""
		Study the code and try to understand how the rules are implemented.
        Do the agents communicate with each other?
        return your answer like this: "true", "false"
		""",
		" they don't communicate, everybody just follows its own rules ",
		x -> x=="true"
	),
]