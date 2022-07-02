module Swarm
using Agents
using InteractiveDynamics, GLMakie,LinearAlgebra, Random
export demo
include("./AgentToolBox.jl")
using .AgentToolBox
mutable struct Agent <: AbstractAgent
    id::Int                    # Boid identity
    pos::NTuple{2,Float64}              # Position of boid
    vel::NTuple{2,Float64}
    patchvalue:: Float64 
end

function initialize_model(  
    ;n_sources = 640,
    worldsize,
    griddims = (worldsize, worldsize),
    ticks=1,
    deJong7= false,
    pPop = 0.0,
    )
    space2d = ContinuousSpace(griddims, 1.0)

    patches = deJong7 ? buildDeJong7(worldsize) : buildValleys(worldsize)

    properties = Dict(
        :patches => patches,
        :pPop => pPop,
        :ticks => ticks
        :deJong7 => deJong7,
        :worldsize => worldsize
    )
    
    
    model = ABM(Agent, space2d, scheduler = Schedulers.fastest,properties = properties)
    
    
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

function buildValleys(worldsize)
    maxCoordinate = worldsize / 2
    xy = 4 .* collect(-maxCoordinate:(maxCoordinate-1)) ./ maxCoordinate
    f(x, y) = (1 / 3) * exp(-((x + 1)^2) - (y^2)) +
                10 * (x / 5 - (x^3) - (y^5)) * exp(-(x^2) - (y^2)) -
                (3 * ((1 - x)^2)) * exp(-(x^2) - ((y + 1)^2))
    f.(xy, xy')
end
function buildDeJong7(worldsize)
    maxCoordinate = worldsize / 2
    xy = 20 .* collect(-maxCoordinate:(maxCoordinate-1)) ./ maxCoordinate
    f(x, y) = sin(180 * 2 * x / pi) / (1 + abs(x)) + sin(180 * 2 * y / pi) / (1 + abs(y))
    f.(xy, xy')
end

function agent_step!(sources,model)
    
    ids = collect(nearby_ids(sources.pos, model, 4,exact=false))
    patch(ids) = model[ids].patchvalue
    min_patch(patch, itr) = itr[argmin(map(patch, itr))]
    id = min_patch(patch, ids)
    sources.vel = eigvec(model[id].pos.-sources.pos)
    move_agent!(sources,model,1);
    sources.patchvalue = model.patches[round(Int,sources.pos[1]),round(Int,sources.pos[2])]

end

function demo()
    worldsize = 80
    model = initialize_model(worldsize=worldsize);
    
    plotkwargs = (
        add_colorbar=false,
        heatarray=:patches,
        heatkwargs=(
            # colorrange=(-8, 0),
            colormap=cgrad(:ice),
            ),
            
        )
    #https://makie.juliaplots.org/stable/documentation/figure/
    #https://makie.juliaplots.org/v0.15.2/examples/layoutables/gridlayout/
    figure,_= abmexploration(model;agent_step!,am = particlemarker,ac = :red,plotkwargs...)
    figure 
end
end