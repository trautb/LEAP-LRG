#========================================================================================#
"""
	Objectives

A collection of displayable objective functions from De Jong and Watson.

Author: Niall Palfreyman, 8/3/2022.
"""
module Objectives

classdef BP301Objective < handle
	%-------------------------------------------------------------
	%BP301Objective: Encapsulates an objective function for GAs.
	%	A BP301Objective instance is a function f: C^n -> R together
	%	with a (by default infinite) domain and dimensionality.
	%-------------------------------------------------------------
	methods
		% Construct a new BP301Objective function instance
		function obj = BP301Objective(fun,dim,dom)
			if (nargin < 3)		% Default domain:
				dom = [-inf inf];
			end;
			if (nargin < 2)		% Default 1-dimensional domain:
				dim = 1;
			end;
			if (nargin < 1)
				fun = 1;				% Use Haupt test function 1
			end;
			if isequal(class(fun),'double')
				% Use one of the suite of test functions:
				if nargin < 2		% Use default dimension:
					[fun,dim,dom] = BP301Objective.testFunction(fun);
				else					% Use requested dimension:
					fun = BP301Objective.testFunction(fun);
				end;
			end;
			
			% Check objective function's domain and dimension:
			if size(dom,2) ~= 2 || ...
					any(dom(:,2) <= dom(:,1))
				disp( 'Domain specification is invalid');
			end;
			if size(dom,1) > 1
				% Note: In this case we discard requested dim:
				dim = size(dom,1);
			else
				dom = repmat(dom,dim,1);
			end;
			
			% If we're here, then dim == size(dom,2):
			obj.myFun = fun;
			obj.myDomain = dom;
			obj.myDim = dim;
		end;	% ... of Constructor
		
		% Dimension of BP301Objective function domain
		function dim = dim(obj)
			dim = obj.myDim;
		end;
		
		% Domain of BP301Objective function
		function dom = domain(obj)
			dom = obj.myDomain;
		end;
		
		% Return vector of n random points in function domain:
		function rnd = rand(obj,n)
			if any(any(abs(obj.myDomain)==inf))
				disp('Cannot sample an infinite domain');
				return;
			end;
			lo = obj.myDomain(:,1);
			dif = obj.myDomain(:,2) - lo;
			rnd = lo(:,ones(1,n)) + ...
				dif(:,ones(1,n)) .* rand(obj.myDim,n);
		end;
		
		% Evaluate BP301Objective function on given domain:
		function image = eval(obj,args)
			image = obj.myFun(args);
		end;
		
		% Depict BP301Objective function over given neighbourhood:
		function depict(obj,dims,centre,radius)
			%-------------------------------------------------------------
			% depict: Depict given dimension(s) of objective function
			%	over Manhattan neighbourhood with given centre and radius.
			%-------------------------------------------------------------
			if nargin < 2
				% Depict up to the first two dimensions:
				dims = 1:min(2,obj.myDim);
			end;
			
			if isempty(dims)
				% Plot a slice through all dimensions of objective:
				dim = obj.myDim;
				inputs = repmat(obj.myDomain(:,1),1,dim+1);
				upbs = repmat(obj.myDomain(:,2),1,dim+1);
				upbLocs = logical([zeros(dim,1) triu(ones(dim,dim))]);
				inputs(upbLocs) = upbs(upbLocs);
				plot( 0:dim, obj.eval( inputs));
				return;
			end;
			
			% dims is from this point on correctly defined.
			if nargin < 3
				if any(any(abs(obj.myDomain)==inf))
					disp('Cannot display an infinite domain');
					return;
				end;
				centre = sum(obj.myDomain,2)/2;
				radius = (obj.myDomain(dims,2)-obj.myDomain(dims,1))/2;
			else
				centre = centre';
				if nargin < 4
					radius = ones(size(dims));
				end;
			end;
			
			% All parameters are now present and correct:
			nGrad = 100;		% Number of gradations in depiction
			nGrad1 = nGrad+1;	% Number of data values in depiction
			glb = max(obj.myDomain(dims,1),(centre(dims)-radius));
			lub = min(obj.myDomain(dims,2),(centre(dims)+radius));
			
			switch numel(dims)
				case 1
					% Use plot for single dimension:
					x = (glb:(lub-glb)/nGrad:lub);
					args = repmat(centre,1,nGrad1);
					args(dims,:) = x;
					plot(x,obj.myFun(args));
				case 2
					% Construct arguments for pcolor:
					[x,y] = meshgrid( ...
						glb(1):(lub(1)-glb(1))/nGrad:lub(1), ...
						glb(2):(lub(2)-glb(2))/nGrad:lub(2));
					args = repmat(centre,[1 nGrad1 nGrad1]);
					args(dims(1),:,:) = x; args(dims(2),:,:) = y;
					field = cellfun( obj.myFun, num2cell(args,[1 2]), ...
						'UniformOutput',false);
					field = cell2mat(field);
					graphic = zeros(nGrad1,nGrad1);
					graphic(:,:) = field(1,:,:);
					surf(x,y,graphic);
					shading interp;
				otherwise
					disp('Cannot depict more than 2 dimensions');
			end;
		end		
	end;
	
	properties (Access = private)
		myFun;			% BP301Objective function handle
		myDomain;		% Domain specification
		myDim;			% Domain dimension
	end;
	
	methods (Static)
		% Suite of standard test functions:
		function [f,dim,dom] = testFunction(n)
			%-------------------------------------------------------------
			% testFunction: Implement suite of standard GA test functions.
			%	f is n-th test function over a default domain.
			%	Functions 1-17 from Haupt & Haupt (2004)
			%	Function 18 from Watson (2004)
			%-------------------------------------------------------------
			switch n
				case 1
					% Minimum: f(0)=1
					f = @(x) abs(x) + cos(x);
					dom = [-20 20];	dim = 1;
				case 2
					% Minimum: f(0)=0
					f = @(x) abs(x) + sin(x);
					dom = [-20 20];	dim = 1;
				case 3
					% Minimum: f(0,0)=1
					f = @(x) sum(x.^2,1);
					dom = [-5 5];		dim = 2;
				case 4
					% Minimum: f(1,1)=0
					f = @(x) sum(100*(x(2:end,:)-x(1:end-1,:).^2).^2 + ...
						(1-x(1:end-1,:)).^2, 1);
					dom = [-1 1];		dim = 2;
				case 5
					% Minimum: f(0^dim)=1
					f = @(x) sum(abs(x) - 10*cos(sqrt(abs(10*x))),1);
					dom = [-10 10];	dim = 2;
				case 6
					% Minimum: f(9.6204)=-100.22
					f = @(x) (x.^2+x).*cos(x);
					dom = [-10 10];	dim = 1;
				case 7
					% Haupt functn 1.1, minimum: f(0.9039,0.8668)=-18.5547
					f = @(x) x(1,:).*sin(4*x(1,:)) + ...
						1.1*x(2,:).*sin(2*x(2,:));
					dom = [0 10];		dim = 2;
				case 8
					% Minimum: f(0.9039,0.8668)=-18.5547
					f = @(x) x(2,:).*sin(4*x(1,:)) + ...
						1.1*x(1,:).*sin(2*x(2,:));
					dom = [0 10];		dim = 2;
				case 9
					% Minimum: varies
					f = @(x) (1:size(x,1))*(x.^4) + randn(1,size(x,2));
					dom = [-2 2];		dim = 2;
				case 10
					% Minimum: f(0,0)=0
					f = @(x) 10*size(x,1) + sum(x.^2-10*cos(2*pi*x),1);
					dom = [-4 4];		dim = 2;
				case 11
					% Minimum: f(0,0)=0
					f = @(x) 1 + sum(x.^2/4000,1) - prod(cos(x),1);
					dom = [-10 10];	dim = 2;
				case 12
					% Minimum: f(1.897,1.006)=-0.5231
					f = @(x) 0.5 + (sin(sqrt(sum(x.^2,1))).^2 - 0.5) ./ ...
						(1 + 0.1*sum(x.^2,1));
					dom = [-5 5];		dim = 2;
				case 13
					% Minimum: f(0,0)=0
					f = @(x) sum(abs(x),1) + ...
						sum(x.^2,1).^0.25 .* ...
						sin(30*(((x(1,:)+0.5).^2+x(2,:).^2).^0.1));
					dom = [-10 10];	dim = 2;
				case 14
					% Minimum: f(1,16606)=-0.3356
					f = @(x) besselj(0,sum(x.^2,1)) + ...
						0.1*sum(abs(1-x),1);
					dom = [-5 5];		dim = 2;
				case 15
					% Minimum: f(-2.7730,-5)=-16.947
					% Note: Haupt's description is ambiguous
					f = @(x) -exp( .2*sqrt(sum((x-1).^2,1)) + ...
						3*(cos(2*x(1,:))+sin(2*x(2,:))));
					dom = [-5 5];		dim = 2;
				case 16
					% Minimum: f(-14.58,-20)=-23.806
					f = @(x) x(1,:).*sin(sqrt(abs(x(1,:)-(x(2,:)+9)))) ...
						-(x(2,:)+9).*sin(sqrt(abs(x(2,:)+0.5*x(1,:)+9)));
					dom = [-20 20];	dim = 2;
				case 17
					% Watson's maximally epistatic function
					% Minimum: ???
					f = @BP301Objective.mepi;
					dom = [0 1];		dim = 128;
				otherwise
					% Test function 1, minimum: f(0)=1
					f = @(x) abs(x) + cos(x);
					dom = [-20 20];	dim = 1;
			end;
			
			end
			
			function y = mepi( x)
				%-------------------------------------------------------------
				%mepi: Watson's maximally epistatic objective function.
				%-------------------------------------------------------------
				[dim,N] = size(x);
				if dim == 1
					y = ones(1,N);
				else
					halfway = floor(dim/2);
					y = dim*(1-prod(+x,1)-prod(1-x,1)) + ...
						BP301Objective.mepi(x(1:halfway,:)) + ...
						BP301Objective.mepi(x(halfway+1:end,:));
				end;
				
				end
						
		% Demo the BP301Objective class:
		function demo()
			% Create new figure:
			figure(1);
			
			% Create and display objective function 1:
			f = @(x) ...
				3*(1-x(1,:)).^2.*exp(-(x(1,:).^2) ...
				- (x(2,:)+1).^2) - 10*(x(1,:)/5 - x(1,:).^3 ...
				- x(2,:).^5).*exp(-x(1,:).^2-x(2,:).^2) ...
				- 1/3*exp(-(x(1,:)+1).^2 - x(2,:).^2);
			obj1 = BP301Objective(f,2);
			subplot(2,1,1);
			obj1.depict(1:2,[0 0],2.9);
			
			% Create and display objective function 2:
			obj2 = BP301Objective(7);
			subplot(2,1,2);
			obj2.depict();
		end;
	end;
end

end		# of Objectives