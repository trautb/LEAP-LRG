#========================================================================================#
"""
	Objectives

A collection of displayable objective functions from De Jong and Watson.

Author: Niall Palfreyman, 10/3/2022.
"""
module Objectives

export Objective, dim, domain, sample, evaluate, depict

using GLMakie

#-----------------------------------------------------------------------------------------
# Module types:

"""
	Objective

An Objective encapsulates an objective function for GAs. An Objective instance is a
function f: C^n -> R together with a (by default infinite) domain and dimensionality.
"""
struct Objective
	functn::Function			# The objective function
	domain::Vector{Vector}		# Domain specification
end

"Construct a new Objective from the test suite with default dimension and donain."
function Objective( fun::Int = 1)
	if ~(fun in 1:length(testSuite))
		fun = 1
	end
	Objective(testSuite[fun]...)
end
		
"Construct a new Objective from the test suite with newly provided donain."
function Objective( fun::Int, dom, dim::Int=1)
	if ~(fun in 1:length(testSuite))
		fun = 1
	end
	Objective(testSuite[fun][1],dom,dim)
end

"""
	Objective(fun,dom,dim)

Create an Objective function with the given domain. If the domain is a vector of two
Numbers, it is a range that should be replicated over several dimensions; otherwise,
if it is a vector of such ranges, it is a complete domain and the dimensionality should
be ignored.
"""
function Objective( fun::Function, dom::Vector, dim::Int)
	if dom[1] isa Vector
		# This is a ready-made domain - ignore the given dimension:
		if any(length.(dom) .!= 2) || any(first.(a).>=last.(a))
			# The domain structure is invalid - abort:
			error( "Domain specification is invalid")
		end
		Objective( fun, dom)
	else
		# This a 1-dimensional range that should be replicated over dim dimensions:
		if length(dom) != 2 || dom[1]>=dom[2] || dim < 1
			# The domain structure is invalid - abort:
			error( "Single domain/dimension specification is invalid")
		end
		Objective( fun, [dom for _ in 1:dim])
	end
end

#-----------------------------------------------------------------------------------------
# Module methods:

#-----------------------------------------------------------------------------------------
"Return dimension of Objective function domain."
function dim( obj::Objective)
	length(obj.domain)
end

#-----------------------------------------------------------------------------------------
"Return domain of Objective function."
function domain( obj::Objective)
	obj.domain
end

#-----------------------------------------------------------------------------------------
"Return a sample vector of n random points in function domain."
function sample( obj::Objective, n::Int=1)
	if any( abs.(collect(Iterators.flatten(obj.domain))).==Inf)
		error("Cannot sample an infinite domain")
	end

	dim = length(obj.domain)
	lo = (x->x[1]).(obj.domain)
	dif = (x->x[2]).(obj.domain) - lo

	[lo + dif.*rand(dim) for _ in 1:n]
end

#-----------------------------------------------------------------------------------------
"Evaluate Objective function for the given collection of arguments."
function evaluate( obj::Objective, args)
	obj.functn.(args)
end

#-----------------------------------------------------------------------------------------
"""
	depict( obj, dims, centre, radius)

Depict an objective function in the specified dimensions over the Manhattan
neighbourhood with the given centre and radius.
"""
function depict( obj::Objective, dims=nothing, centre=nothing, radius=nothing)
	if dims === nothing
		# Depict up to the first two dimensions:
		dims = 1:min(2,length(obj.domain))
	end
	
	if isempty(dims)
		# If dims==[], plot a slice through all dimensions of Objective
		# (Mainly for plotting mepi()):
		ndims = length(obj.domain)
		args = [
			[first.(obj.domain)];
			[[last.(obj.domain[1:d]);first.(obj.domain[d+1:ndims])] for d in 1:ndims-1];
			[last.(obj.domain)]
		]
		return lines( 0:ndims, evaluate( obj, args))
	end
	
	# dims is from this point on correctly defined.
	if centre === nothing
		if any((rng->any(abs.(rng).==Inf)).(obj.domain))
			error( "Cannot display an infinite domain")
			return
		end
		centre = sum.(obj.domain)/2
		radius = (last.(obj.domain)-first.(obj.domain))/2
	else
		if radius === nothing
			radius = ones(length(centre))
		end
	end
	
	# All parameters are now present and correct:
	nGrad = 50			# Number of gradations in depiction
	lwb = max(first.(obj.domain[dims]),(centre[dims]-radius[dims]))
	upb = min( last.(obj.domain[dims]),(centre[dims]+radius[dims]))

	ndims = length(dims)
	if ndims == 1
		# Use plot for single dimension:
		xs = range( lwb[1], upb[1], length = nGrad)
		args = [copy(centre) for _ in 1:nGrad]
		for n in 1:nGrad
			args[n][dims] .= xs[n]
		end
		lines!(xs,evaluate( obj, args))
	elseif ndims == 2
		# Construct arguments for a contour plot:
		xs = range( lwb[1], upb[1], length=nGrad)
		ys = range( lwb[2], upb[2], length=nGrad)
		args = [copy(centre) for _ in 1:nGrad, _ in 1:nGrad]
		for i in 1:nGrad, j in 1:nGrad
			args[i,j][dims[1]] = xs[i]
			args[i,j][dims[2]] = ys[j]
		end
		zs = evaluate(obj,args)
		contourf!(  xs, ys, zs)
	else
		error( "Cannot depict more than 2 dimensions")
	end
