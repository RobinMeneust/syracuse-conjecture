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