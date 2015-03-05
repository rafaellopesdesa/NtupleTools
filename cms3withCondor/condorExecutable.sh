#!/bin/bash

if (( $# != 6 )); then
    echo "Illegal number of arguments."
    return 1
fi

HOME=`pwd`

configFile=$1
number=$2
filedir=$3
username=$4
OUTPUT=$5
libCMS3=$6

#Tell us where we're running
echo "host: " 
hostname

#Specify name of output file and name of directory in /hadoop/.../cgeorge/condor
export DIRNAME=dataNtupling

#This stuff to get output back
export COPYDIR=/hadoop/cms/store/user/$username/condor/${DIRNAME}/${filedir}

#Set tags
gtag="PHYS14_25_V2::All"
tag="master"

#untar tarball containing CMS3 libraries and python files
if [ -e $libCMS3 ]
then
  tar -xzvf $libCMS3
else
  echo "libCMS3 missing!"
  return 1
fi

#Set environment
export CMS_PATH=/cvmfs/cms.cern.ch
export SCRAM_ARCH=slc6_amd64_gcc481
source /cvmfs/cms.cern.ch/cmsset_default.sh
source /cvmfs/cms.cern.ch/slc6_amd64_gcc481/lcg/root/5.34.18/bin/thisroot.sh

pushd .
cd /cvmfs/cms.cern.ch/slc6_amd64_gcc481/cms/cmssw/CMSSW_7_2_0/src/
eval `scramv1 runtime -sh`
popd

#The lib and python directories come from the libCMS3 tarball
export LD_LIBRARY_PATH=$PWD/lib/slc6_amd64_gcc481:$LD_LIBRARY_PATH
export PATH=$PWD:$PATH
export PYTHONPATH=$PWD/python:$PYTHONPATH

#Run it
cmsRun $configFile

#Copy the output
lcg-cp -b -D srmv2 --vo cms --connect-timeout 2400 --verbose file://`pwd`/${OUTPUT} srm://bsrm-3.t2.ucsd.edu:8443/srm/v2/server?SFN=${COPYDIR}/${OUTPUT}
