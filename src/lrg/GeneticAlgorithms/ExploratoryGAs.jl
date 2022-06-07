include("./Casinos.jl")

using Agents
using Random
using Statistics
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
	nAlleles = length(random_agent(model).genome)
	phenotypes = asPhenotype(pop, model.casino)
	@show(sum(phenotypes, dims=2))
	# get fitness matrix:
	# popFitness, _ = fitness(Bool.(population))
	# Selection:
	# selectionWinners = population[performSelection(popFitness),:]
	# Recombination:
	# popₙ = ExploratoryGAAlleles.(selectionWinners[1:size(population,1),:]) # TODO implement
	# popₙ = recombine(model.recombination, selectionWinners)
	# Mutation:
	mutate!(pop, model.mu, model.casino)
	# TODO: remove mock code that just makes all Alleles to ones and replace with actual mutation
	genocide!(model)

	for i ∈ 1:nAgents
		agent = ExploratoryGAAgent(i, (1, 1), pop[i,:])
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

#---------------------------------------------------------------------------------------------------
function asPhenotype(genpool::Matrix{ExploratoryGAAlleles}, casino)
	undefAlleles = genpool .== two
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