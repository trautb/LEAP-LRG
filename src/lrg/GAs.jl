module GAs
# =========================================================================================
### Define different simulations using the agent based model from Agents.jl
# =========================================================================================

# Export functions to start a genetic algorithm simulation
export simulate, compare, compareLevelplain

# Import external modules
using Statistics
using Agents
using Random
using Plots
using DataFrames
using Dates
using TrackingTimers

# Include core structures
include("core/algorithms.jl")
include("core/alleles.jl")				
include("core/agents.jl")				# Depends on core/alleles.jl

# Include util functions and modules
include("utils/Casinos.jl")
include("utils/transpose.jl")
include("utils/results.jl")				# Depends on core/algorithms.jl
include("utils/plotting.jl")			# Depends on utils/results.jl
include("utils/save.jl")				# Depends on utils/results.jl

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
	popFitness, evaluations = fitness(Bool.(genpool), model.useHintonNowlan)

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
		model[agentIDs[i]].score = evaluations[i]
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
	popFitness, evaluations = fitness(genpool, model.nTrials, model.speedAdvantage, model.casino, model.useHintonNowlan) 

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
		model[agentIDs[i]].score = evaluations[i]
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
		:useHintonNowlan => basicGA.useHintonNowlan,
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
		:useHintonNowlan => exploratoryGA.useHintonNowlan,
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
	excludeStepZero!(dataframe::DataFrame)

Excludes all rows from the given dataframe that match the condition :step == 0.
"""
function excludeStepZero!(dataframe::DataFrame)
	filter!(:step => step -> step != 0, dataframe)
end

# -----------------------------------------------------------------------------------------

"""
	simulate

Simulation methods for every genetic algorithm.
"""
function simulate(basicGA::BasicGA, nSteps=100; stepRem=1, seed=42)
	if seed != nothing
		@info string("setting seed to ", seed)
		Random.seed!(seed);
	end
	
	model = initialize(basicGA)

	agentDF, modelDF = run!(model, dummystep, basic_step!, nSteps; 
		adata=[
			:score,
			(a -> min(basicGA.nGenes - sum(Int.(a.genome)),
					  sum(Int.(a.genome))))
		],
		mdata=[
			:minimum,
			:maximum,
			:mean,
			:incorrectEvaluations
		],
		when=(model, step) -> rem(step, stepRem) == 0
	)
	DataFrames.rename!(agentDF, 2 => :organism, 4 => :genomeDistance)
	
	# Postprocessing of data:
	excludeStepZero!(agentDF)
	insertcols!(agentDF, (:modifications => agentDF[:, :step]))
	excludeStepZero!(modelDF)
	insertcols!(modelDF, (:modifications => modelDF[:, :step]))

	return GASimulation(basicGA, agentDF)
end

function simulate(exploratoryGA::ExploratoryGA, nSteps=100; seed=42)
	if seed != nothing
		@info string("setting seed to ", seed)
		Random.seed!(seed);
	end

	model = initialize(exploratoryGA)

	agentDF, modelDF = run!(model, dummystep, exploratory_step!, nSteps; 
		adata=[
			:score,
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
	DataFrames.rename!(agentDF, 2 => :organism, 4 => :genomeDistance)

	# Postprocessing of data:
	excludeStepZero!(agentDF)
	insertcols!(agentDF, (:modifications => agentDF[:, :step] .* (exploratoryGA.nTrials + 1)))
	excludeStepZero!(modelDF)
	insertcols!(modelDF, (:modifications => modelDF[:, :step] .* (exploratoryGA.nTrials + 1)))

	return GASimulation(exploratoryGA, agentDF)
end

"""
	compare(geneticAlgorithms::Vector{T}, nSteps=100; seed=42) where {T <: GeneticAlgorithm}

