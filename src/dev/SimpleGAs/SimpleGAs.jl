#========================================================================================#
"""
	SimpleGA

A simple Genetic Algorithm implementation.

Author: Niall Palfreyman, 8/3/2022.
"""
module SimpleGAs

classdef BP307GABinary < handle
	%----------------------------------------------------------
	% BP307GABinary: Basic binary genetic algorithm
	%----------------------------------------------------------
	methods
		% Construct a new BP307GABinary:
		function gab = BP307GABinary(objective,bitsPerVar,nPop)
			if rem(nPop,2)
				% Warning: nPop must be even!
				nPop = nPop + 1;
			end;
			
			gab.myObjective = objective;
			gab.myNGenes = bitsPerVar*objective.dim;
			gab.myNPop = nPop;
			gab.myPop = floor(2*rand(gab.myNGenes,nPop));
			gab.myMu = 2/(gab.myNGenes*nPop);
			gab.myPX = 1;
			gab.myNonElite = nPop;
			gab.mySigmaScale = 1;
			
			% Initialise mask repository (see mutate)
			gab.myNMuRepos = 5;		% Size of repository
			gab.myMuRepos = ...
				(rand((gab.myNGenes+1)*gab.myNMuRepos,nPop) ...
				< gab.myMu);
			
			% Set up decoding if necessary:
			if bitsPerVar > 1
				gab.myDecoder = ...
					BP306BinaryDecoder(objective.domain,bitsPerVar);
			else
				gab.myDecoder = [];
			end;
		end;	% ... of Constructor
		
		% Set mutation probability:
		function gab = setMu( gab, mu)
			gab.myMu = max(min(mu,1),0);
			% Reinitialise mutation repository (see mutate)
			gab.myMuRepos = ...
				(rand((gab.myNGenes+1)*gab.myNMuRepos,gab.myNPop) < mu);
		end;
		
		% Set crossover probability:
		function gab = setPX( gab, px)
			gab.myPX = max(min(px,1),0);
		end;
		
		% Set number of elite individuals to be retained
		% into next generation. If elite<1, it is a
		% proportion of elite individuals; if elite>=1, it
		% is the number of elites. myNonElite is the
		% number of non-elite individuals.
		function gab = setElite( gab, elite)
			if elite < 1
				elite = ceil( ...
					gab.myNPop * max(min(elite,1),0));
			else
				elite = floor(elite);
			end;
			if rem(elite,2)
				% Recombined population must remain even!
				elite = elite + 1;
			end;
			gab.myNonElite = gab.myNPop - elite;
		end;
		
		% Set sigma scaling:
		function gab = setSigma( gab, sigmaScale)
			gab.mySigmaScale = sigmaScale;
		end;
		
		% Reinitialise BP307GABinary population:
		function gab = init( gab)
			gab.myPop = floor(2*rand(gab.myNGenes,gab.myNPop));
		end;
		
		% Display current status of population:
		function depict( gab)
			[fit,evals] = gab.fitness();
			[~,maxi] = max(fit);
			fprintf( ...
				'Avg value: %f\nBest value: %f\n', ...
				mean(evals), evals(maxi));
		end;
		
		% Perform a single run of nGenerations
		function gab = evolve( gab, nGenerations)
			%-------------------------------------------------------------
			% evolve: A modular version of speedyGA
			%	Author: Niall Palfreyman, December 2011.
			%-------------------------------------------------------------
			if nargin < 2
				nGenerations = 1;
			end;
			
			for n = 1:nGenerations
				fitnesses = gab.fitness();
				
				if gab.myNonElite < gab.myNPop
					% Apply elitism - sort elite individuals to
					% end of population list:
					[fitnesses,idx] = sort(fitnesses);
					gab.myPop = gab.myPop(:,idx);
				end;
				
				if gab.myPX > 0
					% Perform crossover:
					gab = gab.recombine(fitnesses);
				end;
				
				if gab.myMu > 0
					% Perform mutation:
					gab = gab.mutate();
				end;
			end;
			
			end
			
		% Calculate normalised fitness of the population
		function [fit,objeval,indiv] = fitness( gab)
			%-------------------------------------------------------------
			% fitness: Calculate normalised fitness of a population
			%	fit is a column vector of normalised fitnesses of gab
			%	population, minus all sub-sigma-scaled individuals (see
			%	Mitchell p.168). Negative sigma-scaling maximises the
			%	objective; higher magnitudes raise the fitness pressure.
			%	objeval is a colum vector of evaluations of the population.
			%	indiv is a matrix of decoded values of population individuals
			%-------------------------------------------------------------
			if isempty(gab.myDecoder)
				% No decoding required
				indiv = gab.myPop;
			else
				indiv = gab.myDecoder.decode(gab.myPop);
			end;
			
			objeval = gab.myObjective.eval(indiv);
			sigma = std(objeval);
			if sigma ~= 0;
				fitness = 1+(mean(objeval)-objeval) /...
							(gab.mySigmaScale*sigma);
				fitness(fitness<=0) = 0;
			else
				fitness = ones(1,gab.myNPop);
			end;
			
			% Normalise fitness values:
			fit = fitness/sum(fitness);
			
		end
		
		% Recombine the population
		function gab = recombine( gab, fitnesses)
			%-------------------------------------------------------------
			% recombine: Select and recombine members of the gab population
			%	We use Stochastic Universal Sampling (SUS - see Mitchell p. 168)
			%	to reorder prospective parent indices and also use masks to
			%	construct crossovers. Both techniques almost always improve
			%	performance.
			%-------------------------------------------------------------
			% Only recalculate fitnesses if they aren't provided:
			if nargin < 2
				fitnesses = gab.fitness();
			end;
			cumFitness = cumsum( fitnesses);
			
			% Create randomised list of fitness-selected parent indices:
			markers = rem( rand+(1:gab.myNPop)/gab.myNPop, 1);
			[~,parents] = histc(markers,[0 cumFitness]);
			parents = parents(randperm(gab.myNPop));
			
			% 1st half of parents are Mummies; 2nd half are Daddies:
			nMatings = gab.myNonElite/2;
			mummy = gab.myPop(:,parents(1:nMatings));
			daddy = gab.myPop(:,parents(nMatings+1:gab.myNonElite));
			
			% Create crossover masks ...
			xover = false(gab.myNGenes,nMatings);
			xPt = ceil(rand(1,nMatings)*(gab.myNGenes-1));
			for i=1:nMatings
				xover(1:xPt(i),i) = true;
			end;
			% ... then stochastically enforce crossover probability:
			xover(:,rand(1,nMatings)>gab.myPX) = false;
			
			% Perform crossover:
			girls = mummy;
			girls(xover) = daddy(xover);
			boys = daddy;
			boys(xover) = mummy(xover);
			
			gab.myPop(:,1:gab.myNonElite) = [girls boys];
			
		end
			
		% Mutate the population
		function gab = mutate( gab)
			%-------------------------------------------------------------
			% mutate: Mutate the (non-elite) GABinary population
			%	Draw mutation masks from a pregenerated repository of random
			%	bits. This significantly accelerates code by avoiding many
			%	random number generations, with no apparent impact on GA
			%	behaviour.
			%-------------------------------------------------------------
			row = floor(rand*gab.myNGenes*(gab.myNMuRepos-1));
			gab.myPop(:,1:gab.myNonElite) = xor( ...
				gab.myPop(:,1:gab.myNonElite), ...
				gab.myMuRepos((row+1):(row+gab.myNGenes),1:gab.myNonElite) ...
				);
			
		end		
	end;
	
	properties (Access = private)
		myNGenes;		% Number of genes in each individual
		myNPop;			% Number of individuals in population
		myPop;			% Population of individual binary chromosomes
		myMu;				% Mutation rate
		myPX;				% Crossover rate
		myNonElite;		% No. of non-elite recombinables
		myObjective;	% Objective function
		myDecoder;		% Binary decoding for evaluation
		mySigmaScale;	% Sigma-scaling coeff: -ve maximises
		myNMuRepos;		% Size of mask repository
		myMuRepos;		% Mutation repository
	end;
	
	methods (Static)
		% Demo this class for the given test function
		function demo()
			obj = BP301Objective(7);
			gab = BP307GABinary(obj,128,20);
			gab.setSigma(2);
			gab.depict();
			
			nIter = 5000;
			fprintf( '\nAfter %d iterations ...\n', nIter);
			gab.evolve(nIter);
			gab.depict();
		end;
	end;
	
end

end		# of SimpleGAs