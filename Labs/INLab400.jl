#========================================================================================#
#	Laboratory 400
#
# Welcome to course 400: Introduction to Quantum Computation!
#
# Author: Niall Palfreyman, 24/04/2022
#========================================================================================#
[
	Activity(
		"""
		Welcome to course 400: Introduction to Quantum Computation!

		In this course we will explore the wonderful world of quantum physics, quantum
		computing and quantum information. In this introductory lab, we will first gather the
		various mathematical tools we need for dealing with quantum systems - in particular,
		we will need to extend our knowledge of Julia to include complex numbers ... :)

		Recall that a complex number z has the general form x+iy, where x and y are real numbers,
		and i^2==-1. Check this now: In Julia, the number i is written "im", so tell me the
		value of

			im^2
		""",
		"Notice the way in which Julia writes this number - does it make sense to you?",
		x -> x == -1
	),
]