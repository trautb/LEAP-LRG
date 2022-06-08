include("./Casinos.jl")

using Agents
using Random #ToDO just Random: shuffle! ???
using Statistics: std, mean
using .Casinos

"""
	ExploratoryGAAlleles

Enum for Alleles in Exploratory GA, Possible values are 1, 0, 2
"""
@enum ExploratoryGAAlleles zero one qMark

"""
	ExploratoryGAAgent

The exploratory agent in the simulation
"""
@agent ExploratoryGAAgent{ExploratoryGAAlleles} GridAgent{2} begin
	genome::Vector{ExploratoryGAAlleles}
end

# -----------------------------------------------------------------------------------------
# Module methods:

"""
	initialize

Initializes the simulation.
"""
function initialize(; N=100, M=1, seed=42, genome_length=128)
	Random.seed!(seed);
	space = GridSpace((M, M); periodic=false)
	properties = Dict([
		:mu => 0.0001,
		:casino => Casino(N+1, genome_length+1)
	])

	model = ABM(
		ExploratoryGAAgent, space;
		properties
	)
	for n in 1:N
        agent = ExploratoryGAAgent(n, (1, 1), ExploratoryGAAlleles.(rand([0,1], genome_length)))
		add_agent!(agent, model)
    end

	return model
end

"""
	model_step!

Modifies the simulation every step. Here it calculates the fitness matrix and then performs
the selection, recombination and mutation depending on the properties of the ABM.
"""
function model_step!(model)
	nAgents = nagents(model)
	population = map(agent -> Int8.(agent.genome), allagents(model))
	population = reduce(vcat, transpose.(population))
	pop = ExploratoryGAAlleles.(population)

	#nAlleles = length(random_agent(model).genome)
	#phenotypes = evolvePhenotype(pop, model.casino)
	#@show(sum(phenotypes, dims=2))

	# get fitness matrix:
	# ToDo add n plasticityTrials to properties
	popFitness, _ = plasticityFitness(pop, 10, model.casino) 

	# Selection:
	selectionWinners = encounter(popFitness)
	# Recombination:
	popₙ = recombine(pop, selectionWinners)
	# Mutation:
	mutate!(popₙ, model.mu, model.casino)
	# TODO: remove mock code that just makes all Alleles to ones and replace with actual mutation
	genocide!(model)

	for i ∈ 1:nAgents
		agent = ExploratoryGAAgent(i, (1, 1), popₙ[i,:])
		add_agent!(agent, model)
	end
	return 
end


"""
	simulate

Creates and runs the simulation.
"""
function simulate()
	model = initialize()
	data, _ = run!(model, dummystep, model_step!, 5; adata=[(a -> sum(Int.(a.genome)), mean)])
	return data
end

"""
	mutate!(genpool::Matrix{T}, alleles::Vector{T}, mutation::BitFlip) where {T <: Integer}
Mutates the given genpool with Integer elements (alleles) according to the BitFlip mutation (see above), 
but with the subsequent changes:
	1. For each locus, a corresponding allele probability is fetched
	2. Each allele probability is converted into a allele index
	3. For mutation, each orginal allele at a selected locus is replaced by the allele 
	   at the corresponding index
"""
function mutate!(genpool::Matrix{T}, alleles::Vector{T}; mu, casino) where {T <: Integer}
	# Only expend effort on mutating if it is really wanted:
	if mu > 0
		# Get population size and number of genes per individual:
		nIndividuals, nGenes = size(genpool)

		# Find loci to mutate:
		loci = draw(casino, nIndividuals, nGenes, mu)

		# Fetch a allele probability to generate allele indices for locusmutation:
		alleleIdx = Int64.(ceil.(
			draw(casino, nIndividuals, nGenes) .* length(alleles)
		))

		# Now mutate the population:
		for i ∈ 1:nIndividuals
			# Modifiy the selected loci:
			genpool[i, loci[i, :]] = alleles[alleleIdx[i, loci[i, :]]];
		end
	end

	return genpool
end

#---------------------------------------------------------------------------------------------------

"""
	mutate!(genpool::Matrix{T}, mutation::BitFlip) where {T <: Enum}
Mutates the given genpool of alleles (represented by enums) by modifying the underlying integers 
(see above: mutate!(genpool::Matrix{T}, alleles::Vector{T}, mutation::BitFlip) where {T <: Integer})
"""
function mutate!(genpool::Matrix{T}, mu, casino) where {T <: Enum}
	# Determine possible alleles
	alleles = eltype(genpool);

	# Get alleles and convert them to integers:
	intAlleles = [Int(i) for i in instances(alleles)]
	
	# Perform mutation on the genpool of the population:
	mutatedGenpool = mutate!(Int.(genpool), intAlleles; mu, casino)

	# Convert integers back to alleles and modfiy original matrix:
	return genpool .= alleles.(mutatedGenpool)
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

