#========================================================================================#
#	Laboratory 5
#
# Replication: How do populations grow? (Including encapsulation and software design)
#
# Author: Niall Palfreyman, 05/09/2022
#========================================================================================#
[
	Activity(
		"""
		In this laboratory we look at the issue of encapsulation - a super-important topic in
		modern software engineering. If everyone is able to change the value of important variables
		in our program, this will make it EXTREMELY hard for people to understand exactly how our
		program works, so encapsulation HIDES data from unwanted changes. In particular, we want
		others to be able to understand, adapt and maintain our code. I have seen one firm come to
		bankruptcy because they forgot to use encapsulation properly. So how does it work?

		In a moment, you will discover that the variables inside a module or function have LOCAL
		SCOPE - that is, they are only visible and available inside that function, and not in
		the GLOBAL SCOPE outside the function.

		Sometimes, we are tempted to pass data from one function to another by storing that data
		in global variables, but this ALWAYS brings with it the danger that someone might change
		that data by accident, and so cause our program to crash! In this laboratory we investigate
		how to pass data in ways that protect it from being changed by accident.

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
		"Your result may (or not) surprise you, depending on how you think about scoping rules",
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
		"You should find that change_paula() is still safe, even when you have loaded MyModule",
		x -> x==7
	),
	Activity(
		"""
		Great! Now that we know how to hide variables and functions inside a module, we can do
		some real live software development! In later laboratories we will develop our own
		software modules; however, these modules can get quite complex, so we must first learn
		to build them up step-by-step within a file. If you look in the directory
		Ingolstadt/Development/Altruism, you will find a file named Replicators.jl. Open this file
		now and study its contents. What is the name of the data type defined in the file?
		""",
		"The definition is in line 22 of Replicators.jl",
		x -> x=="Replicator"
	),
	Activity(
		"""
		You can use Replicators.jl as a general template for designing any new module. Whenever
		you want to create a new module, I recommend that you simply copy the file Replicators.jl
		to a new file, then change its contents to suit your own needs.

		Notice several things about Replicators.jl. First, it contains just one module called
		Replicators, and in this module the data type Replicator is defined. It provides no further
		code other than the use-case unittest() for the code that we will now implement. A use-case
		is a user program that tests the code that we intend to write. So, for example, we intend
		to write a function run!() that will run a Replicator simulation, so unittest() calls this
		function, but for now I have commented out the call because we haven't yet implemented it.

		Now read and parse the file Replicator.jl. You can do this either by using the Play button
		in VSC or else by entering the following Julia code from inside the Ingolstadt folder:

		include("src/Development/Altruism/Replicators.jl")

		It is important that our use-case runs correctly, because it is the starting-point for
		developing and testing all our software. Run the use-case now by calling the function
		Replicators.unittest() and tell me in which line of code you get your first error:
		""",
		"",
		x -> x==46
	),
	Activity(
		"""
		As you can see, Julia tells us that we have not yet defined a method for the function
		run!(). We will have to do that later, but for now, just comment out the three lines in
		which run!() is called, and check that Replicators.unittest() now runs correctly without
		errors.

		Now we will develop our Replicators module by making successive changes to the file
		Replicators.jl. We will start by thinking about how to construct a Replicator. At present,
		we need to specify the timescale, timestep and timeseries in line 41, but of course we
		don't know the value of the timeseries until the Replicator simulation has run. Also, it
		is more convenient for users if they only have to enter the duration and timestep of the
		simulation in line 41. For example, change line 41 to look like this:

			repl = Replicator(5,1)

		Now recompile and run unittest() and tell me in which line you get an error:
		""",
		"Where does unittest() start looking for a constructor that looks like Replicator(5,1)?",
		x -> x == 41
	),
	Activity(
		"""
		To fix this error, we must implement an appropriate constructor. In fact, we don't really
		want users to use the default constructor Replicator(t,dt,x) at all! We can block this by
		defining an Inner Constructor. Go to line 22 of Replicators.jl and change the definition
		of the data type Replicator to like this:

			struct Replicator
				t::Vector{Real}			# The simulation timescale
				dt::Real				# The simulation timestep
				x::Vector{Real}			# The population timeseries
			
				function Replicator( tfinal::Real, dt=1)
					t = 0.0:dt:tfinal
					new( t, dt, zeros(Float64,length(t)))
				end
			end
		
		Now rerun unittest() and tell me value of your Replicator's timescale:
		""",
		"You can read this from the first element in the displayed Replicator",
		x -> x == 0.0:1:5
	),
	Activity(
		"""
		OK! Now we have a real Replicator model, let's make it run!!! Between lines 30 and 31,
		insert the following lines of code:
			#-----------------------------------------------------------------------------------------
			\"""
				run!( replicator, x0, mu=1.0)
			
			Simulate the exponential growth of a population starting from the value x0 with growth
			constant mu.
			\"""
			function run!( repl::Replicator, x0::Real, mu::Real=1)
				repl.x[1] = x0						# Set initial value
			
				for i in 2:length(repl.t)
					# Perform Euler step:
					repl.x[i] = repl.x[i-1] + repl.dt * mu * repl.x[i-1]
				end
			
				repl								# Return the Replicator
			end
		
		Now remove the comment marker in front of the first call of run!(), then run unittest()
		and tell me the value of your Replicator's timeseries:
		""",
		"",
		x -> x == [1,2,4,8,16,32]
	),
	Activity(
		"""
		Congratulations! You have written your first simulation in Julia! Now remove the comment
		markers in front of the remaining calls to run!() and make sure everything runs correctly.
		""",
		"",
		x -> true
	),
	Activity(
		"""
		Now we can use our Replicator to start doing some experiments with replicating populations.
		You have already seen from unittest() how to change the values of dt and mu, but we'd like
		to do this manually for ourselves outside unittest(). Enter the following command at the
		Julia prompt - does it run successfully?
		
			yeast = Replicator(5,1)
		""",
		"You should get at error",
		x -> occursin("no",lowercase(x))
	),
	Activity(
		"""
		Of course we can't call Replicator() - we haven't yet loaded the module into our global
		Ingolstadt environment! So let's do that now:

			using .Replicators

		Can you now successfully create your Replicator?
		""",
		"You should still get an error",
		x -> occursin("no",lowercase(x))
	),
	Activity(
		"""
		What has happened?! Well, using a module doesn't load all of the methods in that module.
		After all, we sometimes want to write some private methods in the module that should not
		be used by users outside the module. For this reason, Julia requires us to explicitly
		export any names in our module to which we want external users to have access. Insert the
		following line between lines 11 and 12 in Replicators.jl:

			export Replicator, run!

		This makes the data type Replicator and the method run!() available to external users.
		Now save the file, re-include it, then enter the following at the Julia prompt:

			using .Replicators
			yeast = Replicator(5,1)
			run!(yeast,1)

		What is the value of the timeseries?
		""",
		"This should run correctly",
		x -> x == [1,2,4,8,16,32]
	),
	Activity(
		"""
		Now let's do an experiment. You have already created a Replicator whose population
		doubles in each generation, but large, asynchronous populations do not usually jump
		in size at regular time intervals! (Can you think of an animal population that does
		actually behave this way?)

		Let's now see what happens when our population grows in steps of 0.5 instead of 1:

			yeast = Replicator(5,0.5)
			run!(yeast,1)

		What is now the size of the yeast population when t = 1?
		""",
		"Remember that our timestep is now half the previous size, so more steps are needed",
		x -> x == 2.25
	),
	Activity(
		"""
		This is interesting. If the population grows in smaller timesteps, it also grows faster!
		So if we study the population over ever smaller timesteps, will it grow infinitely
		quickly? Let's investigate this phenomenon by looking at the population's growth more
		closely over the timescale 0-1:
	
			yeast = Replicator(1,0.2)
			run!(yeast,1)

		What is now the size of the yeast population when t = 1?
		""",
		"Since our timescale only runs to 1, it should be the last value in yeast.x",
		x -> abs(x-2.48832) < 0.1
	),
	Activity(
		"""
		OK, so reducing the timestep doesn't make the value increase infinitely. So does it maybe
		increase towards an upper limit? Find out by mapping the population over the timescale
		0-1 with a timestep of 0.001. Even this value is not yet accurate, since the sequence
		converges only very slowly, so you may want to investigate the case dt=1e-6. (You can
		suppress output from the Julia prompt by ending your input with a semicolon ;)

		What symbol do we use to represent the value of this limit?
		""",
		"You'll find that the limit lies around 2.718",
		x -> occursin('e',x)
	),
	Activity(
		"""
		You have discovered the reason why nature (and our cognition) cannot be a computer: NO
		computer can EVER simulate continuous time, where dt tends toward 0!

		However, we can do better than the Euler method above. If we set dt=0.01, we can improve our
		simulation results by using the more accurate Runge-Kutta-2 integration method. Replace the
		loop in your run!() method by the following code. Is your result closer to e than before?

			dt2 = repl.dt/2									# dt2 is one half-timestep
			for i in 2:length(repl.t)
				# Perform Runge-Kutta-2 step:
				x2 = repl.x[i-1] + mu*dt2*repl.x[i-1]		# Calculate new x halfway thru step
				repl.x[i] = repl.x[i-1] + mu*repl.dt*x2		# Use x2 as better approximation
			end
		""",
		"",
		x -> occursin("yes",lowercase(x))
	),
	Activity(
		"""
		Finally, you will now apply your exponential model to the problem of drinking and driving.
		If you drink two 25ml shots of whiskey, 8ml of alcohol immediately enters your blood. In
		Europe, you may only drive if the concentration of alcohol in your blood is less than 0.05%
		by volume. If you contain 6 litres of blood, this legal limit corresponds to a blood alcohol
		volume of 3ml. So how long must you wait until your liver has broken down the 8ml of blood
		alcohol to 3ml?

		To find this out, think about the story of how the liver works. In this bioprocess, the
		liver takes a cupful of your blood, then filters the alcohol out of this cupful. If there is
		no alcohol in the cupful, the alcohol breakdown rate is zero; the more alcohol there is, the
		higher the breakdown rate. If there are x=10 ml of blood alcohol, your liver breaks it down
		at a rate of dx/dt=-3 ml/hr. Assuming that breakdown is proportional to blood alcohol lever
		(i.e.: dx/dt=μx), what is the numerical value of μ in our particular case?
		""",
		"Remember that this is a breakdown process - not growth!",
		x -> x == -0.3
	),
	Activity(
		"""
		What function is the exact (analytic) solution of the equation dx/dt = -0.3 x ?
		""",
		"If you are unsure how to write the exponential function, look it up in this lab file.",
		f -> (f isa Function) && (t->f(t)==exp(-0.3t))(rand())
	),
	Activity(
		"""
		If μ is negative, the exponent of e in this solution is negative, so as time progresses,
		your blood alcohol level gets divided (not multiplied!) by e≈2.718 over each unit of time.
		What is the numerical value of x0 in our particular case?
		""",
		"",
		x -> x == 8
	),
	Activity(
		"""
		Create a simulation to calculate how many hours you must wait before you can drive legally
		after your two shots of whiskey.
		""",
		"Use logical indexing and findfirst to locate the time when x falls below 3.",
		x -> abs(x-3.3) < 0.1
	),
]