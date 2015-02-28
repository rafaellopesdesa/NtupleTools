#!/bin/bash

#User input.  these can be passed or manually set.  
if [ $# == 6 ]
then
  files=$1
  filedir=$2
  subfiles=$3
  inputfile=$4
  logdir=$5
  outputName=$6
else
  echo "ELSE!"
  #List files you want to ntuplize here:
  files=/home/users/cgeorge/CMS3/CMSSW_7_2_0/src/CMS3/NtupleMaker/1200_samples.txt
  #Give name for directory to receives files on hadoop
  filedir="13TeV_T5qqqqWW_Gl1200_Chi1000_LSP800"
  #We will create new directory for submission files.  Invent a name for it here
  subfiles=1200_condor_files
  #The input file you want to run on
  inputfile=MCProduction2015_NoFilter_cfg.py
  #The place you want to dump the logs
  logdir=logdir
  #OutputName (default is ntuple_i)
  outputName="ntuple_i"
fi


##################---HERE THERE BE DRAGONS---################################

#get a proxy if you don't have one
while  ! voms-proxy-info -exist
do echo "No Proxy found issuing \"voms-proxy-init -voms cms\""
   voms-proxy-init -hours 168 -voms cms 
done


#make subfiles dir if it does not exist
echo $subfiles
if [ ! -d $subfiles ]
then
  mkdir $subfiles
fi

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
  for ((i = 1; i < $NUMOFLINES+1; i++)); do NEEDSDONE[i]=0; done
  while read line
  do
    NEEDSDONE[$line]=1
  done < $redoFile
else
  for ((i = 1; i < $NUMOFLINES+1; i++)); do NEEDSDONE[i]=1; done
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
  filename=$line
  configFile=MCProduction2015_${number}_cfg.py
  if [ $outputName == "ntuple_i" ] 
  then
    outputfile=ntuple_${number}.root
  else
    outputfile=$outputName
  fi
  condorFile=condorFile_${number}
  
  cp $inputfile $subfiles/$configFile
  
  sed -i "9s,.*,\'$filename\'," $subfiles/$configFile
  sed -i "15s/.*/   fileName     = cms.untracked.string\(\'$outputfile\'\),/" $subfiles/$configFile

  cp condorFile $subfiles/$condorFile
  sed -i "s/FILENAME/$configFile/g" $subfiles/$condorFile
  sed -i "s/NUMBER/$number/g" $subfiles/$condorFile
  sed -i "s/FILEDIR/$filedir/g" $subfiles/$condorFile
  sed -i "s/LOGDIR/$logdir/g" $subfiles/$condorFile
  sed -i "s/USERNAME/${USER}/g" $subfiles/$condorFile
  sed -i "s/OUTPUTFILE/$outputfile/g" $subfiles/$condorFile
  sed -i "s.USERPROXY.$(voms-proxy-info -path).g" $subfiles/$condorFile #proxy string has a "/" in it, so use "." as delimiter

  condor_submit $subfiles/$condorFile
  
done < $files
