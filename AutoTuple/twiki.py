import mechanize
import argparse
import types
import os
import sys
import getpass

#Arguments should be what you want to change:
  #--makeInstructions USERNAME if only want to make the AutoTupler instructions file
  #If you want to update the twiki, then use:
  #--dataset to indicate the sample or sample class that you want to modify
  #--xsec, kfactor, filtEff, globalTag, CMS3tag, location, nIn, nOut to specify what you want to change

#First parse the arguments
parser = argparse.ArgumentParser(description='Update Phys14 samples twiki.  \n Use --makeInstructions USERNAME to make the AutoTupler instructions file.  Use the other arguments to modify the twiki.')
parser.add_argument('username'          , type=types.StringType, help='username to log into the UCSD twiki')
parser.add_argument('--dataset'         , type=types.StringType, help='a specific dataset.')
parser.add_argument('--xsec'            , type=types.FloatType , help='cross-section in pb')
parser.add_argument('--kfactor'         , type=types.FloatType , help='k-factor, used to adjust the xsec (which should agree with MCM) to the most accurate value (from theory papers, etc.)')
parser.add_argument('--filtEff'         , type=types.FloatType , help='filter efficiency of filters applied TO THE PHYS 14 SAMPLE (not filters we applied when making CMS3 or babies)') 
parser.add_argument('--gTag'            , type=types.StringType, help='global tag used to make CMS3')
parser.add_argument('--CMS3tag'         , type=types.StringType, help='CMS3 tag -- which version of CMS3 was used')
parser.add_argument('--location'        , type=types.StringType, help='location of output on hadoop') 
parser.add_argument('--nIn'             , type=types.IntType   , help='number of events in (from MCM)')
parser.add_argument('--nOut'            , type=types.IntType   , help='number of events on the hadoop directory (should equal nIn unless there is a filter somewhere)')
parser.add_argument('--makeInstructions', type=types.StringType, help='username for AutoTupler instructions file.  Leave blank if not making instructions file') 
parser.add_argument('--manual'          , type=types.IntType   , help='use this argument to manually change the twiki.  Argument: 1 to download updateTwiki2.txt and 2 to upload updateTwiki2.txt') 
parser.add_argument('--allSamples'      , type=types.IntType  , help='use this argument to download all samples. Argument: 1') 
args = parser.parse_args()

#Error checking
if (args.manual == None and  args.dataset == None and args.makeInstructions == None and args.allSamples == None):
  print "Aborting! Need to specify either --manual or --dataset or --makeInstructions or --allSamples!"
  sys.exit()
if (args.manual != None and (args.dataset != None or args.makeInstructions != None or args.allSamples != None)):
  print "Aborting! Cannot have more than 1 of (manual, dataset, makeInstructions) at once"
  sys.exit()
if (args.dataset != None and (args.manual != None or args.makeInstructions != None or args.allSamples != None)):
  print "Aborting! Cannot have more than 1 of (manual, dataset, makeInstructions) at once"
  sys.exit()
if (args.dataset != None and (args.makeInstructions != None or args.manual != None or args.allSamples != None)):
  print "Aborting! Cannot have more than 1 of (manual, dataset, makeInstructions) at once"
  sys.exit()
if (args.allSamples != None and (args.makeInstructions != None or args.manual != None or args.dataset != None)):
  print "Aborting! Cannot have more than 1 of (manual, dataset, makeInstructions) at once"
  sys.exit()
if (args.manual != 1 and args.manual != 2 and args.manual != None):
  print "Aborting! Need to specify either 1 (download) or 2 (upload) for manual"
  sys.exit()
if (args.manual != None and (args.gTag != None or args.CMS3tag != None or args.location != None or args.nIn != None or args.nOut != None)):
  print "Aborting! Cannot have manual specified with other options."  
  sys.exit()
if (args.makeInstructions != None and (args.gTag != None or args.CMS3tag != None or args.location != None or args.nIn != None or args.nOut != None)):
  print "Aborting! Cannot have makeInstructions specified with other options."  
  sys.exit()

#Warnings
if (args.manual == 2):
  print "Warning! Going to COMPLETELY replace the twiki with the contents of updateTwiki2.txt.  Make SURE this file is OK!"
  check = raw_input("Type 'yes' to confirm that this file is good, will exit for any other value ")
  if (check != "yes"): 
    print "You did not type yes.  Aborting..."
    sys.exit() 

#Set up a browser
br = mechanize.Browser()

#State that you're not a bot (!)
br.addheaders = [('User-agent', 'Firefox')]

#Ignore robots.txt
br.set_handle_robots( False )

#Now open the twiki login page
r = br.open('http://www.t2.ucsd.edu/tastwiki/bin/login/CMS/')

#Select the first form (which containts all the fields)
br.select_form(nr=0)

#Put in username and password, and submit
br.form[ 'username' ] = args.username
password = getpass.getpass('Please enter your password for the UCSD twiki ')
br.form[ 'password' ] = password
br.submit()

#Look for the link to Phys14 from our home page

which = 0
while (which != 1 and which != 2 and which != 3): 
  which = int(raw_input("Which one do you want?  Type 1 for phys14, 2 for run2_25ns, or 3 for run2_50ns "))

