#========================================================================================#
#	Laboratory 10
#
# Exploratory data analysis, datasets and Dataframes.
#
# Author: Niall Palfreyman, 04/01/2022
#========================================================================================#
[
	Activity(
		"""
		In this laboratory we use Exploratory Data Analysis (EDA) and the Julia DataFrames
		package to explore one of the over 750 industry standard statistical RDatasets.

		Since we haven't used the RDatasets package before, we must first add it to our Julia
		system. To do this, type ']' at the Julia prompt - this starts Julia's Package Manager,
		which you can exit at any time by typing <Backspace>. Within the Package Manager, enter:
		
		add RDatasets

		This will download and compile around 200 packages that are relevant to the RDatasets
		package (this may take a couple of minutes). When it has finished, exit Package Manager,
		then enter:

		using RDatasets						# Takes a few seconds ...
		RDatasets.datasets()

		How many Rows are in the "affairs" dataset?
		""",
		"\"affairs\" is the first dataset in the list of datasets that datasets() prints out.",
		x -> x==601
	),
	Activity(
		"""
		OK, now we've got RDatasets up and running, we'll look specifically at the Iris dataset
		compiled by Edgar Anderson and Ronald Fisher in the early days of genetics research in
		1936. This dataset contains the length and width (in cm) of the sepals and petals of 50
		samples from each of several iris flower species. Enter this code to load the Iris dataset:

		iris = dataset("datasets","iris")

		What is the SepalLength of the first specimen in iris?
		""",
		"This is the specimen in Row 1",
		x -> x==5.1
	),
	Activity(
		"""
		The Iris dataset is an object iris of type DataFrame: a table of rows and columns. Each
		row represents a single specimen, and each column represents an attribute field of that
		specimen. To view the fields of the Iris dataset, enter names(iris). How many fields
		does iris have?
		""",
		"",
		x -> x==5
	),
	Activity(
		"""
		What is the size() of the dataset?
		""",
		"size(iris)",
		x -> x==size(Main.iris)
	),
	Activity(
		"""
		We can view the first five rows of iris using the usual array indexing with square
		brackets []:

		iris[1:5,:]

		Report back to me the last 5 rows of the Iris dataset:
		""",
		"iris[end-4:end,:]",
		x -> x==Main.iris[end-4:end,:]
	),
	Activity(
		"""
		We've seen that the first rows of iris concern the species setosa, and the last rows
		concern the species virginica. What other species does iris contain. To find out, we
		want to group the dataset by Species using the command:
		
		species_groups = groupby(iris,"Species")

		How many groups are contained in this grouping of the data?
		""",
		"size(species_groups)",
		x -> x==3
	),
	Activity(
		"""
		OK, so we've seen that the first of three Species groups contains "iris setosa" specimens,
		and the last Species group contains "iris virginica" specimens. To inspect all three
		Species groups, we will combine specimens from each group into a single row:

		combine(species_groups,nrow)

		What is the name of the second iris species?
		""",
		"",
		x -> occursin(lowercase(x),"versicolor")
	),
	Activity(
		"""
		Don't worry if you don't yet understand how to use the combine() function - we'll soon
		find out! For now, we'd like to understand the Iris dataset a little better. A good
		first step is to describe() the dataset - this provides an overview of each attribute
		column in the table. What is the median petal length of all 150 iris specimens?
		""",
		"describe(iris)",
		x -> x==4.35
	),
	Activity(
		"""
		We can also extend the describe() function using additional descriptors such as the
		25th percentile (:q25) or the standard deviation (:std). Which iris attribute has the
		greatest standard deviation?
		""",
		"describe(iris,:std)",
		x -> x=="PetalLength"
	),
	Activity(
		"""
		We can also calculate these values ourselves by loading and applying the functions
		in Julia's Statistics package:

		using Statistics
		std(iris[:,"PetalLength"])

		What is the median sepal length?
		""",
		"median(iris[:,\"SepalLength\"])",
		x -> x==5.8
	),
	Activity(
		"""
		Let's investigate the covariance attributes in the Iris database. Enter this code:

		attributes = names(iris)[1:end-1]				# Leave out the non-numeric Species
		for x in attributes, y in attributes
			if x > y
				println( "\$x \t \$y \t \$(cov(iris[:,x],iris[:,y]))")
			end
		end

		Look at the results: Unsurprisingly, PetalWidth covaries with PetalLength, but
		SepalLength covaries with both PetalLength and PetalWidth. With which of these
		does SepalLength covary least strongly?
		""",
		"",
		x -> x=="PetalWidth"
	),
	Activity(
		"""
		This is what we might expect - after all, there seems no particular reason why SepalLength
		should covary strongly PetalWidth. But wait! Covariance is a measure that depends on the
		absolute size of the variables! Of PetalLength and PetalWidth, which has the greater
		mean value?
		""",
		"mean(iris[:,\"PetalLength\"]",
		x -> x=="PetalLength"
	),
	Activity(
		"""
		Hm. This is tricky. SepalLength covaries with PetalLength more strongly than with
		PetalWidth, however it may be that the smaller covariance with PetalWidth arises simply
		from the fact that PetalWidth values are much smaller than PetalLength. We can solve this
		question using correlation instead of covariance, because correlation is a relative
		measure rather than an absolute one.
		
		Write code to compare the two correlation values for SepalLength-PetalLength and for
		SepalLength-PetalWidth. Then find out the percentage difference between these two
		values:
		""",
		"100 * (cor(SL,PL)-cor(SL,PW))/cor(SL,PL)",
		x -> abs(x-6.173) < 0.1
	),
	Activity(
		"""
		We see that the correlation of PetalWidth is definitely major - almost as large as the
		correlation PetalLength to SepalLength. What biological function of sepals might explain
		why SepalLength correlates so highly with PetalWidth?
		""",
		"Both length and width of petals increases the bud volume that sepals must enclose.",
		x -> true
	),
	Activity(
		"""
		We can use the columns of iris as ranges for generating random values, for example:
		
		rand(iris[:,"SepalLength"])

		Create a Vector containing a random sample of 21 PetalWidths:
		""",
		"rand(range,10)",
		x -> length(x)==21 && all(map(x) do pw in(pw,Main.iris[:,"PetalWidth"]) end)
	),
	Activity(
		"""
		Let's create our own dataframe of the Group I chemical elements. It is a bad idea to
		clutter our global namespace with lots of trivial names, so we'll create the dataframe
		inside a function using local names:
		
		function group1()
			symbol = ["Li","Na","K","Rb","Cs","Fr"]
			protons = [3,11,19,37,55,87]
			nucleons = [7,23,39,85,133,223]
			electronegativity = [1.0,0.9,0.8,0.8,0.7,0.7]
			DataFrame(; symbol, protons, nucleons, electronegativity)
		end

		You may first need to add the DataFrames package and load it with the keyword "using".
		Now enter the function group1(), use it to create a dataframe named grp1, then extract
		from grp1 the subtable consisting of the 3rd and 4th rows:
		""",
		"",
		x -> size(x)==(2,4) && x[1:2,"symbol"] == ["K","Rb"]
	),
	Activity(
		"""
		Finally, we'll learn to save and load dataframes to and from a file. First we'll do it
		simply, using comma-separated variable (CSV) files. Add and load the CSV package, then
		write the group1 dataframe to a CSV file:

		CSV.write( "group1.csv", group1())

		Now give me the result of reading the csv file:

		str = read("group1.csv",String);
		""",
		"",
		x -> x[43:44] == "Li"
	),
	Activity(
		"""
		Sometimes we want to write to other file formats, such as Excel files, and Julia offers
		us a range of packages such as XLSX for doing this. However, the advantage of csv files
		for small projects is that we can read them into text strings and with a text editor.

		We can also read our csv file as a DataFrame. Give me the following dataframe:

		CSV.read("group1.csv",DataFrame)
		""",
		"",
		x -> typeof(x)==Main.DataFrame && size(x)==(6,4)
	),
]