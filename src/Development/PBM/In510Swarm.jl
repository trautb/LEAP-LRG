module Swarm
using Agents
using InteractiveDynamics, GLMakie,LinearAlgebra, Random
export demo

    mutable struct LightSource <: AbstractAgent
        id::Int                    # Boid identity
        pos::NTuple{2,Float64}              # Position of boid
        phase:: Float64
        EB:: Float64
    end

    function initialize_model(  
        ;n_sources = 2,
        worldsize,psize,
        griddims = (worldsize, worldsize),
        patches = zeros(griddims),
        ticks=1,
        deJong7= true,
        )
        space2d = ContinuousSpace(griddims, 1.0)

        properties = Dict(
            :patches => patches,
            :pPop => pPop,
            :u => u,
            :ticks => ticks
            :deJong7 => deJong7

        )

        if (deJong7==true)
            let x = 10 * (rand(1:worldsize)/worldsize)
            let y = 10 * (rand(1:worldsize)/worldsize)
        else
        
        end


        world = ABM(LightSource, space2d, scheduler = Schedulers.randomly,properties = properties)

        return world
    end

    function agent_step!(source,world)
        freq = 1/50;
        source.EB = sin(source.phase + 360 * freq * world.ticks * world.dt)
    end

    function model_step!()
    
    function demo()
        world = initialize_model(worldsize = 100,psize=2);
        
        plotkwargs = (
        heatarray = :patches,

        heatkwargs = (
            colorrange = (0, 1),
            #colormap = [:blue, :yellow]
            colormap = cgrad(:blues)
        ),
    
        )
        

        figure,p= abmexploration(world;params = Dict(),ac = :red,plotkwargs...)
        figure
    end
    
end