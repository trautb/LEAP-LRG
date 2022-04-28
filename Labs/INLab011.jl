#========================================================================================#
#	Laboratory 11
#
# Deterministic CHAOS and the course project.
#
# Author: Niall Palfreyman, 23/03/2022
#========================================================================================#
[
	Activity(
		"""
		This is the last laboratory in this course, and it presents the assessed project for
		the course. In this laboratory, you will implement a program to demonstrate chaos in a
		gravitational system containing three bodies of equal mass in two dimensions. You will use
		Julia to analyse the execution of a complex simulation program, and adapt this program to
		use Runge-Kutta integration to (a) simulate 3-body motion and (b) evaluate its chaoticity.
		You will present your methods and results in ONE deliverable: A complete Julia module with
		associated demonstration code that presents a pedagogically pleasing description of the
		n-body problem, its solution using Runge-Kutta-2 integration and an analysis of the
		dynamics of your chosen system. This deliverable will also contain a title, information on
		authors and references, and diagrams.
		""",
		"",
		x -> true
	),
	Activity(
		"""
		In your project, you will investigate DETERMINISTIC CHAOS. Chaos is important for biology
		because it is the source of the spontaneity that we observe in living organisms. To see
		how chaos works, first define a Julia version of the Mathematica function nestlist():

			function nestlist( f::Function, x0, n::Integer)
				(n ≤ 0) ? [x0] : begin
					list = Vector{typeof(x0)}(undef, n+1)
					list[1] = x0
					for i in 1:n
						list[i+1] = f(list[i])
					end
					list
				end
			end
		
		Experiment with nestlist(). For example, what is the result of the following invocation?

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
		
		For specific birthrate r, the wasp population's growth is governed by this logistic equation:

			x[i+1] = Λ(r)(x[i]), where
			Λ(r) is the function: (x -> r x (1-x))

		Implement this model now and experiment with it, then tell me the population two years
		after an initial population of x0 = 0.3, if r = 0.5
		""",
		"Λ(r) = (x -> r .* x .* (1 .- x))",
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
		So you see, chaotic motion meanns that even tinsey-tiny changes in the initial conditions
		of a chaotic system lead to completely different behaviour. So even if we measured the
		current wasp population, we could never be sure that we had done it sufficiently accurately
		to be ABSOLUTELY sure that we are accurately predicting the development of the system!

		So. What has all this to do with your course project? Henri Poincaré was the first to
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
		The demo() function of the module NBodies creates an instance of the type NBody to simulate
		the motion of TWO bodies in ONE spatial dimension. Run it now: do the blue and red bodies
		orbit each other? Investigate this further by increasing the resolution of the simulation
		and of the figure. Try focussing your graphic on the time-snapshots around where the two
		bodies meet, and magnify the image. Do they orbit now? What exactly is happening here?
		This is the origin of chaotic motion!

		Check that the vector x returned by the method NBodies.simulate() has three levels: the
		elements of x span the individual time snapshots of the simulation; each snapshot contains
		a list of the bodies participating in the motion; and each body contains a list of that
		body's coordinates. What do the contents of p represent?
		""",
		"",
		x -> occursin("time",lowercase(x))
	),
	Activity(
		"""
		Software development is always driven by the needs of its CLIENT program - in our case,
		this is the function NBodies.demo(). As you work with demo(), think about what kinds of
		behaviour you as a user demand of the type NBody, and include that functionality in your
		NBodies module design. Your use-cases and newly developed design will form an important
		part of your deliverables for this project.

		Notice that the two bodies (blue and red) do not orbit around each other. Why not? It may
		help your thinking to consider the following question: Is energy conserved in this system?
		""",
		"Think about the bodies' positions and momenta during the simulation",
		x -> occursin("no",lowercase(x))
	),
	Activity(
		"""
		Be aware that I have not given much attention to the naming of variables - you will need to
		comment, reformat and document the module much better than I have! Doing this will help you
		to understand the matrix programming techniques I have used, but they are not easy! You
		will need to thoroughly analyse the code and use Help and internet search to look up
		EVERYTHING you do not yet understand. Here is how to do this ...

		First remember: Matrices work very naturally in Julia, so if a=[1 2;3 5] and b=[2 3;4 5],
		then a*b and a.*b will deliver very different results. First test this idea at the Julia
		prompt, and then tell me the value of a*b-a.*b :
		""",
		"",
		x -> x == [8 7;14 9]
	),
	Activity(
		"""
		The secret of matrix programming is this: Whenever you think you need a for-loop to
		manipulate some values, build them together instead into a matrix that does the job for you.
		For example define and test an anonymous version of the factorial function that requires no
		recursion or iteration, but uses the prod() function.
		""",
		"",
		x -> occursin("->prod(1:",replace(x," "=>""))
	),
	Activity(
		"""
		Analyse the internal helper function relpos(), which calculates the relative positions
		x[i]-x[j] between all pairs of particles. Instead of looping over the particles, I compute
		the relative positions more efficiently in a matrix operation. Find where relpos() is
		called, and notice that its argument is a Vector - for example [1,2].
		
		At the Julia prompt, define relpos() and then call relpos([1,2]). What does the result look
		like? What does relpos() do? At the Julia prompt, analyse the calls

			locations = [1,2]
			locPerBody = repeat(locations,1,length(locations))
			permutedims(locPerBody)

		Discuss your findings with others: How, exactly, does relPos() work?

		Now tell me the result of repeat([1,2],2,3)?
		""",
		"",
		x -> x==[1 1 1;2 2 2;1 1 1;2 2 2]
	),
	Activity(
		"""
		Set a breakpoint and use the Debugger to investigate how simulate() uses relpos() to
		calculate the gravitational forces acting between the different bodies in the system.
		Which variable is used to calculate Newton's inverse-square law that falls with
		increased distance between the sources?
		""",
		"",
		x -> x=="invSq"
	),
	Activity(
		"""
		OK, now we can start on your actual project. First, extend my simulator to 2 bodies in
		2 dimensions and get the two bodies to orbit each other. This is your first major
		success - well done!

		Remember to keep your solution very neat, so that others can understand what you have
		done by reading your code.
		""",
		"Just move on when you have completed this activity",
		x -> true
	),
	Activity(
		"""
		Notice that your two bodies spiral outwards on their orbits because of my inaccurate
		simulator. Improve my integration method to achieve (practically) closed orbits.

		What is the name of the integration technique you are using?
		""",
		"",
		x -> occursin("runge-kutta",lowercase(x))
	),
	Activity(
		"""
		Now introduce a third body into your system (use the same mass for all three bodies). Try
		to create a situation in which the three bodies circle around each other without any of
		them getting thrown out of the system to infinity. Ensure that your system is conserving
		energy; that is, the three bodies taken together should neither gain nor lose energy!
		""",
		"Just move on when you have completed this activity",
		x -> true
	),
	Activity(
		"""
		You will need to find a way of testing your simulation for chaotic motion. There are
		several ways to do this - some are easy, some more difficult; some are approximate, some
		are very accurate. Here is a paper containing an accurate method of detecting chaos:
		
		https://www.nature.com/articles/s42003-019-0715-9.pdf
		
		Alternatively, in chaotic dynamics, small differences in initial conditions grow
		exponentially over time in the short term. The easiest way to test for exponential growth
		is by plotting a logarithm graph over time to see if it is linear. Decide how you want to
		measure chaoticity in your system.
		""",
		"",
		x -> true
	),
	Activity(
		"""
		Your project deliverable is a Julia module that must fulfil the following constraints:
			- the demonstration program MUST execute correctly within its own folder;
			- simulates the motion of three or more gravitational bodies;
			- executes an aesthetically pleasing chaotic trajectory;
			- demonstrates that the motion conserves energy;
			- demonstrates that the motion is indeed chaotic;
			- displays explanatory text so that anyone can understand it WITHOUT studying the code!
			- the code must be neat, well documented and easily readable and comprehensible.
		""",
		"Good luck!!!",
		x -> true
	),
]