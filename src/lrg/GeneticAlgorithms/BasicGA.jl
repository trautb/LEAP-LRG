#= ====================================================================================== =#
"""
	BasicGA

An agentbased Implementation of the Basic Genetic Algorithm (i.e. just using selection, 
genetic mutation and recombination).

Authors: Alina Arneth, Michael Staab, Benedikt Traut, Adrian Wild 2022.
"""

include("../utils/Mutations.jl")
# include("../utils/Selections.jl")
include("../utils/TestSelections.jl") # TODO: change import to real Selections module
include("../utils/Recombinations.jl")
include("../utils/Objectives.jl")

using .Mutations, .Recombinations, .Selections, .Objectives
using Agents, Random
using InteractiveDynamics, GLMakie

# -----------------------------------------------------------------------------------------
# Module types:

"""
	BasicGAAlleles

Enum for Alleles in Basic GA, Possible values are 1 and 0
"""
@enum BasicGAAlleles zero one

"""
	BasicGAAgent

The basic agent in the simulation
"""
@agent BasicGAAgent GridAgent{2} begin
	genome::Vector{BasicGAAlleles}
end

# -----------------------------------------------------------------------------------------
# Module methods:

"""
	initialize

Initializes the simulation.
"""
function initialize(; N=100, M=1, mut::Mutation=DummyMutation(), obj::Objective=dummyObjective(),
	recomb::Recombination=DummyRecombination(), sel::Selection=DummySelection(), seed=42, genome_length=128)

	Random.seed!(seed);
	space = GridSpace((M, M); periodic=false)
	properties = Dict(
		:mutations => mut,
		:recombinations => recomb,
		:selection => sel,
		:objective => obj
	)

	model = ABM(
		BasicGAAgent, space;
		properties
	)
	for n in 1:N
        agent = BasicGAAgent(n, (1, 1), BasicGAAlleles.(rand([0,1], genome_length)))
        # agent = BasicGAAgent(n, (1, 1), rand(Bool, genome_lenght))
		add_agent!(agent, model)
    end
	return model
end

"""
	model_step!

Modifies the simulation every step. Here it calculates the fitness matrix and then performs
the selection, recombination and mutation depending on the properties of the ABM.
"""
function model_step!(model)
	population = map(agent -> Int8.(agent.genome), allagents(model))
	nAlleles = length(random_agent(model).genome)
	# get fitness matrix:
	# popFitness = map(genome -> fitness(genome), population)
	popFitness = map(genome -> max(sum(genome), 100), population)
	# Selection:
	# selectionWinners = performSelection(model.selection, popFitness)
	performSelection(model.selection)
	# Recombination:
	# popₙ = recombine(model.recombination, selectionWinners)
	# Mutation:
	# popₙ = mutate(model.mutation, popₙ)
	# TODO: remove mock code that just makes all Alleles to ones and replace with actual mutation
	for agent ∈ allagents(model)
		agent.genome = fill(BasicGAAlleles(1), nAlleles)
	end
	return 
end


"""
	simulate

Creates and runs the simulation.
"""
function simulate()
	model = initialize()
	data, _ = run!(model, dummystep, model_step!, 5; adata=[a -> sum(Int.(a.genome))])
	return data
end