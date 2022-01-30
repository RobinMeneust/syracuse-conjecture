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
    echo "MANUAL: ..."
    exit 1
fi

#date > "output_dir/logs.txt" #add the date at the beginning of the logs file

if ! [ -d "output_dir" ] #if "dir" isn't a directory yet, we create it
then
    mkdir "output_dir"
fi

if ! [ -d "graph" ]
then
    mkdir "graph"
fi

for u0 in `seq $1 $2` #in the directory, we create $2-$1 files for each number of Un between these two numbers
do
    file_name="f${u0}.dat"
    ./syracuse "$u0" "output_dir/${file_name}" #2>>"output_dir/logs.txt"
done
#1600x900
gnuplot_instructions_flights="reset; set terminal jpeg size 1600, 900; set title 'Ensemble des Un=f(n) pour U0 dans [${1}-${2}]'; set ylabel 'Un'; set xlabel 'n'; set output 'graph/syracuse_$1_$2_ALL.jpg'; plot"
gnuplot_instructions_altimax="reset; set terminal jpeg size 1600, 900; set title 'altimax = f(U0) pour U0 dans [${1}-${2}]'; set ylabel 'altimax'; set xlabel 'U0'; set output 'graph/syracuse_$1_$2_altimax.jpg'; plot"
gnuplot_instructions_dureevol="reset; set terminal jpeg size 1600, 900; set title 'dureevol= f(U0) pour U0 dans [${1}-${2}]'; set ylabel 'dureevol'; set xlabel 'U0'; set output 'graph/syracuse$1_$2_dureevol.jpg'; plot"
gnuplot_instructions_dureealtitude="reset; set terminal jpeg size 1600, 900; set title 'dureealtitude = f(U0) pour U0 dans [${1}-${2}]'; set ylabel 'dureealtitude'; set xlabel 'U0'; set output 'graph/syracuse_$1_$2_dureealtitude.jpg'; plot"
#gnuplot -e "reset; set terminal png; set output 'ex.png'; plot 'output_dir/f15.dat' u 1:2 w l, 'output_dir/f20.dat' u 1:2 w l"

#altimax_data exist ???
#if [ -e altimax_data ]
#then
#    read -p "'altimax_data' already exist do you want to delete it ? (y/n): " answer
#    if [ "$answer" = "y" ]
#    then
#        rm altimax_data
#    else
#        echo -e "You have to delete 'altimax_data' before running this script\n"
#        exit 1 
#    fi
#fi

altimax_data=`mktemp`
dureevol_data=`mktemp`
dureealtitude_data=`mktemp`


for u0 in `seq $1 $2`
do
    file_name="f${u0}.dat"
    gnuplot_instructions_flights="${gnuplot_instructions_flights} 'output_dir/${file_name}' u 1:2 title '' w l lc rgb 'blue',"
    echo "$u0 $(tail -n 3 output_dir/${file_name} | sed -n '1p' | cut -d'=' -f2)" >> "$altimax_data"
    echo "$u0 $(tail -n 2 output_dir/${file_name} | sed -n '1p' | cut -d'=' -f2)" >> "$dureevol_data"
    echo "$u0 $(tail -n 1 output_dir/${file_name} | cut -d'=' -f2)" >> "$dureealtitude_data"
done
gnuplot_instructions_altimax="${gnuplot_instructions_altimax} '$altimax_data' u 1:2 title '' w l lc rgb 'blue'"
gnuplot_instructions_dureevol="${gnuplot_instructions_dureevol} '$dureevol_data' u 1:2 title '' w l lc rgb 'blue'"
gnuplot_instructions_dureealtitude="${gnuplot_instructions_dureealtitude} '$dureealtitude_data' u 1:2 title '' w l lc rgb 'blue'"

gnuplot -e "$gnuplot_instructions_flights"
echo "1"
gnuplot -e "$gnuplot_instructions_altimax"
echo "2"
gnuplot -e "$gnuplot_instructions_dureevol"
echo "3"
gnuplot -e "$gnuplot_instructions_dureealtitude"


#BONUS (stats)

#rm -r "output_dir"

rm "$altimax_data"
rm "$dureevol_data"
rm "$dureealtitude_data"