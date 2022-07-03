
"""

"""
# module FirstModel

using Agents
include("AgentToolBox.jl")
using .AgentToolBox: choosecolor


mutable struct Particle <: AbstractAgent
    id::Int
    pos::NTuple{2,Float64}
    vel::NTuple{2,Float64}
end



function initialize_model(;
    worldsize=40,
    extent=(worldsize, worldsize)
)
    spacing = 1.0
    space = ContinuousSpace(extent, spacing)

    model = ABM(Particle, space)

    for _ in 1:3
        add_agent!(
            model,
            (rand(),rand())         # velocity
        )
    end

    return model
end


function agent_step!(particle, model)
    # move the agent only if no other particles are in the radius of 3
    # move_agent!(particle, model)
end


function model_step!(model)
    #for agent in allagents(model)
    #end

    #calculate the mean #hint 3 agents
end

# function demo()
    model = initialize_model()


    # abmplot(model)

# end

# end