end		

#-----------------------------------------------------------------------------------------
"""
	mepi( x)

Watson's maximally epistatic objective function.
"""
function mepi( x)
	dim = length(x)

	if dim == 1
		1
	else
		# Form product of the first and second halves of x separately:
		halflen = div(dim,2)
		dim*(1 - prod(x) - prod(1 .- x)) + mepi(x[1:halflen]) + mepi(x[halflen+1:end])
	end
end

#-----------------------------------------------------------------------------------------
"""
	demo1()

A very simple demonstration of the Objective type.
"""
function demo1()
	fig = Figure(resolution=(300, 300))
	Axis( fig[1,1], xlabel="x", ylabel="y", title="Suite function 7")
	depict( Objective(7))
	fig
end

#-----------------------------------------------------------------------------------------
"""
	demo2()

Demo the Objective type.
"""
function demo2()
	fig = Figure(resolution=(600, 300))

	f(x) =
		3*(1-x[1])^2 * exp(-(x[1]^2) - (x[2]+1)^2) -
		10*(x[1]/5 - x[1]^3 - x[2]^5) * exp(-x[1]^2-x[2]^2) -
		1/3*exp(-(x[1]+1)^2 - x[2]^2)
	obj1 = Objective(f,[-3,3],2)
	Axis( fig[1,1], xlabel="x", ylabel="y", title="Valleys")
	depict( obj1)

	Axis( fig[1,2], xlabel="x", ylabel="y", title="Suite function 7")
	depict( Objective(7))

	fig
end

#-----------------------------------------------------------------------------------------
# Module data:

"""
	testSuite

A vector of standard test functions together with appropriate domains. Functions 1-17 are
roughly drawn from De Jong. Function 18 is Watson's (2004) maximally epistatic function.
"""
testSuite = [
	# 1. Minimum: f(0) = 1:
	(x -> abs(x[1]) + cos(x[1]), [-20,20], 1),
	# 2. Minimum: f(0) = 0:
	(x -> abs(x[1]) + sin(x[1]), [-20,20], 1),
	# 3. Minimum: f(0,0) = 1:
	(x -> sum(x.^2), [-5,5], 2),
	# 4. Minimum: f(1,1) = 0:
	(x -> sum(100*(x[2:end]-x[1:end-1].^2)^2 + (1-x[1:end-1])^2), [-1,1], 2),
	# 5. Minimum: f(0^dim) = 1:
	(x -> sum(abs(x) - 10*cos(sqrt(abs(10*x))),1), [-10,10], 2),
	# 6. Minimum: f(9.6204) = -100.22:
	(x -> (x^2+x)*cos(x), [-10,10], 1),
	# 7. Minimum: f(0.9039,0.8668) = -18.5547:
	(x -> x[1]*sin(4*x[1]) + 1.1*x[2]*sin(2*x[2]), [0,10], 2),
	# 8. Minimum: f(0.9039,0.8668) = -18.5547:
	(x -> x[2]*sin(4*x[1]) + 1.1*x[1]*sin(2*x[2]), [0,10], 2),
	# 9. Minimum: varies:
	(x -> (1:length(x))'*(x.^4) + randn(), [-2,2], 2),
	# 10. Minimum: f(0,0) = 0:
	(x -> 10*length(x) + sum(x.^2-10*cos.(2*pi*x)), [-4,4], 2),
	# 11. Minimum: f(0,0) = 0:
	(x -> 1 + sum(x.^2/4000) - prod(cos.(x)), [-10,10], 2),
	# 12. Minimum: f(1.897,1.006) = -0.5231:
	(x -> 0.5 + (sin(sqrt(sum(x.^2))).^2 - 0.5) ./ (1 + 0.1*sum(x.^2)), [-5,5], 2),
	# 13. Minimum: f(0,0) = 0:
	(x -> sum(abs(x),1) + sum(x.^2).^0.25 .* sin(30*(((x[1]+0.5)^2+x[2]^2).^0.1)), [-10,10], 2),
	# 14. Minimum: f(1,16606) = -0.3356:
	(x -> besselj(0,sum(x.^2)) + 0.1*sum(abs(1-x)), [-5,5], 2),
	# 15. Minimum: f(-14.58,-20) = -23.806:
	(	x -> x[1]*sin(sqrt(abs(x[1]-(x[2]+9)))) - (x[2]+9).*sin(sqrt(abs(x[2]+0.5*x[1]+9))),
		[-20,20], 2
	),
	# 16. Watson's maximally epistatic function:
	(mepi, [0,1], 128),
]
			
end		# of Objectives