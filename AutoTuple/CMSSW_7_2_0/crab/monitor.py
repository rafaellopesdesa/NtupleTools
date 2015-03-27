from sys import argv
import linecache
import sys
import getpass
import os
import time
import datetime
import fileinput
import glob

#First argument tells whether need to run crab status or just use old output
args = sys.argv
tags = args[1:3]
samp = args[3:6]
parts = samp + tags + args[6:]

#Redo and timeout flag in case status check fails
redoFlag = True
timeout = 0

#File name (for status output) and crab dir (for crab task)
crab_dir = 'crab_' + parts[0].split('/')[1]+'_'+parts[0].split('/')[2]
filename = parts[0].split('/')[1]+'_'+parts[0].split('/')[2] + '_log.txt'

#username
user = getpass.getuser()

#Counters (for status page)
numer = 0
denom = 0 
nUnsubmitted = 0
nIdle = 0
nRunning = 0
nTransferring = 0
nTransferred = 0 
nFail = 0
nFailNoResubmit = 0
failFlag = False
queuedFlag = False

while (redoFlag == True and timeout < 10):

  #Redo and timeout flag in case status check fails
  redoFlag = False
  timeout += 1
  
  #Check status of jobs
  os.system('crab status ' + crab_dir + ' --long > ' + filename)
  os.system('web_autoTuple ' + filename + ' &>/dev/null')
  file = open(filename, "r")
  
  #Loop through status output, see what we have
  for line in file:
    if "Error contacting the server." in line:
      redoFlag = True
    if "QUEUED" in line: 
      queuedFlag = True
    if "finished" in line: 
      numer += int(((line.split('(')[1]).split(')')[0]).split('/')[0])
      denom = int(((line.split('(')[1]).split(')')[0]).split('/')[1])
    if "unsubmitted" in line:
      nUnsubmitted = int(((line.split('(')[1]).split(')')[0]).split('/')[0]) 
      denom = int(((line.split('(')[1]).split(')')[0]).split('/')[1])
    if "idle" in line:
      nIdle = int(((line.split('(')[1]).split(')')[0]).split('/')[0]) 
      denom = int(((line.split('(')[1]).split(')')[0]).split('/')[1])
    if "running" in line:
      nRunning = int(((line.split('(')[1]).split(')')[0]).split('/')[0]) 
      denom = int(((line.split('(')[1]).split(')')[0]).split('/')[1])
    if "transferring" in line:
      nTransferring = int(((line.split('(')[1]).split(')')[0]).split('/')[0]) 
      denom = int(((line.split('(')[1]).split(')')[0]).split('/')[1])
    if "transferred" in line:
      nTransferred = int(((line.split('(')[1]).split(')')[0]).split('/')[0]) 
      denom = int(((line.split('(')[1]).split(')')[0]).split('/')[1])
    if (("failed" in line) and not ("failed with exit code" in line) and not ("failed to read" in line)):
      failFlag = True
      nFail = int(((line.split('(')[1]).split(')')[0]).split('/')[0])
      denom = int(((line.split('(')[1]).split(')')[0]).split('/')[1])
    if ("failed with exit code 8001" in line):
      nFailNoResubmit += int(line.split(' jobs ')[0])
    if ("Extended Job Status Table" in line):
      break;
  file.close()

