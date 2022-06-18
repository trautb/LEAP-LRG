"""
	compareMinimumScores(simulationData::Vector{SimulationResults})

This function takes the results of various simulations and returns a plot, that compares the 
minimal scores per step for each simulation result. 
"""
function compareMinimumScores(simulations::Vector{GASimulation}; seed=nothing)
	# Initialize plot:
	minimumComparison = Plots.plot()

	# Plot the graph of minimal scores for each simulation:
	for simulation in simulations
		modelDF = simulation.modelDF
		plot!(
			minimumComparison,
			modelDF[2:end, :step],
			modelDF[2:end, :minimum], 
			label = repr(simulation.algorithm),
			legend = true, 
		)
	end

	# Annotate the plot:
	xlabel!("Step")
	ylabel!("Maximally Epistatic Function")
	title!(string("Seed: ", repr(seed)))

	return minimumComparison
end

# -----------------------------------------------------------------------------------------
"""
	scoreOverTime(agentDF::DataFrame, range::Integer; seed=nothing)

This function takes an agent dataframe and plots the score per step for every agent.
"""
function scoreOverTime(agentDF::DataFrame, range::Integer; seed=nothing)
	pltDF = unstack(agentDF, :step, :id, :mepi)

	plt = Plots.plot(
		Matrix(pltDF[2:end, 2:range]),  # Exclude initialization-row
		legend = false, 
		title = string("Seed: ", repr(seed))
	)

	return plt
end

# -----------------------------------------------------------------------------------------
"""
	scoreSpanOverTime(modelDF::DataFrame; seed=nothing)

This function takes an model dataframe and the maximum, minimum and mean score for every simulation 
step.
"""
function scoreSpanOverTime(modelDF::DataFrame; seed=nothing)
	plt = Plots.plot(
		modelDF[2:end, :step],
		[modelDF[2:end, :mean] modelDF[2:end, :minimum] modelDF[2:end, :maximum]], 
		legend = true,
		labels = ["Mean" "Minimum" "Maximum"], 
		xlabel = "Step",
		ylabel = "Maximally Epistatic Function",
		title = string("Seed: ", repr(seed))
	)

	return plt
end