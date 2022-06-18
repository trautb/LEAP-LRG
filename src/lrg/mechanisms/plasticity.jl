"""
	plasticity

Function that performs a random translation from ? to 0 or 1 in a given genpool of 
ExploratoryGAAlleles. 
"""
function plasticity(genpool::Matrix{ExploratoryGAAlleles}, casino)
	undefAlleles = genpool .== qMark
	nIndividuals, nGenes = size(genpool)

	alleleDefinitions = draw(casino, nIndividuals, nGenes, 0.5)

	phenotypes = BitMatrix(undef, nIndividuals, nGenes)
	phenotypes[undefAlleles] = alleleDefinitions[undefAlleles]
	phenotypes[.!(undefAlleles)] = Int.(genpool[.!(undefAlleles)])

	return phenotypes
end