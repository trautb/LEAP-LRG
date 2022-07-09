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
	;
	worldsize::Int,
	extent::Tuple{Int64, Int64} = (worldsize, worldsize),
	patches::Matrix{Float64} = zeros(extent),
	dt::Float64  = 1.0,   
	aBic::Float64  = 0.01,      
	rnaBic::Float64 = 0.001,    
	cBic::Float64 = 0.01,      
	KBic::Float64 = 0.1,      
	DBic::Float64  = 0.01,      
	bBic::Float64 = 0.0,
	)
	space = ContinuousSpace(extent, 1.0)

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
	model = ABM(Source, space, scheduler = Schedulers.randomly,properties = properties)
	model.patches[1, Int(round(((1/2)*worldsize)))] = model.rnaBic
	model.bBic = model.rnaBic
	add_agent!(
	Tuple([1,round(((1/2)*worldsize))]),
	model,
	)
	return model
end
	
function model_step!(model)
	model.patches = react(model,model.patches,Tuple([1,Int(round(((1/2)*model.worldsize)))]))
	model.patches= diffuse4(model.patches,model.dt*model.DBic,false)
	
end

function react(model,mat,origin)

	map(CartesianIndices(( 1:size(mat)[1], 1:size(mat)[2]))) do x
		if (x[1] == origin[1] && x[2] == origin[2])
			bBic = model.bBic
		else
			bBic = 0.0
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
