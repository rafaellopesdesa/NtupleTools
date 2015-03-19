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

if [ -e /nfs-7/userdata/dataTuple/suicide.txt ]
then
  rm /nfs-7/userdata/dataTuple/suicide.txt
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
echo "*/30 * * * * cd ${PWD} && /bin/sh ${PWD}/manager.sh >> /nfs-7/userdata/dataTuple/dataTuple.log" >> mycron;
echo "*/5 * * * * cd ${PWD} && /bin/sh suicide.sh" >> mycron
crontab mycron
rm mycron
