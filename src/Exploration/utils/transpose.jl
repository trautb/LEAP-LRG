"""
Adds dispatch for (Base.)transpose() on a Matrix of Enums
"""
function Base.transpose(A::Matrix{T}) where T <: Enum
	return T.(transpose(Int.(A)))
end

# -----------------------------------------------------------------------------------------
"""
Adds dispatch for (Base.)transpose() on a Vector of Enums
"""
function Base.transpose(a::Vector{T}) where T <: Enum
	return T.(transpose(Int.(a)))
end