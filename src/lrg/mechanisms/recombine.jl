"""
	recombine

This function takes a matrix (individual * genome) and an Array of indices (of parents) as an input.
It recombines the genomes corresponding to the first 1:N indices (where N is the population size and length(parents) == 2N) 
with the genomes corresponding to the second half of the parents Array.
"""
function recombine(genpool::Matrix{T}, parents::AbstractVector) where {T <: Enum}
	# TODO: naming? nAlleles or nGenes ?
	nIndividuals, nAlleles = size(genpool)

	# random implementation:
	crossOverPnts = rand(1:nAlleles, nIndividuals)

	parentsLogicalMatrix = BitArray(y ≤ crossOverPnts[x] for x = 1:nIndividuals, y = 1:nAlleles)
	
	moms = parents[1:nIndividuals] .- 1
	dads = parents[nIndividuals + 1:end] .- 1

	# calculate indices of the (parental) genes
	indices = ((parentsLogicalMatrix .* moms .+ .!parentsLogicalMatrix .* dads) .* nAlleles) .+ collect(1:nAlleles)'
	
	newGenpool = transpose(genpool)[indices]
	return newGenpool
end