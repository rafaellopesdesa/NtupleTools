import sys, calendar, time

starttime = int(sys.argv[1])

if (calendar.timegm(time.gmtime()) - starttime > 24*60*60): exit('true')
else: exit('false')
