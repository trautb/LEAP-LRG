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
		In this laboratory we look at the issue of encapsulation that we saw at the end of the
		previous laboratory. There, we found that the value of the GLOBAL variable fig had been
		overwritten by the code inside the function myheatmap() ...

			THIS IS SOMETHING THAT SHOULD _NEVER_EVER_ HAPPEN!

		We are sometimes tempted to use global variables to pass data between functions, but
		this ALWAYS carries the danger that someone might change the value of these variables
		by accident - particularly since it is usually extremely difficult for users of our
		program to notice that we are using global variables to pass the data!

		A large part of the science of informatics concerns how to pass data in ways that
		protect that data from being changed by accident, and that is what we will investigate
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
		Aha! So although we can change the value of paula locally within change_paula(), this
		does not change the GLOBAL value of paula. In fact, there exist two different variables
		named paula: the GLOBAL variable containing the value 5, and a LOCAL variable containing
		the value 7. When change_paula() ends, the variables in its local scope are thrown away,
		and the LOCAL paula disappears.

		If we REALLY want to change the global value of paula, we can do so by redefining the
		function change_paula():

		function change_paula()
			global paula = paula + 2
			paula
		end

		This is what I did in the function myheatmap of laboratory 6. It is NOT a good idea! Tell
		me the value of paula now:
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
		The problem is that linus is a Vector that refers to its contents (5,4,3,2,1). We are not
		allowed to change the value of linus, but we ARE allowed to change the contents that it
		refers to. So global variables are still unsafe! What are we to do? The solution is this:

		ALWAYS encapsulate (i.e.: wrap/hide) EVERYTHING you do inside a MODULE!

		Let's see how to do this. Enter the following code:

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
		random numbers is very time-expensive, so in this laboratory we develop a Casino module
		that can generate arrays of random values very quickly.

		There is just one thing we need to do first. Our modules can get quite complex, so we
		will build them up step-by-step within the Ingolstadt filesystem. Please create now a
		subfolder of Ingolstadt\\src named "Development", then create within the Development
		folder another subfolder named "Casinos". Finally, create withïn the Casinos folder an
		empty file named "Casinos.jl" that will contain our wonderful new module ...
		""",
		"Create this file structure now, before continuing",
		x -> isfile("Development/Casinos/Casinos.jl")
	),
	Activity(
		"""
		If you study the file Ingolstadt.jl, you will see that it contains my source code. It's
		all packed into a module named Ingolstadt, and this module is prefixed by a triple-quoted
		multi-line string that describes its purpose. Use my source code as a template to create
		in the file Casinos.jl a module Casinos prefixed by an explanatory help-string, and which
		contains the following test code:

		module Casinos
		test = 5
		end
		""",
		"",
		x -> true
	),
	Activity(
		"""
		Now test your new module by entering this line at the Julia prompt:

		include("src/Development/Casinos/Casinos.jl")

		This will read and parse the Casino module, and you can test it by telling me the
		answer to the following line:

		Casinos.test
		""",
		"",
		x -> x==5
	),
	Activity(
		"""
		Now we can develop our Casinos module in the file Casinos.jl. We start by setting up a
		use-case for the module - that is, we sketch out how we will want to use the module when it
		is finished. Replace your module definition in the file Casinos.jl by the following code,
		then move on to the next activity:

		module Casinos

		#-----------------------------------------------------------------------------------------
		\"""
			unittest()

		Unit-test the Casinos module.
		\"""
		function unittest()
			println("\\n============ Unit test Casinos: ===============")
			println("Casino vault of randomness 2 for matrix withdrawals up to size (2x3):")
			casino = Casino(2,3,2)
			display( casino.vault)
			println()
		
			println("Draw several (2x3) matrices from the casino:")
			display( draw( casino,2,3)); println()
			display( draw( casino,2,3)); println()
			display( draw( casino,2,3)); println()
		
			println("Finally, reshuffle the casino and redisplay its vault:")
			shuffle!(casino)
			display(casino.vault)
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

		If you enter Casinos.unittest() at the Julia prompt, you should see that the command
		runs, but throws various errors (exceptions). We will now start to fix those errors...

		First, let's comment out the lines of unittest() that are causing problems. Insert the
		multi-line comment marker #= at the beginning of the third line of unittest() so that
		it looks like this:
			
		#=	casino = Casino(2,3,2)

		Next, close this multi-line comment by inserting the marker =# to the right of the final
		line of unittest():

			display(casino.vault) =#

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
		(maxrows), and a maximum number of columns (maxcols). It also contains a vault of prepared
		random numbers from which it draws the arrays.
		\"""
		struct Casino
			maxrows::Int							# Maximum number of drawable rows
			maxcols::Int							# Maximum number of drawable columns
			randomness::Int							# How randomised will our withdrawals be?
			vault::Matrix							# Repository of random numbers in [0,1)
		
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
		Casino. Now tell me the size of the Casino vault, and think about why I have designed this
		size to depend on the constructor argument randomness:
		""",
		"",
		x -> x == (6,8)
	),
	Activity(
		"""
		Did you work out why the size of the vault depends on randomness? The idea is that we
		want to draw random matricess from the Casino like drawing cards from a shuffled deck of
		cards, and that is only possible if the deck contains more cards than we actually need.

		Now we'll implement the draw() method. First reveal the next four lines of unittest() and
		insert the following dummy code immediately after the "Module methods:" comment. Now test
		this dummy version of draw to make sure it is robust before moving on:

		\"""
			draw( casino, nrows, ncols)
		
		Draw the required number of rows and columns from the casino vault, first ensuring that the
		vault is large enough to support the withdrawal.
		\"""
		function draw( casino::Casino, nrows::Int, ncols::Int)
			if nrows > casino.maxrows || ncols > casino.maxcols
				# Repository is too small - throw exception:
				error( "Requested withdrawal is too large")
			end
		
			# Choose random offsets and strides for drawing a matrix of size (nrows x ncols) from
			# the vault, assuming that it is big enough to support the withdrawal:
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

			vaultrows, vaultcols = size(casino.vault)
			offset_r = rand( 1 : (vaultrows-nrows))
			stride_r = (nrows <= 1) ? 1 :
							rand( 1 : (vaultrows-offset_r) ÷ (nrows-1))
			offset_c = rand( 1 : (vaultcols-ncols))
			stride_c = (ncols <= 1) ? 1 :
							rand( 1 : (vaultcols-offset_c) ÷ (ncols-1))
		
			# Return a randomly chosen table of slices from the vault:
			casino.vault[
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
		able to shuffle the contents of the vault to give new random values. Reveal all lines
		of code in unittest(), insert the command "using Random" at the beginning of the Casinos
		module - immediately after the line "module Casinos", then insert the following code after
		draw() in Casinos. Then test the module again:

		#-----------------------------------------------------------------------------------------
		\"""
			shuffle!( casino)

		Reassign random values in the vault.
		\"""
		function shuffle!( casino::Casino)
			rand!( casino.vault)
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
		casinos = Casinos.Casino(3,3,5)
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