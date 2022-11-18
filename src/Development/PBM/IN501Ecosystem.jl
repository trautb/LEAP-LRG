"""
	IN501Ecosystem

Module Ecosystem: In this model, Turtles move around a world,
eating algae to gain energy, reproduce if they have enough energy
and die if they can't find algae to eat. Overall it represents a
simple simulation of an ecosystem containing turtles and algae which
interact with each other, directly and indirectly.

Author: Niall Palfreyman (January 2020), Dominik Pfister (July 2022)
"""

module Ecosystem

export demo                # Externally available names
using Agents, GLMakie, InteractiveDynamics   # Required packages

include("./AgentToolBox.jl")
import .AgentToolBox: rotate_2dvector, polygon_marker, reinit_model_on_reset!


#-----------------------------------------------------------------------------------------
# Module definitions:

#-----------------------------------------------------------------------------------------
"""
	Turtle

To construct a new agent implementation, use the @agent macro and add all necessary extra
attributes. Again, id, pos and vel are automatically inserted.
"""
@agent Turtle ContinuousAgent{2} begin
	speed::Float64		# represents the turtle's speed when moving
	energy::Float64		# current energy of the turtle
	Δenergy::Float64	# energy-gain when turtle eats
end

#-----------------------------------------------------------------------------------------
# Module methods:

#-----------------------------------------------------------------------------------------
"""
	initialize_model()

Create the world model.
"""
function initialize_model(;
	n_turtles=50,			# initial number of turtles
	dims=(40, 40),			# dimensions of world inside model
	turtle_speed=1.0,		# value for turtle-speed
	regrowth_chance=0.001,	# chance for algae regrowth
	initial_energy=100.0,	# maximum initial energy of a turtle
	Δenergy_turtle=3.0		# energy gain when turtle eats
)

	# generate world for agents
	space2d = ContinuousSpace(dims, 1.0)

	# set model properties
	properties = Dict(
		:fully_grown => falses(dims), 			# represents the algae
		:regrowth_chance => regrowth_chance, 	# chance for algae regrowth
		:initial_energy => initial_energy,		# initial_energy for the whole model
		:n_turtles => n_turtles,                # initial number of turtles
		:Δenergy_turtle => Δenergy_turtle,      # energy gain when turtle eats
		:turtle_speed => turtle_speed,			# value for turtle-speed
	)

	# Generate model with agent, world, model-properties and order of agent steps
	model = ABM(Turtle, space2d; properties, scheduler=Schedulers.randomly)

	# add n_turtles to the model with random initial energy, random initial velocity 
	# and predefined values for speed and Δenergy_turtle
	for _ in 1:n_turtles
		energy = rand(1:model.initial_energy)
		vel = (rand(-1:0.01:1), rand(-1:0.01:1))
		turtle = Turtle(nextid(model), (0.0, 0.0), vel, turtle_speed, energy, Δenergy_turtle)
		add_agent!(turtle, model) # adds the turtle at a random position to the model
	end

	# algae initial growth state
	# initialize algae at every position as grown
	for p in positions(model)
		fully_grown = true
		model.fully_grown[p...] = fully_grown
	end

	return model
end

#-----------------------------------------------------------------------------------------
"""
	agent_step!(turtle, model)

A turtle has a chance to move forward, eats algae if there is one at its position,
dies if its energy falls below zero and reproduces if its energy is above the
models initial_energy.
"""
function agent_step!(turtle, model)

	# only let a certain amount of turtles move
	if rand() < 0.1
		rotation = rand() * ((1 / 36) * π) * rand([-1, 1])
		turtle.vel = rotate_2dvector(rotation, turtle.vel)
		move_agent!(turtle, model, turtle.speed)           # TODO: for compatibility in Agents@5.4 change to `dt=turtle.speed`
		turtle.energy -= 1 # reduce turtle energy from walking
	end

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

#-----------------------------------------------------------------------------------------
"""
	turtle_eat!(turtle, model)

Lets a turtle eat the algae at its position if there is any.
If a turtle eats algae it gains a feeding-benefit towards its energy.
At the turtles position update grown-property of algae to false
"""

function turtle_eat!(turtle, model)
	position = ceil.(Int, turtle.pos) # normalize position and convert to Int to use it as an index
	if model.fully_grown[position...]
		turtle.energy += turtle.Δenergy
		model.fully_grown[position...] = false
	end
end

#-----------------------------------------------------------------------------------------
"""
	reproduce!(agent, model)

Lets a parent-turtle create a child-turtle with the same properties as the parent.
Reproduction costs the parent-turtle the models initial_energy, which is given to the child.
"""
function reproduce!(agent, model)
	agent.energy = agent.energy - model.initial_energy
	offspring = Turtle(
		nextid(model),
		agent.pos,
		agent.vel,
		agent.speed,
		model.initial_energy,
		agent.Δenergy,
	)
	add_agent_pos!(offspring, model) # add the agent to the model at its own position
	return
end

#-----------------------------------------------------------------------------------------
"""
	model_step!(model)

Each algae-position that doesn't have algae on it has a chance to regrow at every model_step
"""
function model_step!(model)
	@inbounds for p in positions(model) # we don't have to enable bound checking
		if !(model.fully_grown[p...])
			if rand() < model.regrowth_chance
				model.fully_grown[p...] = true
			end
		end
	end
end

#-----------------------------------------------------------------------------------------

"""
	demo()

Creates an interactive abmplot of the Ecosystem module to visualize
a simple ecosystem.
"""
function demo()

	params = Dict(
		:n_turtles => 1:200,
		:turtle_speed => 0.1:0.1:3.0,
		:regrowth_chance => 0:0.0001:0.01,
		:initial_energy => 10.0:200.0,
		:Δenergy_turtle => 0:0.1:5.0,
	)

	# instructions for algaecolor for abm_plot
	algaecolor(model) = model.fully_grown 

	# define heatmap-colors and range of values
	heatkwargs = (colormap=[:black, :green], colorrange=(0, 1)) 

	plotkwargs = (
		ac=:white, 				# agents color (ac)
		am=polygon_marker, 		# agents marker
		heatarray=algaecolor, 	# sets value-calculation for heatmap
		heatkwargs=heatkwargs, 	# sets heatmap-arguments
		add_colorbar=false,
	)

	model = initialize_model()

	fig, p = abmexploration(
		model;
		(agent_step!)=agent_step!,
		(model_step!)=model_step!,
		params,
		plotkwargs...
	)
	reinit_model_on_reset!(p, fig, initialize_model)

	fig
end


end # ... end of module Ecosystem