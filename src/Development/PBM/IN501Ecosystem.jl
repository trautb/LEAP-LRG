#============================================================================================
;; 01Ecosystem
;; This model implements a population of turtles that randomly swim around the world, eating
;; algae that can regrow.
;;
;; Authors:
;;   Niall Palfreyman.
;;
;; Date: January 2020.
;;============================================================================================
;;============================================================================================
;;Global parameters of the model.
;;============================================================================================
#
using Agents

# Module definitions

initialEnergy # Initial energy of a turtle

# Define the attributes of turtles

@agent Turtle ContinuousAgent{2} begin
	energy::Int64 # the slowly declining life-energy of a turtle
end

@agent Algae GridAgent{2} begin
    growthState::Int64
end

#-----------------------------------------------------------------------------------------
# Module methods:

#-----------------------------------------------------------------------------------------
"""
	simpleworld(n)

Create a simple world containing n agents at random locations.
"""
function simpleworld( n::Int)
	# The world is continuous and 2-D, divided into 100×100 cells of width 1.0:
    growthState = 2
	regrowthChance = 0.03


	space = GridSpace( (100, 100))
	properties = (
		growthState = GrowthState,
		regrowthChance = regrowthChance,
	)

	world = ABM( Turtle, ContinuousSpace( (100,100), 1.0))

	# Add the n agents:
	for _ in 1:n
		add_agent!( world, Tuple(rand(1:5,2)), rand(1:9))
	end

	world
end

#=
;;============================================================================================
;; Setup Procedures
;;============================================================================================
;---------------------------------------------------------------------------------------------
; setup: Observer procedure
; Initialise all variables, patches and turtles. Notice that inline comments are vertically
; aligned!
;---------------------------------------------------------------------------------------------
to setup
  clear-all             ; Clear all variable values
                        ; Blank lines separate logically separate sections of code
  set initialEnergy 50  ; Set the global value of the lifespan of a turtle

  setup-patches         ; Initialise all patches
  setup-turtles         ; Initialise all turtles

  reset-ticks           ; Reset the system clock
end

;---------------------------------------------------------------------------------------------
; setup-patches: Observer procedure
; Put green algae on all patches. Notice the position of brackets in a [] code block!
;---------------------------------------------------------------------------------------------
to setup-patches
  ask patches [
    set pcolor green
  ]
end

;---------------------------------------------------------------------------------------------
; setup-turtles: Observer procedure
; Position all turtles randomly in the world.
;---------------------------------------------------------------------------------------------
to setup-turtles
  crt nTurtles [
    setxy random-xcor 0
    set energy random initialEnergy
  ]
end

;;============================================================================================
;; Runtime Procedures
;;============================================================================================
;---------------------------------------------------------------------------------------------
; go: Observer procedure
; Main simulation driver
;---------------------------------------------------------------------------------------------
to go
  if ticks >= 500 [
    stop
  ]
  step-turtles
  eat-algae
  reproduce
  check-death
  regrow-algae
  tick
end

;---------------------------------------------------------------------------------------------
; step-turtles: Observer procedure
; All turtles move approximately forward one step, and age by losing energy.
;---------------------------------------------------------------------------------------------
to step-turtles
  ask turtles [
    right random 20
    left random 40
    forward 1
    set energy energy - 1
  ]
end

;---------------------------------------------------------------------------------------------
; eat-algae: Observer procedure
; All turtles on algae eat the algae and so gain energy.
;---------------------------------------------------------------------------------------------
to eat-algae
  ask turtles [
    if pcolor != black [
      set pcolor black
      set energy energy + 10
    ]
    ifelse show-energy? [
      set label energy
    ] [
      set label ""
    ]
  ]
end

;---------------------------------------------------------------------------------------------
; reproduce: Observer procedure
; All turtles with sufficient energy have a baby, and lose energy doing so.
;---------------------------------------------------------------------------------------------
to reproduce
  ask turtles [
    if energy > initialEnergy [
      set energy energy - initialEnergy
      hatch 1 [
        set energy initialEnergy
      ]
    ]
  ]
end

;---------------------------------------------------------------------------------------------
; check-death: Observer procedure
; All turtles with zero energy die.
;---------------------------------------------------------------------------------------------
to check-death
  ask turtles [
    if energy <= -10 [
      die
    ]
  ]
end

;---------------------------------------------------------------------------------------------
; regrow-algae: Observer procedure
; Algae regrow on an empty patch with a probability of 3%.
;---------------------------------------------------------------------------------------------
to regrow-algae
  ask patches with [pcolor = black] [
    if random 100 < 3 [
      set pcolor blue
    ]
  ]
end
=#=#

using Pkg
using Agents, Random

mutable struct Turtle <:AbstractAgent
    id::Int
    pos::Dims{2}
    energy::Float64
    Δenergy::Float64
end

