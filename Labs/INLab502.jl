
[
	Activity(
		"""
		In the previous sections we learned some basic functions and calcultation methods of julia. In this Section we introduce you to Agent Based modelling
		In this section we work with this package https://juliadynamics.github.io/Agents.jl/dev/
		Here we learn how to create agent based simulations in julia. In Lab007 you learned about the type struct. In this section struct is an important type for your
		agent models. Now create an basic struct 

		using Agents

		mutable struct Agent <: AbstractAgent
			id::Int                    
			pos::NTuple{2,Float64}             
			vel:: NTuple{2,Float64}
		end   

		you can alternativly use 

		ContinuousAgent{D}

		D is the dimension in this example is it two
		The ContinuousAgent has the following attributes the fields id::Int, pos::NTuple{D,Float64}, vel::NTuple{D,Float64} 
		"""

		"""
		"""
		),

		Activity(
		"""
		Another important function from the Toolbox is eigvec. An eigenvector can
		be created with an linear transformation and is an scaled vector.
		This concept is especially important if we want to find the best agent value (nutrient source)
		in an neighborhood. If the model has two agent positions an you want to go from
		one to another. It is recommended to use eigvec if the model searches for an better
		value. 

		include("./src/Development/PBM/AgentToolBox.jl")
		
		using .AgentToolBox: eivec

		scaled vector 
		"""

		),

		Activity(	
		"""

		"""
		),

		Activity(
			"""
			Now it is introdced how to initialize_model. Here we can set every parameter defined in struct and
			for every agents every struct parameter need to be set with add_agent!. If we don't define pos it will be randomly
			set


			function initialize_model(;n_agents=10,worldsize=100)

				extent = (worldsize,worldsize)
				space2d = ContinuousSpace(griddims, 1.0)
				model = ABM(Agent, space2d, scheduler = Schedulers.randomly


				
			"""    
		),
        Activity(
		"""
		# TODO: visualizing and collecting data (mdata, adata): https://juliadynamics.github.io/Agents.jl/stable/api/#Data-collection-1
        # TODO: ... https://juliadynamics.github.io/InteractiveDynamics.jl/dev/agents/
		""",
		"???",
		x -> true
	),


		]