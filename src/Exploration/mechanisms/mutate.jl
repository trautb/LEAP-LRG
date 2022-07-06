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

# -----------------------------------------------------------------------------------------
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