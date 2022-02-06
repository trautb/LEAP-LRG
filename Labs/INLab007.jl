#========================================================================================#
#	Laboratory 7
#
# Encapsulation
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

		It is sometimes tempting to use global variables to pass data between functions, but
		they ALWAYS carry the danger that they can be changed by accident - particularly
		because it is usually extremely difficult for users of our program to notice that we
		are using global variables to pass the data!

		A large part of the science of informatics concerns how to pass data in ways that
		protect that data from being changed by accident, and that is what we will investigate
		in this laboratory.

		In our first experiment, enter the following code, then tell me the value paula:

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
		x -> 7
	),
	Activity(
		"""
		Your result shows us two things: a) The value of the GLOBAL variable paula is available
		inside the LOCAL scope of the function change_paula(); b) We can change the value of
		paula within this LOCAL scope.

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
			global paula = 7
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
		allowed to change the value of linus, but we are allowed to change the contents that it
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
		some real live software development! There is just one further thing we need to do before
		starting: ???
		""",
		"",
		x -> true
	),
	Activity(
		"""
		""",
		"",
		x -> true
	),
	Activity(
		"""
		""",
		"",
		x -> true
	),
	Activity(
		"""
		""",
		"",
		x -> true
	),
	Activity(
		"""
		""",
		"",
		x -> true
	),
	Activity(
		"""
		""",
		"",
		x -> true
	),
	Activity(
		"""
		""",
		"",
		x -> true
	),
	Activity(
		"""
		""",
		"",
		x -> true
	),
	Activity(
		"""
		""",
		"",
		x -> true
	),
	Activity(
		"""
		""",
		"",
		x -> true
	),
	Activity(
		"""
		""",
		"",
		x -> true
	),
	Activity(
		"""
		""",
		"",
		x -> true
	),
	Activity(
		"""
		""",
		"",
		x -> true
	),
	Activity(
		"""
		""",
		"",
		x -> true
	),
	Activity(
		"""
		""",
		"",
		x -> true
	),
	Activity(
		"""
		""",
		"",
		x -> true
	),
	Activity(
		"""
		""",
		"",
		x -> true
	),
	Activity(
		"""
		""",
		"",
		x -> true
	),
	Activity(
		"""
		""",
		"",
		x -> true
	),
	Activity(
		"""
		""",
		"",
		x -> true
	),
	Activity(
		"""
		""",
		"",
		x -> true
	),
	Activity(
		"""
		""",
		"",
		x -> true
	),
	Activity(
		"""
		""",
		"",
		x -> true
	),
	Activity(
		"""
		""",
		"",
		x -> true
	),
	Activity(
		"""
		""",
		"",
		x -> true
	),
]