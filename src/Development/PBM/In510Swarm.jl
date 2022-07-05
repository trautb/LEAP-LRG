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
using .AgentToolBox
export demo
mutable struct Agent <: AbstractAgent
    id::Int                    # Boid identity
    pos::NTuple{2,Float64}              # Position of boid
    vel::NTuple{2,Float64}
    patchvalue:: Float64 
end

"""
Here the model is initialized and the agents are set. The model creates patches 
to the coresponding function buildDeJong7 or buildValleys. The boolean deJong7
decides which function is choosen. After that further model properties are created
for example ticks. Then the agents are positioned and they get the patchvalue from theire
current position.
"""
function initialize_model(  
    ;n_sources = 640,
    worldsize,
    extent = (worldsize, worldsize),
    ticks=1,
    deJong7= false,
    pPop = 0.0,
    )
    space = ContinuousSpace(extent, 1.0)

    patches = deJong7 ? buildDeJong7(worldsize) : buildValleys(worldsize)

    properties = Dict(
        :patches => patches,
        :pPop => pPop,
        :ticks => ticks
        :deJong7 => deJong7,
        :worldsize => worldsize
    )
    
    
    model = ABM(Agent, space, scheduler = Schedulers.fastest,properties = properties)
    
    
    for _ in 1:n_sources
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
Mathematical function to calculate an valley. Here the model creates an 2D plane
with several valleys and peeks.
"""
function buildValleys(worldsize)
    maxCoordinate = worldsize / 2
    xy = 4 .* collect(-maxCoordinate:(maxCoordinate-1)) ./ maxCoordinate
    f(x, y) = (1 / 3) * exp(-((x + 1)^2) - (y^2)) +
                10 * (x / 5 - (x^3) - (y^5)) * exp(-(x^2) - (y^2)) -
                (3 * ((1 - x)^2)) * exp(-(x^2) - ((y + 1)^2))
    f.(xy, xy')
end
"""
Mathematical function to calculate multiple local minima. Here the model creates an 2D plane
with multiple local minima. 
"""
function buildDeJong7(worldsize)
    maxCoordinate = worldsize / 2
    xy = 20 .* collect(-maxCoordinate:(maxCoordinate-1)) ./ maxCoordinate
    f(x, y) = sin(180 * 2 * x / pi) / (1 + abs(x)) + sin(180 * 2 * y / pi) / (1 + abs(y))
    f.(xy, xy')
end

"""
In agent_step! we collect the nearby_ids of every agent in an range of 8.
With min_patch we itarate over the ids and find the smallest patchvalue in
the neighborhood. Then we create an eigenvector between the position with 
the smallest patchvalue and the agent postion. Then the agents move.
Then the position of the agent is collected and the corresponding indices 
in the matrix are 
"""
function agent_step!(sources,model)
    ids = collect(nearby_ids(sources.pos, model, 8,exact=false))
    patch(ids) = model[ids].patchvalue
    min_patch(patch, itr) = itr[argmin(map(patch, itr))]
    id = min_patch(patch, ids)
    sources.vel = eigvec(model[id].pos.-sources.pos)
    move_agent!(sources,model,1);
    sizerow = size(model.patches)[1]
    sizecol = size(model.patches)[2]
    index = [round(Int64,sources.pos[1]),round(Int64,sources.pos[2])]
    
    if (index[1] == 0 || index[2] == sizerow
      ||index[2] == 0 || index[2] == sizecol)
      indices = wrapMat(sizerow,sizecol,index)
      sources.patchvalue = model.patches[indices[1]]
    else
        sources.patchvalue = model.patches[index[1],index[2]]
    end
   

end

function demo()
    model = initialize_model(worldsize=80);
    
    plotkwargs = (
        add_colorbar=false,
        heatarray=:patches,
        heatkwargs=(
            colormap=cgrad(:ice),
            ),
            
        )
    #https://makie.juliaplots.org/stable/documentation/figure/
    #https://makie.juliaplots.org/v0.15.2/examples/layoutables/gridlayout/
    figure,_= abmexploration(model;agent_step!,am = polygon_marker,ac = :red,plotkwargs...)
    figure 
end
end