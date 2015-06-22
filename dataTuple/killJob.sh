#!/bin/bash

if [ $# -eq 0 ] 
  then 
    BASEPATH="$PWD/basepath"
  else
    BASEPATH=$1
fi

touch $BASEPATH/suicide.txt
