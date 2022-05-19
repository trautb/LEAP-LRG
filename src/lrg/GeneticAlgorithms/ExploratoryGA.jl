module ExploratoryGAs

export ExploratoryGA

include("../utils/Casinos.jl")
include("../utils/Mutations.jl")
include("../utils/Objectives.jl")

using .Objectives: Objective
using .Casinos: Casino, draw
using .Mutations: Mutation, BitFlip

@enum PlasticityUnit begin
	off = 0
	on = 1
	learnable = 2
end

mutable struct ExploratoryGA
	ngenes::Integer
	population::Vector{Vector{PlasticityUnit}}
	mutation::Mutation
	learnersCasino::Casino
	objective::Objective

	function ExploratoryGA(
		npop::Integer, 
		obj::Objective, 
		nbits::Int=-1, 
		learncapacity::Float64=0.5
	)
		if rem(npop, 2) == 1
			npop = npop + 1
		end
		nattributes = nbits * dim(obj)
		ngenes = floor(clamp(learncapacity, 0, 1) * nattributes)
		nlearnables = npop - ngenes

		new(
			ngenes,
			[[
				rand([on, off], ngenes); 
				fill(learnable, npop - ngenes)
			] for _ in 1:npop],
			BitFlip(2/(nattributes*npop), Casino(ngenes, npop)),
			Casino(nlearnables, npop)
			obj
		)
	end
end

function populationSize(ga::ExploratoryGA)
	return length(ga.population)
end

function learn(ga::ExploratoryGA)
	
	return 
end

end