#========================================================================================#
#	Laboratory 503
#
# Welcome to course 503: random walks can create Patterns
#
# Author: Niall Palfreyman (...), Nick Diercksen (July 2022)
#========================================================================================#
[
	Activity(
		"""
		Welcome to Lab 503: Emergent behaviour.
        OOSE often assumes that we can know what a procedure is going to do, simply by looking
        at the procedure's individual operations. But if the procedure's behaviour is emergent,
        we cannot predict what it will be, even if we know all the operations.

        Let's get started with some new functionality first: ...
		""",
		"",
		x -> true
	),
    Activity(
		"""
        In this chapter additional plots are added ontop of the general agent plot:
        We want to keep all the visited positions of each agent visible until the model
        is reset.
        To do this, you guessed right, we need Observables once more. You have probably already
        noticed, that `abmexploration` returns beside the figure also an `ABMObservable` `p`
        (containing besides other things also the current model).
        We can now lift `p` (add a listener to it), so that every time `p` changes (generally after
        each `model_step!` call), we can plot the current agent positions.
        Combined with the a custom model property `visited_locations` storing all the previous 
        locations, we can simply plot those.
        
        
        Have a look at the file IN503EmergentBehaviour.jl and tell me the name of the other
        variable being plotted exactly the same!

		""",
		"ℹ️  look at the method `additional_plots`", 
		x -> string(x) == "vertex_points"
	),

    Activity(
		"""

		""",
		"???",
		x -> true
	),
]