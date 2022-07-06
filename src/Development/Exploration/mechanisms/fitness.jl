# =========================================================================================
### fitness.jl: 
# Defines functions which implement the fitness and underlying objective functions of the 
# individuals within this simulation
# =========================================================================================

"""
	mepi(genome::BitVector)

Watson's maximally epistatic objective function.
"""
function mepi(genome::BitVector)
	dim = length(genome)

	if dim == 1
		1
	else
		# Mepi is minimized if allels are the same:
		penality = all(genome) || !any(genome) ? 0 : 1
		# Form product of the first and second halves of genome separately:
		halflen = div(dim, 2)
		dim * penality + mepi(genome[1:halflen]) + mepi(genome[halflen + 1:end])
	end
end

# -----------------------------------------------------------------------------------------
"""
hintonNowlan(genome::BitVector)

Hinton and Nowlans's simple example function.
"""
function hintonNowlan(genome::BitVector)
	# hintonNowlan is minimized if all allels are 1:
	return all(genome) ? 0 : 1
end

# -----------------------------------------------------------------------------------------
"""
	fitness(genpool::BitMatrix, useHintonNowlan::Bool)

Calculate normalised fitness of the population based on the Objective function. 
fitness is a column vector of normalised fitnesses of GA population, 
minus all sub-sigma-scaled individuals (see Mitchell p.168). Negative sigma-scaling maximises 
the objective function; higher magnitudes raise the fitness pressure. 
evaluations is a colum vector of evaluations of the population. 

Returns the fitness and underlying evaluation values.
"""
function fitness(genpool::BitMatrix, useHintonNowlan::Bool) 

	nIndividuals = size(genpool)[1]

	# Calculate the current evaluations of the coosen objective function of the population:
	if useHintonNowlan
		evaluations = hintonNowlan.([genpool[i,:] for i = 1:nIndividuals]) 
	else
		evaluations = mepi.([genpool[i,:] for i = 1:nIndividuals]) 
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
	fitness(genpool::Matrix{ExploratoryGAAlleles}, nTrials::Integer, casino, useHintonNowlan::Bool)  

Calculate normalised fitness based on the Objective function at each plasticity trial
and keeps the best fitness and underlying evaluation of all plasticity trials for each individual. 
Finding good fitness gets rewarded propornational to the time it took.
bestFitnessVals is a column vector of the best normalised fitnesses of all trials for each individual
of the population, minus all sub-sigma-scaled individuals (see Mitchell p.168). Negative sigma-scaling 
maximises the objective function; higher magnitudes raise the fitness pressure. 
underlyingEvaluations is a colum vector of evaluations of the population. 

Returns fitness and underlying evaluation values.
"""
function fitness(
	genpool::Matrix{ExploratoryGAAlleles}, 
	nTrials::Integer,
	casino,
	useHintonNowlan::Bool
)
	nIndividuals, _ = size(genpool)

	# Fitness and evaluations at plasticity trial 0:
	bestFitnessVals = - ones(nIndividuals)	 # Ensure, evaluations are included at least once
	underlyingEvaluations = zeros(nIndividuals)

	# Calculates the fitness at each plasticity trial and keeps the best for each individual:
	for i in 1:nTrials
		fitness_i, evaluations_i = fitness(plasticity(genpool, casino), useHintonNowlan) 
		# Rewarding finding good fitness quickly (see Hinton and Nowlan p.498):
		fitness_i = fitness_i .* ((1 + 19 * (nTrials - i)) / nTrials) 

		# Keep the best fitness values and underlying evaluations:  
		index = bestFitnessVals .< fitness_i
		bestFitnessVals[index] = fitness_i[index]
		underlyingEvaluations[index] = evaluations_i[index]
		
	end

	return (bestFitnessVals, underlyingEvaluations) 
end