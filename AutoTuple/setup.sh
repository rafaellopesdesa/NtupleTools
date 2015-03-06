#!/bin/bash
if [ $# -eq 0 ] 
  then 
  echo "No arguments!" 
  return
fi

gtag=`sed -n '1p' $1`
tag=`sed -n '2p' $1`
export PATH=$PATH:`pwd`
source /cvmfs/cms.cern.ch/crab3/crab.sh
export SCRAM_ARCH=slc6_amd64_gcc481
scramv1 p -n CMSSW_7_2_0 CMSSW CMSSW_7_2_0
cd CMSSW_7_2_0
cmsenv
cp /nfs-7/userdata/libCMS3/lib_$tag.tar.gz . 
tar -xzvf lib_$tag.tar.gz
scram b -j 10
mkdir crab
cd crab
cp -r ../../../condorMergingTools/* ${CMSSW_BASE}/crab/
cp ${CMSSW_BASE}/src/CMS3/NtupleMaker/test/MCProduction2015_NoFilter_cfg.py skeleton_cfg.py
sed -i s/process.GlobalTag.globaltag\ =\ .*/process.GlobalTag.globaltag\ =\ \"$gtag\"/ skeleton_cfg.py
cp ../../submitMergeJobs.sh .
cp ../../submit_crab_jobs.py  .
cp ../../$1 .
cp ../../monitor.py . 
cp ../../monitor.sh . 
cp ../../process.py .
cp ../../pirate.txt .
cp ../../FindLumisPerJob.sh . 
cp ../../das_client.py . 
cp ../../web_autoTuple .
cp ../../crabPic.png .
cp ../../copy.sh .
cp ../../numEventsROOT.C .
python submit_crab_jobs.py $1 $gtag $tag
. monitor.sh $1 $gtag $tag
