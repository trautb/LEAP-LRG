#========================================================================================#
#	Laboratory 8
#
# Writing scientific code for human understanding.
#
# NOTE: This lab makes heavy use of George Datseris' eratosthenes() example from his
#		excellent course Good Scientific Code at: https://github.com/Datseris/ .
#
# Author: Niall Palfreyman, 07/09/2022
#========================================================================================#
[
	Activity(
		"""
		OK, now it's time to start writing good code for real scientific computing. Remember what
		I said at the beginning of this course: Good scientific code is clear text whose purpose
		is to communicate to others your understanding of how to solve a particular problem. Well,
		now is the time to make sure we understand how to write code that is clear enough for
		others to understand! Look now at the method eratosthenes_bad() in the following file:
			
			src/Development/Utilities/Utilities.jl

		The function eratosthenes_bad() generates prime numbers up to a user specified maximum N.
		It uses the algorithm known as the Sieve of Eratosthenes, which is quite simple: Given an
		array of integers from 1 to N, cross out all multiples of 2. Find the next uncrossed
		integer, and cross out all of its multiples. Repeat this until you have passed the square
		root of N. The remaining uncrossed numbers are then all the primes less than N.

		Test the eratosthenes_bad() method by loading it and entering eratosthenis_bad(100) at the
		Julia prompt. What answer do you get?
		""",
		"",
		x -> x == [2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73,79,83,89,97]
	),
	Activity(
		"""
		This eratosthenes_bad() method has been ported directly from Java, and so does not make use
		of higher-level features offered by Julia. You will create your own better version
		eratosthenes() that makes use of such features.

		Please note: I have allowed you plenty of time for this chapter, because it is so important
		that you learn to write clean scientific code. Please take time to do the exercises in this
		lab thoroughly.

		This eratosthenes_bad() method does not make use of Julia's features of list comprehension
		and broadcasting. Copy the code of eratosthenes_bad() into a new file, then work on this
		file iteratively, turning it into a clean, efficient implementation. First, rename your
		copied version to eratosthenes(), then change the implementation to make use of high-level
		features such as list comprehension or broadcasting.

		""",
		"Example of broadcast and comprehension: sin.([3x for x in 0:.1:2pi])",
		x -> true
	),
	Activity(
		"""
		Julia is based on FUNCTIONAL PROGRAMMING. That is, you break your code down into reusable
		functions that each performs a single, specific task. It is very important that a function
		has JUST ONE responsbility, and its name clearly indicates the specific task that the
		function performs. Higher level functions are composed out of lower-level functions. Also,
		function methods are SHORT: usually between 3-30 lines of code. Long methods and long
		method names usually indicate that your method has more than one responsibility.
		
		Functional programming dramatically increases the reusability of your code, and also
		reduces the risk of duplicating code, which can often lead to runtime errors!

		Now use functional programming to simplify the structure of your eratosthenes() method.
		""",
		"The body of a loop often contains code that you could parcel out into a smaller function",
		x -> true
	),
	Activity(
		"""
		Now we turn to function/variable NAMES. The aim of a function or variable name is always
		to indicate to readers how you intend to use the function or variable. Names communicate
		to readers what your code is doing (i.e., its INTENTION).

		In Julia, these names should always be in lower case, with multiple words separated by _.
		The name should be brief, but comprehensible for strangers reading your code (for example,
		NOT: rsdt, rsut and rsus!). Also, NEVER use constant literals in your program, for example,
		not '2022', but rather: 'year=2022', and then use 'year' in your code. The problem is that
		literals say nothing about your intentions.

		Redesign the names of variables/functions in your eratosthenes() method to make the code
		easier to navigate and understand. Don't change the code operations - only the names!
		""",
		"",
		x -> true
	),
	Activity(
		"""
		Now improve your eratosthenes() method by making use of Julia's built-in functions from
		the standard library, for example to count elements or find true elements in an array.
		""",
		"",
		x -> true
	),
	Activity(
		"""
		Now we will work on the COMMENTS in your eratosthenes() method. By now, you should find
		that you don't actually need many comments:
			- Comments compensate for our failure to express ourselves clearly in code!

		The problems with comments is that they are difficult to maintain as your code changes,
		and inappropriate comments are much worse than no comments. But there is a better way:
			- Simple, self-explanator code is far better than complicated but commented code!
		
		Here are my comment rules:
			- Never use CAPITALISED comments - they look like shouting, and distract the reader.
			- Use comments only to point out the high-level intentions or risks of your code.
			- Place comments at the beginning of a code block or aligned (!) to the right of codelines.
			- Replace header comments by docstrings that precede functions, datatype and modules.

		Now apply these rules to the comments in your eratosthenes() method.
		""",
		"",
		x -> true
	),
	Activity(
		"""
		Use VERTICAL formatting to divide your code into blocks with a consistent internal logic -
		like paragraphs in an essay. Place a comment box at the top of each logical section of a
		source file to communicate the intention of that section, and use blank lines ONLY to
		divide logically distinct trains of thought from each other. You never need to put a
		comment box inside a method.
		
		Improve the vertical formatting of your eratosthenes() method now.
		""",
		"",
		x -> true
	),
	Activity(
		"""
		HORIZONTAL formatting is often determined by your company's style-guide, but general
		rules are:
			- Code lines always have a maximum length - use 100 characters in this course.
			- All binary operators (including =) have enclosing white spaces, except for: *, ^, /.
			- Each new code block (for/map loops, functions, ifs) adds 4 spaces of indentation.
			- Floating-point literals always have a leading/trailing zero (e.g.: 0.5 or 5.0)

		Make these alterations to your eratosthenes() method now.
		""",
		"",
		x -> true
	),
	Activity(
		"""
		Finally, check out George Datseris' solution, which I have implemented in Utilities.jl
		as the function senehtsotare(). Make any additional changes that you think appropriate
		to your eratosthenes() function
		""",
		"",
		x -> true
	),
]