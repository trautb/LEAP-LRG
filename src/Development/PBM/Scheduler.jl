mutable struct MyScheduler
	n::Int # step number
end

function (ms::MyScheduler)(model::ABM)
		ms.n += 1
		ids = collect(allids(model))
		# filter all ids whose agents have `w` less than some amount
		filter!(id -> model[id] < rand(5:1:length(ids)), ids)
		return ids
		
end
