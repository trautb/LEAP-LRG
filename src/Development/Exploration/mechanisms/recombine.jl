# =========================================================================================
### recombine.jl: Defines a function to recombine two genomes 
# =========================================================================================
"""
	recombine(genePool::Matrix{T}, parents::AbstractVector) where {T<:Enum}

This function takes a matrix (individual * genome) and an Array of indices (i.e. the 
parents) as an input.
It recombines the genomes corresponding to the first 1:N indices (where N is the population
size and length(parents) == 2N) with the genomes corresponding to the second half of the 
parents Array and returns a matrix of the next generation.

**Arguments:**
- **genePool:** Matrix containing the genome of every individual.
- **parents:** Vector conaining the indices of the individuals who got selected as parent.

**Return:**
- Next generation of individuals.
"""
function recombine(genePool::Matrix{T}, parents::AbstractVector) where {T<:Enum}
    nIndividuals, nGenes = size(genePool)

    crossOverPnts = rand(1:nGenes, nIndividuals)

    # create a matrix showing from which parent the allele should be taken
    parentsLogicalMatrix = BitArray(y ≤ crossOverPnts[x] for x = 1:nIndividuals, y = 1:nGenes)

    # divide the parents-vector in w halfs with |vector| = N
    moms = parents[1:nIndividuals] .- 1
    dads = parents[nIndividuals+1:end] .- 1

    # calculate indices of the (parental) genes 
    # (@see the Documentation for a more detailed exploration how this calculates the indices)
    indices = ((parentsLogicalMatrix .* moms .+ .!parentsLogicalMatrix .* dads) .* nGenes) .+ collect(1:nGenes)'

    # create the next generation by taking the alleles by their index,
    # transpose() needs to be applied here, so the indexing matches
    newGenePool = transpose(genePool)[indices]
    return newGenePool
end