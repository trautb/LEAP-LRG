# =========================================================================================
### results.jl: Defines structs to store the results of run simulations
# =========================================================================================

"""
	GASimulation

A GASimulation contains the results of a single simulation, which is run by calling `simulate`.

The DataFrame `simulationDF` should contain at least the following columns:  
	:step 		- The step, at which the data was collected.  
	:organism	- The id of the organism, for which the data was collected.  
	:score		- The score of the organism at the corresponding step.  
	:zeros		- The number of zeros in the organisms genome.  
	:ones		- The number of ones in the organisms genome.  
	:qMarks		- The number of qMarks in the organisms genome (only for ExploratoryGAs).  
"""
struct GASimulation
    timestamp::DateTime						# The end-time of the simulation
    algorithm::GeneticAlgorithm				# The algorithm used for the simulation
    simulationDF::DataFrame					# The agent-data collected during the simulation

	# Constructor of a GASimulation, that inserts the current time as simulation end-time:
    function GASimulation(
        algorithm::GeneticAlgorithm, 
        simulationDF::DataFrame
    )
        return new(Dates.now(), algorithm, simulationDF)
    end
end

# -----------------------------------------------------------------------------------------
"""
	GAComparison

A GAComparison contains the results multiple genetic algorithm simulations to compare them afterwards.

The vector `simulations` contains an element of `GASimulation` for every run simulation and `timestamp` is the end-time of the comparison. 

`runtimes` should be a DataFrame returned by an expression like 
`DataFrame(trackingTimer::TrackingTimer)` using a `TrackingTimer` from the package TrackingTimers.jl
"""
struct GAComparison
    timestamp::DateTime						# The end-time of the comparison
    simulations::Vector{GASimulation}		# Compared simulations
    runtimes::DataFrame						# The tracked simulation runtimes

	# Constructor of a GAComparison, that inserts the current time as comparison end-time:
    function GAComparison(
        simulations::Vector{GASimulation},
        runtimes::DataFrame
    )
        return new(Dates.now(), simulations, runtimes)
    end
end