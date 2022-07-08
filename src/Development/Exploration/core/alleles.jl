# =========================================================================================
### alleles.jl: Defines different allele types (for each algorithm)
# =========================================================================================
"""
	BasicGAAlleles

Enum containing all possible alleles in BasicGA. The possible values are 0 and 1.
"""
@enum BasicGAAlleles bZero bOne

"""
	ExploratoryGAAlleles

Enum containing all possible alleles in ExploratoryGA. The possible values are 0, 1, ?. 
The "?" gets evaluated in exploratory learning steps.
"""
@enum ExploratoryGAAlleles eZero eOne qMark