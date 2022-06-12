# -----------------------------------------------------------------------------------------
"""
Adds dispatch for (Base.)transpose() on a Matrix of Enums
"""
function Base.transpose(A::Matrix{T}) where T <: Enum
	return T.(transpose(Int.(A)))
end