#!/bin/bash

# environment variable magic. need this (only within scope of this script) or else nothing works!
. /cvmfs/cms.cern.ch/crab3/crab-env-bootstrap.sh >& /dev/null
python FindLumisPerJob.py $1
