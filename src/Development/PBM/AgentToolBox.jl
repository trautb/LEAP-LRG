
"""
	AgentToolBox

This module can be used as a collection of useful functions for modelling
agent based systems, which are not already available through other packages

Authors:  Emilio Borelli, Nick Diercksen, Stefan Hausner, Dominik Pfister (July 2022)
"""
module AgentToolBox


using Agents, InteractiveDynamics

using  GLMakie,Observables			# needed for custom abmexploration functions
import InteractiveUtils: @which		# ...


export choosecolor, diffuse4, diffuse8, eigvec, is_empty_patch, mean_nb, neighbors4, nonwrap_nb,
	polygon_marker, reinit_model_on_reset!, rotate_2dvector, turn_right,turn_left, wrapMat,
	neuman_neighbourhood



# constants ------------

DEGREES = 0:0.01:2π


# agent functions --------------------------------------------------------------


"""
	choosecolor(p)

returns a color depeding on the id of the agent `p`.
* `:red` if p.id%3 == 0
* `:green` if p.id%3 == 1
* `:blue` if p.id%3 > 1

That way a the color of agents will be more diverse.
"""
function choosecolor(p::Union{ContinuousAgent,AbstractAgent})

	if (p.id % 3 == 0)
		ac = :red
	elseif (p.id % 3 == 1)
		ac = :green
	elseif (p.id % 3 > 1)
		ac = :blue
	end
end


"""
	polygon_marker(p)

creates a triangle shaped marker for the given agent `p`. \\
The orientation depends on the velocity of `p`
"""
function polygon_marker(p::Union{ContinuousAgent,AbstractAgent}; as=2)
	particle_polygon = Polygon(Point2f[(-0.25, -0.25), (0.5, 0), (-0.25, 0.25)])
	φ = atan(p.vel[2], p.vel[1])
	scale(rotate2D(particle_polygon, φ), as)
end


"""
	turn_right(agent::AbstractAgent,angle)
	
returns a rotated velocity vector
"""
function turn_right(agent::AbstractAgent, angle)
	vel = rotate_2dvector(360 - angle, agent.vel)
	return eigvec(vel)
end


"""
	turn_left(agent::AbstractAgent,angle)

returns a rotated velocity vector
"""

function turn_left(agent::AbstractAgent, angle)
	vel = rotate_2dvector(angle, agent.vel)
	return eigvec(vel)
end


"""
	eigvec(vector)

creates the eigenvector of an tuple
this function uses linear transformation to
scale an tuple. 
"""
function eigvec(vector)
	if (vector == Tuple([0.0, 0.0]))
		return Tuple([0.0, 0.0])
	else
		vector1 = vector[1] / sqrt((vector[1])^2 + (vector[2])^2)
		vector2 = vector[2] / sqrt((vector[1])^2 + (vector[2])^2)
		return Tuple([vector1, vector2])
	end
end

"""
	rotate_2dvector(φ, vector)

rotates a given `vector` by a radial degree of φ
"""
function rotate_2dvector(φ, vector)
	return Tuple(
		[
			cos(φ) -sin(φ)
			sin(φ) cos(φ)
		] *
		[vector...]
	)
end
"""
	rotate_2dvector(φ, vector)

rotates a given `vector` by a random degree ∈ -π:.01:π
"""
function rotate_2dvector(vector)
	# more efficient to call `rand` on a variable (no need for additional allocations)
	φ = rand(DEGREES)
	return rotate_2dvector(φ, vector)
end



# patch-functions: -------------------------------------------------------------

