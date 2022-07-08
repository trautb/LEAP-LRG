module GAs
# =========================================================================================
### Define different simulations using the agent based model from Agents.jl
# =========================================================================================

# Export functions to start a genetic algorithm simulation
export simulate, compare, compare, demo

# Import external modules
using Statistics
using Agents
using Random
using Plots
using DataFrames
using Dates
using CSV
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
include("utils/save.jl")				# Depends on utils/plotting.jl
include("utils/display.jl")				# Depends on utils/plotting.jl and utils/save.jl

# Include evolutionary mechanisms
include("mechanisms/plasticity.jl")		# Depends on core/alleles.jl
include("mechanisms/fitness.jl")		# Depends on mechanisms/plasticity.jl
include("mechanisms/encounter.jl")
include("mechanisms/mutate.jl")
include("mechanisms/recombine.jl")

# Import submodules
using .Casinos

"""
	basic_step!(model)

Implements one single step of a BasicGA simulation.

**Arguments:**
- **model:** The current agent based model. (from Agents.jl)

**Return**
- Nothing
"""
function basic_step!(model)
	# Get the populations' genePool:
	genePool = reduce(vcat, map(agent -> transpose(agent.genome), allagents(model)))

	# Evaluate objective function and fitness:
	popFitness, evaluations = fitness(Bool.(genePool), model.useHaystack)

	# Perform selection:
	selectionWinners = encounter(popFitness)

	# Perform recombination:
	nextGenePool = recombine(genePool, selectionWinners)

	# Perform mutation:
	mutate!(nextGenePool, model.mu, model.casino)

	# "import" new genome into the ABM:
	agentIDs = collect(allids(model))
	for i ∈ 1:nagents(model)
		model[agentIDs[i]].genome = nextGenePool[i,:]
		model[agentIDs[i]].score = evaluations[i]
	end
	
	return	# Nothing 
end

# -------------------------------------------------------------------------------------------------
"""
	exploratory_step!(model)

Implements one single step of a ExploratoryGA simulation.

**Arguments:**
- **model:** The current agent based model. (from Agents.jl)

**Return**
- Nothing
"""
function exploratory_step!(model)
	# Get the populations' genePool:
	genePool = reduce(vcat, map(agent -> transpose(agent.genome), allagents(model)))

	# Evaluate objective function and fitness:
	popFitness, evaluations = fitness(genePool, model.nTrials, model.casino, model.useHaystack) 

	# Perform selection:
	selectionWinners = encounter(popFitness)

	# Perform recombination:
	nextGenePool = recombine(genePool, selectionWinners)
	
	# Perform mutation:
	mutate!(nextGenePool, model.mu, model.casino)
	
	# "import" new genome into the ABM:
	agentIDs = collect(allids(model))
	for i ∈ 1:nagents(model)
		model[agentIDs[i]].genome = nextGenePool[i,:]
		model[agentIDs[i]].score = evaluations[i]
	end

	return 		# Nothing 
end

# -----------------------------------------------------------------------------------------
"""
	initialize(basicGA::BasicGA)

Initializes an agent based model (see Agents.jl documentation) to run a BasicGA simulation using
the parameters provided by the BasicGA struct.

**Arguments:**
- **basicGA:** The genetic algorithm to use for the simulation.

**Return:**
- The agent based model to use for the simulation.
"""
function initialize(basicGA::BasicGA)
	# Define a space for the model (mandatory parameter, but not used in BasicGA simulations):
	space = GridSpace((basicGA.M, basicGA.M); periodic=false)
	
	# Define model properties using the parameters of the GA instance:
	properties = Dict([
		# Properties for algorithm execution:
		:mu => basicGA.mu,
		:casino => Casino(basicGA.nIndividuals + 1, basicGA.nGenes + 1),
		:useHaystack => basicGA.useHaystack,
	])

	# Initialize the agent based model with properties and fill it with agents:
	model = ABM(BasicGAAgent{BasicGAAlleles}, space; properties)
	for n in 1:basicGA.nIndividuals
        agent = BasicGAAgent(
			n, (1, 1), rand(instances(BasicGAAlleles), basicGA.nGenes), 0
		)
		add_agent!(agent, model)
    end

	return model
