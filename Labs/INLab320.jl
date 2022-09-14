#========================================================================================#
#	Laboratory 8
#
# Genetic algorithms and refactoring.
#
# Author: Niall Palfreyman, 16/03/2022
#========================================================================================#
[
	Activity(
		"""
		In this laboratory we will use our Casinos module to implement a genetic algorithm
		(GA). I have already written most of the code for you, but you will see that there
		is still some work left for you to do, so let's get started ...

		Our GA will locate the global minima of a function that we shall call the objective
		of the GA. Objective functions can be very complicated, so we want to be able to view
		them graphically to understand them. I have written a module Objectives to define and
		view objective functions. Run the simple demo1() method of the Objectives module now,
		and tell me to the nearest integer value the x-coordinate of the global minimum of
		the 7-th function in our test-suite of Objective functions:

			include("src/Development/SimpleGAs/Objectives.jl")
			using .Objectives
			Objectives.demo1()
		""",
		"The low values in this contour map are colourd deep blue - look to the top-left! :)",
		x -> x==9
	),
	Activity(
		"""
		Objectives.demo2() shows you how to insert your own function into an Objective. How
		many hills does the Valleys function possess within the displayed domain?
		""",
		"The hills are coloured green-yellow",
		x -> x==3
	),
	Activity(
		"""
		Go to the source code of the Objectives module and look at the Objective type definition.
		the first field of this type is the function itself - whether you take this from the test
		suite or insert your own function. What is the name of the second field?
		""",
		"",
		x -> occursin("domain",lowercase(x))
	),
	Activity(
		"""
		Create several different Objective functions and study the structure of their domains.
		What do you think is the dimension of test suite function 1?
		""",
		"The dimension is the number of number-pairs [lwb,upb] in the domain",
		x -> x==1
	),
	Activity(
		"""
		Use the evaluate() method to find the value of Objective(7) at various locations. Note
		that evaluate() evaluates the objective function at several different points at once,
		so it expects a vector of points. So to check the value for the point [1,2], you will
		need to enter:

			evaluate( obj, [[1,2]])
		
		What do you now think is the y-coordinate of the global minimum of Objective(7)?
		""",
		"You should find that your earlier answer from graphical inspection is correct",
		x -> x==9
	),
	Activity(
		"""
		Create an instance of the 16-th test suite function. Find out its dimensionality:
		""",
		"You can either inspect the domain or you can use the dim() method",
		x -> x==128
	),
	Activity(
		"""
		Clearly, that is a very large number of dimensions! This makes it very difficult to find
		the global minimum of the function. Indeed, this function is the mepi() (maximally
		epistatic) function created by Robert Watson in 2007 to be maximally difficult for GAs
		to solve. To see how difficult it is to find this function's minimum, you can explore the
		mepi function in any number of dimensions (here 3):

			Objectives.mepi([1,0,1])						# Returns the value 8
			Objectives.mepi.([rand(3) for _ in 1:9])		# Returns nine different mepi values

		Play around with the mepi function to discover its minimum value in 4 dimensions:
		""",
		"Try confining your search to vectors with components either 0 or 1",
		x -> x==4
	),
	Activity(
		"""
		To find out why it is so difficult to find mepi's global minimum, try depicting the
		mepi function in all 128 dimensions. Clearly, you cannot produce a 128-dimensional
		graphic, but you can plot a cross-section of mepi's values in 128 dimensions using the
		command

			depict(Objective(16),[])

		Modify the code of the demo1() method to display this cross-section. Suppose we only had
		8 dimensions. In this case the two minima occur at the vector arguments [0,0,0,0,0,0,0,0]
		and [1,1,1,1,1,1,1,1]. The next lowest local minimum occurs at a vector maximally distant
		from both of these two vectors. What is this vector?
		""",
		"How many 0/1 switches are necessary to convert one of these vectors into the other?",
		x -> x==[0,0,0,0,1,1,1,1] || x==[1,1,1,1,0,0,0,0]
	),
	Activity(
		"""
		OK, now let's look at the module Decoders. Our GA will work with genes consisting of
		0/1 values, but we want to optimise objective functions whose arguments consist of
		real numbers. We therefore need a Decoder to convert our GA chromosomes into input
		numbers for an Objective.
		
		The method Decoders.demo() demonstrates how to use a Decoder to decode the two
		bit-vectors [1,0,1,0,1,0,1,0,0,0,0,1,0,1,1] and [0,1,0,1,0,1,0,1,1,0,1,0,1,1,0]. How
		many bits does each of these two bit-vectors contain?
		""",
		"Count the bits in the vectors! :)",
		x -> x==15
	),
	Activity(
		"""
		Each bit-vector encodes three floating-point values (for example, the three arguments
		of an objective function). How many bits are used to encode each floating-point number?
		""",
		"Length of the bit-vector divided by the number of float values",
		x -> x==5
	),
	Activity(
		"""
		If you look at where the decoder is constructed in the demo() method, you can see that
		it actually specifies a domain with three dimensions and then the number of bits (5)
		that we want to use for encoding each float value. If you then go up to the definition
		of the Decoder constructor, you will see how it converts these two values into the fields
		inside a Decoder.
		
		Notice in particular how it uses a functional expression (x->x[1]) to pull out all the
		lower-bound values from the domain and store them in the field lwb. What is the lower
		bound of the third dimension of the domain in our demonstration example?
		""",
		"",
		x -> x==-7
	),
	Activity(
		"""
		Now study the code inside the Decoder constructor - it creates a matrix that will be
		stored in the field coeffs of the Decoder. At the Julia prompt, enter the lines that
		calculate the vector qlevels (quantum levels), using the value 5 instead of nbits.

		Notice how qlevels first contains the sequence [1/2,1/4,1/8,1/16,...], and then these
		numbers are divided by their sum, so that finally the sum of all values in qulevels is
		equal to 1. Is qlevels a row vector or a column vector?
		""",
		"",
		x -> occursin("col",lowercase(x))
	),
	Activity(
		"""
		The vector span contains the span-width of each domain dimension, which we will need
		to decode the bits. Investigate whether span is a row vector or a column vector:
		""",
		"",
		x -> occursin("row",lowercase(x))
	),
	Activity(
		"""
		The Decoder constructor calculates the coeffs matrix by multiplying qlevels * span.
		Notice that qlevels has size (5,1), while span has size (1,3). These numbers are
		important: 5 is the accuracy of our bit-coding of numbers, and 3 is the number of
		different dimensions we need to decode. What is the size of coeffs?
		""",
		"",
		x -> x==(5,3)
	),
	Activity(
		"""
		Now comes your work. The result of decoding our two bit-vectors should be the two
		floating-point vectors [1.67742, 3.51613, -2.74194] and [1.32258, 4.41935,  1.51613].
		But if you run demo(), you will see that it calculates a silly result. The reason for
		this is that I have changed the two important lines of code in the method decode(). it
		is your job now to write the necessary code. You will find hints and information in
		the comments. When you are getting the right answers, come back here and reply
		"Yay!!!" ...
		""",
		"",
		x -> x=="Yay!!!"
	),
	Activity(
		"""
		Great - well done! Now it's time to look at the GA itself - the source code is in the
		module SimpleGAs. Once again, the method demo() shows you how to use the SimpleGA, but
		again it won't give you correct answers yet because I've changed the code in a couple
		of places. So let's just start exploring the code.

		As you can see, in demo(), I simply create an Objective and attach it to a SimpleGA,
		then let it run. The main work of finding the minimum of the Objective is done by the
		method evolve!(), so let's go there next.

		By the way, how many iterations of the GA does demo() perform?
		""",
		"It is the second argument of evolve!()",
		x -> x==5000
	),
	Activity(
		"""
		evolve!() is basically just a loop over lots of generations, and in the loop you can
		see that each generation of the SimpleGA (sga) first measures the current fitness of
		sga's population, then uses this information to (a) sort out any elitists that will
		survive unchanged into the next generation, (b) perform selection (i.e. fitness-
		dependent recombination/crossover) and (c) mutate the children in the next generation.

		If you have already successfully implemented the Casinos module, you should now be
		getting a compile-error inside the method SimpleGAs.mutate!(). Go there now and look at
		the first line of code. Here, we call Casinos.draw() to create a random Boolean matrix
		that will tell us which genes to mutate. However, we haven't yet implemented a draw()
		method with 4 arguments. How many arguments does your current draw() method have?
		""",
		"Look at the signature of the method Casinos.draw()",
		x -> x==3
	),
	Activity(
		"""
		First let's look at how to create a Bernoulli matrix of Boolean values with a particular
		(Bernoulli) probability mu of being true. Enter this line at the Julia prompt:

			rand(5,5) < 0.2

		This will give you a random Boolean matrix. Find the number of true elements like this:

			sum(ans)

		Now enter sum(rand(5,5) < 0.2) many times - what is the average result that you get?
		""",
		"You'll need to do it about 10 times to estimate the average value",
		x -> x==5
	),
	Activity(
		"""
		OK, so we can calculate a Bernoulli matrix from a matrix of random floats between 0
		and 1. But we already have a draw() method that produceds random float matrices, so
		you now need to create a new Casinos.draw() method with 4 arguments that calls the
		3-argument method, compares it with the Bernoulli probability mu, and returns the
		resulting Boolean matrix.
		
		Do this now, then recompile and run SimpleGAs.demo(). Then give me a "Hi 5!" when
		it runs without errors.
		""",
		"",
		x -> occursin('5',x) || occursin("five",lowercase(x))
	),
	Activity(
		"""
		Notice how good this feels: You have brought a broken program to the stage where it
		runs without errors! Of course, the answer you get is not yet correct, but we will
		fix that now ...

		Go to the method SimpleGAs.recombine!(). First notice the code that selects parents
		for recombination according to their fitness. THIS CODE IS TOTALLY COOL! It is not
		easy to understand, but you will need it if you ever want to implement roulette-wheel
		selection for yourself!

		Further down is a loop that actually generates the individual progeny (children)
		sally and billy from their parents mummy[m] and daddy[m]. You will see there are five
		lines of code that you need to write yourself. Do this now according to the explanations
		in the code.
		
		You can tell when you have succeeded by looking at the results of the GA: The winning
		individual should be close to [9,9], which was your estimate for the location of the
		global minimum of Objective(7). What is the value (to the nearest integer) of the
		objective function at this point?
		""",
		"",
		x -> x==-16
	),
	Activity(
		"""
		Well done! You have now completed the set work for this laboratory, and you have
		created an up-and-running genetic algorithm capable of optimising multi-variable
		functions. Now try out SimpleGA with various other objective functions from our
		test suite. In particular, find out how close you can get to the global minimum of
		mepi() - or Objective(16) - by tuning sga using the following methods:

			mu!(), temperature!(), elite!() and px!()
		""",
		"",
		x -> true
	),
]