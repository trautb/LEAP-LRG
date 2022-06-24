struct GASimulation
    timestamp::DateTime
    algorithm::GeneticAlgorithm
    agentDF::DataFrame

    function GASimulation(
        algorithm::GeneticAlgorithm, 
        agentDF::DataFrame, 
    )
        return new(Dates.now(), algorithm, agentDF)
    end

    function GASimulation(
        algorithm::GeneticAlgorithm, 
        agentDF::DataFrame;
    )

        return GASimulation(algorithm, agentDF)
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
	