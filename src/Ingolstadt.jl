module Ingolstadt

export cheers

"""
    cheers(n)

Add 2 to the number of cheers.

A more detailed explanation can go here.

# Arguments
* `n`: The number to which we add 2

# Notes
* Notes can go here

# Examples
```julia
julia> five = plusTwo(3)
5
```
"""
function cheers( n::Int)
	c = n+2
	println( c, " cheers for You!!")
	c
end

end
