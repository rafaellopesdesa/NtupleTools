from CMS3.NtupleMaker.RecoConfiguration2015_cfg import *

#Global Tag
#process.GlobalTag.globaltag = "PHYS14_25_V2::All"
process.GlobalTag.globaltag = "SUPPLY_GLOBAL_TAG"

#Input
process.source = cms.Source("PoolSource",
  fileNames = cms.untracked.vstring(
  #'root://cmsxrootd.fnal.gov//store/cmst3/group/susy/gpetrucc/13TeV/Phys14DR/MINIAODSIM/T6ttWW_650_150_50_v2/T6ttWW_650_150_50_v2.MINIAODSIM01.root' 
  'SUPPLY_INPUT_FILE_NAME' 
),
)

#Output
process.out = cms.OutputModule("PoolOutputModule",
  #fileName     = cms.untracked.string('ntuple.root'),
  fileName     = cms.untracked.string('SUPPLY_OUTPUT_FILE_NAME'),
  dropMetaData = cms.untracked.string("NONE")
)
process.outpath = cms.EndPath(process.out)

#Max Events
process.maxEvents = cms.untracked.PSet( input = cms.untracked.int32(10) )

#Branches
process.out.outputCommands = cms.untracked.vstring( 'drop *' )
process.out.outputCommands.extend(cms.untracked.vstring('keep *_*Maker*_*_CMS3*'))
process.out.outputCommands.extend(cms.untracked.vstring('drop *_cms2towerMaker*_*_CMS3*'))
process.out.outputCommands.extend(cms.untracked.vstring('drop CaloTowers*_*_*_CMS3*'))

#Makers
process.p = cms.Path( 
  process.egmGsfElectronIDSequence *     
  process.beamSpotMaker *
  process.vertexMaker *
  process.secondaryVertexMaker *
  process.pfCandidateMaker *
  process.eventMaker *
  process.electronMaker *
  process.muonMaker *
  process.pfJetMaker *
  process.subJetMaker *
  process.pfmetMaker *
  process.hltMakerSequence *
  process.pftauMaker *
  process.photonMaker *
  process.genMaker *
  process.genJetMaker *
  process.muToTrigAssMaker *  # requires muonMaker
  process.elToTrigAssMaker *  # requires electronMaker
  process.candToGenAssMaker * # requires electronMaker, muonMaker, pfJetMaker, photonMaker
  process.pdfinfoMaker *
  process.puSummaryInfoMaker *
  process.recoConversionMaker *
  process.metFilterMaker *
  process.hcalNoiseSummaryMaker *
  process.miniAODrhoSequence *
  process.hypDilepMaker
)

#Options
process.MessageLogger.cerr.FwkReport.reportEvery = 100
process.eventMaker.isData                        = cms.bool(False)
process.luminosityMaker.isData                   = process.eventMaker.isData
