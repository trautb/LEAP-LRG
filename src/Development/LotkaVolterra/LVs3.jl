#========================================================================================#
"""
	LVs - Version 3

A system of two interacting predator-prey species.

Version 3 corrects Euler inaccuracies by implementing an RK-2 integration algorithm.
On studying the visualisation graph from Version 2, I noticed that the peaks of the rabbit
population were gradually getting bigger. This improved when I reduced the length of the
Euler time-step, but that also slowed down the program, so I decided to replace Euler by
by Runge-Kutta-2 integration. Also, to reduce the entanglement of the code, I refactored
the RK2 integration into a separate dedicated method rk2().

NOTE: At present, the dynamical equations occur twice within rk2(). If the Lotka-Volterra
system contained more than two equations, I would definitely consider storing their
right-hand sides as a vector function that is an additional member of the LV type.
(See version 4)

Author: Niall Palfreyman, 31/05/2022.
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
	rx							# Reproduction rate of species x
	kx							# Carrying capacity of species x
	ry							# Reproduction rate of species y
	ky							# Carrying capacity of species y
end

#-----------------------------------------------------------------------------------------
# Module methods:
#-----------------------------------------------------------------------------------------
"""
	run( lv::LV)

Run a simulation of the given LV system over the time-duration nsteps * dt.
In this version, I replace the inline Euler integration from Version 2 by a call to the
dedicated method rk2, which performs a single integration step:
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
dt, based on the parameters of the Lotka-Volterra model lv.
"""
function rk2( lv::LV, x::Vector{Float64}, dt::Float64)
	# Perform the RK2 half-step:
	x_half = x + (dt/2) * [
		lv.rx * x[1] * (1 - x[2]/lv.ky),
		-lv.ry * x[2] * (1 - x[1]/lv.kx)
	]

	# Perform the complete RK2 step:
	return x + dt * [
		lv.rx * x_half[1] * (1 - x_half[2]/lv.ky),
		-lv.ry * x_half[2] * (1 - x_half[1]/lv.kx)
	]
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