end

"""
	initialize(exploratoryGA::ExploratoryGA)

Initializes an agent based model (see Agents.jl documentation) to run an ExploratoryGA simulation 
using the parameters provided by the ExploratoryGA struct.

**Arguments:**
- **exploratoryGA:** The genetic algorithm to use for the simulation.

**Return:**
- The agent based model to use for the simulation.
"""
function initialize(exploratoryGA::ExploratoryGA)
	# Define a space for the model (mandatory parameter, but not used in ExploratoryGA simulations):
	space = GridSpace((exploratoryGA.M, exploratoryGA.M); periodic=false)

	# Define model properties using the parameters of the GA instance:
	properties = Dict([
		# Properties for algorithm execution:
		:mu => exploratoryGA.mu,
		:casino => Casino(exploratoryGA.nIndividuals + 1, exploratoryGA.nGenes + 1),
		:useHaystack => exploratoryGA.useHaystack,
		:nTrials => exploratoryGA.nTrials,
	])

	# Initialize the agent based model with properties and fill it with agents:
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

**Arguments:**
- **dataframe:** The dataframe, that gets modified.

**Return:**
- The modified (original) dataframe.
"""
function excludeStepZero!(dataframe::DataFrame)
	filter!(:step => step -> step != 0, dataframe)

	return dataframe
end

# -----------------------------------------------------------------------------------------

"""
	simulate(basicGA::BasicGA, nSteps=100; seed=nothing)

Run a simulation with `nSteps` steps using the given basic genetic algorithm.

The function initializes an agent based model (see Agents.jl documentation for details) and runs it
using the `basic_step!` function as model step. The model collects the total number of 0's and 1's 
in the genome of the individuals as well as the current score and the number of genome modifications
at every step and returns the data as DataFrame.

**Arguments:**
- **basicGA:** The BasicGA instance, that provides the necessary parameters for the simulation.
- **nSteps:** The number of steps, that the simulation should run. (Default: 100)
- **seed:** The seed to use for the simulation. If it's set no `nothing`, no seed is used. (Default: nothing)

**Return:**
- A `GASimulation` instance, containing the simulation results.
"""
function simulate(basicGA::BasicGA, nSteps=100; seed=nothing)
	if seed !== nothing
		Random.seed!(seed);
	end
	
	# Initialize and run the agent based model with parameters from basicGA:
	model = initialize(basicGA)
	simulationDF, _ = run!(model, dummystep, basic_step!, nSteps; 
		adata=[	
			:score,											# Track the score (objective)
			(a -> sum(a.genome .== bZero)),					# Track number of 0's
			(a -> sum(a.genome .== bOne))					# Track number of 1's
		]
	)

	# Process the simulation data before returning it:
	DataFrames.rename!(										# Give columns meaningful names
		simulationDF, 
		2 => :organism, 4 => :zeros, 5 => :ones 	
	)
	excludeStepZero!(simulationDF)								# Exclude data with no information
	insertcols!(											# Insert number of genome modifications
		simulationDF, 
		(:modifications => simulationDF[:, :step])	
	)

	return GASimulation(basicGA, simulationDF)
end

"""
	simulate(exploratoryGA::ExploratoryGA, nSteps=100; seed=nothing)

Run a simulation with `nSteps` steps using the given exploratory genetic algorithm.

The function initializes an agent based model (see Agents.jl documentation for details) and runs it
using the `exploratory_step!` function as model step. 
The model collects the total number of 0's, 1's and ?'s in the genome of the individuals as well as the current score 
and the number of genome modifications at every step and returns the data as DataFrame.

**Arguments:**
- **exploratoryGA:** The BasicGA instance, that provides the necessary parameters for the simulation.
- **nSteps:** The number of steps, that the simulation should run. (Default: 100)
- **seed:** The seed to use for the simulation. If it's set no `nothing`, no seed is used. (Default: nothing)

