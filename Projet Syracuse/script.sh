#!/bin/bash

dir="output_dir"

if ! [ -d $dir ]
then
    mkdir $dir
fi

if [ $# -lt 2 -o $# -gt 2 -o "$1" = "-h" ]
then
    #Display help
    echo "ERROR"
    exit 1
elif [ $1 -gt $2 ]
then
    #Display help
    echo "ERROR"
    exit 1
fi

for u0 in `seq $1 $2`
do
    nom_fichier="f${u0}.dat"
    ./syracuse "$u0" "${dir}/${nom_fichier}"
done