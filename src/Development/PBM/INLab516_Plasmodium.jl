using Agents, LinearAlgebra
using Random # hides
using Pkg
Pkg.add("CairoMakie")
Pkg.add("GLMakie")
Pkg.add("Colors")
Pkg.add("Profile")
Pkg.status("InteractiveDynamics")
using InteractiveDynamics
using GLMakie
using Colors
using Profile


mutable struct plasmnutri5 <: AbstractAgent
		id::Int
		pos::NTuple{2,Int}
		dir::NTuple{2,Int}
		speed::Bool
		plasmodium::Bool
		size::Int64
		color::Symbol
end


function initialize_model(; 
		pPop           =      0.06,
		rDollop        =      5,
		rEvapU         =      0.15, #0.1
		rDiffU         =      1, #1
		tensionAngle   =      60,
		wiggle         =      60,
		tensionRange   =      9,
		bRandomTension =      false,
		rEngulf        =      5,
		rEngulfment    =      1,
		pLive          =      0,#1 / 3,
		rG             =      9,
		nGmin          =      0,
		nGmax          =      10,
		pG             =      1,
		rS             =      1,
		nSmin          =      0,
		nSmax          =      24,
		bDiscworld     =      false,
		bFeeding       =      false,
		u              =      0,#; Reacting and diffusing chemo-attractant
		diffU          =      0,#; Local diffusion rate of attractant: as yet unused
		hazard         =      0,#; Repellent (-inf,0) and illumination (0,1)
		nutrient       =      0,
		extent         =      ((200, 200)),
		tiles          =      zeros(200,200,4),

		dt             = 0.01,
		dxy            =0.01,
		)
		# defining the petri dish
		 # first 2 dimensions are the grid; the 3. dimension are "tile's own properties" (1.: u, 2: diffU, 3.: hazard, 4.: nutrient, 5:du_dt)
		

		# defining the model's "globaly reachable" variables
		properties  =  Dict(:pPop           =>      pPop,
												:rDollop        =>     rDollop,
												:rEvapU         =>      rEvapU,
												:rDiffU         =>      rDiffU,
												:tensionAngle   =>      tensionAngle,
												:wiggle         =>      wiggle,
												:tensionRange   =>      tensionRange,
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
												:cMap            =>     tiles[:,:,1],
												:dt             =>      dt,
												:dxy             =>     dxy,
												:i              =>      1,
												:u              =>      0)

		# setting up space and model                    
		space2d = GridSpace(extent)
		model = ABM(plasmnutri5, space2d; properties, scheduler = Schedulers.fastest) 
		ourHazard = ones(200,200).*-1
		ourHazard[21:179,21:179] .= 0
		model.tiles[:,:,3] = ourHazard
		
		# add the plasmodii
		map(CartesianIndices(( 20:(extent[1]-20), 50:(extent[2]-50)))) do x
				#check if there is hazard on the tile
				if tiles[x,3] != -1 && rand() < pPop  
				p =((rand(-1:1:1), rand(-1:1:1)))
						add_agent!(
						Tuple(x),
						model,
						((p[1],p[2])),
						true,
						true,
						5,
						:orange
				)
				end
		end 
		# set the nutritients
		nutriplace = (((40,70)),((100,70)),((160,70)),((40,130)),((100,130)),((160,130)))
		map(x-> add_agent!(x, model, ((0,0)) ,false, false, 30, :blue), nutriplace)
		#emmit nutritients
		map(nutriplace)do x 
			model.tiles[x[1],x[2],4] = 10
			model.tiles[x[1],x[2],1] += 10
		end

		return model
end

function agent_step!(plasmnutri4,model)
	model.i +=1
		if (model.pLive != 0) && (rand() < model.pLive)
				live(plasmnutri4,model)
		end
		nicheDynamics(plasmnutri4, model, model.i)
		step(plasmnutri4,model)
	 
	 if model.i==length(model.agents)
		model.i = 1
	 end
end

function live(plasmnutri4,model)
		if model.tiles[plasmnutri4.pos[1],plasmnutri4.pos[2],3] != 0 && plasmnutri4.plasmodium == true #check if there is hazard on the tile. remember, (model.tiles[:,:,3] = hazard)!! look in the initialize method if you need a reminder
			#; There is hazard here; forget about growing or shrinking
			plasmnutri4.dir = ((0,0))
		end
		nG = length(collect(nearby_ids(plasmnutri4.pos, model, model.rG))) - 1
		if (nG > model.nGmin && nG <= model.nGmax) && (rand() < model.pG) 
			#; Grow ...
			p = ((rand(-1.0:0.01:1.0), rand(-1.0:0.01:1.0)))
			p = ((1/norm(p)).*p)
			add_agent!(
				model,
				((round(Int,p[1]),round(Int,p[2]))),
				true,
				true,
				5,
				:yellow)
		end
		

		nS = length(collect(nearby_ids(plasmnutri4.pos, model, model.rS))) - 1
		if nS > model.nSmax || nS <= model.nSmin 
			#; ... and die:
			kill_agent!(plasmnutri4,model)
		end
