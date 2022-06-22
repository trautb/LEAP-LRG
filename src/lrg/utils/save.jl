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