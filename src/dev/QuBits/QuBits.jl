#========================================================================================#
"""
	QuBits

Module QuBits: My Very Own Quantum Computer

Author: Niall Palfreyman, 03/05/22
"""
module QuBits

# Externally available names:
export Tensor, ⊗, kron, ⊚, kpow, isclose, ishermitian, isunitary
export State, qubit, ampl, phase, prob, maxprob, nbits

# Imports:
import Base:kron

using LinearAlgebra

#========================================================================================#
# Tensor definitions:
#-----------------------------------------------------------------------------------------
"""
	Tensor

Tensor is a synonym for AbstractArray.
"""
Tensor = AbstractArray

#-----------------------------------------------------------------------------------------
"""
	Kronecker product ⊗

Define ⊗ as an infix operator for the Kronecker product of two Tensors
"""
⊗ = kron

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
# Use circled ring as operator for kpow:
⊚ = kpow

#-----------------------------------------------------------------------------------------
"""
	isclose( t::Tensor, u::Tensor, atol::Float64=1e-6)

Check whether all elements of the Tensor t are close to those of the Tensor u.
"""
function isclose( t, u, atol::Float64=1e-6)
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

#========================================================================================#
# State definitions:
#-----------------------------------------------------------------------------------------
"""
	State

A State is a collection of one or more qubits: a wrapper for Vector{Complex}.
"""
struct State <: AbstractVector{Complex}
	amp::Vector{Complex}								# The State amplitudes

	function State(amp::Vector)
		if isclose(amp,0.0)
			error("State vectors must be non-zero")
		end
		new(amp/norm(amp))
	end
end

#-----------------------------------------------------------------------------------------
# Delegated methods:
Base.length(s::State) = length(s.amp)
Base.size(s::State) = size(s.amp)
Base.setindex(s::State,i) = setindex(s.amp,i)
Base.getindex(s::State,i) = getindex(s.amp,i)

#-----------------------------------------------------------------------------------------
# State constructors:
#-----------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------
"""
	basis( s1::State, s2::State)

Construct a pure State.
"""
function pureStt( dim:Int)
	State(kron(s1.amp,s2.amp))
end

"""
	qubit( alpha::Complex, beta::Complex)

Create a single qubit State from the given amplitudes.
"""
function qubit( alpha::Number, beta=nothing)
	if beta===nothing
		beta = sqrt(1.0 - alpha'*alpha)
	end

	State([alpha,beta])
end

function qubit(; alpha=nothing, beta=nothing)
	if alpha === beta === nothing
		# Neither amplitude is given:
		error("alpha, beta or both are required.")
	end

	if alpha === nothing
		# alpha not given:
		alpha = sqrt(1.0 - beta'*beta)
	end

	qubit(alpha,beta)
end

#-----------------------------------------------------------------------------------------
"""
	kron( s1::State, s2::State)

Return Kronecker product of two States.
"""
function kron( s1::State, s2::State)
	State(kron(s1.amp,s2.amp))
end

#-----------------------------------------------------------------------------------------
"""
	ampl( s::State, bits::BitVector)

Return amplitude for qubit indexed by bits.
"""
function ampl( s::State, bits::BitVector)
	s.amp[1+bits2dec(bits)]					# Add 1 to index because bits counts from 0
end

ampl( s::State, bits...) = ampl(s,BitVector(bits))

#-----------------------------------------------------------------------------------------
"""
	phase( s::State, bits::BitVector)

Return phase of the amplitude of the qubit indexed by bits.
"""
function phase( s::State, bits::BitVector)
	angle(ampl(s,bits))
end

phase( s::State, bits...) = phase(s,BitVector(bits))

#-----------------------------------------------------------------------------------------
"""
	prob( s::State, bits::BitVector)

Return probability for qubit indexed by bits.
"""
function prob( s::State, bits::BitVector)
	amp = ampl(s,bits)						# Retrieve own amplitude
	real(amp'*amp)							# Calculate its squared norm
end

prob( s::State, bits...) = prob(s,BitVector(bits))

#-----------------------------------------------------------------------------------------
"""
	normalise( s::State)

Normalise the state s (but throw an error if it's a zero state).
"""
function normalise(s::State)
	nrm = norm(s)
	if isclose(nrm,0.0)
		error("Attempting to normaise zero-probability state.")
	end
	s /= nrm
end

#-----------------------------------------------------------------------------------------
"""
	nbits( stt::State)

Return number of qubits in this state.
"""
function nbits( s::State)
	Int(log2(length(s)))
end

#-----------------------------------------------------------------------------------------
"""
	maxprob( stt::State)

Return tuple (bitindex,prob) of highest probability qubit in this State.
"""
function maxprob( s::State)
	mxbindex, mxprob = BitVector([]), 0.0
	for bindex in bitprod(nbits(s))
		thisprob = prob(s,bindex)
		if thisprob > mxprob
			mxbindex, mxprob = bindex, thisprob
		end
	end

	(mxbindex, mxprob)
end

#-----------------------------------------------------------------------------------------
"""
	Base.show( s::State)

Display the given State.
"""
function Base.show( io::IO, s::State)
	print( io, "State{", nbits(s), "}[")
	for i in 1:length(s)-1
		print( round(s[i],digits=4), ", ")
	end
	print( io, round(s[end],digits=4), "]")
end

#========================================================================================#
# Helper methods:
#-----------------------------------------------------------------------------------------
"""
	bits2dec( bits::BitVector)

Compute decimal representation of a BitVector.
"""
function bits2dec( bits::BitVector)
    s = 0; v = 1
   for i in view(bits,length(bits):-1:1)
        s += v*i
        v <<= 1
    end 
    s
end

#-----------------------------------------------------------------------------------------
"""
	dec2bits( dec::Int, nbits::Int)

Compute a hi2lo nbit binary representation of a decimal value.
"""
function dec2bits( dec::Int, nbits::Int)
    BitVector(reverse( digits(dec, base=2, pad=nbits)))
end

#-----------------------------------------------------------------------------------------
"""
	bitprod( nbits::Int)

Construct in numerical order a list of all binary numbers containing nbits.
"""
function bitprod( nbits::Int)
    [dec2bits(i,nbits) for i in 0:2^nbits-1]
end

#-----------------------------------------------------------------------------------------
function demo()
	p1 = qubit(alpha=rand())
	x1 = qubit(beta=rand())
	psi = p1 ⊗ x1

	println( isclose( psi'*psi, 1.0))
	println( isclose( p1'*p1*x1'*x1, 1.0))
	println( ampl(psi,1,0))
	println( prob(psi,1,0))
end

end		# ... of module QuBits