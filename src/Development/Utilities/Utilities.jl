#========================================================================================#
"""
	Utilities

A library of useful functions.

Author: Niall Palfreyman, 06/09/2022.
"""
module Utilities

export nestlist

#-----------------------------------------------------------------------------------------
# Module types:
#-----------------------------------------------------------------------------------------

#-----------------------------------------------------------------------------------------
# Module methods:
#-----------------------------------------------------------------------------------------
"""
	nestlist( f, x0, n)

Apply the function f repeatedly to the initial value x0, creating a list of n values generated
in this way. This is useful for simulating the development of initial data over time when repeatedly
acted upon by a discrete rule.
"""
function nestlist( f::Function, x0, n::Integer)
	if n ≤ 0
		# Base case. Return the initial value x0:
		[x0]
	else
		# Recurrence case. Fill a list with n applications of f to the initial value x0:
		list = Vector{typeof(x0)}(undef, n+1)			# List has correct size and type
		list[1] = x0									# Initial value
		for i in 1:n
			# Enter i-th iterated value:
			list[i+1] = f(list[i])
		end
		list											# Return filled list
	end
end

#-----------------------------------------------------------------------------------------
"""
	eratosthenes_bad( N)

Generate a list of prime numbers up to a user specified maximum N. This implementation ports
directly from Java to Julia, and is therefore unreasonably low-level.
"""
function eratosthenes_bad( N)
	if N >= 2 # the only valid case
		# declarations:
		f = Bool[]
		i = 0
		# initialise array to true
		for i in 1:N
			push!(f, true)
		end

		# get rid of known non-primes
		f[1] = false

		# sieve
		j = 0
		for i in 2:round(Int, sqrt(N)+1)
			if f[i] # if i is uncrossed, cross its multiples
				for j in 2*i:i:N
					f[j] = false # multiple is not a prime
				end
			end
		end

		# how many primes are there
		count = 0
		for i in 1:N
			if f[i]
				count += 1
			end
		end

		primes = zeros(Int, count)

		# move the primes into the result
		j = 1
		for i in 1:N
			if f[i] # if prime
				primes[j] = i
				j += 1
			end
		end
		return primes # return the primes
	else # if N < 2
		return Int[] # return null array if bad imput
	end
end

#-----------------------------------------------------------------------------------------
"""
	senehtsotare(N)

Generate a list of prime numbers up to a user specified maximum N. This is George Dateris'
'good' implementation, which incorporates the following changes:

	* Replace initial `if` clause by an early return statement;
	* Crossing out integers is implemented within its own function;
	* Uses Julia's efficient search function for true elements in a boolean array;
	* Uses Julia's 1-based array indexing of `isprime` for efficient crossing-out.
"""
function senehtsotare(N::Int)
	if N < 2; return Int[]; end

	isprime = trues(N)					# Number `n` is prime if `isprime[n] == true`
	isprime[1] = false					# By definition, 1 is not a prime number
	crossout_prime_multiples!(isprime)

	findall(isprime)
end

"""
	crossout_prime_multiples!( isprime::AbstractVector{Bool})

For all primes in `isprime` (elements that are `true`), set all their multiples to `false`.
Assumes `isprime` starts counting from 1.
"""
function crossout_prime_multiples!( isprime::AbstractVector{Bool})
	N = length(isprime)
	for i in 2:round(Int, sqrt(N)+1)
		if isprime[i]
			for j in 2i:i:N
				isprime[j] = false
			end
		end
	end
end

end		# of Utilities