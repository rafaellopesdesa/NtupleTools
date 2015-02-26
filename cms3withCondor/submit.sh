#!/bin/bash

#Take argument of file you are submitting
cd cms3withCondor
. submit.sh ../$1 dataTuple ../submitFiles MCProduction2015_NoFilter_cfg.py
cd ..