function initialize_model(;
  n_turtles = 100, # number of turtles
  dims = (20, 20), # size of world
  regrowth_chance = 0.2, # time for algae to regrow
  initial_energy = 30,
  Δenergy_turtle = 4, # energy gain when turtle eat algae
  seed = 23182, # Seed for randomization
)

  rng = MersenneTwister(seed) # set randomness to seed
  space = GridSpace(dims, periodic = false) # Create environment with size 20/20 and a border(periodic false)
  # Model properties contain the algae as two arrays: whether it is fully grown
  # and the time to regrow. Also have static parameter `regrowth_time`.
  # Notice how the properties are a `NamedTuple` to ensure type stability.
  properties = ( # Setting up algae via world properties
      fully_grown = falses(dims), # status of algae
      regrowth_chance = regrowth_chance, # chance for algae regrowth
      initial_energy = initial_energy
  )
  # create AgentBasedModel with AgentType SheepWolf 
  # (agents are stored in a dictionary which can be accessed via model[id]),
  # world = space, the specified model properties, the set randomness rng,
  # Scheduler defines the order of which agents use the step! function
  model = ABM(Turtle, space; properties, rng, scheduler = Schedulers.randomly)
  id = 0
  for _ in 1:n_turtles
      id += 1
      energy = model.initial_energy # give turtles initial energy
      # create sheep instance with current id, position at (0,0), random energy
      # and the specified sheep reproduce chance and energy gain from eating
      turtle = Turtle(id, (0, 0), energy, Δenergy_turtle)
      add_agent!(turtle, model) # add agent to model
  end
  # algae initial growth state
  for p in positions(model) # for every position of all positions in model 
      fully_grown = true # generate a fully grown world
      model.fully_grown[p...] = fully_grown # set grown-value in model for position p
  end
  return model
end

function turtle_step!(turtle, model)
  walk!(turtle, rand, model) # makes the agent move in a random direction of the 8 adjanced tiles
  turtle.energy -= 1 # reduce turtle energy from walking
  turtle_eat!(turtle, model) # let turtle eat
  if turtle.energy < 0
      kill_agent!(turtle, model) # kill turtle if energy is below 0
      return
  end
  # let turtle reproduce if it has enough energy
  if turtle.energy >= model.initial_energy
      reproduce!(turtle, model)
  end
end

function turtle_eat!(turtle, model)
  if model.fully_grown[turtle.pos...] # is grass fully grwon at position of turtle
      turtle.energy += turtle.Δenergy # add feeding-benefit to energy of turtle
      model.fully_grown[turtle.pos...] = false # set grown-property of grass to false
  end
end

function reproduce!(agent, model)
  agent.energy = agent.energy - model.initial_energy # get half of energy of the agent that wants to reproduce
  id = nextid(model) # get a new id for the new agent
  offspring = Turtle( # generate a new agent with the new id and the same properties of its parent
      id,
      agent.pos,
      model.initial_energy,
      agent.Δenergy,
  )
  add_agent_pos!(offspring, model) # add the agent to the model at its own position
  return
end

# grass regrowth

function grass_step!(model)
  @inbounds for p in positions(model) # we don't have to enable bound checking
      if !(model.fully_grown[p...]) # if position p isnt fully grown
          if rand(1)[1] < model.regrowth_chance # if countdown of p is smaller or equal to 0
              model.fully_grown[p...] = true # set p as regrown
          end
      end
  end
end


using InteractiveDynamics
using CairoMakie

# To view our starting population, we can build an overview plot using abm_plot. 
# We define the plotting details for the wolves and sheep:

#offset(a) = a.type == :sheep ? (-0.7, -0.5) : (-0.3, -0.5) # give agents-marker offset for
# better visualization when two different agents are at the same position
ashape(a) = :utriangle # sheep are circles and wolves are triangles
acolor(a) = RGBAf(1.0, 1.0, 1.0, 0.8) # set colors for agents

grasscolor(model) = model.fully_grown # instructions for grasscolor for abm_plot

heatkwargs = (colormap = [:black, :green], colorrange = (0, 1)) # define heatmap-colors and range of values

plotkwargs = ( # collection of plot arguments
    # define ac, as and am by either giving them constants or "decision"-Functions
    # here we give as a constant value and both ac and am "decision"-Functions
    ac = acolor, # agents color (ac)
    as = 15, # agents size
    am = ashape, # agents marker
    heatarray = grasscolor, # sets value-calculation for heatmap
    heatkwargs = heatkwargs, # sets heatmap-arguments
)

#fig, _ = abm_plot(model; plotkwargs...) # generates the plotted figure of the model with its plot-arguments
#fig

# for data-collection

#sheep(a) = a.type == :sheep # is agent a sheep?
#wolves(a) = a.type == :wolf # is agent a wolf?
#count_grass(model) = count(model.fully_grown) # counts total number of fully grown grass

#= Run simulation:

model = initialize_model()
n = 500 # number of steps
adata = [(sheep, count), (wolves, count)] # number of sheep and wolves
mdata = [count_grass] # model-data: amount of fully grown grass
# run model with the respective agents steps for n steps, meanwhile collect data about adata and mdata
# return data as agentdataframe (adf) and modeldataframe (mdf)
adf, mdf = run!(model, sheepwolf_step!, grass_step!, n; adata, mdata)
=#
# if a video is wanted:
# define model
model = initialize_model(
    n_turtles = 50,
    dims = (25, 25),
    regrowth_chance = 0.02, # time for algae to regrow
    initial_energy = 30,
    Δenergy_turtle = 8, # energy gain when turtle eat algae
    seed = 23182, # Seed for randomization
)
# generate video of model
abmvideo(
    "Documents/VSC Julia/Videos/turtles.mp4", # name of file
    model, # model for simulation
    turtle_step!, #steps
    grass_step!; # steps
    frames = 150, # frames for video
    framerate = 8, # frames pre second
    plotkwargs..., # plot-arguments
)
#