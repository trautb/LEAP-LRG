#========================================================================================#
#	Laboratory 5
#
# Exploratory data analysis
#
# Author: Niall Palfreyman, 04/01/2022
#========================================================================================#
[
	Activity(
		"""
		In this laboratory we use Exploratory Data Analysis (EDA) and the Julia Dataframes
		package to explore one of the over 750 industry standard statistical RDatasets.

		Since we haven't used the RDatasets package before, we must first add it to our Julia
		system. To do this, type ']' at the Julia prompt - this starts Julia's Package Manager,
		which you can exit at any time by typing <Backspace>. Within the Package Manager, enter:
		
		add RDatasets

		This will download and compile around 200 packages that are relevant to the RDatasets
		package (this may take a couple of minutes). When it has finished, exit Package Manager,
		then enter:

		using RDatasets
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
		samples from each of three iris flower species (Iris setosa, Iris virginica, and Iris
		versicolor). To load the Iris dataset, enter the following:

		iris = dataset("datasets","iris")

		What is the SepalLength of the first setosa sample?
		""",
		"",
		x -> x==5.1
	),
	Activity(
		"""
		""",
		"",
		x -> x==0
	),
	Activity(
		"""
		""",
		"",
		x -> x==0
	),
	Activity(
		"""
		""",
		"",
		x -> x==0
	),
	Activity(
		"""
		""",
		"",
		x -> x==0
	),
	Activity(
		"""
		""",
		"",
		x -> x==0
	),
	Activity(
		"""
		""",
		"",
		x -> x==0
	),
	Activity(
		"""
		""",
		"",
		x -> x==0
	),
	Activity(
		"""
		""",
		"",
		x -> x==0
	),
	Activity(
		"""
		""",
		"",
		x -> x==0
	),
	Activity(
		"""
		""",
		"",
		x -> x==0
	),
	Activity(
		"""
		""",
		"",
		x -> x==0
	),
	Activity(
		"""
		""",
		"",
		x -> x==0
	),
	Activity(
		"""
		""",
		"",
		x -> x==0
	),
	Activity(
		"""
		""",
		"",
		x -> x==0
	),
	Activity(
		"""
		""",
		"",
		x -> x==0
	),
	Activity(
		"""
		""",
		"",
		x -> x==0
	),
	Activity(
		"""
		""",
		"",
		x -> x==0
	),
	Activity(
		"""
		""",
		"",
		x -> x==0
	),
	Activity(
		"""
		""",
		"",
		x -> x==0
	),
	Activity(
		"""
		""",
		"",
		x -> x==0
	),
	Activity(
		"""
		""",
		"",
		x -> x==0
	),
	Activity(
		"""
		""",
		"",
		x -> x==0
	),
	Activity(
		"""
		""",
		"",
		x -> x==0
	),
	Activity(
		"""
		""",
		"",
		x -> x==0
	),
	Activity(
		"""
		""",
		"",
		x -> x==0
	),
	Activity(
		"""
		""",
		"",
		x -> x==0
	),
	Activity(
		"""
		""",
		"",
		x -> x==0
	),
	Activity(
		"""
		""",
		"",
		x -> x==0
	),
	Activity(
		"""
		""",
		"",
		x -> x==0
	),
	Activity(
		"""
		""",
		"",
		x -> x==0
	),
	Activity(
		"""
		""",
		"",
		x -> x==0
	),
	Activity(
		"""
		""",
		"",
		x -> x==0
	),
	Activity(
		"""
		""",
		"",
		x -> x==0
	),
	Activity(
		"""
		""",
		"",
		x -> x==0
	),
]