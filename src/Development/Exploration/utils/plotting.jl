# =========================================================================================
### plotting.jl:
#	Provides various functions to visualize simulation results using the Plots.jl package
# =========================================================================================

"""
	finalizePlot!(p::Plots.Plot)

Set specific parameters for the given plot to make the output prettier.

**Arguments:**
- **p:** The plot, which should get finalized.

**Return:**   
- The plot, with specific parameters set.
"""
function finalizePlot!(p::Plots.Plot)
	plot!(p,
		size = (1920, 1080), 			# Full-HD
		bottom_margin = 10Plots.mm,		# Extra space at the bottom
		left_margin = 15Plots.mm,		# Extra space on the left
	)

	return p
end

# -----------------------------------------------------------------------------------------
"""
	compareMinimumScores(simulationData::Dict{GASimulation, DataFrame})

This function takes the results of various simulations and returns a plot, that compares the 
minimal scores per number of modifications for each simulation result. 

_Attention_: The DataFrames in `simulationData` have to be structured like the output of 
`processSimulationData(simulationDF::DataFrame)` in `save.jl`.

**Arguments:**
- **simulationData:** A dictionary of processedDFs for various simulations.

**Return:**
- The finalized, generated plot. (see also `finalizePlot!`) 
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

	# Return the finalized plot:
	return finalizePlot!(minimumComparison)
end

# -----------------------------------------------------------------------------------------
"""
	scoreOverTime(simulationDF::DataFrame, algorithm::GeneticAlgorithm)

This function takes the data of a simulation (``simulationDF``) and plots the score per step for every 
organism.

_Attention_: This function is very expensive for a large number of organisms and steps!

**Arguments:**
- **simulationDF:** The agent dataframe, that was returned by the simulation.
- **algorithm:** The algorithm, that was used for the simulation.

**Return:**
- The generated, finalized plot. (see also `finalizePlot!`)
"""
function scoreOverTime(simulationDF::DataFrame, algorithm::GeneticAlgorithm)
	# Transform the simulation data to get score of each organism per step:
	pltDF = unstack(simulationDF, :step, :organism, :score)

	# Create the plot. The plot contains a seperate line for each organism:
	plt = Plots.plot(
		Matrix(pltDF[:, Symbol.(unique!(sort!(simulationDF[:, :organism])))]),  # Select organisms only
		legend = false, 
		title = repr(algorithm)
	)

	# Return the finalized plot:
	return finalizePlot!(plt)
end

# -----------------------------------------------------------------------------------------
"""
	scoreSpanOverTime(processedDF::DataFrame, algorithm::GeneticAlgorithm)

This function takes a DataFrame of processed simulation data (``processedDF``) and plots and the 
maximum, minimum and mean score over time.

_Attention_: `processedDF` has to be a DataFrame structured like the output of 
`processSimulationData(simulationDF::DataFrame)` in `save.jl`.

**Arguments:** 
- **processedDF:** The DataFrame of processed simulation data.
- **algorithm:** The algorithm, which was used in the simulation.

**Return:**
- The finalized generated plot. (see also `finalizePlot!`)
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

	# Return the finalized plot:
	return finalizePlot!(plt)
end

# -----------------------------------------------------------------------------------------
"""
	topTierOverTime(
		simulationDF::DataFrame, 
		percentage::Number, 
		algorithm::GeneticAlgorithm;
		maxBins::Integer = 100
	)

This function takes the data of a simulation (``simulationDF``) and plots the number of organisms in 
range ``percentage`` around the best score ("top-tiers") for each number of modifications. If the 
number of steps taken from ``simulationDF`` is greater than ``maxBins``, the data has to be processed 
before plotting:

--> If the number of simulation steps is to high, the bar chart would become a black block, so 	
	the number of bins is restricted to ``maxBins``  
--> To keep the visualization consistent with the message of the data, each bin represents the 
	MEAN of the number of top-tiers in the range of modifications covered by the bin.
	
Example:  
=> bin 10 covers modifications 5-15 and t_i is the number of top-tiers after i modifications  
=> so the height of the bin is: mean(t_5 + t_6 + ... + t_15)  
=> and the bin is located over x-position mean(5 + 6 + ... + 14 + 15) = 10

**Arguments:**
- **simulationDF:** The agent dataframe, that was returned by the simulation.
- **percentage:** The maximum relative distance from the best score an individual is allowed to 	
				  have to still count as a top-tier.
- **algorithm:** The genetic algorithm used for the simulation
- **maxBins:** The maximum number of bins in the histogram

**Return:**
- The generated, finalized plot. (see also `finalizePlot!`)
"""
function topTierOverTime(
	simulationDF::DataFrame,
	percentage::Number, 
	algorithm::GeneticAlgorithm;
	maxBins::Integer = 100
)
	# Find the maximum number of steps and modifications:
	steps = maximum(simulationDF[!, :step])
	mods = maximum(simulationDF[!, :modifications])

	# Calculate the number of bins to disply in the plot:
	bins = steps < maxBins ? steps : maxBins

	# Define a function to determine the number of top-tiers in an array of scores:
	topTiers = scores -> sum(scores .< (minimum(scores) + minimum(scores) * (percentage/100))) 
	
	# Group the data per number of modification:
	topTierDF = groupby(simulationDF, :modifications)

	# Calculate the number of top-tiers for each number of modifications:
	topTierDF = combine(topTierDF, :score => topTiers => :topTiers)

	# Distribute the observations equally over <<bins>> classes:
	topTierDF = transform(
		topTierDF, :modifications => ByRow(m -> div(m - 1, div(mods, bins))) => :class
	)

	# Group the data by the previously defined classes:
	topTierDF = groupby(topTierDF, :class)

	# Calculate the mean top-tiers and mean modifications per class:
	topTierDF = combine(
		topTierDF, 
		:topTiers => mean => :meanTopTiers, 
		:modifications => mean => :meanMods
	)

	# Create the bar-plot:
	plt = Plots.bar(
		topTierDF[:, :meanMods],
		topTierDF[:, :meanTopTiers],
		legend = false, 
		title = repr(algorithm),
		xlabel = "Number of Genome Modifications",
		ylabel = string("Organisms in Top ", percentage, "% "),
		bar_width = mods/(2*bins)
	)

	# Return the finalized plot:
	return finalizePlot!(plt)
end
# -----------------------------------------------------------------------------------------
"""
	allelicExpressionNumber(simulationDF::DataFrame, algorithm::GeneticAlgorithm) 

This function takes the data of a simulation, evalates the mean number of diffenrent alleles 
at every step and plots them afterwards.

**Arguments:**
- **simulationDF:** The agent dataframe, that was returned by the simulation.
- **algorithm:** The genetic algorithm, which was used for the simulation.

**Return:**
- The generated, finalized plot (see also `finalizePlot!`).
"""
function allelicExpressionNumber(simulationDF::DataFrame, algorithm::GeneticAlgorithm) 
	
	# Determine the mean number of different alleles for each GA at each step:
	allelDistrDF = groupby(simulationDF,:step)
	if any(names(allelDistrDF) .== "qMarks")
		allelDistrDF= combine(allelDistrDF, :ones => mean, :zeros => mean, :qMarks => mean)
		labels = ["1" "0" "?"]
	else
		allelDistrDF= combine(allelDistrDF, :ones => mean, :zeros => mean)
		labels = ["1" "0"]
	end

	# Create a plot with 3 graphs, when the "qMarks" allele is present, and with 2 graphs otherwise:
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