#Check arguments, set BASEPATH, JOBTYPE
while getopts ":b:t:h:" opt; do
  case $opt in
    b) BASEPATH="$OPTARG";;
    h) echo "./dataTupleLauncher -b PATH_TO_BASEPATH -t CMS3";;
    t)
       if [ $OPTARG == "cms3" ]
       then
         JOBTYPE="$OPTARG"
       elif [ $OPTARG == "user" ]
       then
         JOBTYPE="$OPTARG"
       else
         echo "Invalid argument \"-t $OPTARG\"." >&2
         echo "Acceptable arguments for -t flag are \"cms3\" and \"user\"."
         exit 1
       fi
    ;;
    \?) echo "Invalid option -$OPTARG" >&2; exit 1;;
    : ) echo "Missing option argument for -$OPTARG" >&2; exit 1;;
    * ) echo "Unimplemented option: -$OPTARG" >&2; exit 1;;
  esac
done

if [ ! -d $BASEPATH ]
then
  mkdir -p $BASEPATH
fi

if [ ! -d $BASEPATH ]
then
  "BASEPATH $BASEPATH does not exist and could not be created."
  exit 1
fi

if [ ! -d DataTuple-backup ] && [ "$JOBTYPE" == "cms3" ]
then
  git clone ssh://git@github.com/cmstas/DataTuple-backup
fi

if [ ! -d DataTuple-backup ] && [ "$JOBTYPE" == "cms3" ] 
then
  echo "Failed to create the DataTuple-backup dir.  You're fucked!"
  exit 1 
fi

chmod +x ./*.sh
chmod +x ./*.py
if [ -e submitList.txt ]
then
  rm submitList.txt
fi
if [ -e runningList.txt ]
then
  rm runningList.txt
fi

if [ -e nQueryAttempts.txt ] 
then
  rm nQueryAttempts.txt &>/dev/null
fi

if [ -e emailAboutProxy.txt ] 
then 
  rm emailAboutProxy.txt
fi 

if [ -e cycleNumber.txt ] 
then 
  rm cycleNumber.txt
fi 

if [ -e $BASEPATH/suicide.txt ]
then
  rm -f $BASEPATH/suicide.txt
fi

#Check Proxy
voms-proxy-info --all &> voms_status.txt
if grep "Couldn't find a valid proxy." voms_status.txt &>/dev/null
then
  echo "You don't have a proxy.  Creating one.  Please enter your password below."
  voms-proxy-init -valid 120:00
fi

#Submit
crontab -l > mycron 2>/dev/null
echo "*/30 * * * * cd ${PWD} && /bin/sh ${PWD}/manager.sh -b $BASEPATH -t $JOBTYPE >> $BASEPATH/dataTuple.log 2>&1" >> mycron;
echo "*/10 * * * * cd ${PWD} && /bin/sh suicide.sh $BASEPATH" >> mycron
echo "*/10 * * * * cd ${PWD} && /bin/sh inspectLog.sh $BASEPATH" >> mycron
crontab mycron
rm mycron
