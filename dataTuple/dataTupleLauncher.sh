crontab -l > mycron
echo "* * * * * /bin/sh ${PWD}/manager.sh >> ${PWD}/cron_log.log" >> mycron
crontab mycron
rm mycron
