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
  line = linecache.getline(inFile, lnum)
  parts = line.split()
  os.system('./FindLumisPerJob.sh ' + parts[0] + ' >> LumisPerJob.txt')
  lnum+=1

lnum = 3
redoCrab = 2
while (lnum <= inFile_size):
  line = linecache.getline(inFile, lnum)
  parts = line.split()
  lumi_line = linecache.getline('LumisPerJob.txt', lnum-2)
  lumi_parts = lumi_line.split()
  numLumiPerJob = lumi_parts[0]
  if ((len(glob.glob("/hadoop/cms/store/user/" + getpass.getuser() + "/" + parts[0].split('/')[1] + "/crab_" + parts[0].split('/')[1] + "_" + parts[0].split('/')[2] + "/*/0000/*.root")) > 0) and redoCrab == 2):
    redoCrab = int(input("Some unmerged files already exist!  Remake them? (1/0)"))
  if (redoCrab == 0): continue
  print numLumiPerJob
  command = 'python makeCrab3Files.py -CMS3cfg skeleton_cfg.py -d ' + parts[0] + ' -t ' + tag + ' -gtag ' + gtag + ' -isData ' + parts[3] + ' -lumisPerJob ' + numLumiPerJob
  if len(parts) > 4:
    command += ' -sParms ' + parts[4]
  print command
  os.system(command)
  crab_dir = parts[0].split('/')[1]+'_'+parts[0].split('/')[2]
  os.system('crab submit -c cfg/' + crab_dir + '.py')
  print crab_dir
  lnum+=1
