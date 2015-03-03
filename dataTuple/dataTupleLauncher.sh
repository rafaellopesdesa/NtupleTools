chmod +x ./*.sh
chmod +x ./*.py
crontab -l > mycron
echo "* * * * * cd ${PWD} && /bin/sh ${PWD}/manager.sh >> ${PWD}/cron_log.log" >> mycron
crontab mycron
rm mycron
