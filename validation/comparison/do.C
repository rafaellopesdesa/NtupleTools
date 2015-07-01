{
  gROOT->ProcessLine(".L ../../../Software/dataMCplotMaker/dataMCplotMaker.cc+");
  gROOT->ProcessLine(".L compareNtuples.C+");
  gROOT->ProcessLine("compareNtuples( \
    \"/hadoop/cms/store/user/cgeorge/WJetsToLNu_HT-400to600_Tune4C_13TeV-madgraph-tauola/crab_WJetsToLNu_HT-400to600_Tune4C_13TeV-madgraph-tauola_Phys14DR-PU20bx25_PHYS14_25_V1-v1/150404_082708/0000/ntuple_152.root\", \
    \"/hadoop/cms/store/user/cgeorge/QCD_Pt_170to250_bcToE_TuneCUETP8M1_13TeV_pythia8/crab_QCD_Pt_170to250_bcToE_TuneCUETP8M1_13TeV_pythia8_RunIISpring15DR74-Asympt25ns_MCRUN2_74_V9-v1/150610_195927/0000/ntuple_101.root\",  \
    true, false)");

}

//    \"/hadoop/cms/store/group/snt/phys14/TTJets_MSDecaysCKM_central_Tune4C_13TeV-madgraph-tauola_Phys14DR-PU20bx25_PHYS14_25_V1-v1/V07-02-08/merged_ntuple_2.root\", \
