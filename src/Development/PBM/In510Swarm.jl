"""
This model demonstrates how swarms of particles can solve a minimisation problem
and also the major difficulty of swarm techniques: suboptimisation.
There are two minimisation problem in this Lab In510Swarm the first is DeJong and
the next is valley. After every step the agent looks in his neighborhood and searches 
for the smallest value in neighborhood. 
"""
module Swarm

using Agents
using InteractiveDynamics, GLMakie,LinearAlgebra, Random
include("./AgentToolBox.jl")
using .AgentToolBox: buildDeJong7, buildValleys, eigvec, wrapMat, polygon_marker, reinit_model_on_reset! 

export demo
mutable struct Agent <: AbstractAgent
	id::Int                    # Boid identity
	pos::NTuple{2,Float64}              # Position of boid
	vel::NTuple{2,Float64}
	patchvalue:: Float64 
end

"""
Here the model is initialized and the agents are set. The model creates patches 
with the coresponding function buildDeJong7 or buildValleys. The boolean deJong7
decides which function to choose. After that further model properties are created
for example ticks. Then the agents are positioned in the world and  then 
they get the patchvalue from there current position. 
"""
function initialize_model(  
	;n_agent::Int = 640,
	worldsize::Int = 80,
	extent::Tuple{Int64, Int64} = (worldsize, worldsize),
	ticks::Int=1,
	deJong7::Bool= false,
	pPop::Float64 = 0.0,
	)
	space = ContinuousSpace(extent, 1.0)

	patches =  deJong7 ? buildDeJong7(worldsize) : buildValleys(worldsize)

	properties = Dict(
		:patches => patches,
		:pPop => pPop,
		:ticks => ticks,
		:deJong7 => deJong7,
		:worldsize => worldsize
	)
	
	model = ABM(Agent, space, scheduler = Schedulers.fastest,properties = properties)
	
	for _ in 1:n_agent
		pos = Tuple(rand(2:1:worldsize-1,2,1))
		patchvalue = model.patches[round(Int,pos[1]),round(Int,pos[2])]
		vel = Tuple([1 1])
		add_agent!(
		pos,
		model,
		vel,
		patchvalue
		)
	end
	return model
end

"""
For every step the model collects nearby agents to the scheduled agent. Then searches
for the minimum value of the collected agents with min_patch. Here we iterate through
the collected agents and searches vor the local minma with argmin. patch(ids) returns
us the patchvalues of the currently iterated id. itr chooses the current id to process.
"""
function agent_step!(agent,model)
	ids = collect(nearby_ids(agent.pos, model, 8,exact=false))
	patch(ids) = model[ids].patchvalue
	min_patch(patch, itr) = itr[argmin(map(patch, itr))]
	id = min_patch(patch, ids)
	agent.vel = eigvec(model[id].pos.-agent.pos)
	move_agent!(agent,model,1);
	sizerow = size(model.patches)[1]
	sizecol = size(model.patches)[2]
	index = [round(Int64,agent.pos[1]),round(Int64,agent.pos[2])]
	
	if (index[1] == 0 || index[2] == sizerow
	  ||index[2] == 0 || index[2] == sizecol)
	  indices = wrapMat(sizerow,sizecol,index,true)
	  agent.patchvalue = model.patches[indices[1]]
	else
		agent.patchvalue = model.patches[index[1],index[2]]
	end
end

function demo()
	model = initialize_model();
	params = Dict(
		:deJong7 => false:true
	)
	plotkwargs = (
		add_colorbar=false,
		heatarray=:patches,
		heatkwargs=(
			colormap=cgrad(:ice),
	))
	#https://makie.juliaplots.org/stable/documentation/figure/
	#https://makie.juliaplots.org/v0.15.2/examples/layoutables/gridlayout/
	figure,p= abmexploration(model;agent_step!,params,am = polygon_marker,ac = :red,plotkwargs...)
	reinit_model_on_reset!(p, figure, initialize_model)	
	figure 
end
end