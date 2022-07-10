module Plasmodium
export plasmnutri10, demo4, model


"""
This is based on Jones's Physarum model, 
which simulates very well the behaviour of a particular living system: 
the plasmodium phase of the life-cycle of the protist Physarum polycephalum.


Author: Nial Pallfreyman, Emilio Borrelli

"""

using Agents, LinearAlgebra
using Random # hides
using InteractiveDynamics
using GLMakie
include("./AgentToolBox.jl")
import .AgentToolBox: rotate_2dvector, turn_left, turn_right, diffuse4, remap_resetButton!, wrapMat, eigvec, is_empty_patch

# means plasmodium or nutrition source. unfortunately we can only create one agent per model
mutable struct plasmnutri10 <: AbstractAgent
	id::Int
	pos::NTuple{2,Float64}
	vel::NTuple{2,Float64}
	speed::Float64
	plasmodium::Bool
	size::Int64
	color::Symbol
end


function initialize_model(;
	pPop=0.1,
	rDollop=0.001,
	rEvapU=0.9,
	rDiffU=1.0,
	sensorAngle=60,
	wiggle=44,
	sensorRange=9,
	extent=(200, 200),
	spacing=0.5,
	tiles=zeros(200, 200),
	food=0)



	# defining the model's "globaly reachable" variables
	properties = Dict(:pPop => pPop,
		:rDollop => rDollop,
		:rEvapU => rEvapU,
		:rDiffU => rDiffU,
		:sensorAngle => sensorAngle,
		:wiggle => wiggle,
		:sensorRange => sensorRange,
		:tiles => tiles,
		:u => tiles,
		:nutrient => tiles,
		:cMap => tiles,
		:nuts => (((30, 65)), ((100, 65)), ((170, 65)), ((30, 135)), ((100, 135)), ((170, 135))),
		:food => food)

	# setting up space and model                    
	space2d = ContinuousSpace(extent, spacing)
	model = ABM(plasmnutri10, space2d; properties, scheduler=Schedulers.randomly)

	# add the plasmodii
	map(CartesianIndices((21:(extent[1]-21), 21:(extent[2]-21)))) do x
		#check if there is hazard on the tile
		if rand() < pPop
			vel = [rand(-1.0:0.01:1.0), rand(-1.0:0.01:1.0)]
			vel = eigvec(vel)
			add_agent!(
				Tuple(x),
				model,
				vel,
				1,
				true,
				1,
				:yellow
			)
		end
	end

	return model
end


"""
model_step:
evolves our system
"""
function model_step!(model::ABM)
	for i in model.agents
		sensorPhase(i[2], model)
	end
	for j in model.agents
		motorPhase(j[2], model)
	end
	nicheDynamics(model)
end


"""
sensorPhase:
controlls the direction of our plasmodii:
sniff around and turn to face the highest concentration of chemoattractants
"""
function sensorPhase(plasmodium, model)
	#sniff and turn to face the highest concentration of chemoattractants
	#sniff ahead
	sA = sniff_ahead(plasmodium, model)
	#sniff rigth
	sR = sniff_right(plasmodium, model.sensorAngle, model) - sA
	#sniff left
	sL = sniff_left(plasmodium, model.sensorAngle, model) - sA
	# turn to face highest concentration
	if (sL > 0) || (sR > 0)
		if (sL > 0) && (sR > 0)
			plasmodium.vel = turn_right(plasmodium, rand(1:model.wiggle) - rand(1:model.wiggle))
			#; Here is Jones's code for the above line:
			if rand() < 0.5
				plasmodium.vel = turn_right(plasmodium, model.wiggle)
			else
				plasmodium.vel = turn_left(plasmodium, model.wiggle)
			end
		else
			if (sL > 0)
				plasmodium.vel = turn_left(plasmodium, model.wiggle)
			else
				plasmodium.vel = turn_right(plasmodium, model.wiggle)
			end
		end
	end
end


"""
motorPhase: 
controll the movement of our plasmodii. attempt to move,
if tile is occupied by other plasmodium: turn randomly
"""
function motorPhase(plasmodium, model)
	#attempt to move if space is available and drop chemoattractants
	#println("motorphase")
	if plasmodium.plasmodium == true
		if is_empty_patch(plasmodium, model)
			#println("true")
			move_agent!(plasmodium, model, plasmodium.speed)
			pos = collect(plasmodium.pos)
			pos = [round(Int, pos[1]), round(Int, pos[2])]
			pos = wrapMat(200, 200, pos, false)
			model.u[pos[1], pos[2]] += model.rDollop
		else
			#println("false")
			#turn to random direction
			plasmodium.vel = turn_right(plasmodium, rand(1:360))
			#if rand()>0.8
			#move_agent!(plasmodium,model,plasmodium.speed) 
		end
	end
end



"""
nicheDynamics: 
set nutrients, evaporate and diffuse chemoattractants
"""
function nicheDynamics(model::ABM)
	#emmit nutrients
	map(model.nuts) do x
		model.u[x[1], x[2]] += model.nahrung
	end
	#evaporate
	model.u .*= (1 - model.rEvapU)
	#diffuse
	model.u = diffuse4(model.u, model.rDiffU, true)
	#set the colormap to math chemoattractants
	model.cMap = model.u
end



#--------------------------------------------------------------------------------------------
# Utilities:
# 
#--------------------------------------------------------------------------------------------
"""
makes the agents sniff around to find the highest concentration of chemoattractants
"""
function sniff_right(agent::AbstractAgent, angle, model::ABM)
	sniffpos = collect(agent.pos) + (collect(eigvec(rotate_2dvector(360 - angle, agent.vel))) * model.sensorRange)
	sniffpos = [round(Int, sniffpos[1]), round(Int, sniffpos[2])]
	sniffpos = wrapMat(200, 200, sniffpos, false)
	return model.u[sniffpos[1], sniffpos[2]]
end


function sniff_left(agent::AbstractAgent, angle, model::ABM)
	sniffpos = collect(agent.pos) + (collect(eigvec(rotate_2dvector(angle, agent.vel))) * model.sensorRange)
	sniffpos = [round(Int, sniffpos[1]), round(Int, sniffpos[2])]
	sniffpos = wrapMat(200, 200, sniffpos, false)
	return model.u[sniffpos[1], sniffpos[2]]
end


function sniff_ahead(agent::AbstractAgent, model::ABM)
	sniffpos = collect(agent.pos) + (collect(agent.vel) * model.sensorRange)
	sniffpos = [round(Int, sniffpos[1]), round(Int, sniffpos[2])]
	sniffpos = wrapMat(200, 200, sniffpos, false)
	return model.u[sniffpos[1], sniffpos[2]]
end

function demo4()
	plotkwargs = (
		add_colorbar=false,
		heatarray=:cMap,
		heatkwargs=(
			colormap=cgrad(:bluesreds),
		),)

	params = Dict(
		:sensorAngle => 1:1:90,
		:wiggle => 1:1:90,
		:sensorRange => 1:1:20,
		:food => 0:1:100,)

	model = initialize_model()
	cellcolor(a::plasmnutri10) = a.color
	cellsize(a::plasmnutri10) = a.size
	fig, p = abmexploration(model; model_step!, params, ac=cellcolor, as=cellsize, plotkwargs...)
	fig
end


end