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
crontab -l > mycron 2>/dev/null
#echo "* * * * * cd ${PWD} && /bin/sh ${PWD}/manager.sh >> ${PWD}/cron_log.log" >> mycron
echo "* * * * * cd ${PWD} && /bin/sh ${PWD}/manager.sh >> /nfs-7/userdata/dataTuple/dataTuple.log" >> mycron
crontab mycron
rm mycron
