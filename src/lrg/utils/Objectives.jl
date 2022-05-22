#= ====================================================================================== =#
"""
	Objectives

A collection of displayable objective functions
Authors: Alina Arneth, Michael Staab, Benedikt Traut, Adrian Wild 2022.
"""
module Objectives

export Objective, dim, domain, evaluate, dummyObjective # evaluate necessary?

using Statistics

# -----------------------------------------------------------------------------------------
# Module types:

"""
	Objective

An Objective encapsulates an objective function for GAs. An Objective instance is a
function f: C^n -> R together with a (by default infinite) domain and dimensionality.
"""
struct Objective
	functn::Function			# The objective function
	domain::Vector{Vector}		# Domain specification
end

"Construct a new Objective from the test suite with default dimension and donain."
function Objective(fun::Int=1)
	if ~(fun in 1:length(testSuite))
		fun = 1
	end
	Objective(testSuite[fun]...)
end
		
"Construct a new Objective from the test suite with newly provided domain."
function Objective(fun::Int, dom::Vector, dim::Int=1)
	if ~(fun in 1:length(testSuite))
		fun = 1
	end
	Objective(testSuite[fun][1], dom, dim)
end

"""
	Objective(fun,dom,dim)

Create an Objective function with the given domain. If the domain is a vector of two
Numbers, it is a range that should be replicated over several dimensions; otherwise,
if it is a vector of such ranges, it is a complete domain and the dimensionality should
be ignored.
"""
function Objective(fun::Function, dom, dim::Int)
	if dom[1] isa Vector
		# This is a ready-made domain - ignore the given dimension:
		if any(length.(dom) .!= 2) || any(first.(a) .>= last.(a))
			# The domain structure is invalid - abort:
			error("Domain specification is invalid")
		end
		Objective(fun, dom)
	else
		# This a 1-dimensional range that should be replicated over dim dimensions:
		if length(dom) != 2 || dom[1] >= dom[2] || dim < 1
			# The domain structure is invalid - abort:
			error("Single domain/dimension specification is invalid")
		end
		Objective(fun, [dom for _ in 1:dim])
	end
end

# -----------------------------------------------------------------------------------------
# Module methods:

# -----------------------------------------------------------------------------------------
"Return dimension of Objective function domain."
function dim(obj::Objective)
	length(obj.domain)
end

# -----------------------------------------------------------------------------------------
"Return domain of Objective function."
function domain(obj::Objective)
	obj.domain
end

# -----------------------------------------------------------------------------------------
"Evaluate Objective function for the given collection of arguments."
function evaluate(obj::Objective, args)
	obj.functn.(args)
end

# -----------------------------------------------------------------------------------------
"""
	mepi(x)

Watson's maximally epistatic objective function.
"""
function mepi(genome::BitVector)
	dim = length(genome)

	if dim == 1
		1
	else
		# mepi is minimized if allels are the same
		penality = all(genome) || !any(genome) ? 0 : 1
		# Form product of the first and second halves of genome separately:
		halflen = div(dim, 2)
		dim * penality + mepi(genome[1:halflen]) + mepi(genome[halflen + 1:end])
	end
end

"""
	fitness(sga)

Calculate normalised fitness based on the Objective function. fitness is a column vector of normalised 
fitnesses of sga population, minus all sub-sigma-scaled individuals (see Mitchell p.168).
Negative sigma-scaling maximises the objective function; higher magnitudes raise the fitness pressure. 
evaluations is a colum vector of evaluations of the population. 
"""
function fitness(genpool::BitMatrix, obj::Objective) 

	npop = size(genpool)[1]

	# Calculate the current objective evaluations of the population:
	evaluations = evaluate(obj, [genpool[i,:] for i = 1:npop]) # , genpool]) when genpool::Vector{BitVector}
	#evaluations = mepi.([genpool[i,:] for i = 1:npop]) # = mepi.(genpool) when genpool::Vector{BitVector}
	# Normalise the evaluations into frequencies:
	sigma = std(evaluations)				# Standard deviation
	if sigma == 0
		# Singular case: all evaluations were equal to the mean:
		fitness = ones(npop)
	else
		# Exorcise all evaluations worse than one standard
		# deviations above mean value:
		fitness = 1 .+ (mean(evaluations) .- evaluations) ./ (sigma)
		fitness[fitness .<= 0] .= 0
	end
	
	(fitness,evaluations)					# Return value
end

# -----------------------------------------------------------------------------------------
# Module data:

"""
	testSuite

Vector of functions together with appropriate domains. 
Function 1 is Watson's (2004) maximally epistatic function.
"""
testSuite = [
	# 1. Watson's maximally epistatic function:
	(mepi, [0,100], 128), ###CHANGE DOMAIN !!!
]



# -----------------------------------------------------------------------------------------
# Debugging- & testing-stuff
function dummyObjective()
	return Objective(x -> x, [[0, 10], [0, 10]])
end

function dummyFitness()
	return
end


end # of module Objectives