# =========================================================================================
### Define different agent types
# =========================================================================================
"""
	BasicGAAgent

The basic agent in the simulation
"""
@agent BasicGAAgent{BasicGAAlleles} GridAgent{2} begin
	genome::Vector{BasicGAAlleles}
	currentScore::Number
end

"""
	ExploratoryGAAgent

The exploratory agent in the simulation
"""
@agent ExploratoryGAAgent{ExploratoryGAAlleles} GridAgent{2} begin
	genome::Vector{ExploratoryGAAlleles}
	currentScore::Number
end