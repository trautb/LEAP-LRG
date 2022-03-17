#========================================================================================#
"""
	Decoders

A Decoder of n-bit vectors to floating-point numbers.

Author: Niall Palfreyman, 8/3/2022.
"""
module Decoders

# Externally callable methods of Decoders
export Decoder, decode

#-----------------------------------------------------------------------------------------
# Module types:

"""
	Decoder

A Decoder of bit-vectors whose bit-entries encode ndims dimensions with precision nbits bits.
"""
struct Decoder
	lwb											# Lower bound of each domain dimension
	ndims										# Number of dimensions in domain
	nbits										# Number of bits encoding each dimension
	coeffs										# Matrix of coefficients for decoding bit-vectors

	"Construct a new Decoder"
	function Decoder( domain::Vector=[[0 1]], nbits::Int=10)
		# Set up decoding apparatus:
		span = ((x->x[2]-x[1]).(domain))'		# Row vector of domain dimension extents
		qlevels = 0.5.^(1:nbits)				# Column vector of successive halving fractions
		qlevels = qlevels / sum(qlevels)		# Normalise qlevels to cover entire unit interval
		
		# Initialise all fields of the decoding apparatus:
		new(
			(x->x[1]).(domain),					# lwb: Extract the lower bound of each dimension
			length(domain),						# ndims
			nbits,								# nbits
			qlevels*span						# coeffs
		)
	end
end

#-----------------------------------------------------------------------------------------
# Module methods:

"""
	decode( decoder, x)

Decode the bit-vector x into floating-point numbers. x is a data vector of ndims
floating-point values, each of which is encoded by nbits bits. Therefore, x contains
ndims*nbits bits that we must decode into a data vector of ndims floating-point values.
"""
function decode( decoder::Decoder, x::Vector)
	# Reshape this column of x into a data matrix of ndims columns, each of which contains
	# nbits rows. Then decode each column of data by multiplying it by components in the
	# corresponding column of coeffs, summing the column and adding the corresponding lwb:
	data = ones( decoder.nbits, decoder.ndims)		# reshape() x to the right size.
	sum(decoder.coeffs .* data,dims=1)'				# Add the sum of each column to lwb, then
end													# transpose it back into a column vector.

#-----------------------------------------------------------------------------------------
"""
	demo()

Provide a demonstration of using a Decoder to decode two bit-vectors into into the two
vectors [1.67742, 3.51613, -2.74194] and [1.32258, 4.41935,  1.51613].
"""
function demo()
	bitdata = [ [1,0,1,0,1,0,1,0,0,0,0,1,0,1,1], [0,1,0,1,0,1,0,1,1,0,1,0,1,1,0] ]
	decoder = Decoder( [[1 2],[3 5],[-7 5]], 5)		# Three dimensions, each of precision 5 bits

	println(
		"This bit-data contains two data vectors, each encoding 3 dimensions " *
		"with precision 5 bits:"
	)
	display( bitdata)
	println()
	println( "Here is the Decoder:")
	display( decoder)
	println()
	println( "Here are the two decoded vectors containing three floats:")
	display(
		map(bitdata) do x
			decode( decoder, x)
		end
	)
end
		
end		# of Decoders