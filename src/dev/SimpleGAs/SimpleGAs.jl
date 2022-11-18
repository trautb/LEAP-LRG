#========================================================================================#
"""
	SimpleGAs

A simple Genetic Algorithm implementation.

Author: Niall Palfreyman, 13/3/2022.
"""
module SimpleGAs

export SimpleGA, mu!, px!, elite!, temperature!, init!, depict, evolve!

include("./Objectives.jl")
include("./Decoders.jl")
include("../Casinos/Casinos.jl")

using .Objectives, .Decoders, .Casinos
using Statistics: std, mean
using Random: shuffle!

#-----------------------------------------------------------------------------------------
# Module types:

"""
	SimpleGA

A very basic GA with the capability of optimising binary-encoded functions. This implementation
uses mutation, single-point crossover, elitism and sigma-scaling.
"""
mutable struct SimpleGA
	ngenes				# Number of genes in each individual
	npop				# Number of individuals in population
	population			# Population of individual binary chromosomes
	mu					# Mutation rate
	px					# Crossover rate
	temperature			# Sigma-scaling coeff: -ve values maximise objective function
	nNonelitist			# Number of non-elite recombinable individuals
	objective			# Objective function
	decoder				# Binary decoding for evaluation
	casino				# Mutation repository (Casino)

	"The one and only SimpleGA constructor"
	function SimpleGA( obj, npop, nbits::Int=-1)
		if rem(npop,2)==1
			# Warning: npop must be even for our crossover algorithm!
			npop = npop + 1
		end
		ngenes = nbits * dim(obj)
		decoder = nbits > 0 ? Decoder(obj.domain,nbits) : nothing
		
		new(
			ngenes,									# ngenes
			npop,									# npop
			[rand(Bool,ngenes) for _ in 1:npop],	# population
			2/(ngenes*npop),						# mu: About 2 per generation
			1,										# px
			1,										# temperature
			npop,									# nNonelitist: No elitism
			obj,									# objective
			decoder,								# decoder
			Casino(ngenes,npop)						# casino
		)
	end
end

#-----------------------------------------------------------------------------------------
# Module methods:

"""
	mu!(sga,mu)

Set the mutation probability.
"""
function mu!( sga, mu)
	sga.mu = max(min(mu,1),0)
end

#-----------------------------------------------------------------------------------------
"""
	px!(sga,px)

Set the crossover probability.
"""
function px!( sga, px)
	sga.px = max(min(px,1),0)
end

#-----------------------------------------------------------------------------------------
"""
	elite!(sga,elite)

Set number of elite individuals that are to be retained into next generation. If elite<1,
it describes a proportion of elite individuals; if elite>=1, it is the number of elites.
nNonelitist is the number of non-elite individuals - implemented this way for performance
reasons.
"""
function elite!( sga, elite)
	if elite < 1
		elite = ceil( Int, sga.npop * max(min(elite,1),0))
	else
		elite = floor( Int, elite)
	end
	if rem(elite,2) == 1
		# Recombined population must remain even!
		elite = elite + 1
	end
	sga.nNonelitist = sga.npop - elite
end

#-----------------------------------------------------------------------------------------
"""
	temperature!(sga,sigma)

Set the temperature of the algorithm. High temperature means the GA considers many poor
solutions, while low temperature means the GA only accepts high-quality solutions.
"""
function temperature!( sga, theta)
	sga.temperature = theta
end;

#-----------------------------------------------------------------------------------------
"""
	init!(sga)

Reinitialise SimpleGA population.
"""
function init!( sga)
	sga.population = [rand(0:1,ngenes) for _ in npop]
end

#-----------------------------------------------------------------------------------------
"""
	depict(sga)

Display current status of population.
"""
function depict( sga)
	fit,evals,individuals = fitness(sga)
	_,maxi = findmax(fit)
	println( "Avg value:       ", mean(evals))
	println( "Best value:      ", evals[maxi])
	println( "Best individual: ", individuals[maxi])
end

#-----------------------------------------------------------------------------------------
"""
	evolve!(sga)

Evolve the population through ngen generations.
"""
function evolve!( sga, ngen::Int=1)
	for _ in 1:ngen
		fitnesses,_ = fitness(sga)
		
		if sga.nNonelitist < sga.npop
			# Apply elitism - sort elite individuals to
			# end of population list:
			sp = sortperm(fitnesses)
			fitnesses = fitnesses[sp]
			sga.population = sga.population[sp]
		end
		
		if sga.px > 0
			# Perform crossover:
			recombine!(sga,fitnesses)
		end
		
		if sga.mu > 0
			# Perform mutation:
			mutate!(sga)
		end
	end
	
end
	
