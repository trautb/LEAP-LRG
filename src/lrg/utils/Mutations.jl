#= ====================================================================================== =#
"""
	Mutations

A collection of functions for mutating genomes.

Authors: Alina Arneth, Michael Staab, Benedikt Traut, Adrian Wild 2022.
"""
# Warning: not tested code! Just to show the structural idea!
module Mutations

export Mutation, BitFlip, DummyMutation, mutate

include("../../dev/Casinos/Casinos.jl")

using .Casinos

# -----------------------------------------------------------------------------------------
# Module types:

"""
	Mutation

A Mutation encapsulates the ability of GAs to mutate the genome after recombination.
A Mutation represents a function R^x -> R^x 
(Vector{Allele} -> Vector{Allele})
"""
abstract type Mutation end

"""
	BitFlip

"Classical" Point Mutation (see /SimpleGAs/SimpleGAs.jl) that flips each allele with a given
propability mu.
"""
struct BitFlip <: Mutation 
	mu::Float64
	casino::Casino
end

function mutate(mutation::BitFlip, genome::Vector{Vector{Enum{Integer}}})
	ndims(genome) == 2 || throw(ArgumentError("must be two columns"))
	# Only expend effort on mutating if it is really wanted:
	if mutation.mu > 0
		nIndividuals, nGenes = size(genome)

		# Find loci to mutate:
		loci = draw(mutation.casino, nGenes, mutation.mu)
		
		# Now mutate everyone except the elitists:
		for i ∈ 1:nIndividuals
			# Negate the mutated genes:
			genome[i][loci[:,i]] = .!(genome[i][loci[:,i]])
		end
	end
	return genome
end


# -----------------------------------------------------------------------------------------
# Debugging- & testing-stuff
"""
	DummyMutation

Dummy Mutation, returns unmodified genome.
"""
struct DummyMutation <: Mutation end
function mutate(mutation::DummyMutation, genome::Vector{Vector{Enum}}) return genome end


end # of module Mutations