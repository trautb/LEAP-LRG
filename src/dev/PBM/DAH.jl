
module DAH

export Cell2, demo2

using Agents, LinearAlgebra
using Random # hides
using Pkg
Pkg.add("CairoMakie")
Pkg.add("GLMakie")
Pkg.status("InteractiveDynamics")
using InteractiveDynamics
using GLMakie

mutable struct Cell2 <: AbstractAgent
    id::Int
    pos::NTuple{2,Float64}
    vel::NTuple{2,Float64}
    speed::Float64
    cadherin      ::Float64
    color  ::Symbol

end



function initialize_model(;
    pPop =  1.0,
    rAdhesionRange = 4.0,
    rAdhesion = 0.4,
    rRadius = 1.0,
    rRepulsion = -0.5,
    rThermal = 0.01,
    rGravity = 0.0,
    nAdherins  =  3,
    extent = (40, 40)
   )   
   properties = Dict(:pPop => pPop,
   :rAdhesionRange => rAdhesionRange,
   :rAdhesion => rAdhesion,
   :rRadius =>  rRadius,
   :rRepulsion => rRepulsion,
   :rThermal => rThermal,
   :rGravity => rGravity,
   :nAdherins =>  nAdherins,)

    # Initialise Cell population
    space2d = ContinuousSpace(extent)
    model = ABM(Cell2, space2d; properties, scheduler = Schedulers.randomly)
    for _ in 1:521
        vel = Tuple((0,0))
        speed = 0
        cadherin = rand(1:1:3)
        if cadherin == 1  color = :green1 end
        if cadherin == 2  color = :gold end
        if cadherin == 3  color = :sienna4 end
        add_agent!(
            model,
            vel,
            speed,
            cadherin, 
            color,
        )
    end

    return model
end

function agent_step!(cell2,model)
    adhere(cell2,model)
    repel(cell2,model)
    meander(cell2,model)
end

function  adhere(cell2,model)

    nbr = random_nearby_agent(cell2, model, model.rAdhesionRange)
    if nbr !== nothing
        #continue here
        cell2.vel = get_direction(cell2.pos, nbr.pos, model)
        cell2.speed = model.rAdhesion * cadhesion(cell2.cadherin, nbr.cadherin, model)
        move_agent!(cell2, model, cell2.speed)
    end       
    
    
end

function  repel(cell2,model)
    penetrator = random_nearby_agent(cell2, model, model.rAdhesionRange)
    if penetrator !== nothing
        #continue here
        cell2.vel = get_direction(cell2.pos, penetrator.pos, model)
        cell2.speed = model.rRepulsion 
        move_agent!(cell2, model, cell2.speed)
    end       
   
    
end

function  gravitate(cell2,model)
    
end

function  meander(cell2,model)
    ra = rand(1:1:360)
    newX = cell2.vel[1] * cos(ra) - cell2.vel[2] * sin(ra)
    newY = cell2.vel[1] * sin(ra) + cell2.vel[2] * cos(ra)
    cell2.vel = Tuple((newX,newY))
    cell2.speed = model.rThermal
    move_agent!(cell2, model, cell2.speed)
end

function cadhesion(c1, c2,model)
    return(1-(2*abs(c1-c2) + c1 + c2) / (2*model.nAdherins))
end


function demo2()
    model = initialize_model()
    #create the interactive plot with our sliders
    cellcolor(a::Cell2) = a.color
    fig, p = abmexploration(model; agent_step! = agent_step!, ac = cellcolor, as = 30)
    fig
end
end