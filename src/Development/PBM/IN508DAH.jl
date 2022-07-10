module DAH
	export Cell2, demo2
"""
Stuart Newman and Gerd Müller base an entire theory of morphogenesis on Newman's Differential Adhesion Hypothesis (DAH), 
which suggests that developing organisms structure their tissue into a body by using a series of adhesive molecules of varying strengths.
When the cells rattle around due to thermal motion, these different adhesive properties cause the cells to organise themselves.

Author: Nial Pallfreyman, Emilio Borrelli
"""


	using InteractiveDynamics
	using GLMakie
	using Agents, LinearAlgebra
	using Random # hides
	include("./AgentToolBox.jl")
	import .AgentToolBox: rotate_2dvector, turn_left, turn_right, reinit_model_on_reset!



mutable struct Cell2 <: AbstractAgent
	# define the agent's properties
	id::Int
	pos::NTuple{2,Float64}
	vel::NTuple{2,Float64}
	speed::Float64
	cadherin::Float64
	color::Symbol
end


function initialize_model(;
	#give the function most of both the agent's and the model's own properties 
	pPop=1.0,
	rAdhesionRange=4.0,
	rAdhesion=0.4,
	rRadius=1.0,
	rRepulsion=-0.5,
	rThermal=0.01,
	rGravity=0.0,
	nAdherins=3,
	extent=(40, 40)
)
	#properties of the model
	properties = Dict(
		:pPop => pPop,
		:rAdhesionRange => rAdhesionRange,
		:rAdhesion => rAdhesion,
		:rRadius => rRadius,
		:rRepulsion => rRepulsion,
		:rThermal => rThermal,
		:rGravity => rGravity,
		:nAdherins => nAdherins,
	)
	# Initialise Cell population
	space2d = ContinuousSpace(extent)
	model = ABM(Cell2, space2d; properties, scheduler=Schedulers.randomly)
	vel = Tuple((0, 0))
	speed = 0
	map(CartesianIndices((1:(extent[1]-1), 1:(extent[2]-1)))) do x
		#
		cadherin = rand(1:1:3)
		if cadherin == 1
			color = :darkorchid
		elseif cadherin == 2
			color = :cyan3
		else
			color = :peru
		end
		add_agent!(
			Tuple(x),
			model,
			vel,
			speed,
			cadherin,
			color,
		)
	end
	return model
end



	function  adhere(cell2::AbstractAgent,model::ABM)

		nbr = random_nearby_agent(cell2, model, model.rAdhesionRange)
		if nbr !== nothing
			#continue here
			cell2.vel = get_direction(cell2.pos, nbr.pos, model)
			cell2.speed = model.rAdhesion * cadhesion(cell2.cadherin, nbr.cadherin, model)
			move_agent!(cell2, model, cell2.speed)
		end       
	end



	function  repel(cell2::AbstractAgent,model::ABM)
		
		penetrator = random_nearby_agent(cell2, model, model.rRadius)
		if penetrator !== nothing
			#continue here
			cell2.vel = get_direction(cell2.pos, penetrator.pos, model)
			cell2.speed = model.rRepulsion 
			move_agent!(cell2, model, cell2.speed)
		end       
	end



	function  meander(cell2::AbstractAgent,model::ABM)
		
		cell2.vel = turn_right(cell2,rand(1:360)) 
		cell2.speed = model.rThermal
		move_agent!(cell2, model, cell2.speed)
	end



	function cadhesion(c1::Float64, c2::Float64, model::ABM)
		return(1-(2*abs(c1-c2) + c1 + c2) / (2*model.nAdherins))
	end



	function demo2()
		
		model = initialize_model()
		#create the interactive plot with our sliders
		cellcolor(a::Cell2) = a.color
		fig, p = abmexploration(model; model_step!, ac = cellcolor, as = 15)
		fig
	end

#function agent_step!(cell2,model)
function model_step!(model::ABM)

	for i in model.agents

		adhere(i[2], model)
		repel(i[2], model)
		meander(i[2], model)
	end
end




function cadhesion(c1::Float64, c2::Float64, model::ABM)
	return (1 - (2 * abs(c1 - c2) + c1 + c2) / (2 * model.nAdherins))
end


function demo()

	model = initialize_model()
	#create the interactive plot with our sliders
	cellcolor(a::Cell2) = a.color
	fig, p = abmexploration(model; model_step!, ac=cellcolor, as=15)
	reinit_model_on_reset!(p, fig, initialize_model)
	fig
end

end
