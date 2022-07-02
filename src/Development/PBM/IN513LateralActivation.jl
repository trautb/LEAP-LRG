module LateralActivation
using Agents
using InteractiveDynamics, GLMakie,LinearAlgebra, Random
export demo
include("./AgentToolBox.jl")
using .AgentToolBox

mutable struct Source <: AbstractAgent
    id::Int                    # Boid identity
    pos::NTuple{2,Float64}              # Position of boid
end   

function initialize_model(  
    ;n_sources::Int = 1,
    worldsize::Int64 = 100,
    griddims = (worldsize, worldsize),
    patches = zeros(griddims),
    dt = 1,   
    aBic = 0.01,      
    rnaBic= 0.001,    
    cBic= 0.01,      
    KBic= 0.1,      
    DBic = 0.01,      
    bBic= 0.0,
    )
    space2d = ContinuousSpace(griddims, 1.0)

    properties = Dict(
        :worldsize => worldsize,
        :patches => patches,
        :dt  => dt,                                    
        :aBic  => aBic,                                   
        :rnaBic => rnaBic,                                 
        :cBic  =>  cBic,                                
        :KBic  => KBic,                                  
        :DBic  => DBic,
        :bBic=> bBic ,                                
    )
    model = ABM(Source, space2d, scheduler = Schedulers.randomly,properties = properties)
    model.patches[1, Int(round(((1/2)*worldsize)))] = model.rnaBic
    model.bBic = model.rnaBic
    add_agent!(
    Tuple([1,round(((1/2)*worldsize))]),
    model,
    )
    return model
end
    
function model_step!(model)
    model.patches= diffuse4(model.patches,model.dt*model.DBic)
end

function react(model,mat,origin)

    map(CartesianIndices(( 1:size(mat)[1], 1:size(mat)[2]))) do x
        if (x[1] == origin[1] && x[2] == origin[2])
            bBic = 0.0
        else
            bBic = model.bBic
        end
        hill(s,K) = s^3 / (s^3+K^3)
        mat[x[1],x[2]] = (mat[x[1],x[2]]+model.dt*(bBic - (model.aBic * mat[x[1],x[2]]) + (model.cBic*hill(mat[x[1],x[2]], model.KBic) )))
    end
    return mat
end 
   
function demo()
    model = initialize_model(worldsize=40);
    #https://docs.juliaplots.org/latest/generated/colorschemes/

    plotkwargs = (
    heatarray = :patches,
    add_colorbar=false,
    heatkwargs = (
        colormap = cgrad(:ice), #Set1_3
    ),
    )
    figure,_= abmexploration(model;model_step!,params = Dict(),plotkwargs...)
    figure
end

end
