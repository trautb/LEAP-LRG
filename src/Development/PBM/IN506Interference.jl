module Interference
using Agents
using InteractiveDynamics, GLMakie,LinearAlgebra, Random
export demo
mutable struct LightSource <: AbstractAgent
    id::Int                    # Boid identity
    pos::NTuple{2,Float64}              # Position of boid
    phase:: Float64
    EBSource:: Float64
end   

    function initialize_model(  
        ;n_sources = 1,
        worldsize,
        griddims = (worldsize, worldsize),
        EB = zeros(griddims),
        dEB_dt= zeros(griddims),
        ticks=1,
        c=1.0,
        freq=1.0,
        dt = 0.1,
        dxy=0.1
        )
        space2d = ContinuousSpace(griddims, 1.0)

        properties = Dict(
            :EB => EB,        #patches
            :dEB_dt => dEB_dt,
            :ticks => ticks,
            :c => c,
            :freq => freq,
            :dt => dt,
            :dxy => dxy,
            :worldsize => worldsize,
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
                pos = Tuple([2 round(((1/4)*worldsize))])
            else
                pos = Tuple([2 round(((3/4)*worldsize))])

            end
            phase = 0
            EBSource = 0.0
            add_agent!(
            pos,
            world,
            phase,
            EBSource,
            )
            i += 1;
        end
        return world
    end
    
    function agent_step!(source,world)
        
        #println("\n")
        #println(source.id)
        #println("\n")
        source.EBSource = sin(source.phase + 2π * world.freq * world.ticks * world.dt)

        world.EB[Int(source.pos[1]), Int(source.pos[2])] = source.EBSource
        println("\n")
        show(stdout, "text/plain", world.EB)
        println("\n")
        mw_EB = zeros(world.worldsize,world.worldsize)
        h = 4
        map(CartesianIndices((2:13,2:13))) do x
            mw_EB[x[1],x[2]] = (4/(h^2))*(world.EB[x[1],x[2]-1]+world.EB[x[1],x[2]+1] + world.EB[x[1]-1,x[2]] + world.EB[x[1]+1,x[2]]-world.EB[x[1],x[2]])
        end
       
        world.dEB_dt = world.dEB_dt.+world.dt .*world.c .*world.c .* (mw_EB.-world.EB)./(world.dxy*world.dxy)
        attu = 0.03
        world.dEB_dt = (1 - attu).*world.dEB_dt
        println("\n")
        show(stdout, "text/plain", world.dEB_dt)
        println("\n")
        world.EB =  world.EB .+  world.dt .*  world.dEB_dt
        world.ticks += 1

        println("\n")
        show(stdout, "text/plain", world.EB)
        println("\n")
        println("-------------------")
    end

   
    function demo()
        world = initialize_model(worldsize=14);
        #https://docs.juliaplots.org/latest/generated/colorschemes/
        plotkwargs = (
        heatarray = :EB,
        add_colorbar=false,
        heatkwargs = (
            colorrange=(-1, 1),
            colormap = cgrad(:bluesreds), #Set1_3
        ),
    
        )
        

        figure,p= abmexploration(world;agent_step!,params = Dict(),ac = :red,plotkwargs...)
        figure
    end

end
