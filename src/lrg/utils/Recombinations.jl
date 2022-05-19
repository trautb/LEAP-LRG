#= ====================================================================================== =#
"""
	Recombinations

A collection of functions for mutating genomes.

Authors: Alina Arneth, Michael Staab, Benedikt Traut, Adrian Wild 2022.
"""
module Recombinations

export Recombination, DummyRecombination

# -----------------------------------------------------------------------------------------
# Module types:

"""
    Recombination

A Recombination encapsulates the ability of GAs to recombine the genome of two individuals when creating
children. 
A Recombination represents a function of (R^x, R^x) -> R^x.
(Vector{Allele}, Vector{Allele}) -> Vector{Allele})
"""
abstract type Recombination end





# -----------------------------------------------------------------------------------------
# Debugging- & testing-stuff
"""
	DummyRecombination

Dummy Recombination, returns genome of first parent.
"""
struct DummyRecombination <: Recombination end
function recombine(recombination::DummyRecombination, genomes::Vector{Vector{Bool}}) 
	return genomes[1]
end

end # of Module Recombinations