#========================================================================================#
#	Laboratory 6
#
# Data visualisation
#
# Author: Niall Palfreyman, 27/01/2022
#========================================================================================#
[
	Activity(
		"""
		In this laboratory we learn how to use Julia's Makie plotting package to create
		publication-quality graphics for data visualisation. Makie is the front-end for
		several different backend graphics packages - for example, Cairo, GL and WebGL. We
		shall focus here on Cairo. First, we add and load the CairoMakie package. You already
		know how to do this using the Julia PackageManager, but like everything in Julia, we
		can also do it ourselves from within a program using method calls:

		using Pkg
		Pkg.add("CairoMakie")
		using CairoMakie

		This will take a while - as will also your first graphics call. Julia uses JiT (Just-
		in-time) compilation, so the first time you call a method, it will always take longer
		than the second time you call it. Enter the following command, then tell me the type of
		your return value fig:

		fig = scatterlines(0:10,(0:10).^2);
		""",
		"Enter the command exactly as I have done here",
		x -> x==Main.Makie.FigureAxisPlot
	),
	Activity(
		"""
		If you enter fig at the Julia prompt, you will see that a Makie figure contains a whole
		bunch of fields necessary for producing a graphic image. We will look at this image by
		saving it to a pdf file, but first we need to study the filesystem underlying the Julia
		REPL. Enter now the following command:

		pwd()

		The returned string tells you the path of your Present Working Directory. It should look
		something like this:

		"C:\\\\Users\\\\hswt136nia\\\\...\\\\Projects\\\\Ingolstadt\\\\src"

		In the chapter "Filesystem" of the Julia user manual you will find many functions for
		exploring the filesystem - we shall just use one or two here. Look at the return value of
		the following command and tell me its type:

		readdir()
		""",
		"It should be a Vector of filenames in your PWD",
		x -> x <: Vector{String}
	),
	Activity(
		"""
		We want to create a Temp directory to save our files into. First, check whether there
		already exists such a directory in the PWD by entering:

		"Temp" in readdir()

		If the result is false, create the Temp subdirectory by entering:

		mkdir("Temp")

		What happens if you use this command when Temp already exists?
		""",
		"",
		x -> occursin( "error", lowercase(x)) || occursin( "exist", lowercase(x))
	),
	Activity(
		"""
		Now change directory into your new Temp directory, then check that you've changed PWD:

		cd("Temp")
		pwd()

		Now we're ready to save our Makie figure. Enter the following command, go and look at
		the resulting file using Adobe Acrobat, then come back here and tell me the highest
		number on the vertical axis:

		save("myfig.png", fig)
		""",
		"",
		x -> x==100
	),
	Activity(
		"""
		Didn't it look pretty? :) Wouldn't it be nice to view the graphic from within the Julia
		REPL? The REPL is a very basic environment that cannot display graphics, but we can easily
		include this functionality by adding and loading the package ElectronDisplay. When you have
		done this, just enter fig at the Julia prompt and ElectronDisplay will automatically
		display() your image.

		What is the type of the return value from this display?
		""",
		"",
		x -> x <: Main.Makie.FigureAxisPlot
	),
	Activity(
		"""
		Our figure is still a little primitive - let's customise its attributes. First notice
		that fig has a structure that includes a figure, an axis and a plot object:

		fg,ax,plt = fig;

		Check out the attributes field of plt to find out how many attributes it has:
		""",
		"",
		x -> x >= 15
	),
	Activity(
		"""
		We can ask for help on any function in the REPL by using the help() function. Try:
		
		help(lines)

		and then tell me how many different ways there are of calling the lines() function:
		""",
		"The signature of a function is the pattern of arguments that defines which method to call",
		x -> x==3
	),
	Activity(
		"""
		OK, now let's get fancy. We don't always want the scatter points on our plot, so we'll try
		out the lines() function. Also, it would be nice to plot something a little more exciting,
		like maybe the Hill function. The Hill function describes the activation and inhibition of
		DNA expression in biological cells by a transcription factor (TF):

		function hill( tf, K::Real=2, n::Real=1)
			abs_n = abs(n)
			if abs_n!=1 K = K^abs_n; tf = tf.^abs_n end
			n>=0 ? tf./(K.+tf) : K./(K.+tf)
		end
		trfactor = 0:20
		lines(trfactor,hill(trfactor))

		We can brighten up this figure by adding some interesting line attributes:

		lines( trfactor, hill(trfactor); color=:blue, linewidth=3, linestyle=:dash)
		
		The ; symbol marks the beginning of keyword arguments of a function. Experiment with this
		plot by changing the keyword arguments of lines(). What argument value displays a line
		consisting of a sequence of two dots and a dash (-..-..-..-)?
		""",
		"Search for keyword arguments on the site: https://makie.juliaplots.org/",
		x -> x==:dashdotdot
	),
	Activity(
		"""
		The lines() function returns a Plot object: the line that is to be plotted. This line is
		positioned within a set of axes: an Axis object. We can design the structure of this Axis
		object by adding an Axis specification to lines():
		
		lines( trfactor, hill(trfactor,2,1); color=:blue, label="activation",
			linewidth=3, linestyle=:dash,
			axis=(;
				xlabel="TF concentration", ylabel="Expression rate",
				title="Transcription regulation",
				xgridstyle=:dash, ygridstyle=:dash
			)
		)

		Notice carefully how I have used indentation to make it clear where each structure or
		function begins and ends. It's not easy to do this in the REPL, but soon we will be writing
		our own code, so it's good to practise making our code easily readable by other programmers.

		Experiment now with the axis parameters ...
		""",
		"",
		x -> true
	),
	Activity(
		"""
		This Axis object is then displayed within a Figure object. We can design the appearance of
		this figure by adding a Figure specification to lines():

		lines( trfactor, hill(trfactor); color=:blue, label="activation",
			linewidth=3, linestyle=:dash,
			axis=(;
				xlabel="TF concentration", ylabel="Expression rate",
				title="Transcription regulation",
				xgridstyle=:dash, ygridstyle=:dash
			),
			figure=(;
				figure_padding=5, resolution=(600,400), font="sans",
				backgroundcolor=:green, fontsize=20
			)
		)

		Experiment now with the figure parameters ...
		""",
		"",
		x -> true
	),
	Activity(
		"""
		Once we have set up a Plot object inside an Axis, inside a Figure, we can add extra Plot
		objects using bang! methods that change the current state of an object, for example:

		scatterlines!( trfactor, hill(trfactor,2,-1); color=:red, label="repression", linewidth=3)
		axislegend( "Legend"; position=:rc)

		Once we have done this, we can redisplay the current figure like this:

		current_figure()
		
		Take a look at the point where the curves of the two Hill-functions cross. You can see that
		this TF concentration correspondes to the value of K that we pass to the Hill function.
		Check that this is generally true, and tell me what value of Expression rate corresponds
		in general to the TF concentration value K:
		""",
		"Create a new graphic, and set the new value of K in BOTH calls to hill()",
		x -> x==0.5
	),
	Activity(
		"""
		Let's use our new-found knowledge of plotting to display a bubble-plot:

		data = randn(50,3)
		figr, ax, pltobj = scatter( data[:,1], data[:,2];
			color=data[:,3], label="Bubbles", colormap=:plasma, markersize=15*abs.(data[:,3]),
			axis=(; aspect=DataAspect()),
			figure=(; resolution=(600,400))
		)
		limits!(-3,3,-3,3)
		Legend( fig[1,2], ax, valign=:top)
		Colorbar( fig[1,2], pltobj, height=Relative(3/4))
		figr

		Do you like my pretty bubble-plot?
		""",
		"I'm very insecure: I won't let you go on until you say you like my art!",
		x -> occursin("yes",lowercase(x))
	),
	Activity(
		"""
		As you see, to create a nice graphic, we often need to build it up in several steps, so it
		is a idea to collect these steps together inside a single function. For example, suppose
		we want to display several different 2-d functions as heatmaps - we might do like this:

		function prettyheatmap( f::Function)
			figure = (; resolution=(600,400), font="CMU Serif")
			axis = (; xlabel="x", ylabel="y", aspect=DataAspect())
			xs = range(-2, 2, length = 25)
			ys = range(-2, 2, length = 25)
			zs = [f(x,y) for x in xs, y in ys]

			global fig, ax, pltobj = heatmap( xs, ys, zs, axis=axis, figure=figure)
			Colorbar( fig[1,2], pltobj, label="A colour bar")
			fig
		end

		Now call prettyheatmap() as follows, then tell me how many yellow rings you see:

		prettyheatmap( (x,y) -> cos(5*hypot(x,y)) )
		""",
		"Just count the complete rings - not the circle",
		x -> x==2
	),
	Activity(
		"""
		Now that we have wrapped our plotting code inside the function prettyheatmap(), we can
		easily reuse this encapsulated code to display a completely different function:
		
		mountains(x,y) =
			3 * (1-x)^2 *				exp(-(x^2+(y+1)^2))
			-(1/3) *					exp(-((x+1)^2 + y^2))
			-10 * (x/5 - x^3 - y^5) *	exp(-(x^2+y^2))
		prettyheatmap( mountains)

		How many mountains can you see?
		""",
		"Use the colour bar to count the number of patches where z > 0",
		x -> x==3
	),
	Activity(
		"""
		You see how useful it is to encapsulate (i.e.: hide) code? As soon as we have hidden the
		complicated graphics code inside the function myheatmap(), we can easily reuse this
		encapsulated code, by simply passing to it the name of the function we wish to plot:

		Encapsulation is THE CENTRAL tool for abstraction in modern computer languages!
		
		However, encapsulation can get broken! Before we move on to the next laboratory, I want
		you to notice something important. Do you remember our graph of the quadratic function
		y=x^2 that we saved in a file at the beginning of this laboratory? If you remember, we
		stored this graphic in a global variable fig, so we should be able to look at it again
		now, yes?
		
		OK, so please now display the quadratic graph contained in the global variable fig, and
		then, without doing anything else, move on to the next activity in this laboratory:

		fig
		""",
		"Your result may puzzle you, but please just move on to the next activity",
		x -> true
	),
	Activity(
		"""
		You should have found that the variable fig no longer contains the quadratic graph, but
		instead contains our most recent graph of the mountains() function.

		I want you to think now about this question: Why has the value of fig changed, and what
		single word can you delete in this laboratory to fix this problem? Don't worry if you
		can't immediately work it out: we will return to this important issue of encapsulation
		in laboratory 7.
		""",
		"",
		x -> true
	),
]