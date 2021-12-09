#========================================================================================#
"""
	Ingolstadt

Ingolstadt Evolving Computation Project

This is the central switchboard for the Ingolstadt project, which will build
gradually into a full-scale course in using Julia to implement evolutionary
and rheolectic solutions to understanding the world.

Author: Niall Palfreyman, 7/12/2021
"""
module Ingolstadt

# The externally callable methods of Ingolstadt:
export letsgo!, gimme, reply

# We want to be able to use Pluto notebooks:
using Pluto

#-----------------------------------------------------------------------------------------
# Module fields:

# Definition of Laboratory structure - ignore this for now:
include("Laboratory.jl")

session = Session("001",1,[])					# The initial session

#-----------------------------------------------------------------------------------------
# Module methods:

"""
	letsgo!(user = "")

Initiate an Ingolstadt session for the given user.

Establish the name of the user, then look up whether we possess
persistent registry information on that user. If not, create a new
registry entry for the user. In either case, decide which laboratory
and current exercise this user requires, and set up the session
accordingly.

# Arguments
* `user`: The name of the individual logging into session.

# Notes
* This module is a work in progress 😃 ...

# Examples
```julia
julia> letsgo!("Niall")
Welcome, Niall!! 😃 Let's continue ...
```
"""
function letsgo!(; user::String = "", seshin = session)
	# Get path to Ingolstadt labs and user registry:
	labpath = normpath(joinpath(dirname(@__FILE__),"..","Labs"))
	usrpath = normpath(joinpath(dirname(@__FILE__),"..","User"))

	if isempty(user)
		# Welcome user and request name:
		println( "Welcome to the pedagogical playground of Ingolstadt!! 😃")
		print( "Hi - I'm Ingo! What's your name?  ")
		user = readline()
	else
		# Welcome named user:
		println( "Welcome, ", user, "!! Let's get moving, shall we? 😃")
	end
	
	# Open user record, then initialise userrecord:
	usrfile = user * ".usr"
	if !(usrfile in readdir(usrpath))
		# Register info for new user:
		stream = open(joinpath(usrpath,usrfile),"w")
		println(stream, "000")		# Initial laboratory
		println(stream, "1")		# Initial exercise
		close(stream)
	end
	usrfile = joinpath(usrpath,usrfile)
	stream = open(usrfile)
	seshin.laboratory = lpad(readline(stream),3,'0')
	seshin.currentex = parse(Int,readline(stream))
	close(stream)

	# Check whether lab is a Pluto file and open accordingly:
	labfile = joinpath( labpath, "INLab" * seshin.laboratory * ".jl")
	stream = open(labfile)
	ispluto = occursin("Pluto.jl notebook",readline(stream))
	close(stream)

	if ispluto
		# Open a Pluto lab:
		Pluto.run(notebook=labfile)
	else
		# Open a Julia lab:
		seshin.exercises = include(labfile)
	end
end

function gimme()
	set(laboratory[nexercise])
end

function reply( ans)
	answer(laboratory[nexercise],ans)
	nexercise += 1
end

end # Ingolstadt
