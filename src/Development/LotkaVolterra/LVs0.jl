#========================================================================================#
"""
	LVs - Version 0

A system of two interacting predator-prey species.

Author: Niall Palfreyman, 31/05/2022.
"""
module LVs

#using GLMakie					# I don't actually use this yet, but I know I'll need it later

#-----------------------------------------------------------------------------------------
# Module types:
#-----------------------------------------------------------------------------------------
"""
	LV

A Lotka-Volterra system containing two species interacting with each other.
"""
struct LV
	rx							# Reproduction rate of species x
	kx							# Carrying capacity of species x
	ry							# Reproduction rate of species y
	ky							# Carrying capacity of species y
end

#-----------------------------------------------------------------------------------------
# Module methods:
#-----------------------------------------------------------------------------------------
"""
	run( lv::LV)

Run a simulation of the given LV system over the time-duration nsteps * dt.
"""
function run( lv::LV, x0::Float64, y0::Float64, dt::Float64=0.1, nsteps::Int=200)
	# Dummy code: I assume I'll need to return t- and x-values of a trajectory:
	(1,1)
end

#-----------------------------------------------------------------------------------------
"""
	visualise( t, x)

Visualise the simulation data (t,x) of the given LV system on the screen.
"""
function visualise( t, x)
	# Again, this is just stub functionality:
	println( "t = ", t, ", x = ", x)
end

#-----------------------------------------------------------------------------------------
"""
	demo()

This first version of my use-case method demo() describes everything I want to do in the final
program: Demonstrate simulation of a simple 2-species Lotka-Volterra system in a simple 3-step use-case.

NOTE: USE-CASES are the HEART of software development! This one is already basically complete,
even though the methods it calls are dummy methods (that is: callable, but empty of functionality).
The code in this demo method already organises my thinking by giving me a precise plan of what
methods I will need to implement in later versions of developing program.

It is always a good idea to develop the graphical interface first, so I will develop my programm
according to the following DEVELOPMENT PLAN:

	Version 1: Implement visualise() to generate a static plot of dummy run data provided by run().
	Version 2: Implement run() to generate and display Euler data for a simple rabbit-lynx system.
	Version 3: Fix any execution errors arising from mistakes I made in my original design.

"""
function demo()
	# Build the Lotka-Volterra system:
	lv = LV( 0.05, 1000, 0.1, 100)						# A simple rabbit-lynx system
	
	# Calculate the simulation data with initial conditions 200 rabbits and 50 lynx:
	(t,x) = run( lv, 200.0, 50.0)

	# Run the animation:
	visualise( t, x)
end

end		# of LVs