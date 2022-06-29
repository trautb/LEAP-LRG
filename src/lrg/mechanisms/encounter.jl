"""
encounter(fitness::AbstractVector)

This function takes all individuals and lets each one compete against another individual. 
The individual with the higher fitness will be a parent for the next generation. 
This will be done 2 times, so that the parent vector is twice the size as the individuals. 
That is because during recombination the amount of individuals will be cut in half again.

fitness: A vector containing the current fitness values of all individuals.
parents: A vector containing the indices of the individuals that won the tournament selection. 
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

        # Add the individuals and encounters who had a higher fitness than their opponent to the parents array
        parents[1 + (i-1)nIndividuals : nIndividuals*i] = vcat(individuals[individualWinners], encounters[encounterWinners])

    end

    return parents
end
