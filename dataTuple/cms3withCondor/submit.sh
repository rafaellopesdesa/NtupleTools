#!/bin/bash

files=$1
TIME=$2
OUTPUT_DIR=$3
DO_NTUPLE_NUMBER=$4

CMS3_TAG="CMS3_V07-04-03"
GLOBAL_TAG="MCRUN2_74_V9"

while  ! voms-proxy-info -exist
do echo "No Proxy found issuing \"voms-proxy-init -voms cms\""
   voms-proxy-init -hours 168 -voms cms 
done

if [ -e "/nfs-7/userdata/libCMS3/lib_${CMS3_TAG}.tar.gz" ]
then
  cp /nfs-7/userdata/libCMS3/lib_${CMS3_TAG}.tar.gz .
  libCMS3=lib_${CMS3_TAG}.tar.gz
else
  echo "libCMS3 file does not exist, will make on the fly."
  chmod 744 make_libCMS3.sh
  ./make_libCMS3.sh $CMS3_TAG
  if [ -e "libCMS3=lib_${CMS3_TAG}.tar.gz" ]
  then
    libCMS3=lib_${CMS3_TAG}.tar.gz
  else
    echo "Failed to make libCMS3 tarball on the fly!"
    exit 1
  fi
fi

PSET="pset.py"
INPUT="$PSET, $libCMS3"
SITE="T2_US_UCSD,T2_US_Nebraska,T2_US_Wisconsin,T2_US_MIT,T2_US_FLORIDA"
PROXY=$(voms-proxy-info -path)
SUBMITLOGDIR="${PWD}/submit_logs"
JOBLOGDIR="${PWD}/job_logs"
JOBCFGDIR="${PWD}/job_cfg/$TIME"
LOG="${SUBMITLOGDIR}/condor_$TIME.log"
OUT="${JOBLOGDIR}/1e.\$(Cluster).\$(Process).out"
ERR="${JOBLOGDIR}/1e.\$(Cluster).\$(Process).err"

if [ ! -d "${SUBMITLOGDIR}" ]; then
    mkdir -p ${SUBMITLOGDIR}
fi

if [ ! -d "${JOBLOGDIR}" ]; then
    mkdir -p ${JOBLOGDIR}
fi

if [ ! -d "${JOBCFGDIR}" ]; then
    mkdir -p ${JOBCFGDIR}
fi

number=0
while read line
do

  let "number=$number+1"

  INPUT_FILE_NAME=$line

  if (( $# == 4 )) && [ "$DO_NTUPLE_NUMBER" == "true" ]
  then
    OUTPUT_FILE_NAME="ntuple_$number.root"
  elif (( $# == 4 )) && [ "$DO_NTUPLE_NUMBER" != "true" ]
  then
    echo "Need to supply OUTPUT_FILE_NAME argument or set DO_NTUPLE_NUMBER = true"
    exit 1
  elif (( $# == 5 )) && [ "$DO_NTUPLE_NUMBER" == "true" ]
  then
    echo "Error: If passing OUTPUT_FILE_NAME argument, must set DO_NTUPLE_NUMBER = false"
    exit 1
  else
    OUTPUT_FILE_NAME=$5
  fi

  echo "
  universe=grid
  Grid_Resource=condor cmssubmit-r1.t2.ucsd.edu glidein-collector.t2.ucsd.edu
  when_to_transfer_output = ON_EXIT
  transfer_input_files=${INPUT}
  transfer_output_files = /dev/null
  +DESIRED_Sites=\"${SITE}\"
  +Owner = undefined
  +isDataTupleCMS3flagged="true"
  log=${LOG}
  output=${OUT}
  error =${ERR}
  notification=Never
  x509userproxy=${PROXY}
  executable=condorExecutable.sh
  transfer_executable=True
  arguments=$PSET $libCMS3 $GLOBAL_TAG $INPUT_FILE_NAME $OUTPUT_DIR $OUTPUT_FILE_NAME
  queue
  " > ${JOBCFGDIR}/condor_$OUTPUT_FILE_NAME.cmd
  
  condor_submit ${JOBCFGDIR}/condor_$OUTPUT_FILE_NAME.cmd

done < $files
