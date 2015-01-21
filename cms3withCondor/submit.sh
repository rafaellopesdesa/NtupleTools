#!/bin/bash

inputfile=MCProduction2015_NoFilter_cfg.py
files=/home/users/cgeorge/CMS3/CMSSW_7_2_0/src/CMS3/NtupleMaker/files.txt

while read line
do
  filename=$line
  filedir=${filename%.MINI*root}
  number=`echo $filename | rev | cut -c 6-7 | rev`
  configFile=MCProduction2015_${filedir}_${number}_cfg.py
  outputfile=ntuple_${filedir}_${number}.root
  condorFile=condorFile_${filedir}_${number}
  
  cp $inputfile private/$configFile
  
  sed -i "9s,.*,\'root://cmsxrootd.fnal.gov//store/cmst3/group/susy/gpetrucc/13TeV/Phys14DR/MINIAODSIM/$filedir/$filename\'," private/$configFile
  sed -i "15s/.*/   fileName     = cms.untracked.string\(\'$outputfile\'\),/" private/$configFile
  
  cp condorFile private/$condorFile
  sed -i "s/FILENAME/$configFile/g" private/$condorFile

  condor_submit private/$condorFile
  
done < $files
