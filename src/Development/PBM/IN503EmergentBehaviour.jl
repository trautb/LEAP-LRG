#========================================================================================#
"""
	IN503EmergentBehaviour

Module EmergentBehaviour: 

Author: , 16/05/22
"""
module EmergentBehaviour

export demo									                # Externally available names
using Agents, LinearAlgebra, InteractiveDynamics, GLMakie   # Required packages

#-----------------------------------------------------------------------------------------
# Module definitions:

#-----------------------------------------------------------------------------------------
"""
	Particle

To construct a new agent implementation, use the @agent macro and add all necessary extra
attributes. Again, id, pos and vel are automatically inserted.
"""
@agent Particle ContinuousAgent{2} begin

end

#-----------------------------------------------------------------------------------------
"""
	Vertex

To construct a new agent implementation, use the @agent macro and add all necessary extra
attributes. Again, id, pos and vel are automatically inserted.
"""
@agent Vertex ContinuousAgent{2} begin
	# not used as of now, they are just markers
end

const r = 0.5

#-----------------------------------------------------------------------------------------
"""
particle_marker(p)

The graphical marker for particles
"""
function particle_marker(p::Particle)
    :circle
end

#-----------------------------------------------------------------------------------------
# Module methods:

#-----------------------------------------------------------------------------------------
"""
	createWorld()

Create the world model.
"""
function createWorld(;
	n_particles			= 1,
	extent				= (100, 100)
)
	world = ABM( Particle, ContinuousSpace(extent), scheduler = Schedulers.randomly)
	vertices = createVertices() |> Tuple;
	random_vertex = rand(vertices)
	for _ in 1:n_particles
		add_agent!( world,
			Tuple(random_vertex)
		)
	end
	return world
end


function createVertices(n_vertices=3, extent = 100) 
	angle_step = 360 / n_vertices
	angles = 0:angle_step:360-angle_step

	map(x -> [0.9 * extent * sin(x), 0.9 * extent * cos(x)], angles)
end

#-----------------------------------------------------------------------------------------
"""
    agent_step!( particle, world)

Define how a particel moves within the particle world
"""
function agent_step!( particle, world)
	vertices = createVertices()
	random_vertex = rand(vertices)

	pos = particle.pos .+ r .* (random_vertex .- particle.pos) |> Tuple

	# TODO: put down stamp

	# Move particle
	move_agent!(particle, pos, world)
end

#-----------------------------------------------------------------------------------------
function demo()
    world = createWorld()							# Create a EmergentBehaviour world ...

    abmvideo(										# ... then make a pretty video of it.
        "03 Emergent Behaviour.mp4", world, agent_step!;
        ac = :red, am = particle_marker, as = 10,
        framerate = 20,
        frames = 100,
        title = "03 Emergent Behaviour"
    )
end

end		# ... of module EmergentBehaviour