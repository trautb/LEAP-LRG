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

A Decoder 
"""
struct Decoder
	lo					# Lowest boundary of each dimension
	ndims				# Number of dimensions in domain
	nbits				# Number of bits encoding each dimension
	decoder				# Vector of bit contributions per dimension

	"Construct a new Decoder"
	function Decoder( domain::Matrix=[0 1], nbits::Int=10)
		# Set up decoding apparatus:
		span = (domain[:,2] - domain[:,1])'		# Column of each domain dimension extent
		qlevels = 0.5.^(1:nbits)				# Row of successive halving fractions
		qlevels = qlevels / sum(qlevels)		# Normalise qlevels to cover entire unit interval
		
		# Initialise decoding apparatus:
		new( domain[:,1], size(domain,1), nbits, qlevels*span)
	end
end

#-----------------------------------------------------------------------------------------
# Module methods:

"""
	decode( decoder, x)

Decode the bit-array x to floating-point numbers y. Each column of x encodes a data vector
of ndims floating-point values, each of which is encoded by nbits bits. Therefore, each
column of x contains ndims*nbits bits that we must decode into a data vector of ndims
floating-point values.
"""
function decode( dec::Decoder, x::Matrix)
	ndata = size(x,2)
	decoded = zeros(dec.ndims,ndata)								# Our decoded values

	# Decode each column of x into the corresponding column of decoded:
	for col in 1:ndata
		# Reshape this column of x into a data matrix of ndims columns, each of which contains
		# nbits rows. Then decode each column of data using the corresponding column of dec:
		data = reshape( x[:,col], dec.nbits, dec.ndims)
		decoded[:,col] = dec.lo + sum(dec.decoder .* data,dims=1)'	# Sum each column of data
	end

	decoded
end

"""
	demo()

Provide a demonstration of using a Decoder to decode a simple two-column bit matrix into
the two vectors [1.67742, 3.51613, -2.74194] and [1.32258, 4.41935,  1.51613].
"""
function demo()
	bitmatrix = [ [1,0,1,0,1,0,1,0,0,0,0,1,0,1,1] [0,1,0,1,0,1,0,1,1,0,1,0,1,1,0] ]
	decoder = Decoder( [1 2; 3 5; -7 5], 5)		# Three dimensions, each of precision 5 bits

	println( "This bit-matrix contains two data vectors, each encoding 3 dimensions ")
	println( "of precision 5 bits:")
	display( bitmatrix)
	println()
	println( "Here is the Decoder:")
	display( decoder)
	println()
	println( "Here is the decoded matrix containing two vectors of three floats:")
	display( decode( decoder, bitmatrix))
end
		
end		# of Decoders