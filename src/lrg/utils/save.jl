# =========================================================================================
### save.jl: 
# Provides functions to save plots and dataframes of the simulation results
# =========================================================================================

export savePlots, saveData

"""
	formatTimestamp(timestamp::DateTime)

Format the timestamp format to yyyy_mm_dd__HH_MM_SS.
"""
function formatTimestamp(timestamp::DateTime)
	return Dates.format(timestamp, dateformat"yyyy_mm_dd__HH_MM_SS")
end
# -----------------------------------------------------------------------------------------
"""
	processSimulationData(agentDF::DataFrame)

Create a dataframe that contains the minimum, maximun, and mean of the score 
as well as the modifications for each step.
"""
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
# -----------------------------------------------------------------------------------------
"""
	generateSimulationPlots(simulation::GASimulation, processedDF::DataFrame)

Generate the desired simualtion plots of the simulation.
"""
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
# -----------------------------------------------------------------------------------------
"""
	savePlots(plots::Dict{String, Plots.Plot}, prefix::String, timestamp::DateTime)

Save all generated plots as .png and .pdf file with the constructed filename.
"""
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
"""
	savePlots(plots::Dict{String, Plots.Plot}, prefix::String, timestamp::DateTime)

Save the desired plots of the simulation.
"""
function savePlots(simulation::GASimulation)
	# Process simulation data:
	processedDF = processSimulationData(simulation.agentDF)

	# Generate plots for the given simulation:
	simulationPlots = generateSimulationPlots(simulation, processedDF)

	# Save every plot of the given simulation:
	savePlots(
		simulationPlots, 
		string("simulation_", paramstring(simulation.algorithm)), 
		simulation.timestamp
	)
end

"""
	savePlots(plots::Dict{String, Plots.Plot}, prefix::String, timestamp::DateTime)

Save a plot comparing the minimal scores per number of modifications for each simulation result 
and if wanted the desired plots of each simulation.
"""
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
				string("simulation_", paramstring(simulation.algorithm)), 
				simulation.timestamp
			)
		end
	end
end
# -----------------------------------------------------------------------------------------
"""
	saveData(dataFrame::DataFrames.DataFrame, prefix::String, timestamp::DateTime, content::String)

Save a dataframe as .csv file with the constructed filename.
"""
function saveData(dataFrame::DataFrame, prefix::String, timestamp::DateTime, content::String)
		# Construct a filename:
		filename = string(prefix, "_", formatTimestamp(timestamp), "_", content, ".csv") 

		# Save dataframe as .csv:
		CSV.write(filename, dataFrame)
end

"""
	saveData(simulation::GASimulation)

Save the dataframe including the results of each agent in the simulation.
"""
function saveData(simulation::GASimulation)
	# Save agent dataframe of the simulation:
	saveData(
		simulation.agentDF, 
		"simulation", 
		simulation.timestamp, 
		paramstring(simulation.algorithm)
	)

end

"""
	saveData(comparison::GAComparison)

Save the dataframes including the results of each agent in each simulation 
and the dataframe including the runtimes of each simulation.
"""
function saveData(comparison::GAComparison)
	# Save agent dataframe for each simulation:
	for i in 1:length(comparison.simulations)
		saveData(comparison.simulations[i])
	end

	# Save runtime dataframe:
	saveData(comparison.runtimes, "comparison", comparison.timestamp, "runtimes")
end