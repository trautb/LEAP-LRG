struct GASimulation
	timestamp::DateTime
	algorithm::GeneticAlgorithm
	agentDF::DataFrame
	modelDF::DataFrame
	plots::Dict{String, Plots.Plot}

	function GASimulation(
		algorithm::GeneticAlgorithm, 
		agentDF::DataFrame, 
		modelDF::DataFrame,
		plots::Dict{String, Plots.Plot}
	)
		return new(Dates.now(), algorithm, agentDF, modelDF, plots)
	end

	function GASimulation(
		algorithm::GeneticAlgorithm, 
		agentDF::DataFrame, 
		modelDF::DataFrame;
		seed = nothing
	)
		# Create ga-specific plots:
		plots = Dict{String, Plots.Plot}(
			"scoresOT" => scoreOverTime(agentDF; seed=seed), 
			"scoreSpanOT" => scoreSpanOverTime(modelDF; seed=seed),
			"topTierOT_5P" => topTierOverTime(agentDF, modelDF, 5; seed=seed),
			"topTierOT_1P" => topTierOverTime(agentDF, modelDF, 1; seed=seed),
			"topTierOT_5e-1P" => topTierOverTime(agentDF, modelDF, 0.5; seed=seed)
		)

		return GASimulation(algorithm, agentDF, modelDF, plots)
	end
end

struct GAComparison
	timestamp::DateTime
	simulations::Vector{GASimulation}
	runtimes::TimerOutput
	plots::Dict{String, Plots.Plot}

	function GAComparison(
		simulations::Vector{GASimulation},
		runtimes::TimerOutput,
		plots::Dict{String, Plots.Plot}
	)
		return new(Dates.now(), simulations, runtimes, plots)
	end

	function GAComparison(
		simulations::Vector{GASimulation},
		runtimes::TimerOutput;
		seed = nothing
	)
		# Create plots to compare the submitted algorithms:	
		plots = Dict{String, Plots.Plot}(
			# Create a plot, that compares the minimum scores per step:
			"minimumOT" => compareMinimumScores(simulations; seed=seed)
		)

		return GAComparison(simulations, runtimes, plots)
	end
end
	