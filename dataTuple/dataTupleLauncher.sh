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
echo "* * * * * cd ${PWD} && /bin/sh ${PWD}/manager.sh >> /nfs-7/userdata/dataTuple/dataTuple.log" >> mycron
crontab mycron
rm mycron
