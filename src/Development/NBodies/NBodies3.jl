#========================================================================================#
"""
	NBodies - Version 3

A system of N interacting bodies moving in dim dimensions over time T in res timesteps.
In version 3, we develop animate() further to display an animation of the simple downward
motion that we simulated in version 2.

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
This version is identical to version 2.
"""
function simulate( nb::NBody)
	t = 0 : nb.dt : nb.nsteps*nb.dt
	x = Vector{typeof(nb.x0)}(undef,nb.nsteps+1)
	p = Vector{typeof(nb.p0)}(undef,nb.nsteps+1)

	# Initialisation:
	x[1] = nb.x0
	p[1] = nb.p0

	# Simulation using Euler's method:
	for n = 1:nb.nsteps
		x[n+1] = x[n] + nb.dt * p[n] ./ nb.m			# Move each x in the direction of p.
		p[n+1] = p[n] + nb.dt * forceOnMasses(nb.m)		# Accelerate each body with a force.
	end

	(t,x,p)
end

#-----------------------------------------------------------------------------------------
"""
	forceOnMasses( masses::Vector)

Internal utility function: Calculate the downward (-y) force on each mass by mapping each mass
to a weak downward gravitational force equal to 0.1 times that mass. (Identical to version 2)
"""
function forceOnMasses( masses::Vector)
	map( m->[0,-0.1m], masses)
end

#-----------------------------------------------------------------------------------------
"""
	animate( nb::NBody, t, x)

Animate the simulation data (t,x) of the given NBody system. In this version, we use our
simple downward-motion data to create a visual animation of the motion.
"""
function animate( nb::NBody, t, x)
	# Prepare an Observable containing the initial x/y coordinate for each body:
	x_current = Observable( map( bodycoords->bodycoords[1], x[1]))
	y_current = Observable( map( bodycoords->bodycoords[2], x[1]))
	timestamp = Observable( string( "t = ", round(t[1], digits=2)))

	# Prepare the animation graphics:
	fig = Figure(resolution=(1200, 1200))
	ax = Axis(fig[1, 1], xlabel = "x", ylabel = "y", title = "N-body 2D Motion")
	limits!( ax, -3, 3, -3, 3)
	scatter!( ax, x_current, y_current, markersize=(50nb.m), color=:blue)
	text!( timestamp, position=(-2.5, 2.5), textsize=30, align=(:left,:center))
	display(fig)

	# Run the animation:
	for i in 1:nb.nsteps+1
		x_current[] = map( bodycoords->bodycoords[1], x[i])
		y_current[] = map( bodycoords->bodycoords[2], x[i])
		timestamp[] = string( "t = ", round(t[i], digits=2))

		sleep(1e-4)
	end
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