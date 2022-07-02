module CollectiveBehaviour
using Agents
using InteractiveDynamics, GLMakie, Random, Statistics
export demo
include("./AgentToolBox.jl")
using .AgentToolBox

ContinuousAgent{2}

function initialize_model(  ;n_particles::Int = 50,
                            worldsize::Int64,
                            particlespeed::Float64,
                            meadist::Float64=0.0,
                            globaldist::Matrix{Float64} = zeros(Float64,n_particles,1),
                            extent = (worldsize, worldsize),
                            )

    space = ContinuousSpace(extent, 1.0)

    properties = Dict(
        :globaldist => globaldist,
        :meadist => meadist,
        :particlespeed => particlespeed,
        :worldsize => worldsize,
    )

    model = ABM(ContinuousAgent,space, scheduler = Schedulers.fastest,properties = properties)

    for id in 1:n_particles
        vel = rotate_2dvector([10 10])
        pos = Tuple([worldsize/2 worldsize/2]').+vel
        vel = eigvec(rotate_2dvector(0.5*π,[vel[1] vel[2]]))
        model.globaldist[id,1] = edistance(pos,Tuple([worldsize/2, worldsize/2]),model)
        add_agent!(
            pos,
            model,
            vel,
        )
        
    end
    model.meadist = mean(model.globaldist,dims=1)[1]

    return model
end

function agent_step!(particle,model)
    if rand()<0.1
        particle.vel= eigvec(rotate_2dvector(rand()*((1/36)*π),particle.vel))
        move_agent!(particle,model,model.particlespeed);
        model.globaldist[particle.id,1] = edistance(particle.pos,Tuple([model.worldsize/2, model.worldsize/2]),model) #ändern
        model.meadist = mean(model.globaldist,dims=1)[1]
    end
end

function demo(world_size,particlesize,particlespeed)
    model = initialize_model(worldsize = world_size,particlespeed=particlespeed);
    mdata = [:meadist]
    figure,_= abmexploration(model;agent_step!,params = Dict(),ac=choosecolor,as=particlesize,am = polygon_marker,mdata)
    figure;
end
end
