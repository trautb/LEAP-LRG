#========================================================================================#
"""
	IN511PSO

**Module PSO**: \\
This model demonstrates how swarms of particles can solve a minimisation 
problem - and also the major difficulty of swarm techniques: suboptimisation.


Author: , 31/05/22
"""
module PSO

export demo                # Externally available names
using Agents, GLMakie, InteractiveDynamics   # Required packages

#-----------------------------------------------------------------------------------------
# Module definitions:

#-----------------------------------------------------------------------------------------
"""
	Particle

To construct a new agent implementation, use the @agent macro and add all necessary extra
attributes. Again, id, pos and vel are automatically inserted.
"""
@agent Particle ContinuousAgent{2} begin
    uLowest::Float64        # Lowest value of u that I have yet found in my travels
end

#-----------------------------------------------------------------------------------------
# Module methods:

#-----------------------------------------------------------------------------------------
"""
    create_model()

Create the world model.
"""
function create_model(;
    pPop=0.05,                 # proportion of patches to be populated by one particle
    temperature=0.001,
    tolerance=0.4,
    worldsize=80,
    deJong7=false,
    extent=(worldsize, worldsize)
)

    # pPop = 0.05
    # temperature = 0.001
    # tolerance = 0.4
    # worldsize = 80
    # deJong7 = false
    # extent = (worldsize, worldsize)

    properties = Dict(
        :patches => deJong7 ? buildDeJong7(worldsize) : buildValleys(worldsize),
        :pPop => pPop,
        :temperature => temperature,
        :tolerance => tolerance,
        :deJong7 => deJong7,
        :initialized => false
    )

    model = ABM(Particle, ContinuousSpace(extent, 1); properties=properties)
    # # add_agent!(model) # Add one dummy agent so that abm_video will allow us to plot.
    # add_agent_pos!( # Add one dummy agent so that abm_video will allow us to plot.
    #     Particle(
    #         nextid(model),          # id
    #         (0.0, 0.0),             # pos
    #         (0.0, 0.0),             # vel
    #         2.0                     # uLowest
    #     ),
    #     model
    # )

    spawn_particles!(model)
    return model
end


#-----------------------------------------------------------------------------------------

"""
    setPatches!()

Spawn patches according.
"""
function setPatches!(model)
    model.patches = model.deJong7 ? buildDeJong7(model) : buildValleys(model)
end

function buildValleys(worldsize)
    maxCoordinate = worldsize / 2
    xy = 4 .* collect(-maxCoordinate:(maxCoordinate-1)) ./ maxCoordinate

    f(x, y) = (1 / 3) * exp(-((x + 1)^2) - (y^2)) +
              10 * (x / 5 - (x^3) - (y^5)) * exp(-(x^2) - (y^2)) -
              (3 * ((1 - x)^2)) * exp(-(x^2) - ((y + 1)^2))
    f.(xy, xy')
end

function buildDeJong7(worldsize)
    maxCoordinate = worldsize / 2
    xy = 20 .* collect(-maxCoordinate:(maxCoordinate-1)) ./ maxCoordinate

    f(x, y) = sin(180 * 2 * x / pi) / (1 + abs(x)) + sin(180 * 2 * y / pi) / (1 + abs(y))
    f.(xy, xy')
end

"""
    spawn_particles!(model, n_particles = model.n_particles)

Populates the model with the specified nr of particles.
"""
function spawn_particles!(model)
    @inbounds for p in positions(model)
        if rand() < model.pPop
            add_agent_pos!(
                Particle(
                    nextid(model),          # id
                    (p) .- 0.5,              # pos (in center of patch)
                    Tuple(rand(2)),         # vel
                    1e301                   # Ridiculously high initial value
                ),
                model
            )
        end
    end
    return model
end

#-----------------------------------------------------------------------------------------

"""
    model_step!(world)

Simulate a Moran process, in which a random individual dies, and is replaced by a
child from a random neighbour, except that blues may have an evolutionary advantage AB.
"""
function model_step!(model)
    # if !model.initialized
    #     initialize_model!(model)
    # end


    return model
end

"""
This is the main stabilising procedure: somersault away if u is rising, but stay on track if
u is decreasing. Also, slow down if other agents are around. Finally, throw in some
random thermal motion - especially if you know there is somewhere better than this.
"""
function agent_step!(particle, model)
    uPrevious = particle.uLowest                  # Note previous value of u

    # Take a step forward, depending on speed:
    if rand() < particle.v
        move_agent!(particle, model)
    end

    # Remember the lowest value of u that I have yet found:
    u = model.patches[floor.(particle.pos)...]
    if u < particle.uLowest
        # u has dropped - note the fact:
        particle.uLowest = u
    elseif u > particle.uLowest + model.tolerance
        # u is significantly higher than my lowest so far. Spread dissatisfaction:
        particle.vel = 0.5 * (1 + particle.vel)
        for p in nearby_agents(particle, model)
            p.vel = 0.5 * (1 + p.vel)
        end
    end

    # Now somersault if things are going badly:
    if u > uPrevious
        # Things are getting worse - somersault:
        rotation = rand(-π:0.01:π)
        particle.vel = rotate_2dvector(rotation, vector)
    end

    # Stabilise speed if others are loitering here:
    if length(nearby_agents(particle, model)) > 0
        # There are Particles here - slow down:
        particle.vel *= 0.5
    else
        # Speed up:
        particle.vel = 0.5 * (1 + particle.vel)
    end

    # Thermal motion:
    if rand() < model.temperature
        # Randomly speed up:
        particle.vel = 0.5 * (1 + particle.vel)
    end

end

#-----------------------------------------------------------------------------------------

"""
    initialize_model!(model)

This method is needed to initialize the system. This is specially important to
reflect the adjustements made with the parameters on the abmplot.
"""
function initialize_model!(model)
    setPatches!(model)
    model.initialized = true
    return model
end

#-----------------------------------------------------------------------------------------

"""
    demo()

creates an interactive abmplot of the PSO module to visualize
Particle Swarm Optimizations.
"""
function demo()
    params = Dict(
        :deJong7 => [false, true]
    )

    plotkwargs = (
        add_colorbar=false,
        heatarray=:patches,
        heatkwargs=(
            # colorrange=(-8, 0),
            colormap=cgrad(:ice),
        ),
        as=10,
        ac=:yellow,
        am=:circle,
        title="PSO:",
    )

    model = create_model()
    fig, p = abmexploration(model; (agent_step!)=dummystep, model_step!, params, plotkwargs...)
    fig
end

# TODO: outsource function (taken from Stefans 2nd chapter)
function rotate_2dvector(rotation, vector)

    if rotation >= 0.0
        vector = Tuple([cos(rotation) -sin(rotation); sin(rotation) cos(rotation)] * [vector[1] vector[2]]')
    else
        vector = Tuple([cos(rotation) sin(rotation); -sin(rotation) cos(rotation)] * [vector[1] vector[2]]')
    end
end

# model = create_model()

end # ... of module PSO