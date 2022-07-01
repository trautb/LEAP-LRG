
"""
This module can be used as a collection of useful functions for modelling
    agent based systems, which are not already available through other packages
"""
module AgentToolBox
using Agents, InteractiveDynamics
export getAgentsByType, rotate_2dvector, eigvec, turtlemarker, choosecolor, wrapMat, diffuse4

DEGREES = 0:0.01:2π

"""
    getAgentsByType(model, type)

returns all agents of the given type
"""
getAgentsByType(model, type) = [agent for agent in allagents(model) if agent.type == type]


"""
    turtlemarker(p)

creates a turtle marker (triangle shape) for the given agent `p`. \\
The orientation depends on the velocity of `p`
"""
function turtlemarker(p::Union{ContinuousAgent,AbstractAgent})
    particle_polygon = Polygon(Point2f[(-0.25, -0.25), (0.5, 0), (-0.25, 0.25)])
    φ = atan(p.vel[2], p.vel[1])
    scale(rotate2D(particle_polygon, φ), 2)
end


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

    return Tuple(
        [
            cos(φ) -sin(φ)
            sin(φ) cos(φ)
        ] *
        [vector...]
    )
end


# TODO: description!!!
function eigvec(vector)
    if (vector == Tuple([0.0, 0.0]))
        return Tuple([0.0, 0.0])
    else
        vector1 = vector[1] / sqrt((vector[1])^2 + (vector[2])^2)
        vector2 = vector[2] / sqrt((vector[1])^2 + (vector[2])^2)
        return Tuple([vector1, vector2])
    end
end


# TODO: finish description! (I have little clue what is expected as input nor what will be returned)
"""
    wrapMatrix(matrix,index)

extends the boundaries of a matrix to return valid indices
"""
function wrapMat(size_row, size_col, index::Vector{Vector{Int64}})

    cart(i, j) = (j - 1) * size_col + i
    indeces = []


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
        append!(indeces, [cart(index1, index2)])


    end


    return indeces
end





#Implementation of diffuse4 from Netlogo
# TODO: description!!!
function diffuse4(mat::Matrix{Float64}, rDiff::Float64)
    size_row, size_col = size(mat)
    map(CartesianIndices((1:size_row, 1:size_col))) do x

        cart(i, j) = (j - 1) * size_col + i
        nmacart(i, j) = [cart(i + 1, j), cart(i - 1, j), cart(i, j - 1), cart(i, j + 1)]

        nma(i, j) = [[i + 1, j], [i - 1, j], [i, j - 1], [i, j + 1]]
        if (x[1] == 1 || x[1] == size_row || x[2] == 1 || x[2] == size_col)
            neighbours = wrapMat(size_row, size_col, nma(x[1], x[2]))
        else
            neighbours = nmacart(x[1], x[2])
        end
        flow = mat[x[1], x[2]] * rDiff
        mat[x[1], x[2]] *= 1 - rDiff
        mat[neighbours] = mat[neighbours] .+ (flow / 4)

    end
    return mat
end


end # of module AgentToolBox