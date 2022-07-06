# =========================================================================================
### transpose.jl: Adds additional dispatches for function transpose() on arrays of enums
# =========================================================================================

"""
	Base.transpose(A::Matrix{T}) where T <: Enum

This function implements the transposition of a matrix `A` of enums and adds the corresponding
dispatch to module Base.
"""
function Base.transpose(A::Matrix{T}) where T <: Enum
	return T.(transpose(Int.(A)))
end

# -----------------------------------------------------------------------------------------
"""
	Base.transpose(a::Vector{T}) where T <: Enum

This function implements the transposition of a vector `a` of enums and adds the corresponding
dispatch to module Base.
"""
function Base.transpose(a::Vector{T}) where T <: Enum
	return T.(transpose(Int.(a)))
end