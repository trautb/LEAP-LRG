#========================================================================================#
"""
	Interactors

Module Interactors: A model of species interacting according to varying strategies.

Author: Niall Palfreyman, 29/11/2022
"""
module Interactors

include( "../../Development/Altruism/Simplex.jl")

using GLMakie

#-----------------------------------------------------------------------------------------
# Module types:
#-----------------------------------------------------------------------------------------
"""
	Interactor

A simulation of non-linear game-selection dynamics of 3 population types.
"""
struct Interactor
	A::Matrix{Real}				# Interaction game payoff matrix
	resolution::Int				# Resolution of timescale
	t::Vector{Float64}			# Timescale
	x::Vector{Vector{Float64}}	# Time-series of three population types

	"""
		Interactor( r, epsilon)

	The one-and-only Interactor constructor: Create an Interactor population stepping from
	time zero to ngenerations (1000), using payoff matrix A.
	"""
 	function Interactor( A::Matrix{Float64})
		ngenerations = 1000
		new(
			A, ngenerations,
			zeros(Float64,ngenerations+1),
			Vector{Vector{Float64}}(undef,ngenerations+1)
		)
	end
end

#-----------------------------------------------------------------------------------------
# Module methods:
#-----------------------------------------------------------------------------------------
"""
	plot3!( axis, Interactor)

Display the simulation results in Interactor as a simplex.
"""
function plot3!( axis::Axis, intrctr::Interactor)
	Simplex.plot3!( axis)				# Plot the axes
	Simplex.plot3!( axis, intrctr.x)	# Plot the trajectory
end

"""
	simulate!( Interactor, x0, T)

Simulate the Interactor dynamics for T ticks, starting from initial state x0.
"""
function simulate!( intrctr::Interactor, x0::Vector{Float64}, T::Real)
	dt = T/intrctr.resolution;		# Full time-step
	dt2 = dt/2;						# RK2 half time-step
	
	# Set up time scale and initial value of population:
	intrctr.t[:] = 0:dt:T
	intrctr.x[1] = x0 / sum(x0)
	
	# Calculate population trajectory:
	for step = 1:intrctr.resolution
		# Perform RK2 half-step:
		x  = intrctr.x[step]
		R  = x' * intrctr.A * x
		xh = x + dt2 * x .* (intrctr.A*x .- R)

		# Perform RK2 full-step:
		R  = xh' * intrctr.A * xh
		intrctr.x[step+1] = x + dt * xh .* (intrctr.A*xh .- R)
	end
end

"""
	unittest()

Use replicator dynamics to simulate cyclic dominance in 3 rock-scissors-paper population types.
"""
function unittest()
	println("\n============ Unit test Interactors: ===============")

	# Define RSP payoff matrix:
	Arsp = [
			 0  1 -1
			-1  0  1
			 1 -1  0
		]

	# Define lizard payoff matrix:
	Aliz = [
			4 2 1
			3 1 3
			5 0 2
		]

	# Set up plot:
	fig = Figure()
	ax1 = Axis(fig[1,1])
	ax2 = Axis(fig[1,2])
	
	# RSP:
	intrctr = Interactor( Float64.(Arsp))
	simulate!( intrctr, [20.,10.,1.], 15)
	plot3!(ax1,intrctr)
	
	# Lizard:
	intrctr = Interactor( Float64.(Aliz))
	simulate!( intrctr, [20.,10.,1.], 15)
	plot3!(ax2,intrctr).parent
end

end		# ... of module Interactors