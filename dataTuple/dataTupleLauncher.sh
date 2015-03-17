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

#Check Proxy
voms-proxy-info --all &> voms_status.txt
if grep "Couldn't find a valid proxy." voms_status.txt &>/dev/null
then
  echo "You don't have a proxy.  Creating one.  Please enter your password below."
  voms-proxy-init -valid 120:00
fi

#Submit
crontab -l > mycron 2>/dev/null
#echo "* * * * * cd ${PWD} && /bin/sh ${PWD}/manager.sh >> ${PWD}/cron_log.log" >> mycron
echo "* * * * * cd ${PWD} && timeout 3600 /bin/sh ${PWD}/manager.sh >> /nfs-7/userdata/dataTuple/dataTuple.log" >> mycron && if [ $? == 137 ]; then cp /nfs-7/userdata/dataTuple/dataTuple.log /home/users/$USER/public_html/error_log.log; echo "Warning.  Job was killed after 60 mins.  See log in uaf-7.t2.ucsd.edu/~cgeorge/error_log.log" | /bin/mail -r "george@physics.ucsb.edu" -s "[dataTuple] error report" "george@physics.ucsb.edu, jgran@physics.ucsb.edu"; fi 
crontab mycron
rm mycron