#-----------------------------------------------------------------------------------------
"""
	fitness(sga)

Calculate normalised fitness of the population. fit is a column vector of normalised
fitnesses of sga population, minus all sub-sigma-scaled individuals (see Mitchell p.168).
Negative sigma-scaling maximises the objective function; higher magnitudes raise the
fitness pressure. objeval is a colum vector of evaluations of the population. indiv is a
matrix of decoded values of population individuals.
"""
function fitness( sga)
	if sga.decoder === nothing
		# No decoding required
		individuals = sga.population
	else
		individuals = map(sga.population) do x
			decode(sga.decoder,x)
		end
	end

	# Calculate the current objective evaluations of the population:
	evaluations = evaluate(sga.objective,individuals)
	# Normalise the evaluations into frequencies:
	sigma = std(evaluations)					# Standard deviation
	if sigma == 0
		# Singular case: all evaluations were equal to the mean:
		fitness = ones(sga.npop)
	else
		# Exorcise all evaluations worse than 1/temperature standard
		# deviations above mean value:
		fitness = 1 .+ (mean(evaluations) .- evaluations) ./ (sga.temperature*sigma)
		fitness[fitness .<= 0] .= 0
	end
	
	(fitness,evaluations,individuals)					# Return value
end

#-----------------------------------------------------------------------------------------
"""
	recombine!(sga)

	Select and recombine members of the sga population. We use Stochastic Universal Sampling
	(SUS - see Mitchell p. 168) to select the prospective parent indices. SUS is really cool
	and clever, and almost always improves performance.
	"""
function recombine!( sga::SimpleGA, fitnesses=nothing)
	# Only recalculate fitnesses if they aren't provided:
	if fitnesses === nothing
		fitnesses,_ = fitness(sga)
	end
	
	# Set up a roulette wheel of fitness-biased slots:
	roulette = cumsum( fitnesses)/sum(fitnesses)
	# Set up npop (rigidly) uniformly distributed ball throws (SUS):
	throws = rem.( rand() .+ (1:sga.npop)./sga.npop, 1)

	# Throw ball onto roulette wheel to create randomised list of
	# fitness-selected parent indices:
	parents = zeros(Integer,sga.npop)
	for parent in 1:sga.npop
		for slot in 1:sga.npop
			if throws[parent] <= roulette[slot]
				parents[parent] = slot
				break
			end
		end
	end
	shuffle!(parents)				# Shuffle the order of parents

	# 1st half of parents are Mummies; 2nd half are Daddies:
	nMatings = sga.nNonelitist ÷ 2
	mummy = sga.population[parents[1:nMatings]]
	daddy = sga.population[parents[nMatings+1:sga.nNonelitist]]
	
	# Create next generation:
	progeny = similar(sga.population)
	# Transfer elite parents (at end of population) directly into new progeny:
	progeny[sga.nNonelitist+1:end] = sga.population[sga.nNonelitist+1:end]
	# Now recombine all parents to create all nonelite progeny:
	for m in 1:nMatings
		xpt = rand(1:length(mummy[m])-1)			# Crossover point

		sally = deepcopy.(mummy[m])					# mummy-based progeny
		billy = deepcopy.(daddy[m])					# daddy-based progeny
	
		sally[xpt+1:end] = daddy[m][xpt+1:end]		# Sally also takes after daddy
		billy[xpt+1:end] = mummy[m][xpt+1:end]		# Billy also takes after mummy

		progeny[m] = sally
		progeny[m+nMatings] = billy
	end

	# ... and finally replace the old fogeys:
	sga.population = progeny
	sga
end
	
#-----------------------------------------------------------------------------------------
"""
	mutate!(sga)

Mutate the (non-elite) SimpleGA population Draw mutation masks from a pregenerated casino.
This significantly accelerates code by avoiding many random number generations, with no
apparent impact on GA behaviour.
"""
function mutate!( sga)
	if sga.mu > 0
		# Only expend effort on mutating if it is really wanted:

		# Find loci to mutate (but ignore the elitists):
		loci = draw( sga.casino, sga.ngenes, sga.nNonelitist, sga.mu)
		
		# Now mutate everyone except the elitists:
		for i ∈ 1:sga.nNonelitist
			# Negate the mutated genes:
			sga.population[i][loci[:,i]] = .!(sga.population[i][loci[:,i]])
		end
	end

	sga
end	

#-----------------------------------------------------------------------------------------
"""
	demo()

Demo the SimpleGA type.
"""
function demo()
	obj = Objective(7)
	sga = SimpleGA(obj,128,20)
	temperature!(sga,2)
	elite!(sga,2)
	depict(sga)
	
	nIter = 5000
	println( "\nAfter $nIter iterations ...")
	evolve!(sga,nIter)
	depict(sga)
end

end		# of SimpleGAs