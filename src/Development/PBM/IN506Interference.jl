module Interference
using Agents
using InteractiveDynamics, GLMakie,LinearAlgebra, Random
export demo
mutable struct LightSource <: AbstractAgent
    id::Int                    # Boid identity
    pos::NTuple{2,Float64}              # Position of boid
    phase:: Float64
    c:: Float64
    dt:: Float64
    

    function initialize_model(;n_sources = 2,worldsize,psize,griddims = (worldsize, worldsize))
        space2d = ContinuousSpace(griddims, 1.0)

    properties = Dict(
        :growth_rate => growth_rate,
        :patches => patches = zeros(Int, griddims),
        :EB ==> EB
        :dEB/dt ==> dEB/dt
        :dxy ==> dxy
    )
    world = ABM(Source, space2d, scheduler = Schedulers.randomly,properties = properties)

    for I in CartesianIndices(model.patches)
        model.patches[I] =  rand(0:1)
    end
    i = 1
    for _ in 1:n_sources
        if (i == 1)
            Tuple([0 worldsize/4]')
        else
            Tuple([0 (3/4)*worldsize]')
        end
        add_agent!(
        pos,
        phase,
        c,
        dt,
        )
    end
    return world
end

function agent_step!(source,model)
end

function demo()
    world = initialize_model(worldsize = 100,psize=2);
    
end

end