#Print output of status
inGoodRegion = 0
for line in fileinput.input('AutoTupleHQ.html', inplace=1):
  if "http://uaf-7.t2.ucsd.edu/~" + user + '/' + filename in line: 
    inGoodRegion = 1
  if inGoodRegion == 0 or inGoodRegion == 9: sys.stdout.write(line)
  if inGoodRegion == 1:
    sys.stdout.write(line)
    inGoodRegion = 2
    continue
  if inGoodRegion == 2:
    if queuedFlag == True: 
      sys.stdout.write('<font color="blue"> &nbsp; &nbsp; <b> Task is queued! <font color="black"></b><BR><BR> \n ')
      inGoodRegion = 9
      continue
    elif queuedFlag == False:
      sys.stdout.write('&nbsp; &nbsp; nUnsubmitted: ' + str(nUnsubmitted) + '/' + str(denom) + '<BR>\n')
      sys.stdout.write('&nbsp; &nbsp; idle: ' + str(nIdle) + '/' + str(denom) + '<BR>\n')
      inGoodRegion = 3
      continue
  if inGoodRegion == 3:
    sys.stdout.write('&nbsp; &nbsp; running: ' + str(nRunning) + '/' + str(denom) + '<BR>\n')
    inGoodRegion += 1
    continue 
  if inGoodRegion == 4:
    sys.stdout.write('&nbsp; &nbsp; transferring: ' + str(nTransferring) + '/' + str(denom) + '<BR>\n')
    inGoodRegion += 0.5
    continue 
  if inGoodRegion == 4.5:
    sys.stdout.write('&nbsp; &nbsp; transferred: ' + str(nTransferred) + '/' + str(denom) + '<BR>\n')
    inGoodRegion += 0.5
    continue 
  if inGoodRegion == 5:
    sys.stdout.write('&nbsp; &nbsp; failed, will resubmit: ' + str(nFail - nFailNoResubmit) + '/' + str(denom) + '<BR>\n')
    inGoodRegion += 1
    continue 
  if inGoodRegion == 6:
    sys.stdout.write('&nbsp; &nbsp; failed, will not resubmit: ' + str(nFailNoResubmit) + '/' + str(denom))
    if (nFailNoResubmit > 0): sys.stdout.write('<font color="red"> &nbsp; &nbsp;<b> <-- WARNING!  Job failed!! <font color="black"></b><BR> \n ') 
    else: sys.stdout.write('<BR> \n ')
    inGoodRegion += 1
    continue 
  if inGoodRegion == 7:
    sys.stdout.write('&nbsp; &nbsp; successful: ' + str(numer) + '/' + str(denom) + '<BR>\n')
    inGoodRegion += 1
    continue 
  if inGoodRegion == 8:
    sys.stdout.write('<b>&nbsp; &nbsp; finished: ' + str(numer+nFailNoResubmit) + '/' + str(denom) + '</b><BR> <BR>\n')
    inGoodRegion += 1
    continue 

#If above finished without writing anything, just append to the end
if (inGoodRegion == 0): 
  AutoTupleHQ = open("AutoTupleHQ.html", 'a')
  AutoTupleHQ.write('<A HREF="http://uaf-7.t2.ucsd.edu/~' + user + '/' + filename + '">' + filename.split('_log')[0] + '</A><BR>\n')
  if queuedFlag == False:
    AutoTupleHQ.write('&nbsp; &nbsp; unsubmitted: ' + str(nUnsubmitted) + '/' + str(denom) + '<BR>\n')
    AutoTupleHQ.write('&nbsp; &nbsp; idle: ' + str(nIdle) + '/' + str(denom) + '<BR>\n')
    AutoTupleHQ.write('&nbsp; &nbsp; running: ' + str(nRunning) + '/' + str(denom) + '<BR>\n')
    AutoTupleHQ.write('&nbsp; &nbsp; transferring: ' + str(nTransferring) + '/' + str(denom) + '<BR>\n')
    AutoTupleHQ.write('&nbsp; &nbsp; transferred: ' + str(nTransferred) + '/' + str(denom) + '<BR>\n')
    AutoTupleHQ.write('&nbsp; &nbsp; failed, will resubmit: ' + str(nFail - nFailNoResubmit) + '/' + str(denom) + '<BR>\n')
    AutoTupleHQ.write('&nbsp; &nbsp; failed, will not resubmit: ' + str(nFailNoResubmit) + '/' + str(denom))
    if (nFailNoResubmit > 0): AutoTupleHQ.write('<font color="red"> &nbsp; &nbsp;<b> <-- WARNING!  Job failed!! <font color="black"></b><BR> \n ') 
    else: AutoTupleHQ.write('<BR> \n ')
    AutoTupleHQ.write('&nbsp; &nbsp; successful: ' + str(numer) + '/' + str(denom) + '<BR>\n')
    AutoTupleHQ.write('<b>&nbsp; &nbsp; finished: ' + str(numer+nFailNoResubmit) + '/' + str(denom) + '</b><BR> <BR>\n')
  else: AutoTupleHQ.write('<font color="blue"> &nbsp; &nbsp; <b> Task is queued! <font color="black"></b><BR><BR> \n ')
  AutoTupleHQ.close()

#If finished, done
if (numer == denom and numer > 0): sys.exit(220)
elif (numer+nFailNoResubmit == denom and denom > 0): sys.exit(221)

#Otherwise, check to see if all files really are there
dir = '/hadoop/cms/store/user/' + user + '/' + parts[0].split('/')[1] + '/' + crab_dir + '/*/000*/*.root'
if (os.path.isdir(dir)): sys.exit(0)
dir2 = glob.glob(dir);
sys.exit(0)
