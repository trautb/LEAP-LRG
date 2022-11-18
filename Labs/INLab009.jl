#========================================================================================#
#	Laboratory 9
#
# Deterministic CHAOS and software development.
#
# Author: Niall Palfreyman, 06/09/2022
#========================================================================================#
[
	Activity(
		"""
		In this laboratory, we implement a program to demonstrate chaos in a gravitational system
		containing three bodies of equal mass in two dimensions. We will use Julia to analyse the
		execution of a complex simulation program, and adapt this program to use Runge-Kutta
		integration to demonstrate graphically chaotic 3-body motion.
		""",
		"",
		x -> true
	),
	Activity(
		"""
		In this lab, we investigate DETERMINISTIC CHAOS. Chaos is extremely important in biology,
		because it is the source of the spontaneity that we observe in living organisms. To see how
		chaos works, start by loading my Julia implementation of the Mathematica function nestlist():

			include("src/Development/Utilities/Utilities.jl")
			using .Utilities

		Take a look at the implementation of nestlist(), and then experiment with it. For example,
		what is the result of the following invocation?

			nestlist(x->2x,3,5)
		""",
		"",
		x -> x == [3,6,12,24,48,96]
	),
	Activity(
		"""
		nestlist() applies the function f repeatedly to the initial value x0, creating a list of
		the values that it generates in this way. You can see how this might be useful if we want
		to create a simulation of timesteps that repeat themselves over time. We'll do that now ...

		Imagine a population of wasps living on an island with renewable but limited resources.
		They can fill the island's carrying capacity (population x = 1), they can die out (x = 0),
		or else their population can have any value in the range 0 ≤ x ≤ 1. Also, they all die each
		winter, so their population takes on a new value each year: [x0,x1,x2,...,xn].
		
		For specific birthrate r, the wasp population's growth is governed by the logistic equation:

			x[i+1] = L(r)(x[i]), where L is a function parametrised by r: 
			L(r) = (pop -> r pop (1-pop))

		Implement the function L as an inline function at the Julia prompt, then experiment with
		using it. Then use your function L to calculate the wasp population two years after an
		initial population of x0 = 0.3, assuming that r = 0.5 (remember that pop might be a vector!):
		""",
		"L(r) = (pop -> r .* pop .* (1 .- pop))",
		x -> (0.04698 < x < 0.04699)
	),
	Activity(
		"""
		Use nestlist() to create a list of 5 simulation steps of the wasp population, starting from
		an initial value of 0.3 and using specific growth rate r = 0.5. You will see that the
		population x is tending towards a particular limiting value - what is that limit value?
		""",
		"nestlist(Λ(1),0.3,5)",
		x -> x==0
	),
	Activity(
		"""
		You should now be able to do the following: Use nestlist() to create a list of 20
		simulation steps of the wasp population with x0=0.3, r=0.9, then plot them in a graph.
		What is the limit point of this sequence?
		""",
		"lines(nestlist(Λ(0.9),0.3,20))",
		x -> x==0
	),
	Activity(
		"""
		OK, now we have the equipment, we can investigate the onset of chaos. We will slowly
		increase the value of the specific birthrate r to discover how this affects the
		developmental motion of the wasp population. Use the initial value x0=0.3 for all of the
		folloiwng excercises until I tell you otherwise.
		
		Just to make our language clear: a LIMIT POINT of the wasp population's motion is any
		value of the population that stays the same from one generation to the next: Λ(r)(x) == x.
		
		What was the limit point of the motion Λ(0.9)?
		""",
		"",
		x -> x==0
	),
	Activity(
		"""
		What is the approximate value of the limit point of the motion Λ(1.1)?
		""",
		"",
		x -> 0.07<x<0.1
	),
	Activity(
		"""
		What is the EXACT value of the limit point of the motion Λ(1.5)?
		""",
		"You can work it out for yourself by solving the equation Λ(r)(x) == x, or: r x (1-x) = x",
		x -> x == 1//3
	),
	Activity(
		"""
		Use the technique from the hint in the previous activity to calculate the limit point of
		the motion Λ(2), then check this value using your simulator:
		""",
		"",
		x -> x==0.5
	),
	Activity(
		"""
		Now investigate the motion Λ(2.1). In which direction does the population change from x[6]
		to x[7]: positive (+) or negative (-)?
		""",
		"",
		x -> (x == -)
	),
	Activity(
		"""
		This is interesting 00! Up to now, the development of the wasps has been monotone: the
		population has only either shrunk or grown. But now it grows above the value, then drops
		back down again. Let's investigate this further: find the limit point of the motion
		Λ(2.5) both by calculating and by simulating:
		""",
		"",
		x -> x==0.6
	),
	Activity(
		"""
		Notice that now we have an oscillating motion that dies away as x comes to rest at the
		limit point. Try out various values of r between 2.5 and 2.95. Does the oscillation
		still die away?
		""",
		"",
		x -> occursin("y",lowercase(x))
	),
	Activity(
		"""
		Now find the limiting motion of the population for Λ(3). Does the oscillation die away?
		""",
		"",
		x -> occursin("n",lowercase(x))
	),
	Activity(
		"""
		It now no longer makes sense to speak of a limit VALUE, since the motion oscillates
		forever around the value 2/3. Instead, we speak of a limit CYCLE: the motion Λ(3) displays
		a limit cycle around the value 2/3. "cycle" means the value oscillates forever, and
		"limit" means that it will converge to this cycle, no matter where we start the motion.
		Check this for yourself by changing the value of x0. Does the motion always converge on
		a cycle around 2/3?
		""",
		"",
		x -> occursin("y",lowercase(x))
	),
	Activity(
		"""
		How many oscillatory periods are contained within one complete limit cycle of the motion
		Λ(3)? That is, how many times does the population wobble up and down within ONE cycle? If
		you have difficulty understanding exactly what I am asking, try looking at the hint for
		this activity.
		""",
		"We call this limit cycle a \"period-1 limit-cycle\"!",
		x -> x==1
	),
	Activity(
		"""
		Let's investigate further. Look at the limit-cycle of the motion Λ(3.2) (You may want
		to extend the simulation's duration to 50). How many periods are in this limit cycle?
		""",
		"The number of periods should not (yet) have changed",
		x -> x==1
	),
	Activity(
		"""
		How many periods are in the limit-cycle of the motion Λ(3.45)? That is, how many complete
		oscillations does the population make before the motion repeats itself?
		""",
		"Count very carefully: This should be a period-2 limit-cycle!",
		x -> x==2
	),
	Activity(
		"""
		How many periods are in the limit-cycle of the motion Λ(3.55)? By now, things will move
		quite quickly and the wasp population will need a while to stabilise towards the limit-
		cycle. You may like to save time by using a line like this:

			lines(nestlist(Λ(3.55),0.5,5000)[end-40:end])
		""",
		"Look very carefully!",
		x -> x==4
	),
	Activity(
		"""
		How many periods are in the limit-cycle of the motion Λ(3.567)?
		""",
		"Count ve-ery carefully - remembering to inspect the smaller oscillations as well!",
		x -> x==8
	),
	Activity(
		"""
		How many periods are in the limit-cycle of the motion Λ(3.5695)? You will find this
		one difficult to count, but it is actually a period-16 limit-cycle. If you can't
		distinguish the oscillations, don't worry - just go on to the next activity.
		""",
		"",
		x -> x==16
	),
	Activity(
		"""
		We have seen that as r increases, period-doubling occurs, so the motion takes longer
		and longer before it repeats. Now check out the motion Λ(3.7). How long does it take
		before this motion repeats itself? Or in other words: What is the period-length of
		this limit-cycle?
		""",
		"Find out how to write \"Infinity\" in Julia :)",
		x -> x==Inf
	),
	Activity(
		"""
		We have come a long way, and what we have learned is that some naturally occurring systems
		can enter a type of motion in which they require an infinite amount of time to repeat, and
		so we call them CHAOTIC. Notice that this phenomenon has nothing to do with randomness. The
		population of Vespula Island is perfectly deterministic - we can always predict what will
		happen in the next step, but ONLY by actually simulating it! We cannot calculate in advance
		what will happen after 1000 iterations without actually performing ALL of the 1000 steps
		that lead up to it.

		Actually, the situation is even worse than this. Use the following command to inspect the
		behaviour of Λ(3.7) for the different starting conditions x0 ∈ [0.5,0.50001,4.99999]

			lines(nestlist(Λ(3.7),0.5,5000)[end-40:end])

		Are these three graphs at all similar to each other?
		""",
		"",
		x -> occursin("n",lowercase(x))
	),
	Activity(
		"""
		So you see, chaotic motion meanns that even very tiny changes in the initial conditions
		of a chaotic system lead to completely different behaviour. So even if we measured the
		current wasp population, we could never be sure that we had done it sufficiently accurately
		to be ABSOLUTELY sure that we are accurately predicting the development of the system!

		So. What has all this to do with your project? Henri Poincaré was the first to
		notice deterministic chaos. In 1908, he showed that the gravitational motion of three
		orbiting bodies cannot be solved exactly. Weather, dripping taps and driven pendula have a
		similar problem. We cannot predict the story of their future motion without simulation,
		which as you know is never precise! As an introduction to chaos in the three-body problem,
		please view the following video-clip now, and then proceed to the next activity:

		https://www.youtube.com/watch?v=LwkvO3t1b30&t=113s
		""",
		"",
		x -> true
	),
	Activity(
		"""
		Now we will see how to build up a complex scientific program starting from a set of
		requirements. Take a look at version 0 of my NBodies module:

			src/Development/NBodies/NBodies0.jl

		The aim of this module is to simulate N-body motion. If you look at the unittest()
		function, you will see that my basic use-case creates an instance of the type NBody,
		pushes two bodies into this model, then requests a simulation and graphical animation of
		the model.
		
		Notice that simulate() and animate() are at present just dummy functions that do nothing
		other than report back values. This use of dummy functions is EXTREMELY important in
		software development - it enables me to start designing my module from the external
		requirements, then to develop step-by-step the deeper mechanisms of the software. First
		we set up the use-case, then we slowly fill in the program details, making sure that each
		stage of development is fully robust before we go on to the next.
			
		Study version 0 of NBodies and tell me the line number(s) of the code that defines the
		fact that this is a TWO-dimensional simulation.
		""",
		"",
		x -> x in [109,110]
	),
	Activity(
		"""
		Software development is always driven by the needs of its CLIENT program - in our case,
		this is the function NBodies.unittest(). When you design unittest() in your own projects,
		think carefully about what kinds of behaviour you as a user require of the datatype NBody,
		then incorporate that requirement into unittest(), and implement the functionality in your
		module design. For example ...

		The client program unittest() in version 1 of NBodies (NBodies1.jl) is identical with the
		client program of version 0. The only things we have changed are to generate dummy (sin/cos)
		data in simulate() and then display this data in animate(). It is always a good idea to
		develop the graphical interface of a project first, so that you can visualise the iterative
		development of the project. All we are doing in version 1 is to set up the link between my
		program and GLMakie.

		Look at the dummy code in simulate() and animate() in version 1. What shape of curve do
		you expect to be generated by the dummy data in simulate()?
		""",
		"Try running the program, then explain to a partner how it generates the output curve",
		x -> occursin("ellipse",lowercase(x))
	),
	Activity(
		"""
		Now look at version 2 of NBodies. Here we start to implement Euler's method for integrating
		differential equations by introducing a very simple force acting on the masses, and
		then visualising the path of the integrated motion. Compile and run NBodies2.jl to see
		the results.

		In which line of NBodies2.jl do we define the force acting on the bodies?
		""",
		"Try running the program, then explain to a partner how it generates the output curve",
		x -> x == 105
	),
	Activity(
		"""
		In NBodies3.jl, we develop animation code for the simplified motion that we defined in
		version 2. Try out a few experiments at the Julia prompt to make sure you fully understand
		how we are using the Julia `map` command in lines l06, 107, 120 and 121.
		""",
		"",
		x -> true
	),
	Activity(
		"""
		In NBodies4.jl, we introduce the full interactional dynamics of the two bodies in the
		method simulate(). You need to make sure you understand the matrix programming techniques
		we are using - they are not easy! The core of the implementation is the matrix-based code
		in the method forceOnMasses(), which calculates for each body the (vector) sum of all
		gravitational forces caused by the other bodies. You will need to analyse this code and use
		Help and internet search to look up EVERYTHING you do not yet understand in
		forceOnMasses(). In the coming few activities we will learn how to do this ...

		First remember: Matrices work very naturally in Julia, so if a=[1 2;3 5] and b=[2 3;4 5],
		then a*b, b*a and a.*b will all deliver very different results. Test this idea now at the
		Julia prompt, then tell me the value of a*b-a.*b .
		""",
		"",
		x -> x == [8 7;14 9]
	),
	Activity(
		"""
		The secret of matrix programming is this: Whenever you think you need a for-loop to
		manipulate some values, try instead building them together into a matrix that does the job
		for you. As an example of how to do this, try out the following activity:
			
		Define and test an anonymous version of the factorial function that requires no
		recursion or iteration, but instead uses the prod() function.
		""",
		"",
		x -> occursin("->prod(1:",replace(x," "=>""))
	),
	Activity(
		"""
		Study the definition of the local variable `relpos` in lines 103 and 104 of NBodies4.jl.
		These lines calculate the relative positions x[i]-x[j] between all pairs of bodies i and j.
		However, instead of looping over the bodies, this code computes the relative positions more
		efficiently by constructing a matrix. Notice that this construction starts in line 103
		with the input argument `locations`, which is a Vector containing all Vector locations of
		the N bodies.
		
		We start our journey of understanding by defining a simple, toy example of `locations` at
		the Julia prompt - something like this:
		
			`locations = [[1,2],[3,4]]`
		
		Next, at the Julia prompt, carry out step by step each of the codelines 103 to 105. After
		each step, look carefully at your result, and discuss it with your partners:

			`locnPerBody = repeat(locations,1,length(locations))`
			`permdims = permutedims(locnPerBody)`
			`relpos = locnPerBody - permdims`

		When you have finished, work out in your head the result of `repeat([1,2],2,3)`.
		""",
		"",
		x -> x==[1 1 1;2 2 2;1 1 1;2 2 2]
	),
	Activity(
		"""
		Now set a breakpoint and use the VSC Debugger to investigate how simulate() uses `relpos`
		to calculate the gravitational forces acting between the different bodies in the system.
		What is the name of the variable that is used to calculate Newton's inverse-square law that
		falls with increased distance between the sources?
		""",
		"",
		x -> x=="invCube"
	),
	Activity(
		"""
		OK, now we have understood how the code in NBodies4.jl works, notice that we have a
		runtime problem. Because of inaccuracies of the simulator, the orbits of the two bodies
		are not closed ellipses, but instead the bodies spiral outwards. NBodies5.jl solves this
		problem by replacing Euler integration by Runge-Kutta-2 integration in simulate().

		Study now the method runge_kutta_2() to see how the integration is performed by using
		two Euler steps. Run unittest() to see that the orbits are now much cleaner.
		""",
		"",
		x -> true
	),
	Activity(
		"""
		Finally, check out the new use-case method demo() in NBodies5.jl, which tests our simulator
		using three bodies. Notice how it does not take long for the system to throw out the small
		planet and turn into a binary star system.

		Congratulate yourself on completing this lab by playing around with different starting
		conditions for this 3-body simulation. Can you set up a stable 3-body system?
		""",
		"",
		x -> true
	),
]