**Return:**
- A `GASimulation` instance, containing the simulation results.
"""
function simulate(exploratoryGA::ExploratoryGA, nSteps=100; seed=nothing)
	if seed !== nothing
		Random.seed!(seed);
	end

	# Initialize and run the agent based model with parameters from exploratoryGA:
	model = initialize(exploratoryGA)
	simulationDF, _ = run!(model, dummystep, exploratory_step!, nSteps; 
		adata=[
			:score,								# Track the score (objective)
			(a -> sum(a.genome .== eZero)),		# Track number of 0's
			(a -> sum(a.genome .== eOne)),		# Track number of 1's
			(a -> sum(a.genome .== qMark))		# Track number of ?'s
		]
	)
	
	# Process the simulation data before returning it:
	DataFrames.rename!(							# Give columns meaningful names 					
		simulationDF, 
		2 => :organism, 4 => :zeros, 
		5 => :ones, 6 => :qMarks			
	)
	excludeStepZero!(simulationDF)				# Exclude data with no information
	insertcols!(								# Insert number of genome modifications
		simulationDF, 
		(:modifications => simulationDF[:, :step] .* (exploratoryGA.nTrials + 1))
	)

	return GASimulation(exploratoryGA, simulationDF)
end

# -------------------------------------------------------------------------------------------------
"""
	compare(geneticAlgorithms::Vector{T}, nSteps=100; multiThreading::Bool=true, seed=nothing)

Run one simulation for every genetic algorithm given by the vector `geneticAlgorithms`. 
	
The function checks beforehand, how often the objective function would get evaluated for each 
individual per step, and tries to standardize the number of objective function evaluations across 
all simulations using different numbers of steps. The simulation, that would evaluate the objective 
function most often, is run for `nSteps` steps, while the number of steps for all other simulations 
gets adjusted accordingly.

If `multiThreading` is set to `true`, the function runs every simulation in a single thread, if 
possible. Julia must therefore be started with more than one thread.

**Arguments:**
- **geneticAlgorithms:** The different parameter initialisations, for which simulations should be 
						 run
- **nSteps:** The minimum number of steps a simulation will run. (see description above)
- **multiThreading:** Specifies, if multithreading should be used. (Default: true)
- **seed:** The seed to use for the simulations. If it's set no `nothing`, no seed is used. 
(Default: nothing)

**Return:**
- A GAComparison instance containing the simulation results as well as tracked runtimes of every 
  run simulation.
"""
function compare(geneticAlgorithms::Vector{T}, nSteps=100; multiThreading::Bool=true, seed=nothing) where {T <: GeneticAlgorithm}
	
	# Initialize runtime tracker, number of simulations and container for simulation results:
	runtimes = TrackingTimer()
	nGAs = length(geneticAlgorithms)
	simulationData = Vector{GASimulation}(undef, nGAs)

	# Calculate the objective function evaluations per step for each genetic algorithm:
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

	# Only attempt to use multithreading, if it is specified and there is more than one thread:
	if multiThreading && Threads.nthreads() > 1
		simDataLock = ReentrantLock()					# Initialize lock for multithreading

		# Perform similar simulations for every given genetic algorithm:
		Threads.@threads for i in 1:nGAs
			# Determine the adjustment for the number of steps of the next simulation:
			factor, remainder = divrem(maxEvals, evalsPerStep[i])
			if !(remainder == 0) @warn "Genome modifications not exactly comparable" end
			
			currentAlgorithm = geneticAlgorithms[i]		# Get the next algorithm to simulate

			# Print an information to the console, that the simulation has started:
			@info string(
				"[Thread ", Threads.threadid(), "] (", Dates.Time(now()), ") Running ", currentAlgorithm, " with ", nSteps*factor, " steps."
			)

			# Run the genetic algorithm and initialize runtime tracking:
			TrackingTimers.@timeit runtimes string(i, ": ",currentAlgorithm) result = 
				simulate(currentAlgorithm, nSteps*factor; seed=seed)
			
			# Store the results in the result vector:
			lock(simDataLock) 							# Lock the result vector to avoid data race
			try
				simulationData[i] = result
			finally
				unlock(simDataLock)
			end

			# Print an information to the console, that the simulation has finished:
			@info string(
				"[Thread ", Threads.threadid(), "] (", Dates.Time(now()),
				") Finished running ", currentAlgorithm, "."
			)
		end
	else
		for i in 1:nGAs
			# Determine the adjustment for the number of steps of the next simulation:
			factor, remainder = divrem(maxEvals, evalsPerStep[i])
			if !(remainder == 0) @warn "Genome modifications not exactly comparable" end
			
			currentAlgorithm = geneticAlgorithms[i]			# Get the next algorithm to simulate
			
			# Print an information to the console, that the simulation has started:
			@info string("(", Dates.Time(now()), ") Running ", currentAlgorithm, " with ", nSteps*factor, " steps.")

			# Run the genetic algorithm and initialize runtime tracking:
			TrackingTimers.@timeit runtimes string(i, ": ",currentAlgorithm) result = 
				simulate(currentAlgorithm, nSteps*factor; seed=seed)
			
			simulationData[i] = result						# Store the results

			# Print an information to the console, that the simulation has finished:
			@info string("(", Dates.Time(now()), ") Finished running ", currentAlgorithm, ".")
		end
	end
	
	# Return a comparison of the given genetic algorithms:
	return GAComparison(simulationData, DataFrame(runtimes))
end

"""
	compare(geneticAlgorithms::Vector{T}, nSteps=100; multiThreading::Bool=true, seed=nothing)

