#!/bin/bash

#############################
#   FUNCTIONS
#############################

# Function used to get the approximated value of the decimal logarithm of the given parameter in scientific notation (e.g 5.2e+8)
decimalLogarithmApprox(){
    echo "${1::1}e+$((${#1} - 1))"
}

displayHelp(){
    echo -e "NAME\n\tscript_syracuse.bash\n\nSYNOPSIS\n\tscript_syracuse.bash -h"
    echo -e "\tscript_syracuse.bash UMIN MAX\n\nDESCRIPTION"
    echo -e "\tGenerates graphs in the jpeg format corresponding to maximum altitude, flight duration and altitude duration."
    echo -e "\tIt also generates a resume named synthese-min-max.txt that provide minimum, maximum and average values for each one"
    echo -e "\tUMIN and UMAX are strictly positive integers and UMIN is lesser than UMAX"
    echo -e "\tUMAX must be lesser than 1,000,000,000,000,000\n\n\t-h\n\t\tdisplay this help and exit.\n"
}

# Check if a directory is available. If it's a file the nwe have to delete it before and if it doesn't exist we create it
checkDirAvailability(){
    if ! [ -d "$1" ] 
    then
        if [ -e "$1" ]
        then
            echo -e "ERROR: you have to delete the file '$1' before running this script\n"
            exit 1
        else
            mkdir "$1"
        fi
    fi
}

# Check if a the given executable exist. If it doesn't then we ask if the user want to create it
checkExecutableAvailability(){
    if ! [ -e "$1" ]
    then
        read -p "The executable syracuse doesn't exist and is required. Do you want to create it ? (y/n)" answer
        if [ "$answer" = "y" ]
        then
            gcc main.c -o syracuse
            if [ $? -eq 0 ]
            then
                echo "syracuse was successfully created"
            fi
        else
            echo -e "ERROR: 'syracuse' is required. Please read README.txt and follow the instructions in the installation part\n"
            exit 1
        fi
    elif ! [ -x "syracuse" ]
    then
        echo -e "ERROR: 'syracuse' is not an executable. Please read README.txt and follow the instructions in the installation part\n"
        exit 1
    fi
}

# Get a value in the given file, return it save it in a file generated from the first parameter 'u0'
# $1: u0     $2: line starting from the last three lines    $3: fileOutput
getDataFromDatFiles(){
    local current_value="$(tail -n 3 output_dir/f${1}.dat | sed -n "${2}p" | cut -d'=' -f2)"
    echo "$1 $current_value" >> "$3"
    echo $current_value
}

max(){
    if [ $1 -gt $2 ]
    then
        echo $1
    else
        echo $2
    fi
}

min(){
    if [ $1 -lt $2 ]
    then
        echo $1
    else
        echo $2
    fi
}

