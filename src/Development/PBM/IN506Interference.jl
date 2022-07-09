"""
In this Lab IN506Interference we explore the development of an field.
There are Sources that emit E- and B-fields. Here agents are used
only to initiate the fields. 
"""

module Interference
using Agents
using InteractiveDynamics, GLMakie,LinearAlgebra, Random
export demo
include("./AgentToolBox.jl")
using .AgentToolBox: nonwrap_nb, neuman_neighborhood

mutable struct ESource <: AbstractAgent
	id::Int                   
	pos::NTuple{2,Float64}              
	phase:: Float64
	EBSource:: Float64
end   

"""
Here the model and the agents are initialized. There are
to matices for our field EB and dEB_dt. The models properties 
are field constants the matices. 
After this we set the EB field sources with the agent position.
From here the EB field is intiated.
"""
function initialize_model(  
	;n_sources::Int = 2,
	worldsize::Int,
	extent::Tuple{Int64, Int64} = (worldsize, worldsize),
	EB::Matrix{Float64} = zeros(extent),
	dEB_dt::Matrix{Float64}= zeros(extent),
	ticks::Int=1,
	c::Float64=1.0,
	freq::Float64=1.0,
	dt::Float64 = 0.1,
	dxy::Float64=0.1,
	attenuation::Float64= 0.03,
	colorrange::Tuple{Int64, Int64}=(-1, 1),
	)
	space = ContinuousSpace(extent, 1.0)

	properties = Dict(
		:EB => EB,        #patches
		:dEB_dt => dEB_dt,
		:ticks => ticks,
		:c => c,
		:freq => freq,
		:dt => dt,
		:dxy => dxy,
		:attenuation => attenuation,
		:worldsize => worldsize,
		:colorrange => colorrange,
	)

	model = ABM(ESource, space, scheduler = Schedulers.randomly,properties = properties)

	for id in 1:n_sources
		if (id == 1)
			pos = Tuple([1 round(((1/4)*worldsize))])
		else
			pos = Tuple([1 round(((3/4)*worldsize))])
		end
		phase = 0
		EBSource = 0.0
		add_agent!(
		pos,
		model,
		phase,
		EBSource,
		)
	end
	return model
end
"""
Here the model_step! is used because the agents are only used for intiating the EB-field.
First of all all agents are collected with allagents. Then for every agent the EB field
intiated. The Source value is transfered to the next patch after the EB field is initaited 
the field extends and moves through the field. For the calculation Sources the Laplace 
equation is used.
"""    
function model_step!(model)
	model.colorrange = ((-1*model.freq)-0.1,(1*model.freq)+0.1)
	for particle in allagents(model)
		particle.EBSource = sin(particle.phase + 2π * model.freq * model.ticks * model.dt)
		model.EB[Int(particle.pos[1]), Int(particle.pos[2])] = particle.EBSource
	end
	e_field_pulsation(model)
	model.ticks += 1
end

"""
Here the E-field is created. In neumanh the von Neumann neighborhood is calculated.
After that we intiate through every position in the field. Meannb calculates the 
mean of the von neumann neighborhood for every position in the field. If the one
neighboor is outside the matrix he gets the value 0. Then the von Neumann neighborhood
is created. Then the derivative of an function is calculated. Then the field attenuate,
it gets smaller over time. Then the EB field is created.
"""
function e_field_pulsation(model)
	h = 4
	mv_EB = zeros(model.worldsize,model.worldsize)
	map(CartesianIndices((1:model.worldsize-1,1:model.worldsize-1))) do x
		indices = nonwrap_nb(model.worldsize,model.worldsize,neuman_neighborhood(x[1],x[2]))
		meannb = sum(model.EB[indices])
		mv_EB[x[1],x[2]] = (4/(h^2))*(meannb-model.EB[x[1],x[2]])
	end
	
	model.dEB_dt = model.dEB_dt.+model.dt .*model.c .*model.c .* (mv_EB.-model.EB)./(model.dxy*model.dxy)
	model.dEB_dt = model.dEB_dt.*(1 - model.attenuation)
	model.EB =  model.EB .+  model.dt .*  model.dEB_dt
end

"""
Here 2 sliders are created to adjust the frequency and the attenuation. The field
is visualized with an heatarray and the colormap :oslo.
Also we can observe the change in color as the field progresses.
"""
function demo()
	model = initialize_model(worldsize=60);
	#https://docs.juliaplots.org/latest/generated/colorschemes/
	params = Dict(
	:freq => 0.5:0.1:2,
	:attenuation => 0:0.01:0.1
	)
	plotkwargs = (
	heatarray = :EB,
	add_colorbar=false,
	heatkwargs = (
		colorrange=model.colorrange,
		colormap = cgrad(:oslo), 
	))
	figure,_= abmexploration(model;model_step!,params,ac = :yellow,plotkwargs...)
	figure
end
end
