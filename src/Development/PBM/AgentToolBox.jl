
"""
This module can be used as a collection of useful functions for modelling
    agent based systems, which are not already available through other packages
"""
module AgentToolBox
using Agents,InteractiveDynamics
export getAgentsByType, rotate_2dvector,eigvec,particlemarker,choosecolor

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
function particlemarker(p::Union{ContinuousAgent, AbstractAgent})
    particle_polygon = Polygon(Point2f[(-0.25, -0.25), (0.5, 0), (-0.25, 0.25)])
    φ = atan(p.vel[2], p.vel[1])
    scale(rotate2D(particle_polygon, φ), 2)
end

function choosecolor(p::Union{ContinuousAgent, AbstractAgent})

    if (p.id%3 == 0)
        ac = :red
    elseif (p.id%3 == 1)
        ac = :green
    elseif (p.id%3 > 1)
        ac = :blue
    end
end

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
function eigvec(vector)
    if (vector == Tuple([0.0, 0.0]))
        return Tuple([0.0, 0.0])
    else
    vector1 = vector[1]/sqrt((vector[1])^2+(vector[2])^2)
    vector2 = vector[2]/sqrt((vector[1])^2+(vector[2])^2)
    return Tuple([vector1, vector2])
    end
end


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

end

"""
    wrapMatrix(matrix,index)

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





#Implementation of diffuse4 from Netlogo
function diffuse4(mat::Matrix{Float64},rDiff::Float64)
  map(CartesianIndices(( 1:size(mat)[1], 1:size(mat)[2]))) do x
    iX=x[1]
    iY=x[2]
    neighbours = [wrapMat(mat,[iX+1,iY]), wrapMat(mat,[iX-1,iY]), wrapMat(mat,[iX,iY-1]),  wrapMat(mat,[iX,iY+1])]
                 
    flow = mat[iX,iY]*rDiff
    mat[iX,iY] *= 1-rDiff
    map(neighbours) do j
      mat[j[1],j[2]] += flow/4 
    end
  end
  return mat


  
end



