module Swarm
using Agents
using InteractiveDynamics, GLMakie,LinearAlgebra, Random
export demo

    mutable struct LightSource <: AbstractAgent
        id::Int                    # Boid identity
        pos::NTuple{2,Float64}              # Position of boid
    end

    function initialize_model(  
        ;n_sources = 2,
        worldsize,
        griddims = (worldsize, worldsize),
        patches = zeros(griddims),
        ticks=1,
        deJong7= true,
        pPop = 0.0,
        u = 0.0,
        )
        space2d = ContinuousSpace(griddims, 1.0)

        properties = Dict(
            :patches => patches,
            :pPop => pPop,
            :u => u,
            :ticks => ticks
            :deJong7 => deJong7

        )

        
        world = ABM(LightSource, space2d, scheduler = Schedulers.randomly,properties = properties)
        
        #Id = 1* Matrix(I,worldsize,worldsize)
        #Idfill = Id.*collect(0:1/(worldsize-1):1)
        #world.patches = (world.patches * Idfill)'
        
        if deJong7 == true
            xy = ((collect(-(worldsize/2):1:(worldsize/2))).*10)./worldsize
            for i = 1:worldsize
                y = xy[i]
                for j = 1:worldsize
                    x = xy[j]
                    patches[i,j] = x * sin(180 * 4 * x / pi) + 1.1 * y * sin(180 * 2 * y / pi);
                    println(patches[i,j])
                end
            end
        else
            xy = ((collect(-(worldsize/2):1:(worldsize/2))).*6)./worldsize
            for i = 1:worldsize
                y = xy[i]
                for j = 1:worldsize
                    x = xy[j]
                    patches[i,j] = (1/3)*exp(-((x+1)^2)-(y^2))+10*(x/5-(x^3)-(y^5))*exp(-(x^2)-(y^2))-(3*((1-x)^2))*exp(-(x^2)-((y+1)^2));
                    println(patches[i,j])
                end
            end
        end
        
        
        

        #world.patches = world.patches .- world.patches'
        for _ in 1:n_sources
            pos = Tuple([1 worldsize/4]')
            add_agent!(
            pos,
            world,
            )
        end

        return world
    end

    function agent_step!(source,world)
    end

    function model_step!()
    end
    function demo()
        world = initialize_model(worldsize = 160);
        
        plotkwargs = (
        heatarray = :patches,

        heatkwargs = (
            #https://docs.juliaplots.org/latest/generated/colorschemes/
            colorrange = (-8,0),
            colormap = cgrad(:ice)
        ),
    
        )
        

        figure,p= abmexploration(world;params = Dict(),ac = :red,plotkwargs...)
        Figure(resolution = ((length(world.patches)/2)*4, (length(world.patches)/2)*4))
        figure
    end
    
end