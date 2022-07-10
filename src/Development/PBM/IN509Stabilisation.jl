"""
    IN509Stabilisation

Module Stabilisation: In this module multiple particles move around
a world where they slow down when they get close to each other
and speed up, when they dont have other particles nearby. This
mechanic causes an interesting effect called Stabilisation.

Author: Niall Palfreyman (January 2020), Dominik Pfister (July 2022)
"""

module Stabilisation

export demo                # Externally available names
using Agents, GLMakie, InteractiveDynamics   # Required packages

include("./AgentToolBox.jl")
import .AgentToolBox: neighbors4, polygon_marker, reinit_model_on_reset!, rotate_2dvector

#-----------------------------------------------------------------------------------------
# Module definitions:

#-----------------------------------------------------------------------------------------
"""
	Particle

To construct a new agent implementation, use the @agent macro and add all necessary extra
attributes. Again, id, pos and vel are automatically inserted.
"""
@agent Particle ContinuousAgent{2} begin 
    speed::Float64
end

#-----------------------------------------------------------------------------------------
# Module methods:

#-----------------------------------------------------------------------------------------
"""
	initialize_model()

Create the world model.
"""
function initialize_model(;
    pPop = 0.25,			# Propability of populating a patch with a particle
    dims=(25, 25),		# dimensions of world inside model
    particle_speed=1.0,		# value for turtle-speed
)

    # generate world for agents
    space2d = ContinuousSpace(dims, 1.0)

    # set model properties
    properties = Dict(
        :pPop => pPop,
    )

    # Generate model with agent, world, model-properties and order of agent steps
    model = ABM(Particle, space2d; properties, scheduler=Schedulers.randomly)
    # Randomly sprout particles around the models space
    for p in positions(model)
        if rand() < pPop
            vel = (rand(-1:0.01:1), rand(-1:0.01:1))
            particle = Particle(nextid(model), (p) .- 0.5 , vel, particle_speed)
            add_agent_pos!(particle, model)
        end
    end

    return model
end

#-----------------------------------------------------------------------------------------
"""
	agent_step!(particle, model)

A particle moves forward in the direction its facing depending on the amount of other
particles that are nearby. After its movement it chooses a random new direction.
"""
function agent_step!(particle, model)

    n_neighbors = length(neighbors4(particle, model))
    particle.speed = 1 / (1 + n_neighbors^2)

    if rand() < particle.speed
        move_agent!(particle, model, particle.speed)   # TODO: for compatibility in Agents@5.4 change to `dt=particle.speed`
    end

    particle.vel = (rand(-1:0.01:1), rand(-1:0.01:1))
end

#-----------------------------------------------------------------------------------------

"""
	demo()

creates an interactive abmplot of the Stabilisation module to visualize
a simple stabilisation process.
"""
function demo()

    params = Dict(
		:pPop => 0.01:0.01:1,
	)

    plotkwargs = (
        ac=:green, 				# agents color (ac)
        am=polygon_marker, 		# agents marker
    )

	model = initialize_model()

    fig, p = abmexploration(
        model;
        (agent_step!)=agent_step!,
        (model_step!)=dummystep,
        params,
        plotkwargs...
    )
    reinit_model_on_reset!(p, fig, initialize_model)

    fig
end


end # ... end of module Stabilisation