
module Kull

export Turtle1, demo1

using Agents, LinearAlgebra
using Random # hides
using Pkg
Pkg.add("CairoMakie")
Pkg.add("GLMakie")
Pkg.status("InteractiveDynamics")
using InteractiveDynamics
using GLMakie

mutable struct Turtle1 <: AbstractAgent
    id::Int
    pos::NTuple{2,Float64}
    vel::NTuple{2,Float64}
    speed::Float64
    energy::Int64
    feeding::Bool
    geneticRadius::Float64
    developRadius::Float64
    color::Symbol
end

function initialize_model(;
     popRate = 0.2,
     extent = (40, 40),
     popMax =  popRate * (40*40),
     initEnergy = 15,
     birthEnergy = 5,
     searchSpeed = 15,
     muRate = 0.01,   # Around 3 mutations per generation
     muExtent = 0.1,
     foodRadius = 6.0,
     reactionNorm = 1,
     foodBenefit = 3,)       # Mutations within 10% of parental value)

    properties  =  Dict(
                        :popRate => popRate,
                        :initEnergy => initEnergy,
                        :birthEnergy => birthEnergy,
                        :searchSpeed =>  searchSpeed,
                        :muRate => muRate,
                        :muExtent => muExtent,
                        :foodRadius => foodRadius,
                        :reactionNorm => reactionNorm,
                        :foodBenefit => foodBenefit,
                        :popMax => popMax,
                        )
    # Initialise Cell population
    space2d = ContinuousSpace(extent)
    model = ABM(Turtle1, space2d; properties, scheduler = Schedulers.randomly) 
    feeding = false
    geneticRadius = Float64(20)
    developRadius = Float64(geneticRadius)
    color = :blue
    map(x-> if rand()<popRate add_agent!(
                        Tuple(x),
                        model,
                        ((rand(-1.0:0.01:1.0), rand(-1.0:0.01:1.0))),
                        rand(),
                        initEnergy,
                        feeding,
                        geneticRadius,
                        developRadius,            
                        color,
                        ) end,CartesianIndices(( 1:(extent[1]-1), 1:(extent[2]-1))))

    return model
end

function agent_step!(turtle1, model)
    live(turtle1,model)
    feed(turtle1,model)
    giveBirth(turtle1, model)
    setColor(turtle1,model)
    if turtle1.energy < 0 
        kill_agent!(turtle1, model)
    end
end

function live(turtle1,model)
  if !turtle1.feeding 
    turtle1.vel = ((rand(-1.0:0.01:1.0), rand(-1.0:0.01:1.0)))
    turtle1.speed = rand(3:1:model.searchSpeed)                                           # Move forward:
    move_agent!(turtle1,model,turtle1.speed)
  end
  turtle1.energy = turtle1.energy - 1             # Age
end

function feed(turtle1, model)
  if !turtle1.feeding
    # Still moving - check if inside developmental search radius:
    d = norm(collect(turtle1.pos) - collect((20.0, 20.0)))
    if d <= turtle1.developRadius 
      # Stop inside developmental search radius:
      turtle1.feeding = true
      if d <= model.foodRadius 
        # I'm also inside the food radius - I actually get something to eat!
        turtle1.energy = turtle1.energy + model.foodBenefit*model.initEnergy
      end
    end
  end
end

function giveBirth(turtle1, model)
    if turtle1.energy > model.birthEnergy && length(model.agents) < model.popMax 
    # I've got enough energy and there's sufficient space to have kids:
        parentRadius = turtle1.geneticRadius           # Store parental geneticRadius

        add_agent!(
                model,
                ((rand(-1.0:0.01:1.0), rand(-1.0:0.01:1.0))),
                rand(),
                rand(1:1:model.initEnergy),
                false,
                turtle1.geneticRadius,
                turtle1.developRadius,            
                :blue,
                )

        # Baby mutates genetic feeding radius?
        if rand() < model.muRate 
          # Yes - mutate parental geneticRadius:
          model[first(model.agents)[1]].geneticRadius = min(40, (parentRadius * (1 + model.muExtent * (1 - 2 * rand()))) )
        else
          # No - inherit parental geneticRadius:
          model[first(model.agents)[1]].geneticRadius = parentRadius
        end

        # Baby develops plastically altered feeding radius?
        if model.reactionNorm == 0 
            model[first(model.agents)[1]].developRadius = model[first(model.agents)[1]].geneticRadius
        elseif model.reactionNorm == 1 
            model[first(model.agents)[1]].developRadius = (model[first(model.agents)[1]].geneticRadius * rand())
        else# Yes:
            model[first(model.agents)[1]].developRadius = max(0, (rand([model[first(model.agents)[1]].geneticRadius,(model.reactionNorm * model[first(model.agents)[1]].geneticRadius)])))
        end

        # Mark visually how 'good' my resulting feeding radius is:
        setColor(model[first(model.agents)[1]],model)
        println(length(model.agents))
        turtle1.energy=turtle1.energy - model.birthEnergy
   end
end

function setColor(turtle1,model)
  if turtle1.developRadius < model.foodRadius 
    # Agents with good developmental radius are white:
    turtle1.color = :gray
  elseif  turtle1.developRadius < (5 * model.foodRadius) 
      # Agents with decent developmental radius are green:
      turtle1.color = :lime
  else
      # Agents with crappy developmental radius are blue:
      turtle1.color = :blue
  end
end

function demo1()
  model = initialize_model()

  params = Dict(:foodRadius => 1:0.1:10,
                :reactionNorm => 0:0.1:1,
              :foodBenefit => 0:1:5)
  #create the interactive plot with our sliders
  cellcolor(a::Turtle1) = a.color
  fig, p = abmexploration(model; agent_step! = agent_step!, params, ac = cellcolor)
  fig
end
end