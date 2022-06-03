using Agents
using InteractiveDynamics
using GLMakie

#=
mutable struct Patches <: AbstractAgent
    id::Int
    pos::NTuple{2,Float64}
    value::Int
end

dimsize = 20.0

modeldims = (dimsize, dimsize)
#patch_coords = map(tuple, (i for i in -20:1:20), (j for j in -20:1:20))
space = ContinuousSpace(modeldims, periodic=false)

model = ABM(Patches, space)

for x in (-1)*dimsize:1.0:dimsize
    for y in (-1)*dimsize:1:dimsize
        patch = Patches(nextid(model), (x,y), 1)
        add_agent!(patch, model)
    end
end

#acolor(a) = a.value == 1 ? RGBA(0,255,0,100) : RGBA(0,0,0,100)

#=
plotkwargs = ( # collection of plot arguments
    # define ac, as and am by either giving them constants or "decision"-Functions
    # here we give as a constant value and both ac and am "decision"-Functions
    ac = acolor, # agents color (ac)
    as = 15, # agents size
    am = :square, # agents marker
)
=#
#ashape(a) = :utriangle # sheep are circles and wolves are triangles
#acolor(a) = RGBAf(1.0, 1.0, 1.0, 0.8) # set colors for agents

#grasscolor(model) = model.fully_grown # instructions for grasscolor for abm_plot

#heatkwargs = (colormap = [:black, :green], colorrange = (0, 1)) # define heatmap-colors and range of values

plotkwargs = ( # collection of plot arguments
    # define ac, as and am by either giving them constants or "decision"-Functions
    # here we give as a constant value and both ac and am "decision"-Functions
    ac = RGBAf(0, 0.8, 0, 0.8), # agents color (ac)
    as = 15, # agents size
    am = :square, # agents marker
    #heatarray = grasscolor, # sets value-calculation for heatmap
    #heatkwargs = heatkwargs, # sets heatmap-arguments
)

abmplot(model; plotkwargs...) # generates the plotted figure of the model with its plot-arguments
=#

mutable struct Turtle <: AbstractAgent
    id::Int
    pos::NTuple{2,Float64}
    energy::Float64
    Δenergy::Float64
end


function initialize_model(;
    n_turtles=1, # number of turtles
    dims=(20, 20), # size of world
    regrowth_chance=0.2, # time for algae to regrow
    initial_energy=30,
    Δenergy_turtle=4, # energy gain when turtle eat algae
    seed=23182 # Seed for randomization
)

    #patch_coords = map(tuple, (i for i in -20:1:20), (j for j in -20:1:20))
    space = ContinuousSpace(dims, 1.0)

    properties = (
        patches=zeros(Int, 20, 20),
        regrowth_chance=regrowth_chance,
        initial_energy=initial_energy
    )

    model = ABM(Turtle, space; properties, scheduler=Schedulers.randomly)

    id = 0
    for _ in 1:n_turtles
        id += 1
        energy = model.initial_energy # give turtles initial energy
        # create sheep instance with current id, position at (0,0), random energy
        # and the specified sheep reproduce chance and energy gain from eating
        turtle = Turtle(id, (3.72, 1.48), energy, Δenergy_turtle)
        add_agent!(turtle, model) # add agent to model
    end

    for I in CartesianIndices(model.patches)
        model.patches[I] = rand(0:1)
    end

    model

end

#grasscolor(model) = rand([0,1],20,20) # instructions for grasscolor for abm_plot

heatkwargs = (colormap=[:black, :green], colorrange=(0, 1)) # define heatmap-colors and range of values

plotkwargs = ( # collection of plot arguments
    # define ac, as and am by either giving them constants or "decision"-Functions
    # here we give as a constant value and both ac and am "decision"-Functions
    heatarray=:patches, # sets value-calculation for heatmap
    heatkwargs=heatkwargs, # sets heatmap-arguments
)

#turtle = Turtle(1, (0.7, 0.3), 20, 5)
#add_agent!(turtle, model) # add agent to model

function turtle_step!(turtle, model)
    #walk!(turtle, rand, model) # makes the agent move in a random direction of the 8 adjanced tiles
    #turtle.energy -= 1 # reduce turtle energy from walking
    #turtle_eat!(turtle, model) # let turtle eat
    #if turtle.energy < 0
    #    kill_agent!(turtle, model) # kill turtle if energy is below 0
    #    return
    #end
    # let turtle reproduce if it has enough energy
    #if turtle.energy >= model.initial_energy
    #    reproduce!(turtle, model)
    #end
end

model = initialize_model()

fig, p = abmexploration(model; turtle_step!, dummystep, plotkwargs)

fig

#=
abmvideo(
    "Documents/VSC Julia/Videos/patchworld.mp4", # name of file
    model, # model for simulation
    turtle_step!, #steps
    frames = 150, # frames for video
    framerate = 8, # frames pre second
    plotkwargs..., # plot-arguments
)
=#
#=
abmvideo(
    "Documents/VSC Julia/Videos/patchworld.mp4", # name of file
    model, # model for simulation
    #turtle_step!, #steps
    #grass_step!; # steps
    frames = 150, # frames for video
    framerate = 8, # frames pre second
    plotkwargs..., # plot-arguments
)
=#

