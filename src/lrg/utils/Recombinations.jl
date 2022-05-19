#========================================================================================#
"""
	Recombinations

A collection of functions for mutating genomes.

Authors: Benedikt Traut, 12/5/2022.
"""
module Recombinations

export Recombination

include("../../dev/Casinos/Casinos.jl")

using .Casinos

#-----------------------------------------------------------------------------------------
# Module types:

"""
    Recombination

A Recombination encapsulates the ability of GAs to recombine the genome of two individuals when creating
children. Recombination is a function of ({0,1}^x, {0,1}^x) -> {0,1}^x
"""
abstract type Recombination end

"""
	DummyRecombination

Dummy Recombination, does nothing.
"""
struct DummyRecombination <: Recombination end
function mutate(recombination::DummyRecombination, ::Vector{Vector{Bool}}) return genome end