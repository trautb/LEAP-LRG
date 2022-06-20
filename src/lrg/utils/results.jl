struct GASimulation
	timestamp::DateTime
	algorithm::GeneticAlgorithm
	agentDF::DataFrame
	modelDF::DataFrame
	gaSpecificPlots::AbstractVector

	function GASimulation(
		algorithm::GeneticAlgorithm, 
		agentDF::DataFrame, 
		modelDF::DataFrame,
		gaSpecificPlots::AbstractVector
	)
		return new(Dates.now(), algorithm, agentDF, modelDF, gaSpecificPlots)
	end

	function GASimulation(
		algorithm::GeneticAlgorithm, 
		agentDF::DataFrame, 
		modelDF::DataFrame;
		seed = nothing
	)
		# Create ga-specific plots:
		gaSpecificPlots = [scoreOverTime(agentDF; seed=seed), scoreSpanOverTime(modelDF; seed=seed)]

		return GASimulation(algorithm, agentDF, modelDF, gaSpecificPlots)
	end
end

struct GAComparison
	timestamp::DateTime
	simulations::Vector{GASimulation}
	minimumPlot::Plots.Plot

	function GAComparison(
		simulations::Vector{GASimulation},
		minimumPlot::Plots.Plot
	)
		return new(Dates.now(), simulations, minimumPlot)
	end

	function GAComparison(
		simulations::Vector{GASimulation};
		seed = nothing
	)
		# Create a plot, that compares the minimum scores per step:
		minimumPlot = compareMinimumScores(simulations; seed=seed)

		return GAComparison(simulations, minimumPlot)
	end
end
	