# =========================================================================================
### save.jl: 
# Provides functions to save plots and dataframes of the simulation results
# =========================================================================================

export savePlots, saveData

"""
	formatTimestamp(timestamp::DateTime)

Format the timestamp to match the pattern `yyyy_mm_dd__HH_MM_SS`.

**Arguments:**
- **timestamp:** One DateTime value. 

**Return:**
- Formatted timestamp.
"""
function formatTimestamp(timestamp::DateTime)
	return Dates.format(timestamp, dateformat"yyyy_mm_dd__HH_MM_SS")
end
# -----------------------------------------------------------------------------------------
"""
	processSimulationData(simulationDF::DataFrame)

Create a dataframe that contains the minimum, maximun, and mean of the score 
as well as the modifications for each step.

**Arguments:**
- **simulationDF:** DataFrame containing the simulation data for every individual. 
	
**Return:**
	- DataFrame containing the minimum, maximum and mean values for the entirety of individuals at every step. 
"""
function processSimulationData(simulationDF::DataFrame)
	# Define an array of operations to perform on the simulation data:
	params = [
		:score => minimum => :minimum,
		:score => maximum => :maximum,
		:score => mean => :mean,
		:modifications => first => :modifications
	]

	# Perform the above operations for each simulation step:
	dataPerStep = groupby(simulationDF, :step)
	processedDF = combine(dataPerStep, params...)

	# Return the processed simulation data:
	return processedDF
end
# -----------------------------------------------------------------------------------------
"""
	generateSimulationPlots(simulation::GASimulation, processedDF::DataFrame)

Generate the desired simualtion plots of the simulation.

**Arguments:**
- **simulation:** The result of one simulation.
- **processedDF:** DataFrame processed by processSimulationData().  
	
**Return:**
- Dictionary containing all plots that get created using the simulation and processedDF parameters.
"""
function generateSimulationPlots(simulation::GASimulation, processedDF::DataFrame)
	# Extract simulation parameters and results:
	simulationData = simulation.simulationDF
	algorithm = simulation.algorithm
	
	# Return a dictionary with "plot_name" => "plot" pairs:
	return Dict{String, Plots.Plot}(
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
	savePlots(simulation::GASimulation)

Save the desired plots of the simulation.
"""
function savePlots(simulation::GASimulation)
	# Process simulation data:
	processedDF = processSimulationData(simulation.simulationDF)

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
and the desired plots of each simulation, if specified.

**Arguments:**
- **comparison:** Contains the results multiple genetic algorithm simulations.
- **withSimulationPlots:** Switch that will decide if only comparisonPlots or also simulationPlots will be plotted and saved. 

**Return:**
- Nothing
"""
function savePlots(comparison::GAComparison; withSimulationPlots=true)
	# Process data of every simulation:
	processedData = Dict{GASimulation, DataFrame}(
		map(sim -> sim => processSimulationData(sim.simulationDF), comparison.simulations)
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
	return
end
# -----------------------------------------------------------------------------------------
"""
	saveData(dataFrame::DataFrame, prefix::String, timestamp::DateTime, content::String)

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

Save the dataframe containing the results of each agent in the simulation.
"""
function saveData(simulation::GASimulation)
	# Save agent dataframe of the simulation:
	saveData(
		simulation.simulationDF, 
		"simulation", 
		simulation.timestamp, 
		paramstring(simulation.algorithm)
	)

end

"""
	saveData(comparison::GAComparison)

Save the dataframes containing the results of each agent in each simulation 
and the dataframe containing the runtimes of each simulation.

**Arguments:**
- **comparison:** Contains the results multiple genetic algorithm simulations.

**Return:**
- Nothing
"""
function saveData(comparison::GAComparison)
	# Save agent dataframe for each simulation:
	for i in 1:length(comparison.simulations)
		saveData(comparison.simulations[i])
	end

	# Save runtimes
	saveData(comparison.runtimes, "comparison", comparison.timestamp, "runtimes")
	return
end