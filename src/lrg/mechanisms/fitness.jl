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

# -----------------------------------------------------------------------------------------
"""
	fitness(genpool::BitMatrix)

Calculate normalised fitness of the population. fitness is a column vector of normalised 
fitnesses of sga population, minus all sub-sigma-scaled individuals (see Mitchell p.168).
Negative sigma-scaling maximises the objective function; higher magnitudes raise the fitness 
pressure. 
evaluations is a colum vector of evaluations of the population. 
"""
function fitness(genpool::BitMatrix) 

	npop = size(genpool)[1]

	# Calculate the current objective evaluations of the population:
	evaluations = mepi.([genpool[i,:] for i = 1:npop]) 

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
	
	(fitness, evaluations)					# Return value
end

#---------------------------------------------------------------------------------------------------
"""
	fitness(genpool::BitMatrix, plasticityTrials::Int64, casino) 

Calculates normalised fitness based on the Objective function at each plasticity trial. 
and keeps the best fitness and underlying evaluation for each individual. 
best_fitness_vals is a column vector of normalised fitnesses of the population, minus all 
sub-sigma-scaled individuals (see Mitchell p.168).

Negative sigma-scaling maximises the objective function; higher magnitudes raise the fitness
pressure. 

best_evaluations is a colum vector of evaluations of the population. 
"""
function fitness(
		genpool::Matrix{ExploratoryGAAlleles}, 
		nTrials::Integer, 
		speedAdvantage::Number,
		casino
	) 
	nIndividuals, _ = size(genpool)

	# fitness and evaluations at plasticity trial 0
	best_fitness_vals = zeros(nIndividuals) .- 1	# Ensure, evaluations are included at least once
	best_evaluations = zeros(nIndividuals)

	# calculates the fitness at each plasticity trial and keeps the best for each individual
	for i in 1:nTrials
		fitness_i, evaluations_i = fitness(plasticity(genpool, casino)) 
		# rewarding finding good fitness quickly
		fitness_i = fitness_i .* (1 + speedAdvantage - speedAdvantage * i / (nTrials + 1)) 

		# keep the best fitness values and underlying evaluations 
		index = best_fitness_vals .< fitness_i
		best_fitness_vals[index] = fitness_i[index]
		best_evaluations[index] = evaluations_i[index]
		
	end

	(best_fitness_vals, best_evaluations)
end