import os, sys, commands

fh = open("instructions.txt", "r")
lines = fh.readlines()
fh.close()

basedir = "/hadoop/cms/store/group/snt/run2_25ns/"

print "#"*40
print "COULDN'T PARSE TAG: couldn't parse tag from Twiki"
print "SAMPLE NONEXISTENT: sample hadoop directory does not exist"
print "SAMPLE HAS NO VERSIONS: couldn't find CMS3 tag folders in sample hadoop directory"
print "NEWER TAG: folder exists with newer tag than what's on the Twiki"
print "#"*40

peopleIssues = {} # people are the keys, issues are the values, or maybe I we just have people issues
for line in lines:
    line = line.strip()
    dataset, tag, name, comments = line.split()
    valid = comments == "VALID"

    if(not valid): continue

    if(name not in peopleIssues): peopleIssues[name] = []

    try:
        tag = int(tag.replace("CMS3_V07-04-0",""))
    except:
        peopleIssues[name].append( "COULDN'T PARSE TAG: %s" % (dataset) )
        continue


    stat,out = commands.getstatusoutput("ls %s/%s" % (basedir, dataset))

    if stat != 0:
        peopleIssues[name].append( "SAMPLE NONEXISTENT: %s" % (dataset) )
        continue

    tags = []
    for t in out.split():
        t = t.replace("CMS3_","")
        if("_" in t): continue
        try:
            tags.append( int(t.replace("V07-04-0","")) )
        except:
            pass

    if(len(tags) < 1):
        peopleIssues[name].append( "SAMPLE HAS NO VERSIONS: %s" % (dataset) )
        print dataset, name, tags, out
        continue

    maxtag = max(tags)

    if(tag != maxtag):
        peopleIssues[name].append( "NEWER TAG (0%i vs 0%i): %s" % (maxtag, tag, dataset) )
    else:
        continue

    # if we're here, check to see that both directories have approx the same number of files
    stat,outold = commands.getstatusoutput("ls -1 %s/%s/V07-04-0%i/*.root | wc -l" % (basedir, dataset, tag))
    stat,outnew = commands.getstatusoutput("ls -1 %s/%s/V07-04-0%i/*.root | wc -l" % (basedir, dataset, maxtag))

    try: outold = int(outold)
    except: outold = 0

    try: outnew = int(outnew)
    except: outnew = 0


    if(outnew == 0): continue # if new directory has no root files, it's not ok to update twiki

    if(outnew > 2):
        print "[%s] It is ok to update the twiki to %s CMS3_V07-04-0%i" % (name, dataset, maxtag)


for person in peopleIssues:
    issues = peopleIssues[person]
    if(len(issues) < 1): continue

    for issue in issues:
        print "[%s] %s" % (person, issue)

