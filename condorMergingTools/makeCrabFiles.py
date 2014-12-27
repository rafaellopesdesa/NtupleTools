#! /usr/bin/env python

import string
import commands, os, re
import sys 
                      

cmsswSkelFile = ''
configPfx = 'cfg/'
psetPfx = 'pset/'
taskPfx = 'task/'
dataSet = ''
numEvtsTotal = -1
numEvtsPerJob = 20000
outNtupleName = 'ntuple.root'
storageElement = 'T2_US_UCSD'
tag = 'V07-00-03'
mode = 'remoteGlidein'
dbs_url = 'phys03'
report_every = 1000;
global_tag = '';
sParms = [];

fastSim = False;
MCatNLO = False;
isData  = False;

def makeCrabConfig():
    outFileName = dataSet.split('/')[1]+'_'+dataSet.split('/')[2]
    outFile = open(configPfx + outFileName + '.cfg', 'w')
    print 'Writing CRAB config file: ' + configPfx + outFileName + '.cfg'
    outFile.write('[CRAB]\n')
    outFile.write('jobtype   = cmssw\n')
    outFile.write('scheduler = ' + mode + '\n')
    outFile.write('use_server = ' + '0' + '\n')
    outFile.write('\n[CMSSW]\n')
    outFile.write('datasetpath             = ' + dataSet + '\n')
    outFile.write('dbs_url                 = ' + dbs_url + '\n')
    outFile.write('pset                    = ' + './' + psetPfx + outFileName + '_cfg.py \n')
    outFile.write('total_number_of_lumis   = -1\n')
    outFile.write('number_of_jobs          = 500\n')
    outFile.write('output_file             = ' + outNtupleName + '\n')
    if isData == True :
        outFile.write('total_number_of_lumis   = -1\n')
        outFile.write('lumis_per_job           = 1\n')
    outFile.write('\n[USER]\n')
    outFile.write('return_data             = 0\n')
    outFile.write('copy_data               = 1\n')
    outFile.write('storage_element         = ' + storageElement + '\n')
    outFile.write('ui_working_dir          = ' + taskPfx + outFileName + '\n')
    outFile.write('user_remote_dir         = ' + tag + '/' + outFileName + '\n')
    outFile.write('publish_data            = 0\n')
    outFile.write('\n[GRID]\n')
    
    outFile.write('##run at any US T2 site and access sample with xrootd \n')
    outFile.write('data_location_override = T2_US')
	 
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
    outFile.write( 'import sys, os' + '\n' + 'sys.path.append( os.getenv("CMSSW_BASE") + "/src/CMS2/NtupleMaker/test" )' + '\n' )
    for i in inFile:
        iline += 1
        if i.find('reportEvery') != -1:
            outFile.write('process.MessageLogger.cerr.FwkReport.reportEvery = ' + str(report_every) + '\n'); continue

        if i.find('globaltag') != -1:
            outFile.write('process.GlobalTag.globaltag = "' + global_tag + '"\n'); continue

        if (i.find('cms.Path') != -1 and foundcmsPath == False ):
            foundcmsPath = True            
            outFile.write('process.eventMaker.datasetName                   = cms.string(\"' + dataSet+'\")\n')
            outFile.write('process.eventMaker.CMS2tag                       = cms.string(\"' + tag+'\")\n')

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

    if( not os.path.isdir('./'+taskPfx) ):
        print 'Directory for tasks (%s) does not exist. Creating it.' % taskPfx
        os.makedirs('./'+taskPfx)
    
    print 'CRAB submission should happen outside of {%s,%s,%s}' % (configPfx, psetPfx, taskPfx)



if len(sys.argv) < 9 :
    print 'Usage: makeCrabFiles.py [OPTIONS]'
    print '\nWhere the required options are: '
    print '\t-CMS2cfg\tname of the skeleton CMS2 config file '
    print '\t-d\t\tname of dataset'
    print '\t-t\t\tCMS2 tag'
    print '\t-gtag\t\tglobal tag'
    print '\nOptional arguments:'
    print '\t-isData\t\tFlag to specify if you are running on data.'
    print '\t-strElem\tpreferred storage element. Default is T2_US_UCSD if left unspecified'
    print '\t-nEvts\t\tNumber of events you want to run on. Default is -1'
    print '\t-evtsPerJob\tNumber of events per job. Default is 20000'
    #print '\t-n\t\tName of output Ntuple file. Default is ntuple.root'
    print '\t-m\t\tsubmission mode (possible: condor_g, condor, glite). Default is glidein'
    print '\t-dbs\t\tdbs url'
    print '\t-re\t\tMessage Logger modulus for error reporting. Default is 1000'
    print '\t-sParms\t\tComma seperated, ordered list of Susy Parameter names.'
    print '\t-fastSim\t\tUse a subset of the sequence that is compatible with FastSim. Default is to not use it.'
    print '\t-MCatNLO\t\tUse a subset of the sequence that is compatible with MC@NLO samples. Default is to not use it.'
    sys.exit()


for i in range(0, len(sys.argv)):
    if sys.argv[i] == '-CMS2cfg':
        cmsswSkelFile = sys.argv[i+1]
    if sys.argv[i] == '-d':
        dataSet = sys.argv[i+1]
    if sys.argv[i] == '-nEvts':
        numEvtsTotal = sys.argv[i+1]
    if sys.argv[i] == '-evtsPerJob':
        numEvtsPerJob = sys.argv[i+1]
    if sys.argv[i] == '-strElem':
        storageElement = sys.argv[i+1]
    if sys.argv[i] == '-t':
        tag  = str(sys.argv[i+1])
    if sys.argv[i] == '-m':
        mode  = str(sys.argv[i+1])
    if sys.argv[i] == '-dbs':
        dbs_url = str(sys.argv[i+1])
    if sys.argv[i] == '-re':
        report_every = str(sys.argv[i+1])
    if sys.argv[i] == '-gtag':
        global_tag = str(sys.argv[i+1])
    if sys.argv[i] == '-sParms':
        sParms = str(sys.argv[i+1]).split(',')
    if sys.argv[i] == '-fastSim':
        fastSim = True
    if sys.argv[i] == '-MCatNLO':
        MCatNLO = True
    if sys.argv[i] == '-isData':
        isData = True

if os.path.exists(cmsswSkelFile) == False:
    print 'CMSSW skeleton file does not exist. Exiting'
    sys.exit()

if len(sParms) > 0:
    print 'Including sParmMaker with parameters: ',sParms

checkConventions()
makeCMSSWConfig(cmsswSkelFile)
makeCrabConfig()
