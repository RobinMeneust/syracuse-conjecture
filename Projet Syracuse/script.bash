#!/bin/bash

dir="output_dir"

#We check if we have only two parameters that are integers
if [ $# -ne 2 -o -n "${1//[0-9]/}" -o -n "${2//[0-9]/}" ]
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

date > "${dir}/logs.txt" #add the date at the beginning of the logs file

if ! [ -d $dir ]
then
    mkdir $dir
fi

for u0 in `seq $1 $2`
do
    nom_fichier="f${u0}.dat"
    ./syracuse "$u0" "${dir}/${nom_fichier}" 2>>"${dir}/logs.txt"
done
