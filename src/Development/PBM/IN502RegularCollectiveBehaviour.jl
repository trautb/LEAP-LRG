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
    size:: Float64
    
end

function rotate_2dvector(rotation,vector)

    if rotation>=0.0
        vector = Tuple([cos(rotation) -sin(rotation); sin(rotation) cos(rotation)]*[vector[1] vector[2]]');
    else
        vector = Tuple([cos(rotation) sin(rotation); -sin(rotation) cos(rotation)]*[vector[1] vector[2]]');
    end
end

function initialize_model(;n_particles = 20,worldsize,psize,griddims = (worldsize, worldsize))
space2d = ContinuousSpace(griddims, 1.0)

model = ABM(Particle, space2d, scheduler = Schedulers.randomly,properties = (patches = zeros(Int, griddims),))

for I in CartesianIndices(model.patches)
    model.patches[I] =  rand(0:1)
end
for _ in 1:n_particles
    size = psize
    speed  = 1.0;
    π = 3.1415926535897
    rot = rand(0:0.1:2π)
    vel = Tuple([cos(rot) -sin(rot); sin(rot) cos(rot)]*[10 10]');
    pos = Tuple([worldsize/2 worldsize/2]').+vel
    add_agent!(
        pos,
        model,
        vel,
        speed,
        rot,
        size,
    )
    end
    return model
end

function particle_marker(b::Particle;)
    π = 3.1415926535897
    particle_polygon = Polygon(b.size*Point2f[(-0.25, -0.25), (0.5, 0), (-0.25, 0.25)])
    φ = atan(b.vel[2], b.vel[1])
    scale(rotate2D(particle_polygon, φ), 2)
end

function agent_step!(particle,model)
    π = 3.1415926535897
    if rand()<0.1
        particle.rot = rand()*((1/36)*π);
        #particle.vel = Tuple([cos(particle.rot) -sin(particle.rot); sin(particle.rot) cos(particle.rot)]*[particle.vel[1] particle.vel[2]]');
        particle.vel= rotate_2dvector(particle.rot,particle.vel)
        move_agent!(particle,model,particle.speed);
    end
    
end
function demo()
    model = initialize_model(worldsize = 100,psize=2);
    plotkwargs = (
    heatarray = :patches,

    heatkwargs = (
        colorrange = (0, 1),
        colormap = [:brown, :green]
    ),
    
    )
    fig, p = abmexploration(model;agent_step!,params = Dict(),am = particle_marker,plotkwargs...);
    
    fig;
end

end