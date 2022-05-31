"""
This module can be used as a collection of useful functions for modelling
    agent based systems, which are not already available through other packages
"""
module AgentToolBox

export getAgentsByType

"""
    getAgentsByType(model, type)

returns all agents of the given type
"""
getAgentsByType(model, type) = [agent for agent in allagents(model) if agent.type == type]


end