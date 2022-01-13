#========================================================================================#
#	Laboratory 4
#
# Tuples, Pairs, Dict, Symbol, files, Dates and Random numbers.
# Files and Dates are available in Julia Programming Cookbook
#
# Author: Niall Palfreyman, 13/01/2022
#========================================================================================#
[
	Activity(
		"""
		Laboratory 4:
		
		In this laboratory we introduce several helpful Julia structures that make life a
		little easier: Tuples, Pairs, Dicts, Symbols, Files, DateTimes and Random numbers.

		A Tuple is an immutable container that can contain several different types. We
		construct Tuples using round brackets, for example:

		my_tuple = (5, 2.718, "Niall")

		What is my_tuple[2]?
		""",
		"my_tuple[2]",
		x -> x==my_tuple[2]
	),
	Activity(
		"""
		You have already seen that size() returns a Tuple. Enter the following code:

		ret_size = size(zeros(3,4))

		What is the value of ret_size[1]? Try changing the value of ret_size[2].
		Finally, what is the type of ret_size? 
		""",
		"typeof(ret_size)",
		x -> x==typeof(size(zeros(3,4)))
	),
	Activity(
		"""
		Tuples are especially useful when we want to define anonymous functions with
		more than one argument:

		map((x,y)->3x+2y,4,5)

		Construct a single line mapping that calculates sin(x*y) for corresponding
		elements in the two ranges x = 1:5 and y = 5:-1:1
		""",
		"map((x,y)->sin(x*y),1:5,5:-1:1)",
		x -> x==map((x,y)->sin(x*y),1:5,5:-1:1)
	),
	Activity(
		"""
		??? Pairs 56
		""",
		"",
		x -> x==0
	),
	Activity(
		"""
		""",
		"",
		x -> x==0
	),
	Activity(
		"""
		""",
		"",
		x -> x==0
	),
	Activity(
		"""
		""",
		"",
		x -> x==0
	),
	Activity(
		"""
		""",
		"",
		x -> x==0
	),
	Activity(
		"""
		""",
		"",
		x -> x==0
	),
	Activity(
		"""
		""",
		"",
		x -> x==0
	),
	Activity(
		"""
		""",
		"",
		x -> x==0
	),
	Activity(
		"""
		""",
		"",
		x -> x==0
	),
	Activity(
		"""
		""",
		"",
		x -> x==0
	),
	Activity(
		"""
		""",
		"",
		x -> x==0
	),
	Activity(
		"""
		""",
		"",
		x -> x==0
	),
	Activity(
		"""
		""",
		"",
		x -> x==0
	),
	Activity(
		"""
		""",
		"",
		x -> x==0
	),
	Activity(
		"""
		""",
		"",
		x -> x==0
	),
	Activity(
		"""
		""",
		"",
		x -> x==0
	),
	Activity(
		"""
		""",
		"",
		x -> x==0
	),
	Activity(
		"""
		""",
		"",
		x -> x==0
	),
	Activity(
		"""
		""",
		"",
		x -> x==0
	),
	Activity(
		"""
		""",
		"",
		x -> x==0
	),
	Activity(
		"""
		""",
		"",
		x -> x==0
	),
	Activity(
		"""
		""",
		"",
		x -> x==0
	),
	Activity(
		"""
		""",
		"",
		x -> x==0
	),
	Activity(
		"""
		""",
		"",
		x -> x==0
	),
	Activity(
		"""
		""",
		"",
		x -> x==0
	),
	Activity(
		"""
		""",
		"",
		x -> x==0
	),
	Activity(
		"""
		""",
		"",
		x -> x==0
	),
	Activity(
		"""
		""",
		"",
		x -> x==0
	),
	Activity(
		"""
		""",
		"",
		x -> x==0
	),
	Activity(
		"""
		""",
		"",
		x -> x==0
	),
	Activity(
		"""
		""",
		"",
		x -> x==0
	),
	Activity(
		"""
		""",
		"",
		x -> x==0
	),
	Activity(
		"""
		""",
		"",
		x -> x==0
	),
	Activity(
		"""
		""",
		"",
		x -> x==0
	),
]