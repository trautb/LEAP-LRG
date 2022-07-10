"""
Author: Stefan Hausner
"""

[	
	Activity(
	"""
	Another important function from the Toolbox is eigvec. An eigenvector can
	be created with a linear transformation and is a scaled vector.
	This concept is especially important if we want to find the best agent value (nutrient source)
	in a neighbourhood. If the model has two agent positions a you want to go from
	one to another. It is recommended to use eigvec if the model searches for an better
	value. 

	include("./src/Development/PBM/AgentToolBox.jl")
	
	using .AgentToolBox: eivec
	
	calculate the eigenvector of Tuple([-1.0,3.0])
		
	"""
	"eigvec(Tuple([-1.0,3.0]))",
	x -> x == (-0.31622776601683794, 0.9486832980505138)	
	),

	Activity(	
	"""
	Another important function provided by the Agent package is edistance.
	https://juliadynamics.github.io/Agents.jl/stable/api/

	With this function the model can calculate the euclidian distance between two agents.
	The function edistance needs these parameters edistance(pos1,pos2,model)
	For this Activity you should use an GlMakie graph to plot the euclidian distances.
	https://makie.juliaplots.org/v0.17.8/examples/plotting_functions/lines/index.html

	Copy this code in your julia repl try to copy every function seperatly.
	You can execute the plot with 
	plot_distance()
	
	using Agents
	using  GLMakie: lines	

	mutable struct Agent <: AbstractAgent
		id::Int                   
		pos::NTuple{2,Float64}              
	end   	

	function initialize_model(  
		;n_particles::Int = 5, 
		worldsize::Int64=50,
		extent::Tuple{Int64, Int64} = (worldsize, worldsize)
		,euclidiandist::Matrix{Float64} = zeros(Float64,n_particles,1),)

		properties = Dict(
			:euclidiandist => euclidiandist,
		)
		space = ContinuousSpace(extent, 1.0)
		model = ABM(Agent, space, scheduler = Schedulers.fastest,properties = properties)

		for id in 1:n_particles
			pos = Tuple(rand(2:1:worldsize-1,2,1))
			euclidiandist[id,1] = edistance(pos,Tuple([worldsize/2, worldsize/2]),model)
			add_agent!(
				pos,
				model,
			)
		end
		return model
	end

	function plot_distance()

		model = initialize_model()
		x = range(0, 5, length=5)
		println(model.euclidiandist[1:5])
		figure, axis, lineplot = lines(x, model.euclidiandist[1:5])
		figure
	end
	"""
	),

	Activity(
	"""
	After that you should create a model to position our agents on
	the circle ring.
	Now you can create our Agent.
	First of all we need to create an basic struct.

	using Agents,InteractiveDynamics,GLMakie
	include("./src/Development/PBM/AgentToolBox.jl")
	using .AgentToolBox: rotate_2dvector,polygon_marker

	mutable struct Agent <: AbstractAgent
		id::Int                    
		pos::NTuple{2,Float64}             
		vel:: NTuple{2,Float64}
	end   

	you can alternativly use 

	ContinuousAgent{D}

	D is the dimension in this example is it two
	The ContinuousAgent has the following attributes the fields id::Int, pos::NTuple{D,Float64}, vel::NTuple{D,Float64} 

	For our purpose use the struct Agent
	""",
	x -> true	
	),

	Activity(
	"""
	In the previous Activity you created an struct now you should 
	position our agents on the circle ring. Here we use the 
	rotate method previous used. It is recommended to use 
	a separate file to cod initialize_model


	function initialize_model(
		;n_agents=5,worldsize=50)

		extent = (worldsize,worldsize)
		space2d = ContinuousSpace(extent, 1.0)
		model = ABM(Agent, space2d, scheduler = Schedulers.randomly)

		for id in 1:n_agents
			#vel = ... #rotate random in an radius of 10
			#pos = ... #position the agents on the circle ring.(tangent)
			vel = rotate_2dvector(0.5*π,[vel[1], vel[2]])
			#vel rotates the vector to look at the right direction
			add_agent!(
				pos,
				model,
				vel,
			)
		end
		return model
	end

	function demo()
		model = initialize_model();
		figure, p = abmexploration(model;dummystep,params = Dict(),am = polygon_marker)
		figure;
	end
		
	""" 
	"vel = rotate_2dvector([10 10])
	pos = Tuple([worldsize/2 worldsize/2]').+vel",
	x -> true
	),
	Activity(
		"""
		If you want to create an plot to observe an model variable you should use 
		mdata or adata. In the LabIn502RegularCollectiveBehaviour the model 
		uses mdata to observe the meandistance of every agent to the origin (0,0)

        https://juliadynamics.github.io/InteractiveDynamics.jl/dev/agents/

		You can observe this in the model. Use these two commands to 
		observe the linegraph on the right.

		include("src/Development/PBM/IN502RegularCollectiveBehaviour.jl")
		CollectiveBehaviour.demo()

		""",
		x -> true
	),


		]