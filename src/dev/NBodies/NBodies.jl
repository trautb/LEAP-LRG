#========================================================================================#
"""
	NBodies

A system of N interacting bodies moving in dim dimensions over time T in res timesteps.

Author: Niall Palfreyman, 24/3/2022.
"""
module NBodies

# Externally callable methods of NBodies
export NBody, add!, simulate

#-----------------------------------------------------------------------------------------
# Module types:

"""
	NBody

An NBody system capable of containing multiple (N) bodies that gravitationally interact
with each other.
"""
mutable struct NBody
	N							# Number of bodies
	T							# Duration of simulation
	res							# Timestep resolution
	xi							# Initial positions of bodies
	pi							# Initial momenta of bodies
	m							# Masses of bodies

	"Construct a new NBody"
	function NBody( T=40, resolution=20000)
		# Initialise all fields of the decoding apparatus:
		new(
			0,					# Initially no bodies in the system
			T,					# Duration
			resolution,			# Timestep resolution
			[],					# Initial positions
			[],					# Initial momenta
			[],					# Masses of bodies
		)
	end
end

#-----------------------------------------------------------------------------------------
# Module methods:

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

"""
	relpos( locations)

A useful helper function that calculates relative positions of a vector x of locations.
"""
function relpos( locations)
	locPerBody = repeat(locations,1,length(locations))
	locPerBody - permutedims(locPerBody)
end

"""
	simulate( nbody::NBody)

Run a simulation of the given NBody system over duration divided into res timesteps.
"""
function simulate( nbody)
	dt = nbody.T / nbody.res
	t = 0:dt:nbody.T
	x = Vector{typeof(nbody.xi)}(undef,nbody.res+1)
	p = Vector{typeof(nbody.pi)}(undef,nbody.res+1)

	# Pre-calculate products of masses:
	G = 1
	Gmm = G * nbody.m * nbody.m'
	
	# Initialisation:
	x[1] = nbody.xi
	p[1] = nbody.pi

	# Simulation:
	for n = 1:nbody.res
		# Simulate timestep n:
		x[n+1] = x[n] + dt*p[n]./nbody.m
		
		diff = relpos(x[n])
		invSq = abs.(diff'.*diff) .^ (3/2)
		for i in 1:length(x[n]) invSq[i,i] += 1 end
		forceFROMEachSource = -Gmm .* diff ./ invSq
		forceONEachSource = sum( forceFROMEachSource, dims=2)
		p[n+1] = p[n] + dt * forceONEachSource[:]
	end

	(t,x,p)
end

#-----------------------------------------------------------------------------------------
using GLMakie

"""
	demo()

Demonstrate simulation of a simple 2-body problem.
"""
function demo()
	# Initialise the system:
	nb = NBody( 2.25, 10000)
	addbody!( nb, -1, 0)
	addbody!( nb,  1, 0)
	
	# Run the simulation:
	(t,x,p) = simulate(nb)

	# Display some fancy graphics:
	fig = Figure(resolution=(600, 600))
	ax = Axis(fig[1, 1], xlabel = "Time (t)", title = "N-body Trajectories")

	lines!(ax, t, map(el->el[1],x), color=:blue)		# Body 1
	lines!(ax, t, map(el->el[2],x), color=:red)			# Body 2
	display(fig)
end

end		# of NBodies