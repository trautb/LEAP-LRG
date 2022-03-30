#========================================================================================#
#	Laboratory 3
#
# Ranges, Arrays and Vectors
#
# Author: Niall Palfreyman, 10/01/2022
#========================================================================================#
[
	Activity(
		"""
		In this laboratory we look at a very important structure in Julia: arrays. Once you
		understand how arrays work, and how amazingly useful they are, you will (almost)
		never need to write a for-loop again!

		... But first we start with Ranges. A Range is an interval of values between start
		and stop boundaries. Here is a range of values between 1 and 5:

			r = 1:5

		What is the type of r?
		""",
		"typeof(1:5)",
		(x -> x <: UnitRange)
	),
	Activity(
		"""
		We can collect() the individual values of a Range into a collection:

			collect(1:5)

		What is the type of this data structure?
		""",
		"typeof(collect(1:5))",
		(x -> x <: Vector)
	),
	Activity(
		"""
		We can also construct ranges for other types, and we can also specify our own
		steplength between the values:

			0.0:0.2:1.0

		Use collect() to list the values in this range and find out how many different
		values the range contains:
		""",
		"length(collect(0.0:0.2:1.0))",
		x -> x==6
	),
	Activity(
		"""
		collect() turns a Range into an Array. Arrays are the daily workhorse of data science:
		they collect elements into tables of 1 or more dimensions. A 1-dimensional Array is
		called a Vector. Here is a COLUMN vector:

			v = [5,4,7,6,3]

		What is its size()?
		""",
		"size(v)",
		x -> x==(5,)
	),
	Activity(
		"""
		What is the size of this ROW vector: w = [5 4 7 6 3 2 1] ?
		""",
		"size(w)",
		x -> x==(1,7)
	),
	Activity(
		"""
		As you can see, the FIRST dimension of an array runs down its columns, and
		the SECOND dimension runs across its rows.

		If you want to write a really super-duper-speedy program, you can create arrays
		using the values that are accidentally hanging around in memory:

			A = Array{Int}(undef,2,3)

		However, more usually we want to INITIALISE the elements of a new array. What
		is the value of the elements in this array:

			A = ones(2,3)
		""",
		"A[1]",
		x -> x == 1.0
	),
	Activity(
		"""
		What about this array: zeros(3,4). What is its size?
		""",
		"size(zeros(3,4))",
		x -> x==(3,4)
	),
	Activity(
		"""
		A MATRIX is an Array with just two dimensions. We often want to fill a matrix
		with a particular value. For example:

			B = Matrix{Int}(undef,3,2)
			fill!( B, 42)

		What is the size of this array?
		""",
		"size(B)",
		x -> x==(3,2)
	),
	Activity(
		"""
		We can create an array literal by explicitly naming the array's elements
		in square brackets:

			C = [2 4 7;3 9 1.2]

		Which value determines the type of the array elements here?
		""",
		"The element from the least restrictive number set",
		x -> x==1.2
	),
	Activity(
		"""
		We can also use square brackets to concatenate arrays, for example:

			[ones(2,3) zeros(2,4)]

		Find the symbol for using square brackets to concatenate two arrays vertically:
		""",
		"",
		x -> occursin( ";", x)
	),
	Activity(
		"""
		A very powerful way of constructing arrays is by COMPREHENSION. That is, we
		write a formula in square brackets that specifies (comprehends) the entire
		contents of the array. For example, here is a vector of square values:

			[x^2 for x in 1:12]

		What do you get if you add the condition "if isodd(x)" to the end of this
		comprehension?
		""",
		"[x^2 for x in 1:12 if isodd(x)]",
		x -> x == [x^2 for x in 1:12 if isodd(x)]
	),
	Activity(
		"""
		We can use several comprehension variables:

			[x*y for x in 1:5, y in 1:5]

		Use array comprehension to generate a matrix of values for the function
		exp(-(x^2 + y^2)) with x and y in the range from -1 to +1 in steps of 0.2. This
		function is a 'hill' with a peak value of 1.0 at the centre where x = y = 0.
		""",
		"[exp(-(x^2 + y^2)) for x in -1:0.2:1, y in -1:0.2:1]",
		x -> abs(sum(x) - 61.02) < 0.01
	),
	Activity(
		"""
		Once we have created an array, we usually want to inspect it. First create
		this array:
		
			my_matrix = ((1:3)*(1:4)')//3
		
		Now use eltype() to find the type of the elements in the array my_matrix:
		""",
		"eltype(my_matrix)",
		x -> x <: Rational
	),
	Activity(
		"""
		The length() of a matrix is the number of elements in it. What is the length
		of my_matrix?
		""",
		"length(my_matrix)",
		x -> x==12
	),
	Activity(
		"""
		What is the ndims() of my_matrix?
		""",
		"ndims(my_matrix)",
		x -> x==2
	),
	Activity(
		"""
		You have already used size() to return the size of a matrix, but you can also
		add a second argument to specify which dimension of the matrix you wish to know
		the size of. What is the size of the second dimension of my_matrix?
		""",
		"size(my_matrix,2)",
		x -> x==4
	),
	Activity(
		"""
		Matrix-based languages like Julia offer very many different ways of inspecting
		individual parts of an array. To experiment with this various ways, first define
		the following two arrays:

			my_vector = collect(1:5)
			my_matrix = [1 2 3;4 5 6;7 8 9]

		We can access individual elements of these arrays easily using square brackets
		and subscripts. How do we use subscripts to view the element 8 in my_matrix?
		""",
		"my_matrix[r,c]",
		x -> occursin("my_matrix[3,2]",replace(x," "=>""))
	),
	Activity(
		"""
		The keyword 'end' denotes the last subscript in an array dimension. For example,
		what value is denoted by my_matrix[1,end-1]?
		""",
		"my_matrix[2,end-1]",
		x -> x==2
	),
	Activity(
		"""
		Use subscripting with '=' to change the first entry in my_vector from 1 to 0, then
		give me the new vector that results from this change:
		""",
		"reply(my_vector)",
		x -> x==[0,2,3,4,5]
	),
	Activity(
		"""
		Often, we wish to work not just with individual array elements, but with a whole
		slice of the array. What is the result of the expression my_vector[2:4]?
		""",
		"my_vector[2:4]",
		x -> x==Main.my_vector[2:4]
	),
	Activity(
		"""
		The colon also stands for a complete row or column of an array. What is the
		result of the expression my_matrix[:,3]?
		""",
		"my_matrix[:,3]",
		x -> x==Main.my_matrix[:,3]
	),
	Activity(
		"""
		What is the result of the expression my_matrix[begin+1:end,end]?
		""",
		"my_matrix[begin+1:end,end]",
		x -> x==Main.my_matrix[begin+1:end,end]
	),
	Activity(
		"""
		We can also use slices to change the values in an array. What is the new
		value of the array my_matrix if we perform the following operation:

			my_matrix[3,:] = [17,18,19]
		""",
		"reply(my_matrix)",
		x -> x==[1 2 3;4 5 6;17 18 19]
	),
	Activity(
		"""
		What is the value of the array new_matrix if we construct it like this:

			new_matrix = reshape(my_matrix,1,9)
		""",
		"reshape(my_matrix,1,9)",
		x -> x==reshape(Main.my_matrix,1,9)
	),
	Activity(
		"""
		Notice the strange order of elements in new_matrix. This order arises
		because Julia uses "column-major" ordering of matrix elements: that is,
		these elements have a linear ordering that runs first down the columns
		and then across the rows. You can see this if you list all elements of
		my_matrix using ':'. Show me the result of doing this:
		""",
		"my_matrix[:]",
		x -> x==Main.my_matrix[:]
	),
	Activity(
		"""
		We can perform any function on all elements of an array by using the
		broadcast operator "." like this:

			log.(my_matrix)

		What is the sin() of all elements of my_matrix?
		""",
		"sin.(my_matrix)",
		x -> x==sin.(Main.my_matrix)
	),
	Activity(
		"""
		We can also use broadcasting with infix operators, for example:

			my_matrix .+ 5

		What is the result of taking the reciprocal (1/x) of each element
		in my_matrix?
		""",
		"1 ./ my_matrix",
		x -> x == 1 ./ Main.my_matrix
	),
	Activity(
		"""
		Another way of operating on all elements in an array is to map() the
		operation over the array:

			map(log,my_matrix)

		What is the sin() of my_matrix?
		""",
		"map(sin,my_matrix)",
		x -> x==map(sin,Main.my_matrix)
	),
	Activity(
		"""
		The map() function is particularly useful when we are using anonymous
		functions:

			map(x->5x,my_matrix)

		What do we obtain if we apply the function (x->5sin(x+3)) to my_matrix?
		""",
		"map(x->5sin(x+3),my_matrix)",
		x -> x==map(x->5sin(x+3),Main.my_matrix)
	),
	Activity(
		"""
		We can combine mapping with slicing:

			map(x->5x,my_matrix[:,3])

		What is the result of applying the function (x->5sin(x+3)) to the central
		column of my_matrix?
		""",
		"map(x->5sin(x+3),my_matrix[:,2])",
		x -> x==map(x->5sin(x+3),Main.my_matrix[:,2])
	),
	Activity(
		"""
		We can also iterate (i.e.: loop) over the elements in any array:

			for m in my_array
				print( m, ", ")
			end

		Write a loop to calculate the sum of all elements in my_matrix:
		""",
		"reply(ans)",
		x -> x==sum(Main.my_matrix)
	),
]