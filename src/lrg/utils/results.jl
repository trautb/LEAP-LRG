struct GASimulation
    timestamp::DateTime
    algorithm::GeneticAlgorithm
    agentDF::DataFrame
    modelDF::DataFrame

    function GASimulation(
        algorithm::GeneticAlgorithm, 
        agentDF::DataFrame, 
        modelDF::DataFrame
    )
        return new(Dates.now(), algorithm, agentDF, modelDF)
    end
end

struct GAComparison
    timestamp::DateTime
    simulations::Vector{GASimulation}
    runtimes::DataFrame

    function GAComparison(
        simulations::Vector{GASimulation},
        runtimes::DataFrame
    )
        return new(Dates.now(), simulations, runtimes)
    end
end