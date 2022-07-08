"""
    displayCompareMinimumScoresPlot(simulations::Vector{GASimulation})

This function takes in the simulation data of the compare function and plots the minimal/best scores per step for each simulation result.
This plot will then be displayed.

**Arguments:**
- **simulations:** Vector containing the results of the simulations.

**Return:**
- Nothing
"""
function displayCompareMinimumScoresPlot(simulations::Vector{GASimulation})

    processedData = Dict{GASimulation, DataFrame}(
		map(sim -> sim => processSimulationData(sim.simulationDF), simulations)
	)

    comparisonPlot = compareMinimumScores(processedData)

    display(comparisonPlot)
    return
end
