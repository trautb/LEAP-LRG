#========================================================================================#
#	Laboratory 511
#
# Welcome to course 511: 
#
# Author: Niall Palfreyman (...), Nick Diercksen (July 2022)
#========================================================================================#
[
	Activity(
		"""
		Welcome to Lab 511: This model demonstrates the use of dynamical stabilisation and
        Particle Swarm Optimisation to solve a difficult optimisation problem.

        In the previous tutorial program, we saw how a collective of agents behaving regularly
        can still get trapped in suboptimal solutions of a difficult optimisation problem.
        In this program, we see how particle-swarm optimisation (PSO) offers a partial solution
        to this problem by endowing the swarming particles with a memory. While wandering around,
        each particle in the swarm remembers the best solution it has yet discovered, and if its
        current solution is worse, it communicates its dissatisfaction to other particles in the
        form of thermal motion.

        This memory and the spreading thermal motion make the behaviour of the entire swarm emergent.

        Let's get started with some new functionality first: ...
		""",
		"",
		x -> true
	),
    Activity(
		"""
        Like in the previous chapter, the patches are represented by a 2D matrix which is created
        by calling one of the two functions `buildDeJong7` or `buildValleys`.
        Only on reset can the patches be changed...
		""",
		"""
        \t""",
		x -> x == 2
	),

    Activity(
		"""
        Originally this chapter was written for agents having a 1d velocity and a orientation. But
        to use native functionality from `Agents.jl` just one 2d velocity vector is used.
        When calling
            `move_agent!(particle, model, DT)`
        a timestep DT needs to provided to move the agent correspoding to its velocity vector.
        (if not provided, the agent will moved in a random direction)

        (Since this code is not exact to the original Netlogo implementation, the behaviour
        of the agents is not exactly the same. Despite many trials and effort to implement it with
        a 2D velocity, this chapter might need a rework to provide the original behaviour)
		""",
		"???",
		x -> true
	),
    Activity(
		"""
        Very similar to previous chapters, additional plots can be added after the abmexploration call.
        Here we lift the `model` attribute of the ABMObservable p, so that the plot represent always the
        the `meanPosition` of the current model of `p`.

            meanPos = lift(m -> m.meanPosition, p.model)
            scatter!(meanPos, color=:red, markersize=20)
        
		""",
		"???",
		x -> true
	),
]