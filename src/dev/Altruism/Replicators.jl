#========================================================================================#
"""
	Replicators

Module Replicators: A model of an exponentially replicating population.

Author: Niall Palfreyman, 04/09/2022
"""
module Replicators

# Externally callable methods of Replicators:
export Replicator, run!

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

	#-------------------------------------------------------------------------------------
	# The one-and-only Replicator constructor: Create a replicator population starting
	# from time zero and stepping in time-steps dt to the maximum value tfinal.
	# Question 1: In this constructor, how do I prevent users of my Replicators module
	#	from having access to the default constructor Replicator(t,dt,x)?
	#	(Hint: Look up Inner Constructor Methods in the Julia manual)
	# Question 2: Why do I want to prevent users from having that access?
	#-------------------------------------------------------------------------------------
 	function Replicator( tfinal::Real, dt=1)
		t = 0.0:dt:tfinal
		new( t, dt, zeros(Float64,length(t)))
	end
end

#-----------------------------------------------------------------------------------------
# Module methods:
#-----------------------------------------------------------------------------------------
"""
	run!( replicator, x0, mu=1.0)

Simulate the exponential growth of a population starting from the value x0 with growth
constant mu.
"""
function run!( repl::Replicator, x0::Real, mu::Real=1)
	repl.x[1] = x0						# Set initial value
		
	dt2 = repl.dt/2									# dt2 is one half timestep
	for i in 2:length(repl.t)
		# Perform Runge-Kutta-2 step:
		x2 = repl.x[i-1] + mu*dt2*repl.x[i-1]		# Calculate x after dt2
		repl.x[i] = repl.x[i-1] + mu*repl.dt*x2		# Use x2 as better approximation
	end

	repl								# Return the Replicator
end

#-----------------------------------------------------------------------------------------
"""
	unittest()

Unit-test the Replicators module.
"""
function unittest()
	println("\n============ Unit test Replicators: ===============")
	println("An exponential population of replicators from t=0-5 generations:")
	repl = Replicator(5,1)
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