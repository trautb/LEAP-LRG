# =========================================================================================
### results.jl: Defines structs to store the results of run simulations
# =========================================================================================

"""
	GASimulation

A GASimulation contains the results of a single simulation, which is run by calling `simulate`.
"""
struct GASimulation
    timestamp::DateTime						# The end-time of the simulation
    algorithm::GeneticAlgorithm				# The algorithm used for the simulation
    agentDF::DataFrame						# The agent-data collected during the simulation

	# Constructor of a GASimulation, that inserts the current time as simulation end-time:
    function GASimulation(
        algorithm::GeneticAlgorithm, 
        agentDF::DataFrame
    )
        return new(Dates.now(), algorithm, agentDF)
    end
end

# -----------------------------------------------------------------------------------------
"""
	GAComparison

A GAComparison contains the results multiple genetic algorithm simulations to compare them afterwards.

The vector `simulations` contains an element of `GASimulation` for every run simulation and `timestamp` is the end-time of the comparison. 
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