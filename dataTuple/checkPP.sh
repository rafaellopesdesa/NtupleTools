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

#Run condor_q to get list of running jobs
condor_q $USER > temp_status.txt
sed -i '1,4d' temp_status.txt
sed -i '$d' temp_status.txt
sed -i '$d' temp_status.txt

#Delete old test files
rm runPPlist.txt 2>/dev/null
rm heldPPList.txt 2>/dev/null

#Read condor_q output to fill lists.  
while read line
do
    if [ `echo $line | awk '{ print $6 }'` == "R" ]
    then
	echo `echo $line | awk '{ print $1 }'` >> runPPList.txt
    fi
    if [ `echo $line | awk '{ print $6 }'` == "C" ]
    then
	echo `echo $line | awk '{ print $1 }'` >> runPPList.txt
    fi
    #if [ `echo $line | awk '{ print $6 }'` == "I" ]
    #then
    #    echo `echo $line | awk '{ print $1 }'` >> idlePPList.txt
    #fi
    if [ `echo $line | awk '{ print $6 }'` == "H" ]
    then
	echo `echo $line | awk '{ print $1 }'` >> heldPPList.txt
    fi	
done < temp_status.txt    
rm temp_status.txt

#Delete held jobs
if [ -e heldPPList.txt ]
then
    while read line
    do
	condor_rm $line
    done < heldPPList.txt
    rm helPPdList.txt
fi

counter="0"
while [ -e $BASEPATH/mergedLists/$taskname/metaData_$counter.txt]
do

    mergeFile="$mergedDir/merged_ntuple_$counter.root"

    #grep donePP.txt to see if PP lready finished and mv'ed to hadoop
    grep "$taskname/metaData_$counter.txt" donePP.txt > /dev/null
    isDone=$?
    if [ $isDone == 0 ]; then continue
			      
    grep $mergeFile submitPPList.txt > /dev/null
    wasSubmitted=$?
    if [ ! $wasSubmitted == 0 ]; then
        echo "merged_ntuple_$mergedFileNumber.root never submitted"
	continue
    fi

    grep $mergeFileName runPPlist.txt > /dev/null
    isRunning=$?
			      
    if [ $isRunning == 0 ]; then continue
    elif [ -e $mergeFile ]; then #FIXME: shoud eventually check if output file has correct number of events, right now just checks existence
	mv $mergeFile $target
	echo "$mergefile" >> donePP.txt
    elif [ $wasSubmitted == 0 ]; then
	#FIXME: should add a 20min delay between job-not-running and outfile-doesn't exist, to allow for xfer time    
	echo "$mergeFile does not exist! Will resubmit."
	. submitPPJob.sh $taskName $counter $JOBTYPE
    else echo "Something weird! Doesn't satisfy any conditions...."
    fi

    counter=$[$counter+1]
done

exit 0
