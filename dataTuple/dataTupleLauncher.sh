#Check arguments, set BASEPATH
if [ $# -eq 0 ] 
  then 
    BASEPATH="$PWD/basepath"
  else
    BASEPATH=$1
fi

if [ ! -d $BASEPATH ]
then
  mkdir -p $BASEPATH
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
echo "* * * * * cd ${PWD} && /bin/sh ${PWD}/manager.sh $BASEPATH >> $BASEPATH/dataTuple.log 2>&1" >> mycron;
echo "* * * * * cd ${PWD} && /bin/sh suicide.sh $BASEPATH" >> mycron
crontab mycron
rm mycron
