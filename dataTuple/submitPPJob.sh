#This takes 2-3 arguments
  #1) the directory in /nfs-7/userdata/dataTuple/mergedLists/
  #2) the number file you want to make or remake
  #3) the basepath.  For CMS3 resubmissions, this is /nfs-7/userdata/dataTuple

#You must run this script from inside the dataTuple directory!  

sample=$1
number=$2

if [ "$#" -gt "2" ]
then
  BASEPATH=$3
else
  BASEPATH="$PWD/$BASEPATH"
fi

#Set the environment variables
export inputListDirectory=$BASEPATH/mergedLists/$sample/merged_list_$number.txt
export mData=$BASEPATH/mergedLists/$sample/metaData_$number.txt
export outputDir=/hadoop/cms/store/user/$USER/condor/dataNtupling/merged/$sample
export dataSet=$sample
export workingDirectory=$PWD
export executableScript=`readlink -f $PWD/../condorMergingTools/libsh/mergeScriptRoot6.sh`
export isDataTuple=1

pushd $PWD/../condorMergingTools/
./submitMergeJobs.sh
popd
