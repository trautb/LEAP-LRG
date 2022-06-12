# =========================================================================================
### Define different algorithm types
# =========================================================================================

# Ensure, that the including module exports the algorithm types
export BasicGA, ExploratoryGA

"""
	GeneticAlgorithm

	Abstract supertype for all genetic algorithms.
"""
abstract type GeneticAlgorithm end

# -----------------------------------------------------------------------------------------
"""
	BasicGA

A struct containing all constants to run the basic genetic algorithm.
"""
struct BasicGA <: GeneticAlgorithm
	nIndividuals::Integer
	genomeLength::Integer
	M::Integer

	function BasicGA(
		nIndividuals::Integer = 100, 
		genomeLength::Integer = 128;
		M::Integer = 1
	) 
		return new(nIndividuals, genomeLength, M)
	end 
end

# -----------------------------------------------------------------------------------------
"""
	ExploratoryGA

A struct containing all constants to run the exploratory genetic algorithm.
"""
struct ExploratoryGA <: GeneticAlgorithm
	nIndividuals::Integer
	genomeLength::Integer
	M::Integer

	function ExploratoryGA(
		nIndividuals::Integer = 100, 
		genomeLength::Integer = 128;
		M::Integer = 1
	) 
		return new(nIndividuals, genomeLength, M)
	end 
end	