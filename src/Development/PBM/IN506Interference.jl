module Interference
using Agents
using InteractiveDynamics, GLMakie,LinearAlgebra, Random
export demo
include("./AgentToolBox.jl")
using .AgentToolBox

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

        model = ABM(LightSource, space2d, scheduler = Schedulers.randomly,properties = properties)
        
    
      
        for id in 1:n_sources
            if (id == 1)
                pos = Tuple([2 round(((1/4)*worldsize))])

            else
                pos = Tuple([2 round(((3/4)*worldsize))])

            end
            
            phase = 0
            EBSource = 0.0
            #model.EB[Int(pos[1]), Int(pos[2])] = EBSource
            add_agent!(
            pos,
            model,
            phase,
            EBSource,
            )
        end
        return model
    end
    
    function agent_step!(source,model)
        
        #println("\n")
        #println(source.id)
        #println("\n")
        source.EBSource = sin(source.phase + 2π * model.freq * model.ticks * model.dt)
        println(source.EBSource)
        #source.EBSource = 1.0
        model.EB[Int(source.pos[1]), Int(source.pos[2])] = source.EBSource

        attu = 0.003
        model.EB = diffuse4(model.EB,0.3)
        #model.dEB_dt = model.dEB_dt.+model.dt .*model.c .*model.c .* (mw_EB.-model.EB)./(model.dxy*model.dxy)
        #model.EB = model.EB.*(1 - attu)
        #model.EB =  model.EB .+  model.dt .*  model.dEB_dt
        #=
        si = floor(Int,sqrt(length(model.EB)))
        cart(i,j) = (j-1)*si+i
        nma(i,j) = [cart(i,j-1) cart(i,j+1) cart(i-1,j) cart(i+1,j)]

        map(CartesianIndices((2:13,2:13))) do x
            #model.EB[nma(x[1],x[2])] .= 0.8 * model.EB[x[1],x[2]]
            model.EB[x[1],x[2]-1] = 0.8 * model.EB[x[1],x[2]]
            model.EB[x[1],x[2]+1] = 0.8 * model.EB[x[1],x[2]]
            model.EB[x[1]-1,x[2]] = 0.8 * model.EB[x[1],x[2]]
            model.EB[x[1]+1,x[2]] = 0.8 * model.EB[x[1],x[2]]
        end
        
        =#
        
        #=
        mw_EB = zeros(model.worldsize,model.worldsize)
        h = 2
        map(CartesianIndices((2:13,2:13))) do x
            mw_EB[x[1],x[2]] = (1/(h^2))*(model.EB[x[1],x[2]-1]+model.EB[x[1],x[2]+1] + model.EB[x[1]-1,x[2]] + model.EB[x[1]+1,x[2]]-4*model.EB[x[1],x[2]])
        end
       
        model.dEB_dt = model.dEB_dt.+model.dt .*model.c .*model.c .* (mw_EB.-model.EB)./(model.dxy*model.dxy)
        attu = 0.03
        model.dEB_dt = model.dEB_dt.*(1 - attu)
        println("\n")
        show(stdout, "text/plain", model.dEB_dt)
        println("\n")
        model.EB =  model.EB .+  model.dt .*  model.dEB_dt
        model.ticks += 1

        println("\n")
        show(stdout, "text/plain", model.EB)
        println("\n")
        println("-------------------")
        =#
    end

   
    function demo()
        model = initialize_model(worldsize=14);
        #https://docs.juliaplots.org/latest/generated/colorschemes/
        plotkwargs = (
        heatarray = :EB,
        add_colorbar=false,
        heatkwargs = (
            #colorrange=(-1, 1),
            colormap = cgrad(:ice), #Set1_3
        ),
    
        )
        figure,p= abmexploration(model;agent_step!,params = Dict(),ac = :red,plotkwargs...)
        figure
    end

end
