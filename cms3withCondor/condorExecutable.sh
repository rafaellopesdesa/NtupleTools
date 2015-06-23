#!/bin/bash

if (( $# != 7 )); then
    echo "Illegal number of arguments."
    exit 1
fi

HOME=`pwd`

configFile=$1
libCMS3=$2
GLOBAL_TAG=$3
INPUT_FILE_NAME=$4
OUTPUT_DIR=$5
OUTPUT_FILE_NAME=$6
MAX_NEVENTS=$7

#Tell us where we're running
echo "host: `hostname`" 

source /cvmfs/cms.cern.ch/cmsset_default.sh

#The lib and python directories come from the libCMS3 tarball
export LD_LIBRARY_PATH=$PWD/lib/slc6_amd64_gcc491:$LD_LIBRARY_PATH
export PATH=$PWD:$PATH
export PYTHONPATH=$PWD/python:$PYTHONPATH:python/

#Set environment
pushd /cvmfs/cms.cern.ch/slc6_amd64_gcc491/cms/cmssw-patch/CMSSW_7_4_1_patch1/src/
eval `scramv1 runtime -sh`
echo "should be in cvmfs: $PWD"
popd

#untar tarball containing CMS3 libraries and python files
echo "libCMS3 = $libCMS3"

if [ -e $libCMS3 ]
then
  scramv1 project CMSSW CMSSW_7_4_1_patch1
  mv $libCMS3 CMSSW_7_4_1_patch1/
  cd CMSSW_7_4_1_patch1
  tar -xzvf $libCMS3
  scram b -j 8
  eval `scramv1 runtime -sh`
  cd ..
else
  echo "libCMS3 missing!"
  exit 1
fi

which root

#INPUT_FILE_NAME_ESCAPED=`echo $INPUT_FILE_NAME | sed 's,/,\\\/,g'

sed -i "s/SUPPLY_GLOBAL_TAG/${GLOBAL_TAG}/g" $configFile
sed -i "s,SUPPLY_INPUT_FILE_NAME,${INPUT_FILE_NAME},g" $configFile
sed -i "s/SUPPLY_OUTPUT_FILE_NAME/${OUTPUT_FILE_NAME}/g" $configFile
sed -i "s/SUPPLY_MAX_NEVENTS/${MAX_NEVENTS}/g" $configFile

echo "ls -lrth"
ls -lrth

#Run it
cmsRun $configFile

echo "ls -lrth"
ls -lrth

#Copy the output
lcg-cp -b -D srmv2 --vo cms --connect-timeout 2400 --verbose file://`pwd`/${OUTPUT_FILE_NAME} srm://bsrm-3.t2.ucsd.edu:8443/srm/v2/server?SFN=${OUTPUT_DIR}/${OUTPUT_FILE_NAME}
