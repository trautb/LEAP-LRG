#========================================================================================#
"""
	IN515Turing

**Module Turing**: \\
This program is an exercise in how to speed up a simulation by directly
calculating values that aren't quite correct, but are *good enough* to help you
model a complex biological system. Do you remember how boringly slow the
reaction-diffusion system was in chapter 14? That was because we had to
painfully solve the dynamics of the system using Euler's method.


Author: Niall Palfreyman (April 2020), Nick Diercksen (July 2022)
"""
module Turing

export demo_explorer                        # Externally available names
using Agents, GLMakie, InteractiveDynamics  # Required packages

include("./AgentToolBox.jl")
import .AgentToolBox: rotate_2dvector, buildDeJong7, buildValleys, reinit_model_on_reset!

#-----------------------------------------------------------------------------------------
# Module definitions:

#-----------------------------------------------------------------------------------------
"""
	Patch

In this implementation this agent struct will only be used as a dummy.
Since this is an approximation, only matrices containing attributes of each patch
are used. But to run the simulation and create the model, we need an AbstractAgent subtype.
"""
mutable struct Patch <: AbstractAgent
	id::Int                         # id of the agent needed by the model
	pos::NTuple{2,Float64}          # position of the patch
	# differentiation::Float64      # My current level of differentiation.
	# activators::Int64             # The cells around me that can activate my differentiation.
	# inhibitors::Int64             # The cells further away that can inhibit my differentiation.
end


const dt = 0.1


#  Module methods: -------------------------------------------------------------

"""
initialize_model()

Create the world model.
"""
function initialize_model(;
	inner_radius_x=2.5,
	inner_radius_y=4.2,
	outer_radius_x=6.0,
	outer_radius_y=6.8,
	inhibition=0.35,
	worldsize=140,
	extent=(worldsize, worldsize)
)

	properties = Dict(
		:differentiation => rand(extent...),                # differentiation levels of the patches
		:activators => Matrix{Vector{Tuple{Int64,Int64}}},  # activators for each patch
		:inhibitors => Matrix{Vector{Tuple{Int64,Int64}}},  # inhibitors for each patch
		:inner_radius_x => inner_radius_x,                  # adjustable inner radius
		:inner_radius_y => inner_radius_y,                  # adjustable inner radius
		:outer_radius_x => outer_radius_x,                  # adjustable outer radius
		:outer_radius_y => outer_radius_y,                  # adjustable outer radius
		:inhibition => inhibition,                          # inhibition factor
	)

	model = ABM(Patch, ContinuousSpace(extent, 1.0); properties=properties)

	set_influencers!(model)

	add_agent!(model)   # Add one dummy agent so that abm_exploration will allow us to plot.
	return model
end

# ------------------------------------------------------------------------------

"""
	set_influencers!(model)

part of the initialization
"""
function set_influencers!(model)
	patches = positions(model) |> collect

	# Compute inner-neighbours in an ellipse around each cell:
	model.activators = map(patches) do patch
		nearNbrs(patch, model)
	end
	# Compute outer-neighbors in a ring around each cell (computationally expensive!):
	model.inhibitors = map(patches) do patch
		farNbrs(patch, model)
	end
	return model
end

# step functions ---------------------------------------------------------------

"""
	model_step!(world)

Simulate the Turing activator-inhibitor system, in which a random individual dies, and is replaced by a
child from a random neighbour, except that blues may have an evolutionary advantage AB.
"""
function model_step!(model)
	for patch ∈ positions(model)
		differentiate!(patch, model)
	end
end

"""
    differentiate!()

procedure to increment the differentiation level of the patch.
"""
function differentiate!(patch, model::AgentBasedModel)
	# Calculate total activatory influence on me ...
	activation = mapreduce(+, model.activators[patch...]) do activator
		model.differentiation[activator...]
	end
	inhibition = mapreduce(+, model.inhibitors[patch...]) do inhibitor
		model.differentiation[inhibitor...]
	end
	activation = activation - model.inhibition * inhibition

	# ... then change my differentiation level in accordance:
	model.differentiation[patch...] = (1 - dt) * model.differentiation[patch...]
	if activation > 0
		# Convex combination upwards towards 1:
		model.differentiation[patch...] = model.differentiation[patch...] + dt
	end
	return model
end



#  Helper procedures for defining elliptical neighborhoods. --------------------

"""
	nearNbrs()
	
Calculate my nearest neighbours, who will activate me.
"""
function nearNbrs(patch, model)  #  patch procedure
	neighbours = nearby_positions(patch, model, max(model.inner_radius_x, model.inner_radius_y)) |> collect
	filter!(neighbours) do pos
		1.0 >= (xdistance(patch, pos, model)^2) / (model.inner_radius_x^2) +
			   (ydistance(patch, pos, model)^2) / (model.inner_radius_y^2)
	end
	return neighbours 
end

"""
	farNbrs()

Calculate my further neighbours, who will inhibit me.
"""
function farNbrs(patch, model)  #  patch procedure
	neighbours = nearby_positions(patch, model, max(model.outer_radius_x, model.outer_radius_y)) |> collect
	filter!(neighbours) do pos
		1.0 >= (xdistance(patch, pos, model)^2) / (model.outer_radius_x^2) +
			   (ydistance(patch, pos, model)^2) / (model.outer_radius_y^2) &&
			1.0 < (xdistance(patch, pos, model)^2) / (model.inner_radius_x^2) +
				  (ydistance(patch, pos, model)^2) / (model.inner_radius_y^2)
	end
	return neighbours
end

# ------------------------------------------------------------------------------
"""
	xdistance()

Patch procedure. Calculate the difference in x-position between me and
other-patch. Note: We cannot simply calculate the difference in pxcor values, because the
two patches might be separated by the world boundary.
"""
function xdistance(patch, other_patch, model)
	other_patch = (first(other_patch), last(patch))
	return edistance(Float64.(patch), Float64.(other_patch), model)
end

"""
	ydistance()

Patch procedure. Calculate the difference in y-position between me and
other-patch. Again, the two patches might be separated by the world boundary.
"""
function ydistance(patch, other_patch, model)
	other_patch = (first(patch), last(other_patch))
	return edistance(Float64.(patch), Float64.(other_patch), model)
end


#  execution and visualization: ------------------------------------------------

"""
	demo()

creates an interactive abmplot of the Turing module to visualize the
Turing activator-inhibitor system.
"""
function demo()
	params = Dict(
		:inner_radius_x => 0:0.1:10,
		:inner_radius_y => 0:0.1:10,
		:outer_radius_x => 0:0.1:10,
		:outer_radius_y => 0:0.1:10,
		:inhibition => 0:0.01:2
	)

	plotkwargs = (
		add_colorbar=false,
		heatarray=:differentiation,
		heatkwargs=(
			colorrange=(0, 1),
			colormap=cgrad([:orange, :black]; categorical=true),
		),
		as=0,
	)

	model = initialize_model()
	fig, p = abmexploration(model; (agent_step!)=dummystep, model_step!, params, plotkwargs...)
    reinit_model_on_reset!(p, fig, initialize_model)

	fig
end

end # ... of module Turing