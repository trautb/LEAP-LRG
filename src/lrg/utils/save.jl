function formatTimestamp(timestamp::DateTime)
	return Dates.format(timestamp, dateformat"yyyy_mm_dd__HH_MM_SS")
end

function savePlots(simulation::GASimulation)
	# Save every plot of the given simulation:
	for i in 1:length(simulation.gaSpecificPlots)
		# Construct a (usually unique) filename:
		timestamp = formatTimestamp(simulation.timestamp)
		filename = string("simulation_", timestamp, "_plot_", i)

		# Get next plot:
		plt = simulation.gaSpecificPlots[i]

		# Save plot as pdf- and png-file:
		Plots.png(plt, filename)
		Plots.pdf(plt, filename)
	end
end

function savePlots(comparison::GAComparison; withSimulationPlots=true)
	# Construct a (usually unique) filename:
	timestamp = formatTimestamp(comparison.timestamp)
	filename = string("comparison_", timestamp, "_minimumPlot")

	# Save plots as pdf- and png-file:
	Plots.png(comparison.minimumPlot, filename)
	Plots.pdf(comparison.minimumPlot, filename)

	# Save simulation plots if specified:
	if withSimulationPlots
		for simulation in comparison.simulations
			savePlots(simulation)
		end
	end
end