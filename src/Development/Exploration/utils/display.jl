"""
displayCompareMinimumScoresPlot(simulations::Vector{GASimulation})

This function takes in the simulation data of the compare function and plots the minimal scores per step for each simulation result.
This plot will then be displayed.
simulations: Vector that contains the results of every simulation
"""
function displayCompareMinimumScoresPlot(simulations::Vector{GASimulation})

    processedData = Dict{GASimulation, DataFrame}(
		map(sim -> sim => processSimulationData(sim.agentDF), simulations)
	)

    comparisonPlot = compareMinimumScores(processedData)

    display(comparisonPlot)
end
