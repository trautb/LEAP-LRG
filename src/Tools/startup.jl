#========================================================================================#
#	Sample startup.jl file
#
# Insert this file into your directory ~/.julia/config to have it start automatically
# whenever you start Julia.
#
# Author: Niall Palfreyman, 06/02/2022
#========================================================================================#

# This function moves to the indicated directory and includes Ingolstadt, allowing you to
# start working on your current laboratory. Remember to replace ??? by your own
# directory specification:
function ingo()
	cd("C:/Users/???/Ingolstadt")
	include("src/Ingolstadt.jl")
end
