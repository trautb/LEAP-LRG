function nestlist( f::Function, x0, n::Integer)
	(n ≤ 0) ? [x0] : begin
		list = Vector{typeof(x0)}(undef, n+1)
		list[1] = x0
		for i in 1:n
			list[i+1] = f(list[i])
		end
		list
	end
end