end




#=function step(plasmnutri2,model)
		if plasmnutri2.plasmodium == true
		#; Set up local tension range for this step:
				#tr = model.tensionRange
				#if model.bRandomTension 
				#    tr = 1 + rand(0:0.1:(tensionRange - 1))
				#end

				#; Attempt to move forwards in current facing direction:
				p = Tuple(collect(plasmnutri2.pos)+collect(plasmnutri2.dir))
				if isempty(nearby_ids(p, model, 0))#p != nobod3y and not any? turtles-on p 
				#; Take a step forward:
						#println("true")
						walk!(plasmnutri2, plasmnutri2.dir, model, ifempty=false)
						#set the u value of the tile where our agent is standing. remember that model.tiles[:,:,1] are the u values of our tiles!
						model.tiles[plasmnutri2.pos[1],plasmnutri2.pos[2],1]  += model.rDollop 
				
				else
						#println("false")
						#; Otherwise rotate to a new random direction:
						plasmnutri2.dir=((rand(-1:1:1),rand(-1:1:1)))
				end
	
		#; Sniff the three patches ahead and turn to face highest attractant concentration:
		f = 0
		p = collect(plasmnutri2.pos) .+ (collect(plasmnutri2.dir).* 3) 
		p = mybounds(model.tiles[:,:,1],p)
		f = model.tiles[p[1],p[2],1]
		
	
		fl = 0
		topLeft = [cos(45) -sin(45); cos(45) sin(45)]
		p = collect(plasmnutri2.pos) .+ (((collect(plasmnutri2.dir).* 3))'*topLeft)
		p = (round(Int,p[1]),round(Int,p[2]))
		p = mybounds(model.tiles[:,:,1],p)
		fl = model.tiles[p[1],p[2],1] - f
		
	
		fr = 0
		topRight = [cos(315) -sin(315); cos(315) sin(315)]
		p = (collect(plasmnutri2.pos) .+ (collect(plasmnutri2.dir).* 3))'*topRight
		p = (round(Int,p[1]),round(Int,p[2]))
		p = mybounds(model.tiles[:,:,1],p)
		fr = model.tiles[p[1],p[2],1] - f

	
		if (fl > 0) || (fr > 0) 
			if (fl > 0) && (fr > 0) 
				vel = collect(plasmnutri2.dir)'*rotateVect(360-(rand(0.1:model.wiggle) - rand(0.1:model.wiggle)))
			 # vel = (1/norm(vel)).*vel
				plasmnutri2.dir = ((round(Int,vel[1]),round(Int,vel[2])))
				
				#; Here is Jones's code for the above line:
				if rand() < 0.5 
					vel = collect(plasmnutri2.dir)'*rotateVect(360-model.wiggle)
					#vel =(1/norm(vel).*vel)
					plasmnutri2.dir = ((round(Int,vel[1]),round(Int,vel[2])))
				else
						vel = collect(plasmnutri2.dir)'*rotateVect(model.wiggle)
						#vel =(1/norm(vel).*vel)
						plasmnutri2.dir = ((round(Int,vel[1]),round(Int,vel[2])))
				end
			else
				if (fl > 0) 
					vel = collect(plasmnutri2.dir)'*rotateVect(model.wiggle)
					#vel =(1/norm(vel).*vel)
					plasmnutri2.dir = ((round(Int,vel[1]),round(Int,vel[2])))
				else
						vel = collect(plasmnutri2.dir)'*rotateVect(360-model.wiggle)
						#vel =(1/norm(vel).*vel)
						plasmnutri2.dir = ((round(Int,vel[1]),round(Int,vel[2])))
				end
			end
		end
end
end =#
	
function nicheDynamics(plasmnutri2,model,i)
	if i == length(model.agents)
		# Activate nutrient sources:
		nut = findall(x-> x>0,model.tiles[:,:,4])
		map(nut) do x if !isempty(nearby_ids(((x[1],x[2])), model, model.rEngulf)) 
										model.tiles[x[1],x[2],1]+= model.tiles[x[1],x[2],4]*model.rEngulfment 
									else
										model.tiles[x[1],x[2],1]+= model.tiles[x[1],x[2],4]
									end
		end
	
		model.tiles[:,:,1] .*= (1-model.rEvapU) 
		#diffuse
		#diffuse( u, rDiffU)
		tiles = model.tiles[:,:,1]
		mt_EB = zeros(200,200)
		h = 4
		map(CartesianIndices(( 21:179, 21:179))) do x
			
				#npos = nearby_positions((x[1],x[2]),model,1)
				#model.tiles[x[1],x[2],1] = (1-model.rDiffU) * tiles[x[1],x[2]] + sum(tiles[p[1],p[2]] for p in npos) * 1/8 * model.rDiffU
				#npos = collect(nearby_positions((x[1],x[2]),model,1))
				mt_EB[x[1],x[2]] = (4/(h^2))*(model.tiles[x[1],x[2]-1,1]+model.tiles[x[1],x[2]+1,1] + model.tiles[x[1]-1,x[2],1] + model.tiles[x[1]+1,x[2],1]-model.tiles[x[1],x[2],1])
																	 
		end
		model.tiles[:,:,5] = model.tiles[:,:,5].+model.dt .*model.rDiffU .* (mt_EB.-model.tiles[:,:,1])./(model.dxy*model.dxy)
		attu = 0.03
		model.tiles[:,:,5] = (1 - attu).*model.tiles[:,:,5]
		model.tiles[:,:,1] =  model.tiles[:,:,1] .+  model.dt .*  model.tiles[:,:,5]
	
		@view(model.tiles[:,:,1])[findall(x-> x<0,model.tiles[:,:,3])] .= -1 
		model.cMap = model.tiles[:,:,1]
		
	end
	end













function rotateVect(degree)
		return [cos(degree) -sin(degree); cos(degree) sin(degree)]
end


function wrapMat(matrix::Matrix, index::Vec2)
	if index[1]==0
		index[1] =-1
	end
	if index[1]==size(matrix)[1]
		inndex[1] = size(matrix)[1]+1
	end
	if index[2]==0
		index[2] =-1
	end
	if index[2]==size(matrix)[2]
		index[2] = size(matrix)[2]+1
	end
		return  [rem(index[1]+size(matrix)[1],size(matrix)[1]),rem(index[2]+size(matrix)[2],size(matrix)[2])]
end











	function step(plasmnutri2,model)
		if plasmnutri2.plasmodium == true
		#; Set up local tension range for this step:
				#tr = model.tensionRange
				#if model.bRandomTension 
				#    tr = 1 + rand(0:0.1:(tensionRange - 1))
				#end
			

				#; Attempt to move forwards in current facing direction:
				pos_ahead = Tuple(collect(plasmnutri2.pos)+collect(plasmnutri2.dir))
				if isempty(nearby_ids(pos_ahead, model))#p != nobod3y and not any? turtles-on p 
				#; Take a step forward:
						#println("true")
						
						walk!(plasmnutri2, plasmnutri2.dir, model, ifempty =true)
						#set the u value of the tile where our agent is standing. remember that model.tiles[:,:,1] are the u values of our tiles!
						model.tiles[plasmnutri2.pos[1],plasmnutri2.pos[2],1]  += model.rDollop 
				
				else
						#println("false")
						#; nd()>0.7
						plasmnutri2.dir=((rand(-1:1:1),rand(-1:1:1)))
						
						if rand()>0.98
							walk!(plasmnutri2, plasmnutri2.dir, model)
							model.tiles[plasmnutri2.pos[1],plasmnutri2.pos[2],1]  += model.rDollop 
						
						end
			end
		 
				#walk!(plasmnutri2, plasmnutri2.dir, model, ifempty=true)
				model.u=0
				#; Sniff the patches ahead and turn to face highest attractant concentration:
					positions_ahead = nearby_positions(Tuple(collect(plasmnutri2.pos)+collect(plasmnutri2.dir)),model,1)
					map(positions_ahead) do x
						if model.tiles[x[1],x[2],1]>model.u 
							model.u = model.tiles[x[1],x[2],1]
							plasmnutri2.dir = Tuple([x[1], x[2]]-collect(plasmnutri2.pos))
					 end
					end
				
		end
	end

	
model = initialize_model()

plotkwargs = (
						add_colorbar=false,
						heatarray=:cMap,
						heatkwargs=(
								# colorrange=(-8, 0),
								colormap=cgrad(:bluesreds),
								),
								
						)
cellcolor(a::plasmnutri5) = a.color
	cellsize(a::plasmnutri5) = a.size
	fig, p = abmexploration(model; agent_step! = agent_step!, ac = cellcolor, as = cellsize,plotkwargs...)
	fig
