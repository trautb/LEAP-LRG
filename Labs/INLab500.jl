#========================================================================================#
#	Laboratory 500
#
# Welcome to course 500: An Introduction to Agent-Based Systems!
#
# Author: Niall Palfreyman (24/04/2022), Nick Diercksen (July 2022)
#========================================================================================#
[
    Activity( # nr 1
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
    Activity( # nr 2
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
    Activity( # nr 3
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
        # cannot use `x <: AbstractAgent` here because `Agents.jl` is not loaded here => hence the check with string
        x -> string(supertype(x)) == "AbstractAgent" && fieldtype(x, :id) <: Signed
    ),
    Activity( # nr 4
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
        x -> typeof(x).name.name == :ContinuousSpace && x.extent == (80.0, 80.0)
    ),
    Activity( # nr 5
        """
        So far we learned about Agents and Spaces, now we want to create a model with both.
        We can do that with the function `AgentBasedModel` or in short `ABM`.

        Use the julia help to see how to use AgentBasedModel to create a model with your
        previously created custom agent and space.

        """,
        "type ?AgentBasedModel",
        x -> typeof(model).name.name == :AgentBasedModel
    ),
    Activity( # nr 6 
        """
		We will now combine all the new information.
		Excute the following commands, maybe run `demo()` a few times and then have a
		look at the associated file.

			include("src/Development/PBM/IN500SimpleWorld.jl")
			using .SimpleWorld
			SimpleWorld.demo()
		
		See if you understand everything, if not use either
		the Julia help or directly visit the API documentation of Agents:
		https://juliadynamics.github.io/Agents.jl/stable/api/

		How is the function called to obtain agents near a position?
		""",
        "have a look at the IN500SimpleWorld.jl file",
        x -> string(x) |> x -> (x == "nearby_agents" || x == "nearby_ids")
    ),
    Activity( # nr 7 
        """
		In the last example we only changed the model once via simple commands.
		But the whole benefit of ABMs is that you can do that iteratively.
		To do this, we need to define a step function that each agent will execute.
			
			agent_step!(agent, model)

			mutable struct Particle <: AbstractAgent
				id::Int
				pos::NTuple{2,Float64}
				vel::NTuple{2,Float64}
			end
		
		# TODO: Evolving the model (agent_step)
		
		Create your own agent_step! function that moves a particle 
        """,
        "???",
        x -> true
    ),
    Activity( # nr 8
        """
        # TODO: Evolving the model (model_step)

        The model_step! is always after the agent_step!. Here we can collect data from our model. with
        allagents(model) we collect every agent in our model with agent we acces them. 
        In this example we want to collect the mean velocity (vel). First of all we need the strength of 
        every velocity. Just use Pytagoras.
        
        
        sumvel = 0.0
        for agent in allagents(model)
            velpy = sqrt((agent.vel[1])^2+(agent.vel[2])^2)
            sumvel += velpy
        end

        #calculate mean hint 3 agents
         
        """,
        "???",
        x -> true
    ),
    Activity( # nr 9
        """
        # TODO: Evolving the model (dummystep)
        # if you dont need an agent_step!, but you want still be able to
        # use model_step! use dummystep.

        """,
        "???",
        x -> true
    ),
    Activity( # nr 10
        """
        # TODO: visualizing (abmplot)

        The simplest form of plotting your agents is plotting with abmplot. You can call abmplot in the function demo()
        But first of all you need to import some Packages. GLMakie is an big libary with a lot of function and has
        a long compilation time. GLMakie is used to plot linegraphs,heatmaps and charts.

        using InteractiveDynamics,GLMakie

        in the demo use this commands

        function demo()
            model = initialize_model()
        
            figure = abmplot(model)
            figure
        
        end

        """,
        "???",
        x -> true
    ),
    Activity( # nr 11
        """
        # TODO: visualizing (remember Observables? a sophisticated framework we will use leverages those)
        With Abm Observables we are able to visualize changes in the agents behaviour. We can either visualize
        agent_step! or model_step! or both. It shows us the agent position after every step.

        figure, p = abmplot(model;agent_step!,model_step!)
        figure
        """,
        "???",
        x -> true
    ),
    Activity( # nr 12
        """
        # TODO: visualizing (abmexploration [InteractiveDynamics])
        abmexploration evolves an ABM interactively and plots its evolution, while allowing changing any of the 
        model parameters interactively and also showing the evolution of collected data 
        over time (if any are asked for, see below).

        abmexploration is especially useful if you want to adjust paramters while the model is already compiled.
        This can be achieved with using sliders. This concept will be introdced when model parameter are 
        introdced.
        The code to acess abmexploration is similar to abmobservable

        figure, p = abmexploration(model;agent_step!, model_step!) 

        """,
        "???",
        x -> true
    ),
	Activity( # nr 13
        """
        # TODO: patches (matrices / )
        # TODO: introduce `spacing` of ContinuousSpace to reveal locations and let patches be implemented
        # TODO: => mention `divisions` ?
        """,    
       
        "???",
        x -> true
    ),
    Activity( # nr 14
        """
        # TODO: visualizing (abmvideo? is intro even needed? does this occur somehere? maybe at the end to possibly generate/export a video)
        """,
        "???",
        x -> true
    ),

    # maybe other chapters:
    Activity( # nr 15
        """
        # TODO: patches (matrices / )
        # TODO: introduce `spacing` of ContinuousSpace to reveal locations and let patches be implemented
        # TODO: => mention `divisions` ?
        """,
        "???",
        x -> true
    ),
	Activity( # nr 16 # TODO: creating an ABM (model properties)
        """
        Now that all
        """,
        "???",
        x -> true
    ),
    Activity( # nr 17
        """
        # TODO: visualizing (patches: heatarray)
        """,
        "???",
        x -> true
    ),
    Activity( # nr 18
        """
        # TODO: visualizing (colorschemes)
        """,
        "???",
        x -> true
    ),
    Activity( # nr 19
        """
        # TODO: visualizing (agent inspection)
        """,
        "???",
        x -> true
    ),
    Activity( # nr 20
        """
        # TODO: visualizing (custom abmplot: lifting)
        """,
        "???",
        x -> true
    ),
    Activity( # nr 21
        """
        # TODO: visualizing (mdata, adata)
        """,
        "???",
        x -> true
    ),
]