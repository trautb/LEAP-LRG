#========================================================================================#
"""
	Replicators

Module Replicators: A model of an exponentially replicating population.

Author: Niall Palfreyman, 04/09/2022
"""
module Replicators

# Externally callable methods of Replicators:

#-----------------------------------------------------------------------------------------
# Module types:
#-----------------------------------------------------------------------------------------
"""
	Replicator

A Replicator represents a timescale t in timesteps dt, and a corresponding time-series x
over this timescale. The initial time-series consists solely of zeros.
"""
struct Replicator
	t::Vector{Real}			# The simulation timescale
	dt::Real				# The simulation time-step
	x::Vector{Real}			# The population time-series
end

#-----------------------------------------------------------------------------------------
# Module methods:
#-----------------------------------------------------------------------------------------

#-----------------------------------------------------------------------------------------
"""
	unittest()

Unit-test the Replicators module.
"""
function unittest()
	println("\n============ Unit test Replicators: ===============")
	println("An exponential population of replicators from t=0-5 generations:")
	repl = Replicator( [0,1], 1, [0,1])
	display( repl)
	println()

	println("Run population with initial size x0=1 and growth constant mu=1:")
	run!(repl,1)
	display( repl)
	println()

	println("Run population with initial size x0=1 and growth constant mu=2:")
	display( run!(repl,1,2))
	println()

	println("Run population with initial size x0=3 and growth constant mu=1:")
	display( run!(repl,3))
	println()
end

end		# ... of module Replicators