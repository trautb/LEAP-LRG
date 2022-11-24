#========================================================================================#
"""
	Selectors

Module Selectors: A model of super- and sublinear selection in a population of three
replicating types.

Author: Niall Palfreyman, 16/11/2022
"""
module Selectors

include( "../../Development/Altruism/Simplex.jl")

using GLMakie

export Selector, simulate!, plot3!

#-----------------------------------------------------------------------------------------
# Module types:
#-----------------------------------------------------------------------------------------
"""
	Selector

A Selector represents the time-evolution of a sub- or super-linear selection model.
"""
struct Selector
	r::Vector{Real}				# Vector of three type fitnesses
	epsilon::Real				# Growth non-linearity (default 0)
	resolution::Int				# Resolution of timescale
	t::Vector{Float64}			# Timescale
	x::Vector{Vector{Float64}}	# Time-series of three population types

	"""
		Selector( r, epsilon)

	The one-and-only Selector constructor: Create a Selector population stepping from
	time zero to ngenerations (1000), using fitness values r and nonlinearity epsilon.
	"""
 	function Selector( r::Vector{Float64}, epsilon::Real=0.0)
		ngenerations = 1000
		new( r/sum(r), epsilon, ngenerations,
			zeros(Float64,ngenerations+1), Vector{Vector{Float64}}(undef,ngenerations+1))
	end
end

#-----------------------------------------------------------------------------------------
# Module methods:
#-----------------------------------------------------------------------------------------
"""
	plot3!( axis, selector)

Display the simulation results in selector as a simplex.
"""
function plot3!( axis::Axis, sel::Selector)
	Simplex.plot3!( axis)			# Plot the axes
	Simplex.plot3!( axis, sel.x)	# Plot the trajectory
end

"""
	simulate!( selector, x0, T)

Simulate the selector dynamics for T ticks, starting from initial state x0.
"""
function simulate!( sel::Selector, x0::Vector{Float64}, T::Real)
	dt = T/sel.resolution;			# Full time-step
	dt2 = dt/2;						# RK2 half time-step
	c = 1 + sel.epsilon;			# Nonlinear growth exponent
	
	# Set up time scale and initial value of population:
	sel.t[:] = 0:dt:T
	sel.x[1] = x0 / sum(x0)
	
	# Calculate population trajectory:
	for step = 1:sel.resolution
		# Perform RK2 half-step:
		xPc = sel.x[step].^c		# x[t] to the Power c
		R   = xPc' * sel.r
		xh  = sel.x[step] + dt2 * (xPc.*sel.r - R*sel.x[step])
		
		# Perform RK2 full-step:
		xPc = xh.^c					# xh to the Power c
		R   = xPc' * sel.r
		sel.x[step+1]  = sel.x[step] + dt2 * (xPc.*sel.r - R*xh)
	end
end

"""
	unittest()

Unit-test the Selectors module first with sublinear, then with superlinear selection.
"""
function unittest()
	println("\n============ Unit test Selectors: ===============")

	# Set up plot:
	fig = Figure()
	ax1 = Axis(fig[1,1])
	ax2 = Axis(fig[2,1])
	
	# Simulate sublinear selection dynamics of 3 population types:
	sel = Selector( [2.,4.,5.], -0.3)
	simulate!( sel, [10.,2.,1.], 100)
	plot3!(ax1,sel)

	# Simulate superlinear selection dynamics of 3 population types:
	sel = Selector( [5.,4.,2.], +0.3)
	simulate!( sel, [3.,3.,4.], 100)
	plot3!(ax2,sel).parent
end

end		# ... of module Selectors