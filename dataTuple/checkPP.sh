#checks the status of post-processing for a given task and copies finished files, adds them to the donePP.txt list.

#Takes arguments:
  #1) the target directory to mv file to
  #2) taskname
  #3) JOBTYPE

target=$1
taskname=$2
JOBTYPE=$3

mergedDir="/hadoop/cms/store/user/$USER/dataTuple/$taskName/merged"

if [ ! -d $BASEPATH ]
then
  echo "BASEPATH in checkPP.sh does not exist!"
fi

if [ ! -d $target]; then mkdir -p $target; fi

#make donelist
if [! -e donePP.txt ]
then
    touch donePP.txt
fi

counter="0"
while [ -e $BASEPATH/mergedLists/$taskname/metaData_$counter.txt]
do

    mergeFile="$mergedDir/merged_ntuple_$counter.root"

    grep $mergeFile submitPPList.txt > /dev/null
    wasSubmitted=$?
    
    #FIXME: remove all held condor jobs

    condor_q $USER -l | grep $mergeFileName > /dev/null
    isRunning=$?
    
    #FIXME: shoud eventually check if output file has correct number of events, right now just checks existence

    #grep donePP.txt to see if PP lready finished and mv'ed to hadoop
    grep "$taskname/metaData_$counter.txt" donePP.txt > /dev/null
    isDone=$?

    if [ $isDone == 0 ]; then continue
    elif [ $isRunning == 0 ]; then continue
    elif [ -e $mergeFile ]; then
	mv $mergeFile $target
	$taskname/metaData_$counter.txt >> donePP.txt
    elif [ $wasSubmitted == 0 ]; then
	#FIXME: should add a 20min delay between job-not-running and outfile-doesn't exist, to allow for xfer time    
	echo "$mergeFile does not exist! Will resubmit."
	. submitPPJob.sh $taskName $mergedFileNumber $JOBTYPE
    elif [ ! $wasSubmitted == 0 ]; then
        echo "merged_ntuple_$mergedFileNumber.root never submitted"
    else echo "Something weird! Doesn't satisfy any conditions...."
    fi

    counter=$[$counter+1]
done

exit 0
