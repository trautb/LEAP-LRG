module GAs
# =========================================================================================
### Define different simulations using the agent based model from Agents.jl
# =========================================================================================

# Export function to start a genetic algorithm simulation
export simulate, compare

# Import external modules
using Statistics
using Agents
using Random
using Plots
using DataFrames
import Dates

# Include core structures
include("core/algorithms.jl")
include("core/alleles.jl")				
include("core/agents.jl")				# Depends on core/alleles.jl

# Include util functions and modules
include("utils/Casinos.jl")
include("utils/transpose.jl")
include("utils/results.jl")				# Depends on core/algorithms.jl
include("utils/plotting.jl")			# Depends on utils/results.jl

# Include evolutionary mechanisms
include("mechanisms/plasticity.jl")		# Depends on core/alleles.jl
include("mechanisms/fitness.jl")		# Depends on mechanisms/plasticity.jl
include("mechanisms/encounter.jl")
include("mechanisms/mutate.jl")
include("mechanisms/recombine.jl")

# Include 

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

	# "import" new genome into ABM:
	agentIDs = collect(allids(model))
	for i ∈ 1:nagents(model)
		model[agentIDs[i]].genome = nextGenpool[i,:]
		model[agentIDs[i]].currentScore = evaluations[i]
	end

	# Save best, worst and mean of evaluations for later analysis:
	model.minimum = minimum(evaluations)
	model.maximum = maximum(evaluations)
	model.mean = mean(evaluations)

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
	
	# "import" new genome into ABM:
	agentIDs = collect(allids(model))
	for i ∈ 1:nagents(model)
		model[agentIDs[i]].genome = nextGenpool[i,:]
		model[agentIDs[i]].currentScore = evaluations[i]
	end

	# Save best, worst and mean of evaluations for later analysis:
	model.minimum = minimum(evaluations)
	model.maximum = maximum(evaluations)
	model.mean = mean(evaluations)

	# Check for possile calculation errors:
	model.incorrectEvaluations = sum(evaluations .< size(genpool, 2))

	return 
end

# -----------------------------------------------------------------------------------------

"""
	initialize

Initialization methods for every genetic algorithm.
"""
function initialize(basicGA::BasicGA)
	space = GridSpace((basicGA.M, basicGA.M); periodic=false)
	
	properties = Dict([
		# Properties for algorithm execution:
		:mu => basicGA.mu,
		:casino => Casino(basicGA.nIndividuals + 1, basicGA.nGenes + 1),
		# Properties for later analysis:
		:minimum => 0,
		:maximum => 0,
		:mean => 0.0,
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

function initialize(exploratoryGA::ExploratoryGA)
	space = GridSpace((exploratoryGA.M, exploratoryGA.M); periodic=false)

	properties = Dict([
		# Properties for algorithm execution:
		:mu => exploratoryGA.mu,
		:casino => Casino(exploratoryGA.nIndividuals + 1, exploratoryGA.nGenes + 1),
		:nTrials => exploratoryGA.nTrials,
		:speedAdvantage => exploratoryGA.speedAdvantage,
		# Properties for later analysis:
		:minimum => 0,
		:maximum => 0,
		:mean => 0.0, 
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
	Random.seed!(seed);
	model = initialize(basicGA)

	agentDF, modelDF = run!(model, dummystep, basic_step!, nSteps; 
		adata=[
			# :genome,
			:currentScore,
			(a -> min(basicGA.nGenes - sum(Int.(a.genome)),
					  sum(Int.(a.genome))))
		],
		mdata=[
			:minimum,
			:maximum,
			:mean,
			:incorrectEvaluations
		]
	)
	DataFrames.rename!(agentDF, 3 => :mepi, 4 => :genomeDistance)

	pScoreOverTime = scoreOverTime(agentDF, basicGA.nIndividuals + 1; seed=seed)
	pScoreSpanOverTime = scoreSpanOverTime(modelDF; seed=seed)
	plots = [pScoreOverTime, pScoreSpanOverTime]

	return GASimulation(basicGA, agentDF, modelDF, plots)
end

function simulate(exploratoryGA::ExploratoryGA, nSteps=100; seed=42)
	Random.seed!(seed);
	model = initialize(exploratoryGA)

	agentDF, modelDF = run!(model, dummystep, exploratory_step!, nSteps; 
		adata=[
			# :genome,
			:currentScore,
			(a -> min(exploratoryGA.nGenes - sum(Int.(a.genome)),
					  sum(Int.(a.genome))))
		],
		mdata=[
			:minimum,
			:maximum,
			:mean,
			:incorrectEvaluations
		]
	)
	DataFrames.rename!(agentDF, 3 => :mepi, 4 => :genomeDistance)

	pScoreOverTime = scoreOverTime(agentDF, exploratoryGA.nIndividuals + 1; seed=seed)
	pScoreSpanOverTime = scoreSpanOverTime(modelDF; seed=seed)
	plots = [pScoreOverTime, pScoreSpanOverTime]

	return GASimulation(exploratoryGA, agentDF, modelDF, plots)
end

"""
	compare(geneticAlgorithms::Vector{T}, nSteps=100; seed=42) where {T <: GeneticAlgorithm}

Compare the simulations for a given array of genetic algorithms.
"""
function compare(geneticAlgorithms::Vector{T}, nSteps=100; seed=42) where {T <: GeneticAlgorithm}
	# Initialize necessary variables:
	nGAs = length(geneticAlgorithms)
	simulationData = Vector{GASimulation}(undef, nGAs)

	# Perform similar simulations for every given genetic algorithm:
	for i in 1:nGAs
		simulationData[i] = simulate(geneticAlgorithms[i], nSteps; seed=seed)
	end

	# Return a comparison of the given genetic algorithms:
	return GAComparison(simulationData; seed=seed)
end

"""
	compare(
		dirname::String,
		geneticAlgorithms::Vector{T}, 
		nSteps=100;
		seed=42
	) where {T <: GeneticAlgorithm}

Compare the simulations for a given array of genetic algorithms and saves the plots to directory 
dirname.
"""
function compare(
	dirname::String,
	geneticAlgorithms::Vector{T}, 
	nSteps=100;
	saveSpecificPlots=true,
	seed=42
) where {T <: GeneticAlgorithm}
	comparison = compare(geneticAlgorithms, nSteps; seed=seed)

	if isdir(dirname)
		pwdBackup = pwd()
		cd(dirname)

		format = Dates.DateFormat("yyyy_mm_dd__HH_MM_SS")
		timestamp = Dates.format(Dates.now(), format)
		mkpath(timestamp)
		cd(timestamp)

		timestamp = string("_", timestamp, "_")
		Plots.png(comparison.minimumPlot, string("comparison", timestamp, "minimumPlot"))
		Plots.pdf(comparison.minimumPlot, string("comparison", timestamp, "minimumPlot"))
		
		if saveSpecificPlots
			for i in 1:length(comparison.simulations)
				simulation = comparison.simulations[i]
				for j in 1:length(simulation.gaSpecificPlots)
					plt = simulation.gaSpecificPlots[j]
					Plots.png(plt, string("simulation", timestamp, "ga_", i, "_plot_", j))
					Plots.pdf(plt, string("simulation", timestamp, "ga_", i, "_plot_", j))
				end
			end
		end

		cd(pwdBackup)
	else
		print("Given dirname is no valid directory! Skipped saving figures ...")
	end

	return comparison
end

end # module GAs