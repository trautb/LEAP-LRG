#========================================================================================#
"""
	Simplex

A library of routines providing graphical plotting within a 3-simplex.

Author: Niall Palfreyman, 11/09/2022.
"""
module Simplex

using GLMakie

# Externally callable methods of Simplex:

#-----------------------------------------------------------------------------------------
# Module constants:
#-----------------------------------------------------------------------------------------
"Constant size for graphical text and markers"
const FONT_SIZE = 24

"Constant relative plot coordinates of the three reference vertices of a 3-simplex."
const SIMPLEX = [[0,0],[1,0],[0.5,sqrt(3)/2]]

"Constant relative plot coordinates of the 3-simplex vertices as a conversion matrix."
const SIMPLEX_MATRIX = hcat(SIMPLEX...)

#-----------------------------------------------------------------------------------------
# Module types:
#-----------------------------------------------------------------------------------------

#-----------------------------------------------------------------------------------------
# Module methods:
#-----------------------------------------------------------------------------------------
"""
	plot3(frequency_states::Vector{Vector{Float64}})

Construct a 3-simplex plot of a trajectory of 3-frequency states.
"""
function plot3( frequency_states::Vector{Vector{Float64}})
	fig, axis = plot3()										# Plot the simplex axes
	frequency_states = frequency_states ./ sum.(frequency_states)	# Sum of each state is 1

	# Draw the given trajectory with endpoints:
	trajectory = freq2plot(frequency_states)
    lines!( axis, getindex.(trajectory,1), getindex.(trajectory,2), linewidth=2, color=:blue)
	scatter!( axis, [trajectory[1][1]], [trajectory[1][2]], color=:green, markersize=FONT_SIZE)
	scatter!( axis, [trajectory[end][1]], [trajectory[end][2]], color=:red, markersize=FONT_SIZE)

	fig
end
plot3( frequency_states::Vector{Vector{Int}}) = 
	plot3(map(stt->Float64.(stt),frequency_states))

#-----------------------------------------------------------------------------------------
"""
	plot3(frequency_state::Vector{Float64})

Construct a simplex plot of a single 3-frequency state.
"""
function plot3( frequency_state::Vector{Float64})
	fig, axis = plot3()										# Plot the simplex axes
	frequency_state /= sum(frequency_state)							# Sum of freqs in state is 1

	# Draw the given frequency_state:
	point = freq2plot(frequency_state)
	scatter!( axis, [point[1]], [point[2]], color=:green, markersize=FONT_SIZE)

	fig
end
plot3( frequency_state::Vector{Int}) = plot3(Float64.(frequency_state))

#-----------------------------------------------------------------------------------------
"""
	plot3()

Construct simplex axes for 3-frequency states.
"""
function plot3()
	# Plot the simplex axes:
	vertices = [simplex();[simplex()[1]]]				# Repeat first vertex to draw all sides
	fig = Figure(fontsize=FONT_SIZE)
    axis = Axis(fig[1, 1])
    scatterlines!( axis,
		getindex.(vertices,1), getindex.(vertices,2),
		linewidth=2,
		color=:black,
		markercolor=:magenta,
		markersize=FONT_SIZE
	)
	text!( "x", position=(0,-0.07), textsize=FONT_SIZE)		# Population type x: bottom-left
	text!( "y", position=(1,-0.07), textsize=FONT_SIZE)		# Population type y: bottom-right
	text!( "z", position=(0.49, 0.93), textsize=FONT_SIZE)	# Population type z: top-centre

	(fig, axis)
end

#-----------------------------------------------------------------------------------------
"""
	simplex()

Return the relative plot coordinates of the three reference vertices of a 2-d simplex.
"""
function simplex()
	SIMPLEX
end

#-----------------------------------------------------------------------------------------
"""
	freq2plot(frequency)

Return the relative plot coordinates of the single given frequency witin the SIMPLEX.
"""
function freq2plot( frequency::Vector{Float64})
	SIMPLEX_MATRIX * frequency
end

freq2plot( frequency::Vector{Int}) = freq2plot( Float64.(frequency))

#-----------------------------------------------------------------------------------------
"""
	freq2plot(frequencies)

Return relative plot coordinates of all frequencies within the SIMPLEX.
"""
function freq2plot( frequencies::Vector{Vector{Float64}})
	if length(frequencies[1]) != 3
		error("Sorry: I can only work with 3d convex combinations")
	end

	freq2plot.(frequencies)
end

end		# of Simplex