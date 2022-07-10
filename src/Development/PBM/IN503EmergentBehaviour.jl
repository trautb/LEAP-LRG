#========================================================================================#

"""
	IN503EmergentBehaviour

Module EmergentBehaviour: In this model, Particles move around the world
randomly, while generating a pattern that is emergent, in the sense that we
cannot easily see how it arises from the behaviours of the individual Particles.
However, this is not a collective pattern, since a single agent is also
capable of constructing it.

Author: Niall Palfreyman (January 2020), Nick Diercksen (May 2022)
"""
module EmergentBehaviour

export demo                						# Externally available names
using Agents, GLMakie, InteractiveDynamics  	# Required packages

include("./AgentToolBox.jl")
import .AgentToolBox: reinit_model_on_reset!

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
function initialize_model(;
	n_particles=1,
	r=0.5,
	n_vertices=3,
	worldsize=100,
	extent=(worldsize, worldsize)
)

	properties = Dict(:n_particles => n_particles,
		:r => r,
		:n_vertices => n_vertices,
		:vertices => createVertexCoordinates(n_vertices),
		:spu => 30,
		:visited_locations => Array{Float64}(undef, 0, 2)
	)

	model = ABM(Particle, ContinuousSpace(extent); properties=properties, scheduler=Schedulers.randomly)
	create_vertices!(model)
	spawn_particles!(model)
	return model
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
				(0.0, 0.0)              # vel
			),
			model
		)
	end
	return model
end

# vertex functions: ------------------------------------------------------------

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
function create_vertices!(model::AgentBasedModel)
	n_vertices = model.n_vertices
	worldsize = model.space.extent[1]
	model.vertices = createVertexCoordinates(n_vertices; worldsize)
end

"""
	random_vertex(model)

Returns a random vertex position as tuple.
"""
function random_vertex(model)
	n = size(model.vertices, 1)
	model.vertices[rand(1:n), :] |> Tuple
end


# step-functions: --------------------------------------------------------------

"""
	agent_step!( particle, model)

Define how a particle moves within the particle world
"""
function agent_step!(particle, model)
	vertex = random_vertex(model)
	newpos = particle.pos .+ model.r .* (vertex .- particle.pos)
	move_agent!(particle, newpos, model)
end


"""
	model_step!(model)

After all agents made one step, their current positions will be collected.
"""
function model_step!(model)
	particles = allagents(model)
	current_pos = [p.pos for p in particles] |> (pos -> [first.(pos) last.(pos)])
	model.visited_locations = vcat(model.visited_locations, current_pos)
end


# execution and visualization --------------------------------------------------

"""
	demo()

creates an interactive abmplot of the EmergentBehaviour module to visualize
Sierpinski's triangle.
"""
function demo()
	params = Dict(:n_particles => 1:10, # slider values
		:r => 0:0.1:1,
		:n_vertices => 3:7)

	model = initialize_model()
	fig, p = abmexploration(
		model;
		(agent_step!)=agent_step!,
		model_step!,
		params,
		ac=:red, as=10, am=:circle
	)
    reinit_model_on_reset!(p, fig, initialize_model)

	additional_plots(p)
	fig
end


"""
	additional_plots(p::ABMObservable)

adds a plot for the vertices as well as for the visited locations.
"""
function additional_plots(p::ABMObservable)
	position_points = Observable(Vector{Point{2,Float32}}(undef, 2))
	vertex_points = Observable(Vector{Point{2,Float32}}(undef, 2))

	on(p.model) do m # as soon as p gets updated, the arrays for the plots get updated as well
		position_points[] = Point2f.(m.visited_locations[:, 1], m.visited_locations[:, 2])
		vertex_points[] = Point2f.(m.vertices[:, 1], m.vertices[:, 2])
	end

	scatter!(position_points, color=:red, markersize=5)
	scatter!(vertex_points, color=:black, markersize=20)
end

end # ... of module EmergentBehaviour