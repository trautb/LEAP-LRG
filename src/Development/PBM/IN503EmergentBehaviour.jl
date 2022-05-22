#========================================================================================#
"""
	IN503EmergentBehaviour

Module EmergentBehaviour: 

Author: , 16/05/22
"""
module EmergentBehaviour

export demo                # Externally available names
using Agents, GLMakie, InteractiveDynamics   # Required packages
using LinearAlgebra # TODO: is this currently used?

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
function initialize_model(;
    n_particles=1,
	r = 0.5,
	n_vertices = 3,
    extent=(100, 100)
)
	vertices = createVertices(n_vertices)

    properties = Dict(:n_particles => n_particles,
        :r => r,
        :n_vertices => n_vertices,
		:vertices => vertices)

    model = ABM(Particle, ContinuousSpace(extent); properties=properties, scheduler=Schedulers.randomly)
    spawn_particles!(model)
    return model
end

function random_vertex(model)
    model.vertices[rand(1:model.n_vertices),:] |> Tuple
end

function spawn_particles!(model, n_particles = model.n_particles)
    for _ in 1:n_particles
        add_agent_pos!( # this was the only way to set the position so far (to my knowledge)
            Particle(
                nextid(model),  # Using `nextid` prevents us from having to 
                                # manually keep track of particle IDs
                random_vertex(model),
                (0.0,0.0)       # vel
            ),
            model,
        )
    end
    return model
end

function createVertices(n_vertices=3, extent=100)
    angle_step = 2π / n_vertices
    angles = 0:angle_step:2π-angle_step

    [0.45 * extent .* sin.(angles)   0.45 * extent .* cos.(angles)] .+ 50
end

#-----------------------------------------------------------------------------------------
"""
    agent_step!( particle, world)

Define how a particel moves within the particle world
"""
function agent_step!(particle, model)
    vertex = random_vertex(model)
    pos = particle.pos .+ model.r .* (vertex .- particle.pos)

    # Move particle
    move_agent!(particle, pos, model)
end

function model_step!(model)
    if model.agents.count != model.n_particles
        genocide!(model)            # remove all particles
        spawn_particles!(model)     # repopulate with correct number
    end
    if model.n_vertices !=  size(model.vertices,1)
        model.vertices = createVertices(model.n_vertices)
        # TODO: somehow update the scatter vertices on the plot
    end
    # TODO: put down stamp
        # * maybe with another property in the model saving all the positions
        # * but how can a plotting function be called from within here?

end

#-----------------------------------------------------------------------------------------
function demo()
    model = initialize_model()# Create a EmergentBehaviour world ...

    abmvideo(# ... then make a pretty video of it.
        "03 Emergent Behaviour.mp4", model, agent_step!, model_step!;
        ac=:red, am=particle_marker, as=10,
        framerate=20,
        frames=100,
        title="03 Emergent Behaviour"
    )
end

function demo_explorer()
    params = Dict(:n_particles => 1:10,
        :r => 0:0.1:1,
        :n_vertices => 3:7)

    model = initialize_model()
    fig, p = abmexploration(model; (agent_step!)=agent_step!, model_step!, params, ac=:red, as=13, am=particle_marker, add_controls = true)
	# Axis(fig[1, 1], backgroundcolor = :black)
    fig
    scatter!(model.vertices[:,1], model.vertices[:,2], color = :black, markersize = 20)
    fig
end

end # ... of module EmergentBehaviour