module DataAnalysis

export loadSimulationData, allelicExpressionNumber, compareMinimumScores

using CSV
using DataFrames
using Statistics
using Plots

include("GAs.jl")
using .GAs

function getIndicesOfPattern(pattern::String, text::String) 
	return filter(
		idx -> idx !== nothing, 
		unique(map(
			m -> m !== nothing ? m.offset : nothing, 
			match.(Regex(pattern), text, 1:length(text))
		))
	)
end

function getParameterValue(paramstring::String, param::String)
	paramIndices = getIndicesOfPattern(param, paramstring) # Should have length 1
	paramIdx = length(paramIndices) > 0 ? first(paramIndices) : nothing
	
	if paramIdx === nothing
		return nothing
	end

	valueStartIdx = paramIdx + length(param)
	valueEndMatch = match(r"--", paramstring, valueStartIdx)
	if valueEndMatch !== nothing
		valueEndIdx = valueEndMatch.offset - 1
	else
		valueEndIdx = length(paramstring)
	end
	valueString = underscoreToPoint(paramstring[valueStartIdx:valueEndIdx])
	
	if occursin(r"true", valueString)
		value = true
	elseif occursin(r"false", valueString)
		value = false
	elseif occursin(r"\.", valueString)
		value = parse(Float64, valueString)
	else 
		value = parse(Int64, valueString)
	end

	return value
end

function underscoreToPoint(s::String)
	return replace(s, "_" => ".")
end

function paramstringToBGA(paramstring::String)
	nIndividuals = getParameterValue(paramstring, "nIndividuals-")
	nGenes = getParameterValue(paramstring, "nGenes-")
	mu = getParameterValue(paramstring, "mu-")
	useHaystack = getParameterValue(paramstring, "useHN-")

	return BasicGA(nIndividuals, nGenes, mu, useHaystack)
end

function paramstringToEGA(paramstring::String) 
	nIndividuals = getParameterValue(paramstring, "nIndividuals-")
	nGenes = getParameterValue(paramstring, "nGenes-")
	mu = getParameterValue(paramstring, "mu-")
	useHaystack = getParameterValue(paramstring, "useHN-")
	nTrials = getParameterValue(paramstring, "nTrials-")

	return ExploratoryGA(nIndividuals, nGenes, mu, useHaystack, nTrials)
end

function paramstringToGA(paramstring::String)
	if occursin(r"BasicGA", paramstring)
		return paramstringToBGA(paramstring)
	elseif occursin(r"ExploratoryGA", paramstring)
		return paramstringToEGA(paramstring)
	end
end

function loadSimulationData(csvFile::String)
	return loadSimulationData(
		csvFile, paramstringToGA(csvFile[begin:match(r"\.", csvFile).offset - 1])
	)
end

function loadSimulationData(csvFile::String, algorithm::GAs.GeneticAlgorithm)
	if !isfile(csvFile)
		@warn "Given filename is no valid file!"
		return DataFrame()
	elseif !occursin(r"\.csv", csvFile)
		@warn "Given file is no .csv file!"
		return DataFrame()
	end

	return GAs.GASimulation(algorithm, CSV.read(csvFile, DataFrame))
end

# ==========================================================================================
# Helpers:
function name(algorithm::BasicGA)
	return "BasicGA"
end

function name(algorithm::ExploratoryGA)
	return "ExploratoryGA"
end

function objective(algorithm::BasicGA)
	return algorithm.useHaystack ? "Haystack" : "Mepi"
end

function objective(algorithm::ExploratoryGA)
	return algorithm.useHaystack ? "Haystack" : "Mepi"
end

function complexity(algorithm::BasicGA)
	return algorithm.nGenes
end

function complexity(algorithm::ExploratoryGA)
	return algorithm.nGenes
end

function processSimulationData(simulationDF::DataFrame)
	return GAs.processSimulationData(simulationDF)
end

# ==========================================================================================
# Plots
function generateTitle(algorithm::GAs.GeneticAlgorithm, includeName=true)
	gaComplexity = string("Genome Length ", complexity(algorithm))

	return includeName ? name(algorithm) * " - " * gaComplexity : gaComplexity
end

function generateLabel(algorithm::GAs.GeneticAlgorithm, includeName=true)
	return includeName ? name(algorithm) : nothing
end

function finalizePlot!(p::Plots.Plot)
	plot!(p,
		size = (1920, 1080), 			# Full-HD
		bottom_margin = 10Plots.mm,		# Extra space at the bottom
		left_margin = 15Plots.mm,		# Extra space on the left
	)

	return p
end


function allelicExpressionNumber(simulationDF::DataFrame, algorithm::GAs.GeneticAlgorithm) 
	# Determine the mean number of different alleles for each GA at each step:
	allelDistrDF = groupby(simulationDF, :modifications)
	if any(names(allelDistrDF) .== "qMarks")
		allelDistrDF= combine(allelDistrDF, :ones => mean, :zeros => mean, :qMarks => mean)
		labels = ["1" "0" "?"]
	else
		allelDistrDF= combine(allelDistrDF, :ones => mean, :zeros => mean)
		labels = ["1" "0"]
	end

	# Create a plot with 3 graphs, when the "qMarks" allele is present, and with 2 graphs otherwise:
	plt = plot(
		allelDistrDF[:,:modifications], 
		Matrix(allelDistrDF[:, Not(:modifications)]), 
		title = generateTitle(algorithm),
		titlefont = font(20), 
		legend = true, 
		labels = labels,
		xlabel = "Number of Genome Evaluations",
		ylabel = "Sum of allele occurances across all Individuals",
	)

	# Return the finalized plot:
	return finalizePlot!(plt)
end

function compareMinimumScores(simulationData::Vector{GAs.GASimulation}, refGA::GAs.GeneticAlgorithm; asSubplot=false)
	# Initialize plot:
	minimumComparison = Plots.plot(titlefont=font(20))

	# Plot the graph of minimal scores for each simulation:
	for simulation in simulationData
		processedDF = processSimulationData(simulation.simulationDF)
		plot!(
			minimumComparison,
			processedDF[:, :modifications],
			processedDF[:, :minimum], 
			label = generateLabel(simulation.algorithm, asSubplot),
			legend = !asSubplot
		)
	end

	# Annotate the plot:
	xlabel!("Number of Genome Evaluations")
	ylabel!(objective(refGA))
	title!("Minimum " * objective(refGA) * " values for " * generateTitle(refGA, asSubplot))

	# Return the finalized plot:
	return finalizePlot!(minimumComparison)
end

end # ... of module