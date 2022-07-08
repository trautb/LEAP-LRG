# =========================================================================================
### agents.jl: Defines different agent types
# =========================================================================================
"""
	BasicGAAgent

The agent for a basic genetic algorithm (BasicGA) simulation. It represents an organism, which tries
to minimize an objective function via pure genetic search.
"""
@agent BasicGAAgent{BasicGAAlleles} GridAgent{2} begin
	genome::Vector{BasicGAAlleles}			# Genome of the organism
	score::Number							# Current objective value
end

# -----------------------------------------------------------------------------------------
"""
	ExploratoryGAAgent

The agent for an exploratory algorithm (ExploratoryGA) simulation. It represents an organism, which 
tries to minimize an objective function via genetic search in combination with exploration.
"""
@agent ExploratoryGAAgent{ExploratoryGAAlleles} GridAgent{2} begin
	genome::Vector{ExploratoryGAAlleles} 	# Genome of the organism
	score::Number							# Current objective value
end