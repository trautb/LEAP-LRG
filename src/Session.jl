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
	usr_file :: String					# User registration file
	lab_path :: String					# Path of current labfile
	lab_num :: Int						# Number of current lab
	is_pluto :: Bool					# Is this a Pluto session?
	current_ex :: Int					# Number of current exercise
	exercises :: Vector{Exercise}		# Set of exercises in this session
end
Session() = Session( "", "", 1, false, 1, Vector{Exercise}())

function pose( ex::Exercise)
	println( ex.text)
end

function answer( ex::Exercise, ans)
	if ex.success(ans)
		congratulate()
		true
	else
		commiserate( ex.solution)
		false
	end
end

function congratulate()
	println( "Well done - great work! 🎈😃")
	println()
end

function commiserate( ans)
	print( "Not quite right, I'm afraid. Would you like to see the correct answer: ")
	if occursin( "yes", lowercase(readline()))
		println( "The answer is:")
		println( ans)
	end
	println()
end

function labfile( path, labnum)
	joinpath( path, "INLab" * lpad("$labnum",3,'0')[1:3] * ".jl")
end