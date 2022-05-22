#= ====================================================================================== =#
"""
    Selections

A collection of functions for selecting individuals.

Authors: Alina Arneth, Michael Staab, Benedikt Traut, Adrian Wild 2022.
"""
module Selections

export Selection # , DummySelection, performSelection

"""
    Selection

A Selection encapsulates the ability of GAs to select individuals (depending on their fitness)
for matings. 
A Selection represents a function of R^x^y -> R^x^y. 
(Vector{Vector{Allele}} -> Vector{Vector{Allele}})
"""
abstract type Selection end

struct TournamentSelection <: Selection

end

"""
    One Implementation:

The selection operation is implemented as a tournament selection. 
In this case, we select a few individuals (tournament size) at random in the population. 
Then, the tournament takes place : with the probability ptour, the best individual from the sampled population is selected. 
Otherwise, we discard it and continue the tournament with the remaining individuals.
"""
function selectIndividual(tournamentSize::Int64, ptour::Float64, pop::Array{Individual,1})
    selected = Individual(0, 0, [], [], Inf)
    fitnesses = Array{Float64}(tournamentSize)
    subPop = sample(pop, tournamentSize, replace=true)
    for j in 1:tournamentSize
        fitnesses[j] = subPop[j].fitness
    end
    notSelected = true
    while notSelected
        mxval, mxindx = findmin(fitnesses)
        if rand(Float64) < ptour
            notSelected = false
            selected = subPop[mxindx]
        elseif length(fitnesses) == 1
            selected = subPop[mxindx]
        else
            deleteat!(fitnesses, mxindx)
        end
    end
    return(selected)
end

"""
When we want to select multiple individuals, we simply loop until the desired amount is samled.
"""
function selectIndividuals(nInd::Int64, 
        tournamentSize::Int64, 
        ptour::Float64, 
        pop::Array{Individual,1}
    )
    selected = Array{Individual,1}(nInd)
    for i in 1:nInd
        selected[i] = selectIndividual(tournamentSize, ptour, pop)
    end
    return(selected)
end

"Very basic way to implement tournamentSelection"
function tournamentSelection(pop::Array{Individual,1})
    parents = []
    nPop = length(pop)
    children = Array{Individual}(nPop)
    parent = Array{Individual}(2)
    for i in 1:nPop
        for j in 1:2
            "Could be solved with sample function from StatsBase.jl"
            fighter1 = pop[rand(1:nPop)]
            fighter2 = pop[rand(1:nPop)]
            if fighter1.fitness > fighter2.fitness
                parent[j] = fighter1
            else
                parent[j] = fighter2
            end
        end
        children[i] = recombination(parent[1], parent[2])
    end
end



"""
    This implementation of tournamentSelection expects a matrix of fitness values with the datatype float64

"""
function performSelection(popFitness::Array, selection::TournamentSelection)
    nPop = length(popFitness)
    parents = Array(2*nPop)

    for i in 1:2*nPop
        
        "Could be solved with sample function from StatsBase.jl"
        firstFigther = rand(1:nPop)
        secondFighter = rand(1:nPop)
        
        if popFitness[firstFigher] > popFitness[secondFigher]
            parents[i] = firstFighter
        else
            parents[i] = secondFighter
        end
    end
    return parents
end


# # -----------------------------------------------------------------------------------------
# # Debugging- & testing-stuff
# """
#     DummySelection

# Dummy Selection, does nothing.
# """
# struct DummySelection <: Selection end
# function select(selection::DummySelection; kwargs...) end

end # of module Selections