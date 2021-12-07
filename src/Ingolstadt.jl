#=============================================================================#
"""
	Ingolstadt

Ingolstadt Evolving Computation Project

This is the central switchboard for the Ingolstadt project, which will build
gradually into a full-scale course in using Julia to implement evolutionary
and rheolectic solutions to understanding the world.

Author: Niall Palfreyman, 7/12/2021
"""
module Ingolstadt

using Pluto

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
	# Get path to Ingolstadt root:
	root = normpath(joinpath(dirname(@__FILE__),".."))

	if n ≤ 0
		# Feel free to personalise this welcome message!
		println( "Welcome to the wonderful world of Ingolstadt!! 😃")
	elseif n == 1
		include( joinpath( root, "Labs", "INLab001.jl"))
	else
		Pluto.run(notebook=joinpath( root, "Labs", "INLab002.jl"))
	end
end

end # Ingolstadt
