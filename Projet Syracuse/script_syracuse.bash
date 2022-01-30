#!/bin/bash

dir="output_dir"

#We check if the two firsts parameters are integers
if [ $# -ne 2 -o -n "${1//[0-9]/}" -o -n "${2//[0-9]/}" -o "${1:0:1}" = "0" -o "${2:0:1}" = "0" ]
then
    #Display help
    echo "MANUAL: ..."
    exit 1
elif [ $1 -gt $2 ] #We check if the first number is greater than the second. This line isn't in the first if expression because it was tested even when the previous expressions were true
then
    #Display help
    echo "MANUAL: ..."
    exit 1
fi

#date > "${dir}/logs.txt" #add the date at the beginning of the logs file

if ! [ -d $dir ] #if "dir" isn't a directory yet, we create it
then
    mkdir $dir
fi

for u0 in `seq $1 $2` #in the directory, we create $2-$1 files for each number of Un between these two numbers
do
    file_name="f${u0}.dat"
    ./syracuse "$u0" "${dir}/${file_name}" #2>>"${dir}/logs.txt"
done
