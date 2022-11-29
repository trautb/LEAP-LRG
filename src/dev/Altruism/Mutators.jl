#========================================================================================#
"""
	Mutators

Module Mutators: A model of mutation and the quasi-species equation.

Author: Niall Palfreyman, 22/11/2022
"""
module Mutators

include( "../../Development/Altruism/Simplex.jl")

using GLMakie

#-----------------------------------------------------------------------------------------
# Module types:
#-----------------------------------------------------------------------------------------
"""
	Mutator

A Mutator represents the time-evolution of a quasi-species model with mutation and selection.
"""
struct Mutator
	Q::Matrix{Real}				# Mutation matrix
	r::Vector{Real}				# Vector of three type fitnesses
	resolution::Int				# Resolution of timescale
	t::Vector{Float64}			# Timescale
	x::Vector{Vector{Float64}}	# Time-series of three population types

	"""
		Mutator( Q, r)

	The one-and-only Mutator constructor: Create a Mutator population stepping from
	time zero to ngenerations (1000), using fitness values r.
	"""
 	function Mutator( Q::Matrix{Float64}, r::Vector{Float64}=[1.,1.,1.])
		ngenerations = 1000
		new(
			Q, r/sum(r), ngenerations,
			zeros(Float64,ngenerations+1),
			Vector{Vector{Float64}}(undef,ngenerations+1)
		)
	end
end

#-----------------------------------------------------------------------------------------
# Module methods:
#-----------------------------------------------------------------------------------------
"""
	plot3!( axis, mutator)

Display the simulation results in mutator as a simplex.
"""
function plot3!( axis::Axis, mut::Mutator)
	Simplex.plot3!( axis)			# Plot the axes
	Simplex.plot3!( axis, mut.x)	# Plot the trajectory
end

"""
	simulate!( mutator, x0, T)

Simulate the mutator dynamics for T ticks, starting from initial state x0.
"""
function simulate!( mut::Mutator, x0::Vector{Float64}, T::Real)
	dt = T/mut.resolution;			# Full time-step
	dt2 = dt/2;						# RK2 half time-step
	
	# Set up time scale and initial value of population:
	mut.t[:] = 0:dt:T
	mut.x[1] = x0 / sum(x0)
	
	# Calculate population trajectory:
	for step = 1:mut.resolution
		# Perform RK2 half-step:
		x  = mut.x[step]
		R  = mut.r' * x
		xh = x + dt2 * (mut.Q * (mut.r .* x) - R * x)

		# Perform RK2 full-step:
		R  = mut.r' * xh
		mut.x[step+1] = x + dt * (mut.Q * (mut.r .* xh) - R * xh)
	end
end

"""
	unittest()

Simulate cyclic mutation and selection dynamics of 3 population types.
"""
function unittest()
	println("\n============ Unit test Mutators: ===============")

	# Define cyclic mutation matrix (column sum = 1):
	Q = [
		0.9 0.0 0.1
		0.1 0.9 0.0
		0.0 0.1 0.9
	]

	# Set up plot:
	fig = Figure()
	ax1 = Axis(fig[1,1])
	ax2 = Axis(fig[2,1])
	
	mut = Mutator( Q)
	simulate!( mut, [10.,2.,1.], 100)
	plot3!(ax1,mut)

	mut = Mutator( Q, [1.,2.,3.])
	simulate!( mut, [10.,2.,1.], 100)
	plot3!(ax2,mut).parent
end

end		# ... of module Mutators