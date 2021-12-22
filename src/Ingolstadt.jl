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

# Externally callable methods of Ingolstadt
export letsgo!, gimme, reply, help, save, nextlab

using Pluto								# We want to be able to use Pluto notebooks

#-----------------------------------------------------------------------------------------
# Module fields:

include("Session.jl")				# Definition of Session structure - ignore this for now

session = Session()					# The single Ingolstadt session

#-----------------------------------------------------------------------------------------
# Module methods:

#-----------------------------------------------------------------------------------------
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
Hi Niall! 😃 Let's get going, shall we? ...
```
"""
function letsgo!( user::String = "", seshin::Session = session)
	# Create path to Ingolstadt labs and user registry:
	seshin.lab_path = normpath(joinpath(dirname(@__FILE__),"..","Labs"))
	usrpath = normpath(joinpath(dirname(@__FILE__),"..","User"))

	# Establish user:
	if isempty(user)
		# Request name:
		println( "\nWelcome to the pedagogical playground of Ingolstadt!! 😃")
		print( "My name's Ingo! What's yours?  ")
		user = readline()
	end
	println( "\nHi ", user, "! 😃 Just wait half a sec ... \n")
	
	# Establish usr_file:
	seshin.usr_file = joinpath( usrpath, user*".usr")
	if !(isfile(seshin.usr_file))
		# Register info for new user:
		stream = open(seshin.usr_file,"w")
		println(stream, "1")		# Initial laboratory
		println(stream, "1")		# Initial exercise
		close(stream)
	end

	# Grab information on user's current progress:
	stream = open(seshin.usr_file)
	laboratory = lpad(readline(stream),3,'0')[1:3]
	seshin.lab_num = parse(Int,laboratory)
	seshin.current_ex = parse(Int,readline(stream))
	close(stream)

	# Establish labfile:
	lab_file = labfile( seshin.lab_path, seshin.lab_num)
	stream = open(lab_file)
	seshin.is_pluto = occursin("Pluto.jl notebook",readline(stream))
	close(stream)

	# Open lab_file and offer help:
	if seshin.is_pluto
		# Open a Pluto lab:
		@async Pluto.run(notebook=lab_file)
		println( "You're running a Pluto lab. After it has loaded, you can press Ctrl-C")
		println( "if you want to experiment in the Julia console while it is running.")
		println( "Remember to call nextlab() and restart Julia when you've completed the lab.")
		println()
	else
		# Open a Julia lab:
		seshin.exercises = include(lab_file)
	end
	println( "OK, I've set up the lab session for you.")
	println( "Enter help() in the Julia console at any time to see your options.")
	println( "Have fun! 😃")
end

"""
help()

Display a list of Ingolstadt commands.
"""
function help()
	println( "List of Ingolstadt commands:")
	println( "   letsgo!() :  Start a new session")
	println( "   help() :     Display this list of options")
	println( "   gimme() :    Display the current exercise")
	println( "   reply(ans) : Submit an answer \"ans\" to the current exercise")
	println( "   save() :     Save the current status of this session")
	println( "   nextlab() :  Move to the next lab (then restart Julia before continuing!)")
end

#-----------------------------------------------------------------------------------------
"""
	gimme()

Give me the next exercise in this laboratory.

If the next exercise is available, display it; otherwise ???
"""
function gimme()
	if session.current_ex ≤ length(session.exercises)
		pose(session.exercises[session.current_ex])
	else
		nextlab()
	end
end

#-----------------------------------------------------------------------------------------
"""
	reply( ans)

Reply to the current exercise with the given answer.

If the answer is correct, move on to the next exercise; otherwise check with user.
"""
function reply( ans)
	if ~answer(session.exercises[session.current_ex],ans)
		print("Try again? ")
		if occursin("yes",lowercase(readline()))
			return
		end
	end
	println( "OK, let's move to the next exercise!\n")
	nextex()
end

#-----------------------------------------------------------------------------------------
"""
	nextex( ex)

Move to the next exercise.

If ex is given, move to that number exercise, otherwise move to the next exercise in this
lab. If that takes you beyond the end of this lab, move to the beginning of the next lab.
"""
function nextex( ex::Int = 0)
	if ex ≤ 0
		ex = session.current_ex + 1
	end

	if ex > length(session.exercises)
		nextlab()
	else
		session.current_ex = ex
		save()
	end
	nothing
end

#-----------------------------------------------------------------------------------------
"""
	nextlab( lab)

Move to the beginning of the next lab.

If lab is given, move to that number lab, otherwise move to the next lab. If that takes
you beyond the end of the available labs, stay where you are and inform the user.
"""
function nextlab( lab::Int = 0)
	if lab ≤ 0
		lab = session.lab_num + 1
	end

	if lab > length(readdir(session.lab_path))
		println("Sorry: Lab number $(lab) is invalid.")
	else
		session.lab_num = lab
		session.current_ex = 1
		save()
	end
	println( "Great - that's the end of this lab - I've saved your current status.")
	println( "I recommend restarting Julia to move on to the next lab. 'Bye for now! 😃")
end

#-----------------------------------------------------------------------------------------
"""
	save()

Save the status of the current session.

Write lab_file and current_ex to the usr file.
"""
function save()
	stream = open(session.usr_file,"w")
	println(stream, session.lab_num)		# Initial laboratory
	println(stream, session.current_ex)		# Initial exercise
	close(stream)
end

end # Ingolstadt

#-----------------------------------------------------------------------------------------
# Welcome code:
using .Ingolstadt
println("\nHi! Just enter \"letsgo!()\" to start experimenting ...\n")
