#!/bin/bash

files=$1
TIME=$2
OUTPUT_DIR=$3
OUTPUT_FILE_NAME=$4
MAX_NEVENTS=$5
GLOBAL_TAG=$6

while  ! voms-proxy-info -exist
do echo "No Proxy found issuing \"voms-proxy-init -voms cms\""
   voms-proxy-init -hours 168 -voms cms 
done

PSET="pset.py"
libCMSSW="lib_CMSSW.tar.gz"
INPUT="$PSET, $libCMSSW"
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

while read line
do

  INPUT_FILE_NAME=$line

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
  arguments=$PSET $libCMSSW $GLOBAL_TAG $INPUT_FILE_NAME $OUTPUT_DIR $OUTPUT_FILE_NAME $MAX_NEVENTS
  queue
  " > ${JOBCFGDIR}/condor_$OUTPUT_FILE_NAME.cmd
  
  condor_submit ${JOBCFGDIR}/condor_$OUTPUT_FILE_NAME.cmd

done < $files
