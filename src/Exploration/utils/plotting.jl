"""
Set specific parameters for the given plot.
"""
function finalizePlot!(p::Plots.Plot)
	plot!(p,
		size = (1920, 1080), # Full-HD
		bottom_margin = 10Plots.mm,
		left_margin = 15Plots.mm,
	)

	return p
end

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
			legend = true
		)
	end

	# Annotate the plot:
	xlabel!("Number of Genome Modifications")
	ylabel!("Maximally Epistatic Function (Mepi)")
	title!("Minimum mepi-values for different algorithms over time")

	return finalizePlot!(minimumComparison)
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

	return finalizePlot!(plt)
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
		[processedDF[:, :maximum] processedDF[:, :mean] processedDF[:, :minimum]], 
		legend = true,
		labels = ["Maximum" "Mean" "Minimum"], 
		xlabel = "Step",
		ylabel = "Maximally Epistatic Function",
		title = repr(algorithm)
	)

	return finalizePlot!(plt)
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
	topTierDF = transform(
		topTierDF, :modifications => ByRow(m -> div(m - 1, div(mods, bins))) => :class
	)
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
		bar_width = mods/(2*bins)
	)

	return finalizePlot!(plt)
end
# -----------------------------------------------------------------------------------------
"""
	allelicExpressionNumber(agentDF::DataFrame, algorithm::GeneticAlgorithm) 

This function takes an agent dataframe and plots the mean value of the number of the different allelic expressions 
for every simulation steps.
"""
function allelicExpressionNumber(agentDF::DataFrame, algorithm::GeneticAlgorithm) 
	
	# Determine the mean value of the different allele expressions typical for each GA for each step:
	allelDistrDF = groupby(agentDF,:step)
	if any(names(allelDistrDF) .== "qMarks")
		allelDistrDF= combine(allelDistrDF, :ones => mean, :zeros => mean, :qMarks => mean)
		labels = ["1" "0" "?"]
	else
		allelDistrDF= combine(allelDistrDF, :ones => mean, :zeros => mean)
		labels = ["1" "0"]
	end

	# Create the plot:
	plt = plot(
		allelDistrDF[:,1],
		Matrix(allelDistrDF[:,2:end]), 
		title = repr(algorithm), 
		legend = true, 
		labels = labels,
		xlabel = "Number of steps",
		ylabel = "Mean of the number in the genome",
	)

	# Return the finalized plot:
	return finalizePlot!(plt)
end