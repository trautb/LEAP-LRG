module CollectiveBehaviour
using Agents
using InteractiveDynamics, GLMakie, Random, Statistics
export demo
#=
mutable struct Particle <: AbstractAgent
    id::Int                    # Boid identity
    pos::NTuple{2,Float64}              # Position of boid
    vel::NTuple{2,Float64}              # Velocity direction of boid
end
=#
ContinuousAgent{2}

function rotate_2dvector(rotation,vector)

    if rotation>=0.0
        vector = Tuple([cos(rotation) -sin(rotation); sin(rotation) cos(rotation)]*[vector[1] vector[2]]');
    else
        vector = Tuple([cos(rotation) sin(rotation); -sin(rotation) cos(rotation)]*[vector[1] vector[2]]');
    end
end

function einvec(vector)
    vector1 = vector[1]/sqrt((vector[1])^2+(vector[2])^2)
    vector2 = vector[2]/sqrt((vector[1])^2+(vector[2])^2)
    vector = Tuple([vector1, vector2])
end
function initialize_model(  ;n_particles::Int = 50,
                            meadist::Float64=0.0,
                            worldsize::Int64,
                            particlespeed::Float64,
                            globaldist = zeros(n_particles,1),
                            griddims = (worldsize, worldsize),
                            )
space2d = ContinuousSpace(griddims, 1.0)

properties = Dict(
    :globaldist => globaldist,
    :meadist => meadist,
    :particlespeed => particlespeed,
    :worldsize => worldsize,
)


model = ABM(ContinuousAgent,space2d, scheduler = Schedulers.fastest,properties = properties)
counter = 1
for _ in 1:n_particles
    vel = rotate_2dvector(rand(0:0.1:2π),[10 10])
    pos = Tuple([worldsize/2 worldsize/2]').+vel
    vel = einvec(rotate_2dvector(0.5*π,[vel[1] vel[2]]))
    model.globaldist[counter,1] = edistance(pos,Tuple([worldsize/2, worldsize/2]),model)
    add_agent!(
        pos,
        model,
        vel,
    )
    counter += 1
end
    
    return model
end

function particle_marker(p::ContinuousAgent;)
    particle_polygon = Polygon(Point2f[(-0.25, -0.25), (0.5, 0), (-0.25, 0.25)])
    φ = atan(p.vel[2], p.vel[1])
    scale(rotate2D(particle_polygon, φ), 2)
end

function randomcolor(number)
    

    if (number == 1)
        ac = :red
    elseif (number == 2)
        ac = :green
    else
        ac = :blue
    end
end
function agent_step!(particle,model)
    if rand()<0.1
        particle.vel= einvec(rotate_2dvector(rand()*((1/36)*π),particle.vel))
        move_agent!(particle,model,model.particlespeed);
        model.globaldist[particle.id,1] = edistance(particle.pos,Tuple([model.worldsize/2, model.worldsize/2]),model) #ändern
        model.meadist = mean(model.globaldist,dims=1)[1]

    end
    
end


function demo(world_size,particle_size,particle_speed)
    model = initialize_model(worldsize = world_size,particlespeed=particle_speed);

    mdata = [:meadist]
    figure,p= abmexploration(model;agent_step!,params = Dict(),as=particle_size,am = particle_marker,mdata)#,plotkwargs...);
    
    
    #=
    plot_layout = figure[:,end+1]
    count_layout = plot_layout[1,1] = GridLayout()
    ax_counts = Axis(count_layout[1,1];
    backgroundcolor = :white, ylabel = "Meandist")

    mea = @lift(Point2f.($(p.mdf).step, $(p.mdf).meadist))
    #https://makie.juliaplots.org/stable/examples/plotting_functions/scatterlines/
    scatterlines!(ax_counts,mea)
    
    on(p.model) do m
        autolimits!(ax_counts)
    end
    =#
    figure;
    
end

end
