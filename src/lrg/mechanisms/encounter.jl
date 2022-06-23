"""
encounter

This implementation of tournamentSelection expects a vector of fitness values and returns a vector double the size with the selected individuals.
The fitness of every individual gets compared to 4 different individuals. That way the parents vector is two times as big as the individuals vector.
"""
function encounter(fitness::AbstractVector)

    individualsFitness = fitness
    nIndividuals = length(individualsFitness)
    individuals = collect(1:nIndividuals)
    parents = Vector{Int64}(undef,2nIndividuals)

    for i in 1:2
        Random.shuffle!(individuals)

        encounters = circshift(individuals,1)
        individualWinners = individualsFitness[individuals] .> individualsFitness[encounters]
        encounterWinners = individualWinners .== 0

        # Add individuals and encounters who had a higher fitness than their opponent to the parents array
        parents[1 + (i-1)nIndividuals : nIndividuals*i] = vcat(individuals[individualWinners], encounters[encounterWinners])

    end

    return parents
end
