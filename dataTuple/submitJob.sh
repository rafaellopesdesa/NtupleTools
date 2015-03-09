#!/bin/bash

#Take argument of file you are submitting, output file name
sed -n "$5p" $1 > tempSubmit.txt
cd cms3withCondor
. submit.sh ../tempSubmit.txt $2 $3 false $4
cd ..
rm tempSubmit.txt
