{
  gROOT->ProcessLine(".L compareNtuples.C+");
  gROOT->ProcessLine("compareNtuples( \
    \"/hadoop/cms/store/group/snt/phys14/TTJets_MSDecaysCKM_central_Tune4C_13TeV-madgraph-tauola_Phys14DR-PU20bx25_PHYS14_25_V1-v1/V07-02-08/merged_ntuple_2.root\", \
    \"/home/users/cgeorge/CMS3/CMSSW_7_4_1_patch1/src/CMS3/NtupleMaker/ntuple.root\",  \
    true, false)");

}

//    \"/hadoop/cms/store/group/snt/phys14/TTJets_MSDecaysCKM_central_Tune4C_13TeV-madgraph-tauola_Phys14DR-PU20bx25_PHYS14_25_V1-v1/V07-02-08/merged_ntuple_2.root\", \
