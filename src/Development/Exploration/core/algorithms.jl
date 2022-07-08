# =========================================================================================
### algorithms.jl: Defines different algorithm types
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
    mu::Number 						# mutation rate
    useHaystack::Bool
    M::Integer 						# the size of the ABM space


function BasicGA(
		nIndividuals::Integer = 100, 
		nGenes::Integer = 128,
		mu::Number = 2/(nIndividuals*nGenes),
		useHaystack::Bool = false;
		M::Integer = 1
	) 
		return new(nIndividuals, nGenes, mu, useHaystack, M)
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
	mu::Number						# Mutation rate
	useHaystack::Bool
	nTrials::Integer
	M::Integer						# The size of the abm space

	function ExploratoryGA(
		nIndividuals::Integer = 100, 
		nGenes::Integer = 128,
		mu::Number = 2/(nIndividuals*nGenes),
		useHaystack::Bool = false,
		nTrials::Integer = 100;
		speedAdvantage::Number = 10,
		M::Integer = 1
	) 
		return new(nIndividuals, nGenes, mu, useHaystack, nTrials, M)
	end 
end	

# -----------------------------------------------------------------------------------------
"""
	paramstring(algorithm::GeneticAlgorithm)
	paramstring(algorithm::BasicGA)
	paramstring(algorithm::ExploratoryGA)

Return the parameters for the GeneticAlgorithm `algorithm` as a formatted string.

The returned string is formatted as follows:  
	
	<<GA-Name>>--<<param1>>-<<value1>>--<<param2>>-<<value2>> ...

Every GeneticAlgorithm should have a custom implementation of this method.

**Arguments:**
- **algorithm:** The genetic algorithm, that should be represented as string. 

**Return:**
- A string representing the algorithm and its parameters.
"""
function paramstring(algorithm::GeneticAlgorithm)
	return "no_specific_paramstring_impl_found"
end

function paramstring(algorithm::BasicGA)
	return string("BasicGA",
		"--nIndividuals-", algorithm.nIndividuals,
		"--nGenes-", algorithm.nGenes,
		"--mu-", pointToUnderscore(repr(algorithm.mu)),
		"--useHN-", algorithm.useHaystack
	)
end

function paramstring(algorithm::ExploratoryGA)
	return string("ExploratoryGA",
		"--nIndividuals-", algorithm.nIndividuals,
		"--nGenes-", algorithm.nGenes,
		"--mu-", pointToUnderscore(repr(algorithm.mu)),
		"--useHN-", algorithm.useHaystack,
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