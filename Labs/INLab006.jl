#========================================================================================#
#	Laboratory 6
#
# Tuples, Pairs, Dict, Symbol, files, Dates, Random numbers and downloading.
# Files and Dates are available in Julia Programming Cookbook
#
# Author: Niall Palfreyman, 13/01/2022
#========================================================================================#
[
	Activity(
		"""
		In this laboratory we introduce several helpful Julia tools that make life a
		little easier: Tuples, Pairs, Dicts, Symbols, Files, DateTimes, Random and downloading.

		A Tuple is an immutable container that can contain several different types. We
		construct Tuples using round brackets, for example:

			my_tuple = (5, 2.718, "Niall")

		What is my_tuple[2]?
		""",
		"my_tuple[2]",
		x -> x==Main.my_tuple[2]
	),
	Activity(
		"""
		You have already seen that size() returns a Tuple. Enter the following code:

			ret_size = size(zeros(3,4))

		What is the value of ret_size[1]? Try changing the value of ret_size[2].
		Finally, what is the type of ret_size? 
		""",
		"typeof(ret_size)",
		x -> x==typeof(size(zeros(3,4)))
	),
	Activity(
		"""
		Tuples are especially useful when we want to define anonymous functions with
		more than one argument:

			map((x,y)->3x+2y,4,5)

		Construct a single line mapping that calculates sin(x*y) for corresponding
		elements in the two ranges x = 1:5 and y = 5:-1:1
		""",
		"map((x,y)->sin(x*y),1:5,5:-1:1)",
		x -> x==map((x,y)->sin(x*y),1:5,5:-1:1)
	),
	Activity(
		"""
		A Pair is a structure that contains two objects - typically a key and its
		entry in a dictionary. We construct a Pair like this:

			my_pair = "Yellow Submarine" => "Beatles"

		Construct my_pair and then find the value of last(my_pair):
		""",
		"",
		x -> x==last("Yellow Submarine" => "Beatles")
	),
	Activity(
		"""
		A Dict(ionary) is a hashed database of Pairs. Dicts are very lightweight, so
		we can easily use them in everyday code. We construct a Dict by passing a
		sequence of Pairs to the constructor:

			my_dict = Dict( "pi" => 3.142, "e" => 2.718)

		Construct my_dict, and notice that the Pairs are not necessarily in the same
		order that you entered them. Now look up the value of "pi" in my_dict:
		""",
		"my_dict[\"pi\"]",
		x -> x==3.142
	),
	Activity(
		"""
		We can find out whether our Dict contains the key "e" by using the keys() function:

			"e" in keys(my_dict)

		Delete the entry for "e" from my_dict using the delete!() function. What word do
		you now see in red if you enter my_dict["e"]?
		""",
		"delete!(my_dict,\"e\")",
		x -> x=="ERROR"
	),
	Activity(
		"""
		Now add two extra entries to my_dict:

			my_dict["root2"] = 1.414
			my_dict["epsilon0"] = 8.854e-12

		What is the result of calling haskey(my_dict,"root2")?
		""",
		"",
		x -> x==true
	),
	Activity(
		"""
		We have already met Symbols - they define components of the Julia language, and
		we use them to extend the language with new components. We construct Symbols
		using the colon ':'. Enter the following lines:

			a,b = 2,3
			expr = :(a+b)
			dump(expr)

		What is the value of expr.args?
		""",
		"",
		x -> x==Main.expr.args
	),
	Activity(
		"""
		You can see that the arguments of expr are Symbols waiting to be evaluated. Try:

			typeof(expr.args[2])

		What do you get if you enter string(expr)?
		""",
		"",
		x -> occursin("a+b",replace(x," "=>""))
	),
	Activity(
		"""
		Symbols and Strings are very similar to each other. You will see that graphics
		functions often use Symbols to define special switches such as :red or :filled.
		
		In fact, a Symbol is a String that has been prepared for being evaluated.
		What do you get if you apply the function eval() to expr?
		""",
		"eval(expr)",
		x -> x==5
	),
	Activity(
		"""
		We use the "splat" operator (...) to convert a collection into a set of
		arguments for a function. Define this function and test it with a few numbers:
		
			my_function(x,y,z) = x * (y+z)
		
		Now define this vector: v = [2,3,4]. Suppose we want to use the three numbers
		in v as arguments for my_function. First try it like this: my_function(v), and
		see what happens ...

		It didn't work, did it? Now tell me what you get when you enter this:

			my_function(v...)
		""",
		"",
		x -> x==14
	),
	Activity(
		"""
		Files are an important part of everyday data science. First of all, we need to
		be able to find files in the background filesystem. Enter: pwd() at the Julia
		prompt. This stands for Present Working Directory ...

		What you get back is the path of the current folder. Now enter: readdir() ...

		This gives you a list of filenames in the current folder. Choose a filname in
		this list - for example maybe "filename.ext". Ask whether your file is in the
		current folder. What answer do you get back?
		""",
		"\"filename.ext\" in readdir()",
		x -> x==true
	),
	Activity(
		"""
		pwd() gives us the path of the current folder, and readdir() gives us a vector
		of filenames in it. We can put these together using joinpath(). Find out the
		answer returned by the following function call:

			isfile(joinpath(pwd(),"filename.ext"))

		where filename.ext is the file you previously found in the current directory.
		""",
		"Investigate the value returned by the joinpath() call",
		x -> true
	),
	Activity(
		"""
		Now let's create a new file. The following command creates a file named
		"my_data.txt", and sets up a FILESTREAM named "file" for "w"riting to it:

			file = open("my_data.txt","w")

		Now write some information to the file:

			write( file, "This is my file\nIt belongs to me!\n")

		The value returned by write() is the number of bytes you have written to the
		file. We can also us the print() and println() functions, for example:

			println( file, "It really does!")

		Finally, close() file and tell me the result of isfile("my_data.txt"):
		""",
		"close(file)",
		x -> x==true
	),
	Activity(
		"""
		Congratulations! You have created your first file! Now let's trying
		r(eading) from the file:

			file = open("my_data.txt","r")

		Now enter: readline(file) several times to read the lines of the file.
		Once you have read all the lines, the file is in an end-of-file state:

			eof(file)

		What value does readline() return if you continue to read lines after
		the end-of-file?
		""",
		"readline(file)",
		x -> isempty(x)
	),
	Activity(
		"""
		Now close() the file, then reopen it again to start reading at the
		beginning of the file. We can read all lines of the file at once.
		What is the type of the structure returned by the following code?

			file = open("my_data.txt","r")
			readlines( file)
		""",
		"",
		x -> x <: Vector
	),
	Activity(
		"""
		If our file contained binary data, it would not be possible to read
		it in separate lines - in this case we use the read() function.

		Rewind the file to the beginning using: seekstart(file).
		Enter read(file) to see the characters in the file, and tell me the
		first character:
		""",
		"0x54: Scroll the Julia console back up to see the beginning",
		x -> x==0x54
	),
	Activity(
		"""
		Well, that wasn't very pleasant, was it, with all those characters
		screaming across the screen? Let's do it in a more civilised way this time...

		Rewind the file to the beginning using seekstart().
		Now enter:

			data = read(file);

		Did you remember to write ';' at the end of the line? If not, you
		had the "screaming characters" problem. ';' at the end of a line
		stops the return value being written to the console. Now tell me
		the value of the fifth element of data:
		""",
		"data[5]",
		x -> x==0x20
	),
	Activity(
		"""
		This hex code represents a character. Can you convert the code to
		a character?
		""",
		"Char(data[5])",
		x -> x==' '
	),
	Activity(
		"""
		We can even convert the data entirely to a String like this:

			str = String(data)

		However, this conversion uses up the data values. What value is
		now returned by the function call isempty(data)?
		""",
		"",
		x -> x==true
	),
	Activity(
		"""
		Finally, we must always close a filestream after we have finished
		with it: close(file).
		Also, we should clean up afterwards, so now remove the file we have
		created using rm("my_data.txt"), and tell me the return type of rm():
		""",
		"First call rm(), and then ask: typeof(ans)",
		x -> x==Nothing
	),
	Activity(
		"""
		Now we investigate DateTimes in Julia. Support for date and time
		handling is provided by the Dates package, which we must first load:

			using Dates

		We can access the current time using the now() function:

			datim = Dates.now()

		What is the type of datim?
		""",
		"",
		x -> x==Main.DateTime
	),
	Activity(
		"""
		To create a new date, we pass year, month and day to the constructor:

			Date( 1996, 7, 16)
			Date( 2020, 6)

		What Date value is constructed by the call Date(2022)?
		""",
		"",
		x -> x==Main.Date(2022)
	),
	Activity(
		"""
		We can also create times. Use the minute() function to find the number
		of minutes past the hour in this time:

			DateTime(1992,10,13,6,18)
		""",
		"minute(ans)",
		x -> x==Main.minute(Main.DateTime(1992,10,13,6,18))
	),
	Activity(
		"""
		The module Dates also makes available Periods of time. Use the subtypes()
		function to find the subtypes of Period and also the subtypes of these
		subtypes. How many subtypes does the type TimePeriod have?
		""",
		"subtypes(TimePeriod)",
		x -> x==length(Main.subtypes(Main.TimePeriod))
	),
	Activity(
		"""
		However, we don't just want to construct dates and times - we usually
		want to PARSE (i.e., analyse) them. We can construct a Date from a
		String by passing a DateTime format argument:

			Date("19760915","yyyymmdd")

		For DateTimes, this format gets a little more complicated, so you may
		wish to define your own format:

			format = DateFormat("HH:MM, dd.mm.yyyy")

		Use this format to parse the DateTime "06:18, 13.10.1992". What
		character separates the date from the time in the result?
		""",
		"",
		x -> x=='T'
	),
	Activity(
		"""
		DateTimes contains many useful functions that you can look up at
		docs.julialang.org. For example, use the function dayname() to find
		out the day on which you were born ...

		When you've finished experimenting, just enter reply() to move on
		to the next activity.
		""",
		"",
		x -> true
	),
	Activity(
		"""
		Find out your age in days by subtracting your birthday Date from
		today(), then move on with reply():
		""",
		"",
		x -> true
	),
	Activity(
		"""
		Form a list of the past 8 days by collecting this Range into a Vector:

			today()-Week(1):Day(1):today()
		""",
		"",
		x -> x==Main.eval(:(collect((today()-Week(1)):Day(1):today())))
	),
	Activity(
		"""
		Next we'll look at a very important tool of data science: Random numbers.
		First load the functions that we'll be using:

			using Random: rand, randn, seed!

		By itself, the rand() function returns a pseudo-random Float64 number in the
		half-open interval [0.0,1.0). Try this now.
		
		If you pass rand() a range as its first argument, it returns a random element
		from that range. If you pass it a tuple of integers, it returns an array with
		the size specified by those integers. Use rand() to produce a (2,3) array of
		integer values between -1 and +1:
		""",
		"rand(Range,Size)",
		x -> (typeof(x) <: Matrix{Int}) && size(x) == (2,3) && all(map(y->in(y,-1:1),x))
	),
	Activity(
		"""
		randn() works just the same as rand(), but returns normally distributed values
		with mean 0.0 and standard deviation 1.0. Create a (5,7) array of such normally
		distributed numbers:
		""",
		"",
		x -> size(x) == (5,7) && sum(x)/length(x) < 0.5
	),
	Activity(
		"""
		When we perform simulations with random numbers, we never know in advance how
		our program will behave. On the one hand, this is certainly good, because many
		biological processes are essentially random. On the other hand, it can be very
		frustrating if you observe some special problem or phenomenon, because you may
		never again be able to reproduce that special situation. Because of this, we
		need to be able to make random-number generation REPRODUCIBLE. We do this by
		SEEDING the random-number generator (rng).

		To do this, we use the function seed!() at the beginning of our program to make
		sure all random numbers follow an identical pattern across separate runs of the
		program. Run the following code several times, then tell me what result you get:

			seed!(123); rand(5)
		""",
		"",
		x -> x==(Main.seed!(123); Main.rand(5))
	),
	Activity(
		"""
		OK, and fi-inally at the end of this very long (phew!) laboratory, we look
		briefly at how to download resources from the internet. First, we load the
		download() function from the package Downloads:

			using Downloads: download

		Next we define the url of our resource:
		
			url = "https://raw.githubusercontent.com/NiallPalfreyman/Ingolstadt.jl/main/src/Ingolstadt.jl"

		Next, we download this page into a local file:

			file = download(url)
		
		Use readlines() (don't forget the ';'!) to discover the Date on which Niall
		Palfreyman started writing the Ingolstadt project:
		""",
		"data = readlines(file);",
		x -> x == Main.Date("7/12/2021","d/mm/yyyy")
	),
	Activity(
		"""
		OK, that's the end of this laboratory. The resource we have downloaded is my
		source code - feel free to explore it and use it as much as you like. Bye! :-)
		""",
		"",
		x -> true
	),
]