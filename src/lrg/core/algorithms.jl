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
		mu::Number = 1/nIndividuals,
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
		mu::Number = 1/nIndividuals,
		useHintonNowlan::Bool = false,
		nTrials::Integer = 100;
		speedAdvantage::Number = 10,
		M::Integer = 1
	) 
		return new(nIndividuals, nGenes, mu, useHintonNowlan, nTrials, speedAdvantage, M)
	end 
end	

# -----------------------------------------------------------------------------------------
"""
	paramstring(algorithm::GeneticAlgorithm)

Return the parameters for the GeneticAlgorithm `algorithm` as a formatted string.

The returned string is formatted as follows:  
	
	<<GA-Name>>--<<param1>>-<<value1>>--<<param2>>-<<value2>> ...

Every GeneticAlgorithm should have a custom implementation of this method.
"""
function paramstring(algorithm::GeneticAlgorithm)
	return "no_specific_paramstring_impl_found"
end

function paramstring(algorithm::BasicGA)
	return string("BasicGA",
		"--nIndividuals-", algorithm.nIndividuals,
		"--nGenes-", algorithm.nGenes,
		"--mu-", pointToUnderscore(repr(algorithm.mu)),
		"--useHN-", algorithm.useHintonNowlan
	)
end

function paramstring(algorithm::ExploratoryGA)
	return string("ExploratoryGA",
		"--nIndividuals-", algorithm.nIndividuals,
		"--nGenes-", algorithm.nGenes,
		"--mu-", pointToUnderscore(repr(algorithm.mu)),
		"--useHN-", algorithm.useHintonNowlan,
		"--nTrials-", algorithm.nTrials
	)
end

# -----------------------------------------------------------------------------------------
"""
	pointToUnderscore(s::String)

Replaces every dot "." in string `s` with an underscore "_".

Returns the new string.
"""
function pointToUnderscore(s::String)
	return replace(s, "." => "_")
end