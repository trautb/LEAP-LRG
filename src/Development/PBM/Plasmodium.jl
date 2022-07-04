module Plasmodium
  export plasmnutri10, demo4


  using Pkg
  Pkg.add("CairoMakie")
  Pkg.add("GLMakie")
  using Agents, LinearAlgebra
  using Random # hides
  using InteractiveDynamics
  using GLMakie


  # means plasmodium or nutrition source. unfortunately we can only create one agent per model
  mutable struct plasmnutri10 <: AbstractAgent
      id::Int
      pos::NTuple{2,Float64}
      vel::NTuple{2,Float64}
      speed::Float64
      plasmodium::Bool
      size::Int64
      color::Symbol
  end


  function initialize_model(; 
      pPop           =      0.1,
      rDollop        =      5,
      rEvapU         =      0.1,
      rDiffU         =      1.0,
      sensorAngle    =      60,
      wiggle         =      60,
      sensorRange    =      9,
      bRandomTension =      false,
      rEngulf        =      5,
      rEngulfment    =      1,
      pLive          =      0, #1 / 3
      rG             =      9,
      nGmin          =      0,
      nGmax          =      10,
      pG             =      1,
      rS             =      5,
      nSmin          =      0,
      nSmax          =      24,
      bDiscworld     =      false,
      bFeeding       =      false,
      u              =      0,#; Reacting and diffusing chemo-attractant
      diffU          =      0,#; Local diffusion rate of attractant: as yet unused#; Repellent (-inf,0) and illumination (0,1)
      nutrient       =      0,
      extent         =      ((200, 200)),
      spacing        =      0.5,
      tiles          =      zeros(200,200),
      hazard         =      ones(200,200).*-1,
      nahrung        =      10)
      # defining the petri dish
      # first 2 dimensions are the grid; the 3. dimension are "tile's own properties" (1.: u, 2: diffU, 3.: hazard, 4.: nutrient)
      

      # defining the model's "globaly reachable" variables
      properties  =  Dict(:pPop           =>      pPop,
                          :rDollop        =>      rDollop,
                          :rEvapU         =>      rEvapU,
                          :rDiffU         =>      rDiffU,
                          :sensorAngle    =>      sensorAngle,
                          :wiggle         =>      wiggle,
                          :sensorRange    =>      sensorRange,
                          :bRandomTension =>      bRandomTension,
                          :rEngulf        =>      rEngulf,
                          :rEngulfment    =>      rEngulfment,
                          :pLive          =>      pLive,
                          :rG             =>      rG,
                          :nGmin          =>      nGmin,
                          :nGmax          =>      nGmax,
                          :pG             =>      pG,
                          :rS             =>      rS,
                          :nSmin          =>      nSmin,
                          :nSmax          =>      nSmax,
                          :bDiscworld     =>      bDiscworld,
                          :bFeeding       =>      bFeeding,
                          :tiles          =>      tiles,
                          :i              =>      1,
                          :u              =>      tiles,
                          :nutrient       =>      tiles,
                          :cMap            =>     tiles,
                          :nuts           =>      (((30,65)),((100,65)),((170,65)),((30,135)),((100,135)),((170,135))),
                          :hazard         =>      hazard,
                          :nahrung        =>      nahrung)

      # setting up space and model                    
      space2d = ContinuousSpace(extent,spacing)
      model = ABM(plasmnutri10, space2d; properties, scheduler = Schedulers.randomly) 
      hazard[21:179,21:179] .= 0
      
      # add the plasmodii
      map(CartesianIndices(( 11:(extent[1]-11), 11:(extent[2]-11)))) do x
          #check if there is hazard on the tile
          if hazard[x] != -1 && rand() < pPop  
            vel = [rand(-1.0:0.01:1.0), rand(-1.0:0.01:1.0)]
            vel = eigvec(vel)
          add_agent!(
              Tuple(x),
              model,
              vel,
              1,
              true,
              1,
              :orange
          )
          end
      end 
      # set the nutritients
      #=nutriplace = (((40,70)),((100,70)),((160,70)),((40,130)),((100,130)),((160,130)))
      map(x-> add_agent!(x, model, ((0.0,0.0)) ,0, false, 15, :blue), nutriplace)
      #emmit nutritients
      map(nutriplace)do x 
        model.nutrient[x[1],x[2]] = 10
        model.u[x[1],x[2]] += 10  
      end=#

      return model
  end



  #=function agent_step!(model::ABM)
    #println(model.i)
    for i in model.agents
      sensorPhase(i[2],model) 
    end

    for j in model.agents
      motorPhase(j[2],model) 
    end  
    #model.i+=1  
  end=#

  function model_step!(model::ABM)
    for i in model.agents
      sensorPhase(i[2],model) 
    end
    
    for j in model.agents
      motorPhase(j[2],model) 
    end  
    nicheDynamics(model)   
  end


  function sensorPhase(plasmodium,model)
    #sniff and turn to face the highest concentration of chemoattractants
    #sniff ahead
    #println(model.i)
    sA = sniff_ahead(plasmodium,model)
    #sniff rigth
    sR = sniff_right(plasmodium,model.sensorAngle,model)-sA
    #sniff left
    sL = sniff_left(plasmodium,model.sensorAngle,model)-sA
    # turn to face highest concentration
    if (sL > 0) || (sR > 0) 
      if (sL > 0) && (sR > 0) 
        plasmodium.vel = eigvec(rotate_2dvector(360-(rand(0.1:model.wiggle) - rand(0.1:model.wiggle)),plasmodium.vel))
        #; Here is Jones's code for the above line:
        if rand() < 0.5 
          plasmodium.vel=turn_right(plasmodium,model.wiggle)
        else
          plasmodium.vel=turn_left(plasmodium,model.wiggle)
        end
      else
        if (sL > 0) 
          plasmodium.vel=turn_left(plasmodium,model.wiggle)
        else
          plasmodium.vel=turn_right(plasmodium,model.wiggle)
        end
      end
    end
  end

  function motorPhase(plasmodium,model)
    #attempt to move if space is available and drop chemoattractants
    #println("motorphase")
    if plasmodium.plasmodium==true
      if is_empty_patch(plasmodium,model)  
        #println("true")
        move_agent!(plasmodium,model,plasmodium.speed)
        pos = collect(plasmodium.pos)
        pos = [round(Int,pos[1]),round(Int,pos[2])]
        pos = wrapMat(model.u,pos)
        model.u[pos[1],pos[2]] = model.rDollop
      else
        #println("false")
        #turn to random direction
        plasmodium.vel = turn_right(plasmodium,rand(1:360))
        #if rand()>0.8
        #move_agent!(plasmodium,model,plasmodium.speed) 
      end
    end
  end




  #---------------------------------------------------------------------------------------------
  # nicheDynamics: Observer procedure
  # Attractants interact, evaporate and/or diffuse locally on all patches.
  #---------------------------------------------------------------------------------------------
  function nicheDynamics(model::ABM)
    #emmit nutrients
    map(model.nuts) do x 
      model.u[x[1],x[2]]+= model.nahrung  
    end
    #diffuse
    model.u= diffuse4(model.u, model.rDiffU)
    #evaporate
    model.u.*= (1-model.rEvapU) 
    #reset hazards after diffusion and evaporation
    #=hazards = findall(x-> x<0,model.hazard)
    for j in hazards
      model.u[j]=-1
    end=#
      #set the colormap to math chemoattractants
    model.cMap = model.u
  end

  #---------------------------------------------------------------------------------------------
  # repaintPatches: Observer procedure
  # Repaint all Loci and patches according to attractant concentration
  #---------------------------------------------------------------------------------------------

  function demo4()
    plotkwargs = (
              add_colorbar=false,
              heatarray=:cMap,
              heatkwargs=(
                  # colorrange=(-8, 0),
                  colormap=cgrad(:bluesreds),
                  ),
                  
              )

    params = Dict(:pPop => 0.01:0.01:1,
    :rDollop        =>      0.01:0.01:15,
    :rEvapU         =>      0.1:0.1:1.0,
    :rDiffU         =>      0.1:0.1:1.0,
    :sensorAngle    =>      1:1:90,
    :wiggle         =>      1:0.1:90,
    :sensorRange    =>      1:1:20,
    :nahrung        =>      5:1:400,)
    model = initialize_model()
    cellcolor(a::plasmnutri10) = a.color
    cellsize(a::plasmnutri10) = a.size
    fig, p = abmexploration(model; model_step!, params, ac = cellcolor, as = cellsize, plotkwargs...)
    fig
  end
  #--------------------------------------------------------------------------------------------
  # Utilities:
  # 
  #--------------------------------------------------------------------------------------------
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
      index = [rem(index[1]+size(matrix)[1],size(matrix)[1]), rem(index[2]+size(matrix)[2],size(matrix)[2])]
      return index
  end


  function diffuse4(mat::Matrix{Float64},rDiff::Float64)

    map(CartesianIndices(( 1:size(mat)[1]-1, 1:size(mat)[2]-1))) do x
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


  function rotate_2dvector(φ, vector) 
    return Tuple(
        [
            cos(φ) -sin(φ)
            sin(φ) cos(φ)
        ] *
        [vector...]
    )
  end


  function eigvec(vector)
    if (vector == Tuple([0.0, 0.0]))
        return Tuple([0.0, 0.0])
    else
      vector1 = vector[1]/sqrt((vector[1])^2+(vector[2])^2)
      vector2 = vector[2]/sqrt((vector[1])^2+(vector[2])^2)
      return Tuple([vector1, vector2])
    end
  end


  function turn_right(agent::AbstractAgent,angle)
    vel = rotate_2dvector(360-angle,agent.vel)
    return eigvec(vel)
  end


  function turn_left(agent::AbstractAgent,angle)
    vel = rotate_2dvector(angle,agent.vel)
    return eigvec(vel)
  end

  #=sniffbox = ([sniffpos[1],sniffpos[2]], wrapMat(model.u,[sniffpos[1]-1,sniffpos[2]]), wrapMat(model.u,[sniffpos[1]+1,sniffpos[2]]), 
  wrapMat(model.u,[sniffpos[1],sniffpos[2]-1]), wrapMat(model.u,[sniffpos[1],sniffpos[2]+1]))
  summU = 0
  map(sniffbox) do x
  summU+=model.u[x[1],x[2]]
  end
  return summU=#

  function sniff_right(agent::AbstractAgent,angle,model::ABM)
    sniffpos = collect(agent.pos)+(collect(eigvec(rotate_2dvector(360-angle,agent.vel)))*model.sensorRange)
    sniffpos =[round(Int,sniffpos[1]),round(Int,sniffpos[2])]
    sniffpos = wrapMat(model.u,sniffpos)
    return model.u[sniffpos[1],sniffpos[2]]
  end


  function sniff_left(agent::AbstractAgent,angle,model::ABM)
    sniffpos = collect(agent.pos)+(collect(eigvec(rotate_2dvector(angle,agent.vel)))*model.sensorRange)
    sniffpos=[round(Int,sniffpos[1]),round(Int,sniffpos[2])]
    sniffpos = wrapMat(model.u,sniffpos)
    return model.u[sniffpos[1],sniffpos[2]] 
  end


  function sniff_ahead(agent::AbstractAgent,model::ABM)
    sniffpos = collect(agent.pos)+(collect(agent.vel)*model.sensorRange)
    sniffpos=[round(Int,sniffpos[1]),round(Int,sniffpos[2])]
    sniffpos = wrapMat(model.u,sniffpos)
    return model.u[sniffpos[1],sniffpos[2]]
  end


  function is_empty_patch(agent,model)
    agentpos = collect(agent.pos)+collect(agent.vel)*agent.speed
    agentpos=[round(Int,agentpos[1]),round(Int,agentpos[2])]
    for i in model.agents
      if i[1]!= agent.id && i[2].plasmodium==true
        if agentpos == [round(Int,i[2].pos[1]),round(Int,i[2].pos[2])]
          return false
        else
          return true
        end
      end
    end
  end



end