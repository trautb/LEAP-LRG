#========================================================================================#
"""
	QuBits

Module QuBits: My Very Own Quantum Computer

Author: Niall Palfreyman, 03/05/22
"""
module QuBits

# Externally available names:
export Tensor, ⊗, ⊚, kpow, isclose, ishermitian, isunitary

using LinearAlgebra

#-----------------------------------------------------------------------------------------
# Module definitions:

#-----------------------------------------------------------------------------------------
"""
	Tensor

Define Tensor as a synonym for the Julia Array type.
"""
Tensor = Union{Array,Adjoint}

#-----------------------------------------------------------------------------------------
"""
	Kronecker product ⊗

Define ⊗ as an infix operator for the Kronecker product of two Tensors
"""
⊗ = kron

#-----------------------------------------------------------------------------------------
# Module methods:

#-----------------------------------------------------------------------------------------
"""
	kpow( t::Tensor, n::Int)

Kronecker the Tensor t n times with itself.
"""
function kpow( t::Tensor, n::Int)
	if n==0
		# Base case:
		1.0
	else
		# Build Kronecker product:
		tn = t
		for _ in 1:(n-1)
			tn = tn ⊗ t
		end
		tn
	end
end
# Use circled ring as operator for kpow:
⊚ = kpow

#-----------------------------------------------------------------------------------------
"""
	isclose( t::Tensor, u::Tensor, atol::Float64=1e-6)

Check whether all elements of the Tensor t are close to those of the Tensor u.
"""
function isclose( t::Tensor, u::Tensor, atol::Float64=1e-6)
	all(abs.(t.-u) .< atol)
end

#-----------------------------------------------------------------------------------------
"""
	ishermitian( t::Tensor)

Check whether the Tensor t is hermitian.
"""
function ishermitian( t::Tensor)
	sz = size(t)
	if length(sz) != 2 || sz[1] != sz[2]
		return false
	end

	isclose(t,t')
end

#-----------------------------------------------------------------------------------------
"""
	isunitary( t::Tensor)

Check whether the Tensor t is unitary.
"""
function isunitary( t::Tensor)
	sz = size(t)
	if length(sz) != 2 || sz[1] != sz[2]
		return false
	end

	isclose(t*t',Matrix(I,size(t)))
end

#-----------------------------------------------------------------------------------------
function demo()
	a = [0 1;1 0]
    (ishermitian(a),isunitary(a),isunitary(ones(2,2)))
end

end		# ... of module QuBits