#========================================================================================#
#	Laboratory 10
#
# Accessing the data in arrays.
#
# Author: Niall Palfreyman, 22/03/2022
#========================================================================================#
[
	Activity(
		"""
		Arrays play a very fundamental role in Julia, so we need to learn how to access them
		efficiently. In this laboratory we learn how to index into arrays in Julia - that is,
		how to use indices to access and manipulate the entries in an array. We will also look
		at various ways of applying code to the elements in an array.
		
		Julia offers four kinds of indexing: SUBSCRIPTING, LINEAR indexing, MULTIPLE indexing
		and LOGICAL indexing. All four are extremely useful for scientific programming. To
		investigate these forms of indexing, first create a (4x4) matrix by reshaping a range:

			m = reshape(1:16,(4,4))

		First notice the order in which Julia has placed the numbers 1:16. Do they run down the
		columns or along the rows?
		""",
		"",
		x -> occursin("col",lowercase(x))
	),
	Activity(
		"""
		So: SUBSCRIPTING! To access a matrix element with subscripts, we use square brackets
		enclosing two subscripts i (row) and j (column) like this: m[i,j]. In Julia, the row
		index ALWAYS comes before the column index! Display the element m[3,4[] now, then tell
		me its value:
		""",
		"Just enter m[3,4] at the Julia prompt",
		x -> x==15
	),
	Activity(
		"""
		We have already used the colon operator to create ranges of numbers, for example 1:3 can
		be collected into a vector [1,2,3]. We can also use ranges to select regions of an array.
		Use m[1:3,2:4] to display the top-right (3x3) region of m, then tell me the result
		(Remember you can use reply(ans) to tell me the result of the previous calculation):
		""",
		"",
		x -> x == [5 9 13;6 10 14;7 11 15]
	),
	Activity(
		"""
		1:2:7 creates a range of numbers from 1 to 7 in steps of 2: [1,3,5,7]. Reshape 1:81 into a
		(9x9) matrix, then extract from it the (3x3) matrix obtained by taking the first, then
		every third, row and column of your (9x9) matrix. Then tell me the result:
		""",
		"",
		x -> x == [1 28 55;4 31 58;7 34 61]
	),
	Activity(
		"""
		We can select a whole row or column by writing ":". Display and tell me the third row of m:
		""",
		"",
		x -> x == [3 7 11 15]
	),
	Activity(
		"""
		To assign values to regions of a matrix, we select the desired matrix range and assign to it
		a value. However, we should first be aware of something important. Tell me the type of m:
		""",
		"",
		x -> x <: Base.ReshapedArray
	),
	Activity(
		"""
		Notice that m only LOOKS like an ordinary matrix, but is actually a reshaped range, so Julia
		will not let us change its value by writing to it. To see this, try out the following:

			m[2:3,3:4] .= 1

		Then tell me the name of the function that the error message recommends we use:
		""",
		"",
		x -> occursin("collect",lowercase(x))
	),
	Activity(
		"""
		Let's take the error message's advice:
		
			m = collect(m)
			m[2:3,3:4] .= 1

		Now tell me the new value of m:
		""",
		"",
		x -> x == [1 5 9 13;2 6 1 1;3 7 1 1;4 8 12 16]
	),
	Activity(
		"""
		And what is the type of m now?
		""",
		"",
		x -> x <: Matrix
	),
	Activity(
		"""
		What kind of error do you get if you try to add an element outside the size of the array m:

			m[5,1] = 1
		""",
		"",
		x -> occursin("bounds",lowercase(x))
	),
	Activity(
		"""
		Although we can't add elements outside m's bounds, we can extend the size of m by adding
		new rows or columns: Blank ' ' adds columns (hcat: horizontal concatenation), and
		semicolon ';' adds rows (vcat: vertical concatenation). Tell me the result of this line:

			p = ones(4)
			pp = [m p]
		""",
		"",
		x -> size(x) == (4,5)
	),
	Activity(
		"""
		And what is the result of this line of code?

			q = ones(4)'
			qq = [m;q]
		""",
		"",
		x -> size(x) == (5,4)
	),
	Activity(
		"""
		OK, now let's look at LINEAR indexing! Internally, Julia represents all arrays as vectors =
		it simply makes this vector look like a matrix to us. Create the following matrix:

			A = [1 2 3;4 5 6]

		If we just enter A at the Julia prompt, we see a (2x3) matrix, but if you enter A[:], you
		will see a list of all elements of A in a linear order. Does this order first run down the
		columns or along the rows?
		""",
		"",
		x -> occursin("col",lowercase(x))
	),
	Activity(
		"""
		We can use the linear ordering to index the elements of A. What is the value of A[5]?
		""",
		"",
		x -> x==3
	),
	Activity(
		"""
		We can also use linear indexing to change the elements of A. What is the content of A
		after entering this line of code?

			A[5] = 99
		""",
		"",
		x -> x==[1 2 99;4 5 6]
	),
	Activity(
		"""
		Arrays can have MULTIPLE indices: Vectors have one index and Matrices have two, but we
		can have 3, 4, 5, ...! Of course we need to be a bit careful with the size of these arrays:
		A size (10) Vector contains 10 elements; a size (10,10) Matrix contains 100 elements. How
		many elements will there be in a size (10,10,10,10) array?
		""",
		"",
		x -> x == 1e4
	),
	Activity(
		"""
		We can create multiply indexed arrays using zeros(), ones(), rand(), randn() or reshape().
		A 3-dimensional array might represent 3-dimensional data, such as a chemical concentration
		at various locations in a cell, or it might represent the time-series of elements of a
		matrix A(t). In this case, A[3,5,4] might represent the element [3,5] at time t=4 of the
		time-series.

		Enter R = rand(2,3,4); at the Julia prompt, and study the following expressions:

			R[1,:,:]
			R[]:,1,:]
			R[]:,:,1]
			size(R)
		
		How many elements does R contain?
		""",
		"Use the length function",
		x -> x == 24
	),
	Activity(
		"""
		Here is a (4,4) magic square:

			A = [1 15 14 4;10 11 8 5;7 6 9 12;16 2 3 13]

		Use Julia's sum() function to find the sum of A's elements along any row, column or
		diagonal:
		""",
		"",
		x -> x==34
	),
	Activity(
		"""
		We can generate new magic squares by swapping columns of an existing magic square. Study
		the matrix B = A(:,[1,3,2,4]). Is this also a magic square (remember that rows, columns and
		diagonals of a magic square must all sum to the same number)? Which substructures of A were
		permuted by using the Vector [1,3,2,4] as a permutation index?
		""",
		"",
		x -> occursin("col",lowercase(x))
	),
	Activity(
		"""
		Use a permutation index to swap ROWS 2 and 3 of A, and tell me the result:
		""",
		"",
		x -> x == [1 15 14 4;7 6 9 12;10 11 8 5;16 2 3 13]
	),
	Activity(
		"""
		LOGICAL indexing uses an array of logical values as an index to another array. For example,
		suppose we want to reduce to zero all elements less than 3 in the Vector v = [1,2,3,4,5].
		One way would be to access each individual element in v, check whether it is less than 3,
		and set it to zero. But this would be very inefficient, because accessing each individual
		element costs time. Instead, we can use LOGICAL indexing to change the entire vector v in
		one sweep ...

		First, create the Vector v. Then tell me the result of entering this line:

			d = (v .< 3)
		""",
		"",
		x -> x == [1,1,0,0,0]
	),
	Activity(
		"""
		What is the type of the elements of d?
		""",
		"",
		x -> x == Bool
	),
	Activity(
		"""
		Notice that d is a Vector of Bools with the same length as v. We can use d to index
		elements of v:

			v[d]

		How many elements of v does d pick out?
		""",
		"",
		x -> x == 2
	),
	Activity(
		"""
		Now enter this line:

			v[d] .= 0

		You will see that this zeros out all elements of v that are less than 3. If you recreate
		v, you can even condense this entire process into one step:

			v = collect(1:5)
			v[v.<3] .= 0

		Now set to zero all numbers in the vector -5:2:5 which are greater than 2, and tell me
		the number of non-zero elements in your result:
		""",
		"",
		x -> x == 4
	),
	Activity(
		"""
		Before continuing, let's look at several different ways to apply some code to all elements
		in an array. If the code is just one function, this is easy: we just use the broadcast
		dot (.):

			v = 1:7
			isodd.(v)
		""",
		"",
		x -> x == isodd.(1:7)
	),
	Activity(
		"""
		If the code is a little more complicated, we might map() an anonymous function over
		the array:

			map( x->(sin(x) >= 0), v)
		""",
		"",
		x -> x == map( y->(sin(y) >= 0), 1:7)
	),
	Activity(
		"""
		And finally, if the code is particularly complicated, we can use a do statement that
		allows us to define a complicated mapping over all elements of the array:
			
			map(v) do x
				if x < 4
					isodd(x)
				else
					iseven(x)
				end
			end
		""",
		"",
		x -> x == (map(1:7) do y if y<4 isodd(y) else iseven(y) end end)
	),
	Activity(
		"""
		OK, now the last two activities in this laboratory give you practice in applying indexing,
		broadcasting and mapping to problems that often arise in signal-processing. Have fun! :)

		Use logical indexing to generate a list of all odd multiples of 3 in the range 1:50 :
		""",
		"Use isodd(), rem(), &, and remember to use broadcasts (.) and brackets",
		x -> x == [3,9,15,21,27,33,39,45]
	),
	Activity(
		"""
		This function decides whether or not its argument n is a prime number:

			function isprime(n::Int)
				if n < 2 return false end
				if n in 2:3 return true end
				for i in 2:floor(Int,sqrt(n))
					if rem(n,i) == 0 return false end
				end
				true
			end

		Use the isprime function to generate a list of twenty numbers from 1 to 20, in which
		all prime numbers AND all multiples of 3 are zeroed out:
		""",
		"Use rem(), isprime() and |",
		x -> x == [1,0,0,4,0,0,0,8,0,10,0,0,0,14,0,16,0,0,0,20]
	),
]