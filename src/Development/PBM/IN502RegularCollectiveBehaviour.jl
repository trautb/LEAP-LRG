module CollectiveBehaviour
using Agents
using InteractiveDynamics, GLMakie,LinearAlgebra, Random
export demo
mutable struct Particle <: AbstractAgent
    id::Int                    # Boid identity
    pos::NTuple{2,Float64}              # Position of boid
    vel::NTuple{2,Float64}              # Velocity direction of boid
    speed::Float64                      # Speed of boid
    rot::Float64
end
function initialize_model(;n_particles = 1)
space2d = ContinuousSpace((41,41), 1.0)

model = ABM(Particle, space2d, scheduler = Schedulers.randomly)

for _ in 1:n_particles
    speed  = 1.0;
    π = 3.1415926535897
    angle = rand(0:0.1:2π)
    println(angle)
    rot = angle
    vel = Tuple([cos(angle) -sin(angle); sin(angle) cos(angle)]*[10 10]');
    
    #vel = Tuple(rand(model.rng,2) * 1 .+ 0.1) #Random speed 1 to 2
    pos = Tuple([20.0 20.0]').+vel
    add_agent!(
        pos,
        model,
        vel,
        speed,
        rot,
    )
    end
    return model
end

function particle_marker(b::Particle)
    π = 3.1415926535897
    particle_polygon = Polygon(Point2f[(-0.25, -0.25), (0.5, 0), (-0.25, 0.25)])
    φ = atan(b.vel[1], b.vel[2])
    println(b.id," pm ",φ)
    scale(rotate2D(particle_polygon, φ), 2)
end

function agent_step!(particle,model)
    #=
    π = 3.1415926535897
    particle.cic += 0.1*π
    println(particle)
    println("-----------")
    #vector = [particle.vel[1]  particle.vel[2]]'
    vector = [1.0 1.0]'
    mat = [cos(particle.cic) -sin(particle.cic); sin(particle.cic) cos(particle.cic)]*vector #checked
    #println(vector)
    #println(mat)
    particle.vel = Tuple(mat) # .+ Tuple([1 1]')
    #particle.vel = Tuple([abs(particle.vel[1]-mat[1]) abs(particle.vel[2]-mat[2])]')
    #println(particle.vel)
    #println("-----------")
    =#
    π = 3.1415926535897
    if rand()<0.1
        #println(particle);
        #println(particle.id, " trigger");
        particle.rot = rand()*((1/36)*π);
        #println(particle.rot);
        particle.vel = Tuple([cos(particle.rot) -sin(particle.rot); sin(particle.rot) cos(particle.rot)]*[particle.vel[1] particle.vel[2]]');
        #paritcle.pos = particle.pos .+ vel;
        move_agent!(particle,model,particle.speed);
        #println(particle);
        #println("-----------");
    end
    
end
function demo()
    model = initialize_model();
    fig, p = InteractiveDynamics.abmexploration(model;agent_step!,params = Dict(),am = particle_marker);
    
    fig;
end

end