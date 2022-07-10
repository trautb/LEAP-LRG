#========================================================================================
	QBDefinitions

This file contains global definitions for the module QuBits: A package for experimenting
with quantum computation.

Author: Niall Palfreyman, 25/05/22
========================================================================================#
# Exports:
export Tensor, ⊗, kron, ↑, kpow, isclose

# Imports:
using LinearAlgebra

#========================================================================================#
# Tensor definitions:
#-----------------------------------------------------------------------------------------
"""
	Tensor

Tensor is our term for AbstractArray.
"""
Tensor = AbstractArray

#-----------------------------------------------------------------------------------------
"""
	Kronecker product ⊗

Define ⊗ as an infix operator for the Kronecker product of two Tensors
"""
⊗ = Base.kron

#-----------------------------------------------------------------------------------------
# Tensor methods:

#-----------------------------------------------------------------------------------------
"""
	kpow( t::Tensor, n::Int)

Kronecker the Tensor t n times with itself.
"""
function kpow( t::Tensor, n::Int)
	if n==0
		# Base case:
		return 1.0
	end
	
	# Build Kronecker product:
	tn = t
	for _ in 1:(n-1)
		tn = tn ⊗ t
	end
	tn
end
# Define ↑ (\uparrow) as infix operator for kpow:
↑ = kpow

#-----------------------------------------------------------------------------------------
"""
	isclose( t::Union{Tensor,Number}, u::Union{Tensor,Number}, atol::Float64=1e-6)

Check whether all elements of the Tensor t are close to those of the Tensor u.
"""
function isclose( t::Union{Tensor,Number}, u::Union{Tensor,Number}, atol::Float64=1e-6)
	all(abs.(t.-u) .< atol)
end

#-----------------------------------------------------------------------------------------
"""
	demodefs()

Demonstrate the Tensor type by test-driving the isclose() and kpow() methods.
"""
function demodefs()
	a = [0.9999999 1e-7;0.0000001im 1-1e-7im]
	println("Is this matrix close to the 2x2 identity matrix?")
	println( a)
	println( isclose(a,[1 0;0 1]) ? "Yes, and " : "No, but ", "it's Kronecker square is:")
	display( round.(a ↑ 2))
end