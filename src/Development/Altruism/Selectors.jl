#========================================================================================#
"""
	Selectors

Module Selectors: A model of super- and sublinear selection in a replicating population.

Author: Niall Palfreyman, 14/09/2022
"""
module Selectors

include( "Simplex.jl")

using GLMakie

#-----------------------------------------------------------------------------------------
# Module types:
#-----------------------------------------------------------------------------------------
"""
	Selector

A Selector represents the time-evolution of a sub- or super-linear selection model.
"""
struct Selector
	x::Vector{Real}			# The population time-series
end

#-----------------------------------------------------------------------------------------
# Module methods:
#-----------------------------------------------------------------------------------------
"""
	unittest()

Unit-test the Selectors module.
"""
function unittest()
	println("\n============ Unit test Selectors: ===============")

	Simplex.plot3([[1/6, 1/3, 1/2], [1/2, 1/6, 1/3]])
end

end		# ... of module Selectors