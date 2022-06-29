module CollectiveBehaviour
using Agents
using InteractiveDynamics, GLMakie, Random, Statistics
export demo
include("./AgentToolBox.jl")
using .AgentToolBox

ContinuousAgent{2}

function initialize_model(  ;n_particles::Int = 50,
                            meadist::Float64=0.0,
                            worldsize::Int64,
                            particlespeed::Float64,
                            globaldist = zeros(n_particles,1),
                            griddims = (worldsize, worldsize),
                            )
space2d = ContinuousSpace(griddims, 1.0)

properties = Dict(
    :globaldist => globaldist,
    :meadist => meadist,
    :particlespeed => particlespeed,
    :worldsize => worldsize,
)


model = ABM(ContinuousAgent,space2d, scheduler = Schedulers.fastest,properties = properties)
counter = 1
for _ in 1:n_particles
    vel = rotate_2dvector(rand(0:0.1:2π),[10 10])
    pos = Tuple([worldsize/2 worldsize/2]').+vel
    vel = einvec(rotate_2dvector(0.5*π,[vel[1] vel[2]]))
    model.globaldist[counter,1] = edistance(pos,Tuple([worldsize/2, worldsize/2]),model)
    add_agent!(
        pos,
        model,
        vel,
    )
    counter += 1
end
    
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
    figure,_= abmexploration(model;agent_step!,params = Dict(),ac=choosecolor,as=particlesize,am = particlemarker,mdata)#,plotkwargs...);
    figure;
    
end

end
