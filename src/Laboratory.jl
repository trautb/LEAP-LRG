#========================================================================================#
#	Ingolstadt
#
# This include file defines the structure of exercises, laboratories and sessions.
#
# Author: Niall Palfreyman, 7/12/2021
#========================================================================================#
struct Exercise
	text :: String
	solution :: String
	success :: Function
end

mutable struct Session
	laboratory :: String				# Laboratory identifier
	currentex :: Int					# Pointer to current exercise
	exercises :: Vector{Exercise}		# Set of exercises in laboratory
end

function set( ex::Exercise)
	println( ex.text)
	println()
end

function answer( ex::Exercise, ans)
	if ex.success(ans)
		congratulate()
	else
		commiserate( ex.solution)
	end
end

function congratulate()
	println( "Well done - great work! 🎈😃")
	println()
end

function commiserate( ans)
	println( "Not quite right, I'm afraid. The correct answer is:")
	println( ans)
	println()
end