hadoopDirs = ["phys14", "run2_25ns", "run2_50ns"]
os.system("echo \"" + hadoopDirs[which-1] + "\" > theDir.txt")
for link in br.links():
  if (which == 1 and link.url == '/tastwiki/bin/view/CMS/Phys14Samples'): br.follow_link(link)
  if (which == 2 and link.url == '/tastwiki/bin/view/CMS/Run2Samples_25ns'): br.follow_link(link)
  if (which == 3 and link.url == '/tastwiki/bin/view/CMS/Run2Samples_50ns'): br.follow_link(link)

#Look for the link to 'raw edit'
for link in br.links():
  if (link.url[-11:] == 'nowysiwyg=1'):
    br.follow_link(link)

#Select the first form
try:
  br.select_form('main')
except mechanize._mechanize.FormNotFoundError:
  if("oopsleaseconflict" in str(br)):
    print "Looks like user ", str(br).split("param1=Main.")[-1].split(";")[0], " is editing right now. Aborting..."
  else:
    print "Invalid username or password! Aborting...."

  sys.exit()

#Read the text to updateTwiki.txt
os.system('rm updateTwiki.txt &> /dev/null')
f = open('updateTwiki.txt', 'w');
f.write(br.get_value('text'))
f.close()

#If manual stage 1, copy this and you're done
if (args.manual == 1):
  os.system('cp updateTwiki.txt updateTwiki2.txt')
  sys.exit()

#If manual stage 2, upload and you're done
if (args.manual == 2): 
  blah = ""
  f4 = open('updateTwiki2.txt', 'r')
  for line in f4: blah += line
  br.form[ 'text' ] = blah
  br.submit()
  sys.exit()  

#Open the file for reading
f = open('updateTwiki.txt', 'r');

#If getting all samples, do that
if (args.allSamples != None):
  f5 = open('allsamples.txt', 'w');
  for line in f:
    if (line.find('|') != -1):
      theLine = line.split('|')
      dataset = theLine[1]
      if (dataset.find('/') != -1): f5.write(dataset + '\n')
  f5.close()
  sys.exit()

#If making instructions for AutoTupler do that
gTag = ""
CMS3Tag = ""
nSamples = 0
if (args.makeInstructions != None):
  f3 = open('instructions.txt', 'w');
  for line in f:
    if (line.find(args.makeInstructions) != -1):
      #If you found one of your samples
      nSamples += 1
      theLine = line.split('|')
      dataset = theLine[1]
      xsec = theLine[5]
      kfactor = theLine[6]
      filtEff = theLine[7]
      if (gTag != "" and gTag != theLine[8]): 
        print "Critical Warning!!! Two different global tags!. Picking one at random..."
      if (CMS3Tag != "" and CMS3Tag != theLine[9]): 
        print "Critical Warning!!! Two different CMS3 tags!.  Picking one at random..."
      gTag = theLine[8]
      CMS3Tag = theLine[9]
      Comments = theLine[12]
      sparms = ""
      if (Comments[1:8] == "sParms:"):
        sparms = Comments[8:]
      sparms = sparms.replace(' ', '')
      CMS3tag = theLine[9] 
      if (filtEff[len(filtEff)-2] == "%"): filtEff = str(float(filtEff[1:-2])*0.01)

      #Write to instructions file
      if (nSamples == 1): 
        f3.write(gTag + '\n')
        f3.write(CMS3Tag + '\n')
      f3.write(dataset + str(xsec) + str(kfactor) + str(filtEff) + ' False ' + sparms + '\n')

  if (nSamples == 0):
    print "No samples found for user ", args.makeInstructions, ".  Aborting"
    sys.exit()
  else:
    print "Instructions file written.  Check it carefully!  Change 'False' to 'True' for data samples!  Make sure the CMS3tag is the one you want!"
    f3.close()
    os.system('sed -i "1,2s/\ //g" instructions.txt')
    os.system("sed -i '3,$s/\ //' instructions.txt")

#Done if making instructions
if (args.makeInstructions != None): sys.exit()

#Search for the dataset
foundIt = False
f2 = open('updateTwiki2.txt', 'w');
for line in f:
  if (line.find(args.dataset) != -1):
    #If you found it:
    foundIt = True
    theLine = line.split('|')
    if (args.xsec     != None):  theLine[5]=' ' + str(float(args.xsec))    + ' ' 
    if (args.kfactor  != None):  theLine[6]=' ' + str(float(args.kfactor)) + ' ' 
    if (args.filtEff  != None):  theLine[7]=' ' + str(float(args.filtEff)) + ' ' 
    if (args.gTag     != None):  theLine[8]=' ' + str(args.gTag)           + ' ' 
    if (args.CMS3tag  != None):  theLine[9]=' ' + str(args.CMS3tag)        + ' ' 
    if (args.location != None): theLine[10]=' ' + str(args.location)       + ' ' 
    if (args.nIn      != None):  theLine[3]=' ' + str(int(args.nIn))       + ' ' 
    if (args.nOut     != None):  theLine[4]=' ' + str(int(args.nOut))      + ' ' 

    #Then fix the line
    newLine = ""
    for i in range(0, len(theLine)-1): newLine+=(str(theLine[i]) + '|')
    newLine += str(theLine[len(theLine)-1])

    #Then replace the old line with the new one
    f2.write(newLine)
  else:
    f2.write(line);

f.close()
f2.close()

#otherwise return
if (foundIt == False): 
  print "Error!  Could not find dataset!" 
  sys.exit()

#Now upload the new version to the site
blah = ""
f4 = open('updateTwiki2.txt', 'r')
for line in f4:
  blah += line
br.form[ 'text' ] = blah
br.submit()

