#!/bin/bash

#User input
#List files you want to ntuplize here:
files=/home/users/cgeorge/CMS3/CMSSW_7_2_0/src/CMS3/NtupleMaker/1200_samples.txt
#Give name for directory to receives files on hadoop
filedir="13TeV_T5qqqqWW_Gl1200_Chi1000_LSP800"
#We will create new directory for submission files.  Invent a name for it here
subfiles=1200_condor_files
#The input file you want to run on
inputfile=MCProduction2015_NoFilter_cfg.py


##################---HERE THERE BE DRAGONS---################################

#Figure out which jobs to redo
NUMOFLINES=$(wc -l < "$files")
redoFile=${subfiles}_redo
if [ -d "/hadoop/cms/store/user/cgeorge/condor/privateSignals/$filedir" ]
then
  here=`pwd`
  PATH=$PATH:$here
  pushd /hadoop/cms/store/user/cgeorge/condor/privateSignals/$filedir > /dev/null
  whichMissingCondorSubmissions $NUMOFLINES > /home/users/cgeorge/CMS3/CMSSW_7_2_0/src/CMS3/NtupleMaker/$redoFile
  popd > /dev/null
else
  redoFile=
fi
if [[ -e $redoFile ]] 
then
  if [[ ! -s $redoFile ]]; then echo "No files need to be resubmitted!"; return; fi
  for ((i = 1; i < $NUMOFLINES; i++)); do NEEDSDONE[i]=0; done
  while read line
  do
    NEEDSDONE[$line]=1
  done < $redoFile
else
  for ((i = 1; i < $NUMOFLINES; i++)); do NEEDSDONE[i]=1; done
  echo "Submitting all jobs!"
fi

#Init
number=0
sed -i "6s/.*/Transfer_Input_Files = RecoEgamma.tar,$subfiles\/FILENAME/g" condorFile

#Submit jobs
while read line
do
  let "number=$number+1"
  if [ ${NEEDSDONE[$number]} == 0 ]; then continue; fi
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
