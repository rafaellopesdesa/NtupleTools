import mechanize
import argparse
import types
import os
import sys
import getpass


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
br.form[ 'username' ] = "namin"
password = getpass.getpass('Please enter your password for the UCSD twiki ')
br.form[ 'password' ] = password
br.submit()

for link in br.links():
  if (link.url == '/tastwiki/bin/view/CMS/Run2Samples_25ns'): br.follow_link(link)

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



#Open the file for reading
f = open('updateTwiki.txt', 'r');

#If making instructions for AutoTupler do that
nSamples = 0

f3 = open('instructions.txt', 'w');
for line in f:
  if("|" not in line): continue
  if("CMS3_" not in line): continue

  # print line

  theLine = line.split('|')

  nSamples += 1
  dataset = theLine[1].strip()
  xsec = theLine[5].strip()
  kfactor = theLine[6].strip()
  filtEff = theLine[7].strip()
  gTag = theLine[8].strip()
  CMS3Tag = theLine[9].strip()
  name = theLine[11].strip()
  comments = theLine[12].strip()
  comments = "INVALID" if "INVALID" in comments else "VALID"

  print dataset
  dataset = "_".join(dataset.split("/")[1:3])
  print dataset

  f3.write("%s %s %s %s\n" % (dataset, CMS3Tag, name, comments))

print "Instructions file written.  Check it carefully!  Change 'False' to 'True' for data samples!  Make sure the CMS3tag is the one you want!"
f3.close()

sys.exit()
