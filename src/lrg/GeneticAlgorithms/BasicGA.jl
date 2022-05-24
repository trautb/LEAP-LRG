#= ====================================================================================== =#
"""
	BasicGA

An agentbased Implementation of the Basic Genetic Algorithm (i.e. just using selection, 
genetic mutation and recombination).

Authors: Alina Arneth, Michael Staab, Benedikt Traut, Adrian Wild 2022.
"""
using Statistics
using Agents, Random
using InteractiveDynamics, GLMakie

# -----------------------------------------------------------------------------------------
# Module types:

"""
	BasicGAAlleles

Enum for Alleles in Basic GA, Possible values are 1 and 0
"""
@enum BasicGAAlleles zero one

"""
	BasicGAAgent

The basic agent in the simulation
"""
@agent BasicGAAgent GridAgent{2} begin
	genome::Vector{BasicGAAlleles}
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

	model = ABM(
		BasicGAAgent, space;
	)
	for n in 1:N
        agent = BasicGAAgent(n, (1, 1), BasicGAAlleles.(rand([0,1], genome_length)))
        # agent = BasicGAAgent(n, (1, 1), rand(Bool, genome_lenght))
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
	population = map(agent -> Int8.(agent.genome), allagents(model))
	nAlleles = length(random_agent(model).genome)
	# get fitness matrix:
	popFitness = fitness(population)
	# Selection:
	selectionWinners = population[performSelection(popFitness), 1:end]
	# Recombination:
	# popₙ = recombine(model.recombination, selectionWinners)
	# Mutation:
	popₙ = mutate(popₙ, model.mu, model.obj)
	# TODO: remove mock code that just makes all Alleles to ones and replace with actual mutation
	for agent ∈ allagents(model)
		agent.genome = fill(BasicGAAlleles(1), nAlleles)
	end
	return 
end


"""
	simulate

Creates and runs the simulation.
"""
function simulate()
	model = initialize()
	data, _ = run!(model, dummystep, model_step!, 5; adata=[a -> sum(Int.(a.genome))])
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
	mutatedGenpool = mutate!(Int.(genpool), intAlleles, mu, casino)

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
	
	(fitness,evaluations)					# Return value
end

"""
    This implementation of tournamentSelection expects a matrix of fitness values with the datatype float64
"""
function performSelection(popFitness::Array)
    nPop = length(popFitness)
    parents = Array(2*nPop)

    for i in 1:2*nPop
        
        "Could be solved with sample function from StatsBase.jl"
        firstFigther = rand(1:nPop)
        secondFighter = rand(1:nPop)
        
        if popFitness[firstFigher] > popFitness[secondFigher]
            parents[i] = firstFighter
        else
            parents[i] = secondFighter
        end
    end
    return parents
end