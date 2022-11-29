#========================================================================================#
#	Laboratory 12
#
# Mutation: How do population types change?
#
# Author: Niall Palfreyman, 15/09/2022
#========================================================================================#
[
	Activity(
		"""
		We have seen that different types in a population grow and decline in relation to their
		replication rates r[i], but there is an additional factor in evolution: mutation. Many
		mutations occur when the genomic material of a cell is being copied during replication,
		but mutagens can also induce changes in the genetic material of a single cell. We shall
		study here a simple model of mutation that can be applied in both situations.

		Discuss with your partner the difference between 'genomic' and 'genetic' material. Talk
		with your instructor if you cannot find out the difference.
		""",
		"",
		x -> true
	),
	Activity(
		"""
		First, suppose we have two population types 1 and 2 whose fitness is equal: r[1] = r[2] = 1.
		Suppose mutation turns type 2 into type 1 with probability q[1,2], and turns type 1 into
		type 2 with probability q[2,1]. Now, every type must generate either itself or some other
		type, so q[2,2] = 1 - q[1,2] must be the probability that type 2 is generated from type 2,
		and q[1,1] = 1 - q[2,1] is the probability that type 1 is generated from type 1. In this
		case,
			dx[1]/dt = (1 - q[2,1])*x[1] +    q[1,2]*x[2]    - R*x[1] ;
			dx[2]/dt =    q[2,1]*x[1]    + (1 - q[1,2])*x[2] - R*x[2] ;

		Or in other words:
			dx/dt = (Q - R*I)*x , where Q = [q[1,1] q[1,2]; q[2,1] q[2,2]]

		So we can represent mutation by a MUTATION MATRIX Q, which satisfies the conditions
		q[i,j] ∈ [0,1] and sum(q,dims=1) = 1 (i.e., components are probability values, and the sum
		of all elements in each column is 1).

		What is the population's average fitness R = x[1]*r[1] + x[2]*r[2], given x[2] = 1 - x[1]?
		""",
		"Remember that r[1] = r[2] = 1",
		x -> x == 1
	),
	Activity(
		"""
		Substitute these values in the above dynamical equations to show that:
			dx[1]/dt = q[1,2] - x[1]*(q[2,1] + q[1,2])
		""",
		"",
		x -> true
	),
	Activity(
		"""
		Show that this dynamical equation has a fixed point x[1]* = q[1,2] / (q[2,1] + q[1,2]) 
		""",
		"Set dx[1]/dt = 0",
		x -> true
	),
	Activity(
		"""
		What you have discovered here is that in the long term, mutation leads to the stabilisation
		of two populations. Their relative frequencies depend on their respective mutation rates:
		if q[2,1] > q[1,2], the type 2 population ends up larger than type 1; if q[2,1] < q[1,2],
		the type 1 population will end up bigger. In both cases, the crucial point is that type 1
		and type 2 coexist; it is not necessary for one type to drive the other to extinction!

		Often, the mutation rate in one direction is much larger than in the other direction.
		Imagine that in our 2-type model, q[2,1] ≫ q[1,2]: type 1 individuals mutate much more
		frequently to type 2 individuals than in the reverse direction. We can approximate this
		situation by setting q[1,2] = 0. Substitute this value into the dynamical equations for
		dx[1]/dt and dx[2]/dt, and solve these equations to find the exact behaviour of x[1] and
		x[2] over time. What mathematical name to we give to this type of behaviour over time?
		""",
		"",
		x -> occursin("exponential",lowercase(x))
	),
	Activity(
		"""
		We can easily extend this 2-type model of mutation into an N-type model. Again, we define
		the mutation matrix Q ≡ (q[i,j]) as an (NxN) stochastic matrix of probability elements
		satisfying the conditions q[i,j] ∈ [0,1] and sum(q,1) = 1. Again, since each type
		generates some other type, the sum of all elements in each column is 1. We can write the
		mutation dynamics like this:
			dx/dt = (dx[i]/dt) = sum([q[i,j]*x[j] for j in 1:N]) - R*x[i] = (Q - R*I)*x

		Again, in N-type mutation dynamics, R = 1. Why?.
		""",
		"Think about how mutation converts one type into another",
		x -> true
	),
	Activity(
		"""
		Think back to what you already know about matrices and linear algebra. The fixed points of
		mutation dynamics are defined by dx/dt(x*) = 0. Substitute this constraint into the above
		mutation dynamical equation. What does this tell us about the mathematical relationship
		between Q, x* and R?
		""",
		"When is (Q - R*I)*x = 0?",
		x -> occursin("eigen",lowercase(x))
	),
	Activity(
		"""
		In Julia, create a module Mutators containing a dataype Mutator that is mutated according
		to a pure mutation matrix of your choice that mutates three types cyclically into each
		other: 1 → 2 → 3 → 1. Use an appropriate Julia function to calculate the fixed point of
		your chosen mutation matrix, and then verify the result of this calculation by visualising
		the mutation dynamics graphically in a 3-simplex.
		""",
		"I recommend using the function eigen() in the LinearAlgebra library",
		x -> true
	),
	Activity(
		"""
		Finally, we can combine mutation with constant selection to derive the QUASI-SPECIES
		EQUATION. Manfred Eigen and Peter Schuster used the term QUASI-SPECIES to describe what we
		have here called a TYPE: the quasi-species equation describes how types evolve if they
		possess linear fitness values AND can mutate into each other:
			dx/dt    = Q*(x.*r) - (x∙r)*x ; or
			dx[i]/dt = sum([q[i,j]*(x[j]*r[j]) for j in 1:N]) - R(x)*x[i], where
			R(x)     ≡ sum([x[j]*r[j] for j in 1:N])

		Use the quasi-species equation to include constant selection into your Mutators model from
		the previous activity. Experiment to see what effect various fitness values have on the
		behaviour of your cyclically mutating model. How is this behaviour different from simple
		"Survival of the Fittest"?
		""",
		"",
		x -> true
	),
]