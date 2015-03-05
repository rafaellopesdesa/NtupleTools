#!/bin/bash

#Take argument of file you are submitting, output file name
cd cms3withCondor
. submit.sh ../$1 "false" $2
cd ..
