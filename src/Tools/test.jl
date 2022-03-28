function nestlist( f::Function, x0, n::Integer)
	if n ≤ 0
		[x0]
	else
		list = Vector{typeof(x0)}(undef, n+1)
		list[1] = x0

		for i in 2:n+1
			list[i] = f(list[i-1])
		end
		list
	end
end

Λ(r) = (x -> r .* x .* (1 .- x))
