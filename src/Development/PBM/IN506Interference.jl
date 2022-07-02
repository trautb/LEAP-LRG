module Interference
using Agents
using InteractiveDynamics, GLMakie,LinearAlgebra, Random
export demo
include("./AgentToolBox.jl")
using .AgentToolBox

mutable struct ESource <: AbstractAgent
    id::Int                   
    pos::NTuple{2,Float64}              
    phase:: Float64
    EBSource:: Float64
end   

    function initialize_model(  
        ;n_sources = 2,
        worldsize,
        extent = (worldsize, worldsize),
        EB = zeros(extent),
        dEB_dt= zeros(extent),
        ticks=1,
        c=1.0,
        freq=1.0,
        dt = 0.1,
        dxy=0.1,
        attenuation= 0.03,
        )
        space = ContinuousSpace(extent, 1.0)

        properties = Dict(
            :EB => EB,        #patches
            :dEB_dt => dEB_dt,
            :ticks => ticks,
            :c => c,
            :freq => freq,
            :dt => dt,
            :dxy => dxy,
            :attenuation => attenuation,
            :worldsize => worldsize,

        )

        model = ABM(ESource, space, scheduler = Schedulers.randomly,properties = properties)

        for id in 1:n_sources
            if (id == 1)
                pos = Tuple([1 round(((1/4)*worldsize))])
            else
                pos = Tuple([1 round(((3/4)*worldsize))])
            end
            phase = 0
            EBSource = 0.0
            add_agent!(
            pos,
            model,
            phase,
            EBSource,
            )
        end
        return model
    end
    
    function model_step!(model)
        
        for particle in allagents(model)
            particle.EBSource = sin(particle.phase + 2π * model.freq * model.ticks * model.dt)
            model.EB[Int(particle.pos[1]), Int(particle.pos[2])] = particle.EBSource
        end
        e_field_pulsation(model)
        model.ticks += 1
    end

    function e_field_pulsation(model)
        h = 4
        nma(i,j) = [[i+1,j], [i-1,j], [i,j-1], [i,j+1]]
        mw_EB = zeros(model.worldsize,model.worldsize)
        map(CartesianIndices((1:model.worldsize-1,1:model.worldsize-1))) do x
            meannb = mean_nb(model.EB, nma(x[1],x[2]))
            mw_EB[x[1],x[2]] = (4/(h^2))*(meannb-model.EB[x[1],x[2]])
        end
       
        model.dEB_dt = model.dEB_dt.+model.dt .*model.c .*model.c .* (mw_EB.-model.EB)./(model.dxy*model.dxy)
        model.dEB_dt = model.dEB_dt.*(1 - model.attenuation)
        model.EB =  model.EB .+  model.dt .*  model.dEB_dt
    end
   
    function demo(worldsize)
        model = initialize_model(worldsize=worldsize);
        #https://docs.juliaplots.org/latest/generated/colorschemes/
        params = Dict(
        :freq => 0.1:0.1:2,
        :attenuation => 0:0.01:0.1
        )
        plotkwargs = (
        heatarray = :EB,
        add_colorbar=false,
        heatkwargs = (
            colorrange=(-1, 1),
            colormap = cgrad(:oslo), 
        ))
        figure,_= abmexploration(model;model_step!,params,ac = :yellow,plotkwargs...)
        figure
    end
end
