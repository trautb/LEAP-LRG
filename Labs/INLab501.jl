#========================================================================================#
#	Laboratory 501
#
# Welcome to course 501: A first look at agent-based modelling with a simple Ecosystem
#
# Author: Niall Palfreyman (24/04/2022), Dominik Pfister (July 2022)
#========================================================================================#
[
	Activity( # nr 1
		"""
		Welcome to Lab 501: Ecosystem.
        This first lab of agent-based modelling will show you, how some simple rules let
        organisms interact with each other in an ecosystem.

        In this module turtles live in a world filled with algae. The turtles move around
        and eat the algae if they happen to find some and gain some energy off it. If a 
        turtle has enough energy it will reproduce and if its energy falls to zero it
        will die. The algae that was eaten by the turtles will also rgro after some time.

        With this mixture of rules the turtles will live on and the algae will regrow.

        But there are some new things to notice in this lab. Have a look at the next
        activities to understand the code behind the logic a little bit better.

		""",
		"???",
		x -> true
	),
    Activity( # nr 2
		"""
		The first new function that is used is rotate_2dvector(φ, vector) and is implemented in the AgentToolBox.
        It rotates a vector by the radiant φ with a positive value counter-clockwise and with a negative value
        clockwise. The internal logic is just a simple vector transformation.
        Let's test this new function. First make the AgentToolBox available to your environment:

        include("./src/Development/PBM/AgentToolBox.jl")
        import .AgentToolBox: rotate_2dvector

        Now we can use the rotate_2dvector(φ, vector)-function.
        Try to rotate the vector
            
            a = (1,1)

        by 90 degrees clockwise and return me its values.

		""",
		"Remember to use radiants instead of degrees when using the function rotate_2dvector()!",
		x -> (-1,1) == round.(x, digits=4) 
	),

    Activity( # nr 3
		"""
		Correct!
        The other new feature is a system to show a colored background depending on values.

        These values have to be specified in the properties of a model (in this case in line 61
        of the file IN501Ecosystem.jl).
        Later on this matrix of values has to be plotted with the correct colors and the correct
        range of values. These plot-arguments are specified in the demo()-function.

        And with this you are now set to explore IN501Ecosystem.

		""",
		"???",
		x -> true
	),
]