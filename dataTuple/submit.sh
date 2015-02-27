#!/bin/bash

#Take argument of file you are submitting, date-time for log dir
cd cms3withCondor
. submit.sh ../$1 dataTuple submitFiles MCProduction2015_NoFilter_cfg.py $2
cd ..
