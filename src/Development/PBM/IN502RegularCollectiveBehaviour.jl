module CollectiveBehaviour
using Agents
using InteractiveDynamics, GLMakie,LinearAlgebra
export demo
mutable struct Particle <: AbstractAgent
    id::Int                    # Boid identity
    pos::NTuple{2,Float64}              # Position of boid
    vel::NTuple{2,Float64}              # Velocity direction of boid
    speed::Float64                      # Speed of boid
    size::Float64
    cic::Float64
end
function initialize_model(;
    n_particles = 50,
    speed  = 0.001,
    size = 1.5,
    cic = 0.0001
)
space2d = ContinuousSpace((100,100), 1.0)
model = ABM(Particle, space2d, scheduler = Schedulers.randomly)
for _ in 1:n_particles
    π = 3.1415926535897
    vel = Tuple(rand(model.rng,2))
    add_agent!(
        model,
        vel,
        speed,
        size,
        cic
    )
    end
    return model
end
function agent_step!(particle,model)
    π = 3.1415926535897
    particle.cic += 0.5*π
    particle.vel = particle.pos.+(particle.vel .* sin(particle.cic))
    move_agent!(particle,model,particle.speed)
end
function demo()
    model = initialize_model()
    #abmvideo(										# ... then make a pretty video of it.
    #    "boids.mp4", model, agent_step!;
    #    framerate = 20,
    #    frames = 5000,
    #    title = "Boids"
    #)
    plotkwargs = (;scatterkwargs = (strokewidth = 1.0),)
    fig, p = abmexploration(model;
    agent_step!, params = Dict(), plotkwargs)

    fig
end

end