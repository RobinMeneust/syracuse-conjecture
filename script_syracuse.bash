#!/bin/bash

#We check if the two firsts parameters are integers
if [ $# -ne 2 -o -n "${1//[0-9]/}" -o -n "${2//[0-9]/}" -o "${1:0:1}" = "0" -o "${2:0:1}" = "0" ]
then
    #Display help
    echo -e "NAME\n\tscript_syracuse.bash\n\nSYNOPSIS\n\tscript_syracuse.bash -h\n\tscript_syracuse.bash UMIN MAX\n\nDESCRIPTION\n\tGenerates graphs in the jpeg format corresponding to maximum altitude, flight duration and altitude duration.\n\tIt also generates a resume named synthese-min-max.txt that provide minimum, maximum and average values for each one\n\tUMIN and UMAX are strictly positive integers and UMIN is lesser than UMAX\n\tUMAX must be an unsigned long int (so it's lesser than 18,446,744,073,709,551,615)\n\n\t-h\n\t\tdisplay this help and exit.\n"
    exit 1
elif [ $1 -gt $2 ] #We check if the first number is greater than the second. This line isn't in the first if expression because it was tested even when the previous expressions were true
then
    #Display help
    echo -e "NAME\n\tscript_syracuse.bash\n\nSYNOPSIS\n\tscript_syracuse.bash -h\n\tscript_syracuse.bash UMIN MAX\n\nDESCRIPTION\n\tGenerates graphs in the jpeg format corresponding to maximum altitude, flight duration and altitude duration.\n\tIt also generates a resume named synthese-min-max.txt that provide minimum, maximum and average values for each one\n\tUMIN and UMAX are strictly positive integers and UMIN is lesser than UMAX\n\tUMAX must be an unsigned long int (so it's lesser than 18,446,744,073,709,551,615)\n\n\t-h\n\t\tdisplay this help and exit.\n"
    exit 1
fi

if ! [ -x "syracuse" ]
then
    echo -e "ERROR: syracuse does not exist or is not an executable. Please read README.txt and follow the instructions in the installation part\n"
    exit 1
fi


if [ -e "synthese-$1-$2.txt" ]
then
    read -p "'synthese-$1-$2.txt' already exist do you want to delete it ? (y/n): " answer
    if [ "$answer" = "y" ]
    then
        rm "synthese-$1-$2.txt"
    else
        echo -e "You have to delete 'synthese-$1-$2.txt' before running this script\n"
        exit 1 
    fi
fi

if ! [ -d "output_dir" ] #if "dir" isn't a directory yet, we create it
then
    mkdir "output_dir"
fi

if ! [ -d "graphs" ]
then
    mkdir "graphs"
fi

for u0 in `seq $1 $2` #in the directory, we create $2-$1 files for each number of Un between these two numbers
do
    ./syracuse "$u0" "output_dir/f${u0}.dat" #2>>"output_dir/logs.txt"
    if [ $? -eq 1 ]
    then 
        echo -e "ERROR: the program syracuse couldn't be executed\n"
        exit 1
    fi
done

#gnuplot -e "reset; set terminal png; set output 'ex.png'; plot 'output_dir/f15.dat' u 1:2 with lines, 'output_dir/f20.dat' u 1:2 with lines"



altimax_data=`mktemp`
dureevol_data=`mktemp`
dureealtitude_data=`mktemp`

max_altimax=$(tail -n 3 output_dir/f${1}.dat | sed -n '1p' | cut -d'=' -f2) # temp value to test the current version, it will be the real max value when this project will be completed
min_altimax=$max_altimax
current_altimax=0
average_altimax=0

max_dureevol=$(tail -n 2 output_dir/f${1}.dat | sed -n '1p' | cut -d'=' -f2)
min_dureevol=$max_dureevol
current_dureevol=0
average_dureevol=0

min_dureealtitude=$(tail -n 1 output_dir/f${1}.dat | cut -d'=' -f2)
max_dureealtitude=$min_dureealtitude
current_dureealtitude=0
average_dureealtitude=0

gnuplot_instructions_flights=""

#If there is only one point we don't draw line, we only give one dot, we also have to specify the range (if we don't do this then it will be adjusted automatically)
range_flights=""
range=""
line_style_flights="with lines"
line_style="with lines"

if [ $1 -eq $2 ]
then
    if [ $1 -le 1 ]
    then
        line_style_flights="with linespoints pointtype 7 pointsize 3" #we are drawing a big point so that it can be seen easily
    fi
    line_style="with linespoints pointtype 7 pointsize 3"    
fi

for u0 in `seq $1 $2`
do
    file_name="f${u0}.dat"
    gnuplot_instructions_flights="${gnuplot_instructions_flights} 'output_dir/${file_name}' u 1:2 title '' $line_style_flights lc rgb 'blue', "

    current_altimax="$(tail -n 3 output_dir/${file_name} | sed -n '1p' | cut -d'=' -f2)"
    echo "$u0 $current_altimax" >> "$altimax_data"
    if [ $current_altimax -gt $max_altimax ]
    then
        max_altimax=$current_altimax
    fi
    if [ $current_altimax -lt $min_altimax ]
    then
        min_altimax=$current_altimax
    fi

    current_dureevol="$(tail -n 2 output_dir/${file_name} | sed -n '1p' | cut -d'=' -f2)"
    echo "$u0 $current_dureevol" >> "$dureevol_data"
    if [ $current_dureevol -gt $max_dureevol ]
    then
        max_dureevol=$current_dureevol
    fi
    if [ $current_dureevol -lt $min_dureevol ]
    then
        min_dureevol=$current_dureevol
    fi

    current_dureealtitude="$(tail -n 1 output_dir/${file_name} | cut -d'=' -f2)"
    echo "$u0 $current_dureealtitude" >> "$dureealtitude_data"
    if [ $current_dureealtitude -gt $max_dureealtitude ]
    then
        max_dureealtitude=$current_dureealtitude
    fi
    if [ $current_dureealtitude -lt $min_dureealtitude ]
    then
        min_dureealtitude=$current_dureealtitude
    fi

    average_altimax=$(($average_altimax + $current_altimax))
    average_dureevol=$(($average_dureevol + $current_dureevol))
    average_dureealtitude=$(($average_dureealtitude + $current_dureealtitude))

done

average_altimax=$(($average_altimax / ($2 - $1 +1)))
average_dureevol=$(($average_dureevol / ($2 - $1 +1)))
average_dureealtitude=$(($average_dureealtitude / ($2 - $1 +1)))


if [ $1 -eq $2 ]
then
    if [ $1 -le 1 ]
    then
        range_flights="set xrange [0:$(($1 + 1))]; set yrange [0:$(($max_altimax + 1))]" #the range is adujsted, it starts from 0
    fi
    range_altimax="set xrange [0:$(($1 + 1))]; set yrange [0:$(($max_altimax + 1))]"
    range_dureevol="set xrange [0:$(($1 + 1))]; set yrange [0:$(($max_dureevol + 1))]"
    range_dureealtitude="set xrange [0:$(($1 + 1))]; set yrange [0:$(($max_dureealtitude + 1))]"
fi


gnuplot -e "reset; set terminal jpeg size 1600, 900; $range_flights; set title 'Ensemble des Un=f(n) pour U0 dans [${1}-${2}]' font ',20'; set ylabel 'Un'; set xlabel 'n'; set output 'graphs/syracuse_$1_$2_ALL.jpg'; plot $gnuplot_instructions_flights"
gnuplot -e "reset; set terminal jpeg size 1600, 900; $range_altimax; set title 'altimax = f(U0) pour U0 dans [${1}-${2}]' font ',20'; set ylabel 'altimax'; set xlabel 'n'; set xlabel 'U0'; set output 'graphs/syracuse_$1_$2_altimax.jpg'; plot '$altimax_data' u 1:2 title '' $line_style lc rgb 'blue'"
gnuplot -e "reset; set terminal jpeg size 1600, 900; $range_dureevol; set title 'dureevol= f(U0) pour U0 dans [${1}-${2}]' font ',20'; set ylabel 'dureevol'; set xlabel 'n'; set xlabel 'U0'; set output 'graphs/syracuse_$1_$2_dureevol.jpg'; plot '$dureevol_data' u 1:2 title '' $line_style lc rgb 'blue'"
gnuplot -e "reset; set terminal jpeg size 1600, 900; $range_dureealtitude; set title 'dureealtitude = f(U0) pour U0 dans [${1}-${2}]' font ',20'; set ylabel 'dureealtitude'; set xlabel 'n'; set xlabel 'U0'; set output 'graphs/syracuse_$1_$2_dureealtitude.jpg'; plot '$dureealtitude_data' u 1:2 title '' $line_style lc rgb 'blue'"

#BONUS (stats)

#synthese-$1-$2.txt
echo -e "Altimax :\n\tMin : $min_altimax \n\tMax : $max_altimax \n\tAverage : $average_altimax\n" > "synthese-$1-$2.txt"
echo -e "DureeVol :\n\tMin : $min_dureevol \n\tMax : $max_dureevol \n\tAverage : $average_dureevol\n" >> "synthese-$1-$2.txt"
echo -e "DureeAltitude :\n\tMin : $min_dureealtitude \n\tMax : $max_dureealtitude\n\tAverage : $average_dureealtitude" >> "synthese-$1-$2.txt"

rm -r "output_dir"

rm "$altimax_data"
rm "$dureevol_data"
rm "$dureealtitude_data"

