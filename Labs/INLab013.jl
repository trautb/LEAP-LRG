#========================================================================================#
#	Laboratory 13
#
# Eco-evo: What happens when fitness is nonlinear?
#
# Author: Niall Palfreyman, 15/09/2022
#========================================================================================#
[
	Activity(
		"""
		Until now, we have made a very simple, but also an over-simple assumption: We have
		assumed that the fitness r[i] of a type i is a constant number independent of the
		frequencies x[i] of the various types. However, we know that there are many situations
		where this is just not so. For example, the fitness of a rabbit depends very much on the
		frequency of lynxes in its area, and also on the frequency of other rabbits that might be
		easier for the lynxes to catch!
		
		The important point here is that simplistic slogans like “Survival of the Fittest!” often
		rely on the unjustified assumption that you as an organism have a constant, measurable
		"fitness" number that is determined only by the genomic makeup of your type. But fitness is
		simply the specific growth rate of a population type, and we cannot measure that in you,
		but rather only by watching how your population type grows wthin_a_specific_context:

		Genetics plays a role in determining fitness, but we can only ever measure fitness ecologically!

		And of course, ecology depends on all the details of how your type interacts with this
		context, so fitness is not constant, linear or even particularly simple! In practice, an
		organism's fitness depends highly NONLINEARLY on the interactive games it plays with its
		environment …
		""",
		"",
		x -> true
	),
	Activity(
		"""
		First, let's formulate a definition of general, nonlinear selection. Remember that our
		definition of linear selection looked like this:
			dx[i]/dt = x[i]*(r[i] - R); R = sum(x.*r)				(Linear selection)

		The only change we now need to make is to allow the fitness values r[i] to depend
		explicitly upon the frequencies x[i]:
			dx[i]/dt = x[i]*(r[i](x) - R); R = sum(x.*r(x))			(Frequency-dependent selection)

		If we set N = 2 in these equations, we obtain the simple 2-type situation. In this case, we
		immediately see that the dynamics of frequency-dependent selection is far more interesting
		and fun than boring old constant selection:
			dx[1]/dt = x[1]*(r[1](x) - R);		dx[2]/dt = x[2]*(r[2](x) - R);		where
			R = x[1]*r[1](x) + x[2]*r[2](x);	x[1] + x[2] = 1

		Use this last equation to replace x[2] by (1 - x[1]) in our frequency-dependent selection
		equations and show that they then become:
			dx[1]/dt = x[1]*(1-x[1])*(r[1](x) - r[2](x))
		""",
		"",
		x -> true
	),
	Activity(
		"""
		Again replacing x[2] by 1 - x[1], we can replace the rates r[1] and r[2] by functions of x[1]:
			dx[1]/dt = x[1] * (1-x[1]) * (r[1](x[1])-r[2](x[1]))

		This equation defines dynamics on the interval x[1] ∈ [0,1]. Sketch this interval as a
		horizontal axis and draw arrows on it to represent the dynamical flow from all points of
		the interval toward some single stable fixed point inside that interval. Now see if you can
		invent two functions r[1](x[1]) and r[2](x[1]) with the property that they together
		generate the dynamics you have just drawn.
		""",
		"If you have difficulties, rename the variables from x[1], r[1], r[2] to x, α, β",
		x -> true
	),
	Activity(
		"""
		OK, so we can see that frequency-dependent selection might generate fun dynamics, but can
		we find some realistic situation that produces frequency-dependent selection? In the
		1970's, John Maynard Smith invented EVOLUTIONARY GAME THEORY. His idea was that the
		difference between the types in a population might be behavioural: maybe type 1 uses a very
		different strategy from type 2 for its ecological interactions (with its environment and
		with other individuals), and this strategy might be important for its evolutionary survival!

		A good example is the Hawks and Doves (HD) game. In HD, two dogs meet in a forest at a
		place where a tasty sandwich is lying on the ground whose nutritional benefit is b = 4.
		Each dog has a choice between two strategies: H (hawk: attack) and D (dove: surrender). If
		the first dog adopts strategy H, and the second adopts D, the first dog will gain the
		sandwich benefit b, and the second dog gets nothing. On the other hand, if both dogs adopt
		strategy H, they will probably both pay the cost c = 2 of getting injured; on average,
		each dog will get the sandwich half of the time and so gain an average benefit of b/2.
		If both play strategy D, each will again get the sandwich half the time (benefit b/2),
		and will pay no injury cost.

		At the Julia prompt, define the benefit and cost parameters b = 4 and c = 2.
		""",
		"",
		x -> true
	),
	Activity(
		"""
		Now define the HD game as a PAYOFF MATRIX A, and its two strategies as basis vectors h and d:
			A = [(b-c)/2 b; 0 b/2];		h = [1,0];		d = [0,1]
		""",
		"",
		x -> true
	),
	Activity(
		"""
		The payoff matrix A tells us how each individual will benefit on average from using a
		particular strategy to interact with other individuals in the HD game. We can think of the
		component A[i,j] in row i and column j as representing the payoff that strategy i will
		achieve if it interacts with strategy j. Suppose for example I am playing against a hawk,
		then I will achieve payoff 1 if I use the hawk strategy H, and 0 if I use a dove strategy:
			A*h = [1,0]

		Use matrix multiplication at the Julia prompt to find out what payoff I will typically
		achieve if I play a hawk strategy against a dove.
		""",
		"Calculate A*d",
		x -> x==4
	),
	Activity(
		"""
		A hawk meeting a dove will always do well, getting a payoff of 4, whereas the dove gets
		nothing. On the other hand, the hawk strategy is much less useful in a population containing
		only hawks, since the hawk then only receives an average payoff of 1. In fact, it may well
		happen that all the hawks die out from injuries, whereas a population of doves can survive.

		Suppose we have a population that contains 75% hawks and 25% doves. The population frequency
		vector is then x = [0.75,0.25], and the typical payoff for a hawk or dove is given by the
		product A*x. What is this typical payoff for a hawk?
		""",
		"Look at the components of A*d",
		x -> x==1.75
	),
	Activity(
		"""
		What is the typical payoff for a dove in this situation?
		""",
		"",
		x -> x==0.5
	),
	Activity(
		"""
		Now suppose instead that we are living in a more peaceful environment containing 25% hawks
		and 75% doves. Calculate the typical payoff for a hawk and for a dove in this population.
		Is this new environment better or worse for doves than the previous environment, which had
		more hawks in it?
		""",
		"",
		x -> occursin("better",lowercase(x))
	),
	Activity(
		"""
		You can see that the typical payoff for a hawk or a dove is highly frequency-dependent:
		the 'fitness' of a dove is much higher in a dove population than in a hawk-dominated
		population! For an individual using strategy i to play the game with payoff A≡(A[i,j])
		in a population with type frequencies x=(x[j]), the typical payoff is (A*x)[i]. This value
		represents the average benefit that this individual achieves in its daily life from
		interacting with other individuals in the population. And that average payoff is the
		source of this individual's replicative success r[i] ! Because of this, we can insert the
		payoff success, or fitness, into the frequency-dependent selection equation:
			dx[i]/dt = x[i] * (sum([A[i,j]*x[j] for j in 1:N]) - R) ; where
			R = sum([x[i]*a[i,j]*x[j] for i,j in 1:N])

		or in matrix form:
			dx/dt = x.*(A*x - R) ; where R = x'*A*x						(Replicator equation)

		This is Josef Hofbauer and Karl Sigmund's REPLICATOR EQUATION. It describes the dynamics of
		an infinite population of N strategy-types playing a 2-player game.
		
		In the 2-player game of Chicken, two teenagers ski straight towards each other at high
		speed on a narrow piste. Each teenager chooses one of two possible strategies: C (Chicken
		out and leave the piste) or D (ski Directly ahead). The loser is the one who chickens out
		first; in this case, the other skier gets the prestige benefit b = 3. If neither chickens
		out, both are injured with a cost c = 5, and if both chicken out, they share the benefit. At
		the Julia prompt, set up a general payoff matrix A for the game of Chicken. Use the Replicator
		Equation to calculate the population average payoff R for the two population frequency
		vectors cc = [0.75,0.25] and dd = [0.25,0.75]. Which population is LEAST successful?
		""",
		"Set up the variables b, c, A, cc and dd, then calculate R from the Replicator Equation",
		x -> occursin("dd",lowercase(x))
	),
	Activity(
		"""
		N-strategy games: All our examples so far have had only two possible strategies (H/D or
		C/D), but in general there may be N different strategies for playing a game. In this case,
		the payoff matrix A contains (NxN) entries for playing each strategy against each of the
		others. A simple example is the 3-strategy game rock-scissors-paper (RSP), in which three
		strategies cyclically dominate each other: R beats S, S beats P, and P beats R.
		
		There is in fact a species of lizard whose interactions with each other form a cyclical
		3-strategy game in which strategy 1 beats strategy 2, 2 beats 3 and 3 beats 1. The (3x3)
		payoff matrix for the lizards' interaction looks like this:
			Aliz = [4 2 1;3 1 3;5 0 2]

		The dynamics defined by the Replicator Equation remain unchanged if we subtract an
		arbitrary constant from any column of the payoff matrix. Reduce Aliz to a simpler form Arsp
		by subtracting 4 from the first column, 1 from the second column, and 2 from the third
		column. Tell me the new payoff matrix Arsp that you obtain by doing this:
		""",
		"",
		x -> x==[0 1 -1;-1 0 1;1 -1 0]
	),
	Activity(
		"""
		Define three strategy vectors r = [1,0,0], s = [0,1,0] and p = [0,0,1] at the Julia prompt.
		Using your simplified payoff matrix Arsp, find the results of playing these strategies
		against each other by comparing products like r'*A*s and s'*A*r . Do your results support
		your expectations from the RSP game?
		""",
		"",
		x -> occursin("y",lowercase(x))
	),
	Activity(
		"""
		Now set up the Replicator Equation for the RSP game using the simplified matrix A. Build a
		Julia module Interactors comtaining a datatype Interactor that simulates 3-strategy
		population dynamics. To test your Interactor type, implement a use-case in which the
		payoff matrix is that of the RSP game. Simulate this game and display its results in a
		3-simplex.
		""",
		"Your dynamics will show how the frequency of strategies in the population change over time",
		x -> true
	),
	Activity(
		"""
		Now you will use your RSPs module to verify that the lizard dynamics are the same as RSP
		dynamics. Adapt your RSP implementation to use the original lizard payoff matrix Aliz, then
		display your results for the three lizard types in a 3-simplex. Verify that these dynamics
		are identical to those of RSP.
		""",
		"",
		x -> true
	),
]