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
export gimme, reply, help, hint, save, nextlab, nextact

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
Hi Niall! 😃 Let's get going, shall we? ...
```
"""
function letsgo( learner::String = "")
	global session					# We're setting up the global session

	# Create path to Ingolstadt labs and learner registry:
	session.lab_path = normpath(joinpath(dirname(@__FILE__),"..","Labs"))
	lnrpath = normpath(joinpath(dirname(@__FILE__),"..","Learners"))

	# Establish learner:
	if isempty(learner)
		# Name hasn't been provided - request it:
		println( "\nWelcome to the pedagogical playground of Ingolstadt!! 😃")
		print( "My name's Ingo! What's yours?  ")
		learner = readline()
	end
	println( "\nHi ", learner, "! Wait just half a second ... \n")
	
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

	# Establish labfile:
	lab_file = labfile( session.lab_path, session.lab_num)
	stream = open(lab_file)
	session.is_pluto = occursin("Pluto.jl notebook",readline(stream))
	close(stream)

	# Open lab_file and offer help:
	if session.is_pluto
		# Open a Pluto lab:
		@async Pluto.run(notebook=lab_file)
		println( "You're running a Pluto lab. After it has loaded, you can press Ctrl-C")
		println( "if you want to experiment in the Julia console while it is running.")
		println( "Remember to call nextlab() and restart Julia when you've completed the lab.")
		println()
	else
		# Open a Julia lab:
		session.activities = include(lab_file)
	end
	println( "OK, I've just set up the lab session for you.")
	println( "Enter help() in the Julia console at any time to see your options, and enter")
	println( "hint() to get support on the current learning activity. Have fun! :-)")
end

#-----------------------------------------------------------------------------------------
"""
help()

Display a list of Ingolstadt commands.
"""
function help()
	println( "List of Ingolstadt commands:")
	println( "   help()          : Display this list of options")
	println( "   hint()          : Display a hint for the current activity")
	println( "   gimme()         : Display the current activity")
	println( "   reply(response) : Submit a response to the current activity")
	println( "   save()          : Save the current status of this session")
	println( "   nextlab()       : Move to the next lab (then restart Julia before continuing!)")
	println( "   letsgo()        : Start a new session")
end

#-----------------------------------------------------------------------------------------
"""
hint( act::Activity=session.activity[session.current_act])

Display a hint for the current activity
"""
function hint( act::Activity=session.activities[session.current_act])
	println( "Hint:  ", act.hint)
end

#-----------------------------------------------------------------------------------------
"""
	gimme()

Present learner with the next activity in this laboratory.

If the next activity is available, display it; otherwise move to next laboratory.
"""
function gimme()
	if session.current_act ≤ length(session.activities)
		# There are new activities in this lab - go to the next one:
		pose(session.activities[session.current_act])
	else
		# Current activity was the last in the lab - go to next lab:
		nextlab()
	end
end

#-----------------------------------------------------------------------------------------
"""
	reply( response)

Learner replies to the current activity with the given response.

If the answer is correct, move on to the next activity; otherwise check with learner.
"""
function reply( response)
	if ~evaluate(session.activities[session.current_act],response)
		# Response was unsuccessful:
		print("Do you want to try again? ")
		if occursin("yes",lowercase(readline()))
			return
		end
	end

	# Whether response was correct or incorrect, we're moving to the next activity:
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
function nextlab( lab::Int = 0)
	if lab ≤ 0
		# No lab given - default to next lab after the current one:
		lab = session.lab_num + 1
	end

	if !isfile(labfile(session.lab_path,lab))
		# lab number is greater than the number of lab files available in directory:
		println("Sorry: Lab number $(lab) is invalid.")
	else
		# Increment the number of the current laboratory:
		session.lab_num = lab
		session.current_act = 1
		save()
	end

	# Friendly closing greeting to the learner:
	println( "Great - that's the end of this lab - I've saved your current status.")
	println( "Please restart Julia to move on to the next lab. 'Bye for now! :-)")
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