Run one simulation for every genetic algorithm given by the vector `geneticAlgorithms` and save the 
simulation results to the directory `dirname`.

For further information on how the simulations are run, see 
`compare(geneticAlgorithms::Vector{T}, nSteps=100; multiThreading::Bool=true, seed=nothing)` above.

**Arguments:**
- **dirname:** The directory, where the simulation results should be saved in.
- **geneticAlgorithms:** The different parameter initialisations, for which simulations should be 
						 run
- **nSteps:** The minimum number of steps a simulation will run. (see description above)
- **multiThreading:** Specifies, if multithreading should be used. (Default: true)
- **saveSpecificPlots:** Specifies, whether to create and save plots, that only relate to a single 
						 simulation. (Default: true)
- **seed:** The seed to use for the simulations. If it's set no `nothing`, no seed is used. 
(Default: nothing)

**Return:**
- A GAComparison instance containing the simulation results as well as tracked runtimes of every 
  run simulation.
"""
function compare(
	dirname::String,
	geneticAlgorithms::Vector{T}, 
	nSteps=100;
	multiThreading=false,
	saveSpecificPlots=true,
	seed=nothing
) where {T <: GeneticAlgorithm}
	isDirnameValid = isdir(dirname)

	# If the given dirname is valid, construct a new subdir name out of the current datetime:
	if isDirnameValid
		subdir = Dates.format(Dates.now(), dateformat"yyyy_mm_dd__HH_MM")
	end

	# Run the simulations:
	comparison = compare(geneticAlgorithms, nSteps; multiThreading=multiThreading, seed=seed)

	# If it is valid, save the simulation results to the given directory:
	if isDirnameValid
		pwdBackup = pwd()
		cd(dirname)
		mkpath(subdir)
		cd(subdir)

		savePlots(comparison, withSimulationPlots=saveSpecificPlots)		
		saveData(comparison)												

		cd(pwdBackup)
	else
		@warn "Given dirname is no valid directory! Skipped saving figures ..."
	end

	return comparison
end

# ---------------------------------------------------------------------------------------------------
"""
	demo()

This function shows the use of this module. It will create 4 genetic algorithms with different parameters and run a simulation for each of them. 
Afterwards the results will be plotted and displayed. 

**Arguments:**
- Nothing

**Return:**
- Nothing
"""
function demo()
	bga1 = BasicGA(100,128,1/100,false;M=1)
	bga2 = BasicGA(100,128,1/1000,false;M=1)
	ega1 = ExploratoryGA(100,128,1/100,false,100;speedAdvantage=10,M=1)
	ega2 = ExploratoryGA(100,128,1/1000,false,100;speedAdvantage=10,M=1)
	comparison = compare([bga1, bga2, ega1, ega2])
	displayCompareMinimumScoresPlot(comparison.simulations)
	return
end

end # of module GAs
