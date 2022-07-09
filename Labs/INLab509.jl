#========================================================================================#
#	Laboratory 509
#
# Welcome to course 509: A stabalisation-process with particles moving around a world.
#
# Author: Niall Palfreyman (24/04/2022), Dominik Pfister (July 2022)
#========================================================================================#
[
	Activity( # nr 1
		"""
		Welcome to Lab 509: Stabalisation.
        In this lab you will observe the stabilisation behaviour of particles, which move
        around in random directions. Their simple ruleset makes them move slower when they
        are near other particles and speeds them up when they don't have particles nearby.

        This lab contains a new function that will be explained in the next activity.
		""",
		"???",
		x -> true
	),
    Activity( # nr 2
		"""
		The mentioned function is neighbors4(agent, model) and is also implemented in 
        the AgentToolBox. 
        This function collects all the ids of agents that are on the four patches next to
        the given agent or closer. If there is one agent nearby the given agent it would
        result in an array containing one id, the id of that agent.
        If there were mutliple agents near the given agent the array would contain all 
        their ids and if there were none nearby the array would be empty.
        
        With this information you can now explore IN509Stabilisation.
		""",
		"???",
		x -> true
	),
]