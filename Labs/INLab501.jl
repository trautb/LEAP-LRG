#========================================================================================#
#	Laboratory 501
#
# Welcome to course 501: A first look at agent-based modelling with a simple Ecosystem
#
# Author: Niall Palfreyman (24/04/2022), Dominik Pfister (July 2022)
#========================================================================================#
[
	Activity(
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
        activities to understand the code behind the model a little bit better.

		""",
		"???",
		x -> true
	),
    Activity(
		"""
		In this first lab and model you will learn some basic information, that will be used
        from this point forward in the following labs.

        First thing to notice are the properties, which are defined in initialize_model().
        Proprties includes all the models global variables and data-matrices which the
        model interacts with.
        The properties-variable itself contains symbols mapped to their value inside 
        a dictionary so that any reference of the symbol at a different position in the code 
        will change the value for the model.
        This is used when working with sliders. Further down in the code inside 
        the demo()-function you will notice the reference to the models variable via symbols
        inside the params-dictionary. This dictionary defines all sliders that you see when
        running a model. The slider-values are stored in the symbols of the variables that
        are used when initializing the model.

        When working with sliders it is important to notice that the change in value of the
        slider will only affect the model after pressing the "reset model"-button.
        This will reinitialize the model with the changed values.
        You can also use this button to create new random initial model layouts in some labs.
        
		""",
		"???",
		x -> true
	),
    Activity(
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

    Activity(
		"""
		Correct!
        The other new feature is a system to show a colored background depending on values,
        which you have heard of already in Lab 500. Here is a direct example how it is
        implemented in Code.

        These background-values have to be specified in the properties of a model (in this 
        case in line 61 of the file IN501Ecosystem.jl).
        Later on this matrix of values has to be plotted with the correct colors and the correct
        range of values. These plot-arguments are specified in the demo()-function.

        Then next activity will explain this way of plotting a little bit more detailed.
		""",
		"???",
		x -> true
	),
    Activity(
		"""
		When plotting data there are many customizations you can choose from. The most important ones
		that will be used in the following labs are heatmaps that contain heatarrays and heatkwargs, 
		which include colormaps and colorranges. Heatmaps create colors in plots, which are bound to
		values, e.g. if a variables value is 1 it will be plotted in a specific color, other than 
		another variable containing the value 2.
		A heatarray describes the data that has to be interpreted. Like in the example that would be
		the values 1 and 2.
		heatkwargs (heat-Keyword-Arguments) are a set of multiple arguments which are specified in
		the plotting libraries.
		The most important heatkwargs you will find in the following labs are colormaps and colorranges.
		Colormaps contain the range of colors that should be depicted in the plot, 
		e.g. colormap = [:red, :blue] would create a gradual change starting at red and turning into blue.
		Colorranges specify over which values the colormap will be applied. Taking the example colormap
		with colorrange = (0:1:10) would distribute the change of the color over the steps from 1 to 10.
		1 would be represented as red and 10 would be represented as blue.
		For detailed information about plotting with colors have a look at the plotting documentations 
		for heatmaps: https://docs.juliaplots.org/latest/generated/colorschemes/

        And with this you are now set to explore IN501Ecosystem.
		""",
		"???",
		x -> true
	),
]