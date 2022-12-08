#========================================================================================#
#	Laboratory 14
#
# Altruism: How can frequency-dependent selection promote group cooperation?
#
# Author: Niall Palfreyman, 17/09/2022.
#========================================================================================#
[
	Activity(
		"""
		Now we will start our final, assessed, project for this course. You will investigate how
		frequency-dependent selection can enable the evolution of ALTRUISM: survival of cooperating
		groups. For example, African crows adopt and look after the babies of other crows, with whom
		they are not related. This example makes clear that selection rewards the replication, not
		of individuals, but of entire developmental systems (DS) of genes, organisms and
		environmental conditions that are necessary for replication. To replicate, crows need crow
		genes, bodies, insects and seeds to eat, nests to sleep in, and other crows to help with
		all the work. By adopting young crows to share the work of survival, a gang of crows
		increases the replicative fitness of the gang and its entire DS, and it is this DS, rather
		than individual birds, that stably survives or fails.

		So: how did organisms evolve to start working together to form a stable DS? Earlier, in the
		HD (hawks/doves) game, we saw that an entire population of doves would survive better than
		than an entire population of hawks. Yet we cannot turn a population of hawks into a
		population of doves by simply mutating one hawk baby into a dove, because that one poor
		dove would never survive against all the hawks. Indeed, even just one hawk in a population
		of doves will have such an advantage that it will thrive and quickly drive the doves to
		extinction! This is typical of many EPISTATIC situations in nature, where in order to do
		better, a mutation must accept that it will first do WORSE!

		Really, we would need some way of protecting the dove population from the hawks. Research
		in this direction goes under the names of ALTRUISM, COOPERATION and GROUP SELECTION, and
		often focuses on a particular 2-person game called the Prisoners' Dilemma (PD). PD has the
		interesting epistatic feature that in order to win a better payoff, PD players must first
		be willing to accept getting a WORSE payoff!
		""",
		"",
		x -> true
	),
	Activity(
		"""
		Biology is full of MUTUALISMS - situations in which living systems
		benefit from cooperating with each other. Your cells, nuclei and mitochondria work together
		to benefit the one sperm or egg that will form your child; ants and aphids provide each
		other with protection and honey-dew; the zooids in a Portuguese man-of-war depend so
		completely on each other that they are physiologically inseparable. Yet in each of these
		cases, it would be possible for one participant to benefit by defecting against this
		cooperation: cells can grow into tumours, and ants could let predators eat the aphids. How
		do such mutualisms arise, and why do participants usually not defect against them?

		At each instant, two interacting organisms have two choices: Cooperate or Defect with the
		other organism. If they both try to Defect on each other, they might both reduce their
		payoff and so only benefit minimally from the interaction, each achieving an average payoff
		of perhaps only 1 each. On the other hand, if they both Cooperate, they might both gain the
		benefits of cooperation with a payoff of 4 each. The problem is, though, that if the aphid
		Cooperates and the ant Defects, the Defector gets a free meal of value 5, while the
		Cooperator gains absolutely nothing (0) from the interaction.
		
		This is the Prisoners' Dilemma (PD): Shall I risk cooperating, because that will reap
		benefits in the long-term, or shall I profit by defecting against the other's willingness
		to cooperate? Set up the following PD payoff matrix in Julia, then show it to me:
		           C  D          C  D
		          ------        ------
		 A_pd = C |4  0|  =   C |R  S|
		        D |5  1|      D |T  P|
		""",
		"Define A_pd = ..., then show me your A",
		x -> x == [4 0;5 1]
	),
	Activity(
		"""
		This is not the only possible form of the PD payoff matrix - any form satisfying the
		requirements T > R > P > S and R ≥ (T + P)/2 describes a PD encounter. Here, T is the
		Temptation to defect, which is greater than the Reward for mutual cooperation. R is in turn
		greater than the Punishment for mutual defection, and worst of all is the Sucker's payoff S
		if I cooperate while my partner defects. The idea is that cooperating is not itself
		evolutionarily beneficial; it is MUTUALLY cooperating that is beneficial. If no-one else
		cooperates, then cooperating is bad for me (think of the single dove in a hawk population!).

		Verify that our payoff matrix A satisfies the criteria for a PD payoff matrix.
		""",
		"",
		x -> true
	),
	Activity(
		"""
		Now consider the following rational argument for playing PD: If I cooperate, then you have
		a choice between gaining 4 points by cooperating or 5 points by defecting - so of course
		you defect. On the other hand, if I defect, you have a choice between gaining 0 points by
		cooperating or 1 point by defecting - so of course you defect. Thus, D dominates C: the
		second row of the payoff matrix shows that playing D always does better than playing C.
		If both players choose their move rationally, both will defect, so all they will ever gain
		is 1 point per encounter.

		We can think of this dilemma in terms of a population of two strategy types: C's have a
		frequency of x[1] in the population and D's have a frequency of x[2]. In this case, C's
		will get an average payoff of r[1] = 4x[1], while D's will get an average payoff of
		r[2] = 5x[1] + x[2] = 4x[1] + 1 (since x[2] = 1 - x[1]). But this means defectors ALWAYS
		have a higher fitness than cooperators, and so will drive the cooperators to extinction.

		Our difficulty is that we have so far only considered very limited game strategies in which
		players either always cooperate or always defect, without reacting to each other. Both
		could to better if they both cooperated - but how can they ever evolve such a strategy?
		""",
		"Read on ... :)",
		x -> true
	),
	Activity(
		"""
		Cooperation only becomes beneficial in the ITERATED PD, where the same two players play the
		game m > 1 times. Consider the following two strategies from Martin Nowak:
		    Grim: cooperates in first round, then cooperates if other player doesn't defect; if the
		        other player defects just once, Grim never forgives, but will always defect.
		    AllD: always defects, in all eternity, amen.

		Discuss with your partner why this is the payoff matrix for these strategies:
		               Grim              AllD
		          ------------------------------
		    Grim: |    m*R        S + (m - 1)*P|
		    AllD: |T + (m -1)*P         m*P    |
		""",
		"Imagine each of the scenarios in which two strategies meet, then play for m rounds",
		x -> true
	),
	Activity(
		"""
		Provided mR > T + (m - 1)P, AllD does not dominate Grim. Indeed, Grim is also a strict NASH
		EQUILIBRIUM: Two Grim players can never improve their score by switching to AllD. In
		evolutionary terms, if everyone in a population plays Grim, then a mutation that uses AllD
		can never invade the population, provided m is greater than the critical value (T-P)/(R-P).
		So, if the small amount of cooperation represented by Grim is once present in the
		population, it can remain stably present.

		Explain with a partner why AllD is also a strict Nash equilibrium, provided P > S.
		""",
		"Again, just try out all possible scenarios to see how they work out",
		x -> true
	),
	Activity(
		"""
		Grim is a REACTIVE strategy: It decides what to do as a reaction to whatever happened in
		the previous PD iteration. Its strengths therefore only show themselves in the iterated PD.
		In 1978, Robert Axelrod organised an iterated PD tournament. Fourteen people from all over
		the world submitted various PD strategies, and Axelrod used a computer to play all fourteen
		strategies against each other.
		
		The winner over all other strategies was Tit-For-Tat (TFT), submitted by the game theorist
		Anatol Rapoport. TFT is a forgiving version of Grim: it cooperates on the first round, then
		always plays whatever the other player played on the previous round of the iterated PD.

		Explain why the following matrix correctly describes the average payoff for TFT against
		AllD, where m is the number of rounds over which PD is iterated:
		                TFT            AllD
		          ------------------------------
		    TFT:  |     m*R       S + (m - 1)*P|
		    AllD: |T + (m -1)*P         m*P    |
		""",
		"",
		x -> true
	),
	Activity(
		"""
		Again, TFT is a strict Nash equilibrium - it can resist invasion by AllD, provided
		m > (T - P)/(R - P), but TFT has the advantage over Grim that it is not locked into
		defection: it can start cooperating again if the other player cooperates.

		TFT is another example of a reactive strategy: it decides what to do based on what happened
		on the previous iteration. We can define a reactive strategy S(p,q) in terms of two
		probabilities p (the probability that I will cooperate if you COOPERATED in the previous
		round) and q (the probability that I will cooperate if you DEFECTED in the previous round).

		Explain to your partner why S(0,0) represents AllD, while S(1,0) denotes TFT.
		""",
		"Apply the definition of S(p,q), and compare your actions with the strategies AllD and TFT",
		x -> true
	),
	Activity(
		"""
		Think very carefully about what name might you use to describe a strategy with the
		representation S(1,0.2)? Discuss this name with others.
		""",
		"Its actions are almost the same as TFT - how would you describe the difference?",
		x -> true
	),
	Activity(
		"""
		We can also use a 4-d vector to describe the actions of the two players in any single round
		of PD, by referring to four possible combined actions (my move, your move): CC, CD, DC and
		DD. State CC = [1,0,0,0] means that both Player 1 and Player 2 cooperate; CD = [0,1,0,0]
		means Player 1 cooperates but Player 2 defects; DC = [0,0,1,0] means Player 1 defects and
		Player 2 cooperates; and DD = [0,0,0,1] means both players defect.

		We can combine these two notations by letting Player 1 have the strategy S1(p1,q1) and
		Player 2 the strategy S2(p2,q2). We think of the dynamics of iterated PD as a MARKOV CHAIN:
		a sequence of probabilistic transitions from the state (CC, CD, DC or DD) of one round to
		the state (CC, CD, DC or DD) in the following round. That is, x[t+1] == M*x[t], where M is
		the following transition matrix:
		                 CC                   CD                   DC                   DD
		        ----------------------------------------------------------------------------------
		   CC:  |      p1*p2                q1*p2                p1*q2                q1*q2      |
		   CD:  |p1*(1 - p2)                q1*(1 - p2)          p1*(1 - q2)          q1*(1 - q2)|
		   DC:  |(1 - p1)*p2          (1 - q1)*p2          (1 - p1)*q2          (1 - q1)*q2      |
		   DD:  |(1 - p1)*(1 - p2)    (1 - p2)*(1 - q2)    (1 - p1)*(1 - q2)    (1 - q1)*(1 - q2)|

		Verify that M is a STOCHASTIC matrix - that is, the sum of entries in each column is 1. Why
		should we expect this to be the case?
		""",
		"Think about how a basis vector is transformed by M",
		x -> true
	),
	Activity(
		"""
		When we discussed mutation matrices earlier, we saw that they were stochastic matrices, and
		had an eigenvalue of 1 whose eigenvector x* is the long-term result of applying the
		stochastic matrix repeatedly over time. In fact, this property is quite generally true of
		all stochastic matrices, and so we can say with safety that in the long-term, the matrix M
		will shift the population to a stable distribution x* satisfying the eigenvalue equation:
		    x* = M x*

		By substituting our above definition of M into this eigenvalue equation, Martin Nowak has
		shown that we can always calculate the long-term payoff for any player that uses the
		strategy Si(pi,qi) against strategy Sj(pj,qj) according to the following equations:
		    A[i,j] ≡ R*s[i,j].*s[j,i] + S*s[i,j].*(1-s[j,i]) + T*(1-s[i,j]).*s[j,i] + P*(1-s[i,j])(1-s[j,i])
		    s[i,j] ≡ (r[i]*qj + qi)/(1 - r[i]*r[j])
		    r[i]   ≡ pi - qi
		    |r[i]*r[j]| < 1

		Using these equations, we can calculate the long-term payoff matrix for any two strategies
		for which |(pi - qi)(pj - qj)| ≠ 1. What is the value of s[i,j] if (pi - qi)(pj - qj) = 1?
		""",
		"",
		x -> true
	),
	Activity(
		"""
		So, what should we do if pi - qi = ±1? Explain why the only two strategies satisfying this
		condition are S(1,0) and S(0,1). Find names for these two strategies. What is our name for
		the first, i.e.: S(1,0)?
		""",
		"",
		x -> occursin("tft",lowercase(x)) || occursin("tat",lowercase(x))
	),
	Activity(
		"""
		Your answer to the previous activity means there are two strategies (one of them extremely
		important!) whose long-term payoff we cannot calculate using Nowak's reactive strategy
		formula. Although we can specifically calculate these cases individually, they do not
		actually pose a problem in practice. In your final project, you will generate strategies
		using random numbers p,q in the open interval (0,1). How often will these random numbers
		yield the exact value 0 or 1?
		""",
		"Look up the definition of an OPEN interval",
		x -> occursin("never",lowercase(x))
	),
	Activity(
		"""
		The following link describes cooperation between Geladas (a type of baboon) and Ethiopian
		Wolves, in which wolves benefit from baboons via an increased hunting success rate, and
		baboons benefit because wolves frighten away other predators. A wolf can defect and get a
		free meal by eating a baby gelada, but then it is driven off by other baboons:

		    https://www.newscientist.com/article/dn27675-monkeys-cosy-alliance-with-wolves-looks-like-domestication/?linkId=57684253

		Create an initial template for a Julia module named Domestications. This module will
		simulate the evolution of cooperative domestication in a population of wolves and geladas.
		In your population frequency model, you will not distinguish geladas from wolves - instead
		you will work with a population of N type, each characterised by its own PD strategy. You
		will use our payoff matrix A_pd to see how to get these different types to cooperate with
		each other.
		""",
		"",
		x -> true
	),
	Activity(
		"""
		In your unittest() method, enter this client use-case:
		```
		d = Domestication( nStrategies)        % Create n-strategy population
		for mut in 1:nMutations
		    simulate( d, nGenerations)         % Iterate replicator equation
		    displayStrategies( d)              % Display best strategies
		    mutate( d)                         % Replace worst with random
		end;

		simulate( d, nGenerations)
		displayStrategies( d)
		```
		""",
		"",
		x -> true
	),
	Activity(
		"""
		Initialise your datatype Domestication with the number n of strategies in this population,
		then create a list of n randomly selected reactive strategies S(p,q), where p,q ∈ (0,1).
		The final version of your project might use n = 100, but for early debugging versions, I
		advise you to use n = 5.
		""",
		"",
		x -> true
	),
	Activity(
		"""
		Randomise the distribution vector x of n strategies uniformly. Calculate the (n×n) long-term
		payoff matrix between the strategies using Nowak's formula.
		""",
		"",
		x -> true
	),
	Activity(
		"""
		Substitute this payoff matrix into the replicator equation and run it for nGenerations.
		""",
		"",
		x -> true
	),
	Activity(
		"""
		Replace the worst strategies in the population with new random strategies, ensuring always
		that sum([x[i] for i in 1:N]) = 1
		""",
		"",
		x -> true
	),
	Activity(
		"""
		Recalculate Nowak's long-term payoff matrix for the new strategies, then run the simulation
		for a further nGenerations.
		""",
		"",
		x -> true
	),
	Activity(
		"""
		Repeat these steps nMutations times, then run the simulation for a further nGenerations and
		display the final results.
		""",
		"",
		x -> true
	),
	Activity(
		"""
		Use the results of your simulations to investigate how cooperation can emerge in a
		population. Do cooperative strategies survive well, or do other strategies need to exist
		before cooperative ones can survive? Which strategies survive best?
		""",
		"",
		x -> true
	),
	Activity(
		"""
		OK, now use your Domestications module to investigate an evolutionary problem of your
		own choosing. First choose a research question that you wish to explore - discuss this
		question with your instructor. Then decide how you are going to answer your research
		question using your simulator. Finally, use all of the techniques you have learned in
		this course to develop your unittest() method into a full-scale demonstration of your
		research investigation. Your demonstration will display graphics and text to convince
		users of the importance and correctness of your results. Good luck! :)

		IMPORTANT: In many activities of this course, I have written equations out in terms of
		their matrix components, for example: sum([a[i]*b[i] for i in 1:N]). But of course in
		Julia you can write this expression much more simply as a dot product: a'*b or dot(a,b).
		Please make sure you make full use of Julia's high-level matrix notation in your project!
		""",
		"",
		x -> true
	),
]