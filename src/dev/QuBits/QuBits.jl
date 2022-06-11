#========================================================================================#
"""
	QuBits

Module QuBits: A package for experimenting with quantum computation.

Author: Niall Palfreyman, 03/05/22
"""
module QuBits

include( "./QBOperators.jl")

#-----------------------------------------------------------------------------------------
"""
	demoqb()

Demonstrate how to compose and apply Operators to States.
"""
function demoqb()
	stt3 = bitstate(1,0)					# 2-bit state |2>
	opx1 = paulix()							# 1-bit Pauli-x
	opy1 = pauliy()							# 1-bit Pauli-y
	opp = opx1(opy1,2)						# 3d Pauli-x composed with op21 at bit 2 (???Here be dragons!)
	oxs = opx1(stt3,2)						# opx applied to stt at bit 2
	oxys = opy1(oxs)						# opy1 applied to oxs at bit 1
	opps = opp(stt3)						# Apply composition opp to stt

	println( "Let's start with this 101 state:")
	println( stt)
	println( "We transform it with the Pauli-x matrix at the second qubit:")
	println( oxs)
	println( "... and then transform again with the Pauli-y matrix at the first qubit:")
	println( oxys)
	println( "OR ... we apply the composition opx(opy⊗I↑2,2) directly to 101: ")
	println( opps)
end

end		# ... of module QuBits