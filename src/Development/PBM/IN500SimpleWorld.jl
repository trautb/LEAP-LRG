#========================================================================================#
"""
	IN500SimpleWorld

Module IN500SimpleWorld: A Very Simple example of how to set up agents in a world.

Author: Niall Palfreyman, 26/04/22
"""
module SimpleWorld

export demo									# Externally available names of SimpleWorld
using Agents								# Required packages

#-----------------------------------------------------------------------------------------
# Module definitions:

"""
	Turtle

To construct a new agent implementation, derive it from AbstractAgent and add all necessary
attributes. The @gent macro does this automatically, also inserting the fields id, pos and vel.
speed is our own field, defining distance of travel in one step. Our use of the @agent macro
is equivalent to the following code:

	mutable struct Turtle <: AbstractAgent
		id::Int                             # Boid identity
		pos::NTuple{2,Float64}              # Position of boid
		vel::NTuple{2,Float64}              # Velocity direction of boid
		speed::Float64                      # Speed of boid
	end
"""
@agent Turtle ContinuousAgent{2} begin
	speed::Float64
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
	world = ABM( Turtle, ContinuousSpace( (100,100), 1.0))

	# Add the n agents:
	for _ in 1:n
		add_agent!( world, Tuple(rand(1:5,2)), rand(1:9))
	end

	world
end

#-----------------------------------------------------------------------------------------
"""
	demo()

Create and run a simple world.
"""
function demo()
	# The world is continuous and 2-D, divided into 100×100 cells of width 1.0:
	world = simpleworld(5)

	println( "Number of agents before culling: ",length(allagents(world)))
	for ag in allagents(world)
		println("Agent $(ag.id) at location $(ag.pos) has speed $(ag.speed).")
	end
	
	for id in collect(nearby_ids( (50,50), world, 30))
		# Remove all agents within 30 units of location (50,50):
		kill_agent!( id, world)
	end

	println( "\nNumber of agents after culling: ",length(allagents(world)))
	for ag in allagents(world)
		println("Agent $(ag.id) at location $(ag.pos) has speed $(ag.speed).")
	end

end

end		# ... of module SimpleWorld