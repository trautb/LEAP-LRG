#========================================================================================#
#	Laboratory 1
#
# Introduction to Julia, variables and data.
#
# Author: Niall Palfreyman, 22/12/2021
#========================================================================================#
[
	Activity(
		"""
		Hi! In this laboratory we use activities and questions that introduce us to the basics
		of the Julia language. Feel free to experiment at any time by entering your own
		commands at the Julia prompt.
		
		I will interpret anything you enter as an argument of the function reply() as an
		answer to the current question. Try this now - at the Julia prompt, enter the
		following code:

			city = "Ingolstadt"

		Then enter your answer as:
		
			reply(city)
		""",
		"We're still getting started - simply follow the above instructions precisely. :)",
		x -> (x=="Ingolstadt")
	),
	Activity(
		"""
		You can use the Julia REPL like a calculator. Arithmetic operations have their usual
		priority, so tell me the result you get if you enter "(3+4)*5":
		""",
		"35",
		x -> x==35
	),
	Activity(
		"""
		A very useful feature of the Julia REPL is that you can always retrieve the result of
		your previous calculation by entering "ans" at the Julia prompt. Press up-arrow a few
		times until you see your previous calculation "(3+4)*5". Enter this calculation, and
		then enter "ans" at the Julia prompt. What value is returned?
		""",
		"35",
		x -> x==35
	),
	Activity(
		"""
		Remove the brackets: \"3+4*5\". First calculate this value, then retrieve it again
		by entering the variable \"ans\". Finally, show me the value using \"reply(ans)\":
		""",
		"23",
		x -> x==23
	),
	Activity(
		"What answer do you get if you remove the multiplication sign: \"5(3+4)\"?",
		"35",
		x -> x==35
	),
	Activity(
		"What do you get if you use floating-point division \"1 + 1/7\"?",
		"$(1+1/7)",
		x -> abs(x-(1+1/7)) < 0.01
	),
	Activity(
		"Or you can use exact division to produce a rational number \"a = 1 + 1//7\":",
		"$(1+1//7)",
		x -> x == 1+1//7
	),
	Activity(
		"You can then convert this to a floating-point number: \"Float64(a)\"",
		"$(1+1/7)",
		x -> abs(x-(1+1/7)) < 0.01
	),
	Activity(
		"""
		Let's try working with Vectors. A Vector is a linearly ordered list in square
		brackets. They can contain all kinds of elements. Enter this definition of the
		Vector b: \"b = [3,5,"4",[1,2]]\". Then use length() to find the length of b:
		""",
		"length(b)",
		x -> x == 4
	),
	Activity(
		"Use b[2] to access the 2nd element of b, and use the function isodd() to see if it is odd:",
		"isodd(b[2])",
		x -> x == true
	),
	Activity(
		"What is the type of (typeof) the 4th element of b?",
		"Vector{Int64}",
		x -> (x <: Vector)
	),
	Activity(
		"Change the 3rd element of b to my name \"Niall\" and find the length of that 3rd element",
		"b[3] = \"Niall\"",
		x -> x == 5
	),
	Activity(
		"""
		Ranges are closely related to Vectors. Investigate the expression \"2:4\", then use
		collect() to convert it into a Vector. Finally, use b[2:4] to extract the last three
		elements of b:
		""",
		"[5,\"4\",[1,2]",
		x -> x == [5,"Niall",[1,2]]
	),
	Activity(
		"""
		We can also work with BigInt numbers: \"c = factorial(big(100))\". Find out how
		many digits this number has by using digits() to convert it into a Vector.
		""",
		"158",
		x -> x == 158
	),
	Activity(
		"""
		Functions are centrally important in Julia, and the language offers us three
		different ways of defining them. Use this format to define your own squaring
		function, then use it to compute the square of -253:
			function sq1( x)
				x * x
			end
		""",
		"64009",
		x -> x == 64009
	),
	Activity(
		"""
		Now use this shorter format to define a new squaring function, and use it to
		compute the square of the imaginary number 5im:

			sq2( x) = x * x
		""",
		"-25",
		x -> x == -25
	),
	Activity(
		"""
		Finally, functions are so important in Julia that we often want to create an
		anonymous function quickly in the middle of a calculation. Use the following
		anonymous notation to compute the square of the complex number 1+im:

			(x -> x*x)(1+im)
		""",
		"2im",
		x -> x == 2im
	),
	Activity(
		"""
		Use tuples to assign values in parallel to the variables x and y:

			(x,y) = (2,3)

		Then give me (as a string) the code to swap the values of x and y:
		""",
		"(x,y) = (y,x)",
		x -> (r=replace(x," "=>""); r == "(x,y)=(y,x)" || r == "(y,x)=(x,y)")
	),
	Activity(
		"""
		You can use conditionals in the usual way, for example:

			function f(x)
				if x ≥ 0
					x
				else
					-x
				end
			end

		Now use the shorter notation "x ≥ 0 ? x : -x", and assign g equal to an anonymous function
		that calculates the factorial of its argument. That is, g(n) returns 1 if n ≤ 1, and
		returns n * g(n-1) otherwise. Use g to calculate 9!:
		""",
		"n -> (n ≤ 1 ? 1 : n * g(n-1))",
		x -> (x == 362880)
	),
	Activity(
		"""
		We use double quotation marks to denote Strings. Find out the typeof() "Niall":
		""",
		"typeof(\"Niall\")",
		x -> (x == String)
	),
	Activity(
		"""
		We can concatenate two or more Strings into a single String using the operator *.
		Define the two strings:

			name1 = \"Niall\"
			name2 = \"Palfreyman\"

		What result do you get if you concatenate these two Strings?
		""",
		"name1 * name2",
		x -> (x == "NiallPalfreyman")
	),
	Activity(
		"""
		I prefer my name with a space between the first and second names. We can do this
		using the call join([name1,name2],\" \"). What String results from this?
		""",
		"\"Niall Palfreyman\"",
		x -> (x == "Niall Palfreyman")
	),
	Activity(
		"""
		We can pattern text more simply using STRING INTERPOLATION. Enter this code:

			\"\$name1 \$name2\"

		The dollar sign (\$) interpolates the values of name1 and name2 into the string.
		Enter the following code and then see if you can work out the return value of
		the function println():

			x = π/2; println("The sine of \$x is \$(sin(x)).")

		(Note: You can enter the symbol π by typing "\\pi" and then pressing Tab.
		Alternatively, you can replace this symbol by the named constant "pi".)
		""",
		"\"typeof(ans)\"",
		x -> (x == Nothing)
	),
	Activity(
		"""
		Julia offers us many different functions for manipulating strings. Let's start
		by creating a String that we can play around with:

			a_string = "We are one and we are many, and from all the lands on Earth we come."

		Now ask whether the substring "Earth" occurs in the string a_quote: What is the
		return value of the function call occursin("Earth",a_string)?
		""",
		"",
		x -> x == true
	),
	Activity(
		"""
		What value does the function call startswith("Earth",a_string) return?
		""",
		"",
		x -> x == false
	),
	Activity(
		"""
		What value does the function call endswith("Earth",a_string) return?
		""",
		"",
		x -> x == false
	),
	Activity(
		"""
		Try out the following function calls: lowercase(a_string), uppercase(a_string)
		and titlecase(a_string).
		""",
		"",
		x -> true
	),
	Activity(
		"""
		Try out the call: replace(a_string, "lands" => "countries"). Then find out the
		type of the second argument of this function call:
		""",
		"typeof(\"lands\" => \"countries\")",
		x -> (x <: Pair)
	),
	Activity(
		"""
		The call split(a_string, " ") divides a_string into tokens separated by the
		space symbol " ". How many tokens arise if we split a_string using the
		separator "an"?
		""",
		"split(a_string,\"an\")",
		x -> x == 5
	),
	Activity(
		"""
		We can convert numbers to strings. For example, what result do you get if
		you enter string(2.718)?
		""",
		"",
		x -> x == "2.718"
	),
	Activity(
		"""
		And converting back again, what result do you get if you enter
		parse(Float64,"2.718")?
		""",
		"parse() parses argument 2 according to the type of argument 1.",
		x -> x == 2.718
	),
]