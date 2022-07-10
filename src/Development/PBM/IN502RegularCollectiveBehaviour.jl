"""
	CollectiveBehaviour

In this Module IN502RegularCollectiveBehaviour the movement  of a collective is observed. 
The goal of this Lab is to observe the mean euclidean  distance of every agent over time.
First of all, every agent is positioned randomly on the circles ring with the radius of 10 units.
Then the agent is rotated 90 degrees to be in a tangent to the circles ring. Then the agents are
moved in the world. After every agentstep we measure the euclidean distance of the scheduled agent.
Also, the mean of the matrix euclidiandist is calculated.

Author: Stefan Hausner
"""
module CollectiveBehaviour
using Agents
using InteractiveDynamics, GLMakie, Statistics
export demo
include("./AgentToolBox.jl")
using .AgentToolBox: rotate_2dvector, eigvec,choosecolor,polygon_marker, reinit_model_on_reset!

ContinuousAgent{2}

"""
Here the model and the agents are initialized. euclideandist is
a matrix and collects our euclidean distances. 
Also, the model parameters are initialized and the agents are positioned
and the velocity are set.
"""
function initialize_model(  ;n_particles::Int = 50,
							worldsize::Int64,
							particlespeed::Float64,
							meandist::Float64=0.0,
							euclideandist::Matrix{Float64} = zeros(Float64,n_particles,1),
							extent::Tuple{Int64, Int64} = (worldsize, worldsize),
							)

	space = ContinuousSpace(extent, 1.0)

	properties = Dict(
		:euclideandist => euclideandist,
		:meandist => meandist,
		:particlespeed => particlespeed,
		:worldsize => worldsize,
	)

	model = ABM(ContinuousAgent,space, scheduler = Schedulers.fastest,properties = properties)

	for id in 1:n_particles
		vel = rotate_2dvector([10 10])
		pos = Tuple([worldsize/2 worldsize/2]').+vel
		vel = eigvec(rotate_2dvector(0.5*π,[vel[1], vel[2]]))
		model.euclideandist[id,1] = edistance(pos,Tuple([worldsize/2, worldsize/2]),model)
		add_agent!(
			pos,
			model,
			vel,
		)
		
	end
	model.meandist = mean(model.euclideandist,dims=1)[1]

	return model
end

"""
If an an random value is smaller 0.1 the agent does the following steps.
Here the agent is rotate with a random rotation from 0-1/36π and after that
creates the corresponding eigenvector. Then the euclidean distance
is calculated with edistance. Finally, the mean euclidean distance of every
agent is calculated.
"""
function agent_step!(particle,model)
	if rand()<0.1
		particle.vel= eigvec(rotate_2dvector(rand()*((1/36)*π),particle.vel))
		move_agent!(particle,model,model.particlespeed);
		model.euclideandist[particle.id,1] = edistance(particle.pos,Tuple([model.worldsize/2, model.worldsize/2]),model) #ändern
		model.meandist = mean(model.euclideandist,dims=1)[1]
	end
end

"""
Plot for the agent movement and a plot for progress of the mean euclidean distance.
"""
function demo()
	model = initialize_model(worldsize = 40,particlespeed=1.0);
	mdata = [:meandist]
	figure, p = abmexploration(model;agent_step!,params = Dict(),ac=choosecolor,as=1.5,am = polygon_marker,mdata)
	figure;
end
end
