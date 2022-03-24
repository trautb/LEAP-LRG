#========================================================================================#
"""
	NBodies

A system of N interacting bodies moving in dim dimensions over time T in res timesteps.

Author: Niall Palfreyman, 24/3/2022.
"""
module NBodies

# Externally callable methods of NBodies
export NBody

#-----------------------------------------------------------------------------------------
# Module types:

"""
	NBody

An NBody system capable of containing multiple (N) bodies that gravitationally interact
with each other.
"""
struct NBody
	N							# Number of bodies
	T							# Duration of simulation
	res							# Timestep resolution
	xi							# Initial positions of bodies
	pi							# Initial momenta of bodies
	m							# Masses of bodies

	"Construct a new NBody"
	function NBody( T=40, resolution=20000)
		# Initialise all fields of the decoding apparatus:
		new(
			0,					# Initially no bodies in the system
			T,					# Duration
			resolution,			# Timestep resolution
			zeros(1,N),			# Initial positions
			zeros(1,N),			# Initial momenta
			zeros(1,N),			# Masses of bodies
		)
	end
end

#-----------------------------------------------------------------------------------------
# Module methods:

"""
	addbody( nbody::NBody, xi, pi, m=1)

Add to the system a new body with initial position and momentum xi, pi, and with mass m.
"""
function addbody( nbody, xi, pi, m=1)
	nbody.xi = [nbody.xi xi]
	nbody.pi = [nbody.pi pi]
	nbody.m  = [nbody.m m]
	nbody.N  += 1
end

"""
	simulate( nbody::NBody)

Run a simulation of the given NBody system over duration divided into res timesteps.
"""
function simulate( nbody)
	dt = nbody.T / nbody.res
	t = 0:dt:nbody.T
	x = zeros(1,nbody.N,nbody.res+1)
	p = zeros(1,nbody.N,nbody.res+1)
	G = 1
	Gmm = repmat(G*nbody.m,[1 1 nbody.N])
	Gmm = Gmm .* permute(Gmm,[1 3 2])
	
	# Relative positions of bodies at positions r:
	relPos = @(r) repmat(permute(r,[1 3 2]),[1 nbody.N 1]) - repmat(r,[1 1 nbody.N])
	
	# Initialisation:
	x[1,:,1] = nbody.xi
	p[1,:,1] = nbody.pi
	
	# Simulation:
	for n = 1:nbody.res
		# Simulate timestep n:
		x[1,:,n+1] = x[1,:,n] + dt * p[1,:,n]./nbody.m
		
		diff = relPos(x(1,:,n))
		absDiff = sqrt(sum(diff.*diff,1))
		invSq = absDiff.^3 + permute(eye(nbody.N),[3 2 1])
		forces = Gmm.*diff ./ invSq
		forces = sum(forces,3)
		p[1,:,n+1] = p[1,:,n] + forces * dt
	end

	(t,x,p)
end

#-----------------------------------------------------------------------------------------
"""
	demo()

Demonstrate simulation of a simple 2-body problem.
"""
function demo()
	nb = NBody( 2.25, 10000)
	nb.addbody( -1, 0)
	nb.addbody( 1, 0)
	
	[t,x] = nb.simulate()
	plot( ...
		t,squeeze(x(1,1,:)),'b', ...
		t,squeeze(x(1,2,:)),'r' ...
	);
end
		
end		# of NBodies