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
	nGenes::Integer
	mu::Number
	useHintonNowlan::Bool
	M::Integer

	function BasicGA(
		nIndividuals::Integer = 100, 
		nGenes::Integer = 128,
		mu::Number = 0.0001,
		useHintonNowlan::Bool = false;
		M::Integer = 1
	) 
		return new(nIndividuals, nGenes, mu, useHintonNowlan, M)
	end 
end

# -----------------------------------------------------------------------------------------
"""
	ExploratoryGA

A struct containing all constants to run the exploratory genetic algorithm.
"""
struct ExploratoryGA <: GeneticAlgorithm
	nIndividuals::Integer
	nGenes::Integer
	mu::Number
	useHintonNowlan::Bool
	nTrials::Integer
	speedAdvantage::Number
	M::Integer

	function ExploratoryGA(
		nIndividuals::Integer = 100, 
		nGenes::Integer = 128,
		mu::Number = 0.0001,
		useHintonNowlan::Bool = false,
		nTrials::Integer = 100;
		speedAdvantage::Number = 10,
		M::Integer = 1
	) 
		return new(nIndividuals, nGenes, mu, useHintonNowlan, nTrials, speedAdvantage, M)
	end 
end	