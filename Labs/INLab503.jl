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
        To do this, you guessed it right, we need Observables again. You have probably
        already noticed that `abmexploration` also returns an `ABMObservable` `p` (which,
        among other things, also contains the current model) in addition to the figure.
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
        In the chapter 01Ecosystem you might have already seen the function `reinit_model_on_reset!`
        and wondered what it is for. Now being familiar with the main framework, we can have a look at it.

        When calling `abmexploration` we provide an already initialized model, but there is no way
        for the program to know how to reinitialize a new model.
        If you look at the source code (link available in `hint()`) of `InteractiveDynamics` you can see
        they use the function `deepcopy` to create a new model with the same exact properties. On clicking
        the reset-button, the old model will be replaced with a new one and all the additional plots will
        no longer be able to react to changes made (they still reference the old model).
        The
        
        To provide the possibility to reinitialize the model on reset, you can add `reinit_model_on_reset!`
        to your code (after the `abmexploration`-call) and provide your `initialize_model` funtion.
        This way you can for example:
        * randomly place agents after each reset
        * reinitialize the model with the current slider values
        
        If you want you can try and comment out the function call in the `demo()` function and import this 
        module again to apply the change. This way you can see the effect for yourself.

        Go ahead now ...
        (Make sure to comment in the line again and reimport the module before moving forward)
		""",
		"https://github.com/JuliaDynamics/InteractiveDynamics.jl/blob/def604fa0e5d70ab0afe7677d3ae11c8f5830d5a/src/agents/interaction.jl#L62",
		x -> true
	),
]