#========================================================================================#
#	Laboratory 500
#
# Welcome to course 500: An Introduction to Agent-Based Systems!
#
# Author: Niall Palfreyman (24/04/2022), Nick Diercksen (July 2022)
#========================================================================================#
[
	Activity(
		"""
		"Agent-based modelling (ABM) is a technique for understanding how the behaviour
		of a complex biological system arises from the traits and behaviours of the
		component agents that make up that system."
		
		...

		# TODO: proper introduction to this topic
		""",
		"???",
		x -> true
	),
	Activity(
		"""
		To use Agent Based Models in Julia, there is already a package available called
			
			Agents.jl

		on which this course relies on.
		We will be covering some of the basics to use this package, but if you find
		yourself interested, I recommend checking out the official tuorial:
			https://juliadynamics.github.io/Agents.jl/stable/tutorial/
		
		This package should already be installed in your (Ingolstadt) environment, but
		if not, you can add it via the package manager.
		As always, start by loading this package into your environment:

			using Agents
		
		When done, go to the next activity ...
		""",
		"package not installed? Open the package manager with `]`, then type `add Agents`",
		x -> true
	),
	Activity(
		"""
		Agents are nothing else than modifiable objects, that we will program to interact with
		each other or the environment/world/model they exist in.

		In Julia, we can implement them with `mutable struct`s (as introduced in Lab 02).
		They need to be subtypes of `AbstractAgent`.

		Now create such a subtype with some suitable attributes (fields) together with an `id`!
		The `id` will be necessary to uniquely identify our agent instances later on.
		""",
		"""
		\t Remember with <: you can create a subtype of an abstract type.
		\t The type of `id` needs to be an integer
		""",
		# cannot do `x <: AbstractAgent` here because `Agents.jl` is not loaded here => check with string
		x -> string(supertype(x)) == "AbstractAgent"  && fieldtype(x, :id) <: Signed 
	),
	Activity(
		"""
		Agents will live in a model defined by a specific space. Agents offers multiple
		spaces tailored to specific applications and agent types. For simplicity we will
		only be using `ContiuousSpace` in two dimensions
		(for more details have a look at the Agents.jl documentation).
		
		A space defines the size of the model. In two dimensions it has a width and a
		height, which are usually the same. Together we will call them `extent`:

			worldsize = height = weight = 40
			extent = (worldsize, worldsize)
		
		Now create a space with dimensions 80x80
		""",
		"""
		\tMake sure to forward the extent as one parameter (Tuple): ContinuousSpace(extent)
		\tDid you choose the right size?
		""",
		x -> typeof(x).name.name == :ContinuousSpace && x.extent == (80.0,80.0)
	),
	Activity(
		"""
		# TODO: creating an ABM
		""",
		"???",
		x -> true
	),
	Activity(
		"""
		# TODO: creating an ABM (model properties)
		""",
		"???",
		x -> true
	),
	Activity(
		"""
		# TODO: intro with SimpleWorld to accumulate all the current knowledge
		# TODO: => maybe adjust SimpleWorld to contain some missing functionality if needed
		# TODO: => maybe leave some places empty for a student to complete (the solution (complete file) can be placed in dev/PBM/IN500SimpleWorld.jl )

			include("src/Development/PBM/IN500SimpleWorld.jl")
			using .SimpleWorld
			SimpleWorld.demo()
		
		how is the function called to obtain agents near a position?
		""",
		"have a look at the IN500SimpleWorld.jl file",
		x -> string(x) |> x -> (x == "nearby_agents" || x == "nearby_ids")
	),
	Activity(
		"""
		# TODO: Evolving the model (agent_step)
		""",
		"???",
		x -> true
	),
	Activity(
		"""
		# TODO: Evolving the model (model_step)
		""",
		"???",
		x -> true
	),
	Activity(
		"""
		# TODO: Evolving the model (dummystep)
		""",
		"???",
		x -> true
	),
	Activity(
		"""
		# TODO: visualizing (abmplot)
		""",
		"???",
		x -> true
	),
	Activity(
		"""
		# TODO: visualizing (remember Observables? a sophisticated framework we will use leverages those)
		""",
		"???",
		x -> true
	),
	Activity(
		"""
		# TODO: visualizing (abmexploration [InteractiveDynamics])
		""",
		"???",
		x -> true
	),
	
	Activity(
		"""
		
		""",
		"???",
		x -> true
	),
	Activity(
		"""
		# TODO: visualizing (abmvideo? is intro even needed? does this occur somehere? maybe at the end to possibly generate/export a video)
		""",
		"???",
		x -> true
	),

	# maybe other chapters:
	Activity(
		"""
		# TODO: patches (matrices / )
		# TODO: introduce `spacing` of ContinuousSpace to reveal locations and let patches be implemented
		# TODO: => mention `divisions` ?
		""",
		"???",
		x -> true
	),
	Activity(
		"""
		# TODO: visualizing (patches: heatarray)
		""",
		"???",
		x -> true
	),
	Activity(
		"""
		# TODO: visualizing (agent inspection)
		""",
		"???",
		x -> true
	),
	Activity(
		"""
		# TODO: visualizing (custom abmplot: lifting)
		""",
		"???",
		x -> true
	),
	Activity(
		"""
		# TODO: visualizing (mdata, adata)
		""",
		"???",
		x -> true
	),
]