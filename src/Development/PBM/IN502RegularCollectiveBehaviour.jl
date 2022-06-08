
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

function initialize_model(;n_particles = 20,globaldist = zeros(n_particles,2),tick=0,meadist=0,worldsize,psize,griddims = (worldsize, worldsize),particle_speed)
space2d = ContinuousSpace(griddims, 1.0)
#=
properties = Dict(
    globaldist => globaldist,
    tick => tick,
    meadist => meadist
)
=#
properties = Dict(
    globaldist => globaldist,
    tick => tick,
    meadist => meadist
)
properties[:globaldist] = zeros(n_particles,2)
properties[:tick] = 0
properties[:meadist] = 0.0

#zeros(n_particles,2);
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
    model.globaldist = dist
    model.meadist = mean(dist,dims=1)[1];
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
        dist = particle.pos .- Tuple([100/2 100/2])
        model.globaldist[particle.id,:] = [dist[1] dist[2]]' #ändern
    end
    
end

function model_step!(model)
    model.meadist = mean(model.globaldist,dims=1)[1];
    model.tick += 1
end

function demo(world_size,particle_size,particle_speed)
    model = initialize_model(worldsize = world_size,psize=particle_size,particle_speed=particle_speed);
    
    #rintln(:maedist)
    #dist = mean(model.globaldist,dims=1)
    #println(model.maedist)
    #-----------------------
    println("her")

    println(model.meadist)
    #:meadist = rand(0:10)
    mdata = [:meadist]

    #-----------------------
    #plotkwargs = (
    #heatarray = :patches,

    #heatkwargs = (
    #    colorrange = (0, 1),
    #    colormap = [:brown, :green]
    #),
    
    #)

    #p = lines!( model_step!, model.globaldist, color = :red)
    #agent_df, model_df =run!(model, agent_step!, model_step!, 1000; mdata = mdata)
    #agent_df, model_df =run!(model, agent_step!, model_step!, model.tick; mdata = mdata)
    figure,p= abmexploration(model;model_step!,agent_step!,params = Dict(),am = particle_marker,mdata)#,plotkwargs...);
    plot_layout = figure[:,end+1] = GridLayout()
    count_layout = plot_layout[1,1] = GridLayout()
    ax_counts = Axis(count_layout[1,1];
    backgroundcolor = :white, ylabel = "Meandist")
    #mea = @lift(Point2f.($(p.mdf).tick, $(p.mdf).meadist))
    #mea = @lift(Point2f.($(p.mdf).step, $(p.mdf).meadist))
    mea = @lift(Point2f.($(p.mdf).step, $(p.mdf).meadist))
    println("------------")
    agent_step = @lift($(p.mdf).step)
    agent_steps = to_value(agent_step)
    println(agent_steps[1])

    scatterlines!(ax_counts,mea)
    
    on(p.model) do m
        autolimits!(ax_counts)
    end
    step!(p,1);
    

   
    
    #figure[1, 3] = Axis(figure, ylabel = "main", textsize = 12)
    #ax1 = figure[1, 1] = Axis(p, ylabel = "main_plot", textsize = 12)
    #ax3 = p[1, 2] = Axis(p, ylabel = "temperature", textsize = 12)
    #xs = 0:0.01:12
    #ys = 0.5 .* sin.(xs)
    #lines!(figure[1, 3],mdata[!, :step], mdata[!, :meadist])
    #lines!(ax3, model_df[!, :step], model_df[!, :maedist], color = :red)
    figure;

    #fig, p = abmexploration(model;agent_step!,model_step!,params = Dict(),am = particle_marker)#, mdata= mdata, mlabels  = ["plot","p"])#,plotkwargs...);
    
end

end
