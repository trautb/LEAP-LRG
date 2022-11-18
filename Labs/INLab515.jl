#========================================================================================#
#	Laboratory 515
#
# Welcome to course 515: A more efficient implementation of a Turing activator-inhibitor system, adapted from Uri
#
# Author: Niall Palfreyman (...), Nick Diercksen (July 2022)
#========================================================================================#
[
	Activity(
		"""
		Welcome to Lab 515: A more efficient implementation of a Turing activator-inhibitor system,
        adapted from Uri

        From a computational point of view, there is a biiiiig problem with modelling reaction-diffusion
        Turing systems, and it is a problem that occurs over and over again in biological simulation:
        the problem of timescales.

        The large-scale Turing pattern that interests us, is constructed through the small-scale
        motion of millions of molecules. Since the pattern is emergent, we cannot calculate it accurately
        without simulating all those microscopic motions, and that costs time. However, once we have observed
        the macroscopic pattern, we start to understand its own emergent dynamics, and we can simulate
        it approximately by directly programming not the microscopic dynamics, but the emergent macroscopic
        dynamics. And that is much faster!

		""",
		"",
		x -> true
	),
   
]