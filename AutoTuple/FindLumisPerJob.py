#!/usr/bin/env python
# https://twiki.cern.ch/twiki/bin/view/CMS/DBS3APIInstructions
import  sys
from dbs.apis.dbsClient import DbsApi

if(len(sys.argv) < 2):
    print "Give me an arg!"
    sys.exit()

# dataset='/DYJetsToLL_M-50_Zpt-150toInf_TuneCUETP8M1_13TeV-madgraphMLM-pythia8/RunIISpring15DR74-Asympt25ns_MCRUN2_74_V9-v1/MINIAODSIM'
dataset = sys.argv[-1]
evt_per_job = 30000
url="https://cmsweb.cern.ch/dbs/prod/global/DBSReader"
api=DbsApi(url=url)
output = api.listDatasets(dataset=dataset)

if(len(output)==1):
    inp=output[0]['dataset']
    info = api.listFileSummaries(dataset=inp)[0]

    nevents = info['num_event']
    nlumis = info['num_lumi']
    evt_per_lumi = 1.0*nevents/nlumis
    lumi_per_job = evt_per_job/evt_per_lumi

    dump = api.listFiles(dataset=dataset, detail=1, validFileOnly=1)
    nevents = []; 
    for i in range(0,len(dump)):
      nevents.append(dump[i]['event_count'])
  
    if (max(nevents) > 15000 and max(nevents) < 70000):
      print "FILEBASED"
    else:
      print int(lumi_per_job+1)

