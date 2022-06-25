function formatTimestamp(timestamp::DateTime)
	return Dates.format(timestamp, dateformat"yyyy_mm_dd__HH_MM_SS")
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
	# Save every plot of the given simulation:
	savePlots(simulation.plots, "simulation", simulation.timestamp)
end

function savePlots(comparison::GAComparison; withSimulationPlots=true)
	# Save every plot of the given comparison:
	savePlots(comparison.plots, "comparison", comparison.timestamp)

	# Save simulation plots if specified:
	if withSimulationPlots
		for simulation in comparison.simulations
			savePlots(simulation)
		end
	end
end

function saveData(dataFrames::Vector{DataFrames.DataFrame}, prefix::String, timestamp::DateTime, GAParameters) #df type (Vektor); timestamp?; rename parameters
	for	i in 1:length(dataFrames)
		collector = i == 1 ? "agent" : "model"
		# Construct a filename:
		filename = string(prefix, "_", formatTimestamp(timestamp), "_", GAParameters, collector, ".csv") # equalized vs normal

		# Save dataframe as .csv:
		CSV.write(filename, dataFrames[i])
	end
end

function saveData(simulation::GASimulation)
	# Save agent and model dataframe of the given simulation:
	saveData([simulation.agentDF, simulation.modelDF], "simulation", simulation.timestamp, simulation.algorithm)

end

function saveData(comparison::GAComparison)
	for i in 1:length(comparison)
		saveData(
			[comparsion.simulations[i].agentDF, comparsion.simulations[i].modelDF], 
			"simulation", 
			comparsion.simulations[i].timestamp, 
			comparsion.simulations[i].algorithm
		)
	end
end

#DataFrame(CSV.File(filename))