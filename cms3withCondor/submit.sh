#!/bin/bash

#User input
#List files you want to ntuplize here:
files=/home/users/cgeorge/CMS3/CMSSW_7_2_0/src/CMS3/NtupleMaker/1500_samples.txt
#Give name for directory to receives files on hadoop
filedir="13TeV_T5qqqqWW_Gl1500_Chi800_LSP100"
#We will create new directory for submission files.  Invent a name for it here
subfiles=1500_condor_files
#The input file you want to run on
inputfile=MCProduction2015_NoFilter_cfg.py



##################---HERE THERE BE DRAGONS---################################
number=1

sed -i "8s/.*/Transfer_Input_Files = RecoEgamma.tar,$subfiles\/FILENAME/g" condorFile

while read line
do
  let "number=$number+1"
  filename=`echo $line | rev | cut -c 1 --complement | rev`
  configFile=MCProduction2015_${number}_cfg.py
  outputfile=ntuple_${number}.root
  condorFile=condorFile_${number}
  
  cp $inputfile $subfiles/$configFile
  
  sed -i "9s,.*,$filename," $subfiles/$configFile
  sed -i "15s/.*/   fileName     = cms.untracked.string\(\'$outputfile\'\),/" $subfiles/$configFile
  
  cp condorFile $subfiles/$condorFile
  sed -i "s/FILENAME/$configFile/g" $subfiles/$condorFile
  sed -i "s/NUMBER/$number/g" $subfiles/$condorFile
  sed -i "s/FILEDIR/$filedir/g" $subfiles/$condorFile

  condor_submit $subfiles/$condorFile
  
done < $files
