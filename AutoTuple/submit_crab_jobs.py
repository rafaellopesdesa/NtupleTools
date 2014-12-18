from sys import argv
import linecache
import sys
import os

script, inFile = argv

p = os.popen('wc -l < ' + inFile)
s = p.readline()
p.close()
inFile_size = int(s)

lnum = 1
while (lnum <= inFile_size):
  line = linecache.getline(inFile, lnum)
  parts = line.split()
  command = 'python makeCrab3Files.py -CMS2cfg skeleton_cfg.py -d ' + parts[0] + ' -t ' + parts[3] + ' -gtag ' + parts[4] + ' -isData ' + parts[5]
  if len(parts) > 6:
    command += ' -sParms ' + parts[6]
  os.system(command)
  crab_dir = parts[0].split('/')[1]+'_'+parts[0].split('/')[2]
  os.system('crab submit -c cfg/' + crab_dir + '.py')
  print crab_dir
  lnum+=1