#Adapt the yrange if there is only one value in the file and thus in the created graph
#$1 : fileInput $2 : max value
adaptYRangeIfSingleValue(){
    if [ $(uniq $1 | wc -l) -eq 1 ]
    then
        # yrange is written in scientific notation when it's a large number
        if [ ${#2} -gt 8 ]
        then
            echo "; set yrange [0:$(decimalLogarithmApprox $(($2 * 4)))]"
        else
            echo "; set yrange [0:$(($2 + 1))]"
        fi
    else
        echo ""
    fi
}
#Adapt the xrange if there is only one value in the created graph
#$1 : U0MIN $2 : U0MAX
adaptXRangeIfSingleValue(){
    if [ ${#1} -gt 8 ]
    then
        echo "; set xrange [$(decimalLogarithmApprox $(($1 / 4))):$(decimalLogarithmApprox $(($2 * 4)))]"
    else
        echo "; set xrange [$1:$(($2 + 1))]"
    fi
}


#############################
#   MAIN PART OF THIS SCRIPT
#############################


# We check if the executable compiled from main.c exists
checkExecutableAvailability "syracuse"

# We check if the two firsts parameters are integers, if the first one is greater or equal to the second one and if they are lesser than 1e16
if [ $# -ne 2 -o -n "${1//[0-9]/}" -o -n "${2//[0-9]/}" -o "${1:0:1}" = "0" -o "${2:0:1}" = "0" -o ${#1} -gt 15 -o ${#2} -gt 15 ]
then
    # Display help
    displayHelp
    exit 1
elif [ $1 -gt $2 ] #We check if the first number is greater than the second. This line isn't in the first if expression because it was tested even when the previous expressions were true
then
    # Display help
    displayHelp
    exit 1
fi

# We check if the output files and folders already exist
if [ -d "summary/synthese-$1-$2.txt" ]
then
    echo -e "ERROR: you have to delete the folder 'summary/synthese-$1-$2.txt 'before running this script\n"
    exit 1
fi

checkDirAvailability "output_dir"
checkDirAvailability "graphs"
checkDirAvailability "summary"

# We run 'syracuse' for each U0 between $1 and $2. It creates a file for each of those U0
for u0 in `seq $1 $2` 
do
    ./syracuse "$u0" "output_dir/f${u0}.dat"
    if [ $? -eq 1 ]
    then 
        echo -e "ERROR: the program 'syracuse' couldn't be executed\n"
        exit 1
    fi
done

# We initialize the needed variables

altimax_data=`mktemp`
flight_duration_data=`mktemp`
altitude_duration_data=`mktemp`

max_altimax=$(tail -n 3 output_dir/f${1}.dat | sed -n '1p' | cut -d'=' -f2)
min_altimax=$max_altimax
current_altimax=0
average_altimax=0

max_flight_duration=$(tail -n 2 output_dir/f${1}.dat | sed -n '1p' | cut -d'=' -f2)
min_flight_duration=$max_flight_duration
current_flight_duration=0
average_flight_duration=0

min_altitude_duration=$(tail -n 1 output_dir/f${1}.dat | cut -d'=' -f2)
max_altitude_duration=$min_altitude_duration
current_altitude_duration=0
average_altitude_duration=0

gnuplot_instructions_flights=""

# If there is only one point we don't draw a line, we only give one dot, we also have to specify the range (if we don't do this then it will be adjusted automatically and will display warnings)

range_flights="" # range for the graph of all flights
range="" # range for the other graphs apart from the graph of all flights

line_style_flights="with lines"
line_style="with lines"

if [ $1 -eq $2 ]
then
    if [ $1 -eq 1 ]
    then
        line_style_flights="with linespoints pointtype 7 pointsize 3" #we are drawing a big point so that it can be seen easily
    fi
    line_style="with linespoints pointtype 7 pointsize 3"    
fi

# We get the data needed to create the graphs and the summary
for u0 in `seq $1 $2`
do
    gnuplot_instructions_flights="${gnuplot_instructions_flights} 'output_dir/f${u0}.dat' u 1:2 title '' $line_style_flights lc rgb 'blue', "
    #ALTIMAX
    current_altimax=$(getDataFromDatFiles $u0 1 "$altimax_data")
    min_altimax=$(min $current_altimax $min_altimax)
    max_altimax=$(max $current_altimax $max_altimax)
    average_altimax=$(($average_altimax + $current_altimax))

    #FLIGHT DURATION
    current_flight_duration=$(getDataFromDatFiles $u0 2 "$flight_duration_data")
    min_flight_duration=$(min $current_flight_duration $min_flight_duration)
    max_flight_duration=$(max $current_flight_duration $max_flight_duration)
    average_flight_duration=$(($average_flight_duration + $current_flight_duration))

    #ALTITUDE DURATION
    current_altitude_duration=$(getDataFromDatFiles $u0 3 "$altitude_duration_data")
    min_altitude_duration=$(min $current_altitude_duration $min_altitude_duration)
    max_altitude_duration=$(max $current_altitude_duration $max_altitude_duration)
    average_altitude_duration=$(($average_altitude_duration + $current_altitude_duration))
done

average_altimax=$(($average_altimax / ($2 - $1 + 1)))
average_flight_duration=$(($average_flight_duration / ($2 - $1 + 1)))
average_altitude_duration=$(($average_altitude_duration / ($2 - $1 + 1)))

# summary/synthese-$1-$2.txt is created here
echo -e "Altimax :\n\tMin : $min_altimax \n\tMax : $max_altimax \n\tMoyenne : $average_altimax\n" > "summary/synthese-$1-$2.txt"
echo -e "Dureevol :\n\tMin : $min_flight_duration \n\tMax : $max_flight_duration \n\tMoyenne : $average_flight_duration\n" >> "summary/synthese-$1-$2.txt"
echo -e "Dureealtitude :\n\tMin : $min_altitude_duration \n\tMax : $max_altitude_duration\n\tMoyenne : $average_altitude_duration" >> "summary/synthese-$1-$2.txt"


# We adjust the y ranges if there is only one value
range_altimax=$(adaptYRangeIfSingleValue "$altimax_data" $max_altimax)
range_flight_duration=$(adaptYRangeIfSingleValue "$flight_duration_data" $max_flight_duration)
range_altitude_duration=$(adaptYRangeIfSingleValue "$altitude_duration_data" $max_altitude_duration)

# If there is only one point in xrange (e.g [2:2]) then we need to readjust it
if [ $1 -eq $2 ]
then
    xrange="$(adaptXRangeIfSingleValue $1 $2)"
    range_altimax="${range_altimax}$xrange"
    range_flight_duration="${range_flight_duration}$xrange"
    range_altitude_duration="${range_altitude_duration}$xrange"
    range_altimax="${range_altimax}$xrange"
    if [ $1 -eq 1 ]
    then
        range_flights="; set yrange [0:2]; set xrange [0:1]"
    fi
fi

# We create the graphs
gnuplot -e "reset; set terminal jpeg size 1600, 900 $range_flights; set title 'Ensemble des Un=f(n) pour U0 dans [${1}-${2}]' font ',20'; set ylabel 'Un'; set xlabel 'n'; set output 'graphs/syracuse_$1_$2_ALL.jpg'; plot $gnuplot_instructions_flights"
gnuplot -e "reset; set terminal jpeg size 1600, 900 $range_altimax; set title 'altimax = f(U0) pour U0 dans [${1}-${2}]' font ',20'; set ylabel 'altimax'; set xlabel 'n'; set xlabel 'U0'; set output 'graphs/syracuse_$1_$2_altimax.jpg'; plot '$altimax_data' u 1:2 title '' $line_style lc rgb 'blue'"
gnuplot -e "reset; set terminal jpeg size 1600, 900 $range_flight_duration; set title 'dureevol= f(U0) pour U0 dans [${1}-${2}]' font ',20'; set ylabel 'dureevol'; set xlabel 'n'; set xlabel 'U0'; set output 'graphs/syracuse_$1_$2_dureevol.jpg'; plot '$flight_duration_data' u 1:2 title '' $line_style lc rgb 'blue'"
gnuplot -e "reset; set terminal jpeg size 1600, 900 $range_altitude_duration; set title 'dureealtitude = f(U0) pour U0 dans [${1}-${2}]' font ',20'; set ylabel 'dureealtitude'; set xlabel 'n'; set xlabel 'U0'; set output 'graphs/syracuse_$1_$2_dureealtitude.jpg'; plot '$altitude_duration_data' u 1:2 title '' $line_style lc rgb 'blue'"

# The temporary files (and folder) are deleted
rm -r "output_dir"
rm "$altimax_data" "$flight_duration_data" "$altitude_duration_data"
