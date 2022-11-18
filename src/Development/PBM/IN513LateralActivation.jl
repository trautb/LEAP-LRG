"""
	LateralActivation

This is a model IN513LateralActivation of the basic process by which a Drosophila embryo constructs 
its segmentation during development out of a simple concentration gradient.
The world in this model is a syncytium: the multinucleated egg from which 
a fruitfly grub will develop. When you press Setup,a small amount of maternal
RNA for the protein Bicoid is placed in the left-hand nucleus of the syncytium.
When you press Go, this RNA is expressed, leading to a growing amount of Bicoid
in the left-hand cell. As the Bicoid concentration rises, it diffuses into the next
nucleus to the right. Over time, this process defines the rostral-caudal axis of the embryo.

Author: Stefan Hausner
"""
module LateralActivation
using Agents
using InteractiveDynamics, GLMakie,LinearAlgebra, Random
export demo
include("./AgentToolBox.jl")
using .AgentToolBox: diffuse4

mutable struct Source <: AbstractAgent
	id::Int                    
	pos::NTuple{2,Float64}              
end   
"""
Here the model is initalized and agents are set. 
First of all the model defines an diffusion source.
The model initialize  one patch with rnaBic.
Also, bBic is initalized with rnaBic.
Bbic only exists in the source patch.
"""
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

"""
After every step the matrix react to the change of concentration in a patch.
Then from this patches the model diffuses with the strength model.dt*model.DBic.

"""
function model_step!(model)
	model.patches = react(model,model.patches,Tuple([1,Int(round(((1/2)*model.worldsize)))]))
	model.patches= diffuse4(model.patches,model.dt*model.DBic,false)
	
end
"""
This function simulates the Rna expression of an Drosophila embryo.
"""
function react(model,mat,origin)

	map(CartesianIndices(( 1:size(mat)[1], 1:size(mat)[2]))) do x
		if (x[1] == origin[1] && x[2] == origin[2])
			bBic = model.bBic
		else
			bBic = 0.0
		end
		hill(s,K) = s^3 / (s^3+K^3)
		mat[x[1],x[2]] = (mat[x[1],x[2]]+model.dt*(bBic - (model.aBic * mat[x[1],x[2]]) + 
		(model.cBic*hill(mat[x[1],x[2]], model.KBic) )))
	end
	return mat
end 
"""
Here we plot our model. Plotkwargs creats the background for the 
patches with a colormap.
"""
function demo()
	model = initialize_model(worldsize=40);

	params = Dict(
		:DBic =>0.01:0.001:0.02,
		:cBic=>0.01:0.001:0.02,
		:aBic=>0.01:0.001:0.02,
		:rnaBic=>0.001:0.0005:0.002,
	)

	plotkwargs = (
	heatarray = :patches,
	add_colorbar=false,
	heatkwargs = (
		colormap = cgrad(:ice), #Set1_3
	))
	figure,_= abmexploration(model;model_step!,params,plotkwargs...)
	figure
end
end
