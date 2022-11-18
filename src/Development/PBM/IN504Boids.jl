#Author: Emilio Borrelli, translated from 04_Boids by Prof. Nial Pallfreyman

module Boids

export Bird, demo

using Agents, LinearAlgebra
using Random # hides
using InteractiveDynamics
using GLMakie

include("./AgentToolBox.jl")
import .AgentToolBox: choosecolor, reinit_model_on_reset!

mutable struct Bird <: AbstractAgent
	id::Int
	pos::NTuple{2,Float64}
	vel::NTuple{2,Float64}
	speed::Float64
	cohere_factor::Float64
	separation::Float64
	separate_factor::Float64
	match_factor::Float64
	visual_distance::Float64
end

function initialize_model(;
	n_birds=100,
	speed=1.0,
	cohere_factor=0.25,
	separation=4.0,
	separate_factor=0.25,
	match_factor=0.01,
	visual_distance=5.0,
	extent=(100, 100),
	spacing=visual_distance / 1.5
)
	# setting the slider properties to default values
	properties = Dict(:n_birds => n_birds,
		:visual_distance => visual_distance,
		:separation => separation,
		:cohere_factor => cohere_factor,
		:separate_factor => separate_factor,
		:match_factor => match_factor)

	space2d = ContinuousSpace(extent, spacing)
	model = ABM(Bird, space2d; properties, scheduler=Schedulers.randomly)
	for _ in 1:model.n_birds
		vel = Tuple(rand(model.rng, 2) * 2 .- 1)
		add_agent!(
			model,
			vel,
			speed,
			cohere_factor,
			separation,
			separate_factor,
			match_factor,
			visual_distance,
		)
	end
	return model
end

function agent_step!(bird, model)
	# Obtain the ids of neighbors within the bird's visual distance
	neighbor_ids = nearby_ids(bird, model, model.visual_distance)
	N = 0
	match = separate = cohere = (0.0, 0.0)
	# Calculate behaviour properties based on neighbors
	for id in neighbor_ids
		N += 1
		neighbor = model[id].pos
		heading = neighbor .- bird.pos

		# `cohere` computes the average position of neighboring birds
		cohere = cohere .+ heading
		if edistance(bird.pos, neighbor, model) < model.separation
			# `separate` repels the bird away from neighboring birds
			separate = separate .- heading
		end
		# `match` computes the average trajectory of neighboring birds
		match = match .+ model[id].vel
	end
	N = max(N, 1)
	# Normalise results based on model input and neighbor count
	cohere = cohere ./ N .* model.cohere_factor
	separate = separate ./ N .* model.separate_factor
	match = match ./ N .* model.match_factor
	# Compute velocity based on rules defined above
	bird.vel = (bird.vel .+ cohere .+ separate .+ match) ./ 2
	bird.vel = bird.vel ./ norm(bird.vel)
	# Move bird according to new velocity and speed
	move_agent!(bird, model, bird.speed)
end

function bird_marker(b::Bird)
	bird_polygon = Polygon(Point2f[(-0.5, -0.5), (1, 0), (-0.5, 0.5)])
	φ = atan(b.vel[2], b.vel[1]) #+ π/2 + π
	scale(rotate2D(bird_polygon, φ), 2)
end

## Plotting the flock
# hide
function demo()


	# the sliders youre gonna play around with!
	params = Dict(:n_birds => 100:500,
		:visual_distance => 0:10,
		:separation => 0:10,
		:cohere_factor => 0:0.1:10,
		:separate_factor => 0:0.1:10,
		:match_factor => 0:0.1:10)
	#initialize the model 
	model = initialize_model()
	#create the interactive plot with our sliders
	fig, p = abmexploration(model; (agent_step!)=agent_step!, params, am=bird_marker, ac=choosecolor)
	reinit_model_on_reset!(p, fig, initialize_model)
	fig
end
end