#========================================================================================#
#	Laboratory 505
#
# Welcome to course 505: Flow of a resource in a world, initialized and run by
#                        a central turtle producing and pumping the resource.
#
# Author: Niall Palfreyman (24/04/2022), Dominik Pfister (July 2022)
#========================================================================================#
[
	Activity( # nr 1
		"""
		Welcome to Lab 505: Flow.
        This lab focuses on the diffusion and evaporation of a resource "u" inside a world.
        The resource is being produced and pumped from one point to another by a trutle at the 
        center of the world. The resource u flows from patch to patch through diffusion and
        a small percentage of u evaporates.

        There is one new function used in this lab that will be explained in the next activity.
		""",
		"???",
		x -> true
	),
    Activity( # nr 2
		"""
		The mentioned function is diffuse8(model, diffuse_value, diffusion_rate) and is also
        implemented in the AgentToolBox. 
        The following example explains the simple logic that is happening, when diffusing
        a value of a matrix:
        If we have a matrix
    
        m = [
            1 1 1
            1 8 1
            1 1 1
        ]

        and we would use the function diffuse on the 8 in the middle of the matrix m with a 
        diffusion_rate of 0.5, the result would be the matrix

        m = [
            1.5 1.5 1.5
            1.5 4 1.5
            1.5 1.5 1.5
        ]

        What happened when we used that function was that a part of 8, 8*diffusion_rate to be exact,
        got split up and added to the 8 surrounding patches in equal amounts. When calling the function,
        this way of diffusion is added to every single value in the matrix (not only the 8).
        Using the function on the whole matrix, it would check for matrix bounds and add the
        remainder of otherwise out-of-bounds-values to the closest value that is in-bounds. 

        With this information you are free to explore IN505Flow.
		""",
		"???",
		x -> true
	),
]