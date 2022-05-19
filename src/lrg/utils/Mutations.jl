#==================================================================================================#
"""
	Mutations

A collection of functions for mutating genomes.

Authors: Alina Arneth, Michael Staab, Benedikt Traut, Adrian Wild 2022.
"""
# Warning: not tested code! Just to show the structural idea!
module Mutations

export Mutation, BitFlip, DummyMutation, mutate!

include("./Casinos.jl")

using .Casinos: Casino, draw

#---------------------------------------------------------------------------------------------------
# Module types:

"""
	Mutation

A Mutation encapsulates the ability of GAs to mutate the genome after 
recombination. A Mutation is basically a function R^x -> R^x that mutates a genome (i.e. array 
of alleles).
"""
abstract type Mutation end

"""
	DummyMutation

Dummy Mutation, does nothing.
"""
struct DummyMutation <: Mutation 

end

"""
	BitFlip

"Classical" Point Mutation (see /SimpleGAs/SimpleGAs.jl) that flips each allele 
with a given propability mu.
"""
struct BitFlip <: Mutation
	mu::AbstractFloat
	casino::Casino

	function BitFlip(mu::AbstractFloat, casino::Casino)
		new(mu, casino)
	end
end

#---------------------------------------------------------------------------------------------------
# Module methods:

"""
	mutate!(genpool::Matrix{Bool}, mutation::DummyMutation)	

Dummy implementation of the mutate method. It returns the original genpool
"""
function mutate!(genpool::Matrix{Bool}, mutation::DummyMutation)
	return genpool 
end

#---------------------------------------------------------------------------------------------------

"""
	mutate!(genpool::Matrix{Bool}, mutation::BitFlip)

Mutates the given boolean genpool according to the BitFlip mutation (see above).
"""
function mutate!(genpool::Matrix{Bool}, mutation::BitFlip)
	# Only expend effort on mutating if it is really wanted:
	if mutation.mu > 0
		# Get population size and number of genes per individual:
		nIndividuals, nGenes = size(genpool)

		# Find loci to mutate:
		loci = draw( mutation.casino, nIndividuals, nGenes, mutation.mu)

		# Now mutate everyone except the elitists:
		for i ∈ 1:nIndividuals
			# Negate the mutated genes:
			genpool[i, loci[i, :]] = .!(genpool[i, loci[i, :]])
		end
	end

	return genpool
end

#---------------------------------------------------------------------------------------------------

"""
	mutate!(genpool::Matrix{T}, alleles::Vector{T}, mutation::BitFlip) where {T <: Integer}

Mutates the given genpool with Integer elements (alleles) according to the BitFlip mutation (see above), 
but with the subsequent changes:
	1. For each locus, a corresponding allele probability is fetched
	2. Each allele probability is converted into a allele index
	3. For mutation, each orginal allele at a selected locus is replaced by the allele 
	   at the corresponding index
"""
function mutate!(genpool::Matrix{T}, alleles::Vector{T}, mutation::BitFlip) where {T <: Integer}
	# Only expend effort on mutating if it is really wanted:
	if mutation.mu > 0
		# Get population size and number of genes per individual:
		nIndividuals, nGenes = size(genpool)

		# Find loci to mutate:
		loci = draw(mutation.casino, nIndividuals, nGenes, mutation.mu)

		# Fetch a allele probability to generate allele indices for locusmutation:
		alleleIdx = Int64.(ceil.(
			draw(mutation.casino, nIndividuals, nGenes) .* length(alleles)
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
function mutate!(genpool::Matrix{T}, mutation::BitFlip) where {T <: Enum}
	# Determine possible alleles
	alleles = eltype(genpool);

	# Get alleles and convert them to integers:
	intAlleles = [Int(i) for i in instances(alleles)]
	
	# Perform mutation on the genpool of the population:
	mutatedGenpool = mutate!(Int.(genpool), intAlleles, mutation)

	# Convert integers back to alleles and modfiy original matrix:
	return genpool .= alleles.(mutatedGenpool)
end

end # module Mutations