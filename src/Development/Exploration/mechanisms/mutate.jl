# =========================================================================================
### mutate.jl: Defines functions to mutate the genePool of a population
# =========================================================================================

"""
	mutate!(genePool::Matrix{T}, alleles::Vector{T}; mu, casino) where {T <: Integer}

Mutates the given genePool of alleles (represented by integers).

Each element in `genePool` has probability `mu` to be replaced by a random allele of `alleles`, which
should be a vector of possible allele choices. To dermine the loci, where a mutation should happen,
the function uses the Casino `casino`.

_ATTENTION_: The mutation modifies the original array, but the new genePool is returned anyway.

**Arguments:**
- **genePool:** Matrix containing the genome of every individual.
- **alleles:** Vector containing the alleles found in the genePool. (basicGA: 0,1 ; exploratoryGA: 0,1,2)
- **mu:** Mutation rate.
- **casino:** The Casino instance to use. 

**Return:**
- The mutated (original) genePool.
"""
function mutate!(genePool::Matrix{T}, alleles::Vector{T}; mu, casino) where {T <: Integer}
	# Only expend effort on mutating if it is really wanted:
	if mu > 0
		# Get population size and number of genes per individual:
		nIndividuals, nGenes = size(genePool)

		# Find loci to mutate:
		loci = draw(casino, nIndividuals, nGenes, mu)

		# Fetch a allele probability to generate allele indices for locusmutation:
		alleleIdx = Int64.(ceil.(
			draw(casino, nIndividuals, nGenes) .* length(alleles)
		))

		# Now mutate the genePool of the population:
		for i ∈ 1:nIndividuals
			# Modifiy the selected loci:
			genePool[i, loci[i, :]] = alleles[alleleIdx[i, loci[i, :]]];
		end
	end

	# Return the mutated (original) genePool:
	return genePool
end

# -----------------------------------------------------------------------------------------
"""
	mutate!(genePool::Matrix{T}, mu, casino) where {T <: Enum}

Mutates the given genePool of alleles (represented by enums) by mutating its integer representation.

See above: `mutate!(genePool::Matrix{T}, alleles::Vector{T}; mu, casino) where {T <: Integer}`

_ATTENTION_: The mutation modifies the original array, but the new genePool is returned anyway.

**Arguments:**
- **genePool:** Matrix containing the genome of every individual.
- **mu:** Mutation rate.
- **casino:** Use the casino module. 

**Return:**
- The mutated (original) genePool.
"""
function mutate!(genePool::Matrix{T}, mu, casino) where {T <: Enum}
	# Determine possible alleles:
	alleles = eltype(genePool);

	# Get alleles and convert them to integers:
	intAlleles = [Int(i) for i in instances(alleles)]
	
	# Perform mutation on the genePool of the population:
	mutatedGenePool = mutate!(Int.(genePool), intAlleles; mu, casino)

	# Convert integers back to alleles and modfiy original genePool:
	return genePool .= alleles.(mutatedGenePool)
end