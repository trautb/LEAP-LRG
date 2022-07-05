#========================================================================================#
"""
	IN511PSO

**Module PSO**: \\
This model demonstrates how swarms of particles can solve a minimisation 
problem - and also the major difficulty of swarm techniques: suboptimisation.


Author: Niall Palfreyman (April 2020), Nick Diercksen (May 2022)
"""
module PSO

export demo                # Externally available names
using Agents, GLMakie, InteractiveDynamics      # Required packages
import Statistics: norm                      # magnitude of vector

include("./AgentToolBox.jl")
import .AgentToolBox: rotate_2dvector, buildDeJong7, buildValleys

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

    # Initialise u with a multimodal function
    patches = deJong7 ? buildDeJong7(worldsize) : buildValleys(worldsize)

    properties = Dict(
        :patches => patches,
        :pPop => pPop,
        :temperature => temperature,
        :tolerance => tolerance,
        :deJong7 => deJong7,
        :meanPosition => extent ./ 2
    )

    model = ABM(Particle, ContinuousSpace(extent, 1); properties=properties)
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


"""
    spawn_particles!(model, n_particles = model.n_particles)

Distribute Particles across the world (depedending on `pPop`).
"""
function spawn_particles!(model)
    @inbounds for p in positions(model)
        if rand() < model.pPop
            add_agent_pos!(
                Particle(
                    nextid(model),              # id
                    (p) .- 0.5,                 # pos (in center of patch)
                    rVel(),                     # vel: magnitude ∈ [0,1]
                    1e301                       # Ridiculously high initial value
                ),
                model
            )
        end
    end
    return model
end


"""
    rVel()

creates a random velocity vector with a magnitude ∈ ]0,1[
"""
function rVel()
    r = (rand(), rand())
    vel = (2 .* r .- 1)
    rand() .* vel ./ norm(vel)
end



#-----------------------------------------------------------------------------------------

"""
    model_step!(model)

calculates the mean position of all particles
"""
function model_step!(model)
    m = (0.0, 0.0)
    particles = model.agents
    @inbounds for (_, p) in particles
        m = m .+ p.pos
    end
    model.meanPosition = m ./ length(particles)

    return model
end

"""
    agent_step!(particle, model)

This is the main stabilising procedure: somersault away if u is rising, but stay on track if
u is decreasing. Also, slow down if other agents are around. Finally, throw in some
random thermal motion - especially if you know there is somewhere better than this.
"""
function agent_step!(particle, model)
    uPrevious = particle.uLowest                  # Note previous value of u

    # Take a step forward, depending on speed:
    if rand() < norm(particle.vel)
        move_agent!(particle, model)
    end

    # Remember the lowest value of u that I have yet found:
    u = model.patches[ceil.(Integer, particle.pos)...]
    if u < particle.uLowest
        # u has dropped - note the fact:
        particle.uLowest = u
    elseif u > particle.uLowest + model.tolerance
        # u is significantly higher than my lowest so far. Spread dissatisfaction:
        particle.vel = speed_up(particle.vel)
        @inbounds for p in nearby_agents(particle, model)
            p.vel = speed_up(p.vel)
        end
    end

    # Now somersault if things are going badly:
    if u > uPrevious
        # Things are getting worse - somersault:
        φ = rand(π/2:.01:3/2*π)
        particle.vel = rotate_2dvector(φ, particle.vel)
    end

    # Stabilise speed if others are loitering here:
    if length(collect(nearby_agents(particle, model, 1.2))) > 0
        # There are Particles here - slow down:
        particle.vel = 0.3 .* particle.vel
    else
        # Speed up:
        particle.vel = speed_up(particle.vel)
    end

    # Thermal motion:
    if rand() < model.temperature
        # Randomly speed up:
        particle.vel = speed_up(particle.vel)
    end

end

"""
speed_up(vel)

increases the velocity `vel` by 
"""
# speed_up(vel) = vel ./ (0.5 * (1 + norm(vel)))
function speed_up(vel)
    if any(x -> (abs(x) < 1e-302), vel)
        # avoiding Inf values (that would result if normal speed up is applied)
        return rVel()
    end
    oldM = norm(vel)
    newM = 0.5 * (1.0 + oldM)
    newVel = (newM / oldM) .* vel
    return newVel
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
            colormap=cgrad(:ice),
        ),
        as=8,
        ac=:yellow,
        am=:circle,
        title="PSO:",
    )

    model = create_model()
    fig, p = abmexploration(model; (agent_step!)=agent_step!, model_step!, params, plotkwargs...)

    # as soon as meanPosition gets an update (after each step), the scatter will be updated
    m = lift(m -> m.meanPosition, p.model)
    scatter!(m, color=:red, markersize=20)

    # TODO: add deJong7 
    # dJ = lift(m -> println(m.deJong7), p.model)
    # println(dJ)

    # @lift(println($(p.model.val.deJong7)))

    fig
end


end # ... of module PSO