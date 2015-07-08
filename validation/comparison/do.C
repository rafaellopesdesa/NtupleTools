{
  gROOT->ProcessLine(".L /home/users/sicheng/tas/Software/dataMCplotMaker/dataMCplotMaker.cc+");
  gROOT->ProcessLine(".L compareNtuples.C+");
  gROOT->ProcessLine("compareNtuples( \
    \"/home/users/sicheng/play/comparison/merged_ntuple_143.root\",  \
    \"/home/users/sicheng/play/comparison/merged_ntuple_9.root\",  \
    true, false, 0.95)");

}

    // \"/hadoop/cms/store/group/snt/phys14/TTJets_MSDecaysCKM_central_Tune4C_13TeV-madgraph-tauola_Phys14DR-PU20bx25_PHYS14_25_V1-v1/V07-02-08/merged_ntuple_143.root\", \
    // \"/hadoop/cms/store/group/snt/phys14/TTJets_MSDecaysCKM_central_Tune4C_13TeV-madgraph-tauola_Phys14DR-PU20bx25_PHYS14_25_V1-v1/V07-02-08/merged_ntuple_143.root\", \
