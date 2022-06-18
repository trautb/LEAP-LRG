struct GASimulation
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
		return new(algorithm, agentDF, modelDF, gaSpecificPlots)
	end
end

struct GAComparison
	simulations::Vector{GASimulation}
	minimumPlot::Plots.Plot

	function GAComparison(
		simulations::Vector{GASimulation},
		minimumPlot::Plots.Plot
	)
		return new(simulations, minimumPlot)
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
	