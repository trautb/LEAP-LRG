"""
	Swarm

This model IN510Swarm demonstrates how swarms of particles can solve a minimisation problem
and also, the major difficulty of swarm techniques: suboptimization.
There are two minimisation problem in this Lab In510Swarm the first is DeJong and
the next is valley. After every step the agent looks in his neighbourhood and searches 
for the local minima value in their neighbourhood. 

Author: Stefan Hausner
"""
module Swarm

using Agents
using InteractiveDynamics, GLMakie,LinearAlgebra, Random
include("./AgentToolBox.jl")
using .AgentToolBox: buildDeJong7, buildValleys, eigvec, wrapMat, polygon_marker, reinit_model_on_reset! 

export demo
mutable struct Agent <: AbstractAgent
	id::Int                   
	pos::NTuple{2,Float64}             
	vel::NTuple{2,Float64}
	patchvalue:: Float64 
end

"""
Here the model is initialized and the agents are set. The model creates patches 
with the coresponding function buildDeJong7 or buildValleys. The boolean deJong7
decides which function to choose. After that further model properties are created
for example, ticks. Then the agents are positioned in the world and then 
they get the patchvalue from their current position. 
"""
function initialize_model(  
	;
	neighboursize:: Int = 8,
	worldsize::Int = 80,
	pPop::Float64 = 0.1,
	n_agent::Int = Int(worldsize*worldsize*pPop),
	extent::Tuple{Int64, Int64} = (worldsize, worldsize),
	ticks::Int=1,
	deJong7::Bool= false,
	
	)
	space = ContinuousSpace(extent, 1.0)

	patches =  deJong7 ? buildDeJong7(worldsize) : buildValleys(worldsize)

	properties = Dict(
		:patches => patches,
		:pPop => pPop,
		:ticks => ticks,
		:deJong7 => deJong7,
		:worldsize => worldsize,
		:neighboursize => neighboursize
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
for the minimum value of the collected agents with min_patch. Here the model iterates through
the collected agents and searches for the local minima with argmin. patch(ids) returns
us the patchvalues of the currently iterated id. itr chooses the current id to process.
All local minima are saved in a vector. Then the model calculates the vector between
the current agent and the agent with the lowest value. Here the model uses eigvec to move gradually
to the position. This is important because there might be an even lower value in between these two
positions. If the agent minima patchvalue are one the other side of world the model
uses wrapMat.
"""
function agent_step!(agent,model)
	ids = collect(nearby_ids(agent.pos, model, model.neighboursize,exact=false))
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
"""
Here we plot our model. Params defines the slider deJong7 here the model 
can change it patch heatmap. Plotkwargs creats the background for the 
patches with an colormap. Colormaps uses colorschemes. The reinit_model_on_reset! 
reinitialize the model if the model is resetted. 
https://docs.juliaplots.org/latest/generated/colorschemes/
"""
function demo()
	model = initialize_model();
	params = Dict(
		:deJong7 => false:true,
		:neighboursize => 2:1:8,
		:worldsize => 80:10:160,
		:pPop => 0.1:0.1:0.4
	)
	plotkwargs = (
		add_colorbar=false,
		heatarray=:patches,
		heatkwargs=(
			colormap=cgrad(:ice),
	))
	figure,p= abmexploration(model;agent_step!,params,am = polygon_marker,ac = :red,plotkwargs...)
	reinit_model_on_reset!(p, figure, initialize_model)	
	figure 
end
end