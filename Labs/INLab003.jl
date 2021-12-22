# Generalisation and abstraction: Investigating the benefits of Multiple-Dispatch
# You might want to change the supertype to some kind of function that can be
# differentiated.
module INLab003

export Species, test, scenario, meet, Rabbit, wendy, rabia

abstract type Species end

struct Weasel <: Species; name::String end
struct Rabbit <: Species; name::String end

function encounter( meeter::Species, meetee::Species)
	if meeter isa Weasel && meetee isa Rabbit
		"attacks"
	elseif meeter isa Weasel && meetee isa Weasel
		"challenges"
	elseif meeter isa Rabbit && meetee isa Rabbit
		"sniffs"
	elseif meeter isa Rabbit && meetee isa Weasel
		"flees"
	else
		"ignores"
	end
end

meet( meeter::Weasel, meetee::Rabbit) = "attacks"
meet( meeter::Weasel, meetee::Weasel) = "challenges"
meet( meeter::Rabbit, meetee::Rabbit) = "sniffs"
meet( meeter::Rabbit, meetee::Weasel) = "flees"
meet( meeter::Species, meetee::Species) = "ignores"

function scenario( meeter::Species, meetee::Species)
	println( meeter.name, " encounters ", meetee.name, " and ", encounter(meeter,meetee), ".")
	println( meeter.name, "   meets    ", meetee.name, " and ", meet(meeter,meetee), ".")
end

wendy, willy, rabia, robby =
	(Weasel("Wendy"), Weasel("Willy"), Rabbit("Rabia"), Rabbit("Robby"))
meeters = (wendy, willy, rabia, robby)
meetees = (willy, rabia, robby, wendy)

function test( mters=meeters, mtees=meetees)
	println("Testing using conditional encounters against dispatched meetings ...")
	println()
	map( mters, mtees) do mter, mtee
		scenario( mter, mtee)
	end
	println()
end

end # of module INLab003

using .INLab003

# Activity code - not to be included!
# First we perform generalisation - extending existing function to new type:
struct Marten <: Species; name::String end
milly = Marten("Milly")
scenario(milly,rabia)
INLab003.meet( actor::Marten, meetee::Rabbit) = "hunts"
scenario(milly,rabia)

# Now we perform abstraction - using a function as a thing (e.g. differentiation)