from sys import argv
import linecache
import sys
import os
import time
import datetime
import getpass
import fileinput

user = getpass.getuser()
if (user == "dsklein"): user = dklein;
if (user == "iandyckes"): user = gdyckes;
if (user == "mderdzinski"): user = mderdzin;
user2 = getpass.getuser()
args = sys.argv
gtag = args[1]
tag = args[2]
samp = args[3:6]
parts = samp
parts.append(tag)
parts.append(gtag)
parts += args[6:]

completelyDone = False
dataSet = parts[0].split('/')[1]
nLoops = 0
nEventsIn = 0
temp = "temp" + parts[0].split('/')[1] + ".txt"

#time.sleep(30)

while (completelyDone == False):
  #Submit all the jobs
  date=str(datetime.datetime.now().strftime('%y-%m-%d_%H:%M:%S'))
  crab_dir = 'crab_' + parts[0].split('/')[1]+'_'+parts[0].split('/')[2]
  os.system('python makeListsForMergingCrab3.py -c ' + crab_dir + ' -d /hadoop/cms/store/user/' + user + '/' + parts[0].split('/')[1] + '/' + crab_dir + '/*/0000/ -o /hadoop/cms/store/user/' + user + '/' + parts[0].split('/')[1] + '/' + crab_dir + '/' + parts[3] + '/merged/ -s ' + parts[0].split('/')[1] + ' -k ' + parts[2] + ' -e 1 -x ' + parts[1] + ' --overrideCrab > ' + temp)
  file = open(temp, "r")
  if nLoops == 0:
    for line in file:
      if "Total number of events run over" in line: nEventsIn = int(line.split(":")[1])
  os.system('./submitMergeJobs.sh cfg/' + parts[0].split('/')[1] + '_cfg.sh ' + date + ' > ' + temp)  

  #See if any jobs were submitted (will be false when resubmission not needed):
  file = open(temp, "r")
  for line in file:
    if "Check status of jobs with condor_q" in line: 
      nLeft = int(line.split(" jobs submitted")[0])
  file.close()

  #If no jobs were submitted, we are done, update monitor
  if (nLeft == 0): 
    completelyDone = True
    update = -1
    for line in fileinput.input('AutoTupleHQ.html', inplace=1):
      if line.startswith('<A HREF="http://uaf-7.t2.ucsd.edu/~' + user2 + '/' + dataSet): 
        update = 0
        sys.stdout.write(line)
      elif (update >= 0 and update < 6): 
        update += 1
        sys.stdout.write(line)
      elif (update == 6):
        if (nLoops == 0): sys.stdout.write(line[0:line.rfind("<BR>")])
        else: sys.stdout.write(line)
        update = -1
        sys.stdout.write('\n<b><font color="blue"> &nbsp; &nbsp; Post-processing finished! </b> nEvents in: ' + str(nEventsIn) + '<font color="black"> <BR><BR> \n')
      elif (update > -1 and line.startswith('<A HREF="http://uaf-7.t2.ucsd.edu/~' + user2 + '/')): 
        sys.stdout.write(line)
        update = -1
      elif (update > -1):
        if not "Post" in line: sys.stdout.write(line)
      else:
        sys.stdout.write(line)
    os.system('web_autoTuple AutoTupleHQ.html &>/dev/null')
    continue
 
  #Get ID numbers of jobs submitted
  ids = []
  done = []
  log_list = 'jobs_' + date + '.txt'
  os.system('ls -lthr /data/tmp/' + user2 + '/' + dataSet + '/' + date + '/std_logs/ > ' + log_list)
  file = open(log_list, "r")
  for line in file:
    if '.out' in line: 
      ids.append( ((line.split()[8]).split('.out')[0]).split('1e.')[1])
      done.append( False )
  
  #See if jobs are finished yet.  
  isDone = False
  while (isDone == False):
    if not False in done: continue
    for i in range(0, len(ids)):
      if done[i] == True: continue
      os.system('condor_q ' + ids[i] + ' > ' + temp)
      file = open(temp, "r")
      for line in file:
        stillRunning = False
        if ids[i] in line: stillRunning = True
      if stillRunning == False: done[i] = True
    if not False in done: isDone = True
    nFinished = done.count(True)
    #Update logs
    update = -1
    for line in fileinput.input('AutoTupleHQ.html', inplace=1):
      if line.startswith('<A HREF="http://uaf-7.t2.ucsd.edu/~' + user2 + '/' + dataSet): 
        update = 0
        sys.stdout.write(line)
      elif (update >= 0 and update < 6): 
        update += 1
        sys.stdout.write(line)
      elif (update == 6):
        if (nLoops == 0): sys.stdout.write(line[0:line.rfind("<BR>")])
        else: sys.stdout.write(line)
        update += 1 
        sys.stdout.write('\n<b><font color="blue"> &nbsp; &nbsp; Post-processing started! </b> nEvents in: ' + str(nEventsIn) + '<font color="black"> <BR> \n')
        sys.stdout.write("&nbsp; &nbsp; PostProcessed: " + str(nFinished) + "/" + str(len(done)) + ' <BR><BR> \n')
      elif line.startswith('<A HREF="http://uaf-7.t2.ucsd.edu/~' + user2): 
        update = -1
        sys.stdout.write(line)
      elif (update > -1):
        if not "Post" in line: sys.stdout.write(line)
      else:
        sys.stdout.write(line)
    os.system('web_autoTuple AutoTupleHQ.html &>/dev/null')
    nLoops += 1
    time.sleep(180)
