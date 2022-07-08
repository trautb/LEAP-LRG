# =========================================================================================
### fitness.jl: 
# Defines functions which implement the fitness and underlying objective functions of the 
# individuals within this simulation
# =========================================================================================

"""
	mepi(genome::BitVector)

Watson's maximally epistatic objective function.

**Arguments:**
- **genome:** A vector containing the genes of one individual.

**Return:**
- One value of the datatype Intger. The lower the value the better. The minimum equals the genome length.
"""
function mepi(genome::BitVector)
	dim = length(genome)

	if dim == 1
		return 1
	else
		# Mepi is minimized if allels are the same:
		penality = all(genome) || !any(genome) ? 0 : 1
		# Form product of the first and second halves of genome separately:
		halflen = div(dim, 2)
		return dim * penality + mepi(genome[1:halflen]) + mepi(genome[halflen + 1:end])
	end
end

# -----------------------------------------------------------------------------------------
"""
	haystack(genome::BitVector)

Hinton and Nowlans example function. It works like finding a needle in a haystack only
returning 0 when every gene of an individual has the value 1. 

**Arguments:**
- **genome:** A vector containing the genes of one individual.

**Return:**
- One value of the datatype Integer. Will only be 0 if the whole genome is made out of ones. Otherwise it will be 1.
"""
function haystack(genome::BitVector)
	# haystack is minimized if all allels are 1:
	return all(genome) ? 0 : 1
end

# -----------------------------------------------------------------------------------------
"""
	fitness(genePool::BitMatrix, useHaystack::Bool)

Calculate normalised fitness of the population based on the Objective function. 
fitness is a column vector of normalised fitnesses of GA population, 
minus all sub-sigma-scaled individuals (see Mitchell p.168). Negative sigma-scaling maximises 
the objective function; higher magnitudes raise the fitness pressure. 
evaluations is a colum vector of evaluations of the population. 

**Arguments:**
- **genePool:** A matrix containing the genome of every individual.
- **useHaystack:** Switch to either use mepi or haystack function.

**Return:**
- The fitness and underlying evaluation values.
"""
function fitness(genePool::BitMatrix, useHaystack::Bool) 

	nIndividuals = size(genePool)[1]

	# Calculate the current evaluations of the coosen objective function of the population:
	if useHaystack
		evaluations = haystack.([genePool[i,:] for i = 1:nIndividuals]) 
	else
		evaluations = mepi.([genePool[i,:] for i = 1:nIndividuals]) 
	end

	# Normalise the evaluations into frequencies:
	sigma = std(evaluations)				 # Standard deviation
	if sigma == 0
		# Singular case: all evaluations were equal to the mean:
		fitness = ones(nIndividuals)
	else
		# Exorcise all evaluations worse than one standard
		# deviations above mean value:
		fitness = 1 .+ (mean(evaluations) .- evaluations) ./ (sigma)
		fitness[fitness .<= 0] .= 0
	end
	
	return (fitness, evaluations)					
end

#---------------------------------------------------------------------------------------------------
"""
	fitness(genePool::Matrix{ExploratoryGAAlleles}, nTrials::Integer, casino, useHaystack::Bool)  

Calculate normalised fitness based on the Objective function at each plasticity trial
and keeps the best fitness and underlying evaluation of all plasticity trials for each individual. 
Finding good fitness gets rewarded indirect proportional to the time it took.
bestFitnessVals is a column vector of the best normalised fitnesses of all trials for each individual
of the population, minus all sub-sigma-scaled individuals (see Mitchell p.168). Negative sigma-scaling 
maximises the objective function; higher magnitudes raise the fitness pressure. 
underlyingEvaluations is a colum vector of evaluations of the population. 

**Arguments:**
- **genePool:** A matrix containing the genome of every individual.
- **nTrials:** The number of exploratory searches per step.
- **casino:** The Casino instance to use. 
- **useHaystack:** Switch to either use mepi or haystack function.

**Return:**
- The fitness and underlying evaluation values.
"""
function fitness(
	genePool::Matrix{ExploratoryGAAlleles}, 
	nTrials::Integer,
	casino,
	useHaystack::Bool
)
	nIndividuals, _ = size(genePool)

	# Fitness and evaluations at plasticity trial 0:
	bestFitnessVals = - ones(nIndividuals)	 # Ensure, evaluations are included at least once
	underlyingEvaluations = zeros(nIndividuals)

	# Calculates the fitness at each plasticity trial and keeps the best for each individual:
	for i in 1:nTrials
		fitness_i, evaluations_i = fitness(plasticity(genePool, casino), useHaystack) 
		# Rewarding finding good fitness quickly (see Hinton and Nowlan p.498):
		fitness_i = fitness_i .* ((1 + 19 * (nTrials - i)) / nTrials) 

		# Keep the best fitness values and underlying evaluations:  
		index = bestFitnessVals .< fitness_i
		bestFitnessVals[index] = fitness_i[index]
		underlyingEvaluations[index] = evaluations_i[index]
		
	end

	return (bestFitnessVals, underlyingEvaluations) 
end