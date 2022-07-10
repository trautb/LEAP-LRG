#========================================================================================#
"""
	IN507NeutralDrift

**Module NeutralDrift**: \\
	This model runs a very simple simulation called a Moran process. At each
	step, a random individual dies, and is replaced by a child of one of its
	neighbours. We have added in here the possibility that blue individuals have
	a slight selective advantage over green individuals, but notice how even
	such a tiny advantage a huge effect on the outcome of the simulation!


Author: Niall Palfreyman (March 2020), Nick Diercksen (May 2022)
"""
module NeutralDrift

export demo                                 # Externally available names
using Agents, GLMakie, InteractiveDynamics  # Required packages

include("./AgentToolBox.jl")
import .AgentToolBox: reinit_model_on_reset!

#-----------------------------------------------------------------------------------------
# Module definitions:

#-----------------------------------------------------------------------------------------
"""
	Patch

In this implementation this agent struct will only be used as a dummy.
Patches will be implemented as a matrix and not individual agents, but to run
the simulation and create the model, we need an AbstractAgent subtype.
"""
mutable struct Patch <: AbstractAgent
	id::Int                         # id of the agent needed by the model
	pos::NTuple{2,Float64}          # position of the patch
end

const blue = true;
const lime = false;

#-----------------------------------------------------------------------------------------
# Module methods:

#-----------------------------------------------------------------------------------------
"""
	initialize_model(...)

Create the world model.
"""
function initialize_model(;
	pB=0.5,                 # proportion of blues
	AB=0.000,               # Evolutionary advantage of blue individuals
	worldsize=32,           
	extent=(worldsize, worldsize)
)

	properties = Dict(
		:patches => rand(extent...) .< pB,
		:pB => pB,
		:AB => AB
		)

	model = ABM(Patch, ContinuousSpace(extent,1.0); properties=properties)
	add_agent!(model) # Add one dummy agent so that abm_exploration will allow us to plot.

	return model
end

#-----------------------------------------------------------------------------------------

"""
	model_step!(world)

Simulate a Moran process, in which a random individual dies, and is replaced by a
child from a random neighbour, except that blues may have an evolutionary advantage AB.
"""
function model_step!(model)
	patch = rand(CartesianIndices(model.patches))
	adjacent_patches = nearby_positions(patch.I, model).itr.iter
	random_neighbour = patch + rand(adjacent_patches)

	random_neighbour = min(                         # keeping the neighbour inbounds
		CartesianIndex(Int.(size(model.space))),
		max(CartesianIndex(1, 1), random_neighbour)
	)
	model.patches[patch] = model.patches[random_neighbour]

	# If that colour was blue, do it, otherwise only set
	# to green with a certain (unfair) probability:
	keeping_it_fair = model.patches[patch] == lime && rand() < 1 - model.AB
	model.patches[patch] = keeping_it_fair ? lime : blue
	return model
end

#-----------------------------------------------------------------------------------------

"""
	demo()

creates an interactive abmplot of the EmergentBehaviour module to visualize
Sierpinski's triangle.
"""
function demo()
	params = Dict(      # slider range values
		:pB => 0:0.1:1,
		:AB => 0:0.001:0.01
	)

	plotkwargs = (
		add_colorbar=false,
		heatarray=:patches,     # references the patches matrix of the model
		heatkwargs=(
			colorrange=(0, 1),
			colormap=cgrad([:lime, :blue]; categorical=true),
		),
		as = 0
	)

	model = initialize_model()
	fig, p = abmexploration(model; (agent_step!)=dummystep, model_step!, params, plotkwargs...)
	reinit_model_on_reset!(p, fig, initialize_model)

	fig
end

end # ... of module NeutralDrift