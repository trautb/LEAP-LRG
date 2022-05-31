#========================================================================================#

# TODO: fix Makie thorwing Errors when resetting!

"""
	IN503EmergentBehaviour

Module EmergentBehaviour: In this model, Particles move around the world
randomly, while generating a pattern that is emergent, in the sense that we
cannot easily see how it arises from the behaviours of the individual Particles.
However, this is not a collective pattern, since a single agent is also
capable of constructing it.

Author: , 16/05/22
"""
module EmergentBehaviour

export demo_explorer                # Externally available names
using Agents, GLMakie, InteractiveDynamics   # Required packages

#-----------------------------------------------------------------------------------------
# Module definitions:

#-----------------------------------------------------------------------------------------
"""
	Particle

To construct a new agent implementation, use the @agent macro and add all necessary extra
attributes. Again, id, pos and vel are automatically inserted.
"""
@agent Particle ContinuousAgent{2} begin end


#-----------------------------------------------------------------------------------------
# Module methods:

#-----------------------------------------------------------------------------------------
"""
    initialize_model()

Create the world model.
"""
function create_model(;
    n_particles=1,
    r=0.5,
    n_vertices=3,
    worldsize=100,
    extent=(worldsize, worldsize)
)
    vertices = createVertexCoordinates(n_vertices)
    visited_locations = Observable(Array{Float64}(undef, 0, 2)) # TODO: or is mdata meant for this?

    properties = Dict(:n_particles => n_particles,
        :r => r,
        :n_vertices => n_vertices,
        :vertices => vertices,
        :spu => 30,
        :visited_locations => visited_locations,
        :initialized => false)

    model = ABM(Particle, ContinuousSpace(extent); properties=properties, scheduler=Schedulers.randomly)
    add_agent!(Particle(nextid(model), (1.0, 1.0), (0.0, 0.0)), model) # Add one dummy agent so that abm_video will allow us to plot.
    return model
end

#-----------------------------------------------------------------------------------------

"""
    random_vertex(model)

Returns a random vertex position as tuple.
"""
function random_vertex(model)
    model.vertices[rand(1:model.n_vertices), :] |> Tuple
end

#-----------------------------------------------------------------------------------------

"""
    spawn_particles!(model, n_particles = model.n_particles)

Populates the model with the specified nr of particles.
"""
function spawn_particles!(model, n_particles=model.n_particles)
    for _ in 1:n_particles
        add_agent_pos!(
            Particle(
                nextid(model),          # id
                random_vertex(model),   # pos
                (0.0, 0.0)               # vel
            ),
            model
        )
    end

    # set visited_locations
    particles = allagents(model)
    current_pos = [p.pos for p in particles] |> (pos -> [first.(pos) last.(pos)])
    model.visited_locations[] = vcat(model.visited_locations[], current_pos)
    return model
end

#-----------------------------------------------------------------------------------------

"""
    createVertexCoordinates(n_vertices=3; worldsize=100)

Returns coordinates for the vertices as nx2 Matrix where n corresponds to 
    `n_vertices`. The two columns of the matrix represent x and y coordinates.
"""
function createVertexCoordinates(n_vertices=3; worldsize=100)
    angle_step = 2π / n_vertices
    angles = 0:angle_step:2π-angle_step

    [0.45 * worldsize .* sin.(angles) 0.45 * worldsize .* cos.(angles)] .+ 50
end
function createVertexCoordinates(model::AgentBasedModel)
    n_vertices = model.n_vertices
    worldsize = model.space.extent[1]
    createVertexCoordinates(n_vertices; worldsize)
end

#-----------------------------------------------------------------------------------------
"""
    agent_step!( particle, model)

Define how a particle moves within the particle world
"""
function agent_step!(particle, model)
    if !model.initialized
        initialize_model!(model)
    end

    vertex = random_vertex(model)
    newpos = particle.pos .+ model.r .* (vertex .- particle.pos)

    # Move particle
    move_agent!(particle, newpos, model)
end

#-----------------------------------------------------------------------------------------

"""
    model_step!(model)

After all agents made one step, their current positions will be collected.
"""
function model_step!(model)
    particles = allagents(model)
    current_pos = [p.pos for p in particles] |> (pos -> [first.(pos) last.(pos)])
    model.visited_locations[] = vcat(model.visited_locations[], current_pos)
end

#-----------------------------------------------------------------------------------------

"""
    initialize_model!(model)

This method is needed to initialize the system. This is specially important to
reflect the adjustements made with the parameters on the abmplot.
"""
function initialize_model!(model)
    genocide!(model)
    model.vertices = createVertexCoordinates(model)
    spawn_particles!(model)

    resetplot()
    scatter!(model.vertices[:, 1], model.vertices[:, 2], color=:black, markersize=20)
    # ----
    locs = model.visited_locations
    positions = @lift(Point2f.($locs[:, 1], $locs[:, 2]))
    scatter!(positions, color=:red, markersize=10)
    # ----
    model.initialized = true
    return model
end

#-----------------------------------------------------------------------------------------

"""
resetplot()

removes any additional plots which cannot be updated anymore because of old
references. Plots like stamps of previous locations and vertices will be removed
to then be newly created with correct references.
"""
function resetplot()
    a = current_axis()
    n_initial_plots = 2
    while length(a.scene.plots) > n_initial_plots
        pop!(a.scene.plots)
        sleep(0.01)
    end
    display(current_figure())
end

#-----------------------------------------------------------------------------------------

"""
    demo_explorer()

creates an interactive abmplot of the EmergentBehaviour module to visualize
Sierpinski's triangle.
"""
function demo_explorer()
    params = Dict(:n_particles => 1:10,
        :r => 0:0.1:1,
        :n_vertices => 3:7)

    model = create_model()
    fig, p = abmexploration(model; (agent_step!)=agent_step!, model_step!, params, ac=:red, as=10, am=:circle)
    fig
end

end # ... of module EmergentBehaviour