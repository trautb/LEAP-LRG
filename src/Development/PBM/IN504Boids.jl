#========================================================================================#
"""
	IN504Boids

Module Boids: Reynolds' Boids model of flocking in birds.

Author: Niall Palfreyman, 27/04/22
"""
module Boids

export demo									                # Externally available names
using Agents, LinearAlgebra, InteractiveDynamics, GLMakie   # Required packages

#-----------------------------------------------------------------------------------------
# Module definitions:

#-----------------------------------------------------------------------------------------
"""
	Boid

To construct a new agent implementation, use the @agent macro and add all necessary extra
attributes. Again, id, pos and vel are automatically inserted.
"""
@agent Boid ContinuousAgent{2} begin
    speed::Float64						# Speed of boid
    cohering::Float64					# Extent to which boids want to stay together
    proximity::Float64					# Uncomfortable proximity distance
    separating::Float64					# Extent to which boids move out of proximity
    aligning::Float64					# Extent to which boids align their flight
    sight::Float64						# Distance within which I notice other boids
end

#-----------------------------------------------------------------------------------------
const boid_polygon = Polygon(Point2f[(-0.5, -0.5), (1, 0), (-0.5, 0.5)])
"""
	boid_marker(boid)

The graphical marker for boids
"""
function boid_marker(b::Boid)
    φ = atan(b.vel[2], b.vel[1])
    scale(rotate2D(boid_polygon, φ), 2)
end

#-----------------------------------------------------------------------------------------
# Module methods:

#-----------------------------------------------------------------------------------------
"""
	boidworld()

Create the Boids model.
"""
function boidWorld(;
	n_boids				= 100,
	speed				= 1.0,
	cohering			= 0.25,
	proximity			= 4.0,
	separating			= 0.25,
	aligning			= 0.01,
	sight				= 5.0,
	extent				= (100, 100),
	spacing				= sight / 1.5,
)
	world = ABM( Boid, ContinuousSpace(extent,spacing), scheduler = Schedulers.randomly)
	for _ in 1:n_boids
		add_agent!( world,
			Tuple(2*rand(world.rng, 2) .- 1),				# Random facing direction
			speed,
			cohering,
			proximity,
			separating,
			aligning,
			sight,
		)
	end
	return world
end

#-----------------------------------------------------------------------------------------
"""
    agent_step!( boid, world)

Define how a boid moves within the Boid world, depending on its propensity for cohering,
separating and aligning.
"""
function agent_step!( boid, world)
	idNbrs = nearby_ids(boid, world, boid.sight)		# All neighbour ids within my sight

	N = 0												# Number of neighbours
	heading = separating = cohering = (0.0, 0.0)		# Initialise flight parameters
	for id in idNbrs
		# Calculate neighbour's position and bearing:
		N += 1											# Increment number of neighbours
		position = world[id].pos						# Calculate neighbour's position
		bearing = position .- boid.pos					# Calculate neighbour's bearing from here

		cohering = cohering .+ bearing					# 'cohering' accumulates bearing of neighbours
		if edistance(boid.pos, position, world) < boid.proximity
			# 'separating' accumulates recoil from uncomfortably near neighbours:
			separating = separating .- bearing
		end
		heading = heading .+ world[id].vel				# 'align' accumulates heading of neighbours
	end

	# Calculate average values from accumulations:
	N				= max(N,1)								# Allow for no neighbours in sight
	cohering		= cohering .* boid.cohering ./ N		# Cohere along average bearning
	separating		= separating .* boid.separating ./ N	# Separate along average bearing
	heading			= heading .* boid.aligning ./ N			# Align with average heading

	# Compute velocity based on the three parameters cohering, separating, aligning:
	boid.vel = (boid.vel .+ cohering .+ separating .+ heading) ./ 2
	boid.vel = boid.vel ./ norm(boid.vel)

	# Move boid according to new velocity and speed
	move_agent!(boid, world, boid.speed)
end

#-----------------------------------------------------------------------------------------
function demo()
    bworld = boidWorld()							# Create a Boid world ...

    abmvideo(										# ... then make a pretty video of it.
        "boids.mp4", bworld, agent_step!;
        am = boid_marker,
        framerate = 20,
        frames = 100,
        title = "Boids"
    )
end

end		# ... of module Boids