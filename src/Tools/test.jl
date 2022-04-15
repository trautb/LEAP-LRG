function moritz(data)
	zeilennr = 0

	for zeile in data
		zeilennr += 1

		if occursin("author",lowercase(zeile))
			println(zeile)
			return zeilennr
		end
	end
end