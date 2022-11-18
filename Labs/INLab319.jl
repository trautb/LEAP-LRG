#========================================================================================#
#	Laboratory 7
#
# Encapsulation and software design.
#
# Author: Niall Palfreyman, 06/02/2022
#========================================================================================#
[
	Activity(
		"""
		In this laboratory we look at the issue of encapsulation - a super-important topic in
		modern software engineering. The point is that if everyone is able to change the
		value of important variables, our code will be EXTREMELY hard for people to understand
		and debug. I have seen one firm come to bankruptcy because of this problem. How does it
		come about?

		In a moment, you will discover that the variables inside a module or function have LOCAL
		SCOPE - that is, they are only visible and available inside that function, and not in
		the GLOBAL SCOPE outside the function.

		Sometimes, we are tempted to pass data from one function to another by storing that data
		in global variables, but this ALWAYS brings with it the danger that someone might change
		that data by accident - particularly because it is often very difficult for users of our
		program to notice that we are using global variables to pass the data!

		A large part of the science of informatics concerns how to pass data in ways that
		protect that data from being changed by accident, so that is what we will investigate
		in this laboratory.

		In our first experiment, enter the following code, then tell me the value of paula:

		linus = [5,4,3,2,1]; paula = 5
		""",
		"",
		x -> x==5
	),
	Activity(
		"""
		Now enter the following function:

		function change_paula()
			paula = 7
			paula
		end

		Then call the function change_paula() and tell me the value you get back:
		""",
		"Your result may (not) surprise you, depending on how you think about scoping rules",
		x -> x==7
	),
	Activity(
		"""
		Your result shows us that the variable paula has two different meanings: the meaning in
		the GLOBAL scope outside the function change_paula, and the meaning inside the LOCAL
		scope of change_paula.

		Now tell me the current value of paula:
		""",
		"Ask Julia for the value of paula",
		x -> x==5
	),
	Activity(
		"""
		Aha! So although we can change the value of LOCAL paula inside the function change_paula(),
		this does not affect the value of GLOBAL paula. In fact, there exist two different variables
		named paula: the GLOBAL variable containing the value 5, and a LOCAL variable containing
		the value 7. When change_paula() ends, the variables in its local scope are thrown away,
		and the LOCAL paula disappears.

		If we REALLY want to change the global value of paula, we can do so by redefining the
		function change_paula():

		function change_paula()
			global paula = 7
			paula
		end

		NOTE: Doing this is a Very Bad Idea! Tell me the value of paula now:
		""",
		"",
		x -> x==7
	),
	Activity(
		"""
		So Julia does allow us to make use of global values inside a local scope, but it forces us
		to announce this by using the keyword "global".

		There is a further issue here. Enter this code:

		function change_linus()
			linus[3] = 7
			linus
		end

		Again, the return value tells us that we are able to change the value of a local variable
		named linus. But now tell me the value of the GLOBAL variable named linus:
		""",
		"",
		x -> x==[5,4,7,2,1]
	),
	Activity(
		"""
		The point here is that linus is a Vector that refers to its contents (5,4,3,2,1). Julia
		does not allow us to change the value of linus, however it DOES allow us to change the
		CONTENTS that linus refers to. So global variables are still unsafe! What are we to do?
		The solution is this:

			ALWAYS encapsulate (i.e.: wrap/hide) EVERYTHING you do inside a MODULE!

		Modules offer a very effective of preventing our variables and code from being changed by
		other programmers. Let's see how to do this. Enter the following code:

		module MyModule
			function change_paula1()
				global paula = 9
				paula
			end
		end

		Now call MyModule.change_paula1(), then tell me the value of paula afterwards:
		""",
		"",
		x -> x==7
	),
	Activity(
		"""
		OK, so putting change_paula1() inside the module MyModule means it cannot interfere
		with the value of our global variable paula. But wait! We know that we can load
		modules into global scope by means of the keyword "using": will that make it possible
		for users change paula's value by accident? Load the module MyModule now:

		using .MyModule

		Repeat the previous experiment - what is the value of paula afterwards?
		""",
		"",
		x -> x==7
	),
	Activity(
		"""
		Great! Now that we know how to hide variables and functions inside a module, we can do
		some real live software development! In the next laboratory, we will develop a genetic
		algorithm (GA), and GAs need to work with arrays of random values. However, generating
		random numbers is very time-expensive, so in this laboratory we will develop a software
		tool called a Casino that will later help us generate arrays of random values very quickly.

		There is just one thing we need to do first. Our modules can get quite complex, so we
		will build them up step-by-step within the Ingolstadt filesystem. If you look in the
		directory Ingolstadt/Development/Casinos, you will find a file named Casinos.jl. At
		present, this is just a dummy file that doesn't do anything except create a module named
		Casinos that contains the single variable test. Notice that the module Casinos is prefixed
		by a triple-quoted multi-line string that describes its purpose.
		
		Whenever you start writing a new module, always start the same way I have here - creating
		a very simple file that you can gradually expand into a complex program. We call this
		style of programming AGILE programming, because it is a good way to get started quickly
		on the job of programming a new module.

		Tell me the value that I have assigned to test inside the Casinos module:
		""",
		"The program statement is in line 11 of Casinos.jl",
		x -> x==5
	),
	Activity(
		"""
		Now we'll test the Casinos module by reading and parsing the file Casinos.jl. Enter the
		following line from inside the Ingolstadt folder:

		include("src/Development/Casinos/Casinos.jl")

		Now you can test the Casinos module by telling me the answer to the following line of code:

		Casinos.test
		""",
		"",
		x -> x==5
	),
	Activity(
		"""
		Bingo! Our new module works! Now we can develop our Casinos module in the file Casinos.jl.
		We start by setting up a USE-CASE for the module - that is, we sketch out how we will want
		to use the module when it is finished. Replace your module definition in the file Casinos.jl
		by the following code, then move on to the next activity:

			module Casinos

			#--------------------------------------------------------------------------------------
			\"""
				unittest()

			Unit-test the Casinos module.
			\"""
			function unittest()
				println("\\n============ Unit test Casinos: ===============")
				println("Casino deck of randomness 2 for matrix withdrawals up to size (2x3):")
				casino = Casino(2,3,2)
				display( casino.deck)
				println()
			
				println("Draw several (2x3) matrices from the casino:")
				display( draw( casino,2,3)); println()
				display( draw( casino,2,3)); println()
				display( draw( casino,2,3)); println()
			
				println("Finally, reshuffle the casino and redisplay its deck:")
				shuffle!(casino)
				display(casino.deck)
			end

			end # of Casinos
		""",
		"Note: you can't compile or run Casinos yet - just enter this code and move on",
		x -> true
	),
	Activity(
		"""
		You can test your new module by reincluding Casinos.jl:

		include("src/Development/Casinos/Casinos.jl")

		If you enter Casinos.unittest() at the Julia prompt, you will see that the command
		runs, but throws lots of errors (exceptions). We'll now start fixing those errors...

		First, comment out the lines of unittest() that are causing problems. Insert the
		multi-line comment marker #= at the beginning of the third line of unittest() so that
		it looks like this:
			
		#=	casino = Casino(2,3,2)

		Next, close this multi-line comment by inserting the marker =# to the right of the final
		line of unittest():

			display(casino.deck) =#

		Reinclude Casinos.jl. Now you should be able to run Casino.unittest() without errors.
		Tell me the last six characters that you see in the output:
		""",
		"You should get two lines of output, and the final characters specify a matrix size",
		x -> x == "(2x3):"
	),
	Activity(
		"""
		To start developing our new module, we'll define the type Casino. Insert the following
		code AFTER the "module" line and BEFORE the comment box before unittest(), and check that
		everything still includes and runs properly:

		using Random

		#-----------------------------------------------------------------------------------------
		# Module types:
		
		\"""
			Casino
		
		A Casino can return arrays of random numbers in the range [0,1), up to a maximum number of rows
		(maxrows), and a maximum number of columns (maxcols). It also contains a deck of prepared
		random numbers from which it draws the arrays.
		\"""
		struct Casino
			maxrows::Int							# Maximum number of drawable rows
			maxcols::Int							# Maximum number of drawable columns
			randomness::Int							# How randomised will our withdrawals be?
			deck::Matrix							# Repository of random numbers in [0,1)
		
			"The one and only constructor"
			function Casino(maxrows::Int,maxcols::Int,randomness::Int=5)
				new(
					maxrows, maxcols, randomness,
					rand((maxrows+1)*randomness,(maxcols+1)*randomness)
				)
			end
		end
		
		#-----------------------------------------------------------------------------------------
		# Module methods:
		""",
		"Remember your code won't do anything new yet: just getting it to run is your first goal!",
		x -> true
	),
	Activity(
		"""
		Right, now let's activate the new code. Remove the open-comment marker from the third line
		of unittest() and insert it instead at the beginning of the 7th line:

		#=	println("Draw several (2x3) matrices from the casino:")

		This reveals the lines 3-6. Test that your program can now correctly create and display a
		Casino. Now tell me the size of the Casino deck, and think about why I have designed this
		size to depend on the constructor argument randomness:
		""",
		"",
		x -> x == (6,8)
	),
	Activity(
		"""
		Did you work out why the size of the deck depends on randomness? The idea is that we
		want to draw random matricess from the Casino like drawing cards from a shuffled deck of
		cards, and that is only possible if the deck contains more cards than we actually need.

		Now we'll implement the draw() method. First reveal the next four lines of unittest() and
		insert the following dummy code immediately after the "Module methods:" comment. Now test
		this dummy version of draw to make sure it is robust before moving on:

		\"""
			draw( casino, nrows, ncols)
		
		Draw the required number of rows and columns from the casino deck, first ensuring that the
		deck is large enough to support the withdrawal.
		\"""
		function draw( casino::Casino, nrows::Int, ncols::Int)
			if nrows > casino.maxrows || ncols > casino.maxcols
				# Repository is too small - throw exception:
				error( "Requested withdrawal is too large")
			end
		
			# Choose random offsets and strides for drawing a matrix of size (nrows x ncols) from
			# the deck, assuming that it is big enough to support the withdrawal:
			ones(nrows,ncols)
		end

		""",
		"",
		x -> true
	),
	Activity(
		"""
		Now comes the cool part of the code. Notice how we have made absolutely sure that by the
		time we get to the dummy line "ones(nrows,ncols)", we can rely on the values nrows and
		ncols being small enough to be able to draw our new random matrix. Now replace this
		dummy line by the following code and test it:

			deckrows, deckcols = size(casino.deck)
			offset_r = rand( 1 : (deckrows-nrows))
			stride_r = (nrows <= 1) ? 1 :
							rand( 1 : (deckrows-offset_r) ÷ (nrows-1))
			offset_c = rand( 1 : (deckcols-ncols))
			stride_c = (ncols <= 1) ? 1 :
							rand( 1 : (deckcols-offset_c) ÷ (ncols-1))
		
			# Return a randomly chosen table of slices from the deck:
			casino.deck[
				(offset_r : stride_r : (offset_r + (nrows-1)*stride_r)),
				(offset_c : stride_c : (offset_c + (ncols-1)*stride_c))
			]
		""",
		"",
		x -> true
	),
	Activity(
		"""
		Finally, we'll now give Casinos the functionality of shuffling. We want users to be
		able to shuffle the contents of the deck to give new random values. Reveal all lines
		of code in unittest(), insert the command "using Random" at the beginning of the Casinos
		module - immediately after the line "module Casinos", then insert the following code after
		draw() in Casinos. Then test the module again:

		#-----------------------------------------------------------------------------------------
		\"""
			shuffle!( casino)

		Reassign random values in the deck.
		\"""
		function shuffle!( casino::Casino)
			rand!( casino.deck)
		end

		""",
		"",
		x -> true
	),
	Activity(
		"""
		Congratulations! You have written your first Julia module! You can test its functionality
		for yourself by doing something like this at the Julia prompt:

		include("src/Development/Casinos/Casinos.jl")
		casino = Casinos.Casino(3,3,5)
		Casinos.draw(casino,3,3)

		Make sure you also test error cases like this:

		Casinos.draw(casino,7,9)
		""",
		"",
		x -> true
	),
	Activity(
		"""
		There is just one small thing we can do to make life easier for users of the Casinos
		module: We shall expose the new functionality. After all, it's a pain to have to write
		"Casinos." in front of every command. To avoid this, insert the following lines between
		the line "module Casinos" and the line "using Random":

		# Externally callable methods of Casinos
		export Casino, draw, shuffle!
		
		Now reinclude Casinos.jl and repeat your tests from the previous activity, but this time
		first enter "using .Casinos" at the Julia prompt. You should now be able to call all the
		Casinos functionality without typing "Casinos." in front of everything. :)
		""",
		"",
		x -> true
	),
]