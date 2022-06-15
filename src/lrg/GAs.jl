module GAs
# =========================================================================================
### Define different simulations using the agent based model from Agents.jl
# =========================================================================================

# Export function to start a genetic algorithm simulation
export simulate

# Import external modules
using Statistics
using Agents
using Random
using Plots
using DataFrames

# Include core structures
include("core/algorithms.jl")
include("core/alleles.jl")				
include("core/agents.jl")				# Depends on core/alleles.jl

# Include util functions and modules
include("utils/Casinos.jl")
include("utils/transpose.jl")

# Include evolutionary mechanisms
include("mechanisms/plasticity.jl")		# Depends on core/alleles.jl
include("mechanisms/fitness.jl")		# Depends on mechanisms/plasticity.jl
include("mechanisms/encounter.jl")
include("mechanisms/mutate.jl")
include("mechanisms/recombine.jl")

# Import submodules
using .Casinos

"""
	<genetic-algorithm>_step!

Different model_step! implementations for every genetic-algorithm
"""
function basic_step!(model)
	nAgents = nagents(model)
	population = map(agent -> Int8.(agent.genome), allagents(model))
	population = reduce(vcat, transpose.(population))
	pop = BasicGAAlleles.(population)
	# get fitness matrix:
	popFitness, evaluations = fitness(Bool.(pop))
	# Selection:
	selectionWinners = encounter(popFitness)
	# Recombination:
	popₙ = recombine(pop, selectionWinners)
	# Mutation:
	mutate!(popₙ, model.mu, model.casino)

	# delete old agents and "import" new genome into ABM
	genocide!(model)
	for i ∈ 1:nAgents
		agent = BasicGAAgent(i, (1, 1), popₙ[i,:], evaluations[i])
		add_agent!(agent, model)
	end

	model.evaluatedZeros = sum(evaluations .== 0)

	return 
end

function exploratory_step!(model)
	nAgents = nagents(model)
	population = map(agent -> Int8.(agent.genome), allagents(model))
	population = reduce(vcat, transpose.(population))
	pop = ExploratoryGAAlleles.(population)

	# get fitness matrix:
	# ToDo add n plasticityTrials to properties
	popFitness, evaluations = fitness(pop, 10, model.casino) 

	# Selection:
	selectionWinners = encounter(popFitness)

	# Recombination:
	popₙ = recombine(pop, selectionWinners)
	
	# Mutation:
	mutate!(popₙ, model.mu, model.casino)
	
	# Delete old agents and "import" new genome into ABM
	genocide!(model)
	for i ∈ 1:nAgents
		agent = ExploratoryGAAgent(i, (1, 1), popₙ[i,:], evaluations[i])
		add_agent!(agent, model)
	end

	model.evaluatedZeros = sum(evaluations .== 0)

	return 
end

# -----------------------------------------------------------------------------------------

"""
	initialize

Initialization methods for every genetic algorithm.
"""
function initialize(basicGA::BasicGA; seed=42)
	Random.seed!(seed);
	space = GridSpace((basicGA.M, basicGA.M); periodic=false)
	
	properties = Dict([
		:mu => 0.0001,
		:casino => Casino(basicGA.nIndividuals + 1, basicGA.genomeLength + 1),
		:evaluatedZeros => 0
	])

	model = ABM(
		BasicGAAgent, space;
		properties
	)
	for n in 1:basicGA.nIndividuals
        agent = BasicGAAgent(
			n, (1, 1), rand(instances(BasicGAAlleles), basicGA.genomeLength), 0
		)
		add_agent!(agent, model)
    end

	return model
end

function initialize(exploratoryGA::ExploratoryGA; seed=42)
	Random.seed!(seed);
	space = GridSpace((exploratoryGA.M, exploratoryGA.M); periodic=false)

	properties = Dict([
		:mu => 0.0001,
		:casino => Casino(exploratoryGA.nIndividuals+1, exploratoryGA.genomeLength+1),
		:evaluatedZeros => 0
	])

	model = ABM(
		ExploratoryGAAgent, space;
		properties
	)
	for n in 1:exploratoryGA.nIndividuals
        agent = ExploratoryGAAgent(
			n, (1, 1), rand(instances(ExploratoryGAAlleles), exploratoryGA.genomeLength), 0
		)
		add_agent!(agent, model)
    end

	return model
end

# -----------------------------------------------------------------------------------------

"""
	simulate

Simulation methods for every genetic algorithm.
"""
function simulate(basicGA::BasicGA, nSteps=100; seed=42)
	model = initialize(basicGA; seed)
	agentDF, modelDF = run!(model, dummystep, basic_step!, nSteps; 
		adata=[
			#:genome,
			:mepiCache,
			(a -> min(basicGA.genomeLength - sum(Int.(a.genome)),
					  sum(Int.(a.genome))))
		],
		mdata=[
			:evaluatedZeros
		]
	)
	DataFrames.rename!(agentDF, 3 => :mepi, 4 => :genomeDistance)
	# plotlyjs() # for prettier (and interactive) plots
	pltDF = unstack(agentDF, :step, :id, :mepi)
	plt = Plots.plot(
		Matrix(pltDF[2:end, 2:basicGA.nIndividuals + 1]), # Exclude initialization-row
		legend = false, 
		title = repr(seed)
	)
	return (agentDF, modelDF, pltDF, plt)
end

function simulate(exploratoryGA::ExploratoryGA, nSteps=100; seed=42)
	model = initialize(exploratoryGA; seed)
	agentDF, modelDF = run!(model, dummystep, exploratory_step!, nSteps; 
		adata=[
			#:genome,
			:mepiCache,
			(a -> min(exploratoryGA.genomeLength - sum(Int.(a.genome)),
					  sum(Int.(a.genome))))
		],
		mdata=[
			:evaluatedZeros
		]
	)
	DataFrames.rename!(agentDF, 3 => :mepi, 4 => :genomeDistance)
	# plotlyjs() # for prettier (and interactive) plots
	pltDF = unstack(agentDF, :step, :id, :mepi)
	plt = Plots.plot(
		Matrix(pltDF[2:end, 2:exploratoryGA.nIndividuals + 1]),  # Exclude initialization-row
		legend = false, 
		title = repr(seed)
	)
	return (agentDF, modelDF, pltDF, plt)
end

end # module GAs