module Swarm
using Agents
using InteractiveDynamics, GLMakie,LinearAlgebra, Random
export demo

    mutable struct Agent <: AbstractAgent
        id::Int                    # Boid identity
        pos::NTuple{2,Float64}              # Position of boid
        vel::NTuple{2,Float64}
        patchvalue:: Float64 
    end

    function initialize_model(  
        ;n_sources = 800,
        worldsize,
        griddims = (worldsize, worldsize),
        patches = zeros(griddims),
        ticks=1,
        deJong7= false,
        pPop = 0.0,
        )
        space2d = ContinuousSpace(griddims, 1.0)

        properties = Dict(
            :patches => patches,
            :pPop => pPop,
            :ticks => ticks
            :deJong7 => deJong7
        )

        ms = MyScheduler(1)
        model = ABM(Agent, space2d, scheduler = Schedulers.fastest,properties = properties)
        if deJong7 == true
            xy = ((collect(-(worldsize/2):1:(worldsize/2))).*10)./worldsize
            for i = 1:worldsize
                x = xy[i]
                for j = 1:worldsize
                    y = xy[j]
                    patches[i,j] = x * sin(180 * 4 * x / pi) + 1.1 * y * sin(180 * 2 * y / pi);
                    
                end
            end
        else
            xy = ((collect(-(worldsize/2):1:(worldsize/2))).*6)./worldsize
            #patches = map(((xy,xy),) -> (1/3)*exp(-((x+1)^2)-(y^2))+10*(x/5-(x^3)-(y^5))*exp(-(x^2)-(y^2))-(3*((1-x)^2))*exp(-(x^2)-((y+1)^2)),xy,xy);
            
            for i = 1:worldsize
                y = xy[i]
                for j = 1:worldsize
                    x = xy[j]
                    patches[i,j] = (1/3)*exp(-((x+1)^2)-(y^2))+10*(x/5-(x^3)-(y^5))*exp(-(x^2)-(y^2))-(3*((1-x)^2))*exp(-(x^2)-((y+1)^2));
                    
                end
            end
            
        end
        
        
        

        #world.patches = world.patches .- world.patches'
        for _ in 1:n_sources
            pos_random = rand(10:1:150,2,1)
            pos = Tuple([pos_random[1] pos_random[2]])
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

    function agent_step!(sources,model)
        ids = collect(nearby_ids(sources.pos, model, 8,exact=false))
        min_patchvalue = sources.patchvalue
        best_pos = sources.pos
        for id in ids
            if model[id].patchvalue < min_patchvalue
                min_patchvalue = model[id].patchvalue
                best_pos = model[id].pos
            end
        end
        sources.vel = Tuple([-sources.pos[1], -sources.pos[2]]) .+ best_pos
        if sources.vel[1] == 0.0 && sources.vel[2] == 0.0

        else
            vel1 = sources.vel[1]/sqrt((sources.vel[1])^2+(sources.vel[2])^2)
            vel2 = sources.vel[2]/sqrt((sources.vel[1])^2+(sources.vel[2])^2)
            sources.vel = Tuple([vel1 vel2])
        end
        
        
        
        if sources.vel[1]<0 && sources.vel[2] < 0
            sources.vel = sources.vel .+ (Tuple([-1 -1]).-sources.vel)
        elseif sources.vel[1]>0 && sources.vel[2] > 0
            sources.vel = sources.vel .+ (Tuple([1 1]).-sources.vel)
        elseif sources.vel[1]<0 && sources.vel[2] > 0
            sources.vel = sources.vel .+ Tuple([(-1-sources.vel[1]) (1-sources.vel[2])])
        elseif sources.vel[1]>0 && sources.vel[2] < 0
            sources.vel = sources.vel .+ Tuple([(1-sources.vel[1]) (-1-sources.vel[2])])
        end
        sources.patchvalue = model.patches[round(Int,sources.pos[1]),round(Int,sources.pos[2])]
        move_agent!(sources,model,1);
    end

    
    function particle_marker(b::Agent;)
        particle_polygon = Polygon(Point2f[(-0.25, -0.25), (0.5, 0), (-0.25, 0.25)])
        φ = atan(b.vel[2], b.vel[1])
        scale(rotate2D(particle_polygon, φ), 2)
    end

    function demo()
        model = initialize_model(worldsize = 160);
        heatarray = :patches
        heatkwargs = (colorrange = (-8,0),colormap = cgrad(:ice))

        plotkwargs = (;
        heatarray,
        add_colorbar = false,
        heatkwargs,
        
        );
        
        #https://makie.juliaplots.org/stable/documentation/figure/
        #https://makie.juliaplots.org/v0.15.2/examples/layoutables/gridlayout/
        figure,p= abmexploration(model;agent_step!,params = Dict(),am = particle_marker,ac = :red,plotkwargs...)
        Colorbar(figure[:,end+1],colormap = cgrad(:ice),limits = (-8,0))
        figure 
    end
    
end