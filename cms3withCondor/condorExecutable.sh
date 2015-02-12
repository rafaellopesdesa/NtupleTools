#!/bin/bash

HOME=`pwd`

#This stuff to get it to run
export CMS_PATH=/cvmfs/cms.cern.ch
export SCRAM_ARCH=slc6_amd64_gcc481
source /cvmfs/cms.cern.ch/cmsset_default.sh
source /cvmfs/cms.cern.ch/slc6_amd64_gcc481/lcg/root/5.34.18/bin/thisroot.sh
export LD_LIBRARY_PATH=$ROOTSYS/lib:$LD_LIBRARY_PATH:$PWD:${_CONDOR_SCRATCH_DIR}
export PATH=$ROOTSYS/bin:$PATH:${_CONDOR_SCRATCH_DIR}
export PYTHONPATH=$ROOTSYS/lib:$PYTHONPATH

#This to get the file name
configFile=$1
number=$2
filedir=$3
OUTPUT=ntuple_${number}.root

#Tell us where we're running
echo "host: " 
hostname

#Specify name of output file and name of directory in /hadoop/.../cgeorge/condor
export DIRNAME=privateSignals

#This stuff to get output back
export COPYDIR=/hadoop/cms/store/user/cgeorge/condor/${DIRNAME}/${filedir}

#Set tags
gtag="PHYS14_25_V2::All"
tag="master"

#Set env vars
export PATH=$PATH:`pwd`
export SCRAM_ARCH=slc6_amd64_gcc481

#Checkout CMSSW
scramv1 p -n CMSSW_7_2_0 CMSSW CMSSW_7_2_0
cd CMSSW_7_2_0/src

#Set environment
eval `scramv1 runtime -sh`

#Get the NtupleMaker, build it
git clone https://github.com/cmstas/NtupleMaker.git CMS3/NtupleMaker
cd CMS3/NtupleMaker
git checkout $tag
echo "CMSSW_BASE: $CMSSW_BASE"
cd CMSSW_7_2_0

#SETUP/PATCHES TO SOURCE
#mv $CMSSW_BASE/src/* $CMSSW_BASE/bullshit/
mv $HOME/RecoEgamma.tar $CMSSW_BASE/src/
cd $CMSSW_BASE/src/
echo "THIS IS CMSSW_BASE/src ls"
ls
tar -xvf RecoEgamma.tar
scram b -j 20 
echo "THERE ARE $? ERRORS AFTER SCRAMING"
echo "THIS IS CMSSW_BASE ls"
ls

##############
## MVA JetId #
##############
# 
git clone https://github.com/latinos/UserCode-CMG-CMGTools-External $CMSSW_BASE/src/CMGTools/External
pushd $CMSSW_BASE/src/CMGTools/External
git checkout V00-03-01
rm plugins/PileupJetIdProducer.cc
popd

########################
## LCG dictionaries #
########################
git clone https://github.com/cmstas/Dictionaries $CMSSW_BASE/src/CMS3/Dictionaries
########################

# run checkdeps
printf "\nchecking deps:\n"
git cms-checkdeps -a

# compile
scram build -c -j 20

cd $CMSSW_BASE/src
scram b -j 10

#Move the config file
cd ..
cp ../$configFile . 

#Run it
cmsRun $configFile

#Copy the output
lcg-cp -b -D srmv2 --vo cms --connect-timeout 2400 --verbose file://`pwd`/${OUTPUT} srm://bsrm-3.t2.ucsd.edu:8443/srm/v2/server?SFN=${COPYDIR}/${OUTPUT}
