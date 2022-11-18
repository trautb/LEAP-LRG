"""
	IN505Flow

Module Flow: In this model an agent produces a resource that diffuses
in the world. This resource also evaporates.

Author: Niall Palfreyman (January 2020), Dominik Pfister (July 2022)
"""
module Flow
export demo                # Externally available names
using Agents, GLMakie, InteractiveDynamics   # Required packages

include("./AgentToolBox.jl")
import .AgentToolBox: polygon_marker, diffuse8, reinit_model_on_reset!

#-----------------------------------------------------------------------------------------
# Module definitions:

#-----------------------------------------------------------------------------------------
"""
	Turtle

To construct a new agent implementation, use the @agent macro and add all necessary extra
attributes. Again, id, pos and vel are automatically inserted.
"""
@agent Turtle ContinuousAgent{2} begin end

#-----------------------------------------------------------------------------------------
# Module methods:

#-----------------------------------------------------------------------------------------
"""
	initialize_model()

Create the world model.
"""
function initialize_model(;
    extent=(50, 50),		# dimensions of the world
    du=0.5,					# diffusion rate of resource u
    alphaU=0.1				# evaporation rate of resource u
)

	# generate world for agents
    space = ContinuousSpace(extent, 1.0, periodic=false)

	# set model properties
    properties = Dict(
        :du => du,
        :alphaU => alphaU,
        :u => zeros(Float64, extent) # represents the resource at every position in the world
    )

    # Generate model with agent, world, model-properties and order of agent steps
    model = ABM(Turtle, space; properties, scheduler=Schedulers.randomly)

	# add one turtle in the middle of the world
    turtle = Turtle(nextid(model), (25, 25), (0, 1))
    add_agent!(turtle, turtle.pos, model)

    return model
end

#-----------------------------------------------------------------------------------------
"""
	agent_step!(turtle, model)

The turtle collects the three resource-values infront, front-left and front-right of the direction
it is facing and pumps this value combined with a constant resource-value outwards at its back.
"""

function agent_step!(turtle, model)

	# collectiveU is the constant, that will be added towards the system
    collectiveU = 1						
    position = floor.(Int, turtle.pos) # normalize position and convert to Int to use it as an index
    # set u at turtle-position zero
    model.u[position...] = 0.0

	# add u-value of front position to collectiveU
    frontpos = position .+ floor.(Int, turtle.vel)
    collectiveU += model.u[frontpos...]
    model.u[frontpos...] = 0.0

	# add u-value of front-left position to collectiveU
    frontleftpos = frontpos .+ (-1, 0)
    collectiveU += model.u[frontleftpos...]
    model.u[frontleftpos...] = 0.0

	# add u-value of front-right position to collectiveU
    frontrightpos = frontpos .+ (1, 0)
    collectiveU += model.u[frontrightpos...]
    model.u[frontrightpos...] = 0.0

	# add collectiveU at back-position of turtle
    backpos = position .- floor.(Int, turtle.vel)
    model.u[backpos...] += collectiveU
end

#-----------------------------------------------------------------------------------------
"""
	model_step!(model)

Lets every position of the model diffuse its u-value to the eight surrounding positions.
Afterwards let every position evaporate a small percentage of u.
"""
function model_step!(model)

    newU = diffuse8(model, model.u, model.du)

	# evaporate
    for element in newU
        element = (1 - model.alphaU) * element
    end
    
	# write new u-values into u-matrix of the model
    model.u .= newU
end

#-----------------------------------------------------------------------------------------
"""
	demo()

creates an interactive abmplot of the Flow module to visualize
flow of a resource inside an environment.
"""
function demo()

    #initialize the model 
    model = initialize_model()

    # Sliders for model
    params = Dict(
        :du => 0:0.01:1,
        :alphaU => 0:0.01:1
    )

	# instructions for ucolor for abm_plot
    ucolor(model) = model.u 

	# define heatmap-colors and range of values
    heatkwargs = (colormap=[:black, :green], colorrange=(0:0.1:10)) 

	# specify plot arguments
    plotkwargs = ( 
        ac=:red, 				# agents color (ac)
        as=5, 					# agents size
        am=polygon_marker, 		# agents marker
        heatarray=ucolor, 		# sets value-calculation for heatmap
        heatkwargs=heatkwargs, 	# sets heatmap-arguments
        add_colorbar=false,
    )

    #create the interactive plot with our sliders
    fig, p = abmexploration(
        model; 
        (agent_step!)=agent_step!, 
        (model_step!)=model_step!, 
        params, 
        plotkwargs...)
    
    reinit_model_on_reset!(p, fig, initialize_model)
    
    fig

end


end # ... end of module Flow
