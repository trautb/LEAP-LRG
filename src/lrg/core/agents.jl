# =========================================================================================
### Define different agent types
# =========================================================================================

# Include different allele types
include("alleles.jl")

"""
	BasicGAAgent

The basic agent in the simulation
"""
@agent BasicGAAgent{BasicGAAlleles} GridAgent{2} begin
	genome::Vector{BasicGAAlleles}
	mepiCache::Number
end

"""
	ExploratoryGAAgent

The exploratory agent in the simulation
"""
@agent ExploratoryGAAgent{ExploratoryGAAlleles} GridAgent{2} begin
	genome::Vector{ExploratoryGAAlleles}
	mepiCache::Number
end