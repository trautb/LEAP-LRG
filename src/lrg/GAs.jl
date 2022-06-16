module GAs
# =========================================================================================
### Define different simulations using the agent based model from Agents.jl
# =========================================================================================

# Export function to start a genetic algorithm simulation
export simulate, compareGAs

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
	# Get the populations' genpool:
	genpool = reduce(vcat, map(agent -> transpose(agent.genome), allagents(model)))

	# Evaluate objective function and fitness:
	popFitness, evaluations = fitness(Bool.(genpool))

	# Perform selection:
	selectionWinners = encounter(popFitness)

	# Perform recombination:
	nextGenpool = recombine(genpool, selectionWinners)

	# Perform mutation:
	mutate!(nextGenpool, model.mu, model.casino)

	# Delete old agents and "import" new genome into ABM:
	nAgents = nagents(model)
	genocide!(model)
	for i ∈ 1:nAgents
		agent = BasicGAAgent(i, (1, 1), nextGenpool[i,:], evaluations[i])
		add_agent!(agent, model)
	end

	# Save best and worst evaluation for later analysis:
	model.objectiveInterval = [minimum(evaluations), maximum(evaluations)]

	# Check for possile calculation errors:
	model.incorrectEvaluations = sum(evaluations .< size(genpool, 2))

	return 
end

function exploratory_step!(model)
	# Get the populations' genpool:
	genpool = reduce(vcat, map(agent -> transpose(agent.genome), allagents(model)))

	# Evaluate objective function and fitness:
	popFitness, evaluations = fitness(genpool, model.nTrials, model.speedAdvantage, model.casino) 

	# Perform selection:
	selectionWinners = encounter(popFitness)

	# Perform recombination:
	nextGenpool = recombine(genpool, selectionWinners)
	
	# Perform mutation:
	mutate!(nextGenpool, model.mu, model.casino)
	
	# Delete old agents and "import" new genome into ABM:
	nAgents = nagents(model)
	genocide!(model)
	for i ∈ 1:nAgents
		agent = ExploratoryGAAgent(i, (1, 1), nextGenpool[i,:], evaluations[i])
		add_agent!(agent, model)
	end

	# Save best and worst evaluation for later analysis:
	model.objectiveInterval = [minimum(evaluations), maximum(evaluations)]

	# Check for possile calculation errors:
	model.incorrectEvaluations = sum(evaluations .< size(genpool, 2))

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
		# Properties for algorithm execution:
		:mu => basicGA.mu,
		:casino => Casino(basicGA.nIndividuals + 1, basicGA.nGenes + 1),
		# Properties for later analysis:
		:objectiveInterval => [0, 0],
		:incorrectEvaluations => 0
	])

	model = ABM(BasicGAAgent{BasicGAAlleles}, space; properties)

	for n in 1:basicGA.nIndividuals
        agent = BasicGAAgent(
			n, (1, 1), rand(instances(BasicGAAlleles), basicGA.nGenes), 0
		)
		add_agent!(agent, model)
    end

	return model
end

function initialize(exploratoryGA::ExploratoryGA; seed=42)
	Random.seed!(seed);
	space = GridSpace((exploratoryGA.M, exploratoryGA.M); periodic=false)

	properties = Dict([
		# Properties for algorithm execution:
		:mu => exploratoryGA.mu,
		:casino => Casino(exploratoryGA.nIndividuals+1, exploratoryGA.nGenes+1),
		:nTrials => exploratoryGA.nTrials,
		:speedAdvantage => exploratoryGA.speedAdvantage,
		# Properties for later analysis:
		:objectiveInterval => [0, 0],
		:incorrectEvaluations => 0
	])

	model = ABM(ExploratoryGAAgent{ExploratoryGAAlleles}, space; properties)

	for n in 1:exploratoryGA.nIndividuals
        agent = ExploratoryGAAgent(
			n, (1, 1), rand(instances(ExploratoryGAAlleles), exploratoryGA.nGenes), 0
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
			:currentScore,
			(a -> min(basicGA.nGenes - sum(Int.(a.genome)),
					  sum(Int.(a.genome))))
		],
		mdata=[
			:objectiveInterval,
			:incorrectEvaluations
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
			:currentScore,
			(a -> min(exploratoryGA.nGenes - sum(Int.(a.genome)),
					  sum(Int.(a.genome))))
		],
		mdata=[
			:objectiveInterval,
			:incorrectEvaluations
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

function compareGAs(geneticAlgorithms::Vector{GeneticAlgorithm}, nSteps=100; seed=42)
	
end

end # module GAs