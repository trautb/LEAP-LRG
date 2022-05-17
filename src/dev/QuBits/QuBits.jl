#========================================================================================#
"""
	QuBits

Module QuBits: My Very Own Quantum Computer

Author: Niall Palfreyman, 03/05/22
"""
module QuBits

# Externally available names:
export Tensor, ⊗, kron, ⊚, kpow, isclose, ishermitian, isunitary
export State, qubit, ampl, phase, prob, maxprob, nbits, off, on, pure, bitvec, density
export string

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

Vectuple = Union{AbstractVector,Tuple}					# Useful for indexing States

#-----------------------------------------------------------------------------------------
# Delegated methods:
# Note: States use 0-based indexing - hence the "+1" in get-/setindex.
Base.length(s::State) = length(s.amp)
Base.size(s::State) = size(s.amp)
Base.setindex!(s::State,i::Integer) = setindex!(s.amp,i+1)
Base.getindex(s::State,i::Integer) = getindex(s.amp,i+1)

#-----------------------------------------------------------------------------------------
# State constructors:
#-----------------------------------------------------------------------------------------
"""
	pure( d::Int=1, iamp::Int=0)

Construct a pure State of dimension d in the amplitude iamp.
"""
function pure( d::Int=1, iamp::Int=0)
	if d < 0
		error("Rank must be at least 1")
	end

	amp = zeros(Float64,1<<d)
	amp[iamp+1] = 1.0
	State(amp)
end

#-----------------------------------------------------------------------------------------
"""
	off( d::Int=1)

Construct the pure d-dimensional OFF state |000...0>
"""
function off( d::Int=1)
	pure( d, 0)
end

#-----------------------------------------------------------------------------------------
"""
	on( d::Int=1)

Construct the pure d-dimensional ON state |111...1>
"""
function on( d::Int=1)
	pure( d, 1<<d-1)
end

#-----------------------------------------------------------------------------------------
"""
	bitstring( bits)

Construct a state from the given bits.
"""
function bitvec( bits::Vectuple)
	bv = BitVector(bits)
	pure( length(bv), bits2dec(bv))
end

bitvec( bits...) = bitvec(bits)

#-----------------------------------------------------------------------------------------
"""
	rand( n::Int)

Construct a random combination of n |0> and |1> states.
"""
function rand( n::Int)
	bitvec(Main.rand(Bool,n))
end

#-----------------------------------------------------------------------------------------
"""
	qubit( alpha::Complex, beta::Complex)

Construct a single qubit State from the given amplitudes.
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
# State methods:
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
	getindex( s::State, bits::Vectuple)

Return the amplitude for qubit indexed by bits.
"""
function Base.getindex( s::State, bits::Vectuple)
	s[bits2dec(BitVector(bits))]
end

Base.getindex( s::State, bits...) = s[bits]

#-----------------------------------------------------------------------------------------
"""
	phase( s::State, bits::Vectuple)

Return the phase of the amplitude of the qubit indexed by bits.
"""
function phase( s::State, bits::Vectuple)
	angle(s[bits])
end

phase( s::State, i::Int) = angle(s[i])
phase( s::State, bits...) = phase(s,bits)

#-----------------------------------------------------------------------------------------
"""
	prob( s::State, bits::Vectuple)

Return probability for qubit indexed by bits.
"""
function prob( s::State, bits::Vectuple)
	amp = s[bits]							# Retrieve own amplitude
	real(amp'*amp)							# Calculate its squared norm
end

prob( s::State, bits...) = prob(s,bits)

function prob( s::State, i::Int)
	amp = s[i]								# Retrieve own amplitude
	real(amp'*amp)							# Calculate its squared norm
end

#-----------------------------------------------------------------------------------------
"""
	normalise( s::State)

Normalise the state s (but throw an error if it's a zero state).
"""
function normalise(s::State)
	n = norm(s)
	if isclose(n,0.0)
		error("Attempting to normalise zero-probability state.")
	end
	s /= n
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
	mxindex, mxprob = -1, 0.0
	for i in 0:length(s)-1
		thisprob = prob(s,i)
		if thisprob > mxprob
			mxindex, mxprob = i, thisprob
		end
	end

	(mxindex, mxprob)
end

#-----------------------------------------------------------------------------------------
"""
	density( s::State)

Construct the density matrix of the state s.
"""
function density( s::State)
	s.amp * s.amp'
end

#-----------------------------------------------------------------------------------------
"""
	String( s::State)

Convert the State s to a String.
"""
function Base.string( s::State)
	str = "State{" * string(nbits(s)) * "}["
	last = length(s)-1
	for i in 0:last-1
		str = str * "$(round(s[i],digits=4)), "
	end
	str = str * "$(round(s[last],digits=4))]"
end

Base.String( s::State) = string(s)

#-----------------------------------------------------------------------------------------
"""
	Base.show( io::IO, s::State)

Display the given State.
"""
function Base.show( io::IO, s::State)
	print( io, string(s))
end

#-----------------------------------------------------------------------------------------
"""
	Base.show( io::IO, ::MIME"text/plain", s::State)

Display the given State in verbose form.
"""
function Base.show( io::IO, ::MIME"text/plain", s::State)
	len = length(s)
	nb = nbits(s)
	bv = bitsvec(nb)
	println( io, nb, "-bit, ", len, "-amplitude State:")
	for bits in bv
		ampl = s[bits]
		println( io, " ",
			bits2str(bits), " : ", rpad(round(ampl,digits=4),18),
			": prob=", rpad(round(abs(ampl'*ampl),digits=4),7),
			": phase=", round(angle(ampl),digits=4)
		)
	end
end

#-----------------------------------------------------------------------------------------
# State constants:
#-----------------------------------------------------------------------------------------
"""
	OFF = off(1)

The off qubit.
"""
const OFF = off(1)

#-----------------------------------------------------------------------------------------
"""
	ON = on(1)

The on qubit.
"""
const ON = on(1)

#========================================================================================#
# Helper methods:
#-----------------------------------------------------------------------------------------
"""
	bits2str( bits::Vectuple)

Format bit vector as string
"""
function bits2str( bits::Vectuple)
	"|" * string([+s for s in bits]...) * ">=|" * string(bits2dec(bits)) * ">"
end

bits2str(bits...) = bits2str(bits)

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
	bitsvec( nbits::Int)

Construct a list of all binary numbers containing nbits in numerical order.
"""
function bitsvec( nbits::Int)
    [dec2bits(i,nbits) for i in 0:1<<nbits-1]
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