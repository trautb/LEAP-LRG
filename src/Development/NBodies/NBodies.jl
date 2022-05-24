#========================================================================================#
"""
	NBodies

A system of N interacting bodies moving in dim dimensions over time T in res timesteps.

Author: Niall Palfreyman, 24/3/2022.
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
	G							# Gravitational constant
	x0							# Initial positions of bodies
	p0							# Initial momenta of bodies
	m							# Masses of bodies
	t							# Current time of system
	x							# Current position of system
	p							# Current momentum of system

	"Construct a new NBody"
	function NBody( T=40, resolution=20000, G=1)
		# Initialise all fields of the decoding apparatus:
		new(
			0,					# Initially no bodies in the system
			resolution,			# Duration
			T/resolution,		# Timestep resolution
			G,					# Gravitational constant
			[],					# Initial positions
			[],					# Initial momenta
			[],					# Masses of bodies
			0.0,				# Start time at zero
			[],					# Current position empty
			[]					# Current momentum empty
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
	push!( nbody.x, deepcopy(x0))					# Question: Why do I use deepcopy here?
	push!( nbody.p0, p0)
	push!( nbody.p, deepcopy(p0))
	push!( nbody.m, m)
	nbody.N  += 1
end

#-----------------------------------------------------------------------------------------
"""
	forceOnSources( locations, masses)

Internal utility function: Calculate the force on each source with given mass at the
given locations.
"""
function forceOnSources( locations::Vector, masses::Vector, G=1.0)
	gmm = G * masses * masses'							# Precalculate mass products

	locPerBody = repeat(locations,1,length(locations))	# Set up locations alongside each other
	relpos = locPerBody - permutedims(locPerBody)		# Calculate relative position vectors r_ij
	invCube = abs.(relpos'.*relpos) .^ (3/2)			# 1 / (r_ij)^3
	for i in 1:length(locations) invCube[i,i] = 1 end	# Prevent zero-division along diagonal

	forceFROMSources = -gmm .* relpos ./ invCube		# Force contribution FROM each source

	sum( forceFROMSources, dims=2)						# Sum all forces ON each source
end

#-----------------------------------------------------------------------------------------
"""
	euler!( nbody::NBody)

Perform a single Euler-step of the given NBody system.
"""
function rkstep!( nb::NBody)
	nb.x = nb.x + nb.dt * nb.p./nb.m
	nb.p = nb.p + nb.dt * forceOnSources(nb.x,nb.m,nb.G)[:]
end

#-----------------------------------------------------------------------------------------
"""
	simulate( nb::NBody)

Run a simulation of the given NBody system over duration nb.nsteps * nb.dt.
"""
function simulate( nb::NBody)
	t = 0:nb.dt:nb.nsteps*nb.dt
	x = Vector{typeof(nb.x0)}(undef,nb.nsteps+1)
	p = Vector{typeof(nb.p0)}(undef,nb.nsteps+1)

	# Initialisation:
	x[1] = nb.x0
	p[1] = nb.p0

	# Simulation using Runge-Kutta 2:
	for n = 1:nb.nsteps
		rkstep!(nb)
		x[n+1] = nb.x
		p[n+1] = nb.p
	end

	(t,x,p)
end

#-----------------------------------------------------------------------------------------
"""
	demo()

Demonstrate simulation of a simple 2-body problem.
"""
function demo()
	nb = NBody( 20, 1000)
	addbody!( nb, [ 1.0,0.0], [0.0, 0.5], 2.0)			# Sun
	addbody!( nb, [-1.0,0.0], [0.0,-0.5])				# Planet
	
	# Run the simulation:
	(t,x,p) = simulate(nb)

	map(pos->pos[1],x[1])
	x_curr = Observable(map(body->body[1],x[1]))
	y_curr = Observable(map(body->body[2],x[1]))
	t_curr = Observable(string("t = ", round(t[1], digits=2)))

	# Display some fancy graphics:
	fig = Figure(resolution=(2000, 1000))
	ax = Axis(fig[1, 1], xlabel = "x", ylabel = "y", title = "N-body 2D Motion")
	limits!(ax, -5, 5, -5, 5)
	scatter!(ax, x_curr, y_curr, markersize=(20nb.m), color=[:blue,:red])
	text!(t_curr, position=(-4, 4), textsize=40, align=(:left, :center))
	display(fig)

	# Run the animation:
	for i in 1:length(t)
		x_curr[] = map(body->body[1],x[i])
		y_curr[] = map(body->body[2],x[i])
		t_curr[] = string("t = ", round(t[i]; digits=2))

		sleep(1e-4)
	end
end

end		# of NBodies