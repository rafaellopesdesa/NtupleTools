#! /bin/bash

##
# This is the main usage file. Make sure the cfg is written properly. Also, Make sure you have all the permissions to write out to any necessary directories on hadoop. 
# usage:
# ./submitMergeJobs.sh cfg/sample_cfg.sh

configFile=$1
if [ "$isDataTuple" == "1" ]
then
  workingDirectory=$PWD
else
  source $configFile
fi

#ensures that there is a directory to stageout to
if [ ! -d $outputDir ]; then
	echo "$outputDir does not exist. Attempting to make."
	mkdir -p $outputDir
	didMakeDir=$?
else
	didMakeDir=0;
fi

if [ "$didMakeDir" == "0" ]; then
	echo "Directory $outputDir made successfully. "
else
	echo "Directory $outputDir not made successfully. Exiting."
	exit 1
fi

#this gets the list of lists
filesList=`ls $inputListDirectory`
#filesList="merged_list_78.txt"

#chooses how to call the log submission file
dateS=`date '+%Y.%m.%d-%H.%M.%S'`
if [ ! -d /data/tmp/$USER/$dataSet/submit/std_logs/ ]; then
	mkdir -p /data/tmp/$USER/$dataSet/submit/std_logs/
fi

#make sweepRoot if it doesn't exist
if [ ! -e sweepRoot.tar.gz ] 
then
  wrongRootError=`which root | grep "slc6" > /dev/null ; echo $?`
  if [ "$wrongRootError" == "1" ]
  then
    source /code/osgcode/cmssoft/cmsset_default.sh  > /dev/null 2>&1
    pushd /cvmfs/cms.cern.ch/slc6_amd64_gcc491/cms/cmssw-patch/CMSSW_7_4_1_patch1/
    eval `scramv1 runtime -sh`
    popd
  fi
  pushd ../sweepRoot
  tar -czf sweepRoot.tar.gz sweepRoot.C Makefile
  popd
  mv ../sweepRoot/sweepRoot.tar.gz . 
fi

numjobssubmitted=0

#This loops over the merged file lists and submits a job for each list
for list in $filesList; do

	inputList=${inputListDirectory}$list
    if [ "$isDataTuple" == "1" ]; then inputList=$list; fi
	inputArguments="$inputList $mData $outputDir"
	inputFiles=${inputList},${mData},$executableScript,$workingDirectory/libC/mergeScript.C,sweepRoot.tar.gz,$workingDirectory/libC/addBranches.C

# this takes care of "resubmission. When all your condor jobs are done, this will check that the files are there, and if they are not, it will resubmit a job. If you find a job that has output a corrupted file (which it shouldn't unless stageout fails) just delete the file and run this script again."
	outFileName=`echo $list | sed 's/list/ntuple/g' | sed 's/txt/root/g'`
	# ls -l $outputDir | grep "$outFileName" 
	ls -l $outputDir/$outFileName > /dev/null 2>&1
	doesExist=$?
	if [ $doesExist == 0 ]; then
		echo "File exists, will not submit job for $outputDir/$outFileName."
	else
		echo "submitting job for file $outFileName"
		libsh/submit.sh -e $executableScript -a "$inputArguments" -i $inputFiles -u ${workingDirectory}/${dataSet}_cfg -l /data/tmp/$USER/$dataSet/testlog_$dateS.log -L /data/tmp/$USER/$dataSet/submit/std_logs/
		numjobssubmitted=$(($numjobssubmitted+1))
	fi
done

echo "$numjobssubmitted jobs submitted. Check status of jobs with condor_q $USER"