Compare the simulations for a given array of genetic algorithms.
"""
function compare(
	basicGAs::Vector{BasicGA},
	exploratoryGA::ExploratoryGA;
	nModifications=101_000, 								# Total genome modifications
	seed=42
)
	# Initialize necessary variables:
	nBasicGAs = length(basicGAs)
	nGAs = nBasicGAs + 1
	simulationData = Vector{GASimulation}(undef, nGAs)
	modsPerStep = exploratoryGA.nTrials + 1

	# Adjust nModifications if necessary: 
	if rem(nModifications, modsPerStep) != 0
		modIncrease = modsPerStep * (div(nModifications, modsPerStep) + 1) - nModifications
		print(string("WARNING: nModifications/exploratoryGA.nTrials did not result in an integer! Increasing nModifications by ", modIncrease, " ..."))
		nModifications = nModifications + modIncrease
	end
	# Calculate necessary steps for ExploratoryGA
	exploratorySteps = div(nModifications, modsPerStep)

	# Run the simulations:
	simulationData[1:nBasicGAs]=simulate.(basicGAs, nModifications; stepRem=modsPerStep, seed=seed)
	simulationData[nGAs] = simulate(exploratoryGA, exploratorySteps; seed=seed)

	# Return a comparison of the given genetic algorithms:
	return GAComparison(simulationData; seed=seed)
end

function compare(
	basicGAs::Vector{BasicGA},
	exploratoryGAs::Vector{ExploratoryGA};
	nModifications=100_000, 								# Total genome modifications
	seed=42
)
	return [compare(
		basicGAs, 
		exploratoryGA; 
		nModifications=nModifications, 
		seed=seed
	) for exploratoryGA in exploratoryGAs]
end

"""
	compare(
		dirname::String,
		basicGAs::Vector{BasicGA},
		exploratoryGAs::Vector{ExploratoryGA},
		nModifications=100_000;
		saveSpecificPlots=true,
		seed=42
	)	

Compare the simulations for a given array of genetic algorithms and saves the plots to directory 
dirname.
"""
function compare(
	dirname::String,
	basicGAs::Vector{BasicGA},
	exploratoryGAs::Vector{ExploratoryGA};
	nModifications=100_000,
	saveSpecificPlots=true,
	seed=42
)
	isDirnameValid = isdir(dirname)

	if isDirnameValid
		subdir = Dates.format(Dates.now(), dateformat"yyyy_mm_dd__HH_MM")
	end

	comparison = compare(basicGAs, exploratoryGAs; nModifications=nModifications, seed=seed)

	if isDirnameValid
		pwdBackup = pwd()
		cd(dirname)
		mkpath(subdir)
		cd(subdir)

		savePlots.(comparison; withSimulationPlots=saveSpecificPlots)

		cd(pwdBackup)
	else
		print("Given dirname is no valid directory! Skipped saving figures ...")
	end

	return comparison
end

function compareLevelplain(geneticAlgorithms::Vector{T}, nSteps=100; seed=42) where {T <: GeneticAlgorithm}
	
	runtimes = TrackingTimer()
	# Initialize necessary variables:
	nGAs = length(geneticAlgorithms)
	simulationData = Vector{GASimulation}(undef, nGAs)

	evalsPerStep = 
		map(function(algo) 
			if typeof(algo) == BasicGA
				return 1
			elseif typeof(algo) == ExploratoryGA
				return algo.nTrials
			else
				throw(TypeError())
			end
		end
	, geneticAlgorithms)

	maxEvals, _ = findmax(evalsPerStep)

	# Perform similar simulations for every given genetic algorithm:
	for i in 1:nGAs
		currentAlgorithm = geneticAlgorithms[i]
		factor, remainder = divrem(maxEvals, evalsPerStep[i])
		if !(remainder == 0) @warn "Algorithms not exactly comparable" end

		@info string("Running ", currentAlgorithm, " with ", nSteps*factor, " steps.")
		TrackingTimers.@timeit runtimes string(i, ": ",currentAlgorithm) simulationData[i] = simulate(currentAlgorithm, nSteps*factor; seed=seed)
	end
	
	# Return a comparison of the given genetic algorithms:
	return GAComparison(simulationData,DataFrame(runtimes))
end

function compareLevelplain(
	dirname::String,
	geneticAlgorithms::Vector{T}, 
	nSteps=100;
	saveSpecificPlots=true,
	seed=42
) where {T <: GeneticAlgorithm}
	isDirnameValid = isdir(dirname)

	if isDirnameValid
		subdir = Dates.format(Dates.now(), dateformat"yyyy_mm_dd__HH_MM")
	end

	comparison = compareLevelplain(geneticAlgorithms, nSteps; seed=seed)

	if isDirnameValid
		pwdBackup = pwd()
		cd(dirname)
		mkpath(subdir)
		cd(subdir)

		savePlots(comparison)
		
		cd(pwdBackup)
	else
		print("Given dirname is no valid directory! Skipped saving figures ...")
	end

	return comparison
end

end # module GAs