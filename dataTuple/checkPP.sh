#checks the status of post-processing for a given task and copies finished files, adds them to the donePP.txt list.

#Takes arguments:
  #1) the target directory to mv file to
  #2) taskname
  #3) JOBTYPE

target=$2
taskname=$3
JOBTYPE=$4

mergedDir="/hadoop/cms/store/user/$USER/dataTuple/$taskName/merged"

if [ ! -d $BASEPATH ]
then
  echo "BASEPATH in checkPP.sh does not exist!"
fi

if [ ! -e runningPP.txt ]
then
  echo "no PP jobs running yet..."
  exit 1
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
    #figure out if PP job is already running or not
    #how to do this easily with condor_q? I need to know job ID
    isRunning=$?
    
    #FIXME: shoud eventually check if output file has correct number of events, right now just checks existence
    grep "$taskname/metaData_$counter.txt" donePP.txt > /dev/null
    isDone=$?
    if [ $isRunning == 0 ]; then
	continue
    elif [ -e $mergedDir/merged_ntuple_$mergedFileNumber.root ]; then
	mv $mergedDir/merged_ntuple_$mergedFileNumber.root $target
	$taskname/metaData_$counter.txt >> donePP.txt
    elif [ $isDone != 0 ] && [ $isRunning != 0 ] && [ $wasSubmitted == 0 ]; then
	echo "$mergedDir/merged_ntuple_$mergedFileNumber.root does not exist! Will resubmit."
	. submitPPJob.sh $taskName $mergedFileNumber $JOBTYPE
    elif [ ! $wasSubmitted == 0 ]; then
        echo "merged_ntuple_$mergedFileNumber.root not in runningPP.txt"
    fi

    counter=$[$counter+1]
done

exit 0
