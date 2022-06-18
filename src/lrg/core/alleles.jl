# =========================================================================================
### Define different allele types
# =========================================================================================
"""
	BasicGAAlleles

Enum for alleles in BasicGA. Possible values are 0 and 1
"""
@enum BasicGAAlleles bZero bOne

"""
	ExploratoryGAAlleles

Enum for Alleles in Exploratory GA, Possible values are 0, 1, ?
"""
@enum ExploratoryGAAlleles eZero eOne qMark