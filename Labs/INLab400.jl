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
		we will need to extend our knowledge of Julia to include complex numbers :)

		You might be asking yourself: Why do we need complex numbers? The answer is that quantum
		theory teaches us that particles possess certain probabilities that can interfere with
		each other, and the only way we can calculate these interferences is by using complex
		numbers. So let's start ...

		Recall that a complex number z has the general form x+iy, where x and y are real numbers,
		and i^2==-1. Check this now: In Julia, the number i is written "im", so tell me the
		value of

			im^2
		""",
		"Notice the way in which Julia writes this number - does it make sense to you?",
		x -> x == -1
	),
	Activity(
		"""
		Any complex number has a REAL part x and an IMAGINARY part y. Form the following two
		complex numbers and tell me their sum:

			z1 = 4+5im
			z2 = 3-5im
			z1 + z2
		""",
		"",
		x -> x == 7
	),
	Activity(
		"""
		What is the value of the difference z1 - z2?
		""",
		"",
		x -> x == 1+10im
	),
	Activity(
		"""
		We calculate the CONJUGATE of a complex number by simply reversing the sign of its
		imaginary part. Calculate the complex conjugate of 5+2im:

			conj(5+2im)
		""",
		"",
		x -> x == 5-2im
	),
	Activity(
		"""
		The conjugate of a product of complex numbers is equal to the product of their
		individual conjugates. Check that this is true:

			conj(z1*z2) == conj(z1) * conj(z2)
		""",
		"",
		x -> x == true
	),
	Activity(
		"""
		If we think of a complex number as a vector in the Gaussian plane, its real part is
		its coordinate along the horizontal real axis, and its imaginary part is its coordinate
		along the vertical imaginary axis. In this case, we can calculate the NORM of a complex
		number by using Pythagoras: We square its real and imaginary parts, add them together,
		then take the square-root of the result. Check that this is true by using the Julia
		function abs():

			abs(z1)^2 == real(z1)^2 + imag(z1)^2
		""",
		"",
		x -> x == true
	),
	Activity(
		"""
		We can also compute the norm of a complex number by multiplying the number by its
		conjugate and taking its square-root. Check that this is correct:

			a = abs(z2)
			b = sqrt(z2 * conj(z2))
			a == b
		""",
		"",
		x -> x == true
	),
	Activity(
		"""
		We calculate complex exponents using Euler's famous formula:

			θ = 3
			a = exp(θ*im)
			b = cos(θ) + sin(θ)*im
			a == b
		""",
		"",
		x -> x == true
	),
	Activity(
		"""
		In general, we can express any complex number as the product of its norm and a complex
		exponentiation:

			abs(z1) * exp(angle(z1)*im)

		If you calculate this value, you will see that rounding errors make it not quite equal to
		z1, but are the two numbers almost equal?
		""",
		"Notice we are asking whether z1 == abs(z1) * exp(angle(z1)*im)",
		x -> occursin('y',lowercase(x))
	),
	Activity(
		"""
		
		""",
		"",
		x -> x == -1
	),
	Activity(
		"""
		
		""",
		"",
		x -> x == -1
	),
	Activity(
		"""
		
		""",
		"",
		x -> x == -1
	),
	Activity(
		"""
		
		""",
		"",
		x -> x == -1
	),
	Activity(
		"""
		
		""",
		"",
		x -> x == -1
	),
	Activity(
		"""
		
		""",
		"",
		x -> x == -1
	),
	Activity(
		"""
		
		""",
		"",
		x -> x == -1
	),
	Activity(
		"""
		
		""",
		"",
		x -> x == -1
	),
	Activity(
		"""
		
		""",
		"",
		x -> x == -1
	),
	Activity(
		"""
		
		""",
		"",
		x -> x == -1
	),
	Activity(
		"""
		
		""",
		"",
		x -> x == -1
	),
	Activity(
		"""
		
		""",
		"",
		x -> x == -1
	),
	Activity(
		"""
		
		""",
		"",
		x -> x == -1
	),
	Activity(
		"""
		
		""",
		"",
		x -> x == -1
	),
	Activity(
		"""
		
		""",
		"",
		x -> x == -1
	),
	Activity(
		"""
		
		""",
		"",
		x -> x == -1
	),
	Activity(
		"""
		
		""",
		"",
		x -> x == -1
	),
	Activity(
		"""
		
		""",
		"",
		x -> x == -1
	),
	Activity(
		"""
		
		""",
		"",
		x -> x == -1
	),
	Activity(
		"""
		
		""",
		"",
		x -> x == -1
	),
	Activity(
		"""
		
		""",
		"",
		x -> x == -1
	),
	Activity(
		"""
		
		""",
		"",
		x -> x == -1
	),
	Activity(
		"""
		
		""",
		"",
		x -> x == -1
	),
	Activity(
		"""
		
		""",
		"",
		x -> x == -1
	),
	Activity(
		"""
		
		""",
		"",
		x -> x == -1
	),
	Activity(
		"""
		
		""",
		"",
		x -> x == -1
	),
	Activity(
		"""
		
		""",
		"",
		x -> x == -1
	),
	Activity(
		"""
		
		""",
		"",
		x -> x == -1
	),
]