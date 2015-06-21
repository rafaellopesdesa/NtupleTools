#This takes two arguments
  #1) the directory in /nfs-7/userdata/dataTuple/mergedLists/
  #2) the number file you want to make or remake

#You must run this script from inside the dataTuple directory!  

sample=$1
number=$2

#Set the environment variables
export inputListDirectory=/nfs-7/userdata/dataTuple/mergedLists/$sample/merged_list_$number.txt
export mData=/nfs-7/userdata/dataTuple/mergedLists/$sample/metaData_$number.txt
export outputDir=/hadoop/cms/store/user/$USER/condor/dataNtupling/merged/$sample
export dataSet=$sample
export workingDirectory=$PWD
export executableScript=`readlink -f $PWD/../condorMergingTools/libsh/mergeScriptRoot6.sh`
export isDataTuple=1

pushd $PWD/../condorMergingTools/
./submitMergeJobs.sh
popd
