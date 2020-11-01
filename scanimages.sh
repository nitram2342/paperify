#!/bin/bash -e

dir=$1

if [ ! -d "${dir}" ] ; then
    mkdir $dir
fi

i=0
while true
do
    fmt_number=`printf "%05d\n" ${i}`
    i=$((i+1))
    echo scanning $fmt_number
    
    scanimage --resolution 300 --format=png --mode Gray --output-file ${dir}/scan.png
    convert ${dir}/scan.png -threshold 50% -morphology open square:1 ${dir}/${fmt_number}.png
    rm ${dir}/scan.png
    echo "Hit enter to continue or Ctrl-C to stop."
    read cmd
done
