#! /usr/bin/env python

import string
import commands, os, re
import sys 

cmsswSkelFile = ''
configPfx = 'cfg/'
psetPfx = 'pset/'
dataSet = ''
numLumisPerJob = 1000
outNtupleName = 'ntuple.root'
storageElement = 'T2_US_UCSD'
tag = 'V07-00-03'
dbs_url = 'global'
report_every = 1000;
global_tag = '';
sParms = [];

def makeCrab3Config():
    outFileName = dataSet.split('/')[1]+'_'+dataSet.split('/')[2]
    outFile = open(configPfx + outFileName + '.py', 'w')
    print 'Writing CRAB config file: ' + configPfx + outFileName + '.py'

    outFile.write('from WMCore.Configuration import Configuration\n')
    outFile.write('config = Configuration()\n')
    outFile.write('config.section_(\'General\')\n')
    outFile.write('config.General.transferOutputs = True\n')
    outFile.write('config.General.transferLogs = True\n')
    outFile.write('config.General.requestName = \'%s\'\n' % outFileName)
    outFile.write('\n')
    outFile.write('config.section_(\'JobType\')\n')
    outFile.write('config.JobType.inputFiles = [ 'Summer15_50nsV4_MC.db' ]')
    outFile.write('config.JobType.pluginName = \'Analysis\'\n')
    outFile.write('config.JobType.psetName = \'%s_cfg.py\'\n' % ('./' + psetPfx + outFileName))
    outFile.write('\n')
    outFile.write('config.section_(\'Data\')\n')
    outFile.write('config.Data.inputDataset = \'%s\'\n' % dataSet)
    outFile.write('config.Data.publication = False\n')
    outFile.write('config.Data.unitsPerJob = %i \n' % int(numLumisPerJob))
    outFile.write('config.Data.splitting = \'LumiBased\'\n')
    outFile.write('config.Data.inputDBS = \'%s\'\n' % dbs_url)
    #outFile.write('config.Data.ignoreLocality = True\n')
    outFile.write('\n')
    outFile.write('config.section_(\'User\')\n')
    outFile.write('\n')
    outFile.write('config.section_(\'Site\')\n')
    outFile.write('config.Site.storageSite = \'T2_US_UCSD\'\n')
    #outFile.write('config.Site.whitelist = [\'T2_US_Caltech\',\'T2_US_Florida\', \'T2_US_MIT\', \'T2_US_Nebraska\', \'T2_US_Purdue\', \'T2_US_UCSD\', \'T2_US_Vanderbilt\', \'T2_US_Wisconsin\']\n')
    outFile.write('\n')
	 
#
def makeCMSSWConfig(cmsswSkelFile):
    foundOutNtupleFile = False
    foundreportEvery   = False
    foundcmsPath       = False
    inFile = open(cmsswSkelFile, 'r').read().split('\n')
    nlines = 0
    iline  = 0
    for i in inFile:
        nlines += 1
        if i.find(outNtupleName) != -1:
            foundOutNtupleFile = True
        if i.find('reportEvery') != -1:
            foundOutNtupleFile = True
    if foundOutNtupleFile == False:
        print 'The root file you are outputting is not named ntuple.root as it should be for a CMS3 job.'
        print 'Please check the name of the output root file in your PoolOutputModule, and try again'
        print 'Exiting!'
        sys.exit()
    psetPfx = 'pset/'
    outFileName = dataSet.split('/')[1]+'_'+dataSet.split('/')[2] + '_cfg.py'
    print 'Writing CMS3 CMSSW python config file : ' + psetPfx + outFileName
    outFile = open(psetPfx + outFileName, 'w')
    outFile.write( 'import sys, os' + '\n' + 'sys.path.append( os.getenv("CMSSW_BASE") + "/src/CMS3/NtupleMaker/test" )' + '\n' )
    for i in inFile:
        iline += 1
        if i.find('reportEvery') != -1:
            outFile.write('process.MessageLogger.cerr.FwkReport.reportEvery = ' + str(report_every) + '\n'); continue

        if i.find('globaltag') != -1:
            outFile.write('process.GlobalTag.globaltag = "' + global_tag + '"\n'); continue

        if (i.find('cms.Path') != -1 and foundcmsPath == False ):
            foundcmsPath = True            
            outFile.write('process.eventMaker.datasetName                   = cms.string(\"' + dataSet+'\")\n')
            outFile.write('process.eventMaker.CMS3tag                       = cms.string(\"' + tag+'\")\n')

        outFile.write(i)
        if iline < nlines:
            outFile.write('\n')

    if len(sParms) > 0:
        outFile.write('process.sParmMaker.vsparms = cms.untracked.vstring(\n')
        for sParm in sParms:
            if sParm != sParms[-1]:  #assumes the list is populated with unique entries
                sParm = '\"%s\",'%sParm
            else:
                sParm = '\"%s\"'%sParm
            outFile.write('%s\n'%sParm)
        outFile.write(') # list of sparm parameters, be sure it is the same size as the number of parameter in the files\n')
        outFile.write('process.p.insert( -1, process.sParmMakerSequence ) #adds the sparm producer in to the sequence\n')

    outFile.close()

