#========================================================================================#
#	Laboratory 2
#
# Programs, types and functions
#
# Author: Niall Palfreyman, 04/01/2022
#========================================================================================#
[
	Activity(
		"""
		In this laboratory we look at the very heart of Julia: How it uses types to dispatch
		functions - that is, how Julia decides which particular implementation method
		it will use to calculate the value of a function call.

		First let's start with the structure of a Julia program. Every Julia program
		starts off as a string:

			prog = "8 / (2 + 3.0)"

		Enter this mini-program, then use Meta.parse() to analyse the program into an expression
		'expr' and tell me the typeof() expr:
		""",
		"expr = Meta.parse(prog)",
		x -> (x==Expr)
	),
	Activity(
		"""
		An Expr is a structure with two parts: a head (expr.head) and a vector of arguments
		(expr.args). What is the head of expr?
		""",
		"expr.head",
		x -> x==:call
	),
	Activity(
		"""
		Use the function dump() to view the entire structure of expr. As you can see,
		the .args field of expr is a Vector. Use your experience of accessing vector elements
		to find out the typeof the second argument of the third argument of expr:
		""",
		"dump(expr) or expr.args[3].args[2] - Try both! :-)",
		x -> x==Int64
	),
	Activity(
		"""
		And of course we can execute (i.e., evaluate) our expression using the function eval().
		What is the value of expr?
		""",
		"eval(expr)",
		x -> x==1.6
	),
	Activity(
		"""
		An expression is a tree that can be evaluated. We call such an evaluation tree a
		METHOD: a single, particular implementation of some function we wish to evaluate.
		Let's look at a more complicated evaluation tree. Create the following method for
		calculating the factorial of an Integer value:

			fact(n::Integer) = Meta.parse("(\$n ≤ 1) ? 1 : \$n * eval(fact(\$(n-1)))")

		Notice how we're using string interpolation here to insert the value of the
		argument n into an Expr tree structure that we can study. Use dump, .head and .args
		to study the tree structure of fact(5), and then evaluate that tree ...
		""",
		"eval(fact(5))",
		x -> x==120
	),
	Activity(
		"""
		Our fact() method for Integers is working fine, however we also have a problem:
		What if we wished to calculate the factorial of the floating-point value 5.0? Try
		doing this now to see that it does not work...
		
		This problem actually makes perfect sense. For example, if we allow float values,
		how would we go about calculating fact(5.01)? To calculate the factorial of a float
		value, we need to use the Gamma function gamma(). First load the SpecialFunctions library:

			using SpecialFunctions

		Now experiment with the gamma function to find out its relationship to factorial.
		For example, what value of n yields the result gamma(n) == fact(5)?
		""",
		"n == 6",
		x -> x==6
	),
	Activity(
		"""
		Now write a new factorial method for Real numbers:

			fact(n::Real) = Meta.parse("gamma(\$(n+1))")

		Now use dump, .head and .args to study the tree structure of fact(5.0), and then
		evaluate that tree ...
		""",
		"eval(fact(5.0))",
		x -> x==120.0
	),
	Activity(
		"""
		What is the value of fact(5.01)?
		""",
		"eval(fact(5.01))",
		x -> round(x,digits=2) == 122.07
	),
	Activity(
		"""
		Looking at the method tree for fact(5) and for fact(5.0), you can see that
		Julia is using the type of the function's arguments to decide which method to
		use for calculating the function fact(). This decision-process is called
		DISPATCHING, and it is extremely useful!
		
		Our first fact() method is quicker and simpler in cases where the argument name
		is an Integer, whereas the second method is more effective in cases where n is
		a Real number. The Dispatcher automatically chooses which method is needed for
		the various argument types.

		Use methods() to see a list of the different methods you have written for the
		function fact(). If you are unsure how to use the methods() function, type '?'
		at the Julia prompt and then enter "methods".

		What is the typeof the return result of methods()?
		""",
		"methods(fact)",
		x -> x == Base.MethodList
	),
	Activity(
		"""
		Since types are so important for dispatching functions, let's try creating our
		own user-defined types. First create a few ABSTRACT types to represent various
		biological organisms:

			abstract type Organism end
			abstract type Animal <: Organism end

		Now use the supertype() function to find the supertype of Animal. What type is
		returned if you ask for the subtypes() of Organism?
		""",
		"subtypes(Organism)",
		x -> (x <: Vector)
	),
	Activity(
		"""
		Next create a CONCRETE subtype of our abstract Animal type:

			struct Weasel <: Animal
				name::String
				weight::Integer
				female::Bool
			end

		Use the function fieldnames() to inspect the individual fields of the Weasel
		type, then give me the descriptor of the third field
		""",
		"fieldnames(Weasel)[3]",
		x -> x == :female
	),
	Activity(
		"""
		We use struct types to instantiate concrete OBJECTs in computer memory by
		entering specific values for the individual fields of the Weasel struct:
		
			wendy = Weasel( "Wendy", 101, true)
			willy = Weasel( "Willy", 115, false)

		Notice that types start with an UPpercase letter, whereas objects start with a
		lowercase letter. By default, Julia creates structs as IMMUTABLE - that is, we
		cannot modify the value of their fields. This means Julia can always know exactly
		how much memory an object needs, which provides major performance advantages. Try
		changing the value of Wendy's gender to see that this is not allowed. What word
		does the resulting exception message use to describe the struct you tried to modify?
		""",
		"wendy.female = false",
		x -> lowercase(strip(x)) == "immutable"
	),
	Activity(
		"""
		Immutability might at first seem awkward, but very often we don't want to change
		an object's fields, but instead want to replace one object by another. This way
		of using objects is far faster and less error-prone. If, however, we do want to
		change the fields of a type, we must define it as MUTABLE, like this:

			mutable struct Rabbit <: Animal
				name::String
				length::Integer
			end

			rabia = Rabbit( "Rabia", 27)

		Change Rabia's length to 29 cm, then give Rabia to me to look at for myself:
		""",
		"rabia.length = 29",
		x -> (x.length == 29)
	),
	Activity(
		"""
		Unlike object-oriented languages, which only dispatch on the first argument of a
		function, a major design feature of Julia is that it uses MULTIPLE DISPATCHING,
		which is particularly important when we use Julia to perform biological simulations.
		To see multiple dispatching in action, let's use our above type definitions. 

		When Animals meet each other, they react in different ways according to their type:
		Weasels challenge each other, but they attack Rabbits. We could implement these
		different interactions using if-else conditionals, but it is easier to use
		multiple dispatching. Enter the following definitions at the Julia prompt:

			meet( meeter::Weasel, meetee::Rabbit) = "attacks"
			meet( meeter::Weasel, meetee::Weasel) = "challenges"
			meet( meeter::Rabbit, meetee::Rabbit) = "sniffs"
			meet( meeter::Rabbit, meetee::Weasel) = "hides"
			meet( meeter::Organism, meetee::Organism) = "ignores"
		
		Test these definitions by finding out what happens when Rabia meets Wendy:
		""",
		"meet(rabia,wendy)",
		x -> occursin( "hide", lowercase(x))
	),
	Activity(
		"""
		The dispatcher must make these decisions during the execution time of our
		simulation program. Enter the following function definition:

			function encounter( meeter::Organism, meetee::Organism)
				println( meeter.name, " meets ", meetee.name, " and ", meet(meeter,meetee), ".")
			end
		
		Now test this function by calling encounter() with various combinations of
		Wendy, Willy and Rabia.

		What happens if you create a new Rabbit called Robby, and Rabia encounters him?
		""",
		"meet(robby,rabia)",
		x -> occursin( "sniff", lowercase(x))
	),
	Activity(
		"""
		Now, to see the full power of multiple dispatching, add your own new concrete
		type and then check how an encounter between your type and Rabia works out. Do
		it something like this:

			struct Tree <: Organism; name::String end
			tilly = Tree( "Tilly")

		How does Rabia react to Tilly?
		""",
		"encounter(rabia,tilly)",
		x -> occursin( "ignores", lowercase(x))
	),
	Activity(
		"""
		And now one final Activity for you: Can you add a new type of Organism called
		Grass, and arrange for Rabia to eat it? It is possible to do this in just 3-4
		new lines of code.
		""",
		"encounter(meeter::Rabbit,meetee::Grass) = \"eats\"",
		x -> occursin( "eats", lowercase(x))
	),
]