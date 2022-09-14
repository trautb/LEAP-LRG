#========================================================================================#
"""
	NBodies - Version 2

A system of N interacting bodies moving in dim dimensions over time T in res timesteps.
In version 2 we implement simulate() to generate and display Euler data for the case where
the bodies move under a constant downward gravitational force - for instance like balls at
the Earth's surface.

Author: Niall Palfreyman, 29/05/2022.
"""
module NBodies

using GLMakie

#-----------------------------------------------------------------------------------------
# Module types:
#-----------------------------------------------------------------------------------------
"""
	NBody

An NBody system capable of containing multiple (N) bodies that gravitationally interact
with each other.
"""
mutable struct NBody
	N							# Number of bodies
	nsteps						# Duration of simulation
	dt							# Timestep resolution
	x0							# Initial positions of bodies
	p0							# Initial momenta of bodies
	m							# Masses of bodies

	"Construct a new NBody"
	function NBody( T=40, resolution=20000, G=1)
		# Initialise all fields of the decoding apparatus:
		new(
			0,					# Initially no bodies in the system
			resolution,			# Duration
			T/resolution,		# Timestep resolution
			[],					# Initial positions
			[],					# Initial momenta
			[],					# Masses of bodies
		)
	end
end

#-----------------------------------------------------------------------------------------
# Module methods:
#-----------------------------------------------------------------------------------------
"""
	addbody!( nbody::NBody, x0::Vector{Float64}, p0::Vector{Float64}, m::Float64=1)

Add to the system a new body with initial position and momentum x0, p0, and with mass m.
As a result, nbody.x0 is a list of initial position Vectors - one for each body in the system.
Similarly, nbody.p0 is a list of initial momentum Vectors - one for each body in the system;
and nbody.m is a list of masses - one for each body in the system.
"""
function addbody!( nbody::NBody, x0::Vector{Float64}, p0::Vector{Float64}, m::Float64=1.0)
	push!( nbody.x0, x0)
	push!( nbody.p0, p0)
	push!( nbody.m, m)
	nbody.N  += 1
end

#-----------------------------------------------------------------------------------------
"""
	simulate( nb::NBody)

Run a simulation of the given NBody system over duration nb.nsteps * nb.dt.
In this version, we simulate a simple downward-pointing force due to gravity at a planet's
surface. That way, we can concentrate on getting Euler's method corrrect, without yet
having to program a complex set of forces between the different bodies.
"""
function simulate( nb::NBody)
	t = 0 : nb.dt : nb.nsteps*nb.dt

	# I have no idea which x and p coordinates the user will provide, so I simply grab whatever
	# type she uses from the initial values stored in nb.x0 and nb.p0. x is then a list of
	# x-coordinates - one Vector of coordinates for each body in the NBody system:
	x = Vector{typeof(nb.x0)}(undef,nb.nsteps+1)
	p = Vector{typeof(nb.p0)}(undef,nb.nsteps+1)

	# Initialisation: The very first values of x and p in our simulated trajectory:
	x[1] = nb.x0
	p[1] = nb.p0

	# Simulation using Euler's method. Remember: x[n] is a list of coordinate Vectors - one
	# for each body in the NBody system. Similarly for p[n] and m[n]:
	for n = 1:nb.nsteps
		x[n+1] = x[n] + nb.dt * p[n] ./ nb.m			# Move each x in the direction of p.
		p[n+1] = p[n] + nb.dt * forceOnMasses(nb.m)		# Accelerate each body with a force.
	end

	(t,x,p)
end

#-----------------------------------------------------------------------------------------
"""
	forceOnMasses( masses)

Internal utility function: Calculate the downward (-y) force on each mass by mapping each mass
to a very weak downward gravitational force equal to 0.1 times that mass.
"""
function forceOnMasses( masses::Vector)
	map( m->[0,-3.0m], masses)
end

#-----------------------------------------------------------------------------------------
"""
	animate( nb::NBody, t, x)

Animate the simulation data (t,x) of the given NBody system.
In this version, we plot the x[1] (i.e. x) and x[2] (i.e. y) coordinates of the bodies over time.
"""
function animate( nb::NBody, t, x)
	# Prepare the graphics axes:
	fig = Figure(resolution=(1200, 1200))
	ax = Axis(fig[1, 1], xlabel = "x", ylabel = "y", title = "N-body 2D Motion")
	limits!(ax, -3, 3, -3, 3)

	# Plot a curve of y-coordinate against x-coordinate for each body in the system:
	for n in 1:nb.N
		x_coords = map( snapshot->snapshot[n][1], x)
		y_coords = map( snapshot->snapshot[n][2], x)

		lines!( ax, x_coords, y_coords, linewidth = 5, color = :blue)
	end

	# Insert some explanatory text:
	text!( "This will contain time data", position=(-2.5, 2.5), textsize=30, align=(:left,:center))

	# Display the results:
	display(fig)
end

#-----------------------------------------------------------------------------------------
"""
	unittest()

Demonstrate simulation of a simple 2-body problem in a simple 3-step use-case.
"""
function unittest()
	# Build the 2-body system:
	nb = NBody( 20, 1000)								# 20 time units divided into 1000 steps
	addbody!( nb, [0.0, 1.0], [ 0.8,0.0], 2.0)			# Sun (m = 2)
	addbody!( nb, [0.0,-1.0], [-0.8,0.0])				# Planet (m = 1)
	
	# Calculate the simulation data:
	(t,x) = simulate(nb)

	# Run the animation:
	animate( nb, t, x)
end

end		# of NBodies