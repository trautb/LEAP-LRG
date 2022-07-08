#========================================================================================#
"""
	Casinos

Module Casinos: A repository for fast access to arrays random numbers.

Author: Niall Palfreyman, 9/02/22
"""
module Casinos

# Externally callable methods of Casinos
export Casino, draw, shuffle!

using Random

#-----------------------------------------------------------------------------------------
# Module types:

"""
	Casino

A Casino can return arrays of random numbers in the range [0,1), up to a maximum number of rows
(maxrows), and a maximum number of columns (maxcols). It also contains a deck of prepared
random numbers from which it draws the arrays.
"""
struct Casino
	maxrows::Int					# Maximum number of drawable rows
	maxcols::Int					# Maximum number of drawable columns
	randomness::Int					# How randomised will our withdrawals be?
	deck::Matrix					# Repository of random numbers in [0,1)
	bernoulli						# Dictionary of Bernoulli outcomes

	"The one and only Casino constructor"
	function Casino(maxrows::Int,maxcols::Int,randomness::Int=5)
    	new(
			maxrows, maxcols, randomness,
			rand((maxrows+1)*randomness,(maxcols+1)*randomness),
			Dict{Float64,BitMatrix}()
		)
	end
end

#-----------------------------------------------------------------------------------------
# Module methods:

"""
	draw( casino, nrows, ncols)

Draw the required number of rows and columns from the casino deck, first ensuring that the
deck is large enough to support the withdrawal.
"""
function draw( casino::Casino, nrows::Int, ncols::Int)
	if nrows > casino.maxrows || ncols > casino.maxcols
		# Repository is too small - throw exception:
		error( "Requested withdrawal is too large")
	end

	# Access the deck:
	access( casino.deck, nrows, ncols)
end

#-----------------------------------------------------------------------------------------
"""
	draw( casino, nrows, ncols, bernoulli)

Draw (nrows x ncols) Boolean coin-toss values from the casino, using a bernoulli-biased coin.
"""
function draw( casino::Casino, nrows::Int, ncols::Int, bernoulli::Float64)
	if nrows > casino.maxrows || ncols > casino.maxcols
		# Deck is too small - throw exception:
		error( "Requested withdrawal is too large")
	end

	# Ensure bernoulli is a valid probability between 0 and 1:
	bernoulli = max( 0, min( 1, bernoulli))

	# Ensure Bernoulli entry exists in the Dictionary:
	if !haskey( casino.bernoulli, bernoulli)
		casino.bernoulli[bernoulli] = (casino.deck .< bernoulli)
	end

	# Access the bernoulli-biased matrix entry:
	access( casino.bernoulli[bernoulli], nrows, ncols)
end

#-----------------------------------------------------------------------------------------
"""
	shuffle!( casino)

Reassign random values in the deck.
"""
function shuffle!( casino::Casino)
    rand!( casino.deck)
end

#-----------------------------------------------------------------------------------------
"""
    access( matrix, nrows, ncols)

Access the required number of rows and columns from a matrix, on the
assumption that the matrix is big enough.
"""
function access( matrix, nrows::Int, ncols::Int)
	reprows, repcols = size(matrix)
	offset_r = rand( 1 : (reprows-nrows))
	stride_r = (nrows <= 1) ? 1 :
					rand( 1 : (reprows-offset_r) ÷ (nrows-1))
	offset_c = rand( 1 : (repcols-ncols))
	stride_c = (ncols <= 1) ? 1 :
					rand( 1 : (repcols-offset_c) ÷ (ncols-1))

	# Return a randomly chosen table of slices from the matrix:
	matrix[
		(offset_r : stride_r : (offset_r + (nrows-1)*stride_r)),
		(offset_c : stride_c : (offset_c + (ncols-1)*stride_c))
	]
end

#-----------------------------------------------------------------------------------------
"""
	unittest( casino)

Unit-test the Casinos module.
"""
function unittest()
	println("\n============ Unit test Casinos: ===============")
	println("Casino deck of randomness 2 for matrix withdrawals up to size (2x3):")
	casino = Casino(2,3,2)
	display( casino.deck)
	println()

	println("Draw several (2x3) matrices from the casino:")
	display( draw( casino,2,3)); println()
	display( draw( casino,2,3)); println()
	display( draw( casino,2,3)); println()

	println("Finally, reshuffle the casino and redisplay its deck:")
	shuffle!(casino)
	display(casino.deck)
end

end		# ... of module Casinos