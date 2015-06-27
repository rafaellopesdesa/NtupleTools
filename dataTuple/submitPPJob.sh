#This takes 2-3 arguments
  #1) the directory in /nfs-7/userdata/dataTuple/mergedLists/
  #2) the number file you want to make or remake
  #3) The jobtype

#You must run this script from inside the dataTuple directory!  

sample=$1
number=$2
JOBTYPE=$3

#if [ "$#" -gt "2" ]
#then
#  BASEPATH=$3
#else
#  BASEPATH="$PWD/$BASEPATH"
#fi

#Set the environment variables
export inputListDirectory=$BASEPATH/mergedLists/$sample/merged_list_$number.txt
export mData=$BASEPATH/mergedLists/$sample/metaData_$number.txt
if [ "$JOBTYPE" == "cms3" ] 
then
  export outputDir=/hadoop/cms/store/user/$USER/dataTuple/$sample/merged
else
  export outputDir=/hadoop/cms/store/user/$USER/userjob_test/$sample/merged
fi
export dataSet=$sample
export workingDirectory=$PWD
export executableScript=`readlink -f $PWD/../condorMergingTools/libsh/mergeScriptRoot6.sh`
export isDataTuple=1

mkdir -p $outputDir

pushd $PWD/../condorMergingTools/
./submitMergeJobs.sh
popd
