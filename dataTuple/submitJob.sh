#!/bin/bash

#Take argument of file you are submitting, output file name
sed -n "$5p" $1 > temp.txt
cd cms3withCondor
. submit.sh ../temp.txt $2 $3 false $4
cd ..