# -----------------------------------------------------------------------------------------
"""
	fitness(sga)

Calculate normalised fitness based on the Objective function. fitness is a column vector of normalised 
fitnesses of sga population, minus all sub-sigma-scaled individuals (see Mitchell p.168).
Negative sigma-scaling maximises the objective function; higher magnitudes raise the fitness pressure. 
evaluations is a colum vector of evaluations of the population. 
"""
function fitness(genpool::BitMatrix) 

	npop = size(genpool)[1]

	# Calculate the current objective evaluations of the population:
	evaluations = mepi.([genpool[i,:] for i = 1:npop]) # = mepi.(genpool) when genpool::Vector{BitVector}
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

# -----------------------------------------------------------------------------------------
"""
    This implementation of tournamentSelection expects a matrix of fitness values with the datatype float64
"""
function encounter(popFitness::AbstractVector)
    nPop = length(popFitness)
    parents = Array{Int64,1}(undef, 2 * nPop)

    for i in 1:2 * nPop
        
        "Could be solved with sample function from StatsBase.jl"
        firstFighter = rand(1:nPop)
        secondFighter = rand(1:nPop)
        
        if popFitness[firstFighter] > popFitness[secondFighter]
            parents[i] = firstFighter
        else
            parents[i] = secondFighter
        end
    end
    return parents
end

# -----------------------------------------------------------------------------------------
"""
	recombine

This function takes a matrix (individual * genome) and an Array of indices (of parents) as an input.
It recombines the genomes corresponding to the first 1:N indices (where N is the population size and length(parents) == 2N) 
with the genomes corresponding to the second half of the parents Array.
"""
function recombine(genpool::Matrix{T}, parents::AbstractVector) where {T <: Enum}
	nAgents, nAlleles = (div(length(parents), 2), size(genpool, 2))

	# random implementation:
	crossOverPnts = rand(1:nAlleles, nAgents)

	moms = BitArray(y ≤ crossOverPnts[x] for x = 1:nAgents, y = 1:nAlleles)
	p = parents .- 1
	indices = ((moms .* p[1:nAgents] .+ .!moms .* p[nAgents + 1:end]) .* nAlleles) .+ collect(1:nAlleles)'

	popₙ = transpose(genpool)[indices]
	return popₙ
end

# -----------------------------------------------------------------------------------------
"""
Adds dispatch for (Base.)transpose() on a Matrix of Enums
"""
function Base.transpose(A::Matrix{T}) where T <: Enum
	return T.(transpose(Int.(A)))
end

#---------------------------------------------------------------------------------------------------
function evolvePhenotype(genpool::Matrix{ExploratoryGAAlleles}, casino)
	undefAlleles = genpool .== qMark
	nIndividuals, nGenes = size(genpool)

	alleleDefinitions = draw(casino, nIndividuals, nGenes, 0.5)

	phenotypes = BitMatrix(undef, nIndividuals, nGenes)
	phenotypes[undefAlleles] = alleleDefinitions[undefAlleles]
	phenotypes[.!(undefAlleles)] = Int.(genpool[.!(undefAlleles)])

	return phenotypes
end


#---------------------------------------------------------------------------------------------------
function findFitness!(fitnessMatrix, population, currentStep, nSteps)
	popFitness, _ = fitness(Bool.(population))
	return fitnessMatrix[:,currentStep] = popFitness .* (10 - 10*currentStep/nSteps)
end

#---------------------------------------------------------------------------------------------------

"""
	plasticityFitness(genpool::BitMatrix, plasticityTrials::Int64, casino) 

Calculates normalised fitness based on the Objective function at each plasticity trial. 
and keeps the best fitness and underlying evaluation for each individual. 
fitness is a column vector of normalised fitnesses of the population, minus all sub-sigma-scaled individuals (see Mitchell p.168).
Negative sigma-scaling maximises the objective function; higher magnitudes raise the fitness pressure. 
evaluations is a colum vector of evaluations of the population. 

"""
function plasticityFitness(genpool::Matrix{ExploratoryGAAlleles}, plasticityTrials::Int64, casino) 

	nIndividuals, _ = size(genpool)

	# fitness and evaluations at plasticity trial 0
	best_fitness_vals = zeros(nIndividuals)
	best_evaluations = zeros(nIndividuals)

	# calculates the fitness at each plasticity trial and keeps the best for each individual
	for i in 1:plasticityTrials
		fitness_i, evaluations_i = fitness(evolvePhenotype(genpool, casino)) 
		# rewarding finding good fitness quickly
		fitness_i = fitness_i .* (10 - 10 * i / plasticityTrials) 

		# keep the best fitness values and underlying evaluations 
		index = best_fitness_vals .< fitness_i
		best_fitness_vals[index] = fitness_i[index]
		best_evaluations[index] = evaluations_i[index]
	end

	(best_fitness_vals, best_evaluations)
end
