

"""
encounter

This implementation of tournamentSelection expects a vector of fitness values and returns a vector double the size with the selected individuals.
The fitness of every individual gets compared to 4 different individuals. That way the parents vector is two times as big as the individuals vector.  
"""
function encounter(fitness::AbstractVector)

individualsFitness = fitness
nIndividuals = length(individualsFitness)
individuals = collect(1:nIndividuals)
parents = Vector{Int64}(undef,0)

for i in 1:2
    Random.shuffle!(individuals)

    encounters = circshift(individuals,1)
    individualWinners = individualsFitness[individuals] .> individualsFitness[encounters]
    encounterWinners = individualWinners .== 0

    # Append individuals and encounters who had a higher fitness than their opponent 
    append!(parents, individuals[individualWinners]) 
    append!(parents, encounters[encounterWinners])

end

return parents
end


"""
	encounter

This implementation of tournamentSelection expects a vector of fitness values and returns a vector double the size with the selected 

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
"""
