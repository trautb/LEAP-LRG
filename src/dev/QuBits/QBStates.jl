#========================================================================================
	QBStates

This file contains the definition of the type State for the module QuBits: A package for
experimenting with quantum computation.

Author: Niall Palfreyman, 25/05/22
========================================================================================#
include( "./QBDefinitions.jl")

# Exports:
export State, qubit, ampl, phase, prob, maxprob, nbits, off, on, pure, bitstate, density, ON, OFF

#========================================================================================#
# State definitions:
#-----------------------------------------------------------------------------------------
"""
	State

A State is a collection of one or more qubits entangled together in a Kronecker product.
"""
struct State <: Tensor{Complex,1}
	amp::Vector												# The State's amplitudes
	ket::Bool												# Ket or bra?
end

Vectuple = Union{AbstractVector,Tuple}						# Useful for indexing States

#-----------------------------------------------------------------------------------------
# Delegated State methods:
Base.length(s::State) = length(s.amp)
Base.size(s::State) = size(s.amp)
Base.getindex(s::State,i::Integer) = getindex(s.amp,i)

#-----------------------------------------------------------------------------------------
# State constructors:
#-----------------------------------------------------------------------------------------
"""
	State( amp::Union{Vector,Adjoint,Matrix}, ket::Bool=true)

Construct a State from the given amplitudes
"""
function State( amp::Union{Vector,Adjoint,Matrix})
	len = length(amp)
	siz = size(amp)
	if !(len in siz)
		# Amplitude structure is multi-dimensional:
		error( "States must have dimensionality 1")
	end

	l2len = log2(len)
	if !(isclose(l2len,round(l2len)))
		# length(amp) is not a power of 2:
		error( "Number of State amplitudes must be a power of 2")
	end

	nrm = norm(amp)
	if isclose(nrm,0.0)
		# Amplitudes are way too small:
		error( "States must be non-zero")
	end

	# Convert to normalised complex Vector in either ket or bra mode
	State( ComplexF64.(vec(collect(amp)))/nrm, !(siz[1]==1))
end

#-----------------------------------------------------------------------------------------
"""
	pure( d::Int=1, i::Int=1)

Construct an n-qubit State pure in the i-th amplitude.
"""
function pure( d::Int=1, i::Int=1)
	if d < 0
		error("Rank must be at least 1")
	end

	amp = zeros(Float64,1<<d)
	amp[i] = 1.0
	State(amp)
end

#-----------------------------------------------------------------------------------------
"""
	off( d::Int=1)

Construct the pure d-dimensional OFF state |000...0>
"""
function off( d::Int=1)
	pure( d, 1)
end

#-----------------------------------------------------------------------------------------
"""
	on( d::Int=1)

Construct the pure d-dimensional ON state |111...1>
"""
function on( d::Int=1)
	pure( d, 1<<d)
end

#-----------------------------------------------------------------------------------------
"""
	bitstate( bits)

Construct a state from the given bits.
"""
function bitstate( bits::Vectuple)
	bv = BitVector(bits)
	pure( length(bv), bits2dec(bv)+1)
end

bitstate( bits...) = bitstate(bits)

#-----------------------------------------------------------------------------------------
"""
	rand( n::Int)

Construct a random combination of n |0> and |1> states.
"""
function rand( n::Int)
	bitstate(Main.rand(Bool,n))
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
	getindex( s::State, bits::Vectuple)

Return the amplitude for qubit indexed by bits. Note: since binary values start from 0, we must
add 1 to the decimal conversion of bits.
"""
function Base.getindex( s::State, bits::Vectuple)
	s[bits2dec(BitVector(bits))+1]
end

"""
	getindex( s::State, bits...)

Return the amplitude specified by the given bit values.
"""
Base.getindex( s::State, bits...) = s[bits]

#-----------------------------------------------------------------------------------------
"""
	Base.*( s1::State, s2::State)

Inner product of two States yields either a scalar (bra * ket) or a density matrix (ket * bra).
"""
function Base.:*( s1::State, s2::State)
	if s1.ket == s2.ket
		error( "Cannot multiply ket with ket or bra with bra")
	end

	s1.ket ? (s1.amp * permutedims(s2.amp)) : (permutedims(s1.amp) * s2.amp)[1]
end

#-----------------------------------------------------------------------------------------
"""
	Base.kron( s1::State, s2::State)

Kronecker product of two States is itself a State.
"""
Base.kron( s1::State, s2::State) = State(kron(s1.amp,s2.amp))

#-----------------------------------------------------------------------------------------
"""
	adj( s::State)

Return the adjoint of the state s.
"""
function adj( s::State)
	State(conj(s.amp),!s.ket)
end

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
	real(conj(amp)*amp)						# Calculate its squared norm
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
function normalise!(s::State)
	n = norm(s)
	if isclose(n,0.0)
		error("Attempted to normalise zero-State.")
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
	for i in 1:length(s)
		thisprob = prob(s,i)
		if thisprob > mxprob
			mxindex, mxprob = i, thisprob
		end
	end

	(mxindex, mxprob)
end

#-----------------------------------------------------------------------------------------
"""
	string( s::State)

Convert the State s to a String.
"""
function Base.string( s::State)
	str = (s.ket ? "ket" : "bra") * "-State{" * string(nbits(s)) * "}["
	for i in 1:length(s)-1
		str = str * "$(round(s[i],digits=4)), "
	end
	str = str * "$(round(s[end],digits=4))]"
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
	println( io, nb, "-bit, ", len, "-amplitude ", (s.ket ? "ket" : "bra"), "-State:")
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
"""
	demostates()

Demonstrate how to use a variety of State constructors and the display() method.
"""
function demostates()
	stt1 = bitstate(1,0,1)
	stt2 = ON ⊗ OFF ⊗ ON

	println("Are these two states approximately equal?")
	println( "stt1 ≡ bitstate(1,0,1) = ", stt1)
	println( "stt2 ≡ ON ⊗  OFF ⊗  ON = ", stt2)
	println( isclose(stt1,stt2) ? "Yes:" : "No:")
	display(stt1)
end