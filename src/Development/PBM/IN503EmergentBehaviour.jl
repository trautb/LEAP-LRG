#========================================================================================#
"""
	IN503EmergentBehaviour

Module EmergentBehaviour: work in progress.

* Code still needs cleaning up
* implement alternative to adding agents for stamping

Author: , 16/05/22
"""
module EmergentBehaviour

export demo_explorer                # Externally available names
using Agents, GLMakie, InteractiveDynamics   # Required packages

#-----------------------------------------------------------------------------------------
# Module definitions:

#-----------------------------------------------------------------------------------------
"""
	Agent_type

To differentiate between agents types for plotting.
"""
@enum Agent_type movable vertex stamp

#-----------------------------------------------------------------------------------------
"""
	Particle

To construct a new agent implementation, use the @agent macro and add all necessary extra
attributes. Again, id, pos and vel are automatically inserted.
"""
@agent Particle ContinuousAgent{2} begin
    type::Agent_type
end

#-----------------------------------------------------------------------------------------
"""
    particle_marker(p)

The graphical marker for particles
"""
function particle_marker(p::Particle)
    :circle
end

#-----------------------------------------------------------------------------------------
"""
    typecolor(p)

The color of the graphical marker for particles
"""
typecolor(p) = p.type == vertex ? :black : :red

#-----------------------------------------------------------------------------------------
"""
    typesize(p)

The size of the graphical marker for particles
"""
typesize(p) = p.type == vertex ? 20 : 10

#-----------------------------------------------------------------------------------------
# Module methods:

#-----------------------------------------------------------------------------------------
"""
    initialize_model()

Create the world model.
"""
function initialize_model(;
    n_particles=1,
	r = 0.5,
	n_vertices = 3,
    extent=(100, 100)
)
	vertices = createVertexCoordinates(n_vertices)

    properties = Dict(:n_particles => n_particles,
        :r => r,
        :n_vertices => n_vertices,
		:vertices => vertices,
        :spu => 30)

    model = ABM(Particle, ContinuousSpace(extent); properties=properties, scheduler=Schedulers.randomly)
    spawn_particles!(model)
    spawnVertices!(model)
    return model
end

function random_vertex(model)
    model.vertices[rand(1:model.n_vertices),:] |> Tuple
end

function spawn_particles!(model, n_particles = model.n_particles)
    for _ in 1:n_particles
        add_agent_pos!(             # this was the only way to set the position so far (to my knowledge)
            Particle(
                nextid(model),      
                random_vertex(model),
                (0.0,0.0),          # vel
                movable             # type
            ),
            model
        )
    end
    return model
end

function spawn_stamps!(model)
    particles = getAgentsByType(model, movable)
    for p in particles
        add_agent_pos!(             # this was the only way to set the position so far (to my knowledge)
            Particle(
                nextid(model),      
                p.pos,              # pos
                (0.0,0.0),          # vel
                stamp               # type
            ),
            model
        )
    end
end

getAgentsByType(model, type) = [particle for particle in allagents(model) if particle.type == type]

function createVertexCoordinates(n_vertices=3, extent=100)
    angle_step = 2π / n_vertices
    angles = 0:angle_step:2π-angle_step

    [0.45 * extent .* sin.(angles)   0.45 * extent .* cos.(angles)] .+ 50
end

"""
    spawnVertices(model)

(Re-) Sets all vertices corresponding to the property `n_vertices` of the `model`.
"""
function spawnVertices!(model)
    genocide!(model, p -> p.type == vertex)

    for i in 1:model.n_vertices
        pos = model.vertices[i,:] |> Tuple
        add_agent_pos!(         # this was the only way to set the position so far (to my knowledge)
            Particle(
                nextid(model),  # id    
                pos,            # pos
                (0.0,0.0),      # vel
                vertex          # type
            ),
            model,
        )
    end
    return model
end


#-----------------------------------------------------------------------------------------
"""
    agent_step!( particle, world)

Define how a particel moves within the particle world
"""
function agent_step!(particle, model)
    if particle.type != movable
        return
    end
    vertex = random_vertex(model)
    newpos = particle.pos .+ model.r .* (vertex .- particle.pos)

    # Move particle
    move_agent!(particle, newpos, model)
end

function model_step!(model)
    particles = getAgentsByType(model, movable)
    if  length(particles) != model.n_particles
        genocide!(model, p -> p.type == movable)    
        spawn_particles!(model)                     
    end
    if model.n_vertices !=  size(model.vertices,1)
        model.vertices = createVertexCoordinates(model.n_vertices)
        spawnVertices!(model)
    end
    # TODO: put down stamp as plot
        # * maybe with another property in the model saving all the positions (something with observables)
        # * but how can a plotting function be called from within here?
    spawn_stamps!(model)
end

#-----------------------------------------------------------------------------------------
# function demo()
#     model = initialize_model()# Create a EmergentBehaviour world ...

#     abmvideo(# ... then make a pretty video of it.
#         "03 Emergent Behaviour.mp4", model, agent_step!, model_step!;
#         ac=:red, am=particle_marker, as=10,
#         framerate=20,
#         frames=100,
#         title="03 Emergent Behaviour"
#     )
# end

"""
    demo_explorer()

    increase the `spu` slider to see faster progress
    Currently very laggy since creating agents and not plotting
"""
function demo_explorer()
    params = Dict(:n_particles => 1:10,
        :r => 0:0.1:1,
        :n_vertices => 3:7)

    model = initialize_model()
    fig, p = abmexploration(model; (agent_step!)=agent_step!, model_step!, params, ac=typecolor, as=typesize, am=particle_marker)
    fig
end

end # ... of module EmergentBehaviour