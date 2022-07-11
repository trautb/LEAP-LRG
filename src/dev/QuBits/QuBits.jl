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
	demo()

Demonstrate how to compose and apply Operators to States.
"""
function demo()
	println( "First, we create the 2-qubit state psi=|01>:")
	psi = bitstate(0,1)
	println( psi); println()

	println( "We flip the first qubit of psi using the PauliX matrix:")
	x1psi = PauliX(psi)
	println( x1psi); println()

	println( "... then negate the on-state of the second qubit using PauliZ:")
	x1z2psi = PauliZ(x1psi,2)
	println( x1z2psi); println()

	println( "Alternatively, we can construct the composed operator (PauliX⊗ I)(PauliZ,2):")
	opx1z2 = (PauliX ⊗ identity())(PauliZ,2)
	display( opx1z2); println()

	println( "... then apply this composition directly to the original state psi=|01>: ")
	println( opx1z2(psi))
end

end		# ... of module QuBits