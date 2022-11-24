#========================================================================================#
#	Laboratory 11
#
# Selection: How do populations stop growing?
#
# Author: Niall Palfreyman, 10/09/2022
#========================================================================================#
[
	Activity(
		"""
		In this laboratory we really get started with the biological content of this course.
		We know from lab 5 that replication is represented by the Exponential model:
			dx/dt = r*x

		where x is the size of a population and r is the specific growth rate of that population.
		This model generates the exponential growth story, for which we can formulate an exact model:
			x(t) = x0 exp(r*t), with doubling time T2 = ln(2)/r
		
		Suppose a particular bacteria population has a specific growth rate of r = 0.035 /min . Use
		the Julia REPL to calculate the population's doubling time.
		""",
		"You will need to look up the Julia function for ln()",
		x -> true
	),
	Activity(
		"""
		Use Julia as a calculator to calculate the number of minutes in a day. How many cells will
		one bacterium generate over 3 days?
		""",
		"The population doubles in each doubling time over the three days",
		x -> 151 < log(x) < 152
	),
	Activity(
		"""
		This number is enooormous! In fact, it is so enormous that it cannot be true! In the
		biological world, there is no such thing as exponential growth. Instead, as Darwin
		realised, limited resources always cause the population growth rate to drop as the
		population x gets bigger. This is modelled by the logistic equation:
			dx/dt = r*x*(1 - x/K)

		Here, r is the specific replication rate of the population only when x is much smaller
		than the resource limitation (carrying capacity) K. If x → 0, or if x → K, then the growth
		rate dx/dt → 0. In this case, the population has an unstable fixed point at x* = 0, but
		grows from any initial value x0 > 0 towards the stable fixed point at x* = K. (An asterisk
		denotes a fixed-point value.)

		Again using the value r = 0.035 /min from the previous activity, use a value of K = 100 to
		calculate the growth rate dx/dt of the bacteria population when x = 99.
		""",
		"Apply the logistic equation",
		x -> (0.0346 < x < 0.0347)
	),
	Activity(
		"""
		Suppose we have two exponential populations x and y that reproduce at different rates r and
		s. Suppose they have initial conditions x(0)=x0 and y(0)=y0, then:
			dx/dt = r*x and dy/dt = s*y, so that
			x(t) = x0*exp(r*t) and y(t) = y0*exp(s*t)

		Both x and y grow exponentially, and if r > s, x will grow faster than y. Eventually, there
		will be more x's than y's. Let's define ρ(t) ≡ x(t)/y(t). Use the quotient rule to prove
		that ρ(t) also follows an exponential model: dρ/dt = (r - s)*ρ .
		""",
		"On paper, divide the exponential expression for x by the exponential for y, then differentiate",
		x -> true
	),
	Activity(
		"""
		The solution of this equation is ρ(t) = ρ0*exp((r - s)*t), so if r > s, ρ will grow toward
		infinity, and x outcompetes y. In addition, if we also suppose that resources are limited,
		the populations x and y will grow toward a point where the total population (x + y) stays
		constant, so that if x gets infinitely bigger than y, this must mean that y → 0.

		This is selection: where the growth of x drives y to extinction. For selection to happen,
		we need different rates of growth of the populations x and y, plus resource limitation.
		
		To study selection situations, we often use two simple modelling tricks:
		- We think of x and y not as populations, but as FREQUENCIES. That is, we assume that the
			sum of both population types is 1 (x + y = 1), so that x describes the proportion of
			the combined population that are x-individuals, while y describes the proportion that
			are y-individuals.
		- In addition, we think of the growth rates r and s as FITNESS values: r describes how
			fit the type x is, in terms of how effectively it grows by comparison with y.

		We want to make sure that the sum x + y = 1 of the two frequencies stays constant. To
		achieve this, we will reduce the growth rates of x and y by equal amounts R in the
		selection equations:
			dx/dt = (r - R)*x and dy/dt = (s - R)*y .
			
		Prove that this will only work if R is the average fitness of the two population types:
			R ≡ r*x + s*y .
		""",
		"The condition for (x + y) to stay constant is: d(x + y)/dt = 0",
		x -> true
	),
	Activity(
		"""
		One advantage of using these selection model tricks is that y now depends upon x:
			y = 1 - x.
			
		Show that in this case, we can eliminate y from the two selection equations, so that we
		now only need to solve the single equation:
			dx/dt = (r - s)*x*(1 - x)
		""",
		"Substitute the constraint y = 1 - x into the logistic equations for x and y",
		x -> true
	),
	Activity(
		"""
		We recognise this equation: it is the logistic equation with specific growth rate (r - s)
		and carrying capacity 1. We also know how the logistic story evolves over time - it has two
		equilibria at 0 and 1:
			If r > s, x → 1, so y → 0, and type x is selected over type y;
			If s > r, x → 0, so y → 1, and type y is selected over type x.

		Martin Nowak calls this model “Survival of the Fitter”. But models like this can also display
		many other exciting behaviours! :)

		By the way, before we proceed, you should beware of thinking of the frequencies x and y as
		species, because they might simply be different groups in a population of one species. It
		might even be that x's can genetically transform into y's. We shall refer to them here
		simply as "frequencies" or "types".
		""",
		"",
		x -> true
	),
	Activity(
		"""
		We can extend this 2-type model to selection between N different types within a population.
		If we label the individual type frequencies x[i](t) (where i is in 1:N), the structure
		describing all N types is a vector: x ≡ [x1,x2, …, xN]. Now define r[i] ≥ 0 as the fitness
		of type i, then the average fitness of the entire population of N types is:
			R = sum([r[i]*x[i] for i in 1:N]), or simply dot(r,x)

		We can then write the selection dynamics model as:
			d(x[i])/dt = x[i]*(r[i] .- R)

		This is the general LINEAR SELECTION model. The frequency x[i] of type i increases if its
		fitness r[i] is higher than the population average R; otherwise x[i] decreases. However,
		the total population stays constant:
			sum(x) ≡ 1 and sum(dx/dt) ≡ 0

		We will find these relations very useful when we study the growth and decline of types
		within a population. In particular, we shall want to make use of the dot product between two
		vectors. At the Julia prompt, create two vectors a = [1,2,3] and b = [4,5,6], then verify
		that a'*b calculates the dot product of a and b. Then look up and tell me which library we
		need to load in order to make use of the dot product function: dot(a,b).
		""",
		"LinearAlgebra",
		x -> x == "LinearAlgebra"
	),
	Activity(
		"""
		The set of all values x[i] > 0 obeying the property that sum(x) = 1 is called a SIMPLEX.
		The useful thing about simplexes is that we can represent them both graphically and as
		coordinates. Given any two points P1 and P2 in the plane, we can represent any point on the
		straight line between P1 and P2 as a weighted average of P1 and P2. So, for example:
			(1,0)			corresponds to the point P1
			(0,1)			corresponds to the point P2
			(0.25,0.75)		corresponds to a point three-quarters of the way from P1 towards P2

		The coefficients of a weighted average are always frequencies that add up to 1, and we are
		using them here as coefficients that define a linear combination of the two points P1 and
		P2. Any linear combination whose coefficients add up to 1 is called a CONVEX COMBINATION.

		What are the convex coordinates of the midpoint lying halfway between P1 and P2?
		""",
		"",
		x -> collect(x) == [0.5,0.5]
	),
	Activity(
		"""
		So if we have two population types x and y, we can represent any particular values of these
		two types as a convex combination of two points in a graph. Now, you might not at first
		think this is particularly useful, but what if we had three populations? It would be quite
		difficult to visualise these three numbers in a 3-D graph, but is very easy to visualise
		them as convex combinations of the three vertices of a triangle!

		This is exactly what I have done in the graphics function Simplex.plot3(), which takes a 3-d
		state vector and displays it graphically in a 3-simplex based on three populations x, y and
		z. To see this in action, enter the following at the Julia prompt:
			include("src/Development/Altruism/Simplex.jl")
			Simplex.plot3([1,2,3])
			
		Simplex.plot3() automatically normalises your state vector so that the sum of the three
		frequencies is equal to 1, then plots this vector as a dot inside a 3-simplex. Notice how
		each population frequency represents how close the dot is to the corresponding vertex of
		the simplex. Which vertex is closest to the dot?
		""",
		"Which species type has the highest frequency?",
		x -> occursin("z",lowercase(x))
	),
	Activity(
		"""
		Now try plotting the trajectory of a population over time by entering the following:
			Simplex.plot3([[(1+sin(t))/2,(1+cos(t))/3,t] for t in 0:0.1:6])

		Which colour have I used to signify graphically the START of the trajectory?
		""",
		"Locate the value of z in the first state vector of the above list comprehension",
		x -> occursin("green",lowercase(x)) || x == :green
	),
	Activity(
		"""
		Which vector of frequencies corresponds to the centre of the 3-simplex? Test your answer
		graphically.
		""",
		"Which coordinates are equally far away from all three vertices?",
		x -> x[1] == x[2] == x[3]
	),
	Activity(
		"""
		Which point would represent the situation in which type y is absent, and types x and z
		are present in equal quantities?
		""",
		"",
		x -> x == [0.5,0,0.5]
	),
	Activity(
		"""
		In the linear selection model above, imagine that the type k in 1:N has greater fitness
		r[k] than any other type: r[k] > r[i], ∀i≠k. What effect does this have on the value of the
		factor (r[i]-R)? What effect will this have on the growth rate dx[k]/dt of type k whenever
		other types are present? What will be the frequency of the types after a long time? Over
		time, where will any state vector of population frequencies within the simplex move to?
		""",
		"Which vertex will the frequencies move towards?",
		x -> occursin("vertex",lowercase(x)) && occursin("k",lowercase(x))
	),
	Activity(
		"""
		In the following activities, we'll build a slightly more general model of selection:
			dx[i]/dt = r[i]*x[i]^c - R*x[i]; R = sum([r[i]*x[i]^c for i in 1:N])
		
		If c < 1, we call this selection model SUBlinear; if c > 1, it is SUPERlinear. What model
		does this reduce to if we set c = 1?
		""",
		"Look earlier in this chapter",
		x -> occursin( "linear", lowercase(x))
	),
	Activity(
		"""
		In the sublinear selection model, where c < 1, the population growth is slower than
		exponential (subexponential), and if c> 1, the growth is faster than exponential
		(superexponential). An extreme example of subexponential growth is immigration at a
		constant rate. An example of superexponential growth is sexual reproduction, where two
		organisms must cooperate in order to replicate.

		In our more general selection model, let’s take the simple case N = 3. Show that in this
		case, so long as the population lies inside the 3-simplex (so sum(x) = 1), the rate of
		change (sum(dx/dt)) of the entire population is equal to zero. What does this imply for
		the evolving population in relation to the 3-simplex?
		""",
		"What constraint will automatically apply to all population values throughout evolution?",
		x -> occursin("inside",lowercase(x))
	),
	Activity(
		"""
		Take the module Replicators as a template, and extend the module Selectors (in Selectors.jl)
		to include a datatype Selector that uses RK2 to simulate the evolution of a population of
		three types under sub- and superlinear selection. Your client function unittest() should:
			-	use a constructor method to set the value of c and the three specific growth rates;
			-	then call the method simulate!(s,[x0 y0 z0],T) to evolve the population over a time
				T, starting from the initial frequencies [x0 y0 z0];
			-	then plot this evolution graphically within a triangular 3-simplex.
			
		For example:
			fig = Figure()
			ax = Axis(fig[1,1])
			sel = Selector( [0.5,0.4,0.1], 1.3)
			simulate!( sel, [0.3,0.3,0.4], 100)
			plot3!(ax,sel)

		Nowak describes the case c < 1 as Survival of All, and the case c > 1 as Survival of the
		First. Use your Selector class to understand why he uses these names for the two cases.
		""",
		"",
		x -> true
	),
]