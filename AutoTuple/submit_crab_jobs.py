from sys import argv
import linecache
import sys
import os

script, inFile = argv

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

lnum = 1
while (lnum <= inFile_size):
  line = linecache.getline(inFile, lnum)
  parts = line.split()
  os.system('./FindLumisPerJob.sh ' + parts[0] + ' >> LumisPerJob.txt')
  lumi_line = linecache.getline('LumisPerJob.txt', lnum)
  lumi_parts = lumi_line.split()
  numLumiPerJob = lumi_parts[0]
  print numLumiPerJob
  command = 'python makeCrab3Files.py -CMS2cfg skeleton_cfg.py -d ' + parts[0] + ' -t ' + parts[3] + ' -gtag ' + parts[4] + ' -isData ' + parts[5] + ' -lumisPerJob ' + numLumiPerJob
  if len(parts) > 6:
    command += ' -sParms ' + parts[6]
  print command
  os.system(command)
  crab_dir = parts[0].split('/')[1]+'_'+parts[0].split('/')[2]
  os.system('crab submit -c cfg/' + crab_dir + '.py')
  print crab_dir
  lnum+=1
