#========================================================================================#
"""
	NBodies - Version 0

A system of N interacting bodies moving in dim dimensions over time T in res timesteps.
In version 0, we simply create a framework which will run, and indicate (in the methd demo())
what use-cases we intend our software to fulfil.

Author: Niall Palfreyman, 29/05/2022.
"""
module NBodies

using GLMakie					# I don't actually use this yet, but I know I'll need it later

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
	nsteps						# Number of steps in simulation
	dt							# Length of timestep
	x0							# Array containing initial position of each body
	p0							# Array containing initial momentum of each body
	m							# Array containing mass of each body

	"Construct a new NBody"
	function NBody( T=40, resolution=20000, G=1)
		# Initialise all fields of the decoding apparatus:
		new(
			0,					# Initially no bodies in the system
			resolution,			# Number of steps in simulation
			T/resolution,		# Length of timestep
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

Run a simulation of the given NBody system over the time-duration nb.nsteps * nb.dt.
"""
function simulate( nb::NBody)
	(1,1,1)			# Dummy code: I assume I'll need to return t-,x- and p-values of a trajectory.
end

#-----------------------------------------------------------------------------------------
"""
	animate( nb::NBody, t, x)

Animate the simulation data (t,x) of the given NBody system on the screen.
"""
function animate( nb::NBody, t, x)
	println( "t = ", t)
	println( "x = ", x)
	println( "nb = ", nb)
end

#-----------------------------------------------------------------------------------------
"""
	unittest()

This first version of my use-case method unittest() describes everything I want to do in the final
program: Demonstrate simulation of a simple 2-body problem in a simple 3-step use-case.

NOTE: USE-CASES are the HEART of software development! This one is already basically complete,
even though the methods it calls are dummy methods (that is: callable, but empty of functionality).
The code in this demo method already organises my thinking by giving me a precise plan of what
methods I will need to implement in later versions of the developing software.

I will develop my program according to the following DEVELOPMENT PLAN:

	Version 1: Implement animate() to generate a static plot of dummy simulation data provided
				by simulate().
	Version 2: Implement simulate() to generate and display Euler data for the case where the
				bodies move within the constant gravitational force at the Earth's surface.
	Version 3: Develop animate() to display an animation of the simple behaviour from version 2.
	Version 4: Develop simulate() to provide genuine data for N gravitationally interacting bodies.
	Version 5: Fix any execution errors arising from mistakes I made in my original design.

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