"""
This module can be used as a collection of useful functions for modelling
    agent based systems, which are not already available through other packages
"""
module AgentToolBox

export getAgentsByType, rotate_2dvector

DEGREES = 0:.01:2π

"""
    getAgentsByType(model, type)

returns all agents of the given type
"""
getAgentsByType(model, type) = [agent for agent in allagents(model) if agent.type == type]


"""
    rotate_2dvector(φ, vector)

rotates a given `vector` by a radial degree of φ
"""
function rotate_2dvector(φ, vector)
    Tuple(
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
    Tuple(
        [
            cos(φ) -sin(φ)
            sin(φ) cos(φ)
        ] *
        [vector...]
    )
end

end

"""
    warpMatrix(matrix,index)

extends the boundaries of a matrix to return valid indices
"""

 function wrapMat(matrix::Matrix{Float64}, index::Vector{Int64})
    if index[1]==0
      index[1] =-1
    end
    if index[1]==size(matrix)[1]
      index[1] = size(matrix)[1]+1
    end
    if index[2]==0
      index[2] =-1
    end
    if index[2]==size(matrix)[2]
      index[2] = size(matrix)[2]+1
    end
      return  [rem(index[1]+size(matrix)[1],size(matrix)[1]),rem(index[2]+size(matrix)[2],size(matrix)[2])]
  end
