"""
	encounter

This implementation of tournamentSelection expects a matrix of fitness values with the datatype 
float64
"""
function encounter(popFitness::AbstractVector)
    nPop = length(popFitness)
    parents = Array{Int64,1}(undef, 2 * nPop)

    for i in 1:2 * nPop 
        "Could be solved with sample function from StatsBase.jl"
        firstFighter = rand(1:nPop)
        secondFighter = rand(1:nPop)
        
        if popFitness[firstFighter] > popFitness[secondFighter]
            parents[i] = firstFighter
        else
            parents[i] = secondFighter
        end
    end
    return parents
end