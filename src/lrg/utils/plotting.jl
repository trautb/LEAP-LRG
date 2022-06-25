"""
Globally used plot size
"""
global gPlotSize = () -> (1920, 1080) # Full-HD

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
			size = gPlotSize()
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
		title = repr(algorithm), 
		size = gPlotSize()
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
		title = repr(algorithm), 
		size = gPlotSize()
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
	percentage::Number, 
	algorithm::GeneticAlgorithm;
	maxBins::Integer = 100
)
	steps = maximum(agentDF[!, :step])
	mods = maximum(agentDF[!, :modifications])
	bins = steps < maxBins ? steps : maxBins
	topTiers = scores -> sum(scores .< (minimum(scores) + minimum(scores) * (percentage/100))) 
	
	topTierDF = groupby(agentDF, :modifications)
	topTierDF = combine(topTierDF, :score => topTiers => :topTiers)
	topTierDF = transform(topTierDF, :modifications => ByRow(m -> div(m - 1, bins)) => :class)
	topTierDF = groupby(topTierDF, :class)
	topTierDF = combine(
		topTierDF, 
		:topTiers => mean => :meanTopTiers, 
		:modifications => mean => :meanMods
	)

	plt = Plots.bar(
		topTierDF[:, :meanMods],
		topTierDF[:, :meanTopTiers],
		legend = false, 
		title = repr(algorithm),
		xlabel = "Number of Genome Modifications",
		ylabel = string("Organisms in Top ", percentage, "% "),
		bar_width = mods/(2*bins), 
		size = gPlotSize()
	)

	return plt
end