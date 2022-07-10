#========================================================================================#
#	Laboratory 507
#
# Welcome to course 507: 
#
# Author: Niall Palfreyman (...), Nick Diercksen (July 2022)
#========================================================================================#
[
	Activity(
		"""
		Welcome to Lab 507: Neutral Drift.


        Let's get started with some new functionality first: ...
		""",
		"",
		x -> true
	),
    Activity(
		"""
        This chapter is not going to be a long: We actually only need one single
        stepping function, namely `model_steo!`. The Developers of Agents.jl provide
        a neat alternative to just declare and use an empty step-function: We can
        just use a `dummystep`.
            abmexploration(model; (agent_step!)=dummystep, ...)
        
        How many methods does dummystep have?
		""",
		"""
        \tdid you load Agents.jl?
        \tJust enter dummystep in the console or have a look at the API.""",
		x -> x == 2
	),

    Activity(
		"""

		""",
		"???",
		x -> true
	),
]