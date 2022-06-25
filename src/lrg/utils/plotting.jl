"""
	compareMinimumScores(simulationData::Dict{GASimulation, DataFrame})

This function takes the results of various simulations and returns a plot, that compares the 
minimal scores per step for each simulation result. 
"""
function compareMinimumScores(simulationData::Dict{GASimulation, DataFrame})
	# Initialize plot:
	minimumComparison = Plots.plot()

	# Plot the graph of minimal scores for each simulation:
	for (simulation, processedDF) in pairs(simulationData)
		plot!(
			minimumComparison,
			processedDF[:, :modifications],
			processedDF[:, :minimum], 
			label = repr(simulation.algorithm),
			legend = true, 
		)
	end

	# Annotate the plot:
	xlabel!("Number of Genome Modifications")
	ylabel!("Maximally Epistatic Function (Mepi)")
	title!("Minimum mepi-values for different algorithms over time")

	return minimumComparison
end

# -----------------------------------------------------------------------------------------
"""
	scoreOverTime(agentDF::DataFrame, algorithm::GeneticAlgorithm)

This function takes an agent dataframe and plots the score per step for every agent.
"""
function scoreOverTime(agentDF::DataFrame, algorithm::GeneticAlgorithm)
	pltDF = unstack(agentDF, :step, :organism, :score)

	plt = Plots.plot(
		Matrix(pltDF[:, Symbol.(unique!(sort!(agentDF[:, :organism])))]),  # Select organisms only
		legend = false, 
		title = repr(algorithm)
	)

	return plt
end

# -----------------------------------------------------------------------------------------
"""
	scoreSpanOverTime(modelDF::DataFrame, algorithm::GeneticAlgorithm)

This function takes an model dataframe and the maximum, minimum and mean score for every simulation 
step.
"""
function scoreSpanOverTime(processedDF::DataFrame, algorithm::GeneticAlgorithm)
	plt = Plots.plot(
		processedDF[:, :step],
		[processedDF[:, :mean] processedDF[:, :minimum] processedDF[:, :maximum]], 
		legend = true,
		labels = ["Mean" "Minimum" "Maximum"], 
		xlabel = "Step",
		ylabel = "Maximally Epistatic Function",
		title = repr(algorithm)
	)

	return plt
end

# -----------------------------------------------------------------------------------------
"""
	topTierOverTime(
		agentDF::DataFrame, 
		modelDF::DataFrame, 
		percentage::Number, 
		algorithm::GeneticAlgorithm
	)

This function takes an agent dataframe and plots number of agents in range percentage around the 
max score at that point of time.
"""
function topTierOverTime(
	agentDF::DataFrame, 
	processedDF::DataFrame, 
	percentage::Number, 
	algorithm::GeneticAlgorithm
)
	pltDF = unstack(agentDF, :modifications, :organism, :score)
	minima = processedDF[!, :minimum]
	scaledMinima = minima .+ minima .* (percentage/100)
	topTierIdx = pltDF[!, Symbol.(unique!(sort!(agentDF[:, :organism])))] .< scaledMinima
	topTierOrganisms = sum.(eachrow(topTierIdx))

	plt = Plots.bar(
		pltDF[:, :modifications],
		topTierOrganisms,
		legend = false, 
		title = repr(algorithm),
		xlabel = "Number of Genome Modifications",
		ylabel = string("Organisms in Top ", percentage, "% ")
	)

	return plt
end