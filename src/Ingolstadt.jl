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
export gimme, lab, act, reply, help, hint, save, nextlab, nextact

using Pluto								# We want to be able to use Pluto notebooks

#-----------------------------------------------------------------------------------------
# Module fields:

include("Session.jl")			# Include definitions of Session and Activity types.

session = Session()				# Create the single Ingolstadt session

#-----------------------------------------------------------------------------------------
# Module methods:

#-----------------------------------------------------------------------------------------
"""
	letsgo!(learner = "")

Initiate an Ingolstadt session for the given learner.

Establish the name of the learner, then look up whether we possess persistent registry
information on that learner. If not, create a new registry entry for the learner. In either
case, decide which laboratory and current Activity this learner requires, and initialise
the session accordingly.

# Arguments
* `learner`: The name of the individual logging into session to continue learning.

# Notes
* This module is a work in progress 😃 ...

# Examples
```julia
julia> letsgo!("Niall")
Hi Niall! Wait just half a second ...
```
"""
function letsgo( learner::String = "")
	global session					# We're setting up the global session

	# Create path to Ingolstadt labs and learner registry:
	session.lab_path = normpath(joinpath(dirname(@__FILE__),"..","Labs"))
	lnrpath = normpath(joinpath(dirname(@__FILE__),"..","Learners"))

	if isempty(learner)
		# Learner's name hasn't been provided - request it:
		println( "\nWelcome to the pedagogical playground of Ingolstadt!! :)")
		print( "My name's Ingo! What's yours?  ")
		learner = readline()
	end
	println( "\nHi ", learner, "! Just setting things up for you ...\n")

	if !isdefined(Main,:ingo)
		# ingo() is not yet defined - suggest setting it up:
		println( "You may find it convenient to insert the following method definition into the")
		println( "startup.jl file in your ~\\.julia\\config folder:\n")
		println( "    function ingo()")
		println( "        cd(\"$(normpath(joinpath(dirname(@__FILE__))))\")")
		println( "        include(\"Ingolstadt.jl\")")
		println( "    end\n")
		println( "The function call \"ingo()\" will always bring you to this folder and start me up! :)")
		println()
	end

	# Establish lnr_file:
	session.lnr_file = joinpath( lnrpath, learner*".lnr")
	if !(isfile(session.lnr_file))
		# Register info for new learner:
		stream = open(session.lnr_file,"w")
		println(stream, "1")		# Initial laboratory
		println(stream, "1")		# Initial activity
		close(stream)
	end

	# Grab information on learner's current progress:
	stream = open(session.lnr_file)
	laboratory = lpad(readline(stream),3,'0')[1:3]
	session.lab_num = parse(Int,laboratory)
	session.current_act = parse(Int,readline(stream))
	close(stream)

	# Open the requested labfile:
	nextlab(session.lab_num,session.current_act)
end

#-----------------------------------------------------------------------------------------
"""
help()

Display a list of Ingolstadt commands.
"""
function help()
	println( "List of Ingolstadt commands:")
	println( "   help()               : Display this list of options")
	println( "   hint()               : Display a hint for the current activity")
	println( "   gimme()              : Give me the current activity")
	println( "   act()                : Display the current activity number")
	println( "   lab()                : Display the current laboratory number")
	println( "   reply(response=skip) : Submit a response to the current activity")
	println( "   save()               : Save the current status of this session")
	println( "   nextact(act=next)    : Move to the learning activity act")
	println( "   nextlab(lab=next)    : Move to the laboratory lab ",
											"(then restart Julia before continuing!)")
end

#-----------------------------------------------------------------------------------------
"""
hint( act::Activity=session.activity[session.current_act])

Display a hint for the current activity
"""
function hint( act::Activity=session.activities[session.current_act])
	if isempty(act.hint)
		# No hint is given - display general remorse:
		println( "No hint available - you're on your own here, I'm afraid! :-(")
	else
		# Display the available hint:
		println( "Hint:  ", act.hint)
	end
end

