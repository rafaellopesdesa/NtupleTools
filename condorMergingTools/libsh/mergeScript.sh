#! /bin/bash

##check metadata to find CMSSW and scramarch. Might do this later.
#input merged list
inputList=$1
#input metadata
mData=$2
#output
outputDir=$3

#This step prevents the ntuples from staging out in your home directory.
mkdir tempdir
cd tempdir
cp ../* .

# shows files you have to work with.
echo "current files in directory:"
echo `ls -l`

# This sets up some variables for later.
inputList=`basename $inputList`
echo "Attempting to merge files from $inputList"
mData=`basename $mData`
echo "using metadata file: $mData"

# set up golf-type environment (standalone root, no CMSSW)
#  Dominick was having problems with lcg-cp after setting up CMSSW env..
export CMS_PATH=/code/osgcode/cmssoft/cms
export SCRAM_ARCH=slc5_amd64_gcc462
source /code/osgcode/cmssoft/cms/cmsset_default.sh > /dev/null 2>&1
source /code/osgcode/fgolf/5.30-patches/bin/thisroot.sh
export LD_LIBRARY_PATH=$PWD:$LD_LIBRARY_PATH
export PYTHONPATH=$ROOTSYS/lib:$PYTHONPATH

#sets variable for stageout later
localdir=`pwd`

# check that sweepRoot exists
if [ ! -e "sweepRoot" ]; then
	echo "Error: sweepRoot doesn't exist, exiting.."
	exit 4
fi

#runs merging script, and if it fails tries one more time.
root -b -q -l "mergeScript.C (\"$inputList\",\"merged_ntuple.root\")"
./sweepRoot -o "Events" merged_ntuple.root
didMerge=$?

if [ $didMerge != 0 ]; then

	echo "Error in merging process, attempting to merge one more time.."

	if [ -e "merged_ntuple.root" ]; then

		rm merged_ntuple.root
	fi

	root -b -q -l "mergeScript.C (\"$inputList\",\"merged_ntuple.root\")"
	./sweepRoot -o "Events" merged_ntuple.root
	didMerge=$?	
fi
	
if [ $didMerge != 0 ]; then

	echo "Error in second merging attempt. Exiting."

	if [ -e "merged_ntuple.root" ]; then
		
		rm merged_ntuple.root
		
	fi
	
	exit 2	
fi

#Makes the name of the output ntuple depending on the name of the file list
outFileName=`echo $inputList | sed 's/list/ntuple/g' | sed 's/txt/root/g'`
outFileName=`basename $outFileName`
echo "outfile name = $outFileName"

#Adds cms2 branches to the file. If it fails, it tries again.
root -b -q -l "addBranches.C (\"$mData\",\"merged_ntuple.root\",\"$outFileName\")"
./sweepRoot -o "Events" `pwd`/$outFileName
didAddBranches=$?

if [ $didAddBranches != 0 ]; then

	echo "Error in adding cms2 branches. Attempting one more time.."

	if [ -e $outFileName ]; then
		
		rm $outFileName
		
	fi

	root -b -q -l "addBranches.C (\"$mData\",\"merged_ntuple.root\",\"$outFileName\")"
	./sweepRoot -o "Events" `pwd`/$outFileName
	didAddBranches=$?

fi


if [ $didAddBranches != 0 ]; then
	
	echo "Error in second attempt to add cms2 branches. Exiting."
	
	if [ -e $outFileName ]; then
		
		rm $outFileName
		
	fi
	
	exit 3
fi

echo $CMSSW_RELEASE_BASE
#use lcgcp to stageout
echo "filename = $outFileName"
echo "Outputting file to $outputDir from worker node."
localFile=`pwd`/${outFileName}

if [ $didAddBranches == 0 ]; then

	echo -e "copying file now from : \n$localFile \nto:\n$outputDir/$outFileName"
	lcg-cp -b -D srmv2 --vo cms -t 2400 --verbose file:`pwd`/${outFileName} srm://bsrm-3.t2.ucsd.edu:8443/srm/v2/server?SFN=$outputDir/${outFileName}
	stageout_error=$?

	if [ $stageout_error != 0 ]; then

		echo "Error merging files in $inputList. Job exit code $stageout_error. Stageout with lcg-cp failed."

	fi

	if [ $stageout_error == 0 ]; then

		echo "Merging of files in $inputList successful. Job exit code $stageout_error." # Error occurred while running makeSkime.C."

	fi
fi

echo "Cleaning up."
rm $outFileName merged_ntuple.root *.txt
echo "End of Merging."
#add white space.
