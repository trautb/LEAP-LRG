#========================================================================================#
#	Sample startup.jl file
#
# Insert this file into your directory ~/.julia/config to have it load automatically
# whenever you start Julia.
#
# Author: Niall Palfreyman, 06/02/2022
# Reworked: Nick Diercksen, 30/06/2022
#========================================================================================#
"""
	ingo()

Change to the directory Workpath/Ingolstadt then include Ingolstadt.jl, allowing user to
work on their current Ingolstadt laboratory. Remember to replace the string marked ??? by
your own Workpath specification.
"""
function ingo()
	localProjectPath = "??? Your Workpath/Ingolstadt ???"
	cd(localProjectPath)
 	include("src/Ingolstadt.jl")
 	@eval using .Ingolstadt					# Avoid running 'using' when initialising functions
											# (https://stackoverflow.com/questions/55531397/load-julia-modules-on-demand)
 	Base.invokelatest(Ingolstadt.letsgo)	# Initialise persistently saved session
end