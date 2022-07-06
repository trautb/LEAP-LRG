# =========================================================================================
### mutate.jl: Defines functions to mutate the genpool of a population
# =========================================================================================

"""
	mutate!(genpool::Matrix{T}, alleles::Vector{T}; mu, casino) where {T <: Integer}

Mutates the given genpool of alleles (represented by integers).

Each element in `genpool` has probability `mu` to be replaced by a random allele of `alleles`, which
should be a vector of possible allele choices. To dermine the loci, where a mutation should happen,
the function uses the Casino `casino`.

ATTENTION: The mutation modifies the original array, but the new genpool is returned anyway.
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

		# Now mutate the genpool of the population:
		for i ∈ 1:nIndividuals
			# Modifiy the selected loci:
			genpool[i, loci[i, :]] = alleles[alleleIdx[i, loci[i, :]]];
		end
	end

	# Return the mutated (original) genpool:
	return genpool
end

# -----------------------------------------------------------------------------------------
"""
	mutate!(genpool::Matrix{T}, mu, casino) where {T <: Enum}

Mutates the given genpool of alleles (represented by enums) by mutating its integer representation.

See above: `mutate!(genpool::Matrix{T}, alleles::Vector{T}; mu, casino) where {T <: Integer}`

ATTENTION: The mutation modifies the original array, but the new genpool is returned anyway.
"""
function mutate!(genpool::Matrix{T}, mu, casino) where {T <: Enum}
	# Determine possible alleles:
	alleles = eltype(genpool);

	# Get alleles and convert them to integers:
	intAlleles = [Int(i) for i in instances(alleles)]
	
	# Perform mutation on the genpool of the population:
	mutatedGenpool = mutate!(Int.(genpool), intAlleles; mu, casino)

	# Convert integers back to alleles and modfiy original genpool:
	return genpool .= alleles.(mutatedGenpool)
end