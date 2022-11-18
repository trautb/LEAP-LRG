#========================================================================================#
#	Laboratory 500
#
# Welcome to course 500: An Introduction to Agent-Based Systems!
#
# Authors:  Emilio Borelli, Nick Diercksen, Stefan Hausner, Dominik Pfister (July 2022)
#========================================================================================#

# TODO: upgrade all Chapters to Agents@5.4 https://github.com/JuliaDynamics/Agents.jl/releases/tag/v5.4.0
# * `spacing` is now a keyword in e.g. ContiousSpace / Gridspace
# * `move_agent` now needs to specify `dt` for an agent to move correspondong to its vel
# * nearby_ids has no longer a kw `exact`
# (upgrade is not done yet, to not interfere with agent exploration (research) group)

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
		x -> x <: Main.AbstractAgent && fieldtype(x, :id) <: Signed
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
		x -> x isa Main.ContinuousSpace && x.extent == (80.0, 80.0)
	),
	Activity(
		"""
		So far we learned about Agents and Spaces, now we want to create a model with both.
		We can do that with the function `AgentBasedModel` or in short `ABM`.

		Use the julia help to see how to use AgentBasedModel to create a model with your
		previously created custom agent and space.

		""",
		"type ?AgentBasedModel",
		x -> x isa Main.AgentBasedModel
	),
	Activity(
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
		# input as string and as function is accepted:
		x -> string(x) |> x -> (x == "nearby_agents" || x == "nearby_ids")
	),
	Activity(
		"""
		In the last example we only changed the model once via simple commands.
		But the whole benefit of ABMs is that you can do that iteratively.
		To do this, we need to define two stepping functions:
        
            * agent_step!(agent, model)
            * model_step!(model)
        
        As the names suggest, `agent_step!` will contain the behaviour each agent
        will perform in one iteration. `model_step!` will represent general behaviour,
        like changing environment, data collection, ...

        You will soon enough see and use those in action.
        Jump to the next activity ...
		""",
		"",
		x -> true
	),
	Activity(
		"""
        Before we look at custom models and stepping functions, we will now look at
        visualizations:
        `GLMakie.jl` is a backend for the large plotting library `Makie.jl` (which has a lot of
        functionality). `GLMakie` can be used e.g. for plotting line charts, heat maps and diagrams.
		
        Do you remember Observables from Lab06? Since the Makie plotting framework is based
        on them, we can create dynamic and interactive plots.
        Imagine we want to do this ourselves for all our changed agents and model. We can do this,
        no question, but it will be tedious. 
        The julia package `InteractiveDynamics.jl` already did all this work for us and provides
        a simple form of plotting your agents dynamically. The function doing all the magic is
        called `abmexploration`.        
        Plots will change dynamiclly if anything in the model changes. The plots will be refreshed
        after every model_step!.
        
        To explore an example, Agents provides some predefined models:

            using InteractiveDynamics, GLMakie
            model, agent_step!, model_step! = Agents.Models.flocking()
            figure, p = abmplot(model;agent_step!,model_step!)
            figure
        
        When done exploring, go to the next activity ...
		""",
		"Make sure that `Agents.jl` is loaded as well",
		x -> true
	),
	
	Activity(
        """
        often we want the ground/surrounding of the Simulation to have properties/behaviour too.
        In order to do so, we can define a Matrix with the size of the model space.
        we can either define one 2d matrix for every property or we can create a multidimensional matrix

        i.e.: patches = <some 3 dimensional matrix size 200x200>
        patches[:,:,1] would then correspond to one of the tile`s propperties

        for readability purposes however, it makes more sense to define several space matricies 
        i.e.: patches_property1 = <somne one dimensional matrix>
              patches_property2 = <somne one dimensional matrix>
              etc.
              now: initialize a 200x200 patches Matrix called nutrients
        """,    
        
        "try zeros(200,200)",
        x -> x==zeros(200,200)
    ),
    Activity(
        """
        Most of the time you want to work with continuous spaces, because it gives your agents more flexibility to move.
        the problem, as you might imagine, is that you cannot use the agent's position (usually a Float) to index the patches matrix.
            to solve that problem, you can round the agent`s position to an int: i.e.: 

        
            now you can make the agent interact with his surrounding. you can make him pick something up, or drop something for other agents to interact with.
            It gives your simulation a lot of possibilities!
            try to use posistion = [50.7 67.88] to idex your nutrients matrix and set its value to 2. return to me the index
        """,

        "try position = [round(Int, position[1]) round(Int, position[1])]",
        x -> x==[51 68]
    ),

    # maybe other chapters:
    Activity(
        """
        Agents.jl will deal with space boundaries for you when moving your agent. If you work with own matricies however, you need to deal with that yourself.
        What do you do if you want to check a tile on your nutrients matrix, that is in front of your agent, but your agent already is standing at the border of the map?
        One technique is, to make him check the first tile on the opposite side of the matrix. You can achive this, by following funktion:
        
            function wrapMatrix(mat,index)

                for ids in 1:size(index)[1]
                    if index[ids][1] == 0
                        index[ids][1] = -1
                    end
                    if index[ids][1] == size_row
                        index[ids][1] = size_row + 1
                    end
                    if index[ids][2] == 0
                        index[ids][2] = -1
                    end
                    if index[ids][2] == size_col
                        index[ids][2] = size_col + 1
                    end
            
                    index1 = rem(index[ids][1]+size_row,size_row)
                    index2 = rem(index[ids][2]+size_col,size_col)
                    return [index1, index2]
            end

        Hint: rem() gives you the remain/rest after division

        now you canmake an agent interact with his surrounding, wherever he is standing!

        """,
        "no Hint here",
        x -> true
    ),
	Activity(
        """
        One thing, that Agent based Simulations are not so efficient at, are differential equations. There is an other disciplline called equation based moddeling for that.
        So if you want to model something like diffusion, you have to find a workaround, or an approximation, that is good enough. Either way can work.
        Lets stick to the example of diffusion!
        In this case I personally have two options in mind. You could take advantage of techniques from Image processing, and apply an blurr filter
        to your matrix of diffusing values. Read a little about Immage filtering and kernels in google and return once youre done!
        But we can simplify a little more! take a look at the following function:

        function diffuse4(mat::Matrix{Float64},rDiff::Float64)

            map(CartesianIndices(( 1:size(mat)[1]-1, 1:size(mat)[2]-1))) do x
              iX=x[1]
              iY=x[2]
              neighbours = [wrapMat(mat,[iX+1,iY]), wrapMat(mat,[iX-1,iY]), wrapMat(mat,[iX,iY-1]),  wrapMat(mat,[iX,iY+1])]           
              flow = mat[iX,iY]*rDiff
              mat[iX,iY] *= 1-rDiff
        
              map(neighbours) do j
                mat[j[1],j[2]] += flow/4
              end
            end
            return mat
          end


          basicly we are applying a small, simple kernell to our matrix and tell every tile, to split a certain ammount of its value to its 4 neighbours.
          This works good enogh for most of our use cases. 
          see how we take advantage of our previous functions? (i.e.: wrapMat)
        """,
        "no hint here",
        x -> true
    ),
    Activity(
        """
        Taka a matrix n x m : I bet you are used to iterate through something like this using two for loops...
        But that is actually really inefficient.
        it is better to use an array of cartesian indicees, and apply the map function like this:

        map(CartesianIndices(( 1:size(mat)[1]-1, 1:size(mat)[2]-1))) do x

            ... do something with each element x i.e.:
            println(matrix[x[1],x[2]])
        end

        now we have only one loop! That is so much faster!

        """,
        "no hint here",
        x -> true
    ),
	Activity(
		"""
		While running an abmexploration-Model you can stop the simulation at any moment.
		When the model is paused you can hover over the plot and retrieve information
		about the background of the plot or specific agents.
		Every agent will show a list of its attributes with its values and for every
		background-patch it will show you the position and the plotted variable and value.
		You should try it out whenever you want to know how components of a plot work and
		maybe use the step-button to see the values change.
		
		INFO: When the marker polygon_marker was used it is not possible to see the data of
		the agents. It also rarely happens that the model is unable to get the data for
		the background too.
		""",
		"???",
		x -> true
	),
]
