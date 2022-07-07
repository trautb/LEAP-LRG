# ================================================================================================
### plasticity.jl: 
#	Defines functions which implement the concept of phenotypic plasticity within this simulation
# ================================================================================================

"""
	plasticity(genpool::Matrix{ExploratoryGAAlleles}, casino)

Perform a random translation from `qMark` to `eZero` or `eOne` in a given `genpool` of 
`ExploratoryGAAlleles`. 

Every `qMark` has an equal probability of 50% to change into an `eZero` or an `eOne`.

**Arguments:**
- **genpool:** Matrix containing the genome of every individual.
- **casino:** The Casino instance to use. 

**Return:**
- The phenotype-matrix resulting from the above translation (plasticity) as a new array.
"""
function plasticity(genpool::Matrix{ExploratoryGAAlleles}, casino)
	# Find all qMarks in the genpool:
	undefAlleles = genpool .== qMark

	# Get population size and number of genes per individual:
	nIndividuals, nGenes = size(genpool)
	
	# Get a genpool-sized matrix of bits with an approximately equal number of ones and zeros:
	eOneRate = 0.5
	alleleDefinitions = draw(casino, nIndividuals, nGenes, eOneRate)

	# Define the phenotype-matrix of the population:
	phenotypes = BitMatrix(undef, nIndividuals, nGenes)
	
	# Fill the phenotype-matrix with bit-values where qMarks were located in the original genpool:
	phenotypes[undefAlleles] = alleleDefinitions[undefAlleles]

	# Copy all other alleles into the phenotypes-matrix without changes:
	phenotypes[.!(undefAlleles)] = Int.(genpool[.!(undefAlleles)])

	# Return the penotype-matrix:
	return phenotypes
end