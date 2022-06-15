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
	
	newGenpool = transpose(genpool)[indices]
	return newGenpool
end