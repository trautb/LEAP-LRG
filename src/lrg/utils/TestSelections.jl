#= ====================================================================================== =#
"""
    Selections

A collection of functions for selecting individuals.

Authors: Alina Arneth, Michael Staab, Benedikt Traut, Adrian Wild 2022.
"""
module Selections

export Selection, DummySelection, performSelection

"""
    Selection

A Selection encapsulates the ability of GAs to select individuals (depending on their fitness)
for matings. 
A Selection represents a function of R^x -> R^x^2. 
(Vector{Fitness} -> Vector{MatingPair})
"""
abstract type Selection end

# -----------------------------------------------------------------------------------------
# Debugging- & testing-stuff
"""
    DummySelection

Dummy Selection, does nothing.
"""
struct DummySelection <: Selection end
function performSelection(selection::DummySelection; kwargs...) end

end # of module Selections