from sys import argv
import linecache
import sys
import os
import sys
import datetime
import getpass
import fileinput
import glob

script, inFile = argv
lines = [ line.strip() for line in open(inFile)]
gtag = lines[0]
tag = lines[1]

#pirate stuff
f = open('pirate.txt', 'r')
me_ship = f.read()
print (me_ship)
f.close()

p = os.popen('wc -l < ' + inFile)
s = p.readline()
p.close()
inFile_size = int(s)

try:
    os.remove('LumisPerJob.txt')
except OSError:
    pass

lnum = 3
while (lnum <= inFile_size): 
  print "checking file on line", lnum, "for size and validity."
  line = linecache.getline(inFile, lnum)
  parts = line.split()
  os.system('./FindLumisPerJobNoDAS.sh ' + parts[0] + ' >> LumisPerJob.txt')
  lnum+=1

for line in open("LumisPerJob.txt"):
  if "Aborting" in line: 
    print "One of your samples is invalid!  See LumisPerJob.txt for details."
    sys.exit() 

lnum = 3
redoCrab = 2
while (lnum <= inFile_size):
  line = linecache.getline(inFile, lnum)
  parts = line.split()
  lumi_line = linecache.getline('LumisPerJob.txt', lnum-2)
  lnum+=1
  lumi_parts = lumi_line.split()
  numLumiPerJob = lumi_parts[0]
  if ((len(glob.glob("/hadoop/cms/store/user/" + getpass.getuser() + "/" + parts[0].split('/')[1] + "/crab_" + parts[0].split('/')[1] + "_" + parts[0].split('/')[2] + "/*/0000/*.root")) > 0) and redoCrab != 1):
    while (redoCrab != 0 and redoCrab != 1):  redoCrab = int(input("Some unmerged files already exist!  Remake them? (1/0) "))
    if (redoCrab == 0): 
      f = open("crab_status_logs/noCrab_" + parts[0].split('/')[1] + "_" + parts[0].split('/')[2] + ".txt", 'w+')
      f.write("yes")
      f.close()
      continue
  print numLumiPerJob
  isFsim = False
  if "FSPremix" in parts[0]: 
    isFsim = true
    print "Detected fastsim"
    command = 'python makeCrab3Files.py -CMS3cfg skeleton_fsim_cfg.py -d ' + parts[0] + ' -t ' + tag + ' -gtag ' + gtag + ' -lumisPerJob ' + numLumiPerJob
  else:
    command = 'python makeCrab3Files.py -CMS3cfg skeleton_cfg.py -d ' + parts[0] + ' -t ' + tag + ' -gtag ' + gtag + ' -lumisPerJob ' + numLumiPerJob
  if len(parts) > 5:
    command += ' -sParms ' + parts[5]
  if parts[0].endswith("/USER"):
    command += ' -dbs phys03'
    print "Found USER dataset, so setting dbs_url to phys03"
  print command
  os.system(command)
  crab_dir = parts[0].split('/')[1]+'_'+parts[0].split('/')[2]
  os.system('crab submit -c cfg/' + crab_dir + '.py')
  print crab_dir
