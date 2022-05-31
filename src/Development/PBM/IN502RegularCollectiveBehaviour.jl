module CollectiveBehaviour
using Agents
using InteractiveDynamics, GLMakie,LinearAlgebra, Random, Statistics
export demo
mutable struct Particle <: AbstractAgent
    id::Int                    # Boid identity
    pos::NTuple{2,Float64}              # Position of boid
    vel::NTuple{2,Float64}              # Velocity direction of boid
    speed::Float64                      # Speed of boid
    rot::Float64
    size:: Float64
    mdist:: NTuple{2,Float64}  
end

function rotate_2dvector(rotation,vector)

    if rotation>=0.0
        vector = Tuple([cos(rotation) -sin(rotation); sin(rotation) cos(rotation)]*[vector[1] vector[2]]');
    else
        vector = Tuple([cos(rotation) sin(rotation); -sin(rotation) cos(rotation)]*[vector[1] vector[2]]');
    end
end

function initialize_model(;n_particles = 20,mdist = 0.0,worldsize,psize,griddims = (worldsize, worldsize),particle_speed)
space2d = ContinuousSpace(griddims, 1.0)


properties = (
    globaldist = zeros(n_particles,2) ,
    tick = 0,
    meadist =  0.0
    )
#properties["globaldist"] = zeros(n_particles,2)
#properties["meadist"] = 0.0

model = ABM(Particle,space2d, scheduler = Schedulers.randomly,properties = properties)


#for I in CartesianIndices(model.patches)
#    model.patches[I] =  rand(0:1)
#end
dist = zeros(n_particles,2)
counter = 1
for _ in 1:n_particles
    size = psize
    speed  = particle_speed;
    π = 3.1415926535897
    rot = rand(0:0.1:2π)
    vel = rotate_2dvector(rot,[10 10])
    pos = Tuple([worldsize/2 worldsize/2]').+vel
    vel = rotate_2dvector(0.5*π,[vel[1] vel[2]])
    dist[counter,:] = [pos[1] pos[2]]
    mdist = pos
    add_agent!(
        pos,
        model,
        vel,
        speed,
        rot,
        size,
        mdist,
    )
    counter += 1
end
    globaldist = dist
    meadist = 0.0
    return model
end

function particle_marker(b::Particle;)
    particle_polygon = Polygon(b.size*Point2f[(-0.25, -0.25), (0.5, 0), (-0.25, 0.25)])
    φ = atan(b.vel[2], b.vel[1])
    scale(rotate2D(particle_polygon, φ), 2)
end

function agent_step!(particle,model)
    π = 3.1415926535897
    if rand()<0.1
        particle.rot = rand()*((1/36)*π);
        particle.vel= rotate_2dvector(particle.rot,particle.vel)
        move_agent!(particle,model,particle.speed);
        #model.globaldist[particle.id,:] = particle.pos .- Tuple([worldsize/2 worldsize/2]')
        #particle.mdist = mean(globaldist,dims=1);
        #model.meadist = mean(globaldist,dims=1)[1];
    end
    
end

function model_step!(model)
    for p in positions(model)
        model.meadist = mean(model.globaldist,dims=1)[1];
    end
    model.tick += 1
end

function demo(world_size,particle_size,particle_speed)
    model = initialize_model(worldsize = world_size,psize=particle_size,particle_speed=particle_speed);
    #rintln(:maedist)
    #dist = mean(model.globaldist,dims=1)
    #println(model.maedist)
    #-----------------------
    
    globaldist(model) = mean(model.globaldist,dims=1)[1]
    mdata = [globaldist, :meadist]
    
    #-----------------------
    #plotkwargs = (
    #heatarray = :patches,

    #heatkwargs = (
    #    colorrange = (0, 1),
    #    colormap = [:brown, :green]
    #),
    
    #)

    p = lines!( model_step!, model.globaldist, color = :red)
    agent_df, model_df =run!(model, agent_step!, model_step!, 1000; mdata = mdata)
    figure, p = abmexploration(model;agent_step!,params = Dict(),am = particle_marker)#,plotkwargs...);
     
    #ax1 = figure[1, 1] = Axis(p, ylabel = "main_plot", textsize = 12)
    #ax3 = p[1, 2] = Axis(p, ylabel = "temperature", textsize = 12)
    
    #lines!(ax3, model_step!, model.meadist, color = :red)
    #lines!(ax3, model_df[!, :step], model_df[!, :maedist], color = :red)
    figure;

    #fig, p = abmexploration(model;agent_step!,model_step!,params = Dict(),am = particle_marker)#, mdata= mdata, mlabels  = ["plot","p"])#,plotkwargs...);
    
end

end