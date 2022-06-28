export savePlots

function formatTimestamp(timestamp::DateTime)
	return Dates.format(timestamp, dateformat"yyyy_mm_dd__HH_MM_SS")
end

function processSimulationData(agentDF::DataFrame)
	# Define an array of operations to perform on the simulation data:
	params = [
		:score => minimum => :minimum,
		:score => maximum => :maximum,
		:score => mean => :mean,
		:modifications => first => :modifications
	]

	# Perform the above operations for each simulation step:
	dataPerStep = groupby(agentDF, :step)
	processedDF = combine(dataPerStep, params...)

	# Return the processed simulation data:
	return processedDF
end

function generateSimulationPlots(simulation::GASimulation, processedDF::DataFrame)
	# Extract simulation parameters and results:
	simulationData = simulation.agentDF
	algorithm = simulation.algorithm
	
	# Return a dictionary with "plot_name" => "plot" pairs:
	return Dict{String, Plots.Plot}(
		#"scoreOT" => scoreOverTime(simulationData, algorithm),
		"scoreSpanOT" => scoreSpanOverTime(processedDF, algorithm),
		"topTierOT_5P" => topTierOverTime(simulationData, 5, algorithm),
		"topTierOT_1P" => topTierOverTime(simulationData, 1, algorithm),
		"allelicExpNumbOT" => allelicExpressionNumber(simulationData, algorithm)
	)
end

function savePlots(plots::Dict{String, Plots.Plot}, prefix::String, timestamp::DateTime)
	# Save all plots in the given dictionary to the current working directory:
	for (plotKey, plot) in pairs(plots)
		# Construct a filename:
		filename = string(prefix, "_", formatTimestamp(timestamp), "_", plotKey)

		# Save plot as pdf- and png-file:
		Plots.png(plot, filename)
		Plots.pdf(plot, filename)
	end
end

function savePlots(simulation::GASimulation)
	# Process simulation data:
	processedDF = processSimulationData(simulation.agentDF)

	# Generate plots for the given simulation:
	simulationPlots = generateSimulationPlots(simulation, processedDF)

	# Save every plot of the given simulation:
	savePlots(simulationPlots, "simulation", simulation.timestamp)
end

function savePlots(comparison::GAComparison; withSimulationPlots=true)
	# Process data of every simulation:
	processedData = Dict{GASimulation, DataFrame}(
		map(sim -> sim => processSimulationData(sim.agentDF), comparison.simulations)
	)
	
	# Generate plots for the given comparison:
	comparisonPlots = Dict{String, Plots.Plot}(
		"minimumOT" => compareMinimumScores(processedData)
	)

	# Save comparison plots:
	savePlots(comparisonPlots, "comparison", comparison.timestamp)

	# Save simulation plots if specified:
	if withSimulationPlots
		for (simulation, processedDF) in processedData
			savePlots(
				generateSimulationPlots(simulation, processedDF), 
				"simulation", 
				simulation.timestamp
			)
		end
	end
end

function saveData(dataFrame::DataFrames.DataFrame, prefix::String, timestamp::DateTime, content)
		# Construct a filename:
		filename = string(prefix, "_", formatTimestamp(timestamp), "_", content, ".csv") 

		# Save dataframe as .csv:
		CSV.write(filename, dataFrame)
end

function saveData(simulation::GASimulation)
	# Save agent and model dataframe of the given simulation:
	saveData(simulation.agentDF, "simulation", simulation.timestamp, simulation.algorithm)

end

function saveData(comparison::GAComparison)
	# Save agent and model dataframe of the given simulation
	for i in 1:length(comparison.simulations)
		saveData(comparison.simulations[i])
	end
	# Save runtimes
	saveData(comparison.runtimes, "comparison", Dates.now(), "runtimes")
end

#DataFrame(CSV.File(filename))