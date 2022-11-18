#========================================================================================#
"""
	LVs - Version 4

A system of two interacting predator-prey species.

Version 3 suffered from the deficiency that the RK-2 step needed to duplicate the code that
defines the right-hand side of the LV differential equations:

	dx/dt = f(x,y)
	dy/dt = g(x,y)

This duplication has two problems: it can lead to incorrect code if I change one copy without
changing the other; and it doubles the amount of effort if I want to extend this model to a
more complex one involving more differential equations.

For these reasons, in version 4 I store these functions as an additional member of the LV type.
Notice that this necessitates writing a constructor for the LV type that assigns the correct
functions.

Author: Niall Palfreyman, 11/06/2022.
"""
module LVs

using GLMakie

#-----------------------------------------------------------------------------------------
# Module types:
#-----------------------------------------------------------------------------------------
"""
	LV

A Lotka-Volterra system containing two species interacting with each other.
"""
struct LV
	r1::Float64								# Reproduction rate of species x
	k1::Float64								# Carrying capacity of species x
	r2::Float64								# Reproduction rate of species y
	k2::Float64								# Carrying capacity of species y
	rhs::Function							# Vector function incorporating all RHS functions

	function LV(r1,k1,r2,k2)
		new(
			r1, k1, r2, k2,
			x -> [							# The 2-d right-hand side vector function
				 r1 * x[1] * (1 - x[2]/k2),
				-r2 * x[2] * (1 - x[1]/k1)
			]
		)
	end
end

#-----------------------------------------------------------------------------------------
# Module methods:
#-----------------------------------------------------------------------------------------
"""
	run( lv::LV)

Run a simulation of the given LV system over the time-duration nsteps * dt.
"""
function run( lv::LV, x0::Float64, y0::Float64, dt::Float64=0.1, nsteps::Int=2000)
	t = 0 : dt : nsteps*dt
	x = [[0.0,0.0] for _ in 1:length(t)]

	# Initialisation:
	x[1] = [x0,y0]

	for n = 1:nsteps
		# Perform a single Runge-Kutta-2 integration step:
		x[n+1] = rk2( lv, x[n], dt)
	end

	(t,x)
end

"""
	rk2( lv::LV, x::Vector{Float64}, dt::Float64)

Based on the current state x, perform a single Runge-Kutta-2 integration step of length
dt, based on the parameters and rhs functions of the Lotka-Volterra model lv.
"""
function rk2( lv::LV, x::Vector{Float64}, dt::Float64)
	x_half = x + (dt/2) * lv.rhs(x)			# Perform the RK2 half-step
	return x + dt * lv.rhs(x_half)			# Perform the complete RK2 step
end

#-----------------------------------------------------------------------------------------
"""
	visualise( t, x)

Visualise the run data (t,x) on the screen as a simple GLMakie plot.
"""
function visualise( t, x)
	# Prepare the graphics axes:
	fig = Figure(resolution=(1200, 600))
	ax = Axis(fig[1, 1], xlabel = "t", ylabel = "x", title = "Predator-prey system")

	prey = map( v->v[1],x)
	pred = map( v->v[2],x)
	maxvertical = 1.1max( findmax(prey)[1], findmax(pred)[1])
	limits!(ax, 0, t[end], 0, maxvertical)

	# Plot two curves of x against t:
	lines!( ax, t, prey, linewidth = 5, color = :blue)
	lines!( ax, t, pred, linewidth = 5, color = :red)

	# Insert some explanatory text:
	text!( "This is a simple Predator-prey system",
		position=(20,round(0.95maxvertical)), textsize=30, align=(:left,:center)
	)

	# Display the results:
	display(fig)
end

#-----------------------------------------------------------------------------------------
"""
	demo()

This use-case method describes everything I want to do in the final program: Demonstrate
simulation of a simple 2-species Lotka-Volterra system in a simple 3-step use-case.
"""
function demo()
	# Build the Lotka-Volterra system:
	lv = LV( 0.05, 1000, 0.1, 100)						# A simple rabbit-lynx system
	
	# Calculate the simulation data with initial conditions 200 rabbits and 50 lynx:
	(t,x) = run( lv, 200.0, 50.0)

	# Run the animation:
	visualise( t, x)
end

end		# of LVs