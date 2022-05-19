#========================================================================================#
"""
	BasicGA

An agentbased Implementation of the Basic Genetic Algorithm (i.e. just using 
genetic mutation and recombination).

Author: Benedikt Traut, 12/05/2022.
"""
module BasicGA

#export

include("../utils/Mutations.jl")
include("../utils/Selections.jl")
include("../utils/Recombinations.jl")
include("../utils/Objectives.jl")

using .Mutations, .Recombinations, .Selections, .Objectives
using Agents

#-----------------------------------------------------------------------------------------
# Module types:

"""
	BasicGAAgent

The basic agent in the simulation
"""
@agent BasicGAAgent GridAgent{2} begin
	genome::Vector{Bool}
end

#-----------------------------------------------------------------------------------------
# Module methods:

"""
	initialize

Initializes the simulation.
"""
function initialize(; N = 100, M = 20, mutation = DummyMutation, recombination = DummyRecombination)
	space = GridSpace((M, M); periodic = false)
	properties = Dict(
		:mutations => mutation,
		:recombinations => recombination
	)
	

end