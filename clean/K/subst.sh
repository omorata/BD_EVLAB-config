#!/bin/bash

#MODELFILE=Ksb1-gaincal.ini
#SUFX="-gaincal.ini"
SUFX="-J041757.ini"
MODELFILE="Ksb1${SUFX}"

for i in $(seq 2 8)
do
    outfile="Ksb${i}${SUFX}"
    echo $outfile
    cp ${MODELFILE} $outfile
    sed "s/sb1/sb${i}/g" ${MODELFILE} > $outfile
done