"""
	buildValleys(worldsize)

creates a height map (u values) corresponding of a multimodal landscape.
The returned matrix has dimensions of (worldsize, worldsize)
"""
function buildValleys(worldsize)
	maxCoordinate = worldsize ÷ 2
	xy = 4 .* collect(-maxCoordinate:(maxCoordinate-1)) ./ maxCoordinate

	f(x, y) = (1 / 3) * exp(-((x + 1)^2) - (y^2)) +
			  10 * (x / 5 - (x^3) - (y^5)) * exp(-(x^2) - (y^2)) -
			  (3 * ((1 - x)^2)) * exp(-(x^2) - ((y + 1)^2))
	f.(xy, xy')
end


"""
	buildValleys(worldsize)

creates a height map (u values) corresponding to De Jong's complicated multi-
modal landscape.
The returned matrix has dimensions of (worldsize, worldsize)
"""
function buildDeJong7(worldsize)
	maxCoordinate = worldsize ÷ 2
	xy = 20 .* collect(-maxCoordinate:(maxCoordinate-1)) ./ maxCoordinate

	f(x, y) = sin(180 * 2 * x / pi) / (1 + abs(x)) + sin(180 * 2 * y / pi) / (1 + abs(y))
	f.(xy, xy')
end

"""
	diffuse4(mat::Matrix{Float64}, rDiff::Float64, wrapmat::Bool)

mat defines the matrix 
rDiff defines the difussion rotate
wrapmat decides if the model should wrap the matrix or not
neighbors returns the indices in cartician indices

Takes a matrix with values to be diffused, a diffusionrate and a boolean. Returns the diffused matrix.
The functin iterates through the mat matrix. For each value in the matrix it takes the percentage of its value, 
given by rDiff and splits it up to its neuman 4 neighborhood
"""

function diffuse4(mat::Matrix{Float64}, rDiff::Float64, wrapmat::Bool)
	size_row = size(mat)[1]
	size_col = size(mat)[2]
	map(CartesianIndices((1:size(mat)[1], 1:size(mat)[2]))) do x

		if (x[1] == 1 || x[1] == size_row || x[2] == 1 || x[2] == size_col)
			if (wrapmat == true)
				neighbours = wrapMat(size_row, size_col, neuman_neighbourhood(x[1], x[2]))
			elseif (wrapmat == false)
				neighbours = nonwrap_nb(size_row, size_col, neuman_neighbourhood(x[1], x[2]))
			end
		else
			neighbours = neumann_cartini(size_col, x[1], x[2])
		end
		flow = mat[x[1], x[2]] * rDiff
		mat[x[1], x[2]] *= 1 - rDiff
		mat[neighbours] = mat[neighbours] .+ (flow / 4)
	end
	return mat
end

"""
	nonwrap_nb(size_row, size_col, index::Vector{Vector{Int64}})

return the cartesian indices that are inside the world.
indices outside the world will not be used.
"""
function nonwrap_nb(size_row, size_col, index::Vector{Vector{Int64}})
	sumup = []
	for ids in 1:size(index)[1]
		if index[ids][1] <= 0 || index[ids][1] >= size_row || index[ids][2] <= 0 || index[ids][2] >= size_col
		else
			append!(sumup, cartesian_indices(size_col, index[ids][1], index[ids][2]))
		end
	end
	return sumup
end
"""
	neuman_neighbourhood(rowindex, colindex)

Creates an neumann_neighborhood.
Gets the patch on the left on the right ont the
top and the bottom. 
returns indices in pairs
"""
function neuman_neighbourhood(rowindex, colindex)
	i = rowindex
	j = colindex
	return [[i + 1, j], [i - 1, j], [i, j - 1], [i, j + 1]]
end

"""
	cartesian_indices(size_col, rowindex, colindex)

converts inidices into cartesian_indices
"""
function cartesian_indices(size_col, rowindex, colindex)
	i = rowindex
	j = colindex
	return (j - 1) * size_col + i
end

"""
	neumann_cartini(size_col, rowindex, colindex)

return the von neumann neighborhood in 
cartesian indices
"""
function neumann_cartini(size_col, rowindex, colindex)
	i = rowindex
	j = colindex
	return [cartesian_indices(size_col, i + 1, j), cartesian_indices(size_col, i - 1, j),
		cartesian_indices(size_col, i, j - 1), cartesian_indices(size_col, i, j + 1)]
end

# -------

"""
	diffuse8(model, diffuse_matrix, diffusion_rate)

Function for diffusing all values of a matrix to their respective 8 surrounding tiles.
Size of model and diffuse_matrix have to match.
"""
function diffuse8(model::AgentBasedModel, diffuse_value::Matrix{Float64}, diffusion_rate::Float64)
	# Create new matrix to not interfere with the current values of diffuse_value
	newMatrix = zeros(Float64, size(diffuse_value))

	@inbounds for p in positions(model)
		# calculate diffusion values
		diff_at_p = diffuse_value[p...]
		Δdiff_at_p = diff_at_p * diffusion_rate
		split_value = 1 / 8 * Δdiff_at_p

		# create new position kernel
		position_kernel = [
			(-1, 1) (0, 1) (1, 1)
			(-1, 0) (0, 0) (1, 0)
			(-1, -1) (0, -1) (1, -1)
		]

		# transform position_kernel to current p
		position_kernel = [t .+ p for t in position_kernel]

		# fix out-of-bounds indices
		position_kernel = check_boundaries(position_kernel, size(diffuse_value))

		# generate value-kernel for position p
		value_kernel = [
			split_value split_value split_value
			split_value diff_at_p-Δdiff_at_p split_value
			split_value split_value split_value
		]

		# add value_kernel to positions in newMatrix
		for i in 1:9
			newMatrix[position_kernel[i]...] += value_kernel[i]
		end
	end
	return newMatrix
end


"""
check_boundaries(position_kernel, model_extent)

Function for checking if a position_kernel contains out-of-bounds inidices and fixes them.
This function is only used as background-logic for diffuse8.
"""
function check_boundaries(position_kernel::Matrix{Tuple{Int64, Int64}}, model_extent::Tuple{Int64, Int64})

	n_rows, n_columns = model_extent

	for i in 1:9
		p_x, p_y = position_kernel[i]
		if (p_x <= 0)
			p_x = 1
		elseif (p_x > n_columns)
			p_x = n_columns
		end
		if (p_y <= 0)
			p_y = 1
		elseif (p_y > n_rows)
			p_y = n_rows
		end
		position_kernel[i] = (p_x, p_y)
	end

	return position_kernel
end


"""
	neighbors4(agent, model)

Collects all agents ids that are on the 4 adjacent spots to the agents position
or on the agents spot itself.
"""
function neighbors4(agent::AbstractAgent, model::AgentBasedModel)

	near_agents = nearby_agents(agent, model, 2)
	list_of_ids = []
	for ag in near_agents
		if ag.id != agent.id
			if (is_agent_in_neighbors4(agent, ag))
				append!(list_of_ids, ag.id)
			end
		end
	end
	return list_of_ids
end


"""
	is_agent_in_neighbors4(central_agent, test_agent)

Tests if an agent is inside another agents direct neighborhood, that being the four
patches directly next to the central_agents patch or at the central_agents patch itself.
This function is only used as background-logic for neighbors4.
"""

function is_agent_in_neighbors4(central_agent::AbstractAgent, test_agent::AbstractAgent)

	ca_x, ca_y = ceil.(central_agent.pos)
	ta_x, ta_y = ceil.(test_agent.pos)

	return ta_x - ca_x >= -1 && ta_x - ca_x <= 1 &&
		   ta_y - ca_y >= -1 && ta_y - ca_y <= 1 &&
		   !(ta_x == 1 && ta_y == 1) &&
		   !(ta_x == 1 && ta_y == -1) &&
		   !(ta_x == -1 && ta_y == 1) &&
		   !(ta_x == -1 && ta_y == -1)
end


"""
  is_empty_patch(agent,model)
"""
function is_empty_patch(agent::AbstractAgent, model::ABM)
	agentpos = collect(agent.pos) + collect(agent.vel) * agent.speed
	agentpos = [round(Int, agentpos[1]), round(Int, agentpos[2])]
	for i in model.agents
		if i[1] != agent.id && i[2].plasmodium == true
			if agentpos == [round(Int, i[2].pos[1]), round(Int, i[2].pos[2])]
				return false
			else
				return true
			end
		end
	end
end


# TODO: finish description! (I have little clue what is expected as input nor what will be returned)
"""
	wrapMat(size_row, size_col,index)

extends the boundaries of a matrix to return valid indices
"""
function wrapMat(size_row, size_col, index::Union{Vector{Vector{Int64}},Vector{Int64}}, output_cartindi=true)
	indices = []

	if typeof(index) == Vector{Int64}
		index = [index]
	end

	for ids in 1:size(index)[1]
		if index[ids][1] == 0
			index[ids][1] = -1
		end
		if index[ids][1] == size_row
			index[ids][1] = size_row + 1
		end
		if index[ids][2] == 0
			index[ids][2] = -1
		end
		if index[ids][2] == size_col
			index[ids][2] = size_col + 1
		end

		index1 = rem(index[ids][1] + size_row, size_row)
		index2 = rem(index[ids][2] + size_col, size_col)

		if output_cartindi == true
			append!(indices, [cartesian_indices(size_col, index1, index2)])
		elseif output_cartindi == false
			append!(indices, [index1, index2])
		end


	end

	return indices
end



# functions extending `abmexploration`: ----------------------------------------

# not necessary to understand.
# compare the original source code if desired (Button initialization):
# https://github.com/JuliaDynamics/InteractiveDynamics.jl/blob/def604fa0e5d70ab0afe7677d3ae11c8f5830d5a/src/agents/interaction.jl#L62

"""
	reinit_model_on_reset()

Replaces the model of the `ABMObervable p` when clicking the "reset model"-Button.

Starting conditions on resetting can thus be changed via sliders, Agents can be 
placed randomly each time.
This way a model can be newly initialized when "resetting" the model, instead of
using a deepcopy of the forwarded model to `abmexploration` as resettable state.
* `initialize_model`: the function creating a new `ABM`

@author Nick Diercksen
"""
function reinit_model_on_reset!(p::ABMObservable, fig, initialize_model)
	# getting the reset Button:  (fig.content[10])
	reset_btn = nothing
	for element ∈ fig.content
		if element isa Button && element.label[] == "reset\nmodel"
			reset_btn = element
			break
		end
	end
	@assert !isnothing(reset_btn) "the 'reset-model-Button' could not be found!"
	# if (isnothing(reset_btn)) return

	on(reset_btn.clicks) do _
		# all keyword agruments from the function `initialize_model`
		kwargs = Base.kwarg_decl(@which initialize_model())                         # https://discourse.julialang.org/t/get-the-argument-names-of-an-function/32902/4

		# getting current values of the model: (all keywords saved as properties)
		props = p.model.val.properties
		kws = (; Dict([Pair(k, props[k]) for k in (keys(props) ∩ kwargs)])...)      # https://stackoverflow.com/questions/38625663/subset-of-dictionary-with-aliases

		# replacing the current model with a newly generated one with new initial values
		p.model[] = initialize_model(; kws...)
	end
end


end # ... of module AgentToolBox
