/////////////////////
SYRACUSE
/////////////////////

	In this file when a command is written between "" type it without the "" (e.g "make" becomes make).

/////////////////////
INSTALLATION

	It requires Linux.

/////////////////////
COMPILATION

	Type in the console: "main.c -o syracuse"

/////////////////////
EXECUTION
	
	You need to add execution rights to this script :
	"chmod u+x syracuse.bash"

	In the folder containing the executable "syracuse", type the following commmand with options:
	"./script_syracuse.bash"

	Type "./script_syracuse.bash -h" to display the help or read the section HELP at the end of this README to know all the options.

/////////////////////
MISCELLANEOUS

	The name of the executable "syracuse" must not be changed

/////////////////////
HELP:

	NAME
	script_syracuse.bash

SYNOPSIS
	script_syracuse.bash -h
	script_syracuse.bash UMIN MAX

DESCRIPTION
	Generates graphs in the jpeg format corresponding to maximum altitude, flight duration and altitude duration.
	It also generates a resume named "synthese-min-max.txt" that provide minimum, maximum and average values for each one
	UMIN and UMAX are strictly positive integers and UMIN is lesser than UMAX
	UMAX must be an unsigned long int (so it's lesser than 18,446,744,073,709,551,615)

	-h
		display this help and exit.
