module Interference
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
        EB=0.0,
        dEB_dt=0.0,
        dxy=0.1,
        c=1.0,
        dt = 0.1)
        space2d = ContinuousSpace(griddims, 1.0)

        properties = Dict(
            :patches => patches,
            :dEB_dt => dEB_dt,
            :dxy => dxy,
            :ticks => ticks
            :EB => EB
            :c => c
            :dt => dt
        )
        #=
        properties[:patches] = zeros(Int, griddims);
        properties[:growth_rate] = 1.0;
        properties[:EB] = 1.0;
        properties[:dEB_dt] = 1.0;  
        properties[:dxy] = 1.0;     
        =#
        world = ABM(LightSource, space2d, scheduler = Schedulers.randomly,properties = properties)
        
    
        i = 1
        for _ in 1:n_sources
            if (i == 1)
                pos = Tuple([1 worldsize/4]')
                #index_1 = round(Int,pos[1]);
                #index_2 = round(Int,pos[2]);
                #world.patches[index_1:index_1+1, index_2-1:index_2+1] .= 0.5
            else
                pos = Tuple([1 (3/4)*worldsize]')

            end
            phase = 90.0
            EB = 0.0
            add_agent!(
            pos,
            world,
            phase,
            EB,
            )
            i += 1;
        end
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
