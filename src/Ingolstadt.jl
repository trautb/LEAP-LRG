#=============================================================================#
"""
	Ingolstadt

Ingolstadt Evolving Computation Project

This is the central switchboard for the Ingolstadt project,
which will build gradually into a full-scale course in using
Julia to implement evolutionary solutions to understanding
the world.

Author: Niall Palfreyman, 7/12/2021
"""
module Ingolstadt

export letsGo!

"""
	letsGo!(n)

Initiate an Ingolstadt session.

Start playing in laboratory n. If n is zero or absent,
print a welcome message with further instructions.

# Arguments
* `n`: The laboratory we wish to play in.

# Notes
* This module is a work in progress 😃 ...

# Examples
```julia
julia> letsGo!()
Welcome to the wonderful world of Ingolstadt!! 😃
```
"""
function letsGo!( n::Int=0)
	if n ≤ 0
		println( "Welcome to the wonderful wirld of Ingolstadt!! \😃")
	end
end

end; # Ingolstadt