def checkConventions():
    if( not os.path.isdir('./'+configPfx) ):
        print 'Directory for configs (%s) does not exist. Creating it.' % configPfx
        os.makedirs('./'+configPfx)

    if( not os.path.isdir('./'+psetPfx) ):
        print 'Directory for psets (%s) does not exist. Creating it.' % psetPfx
        os.makedirs('./'+psetPfx)

    
    print 'CRAB submission should happen outside of {%s,%s}' % (configPfx, psetPfx)

if len(sys.argv) < 9 :
    print 'Usage: makeCrabFiles.py [OPTIONS]'
    print '\nWhere the required options are: '
    print '\t-CMS3cfg\tname of the skeleton CMS3 config file '
    print '\t-d\t\tname of dataset'
    print '\t-t\t\tCMS3 tag'
    print '\t-gtag\t\tglobal tag'
    print '\nOptional arguments:'
    print '\t-strElem\tpreferred storage element. Default is T2_US_UCSD if left unspecified'
    print '\t-nEvts\t\tNumber of events you want to run on. Default is -1'
    print '\t-evtsPerJob\tNumber of events per job. Default is 20000'
    #print '\t-n\t\tName of output Ntuple file. Default is ntuple.root'
    print '\t-dbs\t\tdbs url'
    print '\t-re\t\tMessage Logger modulus for error reporting. Default is 1000'
    print '\t-sParms\t\tComma seperated, ordered list of Susy Parameter names.'
    sys.exit()


for i in range(0, len(sys.argv)):
    if sys.argv[i] == '-CMS3cfg':
        cmsswSkelFile = sys.argv[i+1]
    if sys.argv[i] == '-d':
        dataSet = sys.argv[i+1]
    if sys.argv[i] == '-lumisPerJob':
        numLumisPerJob = sys.argv[i+1]
    if sys.argv[i] == '-strElem':
        storageElement = sys.argv[i+1]
    if sys.argv[i] == '-t':
        tag  = str(sys.argv[i+1])
    if sys.argv[i] == '-dbs':
        dbs_url = str(sys.argv[i+1])
    if sys.argv[i] == '-re':
        report_every = str(sys.argv[i+1])
    if sys.argv[i] == '-gtag':
        global_tag = str(sys.argv[i+1])
    if sys.argv[i] == '-sParms':
        sParms = str(sys.argv[i+1]).split(',')

if os.path.exists(cmsswSkelFile) == False:
    print 'CMSSW skeleton file does not exist. Exiting'
    sys.exit()

if len(sParms) > 0:
    print 'Including sParmMaker with parameters: ',sParms

checkConventions()
makeCMSSWConfig(cmsswSkelFile)
makeCrab3Config()
