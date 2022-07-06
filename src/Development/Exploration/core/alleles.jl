# =========================================================================================
### alleles.jl: Defines different allele types (for each algorithm)
# =========================================================================================
"""
	BasicGAAlleles

Enum for the possible alleles in BasicGA. The possible values are 0 and 1.
"""
@enum BasicGAAlleles bZero bOne

"""
	ExploratoryGAAlleles

Enum for the possible alleles in ExploratoryGA. The possible values are 0, 1, ?. Where
the "?" gets evaluated in exploratory learning steps.
"""
@enum ExploratoryGAAlleles eZero eOne qMark