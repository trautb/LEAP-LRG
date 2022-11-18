#========================================================================================#
"""
	IN507NeutralDrift

**Module NeutralDrift**: \\
    This model runs a very simple simulation called a Moran process. At each
    step, a random individual dies, and is replaced by a child of one of its
    neighbours. We have added in here the possibility that blue individuals have
    a slight selective advantage over green individuals, but notice how even
    such a tiny advantage a huge effect on the outcome of the simulation!


Author: , 30/05/22
"""
module NeutralDrift

export demo_explorer                # Externally available names
using Agents, GLMakie, InteractiveDynamics   # Required packages

#-----------------------------------------------------------------------------------------
# Module definitions:

#-----------------------------------------------------------------------------------------
"""
	Patch

To construct a new agent implementation, use the @agent macro and add all necessary extra
attributes. Again, id, pos and vel are automatically inserted.
"""
@agent Patch GridAgent{2} begin end

const blue = true;
const lime = false;

#-----------------------------------------------------------------------------------------
# Module methods:

#-----------------------------------------------------------------------------------------
"""
    create_model()

Create the world model.
"""
function create_model(;
    pB=0.5,                 # proportion of blues
    AB=0.000,                 # Evolutionary advantage of blue individuals
    worldsize=32,
    extent=(worldsize, worldsize)
)

    properties = Dict(
        :patches => falses(extent),
        :pB => pB,
        :AB => AB,
        :spu => 30,
        :sleep => 0.0,
        :initialized => false)

    model = ABM(Patch, GridSpace(extent); properties=properties)
    add_agent!(model) # Add one dummy agent so that abm_video will allow us to plot.
    return model
end

#-----------------------------------------------------------------------------------------

"""
    spawn_blues!()

Spawn blue patches according to the proportion of blues `pB`.
"""
function spawn_blues!(model)
    model.patches = rand(size(model.patches)...) .< model.pB
    return model
end

#-----------------------------------------------------------------------------------------

"""
    model_step!(world)

Simulate a Moran process, in which a random individual dies, and is replaced by a
child from a random neighbour, except that blues may have an evolutionary advantage AB.
"""
function model_step!(model)
    if !model.initialized
        initialize_model!(model)
    end

    patch = rand(CartesianIndices(model.patches))
    random_neighbour = patch + rand(nearby_positions(patch.I, model).itr.iter)
    random_neighbour = min(
        CartesianIndex(size(model.space)...),
        max(CartesianIndex(1, 1), random_neighbour)
    )
    model.patches[patch] = model.patches[random_neighbour]

    # If that colour was blue, do it, otherwise only set
    # to green with a certain (unfair) probability:
    keeping_it_fair = model.patches[patch] == lime && rand() < 1 - model.AB
    model.patches[patch] = keeping_it_fair ? lime : blue
    return model
end

#-----------------------------------------------------------------------------------------

"""
    initialize_model!(model)

This method is needed to initialize the system. This is specially important to
reflect the adjustements made with the parameters on the abmplot.
"""
function initialize_model!(model)
    spawn_blues!(model)
    model.initialized = true
    return model;
end

#-----------------------------------------------------------------------------------------
"""
    demo_explorer()

creates an interactive abmplot of the EmergentBehaviour module to visualize
Sierpinski's triangle.
"""
function demo_explorer()
    params = Dict(
        :pB => 0:0.1:1,
        :AB => 0:0.001:0.01
    )

    plotkwargs = (
        add_colorbar=false,
        heatarray=:patches,
        heatkwargs=(
            colorrange=(0, 1),
            colormap=cgrad([:lime, :blue]; categorical=true),
        ),
        as = 0,
        title = "Nuetral Drift:",
    )

    model = create_model()
    fig, p = abmexploration(model; (agent_step!)=dummystep, model_step!, params, plotkwargs...)
    fig
end

end # ... of module NeutralDrift