#-----------------------------------------------------------------------------------------
"""
	gimme()

Display the current activity to the learner.

If this activity is available, display it; otherwise move to next laboratory.
"""
function gimme()
	if session.current_act ≤ length(session.activities)
		# There are new activities in this lab - go to the next one:
		act()												# Display activity number
		pose(session.activities[session.current_act])		# Display activity text
	else
		# Current activity was the last in the lab - go to next lab:
		nextlab()
	end
end

#-----------------------------------------------------------------------------------------
"""
	lab()

Display the current laboratory number to the learner.
"""
function lab()
	println("Laboratory ",session.lab_num," ...")
end

#-----------------------------------------------------------------------------------------
"""
	act()

Display the current activity number to the learner.
"""
function act()
	println("Activity ",session.current_act," ...")
end

#-----------------------------------------------------------------------------------------
"""
	reply( response)

Learner replies to the current activity with the given response.

If the answer is correct, move on to the next activity; otherwise check with learner.
"""
function reply( response=nothing)
	if response !== nothing && ~evaluate(session.activities[session.current_act],response)
		# Response is present and unsuccessful:
		print("Do you want to try again? ")
		if occursin("yes",lowercase(readline()))
			return
		end
	end

	# Whether response was correct, incorrect or missing, we're moving to the next activity:
	println( "Let's move on ...")
	println()
	nextact()
end

#-----------------------------------------------------------------------------------------
"""
	nextact( activity)

Move to the next activity.

If activity is given, move to that number activity, otherwise move to the next activity in
this lab. If that takes you beyond the end of this lab, move to the beginning of the next lab.
"""
function nextact( act::Int = 0)
	if act ≤ 0
		# No activity given - default to next activity after current one:
		act = session.current_act + 1
	end

	if act ≤ length(session.activities)
		# act is a valied activity - go to it:
		session.current_act = act
		save()
		gimme()
	else
		# We've completed last activity - go to next lab:
		println( "That's the end of lab ", session.lab_num, ". Just preparing the next lab ...")
		nextlab()
	end
end

#-----------------------------------------------------------------------------------------
"""
	nextlab( lab)

Move to the beginning of the next lab.

If lab is given, move to that number lab, otherwise move to the next lab. If that takes
you beyond the end of the available labs, stay where you are and inform the learner.
"""
function nextlab( lab_num::Int = 0, current_act::Int = 1)
	if lab_num ≤ 0
		# No lab given - default to next lab after the current one:
		lab_num = session.lab_num + 1
	end

	# Check validity of lab_file:
	lab_file = labfile(session.lab_path,lab_num)
	if !isfile(lab_file)
		# The new lab_file is not available in the lab directory:
		println("Sorry: Lab number $(lab_num) is unavailable.")
		return
	end

	# Update session information for the new laboratory:
	session.lab_num = lab_num
	session.current_act = current_act
	save()

	# Open lab_file and offer help:
	stream = open(lab_file)
	session.is_pluto = occursin("Pluto.jl notebook",readline(stream))
	close(stream)

	if session.is_pluto
		# Open a Pluto lab:
		@async Pluto.run(notebook=lab_file)
		println( "You're running a Pluto lab. After it has loaded, you can press Ctrl-C in the")
		println( "Julia console if you want to experiment in Julia while the lab is running.")
		println()
	else
		# Open a Julia lab:
		session.activities = include(lab_file)
	end

	# Display welcome message to the new laboratory.
	println( "Great - I've set up the laboratory. If you've just completed working on another")
	println( "laboratory, I recommend that you restart Julia now. This will keep your environment")
	println( "clean and avoid naming conflicts.")
	println( "Enter help() at any time to see the available options. Have fun! :)")
	println()

	# Display the new laboratory number:
	lab()
end

#-----------------------------------------------------------------------------------------
"""
	save()

Save the status of the current session.

Write lab_file and current_act to the usr file.
"""
function save()
	stream = open(session.lnr_file,"w")
	println(stream, session.lab_num)		# Save current laboratory
	println(stream, session.current_act)	# Save current activity
	close(stream)
end

end # End of Module Ingolstadt

#-----------------------------------------------------------------------------------------
# Initialisation code:
using .Ingolstadt

# Comment out the following line when executing/debugging within VSC:
Ingolstadt.letsgo()							# Initialise persistently saved session
