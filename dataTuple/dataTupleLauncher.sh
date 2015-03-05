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
crontab -l > mycron
echo "* * * * * cd ${PWD} && /bin/sh ${PWD}/manager.sh >> ${PWD}/cron_log.log" >> mycron
crontab mycron
rm mycron
