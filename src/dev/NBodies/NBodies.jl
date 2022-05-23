#========================================================================================#
"""
	NBodies

A system of N interacting bodies moving in dim dimensions over time T in res timesteps.

Author: Niall Palfreyman, 24/3/2022.
"""
module NBodies

# Externally callable methods of NBodies
export NBody, add!, simulate

#========================================================================================#
# Module types:
#-----------------------------------------------------------------------------------------
"""
	NBody

An NBody system capable of containing multiple (N) bodies that gravitationally interact
with each other.
"""
mutable struct NBody
	N::Int						# Number of bodies
	T::Float64					# Duration of simulation
	res::Int					# Timestep resolution
	xi::Vector{Vector}			# Initial positions of bodies
	pi::Vector{Vector}			# Initial momenta of bodies
	m::Vector{Float64}			# Masses of bodies
	G::Float64					# Universal gravitational constant

	"Construct a new NBody"
	function NBody( T=40, resolution=20000, G=1)
		# Initialise all fields of the decoding apparatus:
		new(
			0,					# Initially no bodies in the system
			T,					# Duration
			resolution,			# Timestep resolution
			[],					# Initial positions
			[],					# Initial momenta
			[],					# Masses of bodies
			G					# Gravitational constant
		)
	end
end

#========================================================================================#
# Module methods:
#-----------------------------------------------------------------------------------------
"""
	addbody!( nbody::NBody, xi, pi, m=1)

Add to the system a new body with initial position and momentum xi, pi, and with mass m.
"""
function addbody!( nbody::NBody, xi, pi, m=1)
	push!( nbody.xi, xi)
	push!( nbody.pi, pi)
	push!( nbody.m, m)
	nbody.N  += 1
end

#-----------------------------------------------------------------------------------------
"""
	forceOnSources( locations, masses)

Internal utility function: Calculate the force on each source with given mass at the
given locations.
"""
function forceOnSources( locations::Vector, masses::Vector{Float64}, G=1.0)
	gmm = G * masses * masses'								# Precalculate mass products

	locPerBody = repeat(locations,1,length(locations))		# Set up locations alongside each other
	relpos = locPerBody - permutedims(locPerBody)			# Antisymmetric relative positions
	invCube = abs.(relpos'.*relpos) .^ (3/2)				# 1 / (r_ij)^3
	for i in 1:length(locations) invCube[i,i] = 1 end		# Prevent zero-division along diagonal

	forceFROMSources = -gmm .* relpos ./ invCube			# Force contribution FROM each source

	sum( forceFROMSources, dims=2)							# Sum all forces ON each source
end

#-----------------------------------------------------------------------------------------
"""
	simulate( nbody::NBody)

Run a simulation of the given NBody system over duration divided into res timesteps.
"""
function simulate( nbody)
	dt = nbody.T / nbody.res
	dt2 = dt/2
	t = 0:dt:nbody.T
	x = Vector{typeof(nbody.xi)}(undef,nbody.res+1)
	p = Vector{typeof(nbody.pi)}(undef,nbody.res+1)

	# Initialisation:
	x[1] = nbody.xi
	p[1] = nbody.pi

	# Simulation using Runge-Kutta 2:
	for n = 1:nbody.res
		# Half-step:
		xh = x[n] + dt2 * p[n]./nbody.m
		ph = p[n] + dt2 * forceOnSources(x[n],nbody.m,nbody.G)[:]
		
		# Full-step:
		x[n+1] = x[n] + dt * ph./nbody.m
		p[n+1] = p[n] + dt * forceOnSources(xh,nbody.m,nbody.G)[:]
	end

	(t,x,p)
end

#========================================================================================#
using GLMakie

"""
	demo()

Demonstrate simulation of a simple 2-body problem.
"""
function demo()
	# Initialise the system:
	nb = NBody( 300, 100000, 100)

	addbody!( nb, [ 4.5,0.0], 	[ 0.000, 2.000],		1.000)			# Sun 1
	addbody!( nb, [-4.5,0.0],	[-0.001,-2.003],		2.000)			# Sun 2
	addbody!( nb, [25.0,0.0],	[-0.001, 0.003],		0.001)			# Planet
	
	# Run the simulation:
	(t,x,p) = simulate(nb)

	# Display the trajectories:
	fig = Figure(resolution=(600, 600))
	ax = Axis(fig[1, 1], xlabel = "Time (t)", title = "N-body Trajectories")

	lines!(ax, map(el->el[1][1],x), map(el->el[1][2],x), color=:red)	# Sun 1
	lines!(ax, map(el->el[2][1],x), map(el->el[2][2],x), color=:orange)	# Sun 2
	lines!(ax, map(el->el[3][1],x), map(el->el[3][2],x), color=:blue)	# Planet

	display(fig)
end

end		# of NBodies